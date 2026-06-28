local M = {}
local __ChatClient = CS.ChatClient.Instance
local __CHAT_CHANNEL = {LOCAL = 1, WORLD = 2, GUILD = 3, PRIVATE = 4}
local __CHANGE_ADDRESS_TIMES = 1 --重连切换地址的次数
local __MAX_CHANGE_LOOP_TIMES = 1 --切换一组地址的最大次数 这一组地址循环1次重连失败后，请求短连接更换新的地址组后 重置为0
local __CHANGE_LOOP_TIMES = 0 --切换一组地址的当前次数 这一组地址循环__MAX_CHANGE_LOOP_TIMES次重连失败后，请求短连接更换新的地址组
local __TOTAL_MAX_CHANGE_NET_TIMES = 2 --切换一组地址的最大次数 请求短连接更换新的地址组后 不重置为0
local __CUR_CHANGE_LOOP_TIMES = 0 --切换一组地址的最大次数 超过之后__TOTAL_MAX_CHANGE_TIMES断开连接不再重连，请求短连接更换新的地址组后 不重置为0
local __DISCONNECT_BY_LUA = false --当前是否有客户端主动断开连接
M.pb = require "pb"
M.pbs = require "Net.pbs"
M.pbc = require "Net.protoc"
assert(M.pbc:load(M.pbs.chat))

M.cur_input_msg = nil
M.type_detail_sort = 1  -- 1:最近登录时间, 2:最近聊天时间
M.type_select_index = 1
M.cur_private_uid = nil  -- uid / nil
M.read_tss = {}  -- read_tss[channel/uid] = ts
M.player_red_points = {}  -- player_red_points[uid] = 1 / nil
M.channel_red_points = {}  -- channel_red_point[channel] = true / false

function M:initData()
    self.msgs = self.msgs or {}
    self.player_names = self.player_names or {}  -- player_names[name] = uid / nil，包含历史姓名
    self.private_uids = self.private_uids or {}  -- private_uids[uid] = name / nil，包含最新姓名
    if self.private_player_avatar == nil then
        self.private_player_avatar = {}
    end
    self.channel_msgs = {}  -- channel_msgs[channel][uid] = msgs{}
    self.m_latest_private_msg = {}
    self.m_channel_cd_limit = self.m_channel_cd_limit or {}
    self.m_channel_times_limit = self.m_channel_times_limit or {}
    self.channel_msgs[__CHAT_CHANNEL.LOCAL] = {}  -- 本地频道
    self.channel_msgs[__CHAT_CHANNEL.WORLD] = {}  -- 世界频道
    self.channel_msgs[__CHAT_CHANNEL.GUILD] = {}  -- 帮派频道
    self.channel_msgs[__CHAT_CHANNEL.PRIVATE] = {}  -- 私聊频道
    self.m_heart_times = 0
end

--连接聊天服务器
function M:connectChatServer(need_change_address)
    local self_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")

    local function sortMsg(msg, is_login)
        table.insert(self.msgs, msg)
        local channel = tonumber(msg.channel_type)
        if channel == __CHAT_CHANNEL.PRIVATE then
            table.insert(self.m_latest_private_msg, msg)
            self.channel_msgs[channel] = self.channel_msgs[channel] or {}
            if self_uid == msg.uid then
                local private_uid = tonumber(msg.channel_id)
                self.private_uids[private_uid] = msg.target_name
                self.player_names[msg.target_name] = private_uid
                self.channel_msgs[channel][private_uid] = self.channel_msgs[channel][private_uid] or {}
                table.insert(self.channel_msgs[channel][private_uid], msg)
            else
                local private_uid = msg.uid
                self.private_uids[private_uid] = msg.name
                self.player_names[msg.name] = msg.uid
                self.private_player_avatar[msg.name] = msg.avatar
                self.channel_msgs[channel][private_uid] = self.channel_msgs[channel][private_uid] or {}
                table.insert(self.channel_msgs[channel][private_uid], msg)
                EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHAT_NEW_PRIVATE)
            end
        else
            self.channel_msgs[channel] = self.channel_msgs[channel] or {}
            table.insert(self.channel_msgs[channel], msg)
        end
    end

    self:initData()
    local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id") or 0
    if guild_id ~= 0 then
        self.channel_msgs[__CHAT_CHANNEL.GUILD] = {} --工会频道
    end

    __ChatClient:RegisterLuaChatMgr(
            function(msg_data)
                local cmd_id = msg_data._cmdId
                local bytes = msg_data._bytes

                local newByte_decrypt = CS.Xxtea.XXTEA.Decrypt(bytes, UserDataManager.client_data.crypto_key)
	            local newByte_decomp = CS.wt.framework.GZipHelper.GzipDecompress(newByte_decrypt)--, __LuaFileHelper.xxteaKey)

                local data = assert(ChatUtil.pb.decode("chat.ChatResponsePack", newByte_decomp))
                if data.result.code == 0 then
                    local res = data["res" .. cmd_id]
                    self:updateCDLimits(res)
                    self:updateTimesLimits(res)
                    if cmd_id == 1 then
                        __CUR_CHANGE_LOOP_TIMES = 0
                        self:initReadTs(res.tss)
                        local function sort_func(data1, data2)
                            return data1.time < data2.time
                        end
                        table.sort(res.msgs, sort_func)
                        for i, msg in pairs(res.msgs) do
                            if not(UserDataManager:isInBlackList(msg.uid)) then
                                sortMsg(msg)
                            end
                        end
                        self:updateRedPointData()
                        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHAT_INIT)
                    elseif cmd_id == 2 then
                        if not(UserDataManager:isInBlackList(res.uid)) then
                            sortMsg(res)
                            local channel = tonumber(res.channel_type)
                            local is_open = static_rootControl:hasChild("Chat2")
                            local self_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
                            local uid = self_uid == res.uid and tonumber(res.channel_id) or res.uid
                            if not is_open then  -- 聊天窗口是否打开
                                self:updateRedPointData()
                            else
                                if channel ~= G_CHAT_CHANEL then  -- 消息是否来自当前频道
                                    self:updateRedPointData()
                                else
                                    if channel ~= __CHAT_CHANNEL.PRIVATE then  -- 当前频道是否为私聊
                                        self:updateReadTs(channel)
                                    else
                                        if uid ~= self.cur_private_uid then  -- 消息是否来自当前对话框
                                            self:updateRedPointData()
                                        else
                                            self:updateReadTs(channel, uid)
                                        end
                                    end
                                end
                            end
                            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHAT_REFRESH)
                        end
                    elseif cmd_id == 9 then
                        self:updateGameAction(res)
                    end
                elseif data.result.code == 1500 then --多点登录错误码，在通用网络回调中处理，聊天服务器中不进行处理
                else
                    local tips_msg = data.result.msg
                    if static_rootControl then
                        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey(tips_msg), delay_close = 2})
                    end
                end
            end
    )
   
    local chat_address_tab = UserDataManager.server_data:getServerData().chat_addr_list
    local chat_ip, chat_port = nil, nil
    local chat_address_index = 1
    local net_lock = false
    if need_change_address and chat_address_tab and next(chat_address_tab) then --socket那边重连三次发现连接失败则需要切换一次聊天的ip和port
        __CHANGE_ADDRESS_TIMES  = __CHANGE_ADDRESS_TIMES + 1
        local address_index = __CHANGE_ADDRESS_TIMES % #chat_address_tab
        if address_index == 0 or #chat_address_tab == 1 then
            address_index = #chat_address_tab
            __CHANGE_LOOP_TIMES = __CHANGE_LOOP_TIMES + 1
            if __CHANGE_LOOP_TIMES > __MAX_CHANGE_LOOP_TIMES then  --遍历请求地址表轮数超过__MAX_CHANGE_LOOP_TIMES次时，请求user_get_idle_connector 更新地址表
                net_lock = true
                local function netDataCallBack(response)
                    __CHANGE_ADDRESS_TIMES = 0
                    __CHANGE_LOOP_TIMES = 0
                    __CUR_CHANGE_LOOP_TIMES = __CUR_CHANGE_LOOP_TIMES + 1
                    address_index = 1
                    chat_address_index = address_index
                    if response.chat_addr_list then
                        UserDataManager.server_data:getServerData().chat_addr_list = response.chat_addr_list
                        chat_address_tab = response.chat_addr_list
                    end
                    if response.chat_addr then
                        UserDataManager.server_data:getServerData().chat_addr = response.chat_addr
                    end
                    self:changeIpToConnect(chat_address_tab, chat_address_index)
                   
                    if __CUR_CHANGE_LOOP_TIMES > __TOTAL_MAX_CHANGE_NET_TIMES then --重试太多次了断开连接
                        self:closeSocket()
                        __CUR_CHANGE_LOOP_TIMES = 0
                        __DISCONNECT_BY_LUA = true
                    end
                end
                local function requestChangeNet(random_time)
                    if static_rootControl then
                        local random_time = random_time or math.random(1, 10)
                        static_rootControl:setOnceTimer(random_time, function ()
                            local net_type = GameUtil:getNetworkReachability()
                            if net_type == "nil" then
                                requestChangeNet(30)
                            else
                                static_rootControl.m_model:getNetData("user_get_idle_connector", nil, netDataCallBack, 0);
                            end
                        end)
                    end
                end
                requestChangeNet()
            end
        end
        --遍历聊天地址表chat_address_tab中的ip和端口
        chat_address_index = address_index
    end
    if not(net_lock) then
        self:changeIpToConnect(chat_address_tab, chat_address_index)
    end
end

function M:changeIpToConnect(chat_address_tab, chat_address_index)
    local chat_ip, chat_port = nil, nil
    if chat_address_tab and chat_address_tab[chat_address_index] and chat_address_tab[chat_address_index][1] then
        chat_ip = chat_address_tab[chat_address_index][1]
        chat_port = chat_address_tab[chat_address_index][2]
    end
    if chat_ip == nil then --新的聊天地址表为空的时候走老的数据
        chat_ip =  UserDataManager.server_data:getServerData().chat_addr[1]
        chat_port = UserDataManager.server_data:getServerData().chat_addr[2]
    end
    __ChatClient:Connect(
            chat_ip,
            chat_port,
            handler(self, self.eventAction)
    )
end

function M:updateCDLimits(res)
    local cd = 0
    local cd_type = "0"
    if res and res.cd_limit and next(res.cd_limit) then
        cd = res.cd_limit.cd
        cd_type = res.cd_limit.cd_type
    end
    if cd_type ~= "0" then
        if self.m_channel_cd_limit[cd_type] == nil then
            self.m_channel_cd_limit[cd_type] = 0
        end
        self.m_channel_cd_limit[cd_type] = cd
    end
end

function M:updateTimesLimits(res)
    local times = 0
    local channel_type = "0"
    if res and res.times_limit and next(res.times_limit) then
        times = res.times_limit.times
        channel_type = res.times_limit.channel_type
    end
    if channel_type ~= "0" then
        if self.m_channel_times_limit[channel_type] == nil then
            self.m_channel_times_limit[channel_type] = 0
        end
        self.m_channel_times_limit[channel_type] = times
    end
end

function M:isTimesByType(cd_type)
    local is_max_times = false
    local need_stage = 0
    local tips_stage = 0
    local cfg_id = cd_type == __CHAT_CHANNEL.PRIVATE and 456 or 455
    local cfg_limit_time = ConfigManager:getCommonValueById(cfg_id, {})
    local no_limit_stage = ConfigManager:getCommonValueById(457, 0)
    need_stage = cfg_limit_time[1] and cfg_limit_time[1] or 0
    local tips_stage = 0
    local stage_id = UserDataManager:getCurStage()
    local tips_id = ""
    if stage_id >= no_limit_stage then
        is_max_times = false
    elseif stage_id >= need_stage then
        local cur_times = 0
        if self.m_channel_times_limit[tostring(cd_type)] then
            cur_times = self.m_channel_times_limit[tostring(cd_type)]
        end
        local limit_times = cfg_limit_time[2] and cfg_limit_time[2] or 9999
        if cur_times >= limit_times then
            is_max_times = true
            tips_stage = no_limit_stage
            tips_id = "new_str_0962"
        else
            is_max_times = false
        end
    else
        is_max_times = true
        tips_stage = need_stage
        tips_id = "new_str_0961"
    end
    return is_max_times, tips_stage
end

function M:isCdByType(cd_type)
    if self.m_channel_cd_limit[tostring(cd_type)] then
        local cd = self.m_channel_cd_limit[tostring(cd_type)]
        local server_time = UserDataManager:getServerTime()
        local cfg_id = 458
        if cd_type == __CHAT_CHANNEL.PRIVATE then
            cfg_id = 459
        elseif cd_type == __CHAT_CHANNEL.GUILD then
            cfg_id = 478
        end
        local cfg_cd_time = ConfigManager:getCommonValueById(cfg_id, 0)
        local time = server_time - cd
        return  server_time - cd <= cfg_cd_time
    end
    return false
end

-- 聊天时间戳
function M:initReadTs(tss)
    for _,v in ipairs(tss) do
        local id = tonumber(v.channel_id)
        local ts = tonumber(v.ts)
        self.read_tss[id] = ts
    end
end

function M:updateReadTs(channel, uid)
    local msgs
    local channel_or_uid
    if channel ~= __CHAT_CHANNEL.PRIVATE then
        channel_or_uid = channel
        msgs = self.channel_msgs[channel] or {}
    elseif uid ~= nil then
        channel_or_uid = uid
        msgs = self.channel_msgs[__CHAT_CHANNEL.PRIVATE][uid] or {}
    elseif self.cur_private_uid ~= nil then
        uid = self.cur_private_uid
        channel_or_uid = uid
        msgs = self.channel_msgs[__CHAT_CHANNEL.PRIVATE][uid] or {}
    else 
        return
    end
    
    local last_msg = msgs[#msgs]
    local ts = last_msg ~= nil and tonumber(string.sub(last_msg.time, 1, 10)) or 0
    self.read_tss[channel_or_uid] = ts
    
    local data = {}
    data["req8"] = {}
    data["req8"]["ts"] = tostring(ts)
    data["req8"]["channel_type"] = tostring(channel)
    data["req8"]["target_uid"] = uid ~= nil and tostring(uid) or nil
    
    local bytes = assert(self.pb.encode("chat.ChatRequestPack", data))
    local newByte_comp = CS.wt.framework.GZipHelper.GzipCompress(bytes)
    local newByte_decrypt = CS.Xxtea.XXTEA.Encrypt(newByte_comp, UserDataManager.client_data.crypto_key)
    __ChatClient:SendMsg(newByte_decrypt, 8)
end

-- 更新红点数据
function M:updateRedPointData()
    -- 更新玩家红点
    for uid,_ in pairs(self.private_uids) do
        local player_msgs = self.channel_msgs[__CHAT_CHANNEL.PRIVATE][uid] or {}
        local last_msg_index = #player_msgs
        if last_msg_index == 0 then
            self.player_red_points[uid] = nil
        else
            local read_ts = self.read_tss[uid] or 0
            local last_msg_ts_str = string.sub(player_msgs[last_msg_index].time, 1, 10)
            local last_msg_ts = tonumber(last_msg_ts_str)
            self.player_red_points[uid] = last_msg_ts > read_ts and 1 or nil
        end
    end
    
    -- 更新频道红点
    for i = 1, 4 do
        if i ~= __CHAT_CHANNEL.PRIVATE then
            local last_msg_index = #self.channel_msgs[i]
            if last_msg_index == 0 then
                self.channel_red_points[i] = false
            else
                local read_ts = self.read_tss[i] or 0
                local last_msg_ts_str = string.sub(self.channel_msgs[i][last_msg_index].time, 1, 10)
                local last_msg_ts = tonumber(last_msg_ts_str)
                self.channel_red_points[i] = last_msg_ts > read_ts
            end
        else
            local has_player_red_point = next(self.player_red_points) ~= nil
            self.channel_red_points[__CHAT_CHANNEL.PRIVATE] = has_player_red_point
        end
    end
end

function M:updateGameAction(res)
    local jsonData = nil
    if res.json_data then
        jsonData = Json.decode(res.json_data)
    end
    if res.event_type then
        if res.event_type == "test" then
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.COMMON_REFRESH)
        elseif  res.event_type == "rta.sync" then
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.RTA_SYNC,{event_type=res.event_type,sync_data=jsonData})
        end
    end
end



function M:hasChannelRedPoint(channel)
    return self.channel_red_points[channel] or false 
end

function M:hasPlayerRedPoint(uid)
    return self.player_red_points[uid] or false
end

function M:getLatestPrivateMsg()
    return self.m_latest_private_msg
end

function M:getChannelMsg(channel, uid)
    if channel == __CHAT_CHANNEL.PRIVATE then
        if uid and self.channel_msgs[channel] then
            return self.channel_msgs[channel][uid] or {}
        else
            return {}
        end
    else
        return self.channel_msgs[channel] or {}
    end
end

function M:eventAction(event_name)
    if event_name == "connect_success" then
        self:initData()
        self:login()
    elseif event_name == "reconnect_success" then
        -- if static_rootControl then
        --     GameUtil:lookInfoTips(static_rootControl, { msg = Language:getTextByKey("new_str_0423"), delay_close = 2})
        -- end
        self:initData()
        self:login()
    elseif event_name == "disconnect" then
        -- if static_rootControl then
        --     GameUtil:lookInfoTips(static_rootControl, { msg = Language:getTextByKey("new_str_0424"), delay_close = 2})
        -- end
    elseif event_name == "send_data_failed" then
        self:changeAddress()
        if static_rootControl then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("new_str_0425"), delay_close = 2})
        end
    elseif event_name == "change_address" then
        self:changeAddress()
    end
end

function M:changeAddress()
    self:closeSocket()
    if static_rootControl then
        static_rootControl:setOnceTimer(0.2, function()
            self:connectChatServer(true)
            local bytes =
            assert(self.pb.encode("chat.ChatRequestPack", {["req5"] = {uid = UserDataManager.user_data:getUid()}}))
            __ChatClient:SetHeartbeatByte(bytes, 5)
        end)
    end
end

function M:login()
    local data = {
        uid = UserDataManager.user_data:getUid(),
        new_sid = tostring(UserDataManager.server_data:getUserSid()),
        Language = "CN",
        server_id = tostring(UserDataManager.server_data:getServerId()),
        guild_id = tostring(UserDataManager.user_data:getUserStatusDataByKey("guild_id") or 0)
    }
    self:sendMsg(data, 1)
    local bytes =
    assert(self.pb.encode("chat.ChatRequestPack", {["req5"] = {uid = UserDataManager.user_data:getUid()}}))
    __ChatClient:SetHeartbeatByte(bytes, 5)
end

--打开界面时绑定网络返回方法
function M:bindFunc(func)
    self.receive_func = func
end

--关闭界面时解绑
function M:unbindFunc()
    self.receive_func = nil
end

--向服务器发送聊天消息，可以在这里添加时间限制
function M:sendMsg(msg_data, cmd_id)
    if __DISCONNECT_BY_LUA and static_rootControl then
        __DISCONNECT_BY_LUA = false
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("new_str_0425"), delay_close = 2})
        self:connectChatServer()
    else
        local data = {}
        data["req" .. cmd_id] = msg_data
        local bytes = assert(self.pb.encode("chat.ChatRequestPack", data))

        local newByte_comp = CS.wt.framework.GZipHelper.GzipCompress(bytes)
        
        local newByte_decrypt = CS.Xxtea.XXTEA.Encrypt(newByte_comp, UserDataManager.client_data.crypto_key)
        __ChatClient:SendMsg(newByte_decrypt, cmd_id)

    end
end

function M:closeSocket()
    __ChatClient:CloseChatSocket()
end

function M:setRTAHeartInternal(internal)
    self.m_rta_heart_internal = internal
end

function M:resetRTAHeart()
    self.m_heart_cd = self.m_rta_heart_internal
end

function M:cancelRTAHeart()
    self.heartStarted=false
end

function M:startRTAHeart()
    self:resetRTAHeart()
    self.heartStarted=true
    if self.m_heart_timer == nil then
        local function heart_tick(_, dt)
            if self.heartStarted then
                self.m_heart_cd = self.m_heart_cd - dt
                if self.m_heart_cd <= 0 then

                    --local callfunc=function()
                    --    Logger.log("heart tick --------")
                    --end
                    --self.m_model:getNetData("user_heartbeat", nil, callfunc, 0)
                    EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.RTA_SYNC,{event_type="rta.sync"})
                    self:resetRTAHeart()
                end
            end
        end
        self.m_heart_timer = static_rootControl:setTimer(1, heart_tick)
    end
end

return M
