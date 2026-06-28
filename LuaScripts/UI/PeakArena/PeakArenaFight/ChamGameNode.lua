local M = class("ChamGameNode", LikeOO.OOUIbase)

M.m_uiName = "PeakArena/ChamGameNode"

function M:onEnter()
    self:refreshUI()
end

function M:refreshUI()
    for i = 4, 7 do
        local player_info = self:findGameObject("player_info_"..i)
        self:updatePlayerInfoData(player_info, i)
    end
    for i = 2,3 do
        local player_info = self:findGameObject("player_info_"..i)
        self:updatePlayerInfoData(player_info, i)
    end
    local player_info = self:findGameObject("player_info_1")
    self:updatePlayerInfoData(player_info, 1)
end

function M:clickLeft()
	
end

function M:clickRight()

end

function M:updatePlayerInfoData(obj, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local data = nil 
        if index >= 4 then
            data = self.m_model:getWinPlayerData(index)  
        elseif index >= 2 then
            data = self.m_model:getWinPlayerData2(index)  
        else
            data = self.m_model:getWinPlayerData3()    
        end
        local HeadNode = luaBehaviour:FindGameObject("HeadNode")
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_light", false) 
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "last_line_light", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "attack_flag", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "defence_flag", false)
        if data then
            if data.user then
                GameUtil:setUserAvatar(HeadNode, data.user, false, nil, {show_flag = true, scale = 1})
            else
                GameUtil:setUserAvatar(HeadNode, data, false, nil, {show_flag = true, scale = 1})    
            end
            local py_name = nil
            if data.user then
                py_name = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "player_name", data.user.name)
            else
                py_name = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "player_name", data.name)    
            end
            local win_data = self.m_model:checkPromotionDataByIndex(data.index)
            if win_data and win_data.uid == data.uid then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_light", true)
            else
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_light", false)    
            end
            if data.battle_id then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_btn", true)  
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "last_line_light", true)
            else
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_btn", false)      
            end
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_my_img", data.index == self.m_model.m_rank_pos)
            py_name.color = GlobalConfig.COMMON_COLLOR.COMMON_1
            if data.is_atk == 1 then --攻击方
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "attack_flag", true)
            elseif data.is_atk == 0 then --防守方
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "defence_flag", true)
            else --没有这个字段的不展示防守攻击标识，兼容老数据

            end
        else
            GameUtil:setUserAvatar(HeadNode, {},false, nil,{show_flag = true, scale = 1})
            local py_name = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "player_name", "peak_str_0005") 
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_light", false)  
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_btn", false)  
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_my_img", false)
            py_name.color = GlobalConfig.COMMON_COLLOR.COMMON_14
        end
        local function onButtonClick(obj, name)
            audio:SendEvtUI("Play_UI_Popup_1")
            if name == "check_btn" then
                if data.battle_id then
                    local item_data = data
                    self:openView("Arena.ArenaHigher.ArenaHigherBattleDetail", {battle_id = item_data.battle_id, top_arena = true, log_data = item_data})
                end
            else
                if data then
                    self:openView("Pops.PlayerInfo", {uid = data.uid, look_model = 5})
                end
            end
        end
        luaBehaviour:RegistButtonClick(onButtonClick)
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M
