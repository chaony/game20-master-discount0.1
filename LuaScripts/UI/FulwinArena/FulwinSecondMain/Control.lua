
local M = class("FulwinSecondMainControl",LikeOO.OOControlBase)

function M:onEnter()
    self:updateMsg("update_data")
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:exitRing()
    elseif msg == "remove_player" then --移除玩家
        self:removePlayer(data)
    elseif msg == "add_player" then --添加
        self:playerInvite()
        audio:SendEvtUI("UI_Tab_N5")
    elseif msg == "start_btn" then --开战
        self:battleStart()
    elseif msg == "chat_btn" then --聊天
        self:openView("Chat2")
    elseif msg == "formation_btn" then --布阵
        self:openFormation()
    elseif msg == "bailei_btn" then --擂台设置
        self:editRingInof()
    elseif msg == "reday_btn" then -- 准备
        self:playerReady()
    elseif msg == "player_btn" then -- 查看玩家
        local user = self.m_model:getPlayerData(data)
        if user then
            self:openView("Pops.PlayerInfo", {uid = user.user_info.uid})
        end
    elseif msg == "update_data" then
        self:updateData()
    elseif msg == "log_btn" then
        if self.m_model.m_data.battle_logs and #self.m_model.m_data.battle_logs > 0 then
            self:openView("FulwinArena.FulwinSecondFight", self.m_model.m_data)
        end
    elseif msg == "explain_btn" then
        local content = Language:getTextByKey("Fengyun_challenge_tips_2")
        local titleName = Language:getTextByKey("fylt_str_0021")
        self:openView("Pops.CommonHelpPop", { title = titleName, content = content })
    end
end

-- 更新房间数据
function M:updateData()
    if self.m_info_timer then
        self:removeTimer(self.m_info_timer)
        self.m_info_timer = nil
    end
    
    local function battleLoad()
        local battle_time, log_battle_time = self.m_model:getBattleTime()
        if battle_time > 0 and battle_time ~= log_battle_time then
            local server_time = UserDataManager:getServerTime()
            if server_time - battle_time < 30 then
                if not self:hasChild("FulwinArena.FulwinSecondFightLoad") then
                    self:openView("FulwinArena.FulwinSecondFightLoad")
                end
            else
                self.m_model:setBattleRecordPlayed(self.m_model.m_data.battle_logs[1].battle_record_id, battle_time)
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("fylt_str_00101"), delay_close = 2})
                if self:hasChild("FulwinArena.FulwinSecondFightLoad") then
                    self:closeView("FulwinArena.FulwinSecondFightLoad")
                end
            end
        else
            if self:hasChild("FulwinArena.FulwinSecondFightLoad") then
                self:closeView("FulwinArena.FulwinSecondFightLoad")
            end
        end
    end

    local function callfunc(response)
        --Logger.log(response,"updateInfo response =====")
        self.m_model:updateData(response)
        if response.battle_logs and #response.battle_logs > 0  then
            if not self.m_model:battleRecordIsPlay(response.battle_logs[1].battle_record_id) then
                self:closeView("FulwinArena.FulwinSecondFightLoad")
                self:openView("FulwinArena.FulwinSecondFight", response)
                self.m_model:setBattleRecordPlayed(response.battle_logs[1].battle_record_id, response.ring_info.start_battle_time)
            else
                battleLoad()
            end
        else
            battleLoad()
        end
        
        if self.m_model:isRemove() then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("fylt_str_0088"), delay_close = 2})
            self:updateMsg("btn_fresh", nil, "FulwinArena.FulwinArenaMain")
            self:closeView("FulwinArena.FulwinSecondFight")
            self:closeView()
            return
        end
        self.m_view:refreshUI()
    end

    local function updateInfo()
        self.m_model:getNetData("friend_arena_ring_info", {ring_id = self.m_model.m_ring_id, need_rank = 1}, callfunc)
    end
    self.m_info_timer = self:setTimer(5, updateInfo)
    updateInfo()
end

-- 离开房间
function M:exitRing()
    local function callfunc(response)
        --Logger.log(response,"freshListData response =====")
        self:updateMsg("fresh_list_data", nil, "FulwinArena.FulwinArenaMain")
        self:closeView()
    end

    if self.m_model:selfIsReady() then
        local params =
        {
            on_ok_call = function(msg)
                self.m_model:getNetData("friend_arena_exit_ring",{ring_id = self.m_model.m_ring_id}, callfunc)
            end,
            text = Language:getTextByKey("fylt_str_0098"),
        }
        self:openView("Pops.CommonPop", params)
    else
        self.m_model:getNetData("friend_arena_exit_ring",{ring_id = self.m_model.m_ring_id}, callfunc)
    end
end

-- 移除玩家
function M:removePlayer(index)
    local user = self.m_model:getPlayerData(index)
    if user then
        local function callfunc(response)
            --Logger.log(response,"removePlayer response =====")
            self.m_model:updateData(response)
            self.m_view:refreshUI()
        end
        self.m_model:getNetData("friend_arena_remove_player",{uid = user.user_info.uid}, callfunc)
    end
end

-- 邀请
function M:playerInvite()
    if self.m_model.m_data and self.m_model.m_data.ring_info then
        local params = {}
        params.typ = self.m_model.m_data.ring_info.typ
        params.ring_id = self.m_model.m_ring_id
        self:openView("FulwinArena.FulwinArenaShare",params)
    end
end

-- 打开布阵
function M:openFormation()
    local params = {}
    if self.m_model.m_data.ring_info.team_type == 1 then
        params.mode = GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_LOCAL_ONE
    else
        params.mode = GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_LOCAL_THREE
    end
    
    params.fair_fulwin = self.m_model.m_data.ring_info.fair
    params.formation_index = 1
    params.edit_team = 1
    params.races = self.m_model:getUsableRace()
    params.lock_job = self.m_model:getDisableJob()
    self:openView("Formation",params)
end

-- 编辑房间信息
function M:editRingInof()
    local params = {}
    params.ring_id = self.m_model.m_ring_id
    params.typ = self.m_model.m_data.ring_info.typ
    params.team_type = self.m_model.m_data.ring_info.team_type
    params.fair = self.m_model.m_data.ring_info.fair
    params.ban_race = self.m_model.m_data.ring_info.ban_race
    params.ban_role_type = self.m_model.m_data.ring_info.ban_role_type
    self:openView("FulwinArena.FulwinArenaSingleSetting",params)
end

-- 准备
function M:playerReady()
    local function callfunc(response)
        --Logger.log(response,"playerReady response =====")
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end

    local teams_flag = self.m_model:teamFormationRed()
    if teams_flag then
        local params =
        {
            on_ok_call = function(msg)
                self.m_model:getNetData("friend_arena_ready",nil, callfunc)
            end,
            text = Language:getTextByKey("fylt_str_0097"),
        }
        self:openView("Pops.CommonPop", params)
    else
        self.m_model:getNetData("friend_arena_ready",nil, callfunc)
    end
end

-- 战斗
function M:battleStart()
    local player_num = #self.m_model.m_data.players
    if player_num < 4 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("fylt_str_0093"), delay_close = 2})    
    else
        local is_ready = self.m_model:isAllReady()
        if not is_ready then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("fylt_str_0076"), delay_close = 2})
            return
        end

        local function callfunc(response)
            Logger.log(response,"battleStart response =====")
            --if response then
                --self.m_model.m_data.battle_logs = response
                --self:openView("FulwinArena.FulwinSecondFight", self.m_model.m_data)
                --self:closeView("FulwinArena.FulwinSecondFightLoad")
                --self.m_model:setBattleRecordPlayed(response[1].battle_record_id)
            --end
        end
        self.m_model:getNetData("friend_arena_battle_pvp",nil, callfunc, 0, nil,nil,nil,nil,0)
        self:openView("FulwinArena.FulwinSecondFightLoad")
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
