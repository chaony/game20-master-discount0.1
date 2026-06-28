local M = class("XianModel", LikeOO.OODataBase)

M.GREETING = {"早上", "上午", "中午", "下午", "晚上"}

function M:onCreate()
    M.super.onCreate(self)
    self:getData("welfare_npc_index")
end

function M:onEnter()
    self.festival_type = 0-- 节日类型 0默认, 1五一, 2十一, 3元旦, 4圣诞, 5春节, 6七夕
    self:readFestivalData()
    self.m_open_npc_guide = self.m_params.open_npc_guide 
    
    self.priority_hight_list = {} --点击领奖聊天列表
    self.m_sceneId = self.m_data.scene or 0
    self.m_skin_id = self.m_data.skin_id --风华录角色
    --第一次进入的等待时间
    self.m_fristInTime = 4
    self.m_curFristInTime = self.m_fristInTime
    --气泡存在事件
    self.m_showTime = 4
    self.m_curShowTime = 0
    --每8 秒显示一句自主对白
    self.m_randomTime = 8
    self.m_curRandomTime = self.m_randomTime
    self.m_vip = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
    self.m_vip_exp = UserDataManager.user_data:getUserStatusDataByKey("vip_exp") or 0
    self:resetGreetList()
    self.npc_guide_tab = self:getNpdGuideTab()
    self.m_welf_table = self:getWelfTable()
    self:checkFirstTimeBucket()
    local vip_tab = ConfigManager:getCfgByName("vip")
    local max_num = table.nums(vip_tab) 
    self.max_vip = max_num - 1
end


function M:resetRandomTime()
    self.m_curRandomTime = self.m_randomTime
end

function M:readFestivalData()
    local npc_festival = ConfigManager:getCfgByName("npc_festival")
    local cur_tim = UserDataManager:getServerTime()
    for k,v in pairs(npc_festival) do
        local star_tim = v.start_time
        local end_time = v.end_time
        local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
        if #star_tim > 0 then
            local y, mon, d, h, min, s = star_tim:match(pattern)  --string.match(star_tim)
            local e_y, e_mon, e_d, e_h, e_min, e_s = end_time:match(pattern)
            local timeChu = os.time({day=d, month=mon, year=y, hour=h, minute=min, second=s})
            local end_timeChu = os.time({day=e_d, month=e_mon, year=e_y, hour=e_h, minute=e_min, second=e_s})
            if cur_tim >= timeChu and cur_tim<= end_timeChu then
                self.festival_type = k
                break
            end
        end
    end
end

function M:updateVipData()
    self.m_vip = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
    self.m_vip_exp = UserDataManager.user_data:getUserStatusDataByKey("vip_exp") or 0
end

function M:updateData(data)
    if data.mails then
        self.m_data.mails = data.mails
    end
    if data.notices then
        self.m_data.notices = data.notices
    end
    if data.code then
        self.m_data.code = data.code
    end
    self:resetGreetList()
end

function M:removeCode(data)
    if self.m_data.codes[tostring(data.code_id)] then
        self.m_data.codes[tostring(data.code_id)] = nil
    end
end

function M:updateOneCode(data)
    for i, v in pairs(self.m_data.codes) do
        if data.id == i then
            self.m_data.codes[i] = data.code
            break
        end
    end
end

function M:updateOnMail(data)
    for i, v in pairs(self.m_data.mails) do
        if data.id == i then
            self.m_data.mails[i] = data.data
            break
        end
    end
    self:resetGreetList()
end

function M:updateOnNotice(data)
    for i, v in pairs(self.m_data.notices) do
        if v.nid == data then
            v.status = 1
            break
        end
    end
    self:resetGreetList()
end

--问候列表
function M:resetGreetList()
    self.greet_list = {}
    local tb_cfg = self:getTimBuckCfg()
    if tb_cfg then
        for k, v in pairs(tb_cfg.dialogue) do
            local dia = self:getDiaById(v)
            if next(dia) ~= nil then
                table.insert(self.greet_list, dia)
            end
        end
    end
    
    -- 邮件
    --for k, v in pairs(self.m_data.mails) do
    --    if v.status == 0 then
    --        if #v.dialogue > 0 then
    --            local talks = string.split(v.dialogue, "|")
    --            for i = 1, table.nums(talks) do
    --                table.insert(self.greet_list, {type = 1, des = talks[i]} )
    --            end
    --        end
    --    end
    --end
    
    -- 读取公告
    --for k, v in pairs(self.m_data.notices) do
    --    if v.status == 0 then
    --        if #v.dialogue > 0 then
    --            local talks = string.split(v.dialogue, "|")
    --            for i = 1, table.nums(talks) do
    --                table.insert(self.greet_list, {type = 1, des = talks[i]} )
    --            end
    --        end
    --    end
    --end
end

function M:getNpdGuideTab()
    local shouce_tab = self:getNpcGuide()
    local new_list = {}
    if shouce_tab then
        for k,v in pairs(shouce_tab) do
            local dia = self:getDiaById(v.dialogue2)
            if next(dia) ~= nil then
                table.insert(new_list, dia)
            end
        end
    end
    return new_list
end


function M:updateWelfares(id, data)
    if id then
        if self.m_data.welfares[id] then
            self.m_data.welfares[id] = data
        end
    end
    self.m_welf_table = self:getWelfTable()
end

function M:checkWelfares()
    for k, v in pairs(self.m_data.welfares) do
        if v.status == 0 then
            return true
        elseif v.status == 1 and next(v.gifts) ~= nil then
            return true
        end
    end
    return false
end

function M:getWelfData()
    for k, v in pairs(self.m_data.welfares) do
        if v.status == 0 then
            return k
        elseif v.status == 1 and next(v.gifts) ~= nil then
            return k
        end
    end
    return nil
end

function M:getWelfTable()
    local rew_tab = {}
    for k, v in pairs(self.m_data.welfares) do
        if v.status == 0 then
            table.insert(rew_tab, {id = k, data = v})
        end
    end
    local function sortFunc(id_one, id_two)
        local nid_1 = tonumber(id_one.id) 
        local nid_2 = tonumber(id_two.id)
        return nid_1 < nid_2
    end
    table.sort(rew_tab, sortFunc)
    return rew_tab
end

function M:checkMailRedPoint()
    for k, v in pairs(self.m_data.codes) do
        if v.status == 0 then
            return true
        end
    end
    return false
end

function M:checkNoticeRedPoint()
    for k, v in pairs(self.m_data.notices) do
        if v.status == 0 then
            return true
        end
    end
    return false
end

function M:checkShouceRedPoint()
    return RedPointUtil:hasRedPointById(10003)
end

--获取触摸时候的对话数据
function M:getTouchRandomTalkData()
    local cur_dia_cfg = self:getTimBuckCfg()
    if cur_dia_cfg then
        local index = math.random(1,#cur_dia_cfg.click)
        return self:getDiaById(cur_dia_cfg.click[index])
    end
    return nil
end


--进入问候
function M:getEnterGreeting()
    local cur_dia_cfg = self:getTimBuckCfg()
    if cur_dia_cfg then
        if self:isFirstGetting() == true then
            return self:getDiaById(cur_dia_cfg.regards_first[1])
        else
            --每次进入随机问候
            local len = #cur_dia_cfg.regards_then
            local index = math.random(1,len )
            return self:getDiaById(cur_dia_cfg.regards_then[index])
        end
    end
    return nil
end

--是否是当前时间段首次问候
function M:isFirstGetting()
    local day = GameUtil:dayCompute()
    local tim_b = self:getCurTimeBucket()
    local is_first = UserDataManager.local_data:getUserDataByKey("time_first_" .. day.."_"..tim_b, 0)
    if is_first == 0 then
        UserDataManager.local_data:setUserDataByKey("time_first_" .. day.."_"..tim_b, 1)
        return true
    else
        return false    
    end
    return false
end

function M:getTimBuckCfg()
    local all_cfg = ConfigManager:getCfgByName("npc_dialogue")
    local cfg = all_cfg[self.m_skin_id]
    if cfg == nil then
        return nil
    end
    local tim_b = self:getCurTimeBucket()
    return cfg[tim_b]
    --for i, v in ipairs(cfg) do
    --    if v.sort == tim_b then
    --        return v
    --    end
    --end
end

function M:getDiaById(id)
    local dialogui_cfg = ConfigManager:getCfgByName("npc_dialogue_guide")
    local dia_cfg = dialogui_cfg[id]
    local cfg_type = dia_cfg.config[self.festival_type] or dia_cfg.config[0]
    return cfg_type
end

--随机问侯
function M:getGreeting()
    local len = #self.greet_list
    if len == 0 then
        return nil
    end
    local index = math.random(0, len)
    return self.greet_list[index]
end

--是否为某个时间段的首次进入
function M:checkFirstTimeBucket()
    local day = GameUtil:dayCompute() --注册天数
    local time_b = self:getCurTimeBucket() -- 当前时间段
    local f_b = UserDataManager.local_data:getUserDataByKey("xian_" .. day .. "_" .. time_b, 0)
    if f_b == 0 then
        self.first_time_bucket = true
        UserDataManager.local_data:setUserDataByKey("xian_" .. day .. "_" .. time_b, 1)
    else
        self.first_time_bucket = false
    end
end

function M:getCurTimeBucket()
    local server_ts = UserDataManager:getServerTime()
    local data = os.date("*t", server_ts)
    if data.hour >= 5 and data.hour < 8 then
        return 1 -- 早上
    elseif data.hour >= 8 and data.hour < 11 then
        return 2 -- 上午
    elseif data.hour >= 11 and data.hour < 13 then
        return 3 -- 中午
    elseif data.hour >= 13 and data.hour < 18 then
        return 4 -- 下午
    elseif data.hour >= 18 or data.hour < 5 then
        return 5 -- 晚上
    end
    return 1
end

function M:getAllTalk()
end

function M:getVipProgress()
    local vip_tab = ConfigManager:getCfgByName("vip")
    local max_num = table.nums(vip_tab) 
    if max_num > self.m_vip+1 then
        local next_cfg = vip_tab[self.m_vip+1]
        return self.m_vip_exp, next_cfg.exp
    else
        local max_cfg = vip_tab[max_num-1]
        return self.m_vip_exp, max_cfg.exp     
    end
end

function M:getItems()
    local item_ids = UserDataManager.item_data:getItemsId()
    local item_table = {}
    for k,v in pairs(item_ids) do
        local data, cfg = UserDataManager.item_data:getItemDataById(v)
        if cfg and cfg.type == 16 then
            table.insert( item_table, v)
        end
    end
    local function sortTable(oid1, oid2)
        local data1, cfg1 = UserDataManager.item_data:getItemDataById(oid1)
        local data1, cfg2 = UserDataManager.item_data:getItemDataById(oid2)
        if cfg1 and cfg2 then 
            return cfg1.quality < cfg2.quality
        else 
            return true
        end
    end
    table.sort(item_table, sortTable)
    return item_table
end


function M:checkVipRedPoint()
    for i = 0, self.m_vip do
        local status = self:checkCanGet(i)
        if status == 1 then
            return true
        end
    end
    return false
end

function M:checkCanGet(index)
    if index == 0 then
        return 0
    end
    local vip_received = UserDataManager.vip_received 
    if self.m_vip >= index then
        for k,v in pairs(vip_received) do
            if v == index then
                return 2
            end
        end
        return 1
    else
        return 0    
    end
    return 0
end

function M:getXianGiftDialogData(num)
    local dialogui_cfg = ConfigManager:getCfgByName("npc_dialogue_guide")
    local stage = 1  --好感度阶数
    local sort = 1
    if self.m_vip >= 12 then
        stage = 4
    elseif self.m_vip >= 8 then
        stage = 3
    elseif self.m_vip >= 4 then
        stage = 2
    else
        stage = 1           
    end
    if num >= 50 then
        sort = 2
    else
        sort = 1
    end
    local cfg_list = {}
    for k,v in pairs(dialogui_cfg) do
        local c_cfg = v.config[self.festival_type]
        if c_cfg.sort == sort and c_cfg.stage == stage then
            table.insert(cfg_list, c_cfg)
        end
    end
    local index = math.random(1, #cfg_list)
    return cfg_list[index] 
end

function M:getQuickItemList()
    local all_item = self:getItems()
    local ts_item = {}
    local all_num = 0
    for i = 1, table.nums(all_item) do
        local item_data,item_cfg = UserDataManager.item_data:getItemDataById(all_item[i])
        ts_item[all_item[i]] = item_data.num
        all_num = all_num + (item_data.num*item_cfg.effect)
    end
    return all_num, ts_item
    -- local c_num, next_num = self:getVipProgress()
    -- local need_num = next_num - c_num 
    -- local use_num = 0
    -- local new_item = {}
    -- for i = 1, table.nums(all_item) do
    --     local item_data,item_cfg = UserDataManager.item_data:getItemDataById(all_item[i])
    --     if item_data.num*item_cfg.effect > need_num then
    --         for ii = 1, item_data.num do
    --             need_num = need_num - item_cfg.effect
    --             if need_num<= 0 then
    --                 new_item[all_item[i]] = ii
    --                 use_num = use_num + (ii*item_cfg.effect)
    --                 break
    --             end
    --         end
    --         break
    --     else
    --         new_item[all_item[i]] = item_data.num
    --         need_num = need_num - (item_data.num*item_cfg.effect)
    --         use_num = use_num + (item_data.num*item_cfg.effect)
    --     end
    -- end
    -- return use_num, new_item
end

function M:getNpcGuide()
    local npc_guide_list = {}
    local cur_stage = UserDataManager:getCurStage()
    local npc_guide_table = ConfigManager:getCfgByName("npc_guide")
    if cur_stage > 0 then
        for k,v in pairs(npc_guide_table) do
            if v.sort == 1 or v.sort == 2 then
                if v.guide_stage <= cur_stage and v.unlock_condition_param > cur_stage then
                    table.insert(npc_guide_list, v)
                end
            end
        end
    end
    return npc_guide_list
end

function M:getNpcGuide2()
    local npc_guide_list = {}
    local cur_stage = UserDataManager:getCurStage()
    local npc_guide_table = ConfigManager:getCfgByName("npc_guide")
    if cur_stage > 0 then
        for k,v in pairs(npc_guide_table) do
            if v.sort == 1 then
                table.insert(npc_guide_list, k)
            end
        end
    end
    return npc_guide_list
end

function M:getNpcGuideData(id)
	local npc_guide_tab =  ConfigManager:getCfgByName("npc_guide")
	local guide_cfg = npc_guide_tab[id]
	local get_bl = false
	for k,v in pairs(UserDataManager.welfare_npc_guide) do
		if v == id then
			get_bl = true
		end
	end
	return get_bl,guide_cfg
end

--获取江湖进度开始关卡
function M:getStartStage()
    local level = 1000000
    local server_level = ConfigManager:getCfgByName("server_level")
    for i, v in pairs(server_level) do
        if i < level then
            level = i
        end
    end
    return level
end

--获取充值返利url
function M:getRechargeRebateURL(activeUrl)
    local active_tab = ConfigManager:getCfgByName("active")
    local url = ""
    for i, v in pairs(active_tab) do
        if v.open_id == 219 then
            url = v.link
        end
    end
    local urls = activeUrl or url
    local token = UserDataManager.client_data:getSdkToken()
    local role_id = UserDataManager.user_data:getUid()
    local server_id = UserDataManager.server_data:getServerId()
    if urls:find("?") then
        urls = urls.."&"
    else
        urls = urls.."?"
    end
    local new_url = urls.."access_token="..token.."&role_id="..role_id.."&server_id="..server_id or ""
    return new_url
end

--获取充值返利开始关闭时间
function M:getRechargeRebateTime()
    local active_tab = ConfigManager:getCfgByName("active")
    local start_time = ""
    local end_time = ""
    for i, v in pairs(active_tab) do
        if v.open_id == 219 then
            start_time = v.start_time
            end_time = v.end_time
        end
    end
    return start_time,end_time
end

--更新皮肤
function M:updateSkin(skin_id, flag)
    self.skin_id = skin_id
    self.have_flag = flag

end

return M