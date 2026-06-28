local M = class("FulwinArenaSingleMainControl", LikeOO.OOControlBase)

function M:onEnter()
    self:updateMsg("update_data")
    if self.m_model.m_params.invite then
        self:updateMsg("btn_invite")
    end
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:exitRing()
    elseif msg == "btn_put" then
        self:editRingInof()
    elseif msg == "btn_formation" then
        self:openFormation()
    elseif msg == "btn_move" then
        self:removePlayer()
    elseif msg == "update_data" then
        self:updateData()
    elseif msg == "btn_battle" then
        self:battleStart()
    elseif msg == "btn_ok" then
        self:playerReady()
    elseif msg == "btn_invite" then
        self:playerInvite()
    elseif msg == "btn_chat" then
        self:openChat()
    elseif msg == "explain_btn" then
        local content = Language:getTextByKey("Fengyun_challenge_tips_0")
        local titleName = Language:getTextByKey("fylt_str_0020")
        self:openView("Pops.CommonHelpPop", { title = titleName, content = content })
    elseif msg == "left_player_btn" or msg == "right_player_btn" then
        local user = self.m_model:getOpponentPlayerUser()
        if user then
            self:openView("Pops.PlayerInfo", {uid = user.user_info.uid})
        end
    end
end

-- 更新房间数据
function M:updateData()
    if self.m_info_timer then
        self:removeTimer(self.m_info_timer)
        self.m_info_timer = nil
    end

    local function callfunc(response)
        --Logger.log(response,"updateInfo response =====")
        if response.battle_log and response.battle_log.battle_record_id  then
            if not self.m_model:battleRecordIsPlay(response.battle_log.battle_record_id) then
                self:playerBattle(response.battle_log)
                self.m_model:setBattleRecordPlayed(response.battle_log.battle_record_id)
            end
            
        end
        self.m_model:updateData(response)
        if self.m_model:isRemove() then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("fylt_str_0088"), delay_close = 2})
            self:updateMsg("btn_fresh", nil, "FulwinArena.FulwinArenaMain")
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
    
    local is_president = self.m_model:isPresident()
    if not is_president then
        local player = self.m_model:getPlayerUser()
        if player.ready == 1 then
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
    else
        self.m_model:getNetData("friend_arena_exit_ring",{ring_id = self.m_model.m_ring_id}, callfunc)
    end
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

-- 移除玩家
function M:removePlayer()
    local user = self.m_model:getPlayerUser()
    if user then
        local function callfunc(response)
            --Logger.log(response,"removePlayer response =====")
            self.m_model:updateData(response)
            self.m_view:refreshUI()
        end
        self.m_model:getNetData("friend_arena_remove_player",{uid = user.user_info.uid}, callfunc)
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

-- 邀请
function M:playerInvite()
    if self.m_model.m_data and self.m_model.m_data.ring_info then
        local params = {}
        params.typ = self.m_model.m_data.ring_info.typ
        params.ring_id = self.m_model.m_ring_id
        self:openView("FulwinArena.FulwinArenaShare",params)
    end
end

-- 战斗
function M:battleStart()
    local user = self.m_model:getPlayerUser()
    if user then
        if user.ready == 1 then
            local function callfunc(response)
                --Logger.log(response,"battleStart response =====")
                if response then
                    self:playerBattle(response)
                    self.m_model:setBattleRecordPlayed(response.battle_record_id)
                end
            end
            self.m_model:getNetData("friend_arena_battle_pvp",nil, callfunc)
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("fylt_str_0076"), delay_close = 2})
        end
    end
end

-- 打开聊天
function M:openChat()
    local user = self.m_model:getOpponentPlayerUser()
    if user then
        self:openView("Chat2",{['id']=user.user_info.uid, ['name']=user.user_info.name, ['avatar'] = user.user_info.avatar})
    else
        self:openView("Chat2")
    end
end

-- 播放战斗
function M:playerBattle(battle_log)
    local function callfunc(response)
        --Logger.log(response,"playerBattle response =====")
        self:openView("GamePanel", {data = response, replay = true, mode = response.battle.sort})
        if self:hasChild("Settlement") then
            self:closeView("Settlement")
        end
    end
    self.m_model:getNetData("battle_replay",{battle_id = battle_log.battle_record_id}, callfunc)
end

return M