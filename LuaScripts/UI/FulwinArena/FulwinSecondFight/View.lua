
local M = class("FulwinSecondFightView",LikeOO.OOPopBase)
-- 风云擂台晋级赛
M.m_uiName = "FulwinArena/FulwinSecondFight"  -- prefab name
M.m_size_type = 1
M.m_iphoneXAdapter = true


function M:onEnter()
    self:setTextByLanKey("close_title_text", "fylt_str_0021")
    for i = 1,7 do
        local battle_node = self:findGameObject("battle_" .. i)
        local luaBehaviour = UIUtil.findLuaBehaviour(battle_node)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_atk", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_def", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "last_line_light", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "battle_log_btn", false)
        local function onButtonClick(obj, name)
            audio:SendEvtUI("Play_UI_Popup_1")
            if name == "battle_log_btn" then
                self:updateMsg("play_battle", i)
            end
        end
        luaBehaviour:RegistButtonClick(onButtonClick)
    end

    for i=1, 3 do
        local round_data = self.m_model:getRoundData(i)
        if round_data then
            for k,v in ipairs(round_data) do
                local atk_player_node = self:findGameObject(v.player_node_atk)
                local def_player_node = self:findGameObject(v.player_node_def)
                local luaBehaviour_atk = UIUtil.findLuaBehaviour(atk_player_node)
                local luaBehaviour_def = UIUtil.findLuaBehaviour(def_player_node)
                LuaBehaviourUtil.setText(luaBehaviour_atk, "player_name", "")
                LuaBehaviourUtil.setText(luaBehaviour_def, "player_name", "")
            end
        end
    end
    local player_info = self:findGameObject("player_info_1")
    local luaBehaviour = UIUtil.findLuaBehaviour(player_info)
    LuaBehaviourUtil.setText(luaBehaviour, "player_name", "")
    self:refreshUI()  
    self:setBattleDownTime()
end

function M:refreshUI()
    for i=1, self.m_model.m_round do
        local round_data = self.m_model:getRoundData(i)
        if round_data then
            for k,v in ipairs(round_data) do
                local battle_log = self.m_model:getBattleData(v.battle_id)
                local atk_player_node = self:findGameObject(v.player_node_atk)
                self:updatePlayerInfoData(atk_player_node, battle_log.atk_user_info)
                local def_player_node = self:findGameObject(v.player_node_def)
                self:updatePlayerInfoData(def_player_node, battle_log.def_user_info)
                if i < self.m_model.m_round then
                    local battle_node = self:findGameObject("battle_" .. v.battle_id)
                    local luaBehaviour = UIUtil.findLuaBehaviour(battle_node)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_atk", battle_log.result == 1)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_def", battle_log.result == 0)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "last_line_light", true)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "battle_log_btn", true)
                end
            end
        end
    end
    if self.m_model.m_round > 3 then
        local round_data = self.m_model:getRoundData(3)
        local battle_log = self.m_model:getBattleData(round_data[1].battle_id)
        local player_info = self:findGameObject("player_info_1")
        if battle_log.result == 1 then
            self:updatePlayerInfoData(player_info, battle_log.atk_user_info)
        else
            self:updatePlayerInfoData(player_info, battle_log.def_user_info)
        end
    end
    
    
end

function M:updatePlayerInfoData(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local HeadNode = luaBehaviour:FindGameObject("HeadNode")
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "attack_flag", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "defence_flag", false)
        if data then
            GameUtil:setUserAvatar(HeadNode, data, false, nil, {show_flag = true, scale = 1})    
            
            local py_name = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "player_name", data.name)
            py_name.color = GlobalConfig.COMMON_COLLOR.COMMON_1
            
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_my_img", false)
        else
            GameUtil:setUserAvatar(HeadNode, {},false,nil,{show_flag = true, scale = 1})
            local py_name = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "player_name", "peak_str_0005") 
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_light", false)  
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_btn", false)  
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_my_img", false)
            py_name.color = GlobalConfig.COMMON_COLLOR.COMMON_14
        end
        local function onButtonClick(obj, name)
            audio:SendEvtUI("Play_UI_Popup_1")
            if data then
                self:updateMsg("show_player", data)
            end
        end
        luaBehaviour:RegistButtonClick(onButtonClick)
    end
end

function M:setBattleDownTime()
    if self.m_model.m_round > 3 then
        self:setTextByLanKey("star_time", "fylt_str_0094")
        return
    end
    if self.m_tick_timer then
        self.m_control:removeTimer(self.m_tick_timer)
        self.m_timer = nil
    end
    local battle_time = self.m_model:getNextTime()
    local function tick()
        local server_time = UserDataManager:getServerTime()
        if server_time < battle_time then
            local time = GameUtil:formatTimeBySecond(battle_time - server_time)
            self:setText("star_time", time)
        else
            self:updateMsg("round_battle")
        end
    end
    tick()
    self.m_tick_timer = self.m_control:setTimer(1, tick)
end

function M:destroy()
    M.super.destroy(self)
end

return M


