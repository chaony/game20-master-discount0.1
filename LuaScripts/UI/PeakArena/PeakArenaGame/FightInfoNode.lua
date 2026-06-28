local M = class("FightInfoNode", LikeOO.OOUIbase)

M.m_uiName = "PeakArena/FightInfoNode"

function M:onEnter()
    self:refreshUI()
end

function M:refreshUI()
    if self.m_model.m_selete_index == 3 then
        self:setObjectVisible("bottom_com", true)
        self:setTextByLanKey("se_num", "第"..self.m_model.m_battle_index_64.."场")
    else
        self:setObjectVisible("bottom_com", false)
    end
    for i = 8, 15 do
        local player_info = self:findGameObject("player_info_"..i)
        self:updatePlayerInfoData(player_info, i)
    end
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

function M:updatePlayerInfoData(obj, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local data = nil 
        if self.m_model.m_selete_index == 3 then
            if index >= 8 then
                data = self.m_model:getPlayerDataByIndex(index)
            elseif index >= 4 then
                data = self.m_model:getPlayerDataByIndex2(index)  
            elseif index >= 2 then
                data = self.m_model:getPlayerDataByIndex3(index)  
            else
                data = self.m_model:getPlayerDataByIndex4()    
            end
        else
            if index >= 8 then
                data = self.m_model:getWinPlayerData(index)
            elseif index >= 4 then
                data = self.m_model:getWinPlayerData2(index)  
            elseif index >= 2 then
                data = self.m_model:getWinPlayerData3(index)  
            else
                data = self.m_model:getWinPlayerData4()    
            end
        end
        local HeadNode = luaBehaviour:FindGameObject("HeadNode")
        if data then
            if data.user then
                GameUtil:setUserAvatar(HeadNode, data.user, true,nil,{show_flag = true, scale = 1})
            else
                GameUtil:setUserAvatar(HeadNode, data, true,nil,{show_flag = true, scale = 1})    
            end
            if data.user then
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "player_name", data.user.name)
            else
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "player_name", data.name)    
            end
            local win_data = self.m_model:checkPromotionDataByIndex(data.index)
            if win_data and win_data.uid == data.uid then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_light", true)
            else
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_light", false)    
            end
            if data.battle_id then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_btn", true)  
            else
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_btn", false)      
            end
        else
            GameUtil:setUserAvatar(HeadNode, {},false,nil,{show_flag = true, scale = 1})
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "player_name", "虚位以待") 
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_light", false)  
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_btn", false)  
        end
        local function onButtonClick(obj, name)
            if name == "check_btn" then
                if data.battle_id then
                    local item_data = data
                    self:openView("Arena.ArenaHigher.ArenaHigherBattleDetail", {battle_id = item_data.battle_id, log_data = item_data, top_arena = true})
                end
            else
                if data then
                    self:openView("Pops.PlayerInfo", {uid = data.uid, look_model = 2})
                end
            end
        end
        luaBehaviour:RegistButtonClick(onButtonClick)
    end
end

function M:updateTime()

end

function M:onButtonClick(obj, name)
    if self.m_model:checkCanClick() == false then
        self.m_control:checkIsClose()
        return
    end
    if name == "check_btn_1" or name == "check_btn_2" or name == "check_btn_3" or name == "check_btn_4"
    or name == "check_btn_5" or name == "check_btn_6" or name == "check_btn_7" then
        self:openView("PeakArena.FightDetailsPop")
    elseif name == "left_btn" then
        if self.m_model.m_selete_index == 3 and self.m_model.m_battle_index_64 > 1 then
            self.m_model.m_battle_index_64 = self.m_model.m_battle_index_64 - 1
            self:refreshUI()
        end
    elseif name == "right_btn" then
        if self.m_model.m_selete_index == 3 and self.m_model.m_battle_index_64 < 8 then
            self.m_model.m_battle_index_64 = self.m_model.m_battle_index_64 + 1
            self:refreshUI()
        end
    else
        self:updateMsg(name)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
