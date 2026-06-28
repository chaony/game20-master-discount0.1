
local M = class("FulwinArenaMainView",LikeOO.OOPopBase)
-- 风云擂台主界面
M.m_uiName = "FulwinArena/FulwinArenaMain"  -- prefab name
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self:bindUI()
    self:refreshUI()  
end

function M:refreshUI()
    self:refreshLeftNode()
    self:refreshRightNode()
end

function M:refreshLeftNode()
    
end

function M:refreshRightNode()
    local itemAloneNode = self:findGameObject("itemAloneNode")
    self:refreshItemNode(itemAloneNode, -1, self.m_model.mult_main_one )
    local listData = self.m_model.mult_main_teams
    for index = 1, 3 do
        local itemData = listData[index]
        local itemNode = self:findGameObject("itemNode"..index)
        self:refreshItemNode(itemNode, index, itemData)
    end
    self:refreshSequenceStateUI()
end

function M:refreshSequenceStateUI()
    local m_edit_status = self.m_model.m_edit_status
    self:setObjectVisible("btn_modifyRank", m_edit_status == 1)
    self:setObjectVisible("btn_cancel", m_edit_status ~= 1)
    self:setObjectVisible("btn_save", m_edit_status ~= 1)
end

function M:refreshItemNode(obj, index, data )
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if not luaBehaviour then
        return
    end
    local titleName = (index > 0) and ("fylt_str_000"..index) or "fylt_str_0007"
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "text_teamIndex", titleName)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "formation_edit_btn_text", "fylt_str_0011")

    local formation_edit_btn = luaBehaviour:FindGameObject("formation_edit_btn")
    UIUtil.setButtonClick(
            formation_edit_btn.transform,
            function()
                self:updateMsg("edit_team", {index = index , cell_data = data})
            end
    )
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "formation_edit_btn", self.m_model.m_edit_status == 1 )
    local exchange_btn = luaBehaviour:FindGameObject("exchange_btn")
    if not IsNull(exchange_btn) then
        UIUtil.setButtonClick(
                exchange_btn.transform,
                function()
                    self:updateMsg("exchange_btn", {index = index , cell_data = data})
                end
        )
        local edit_status = self.m_model.m_edit_status
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "exchange_btn", edit_status ~= 1 and self.m_model.m_select_cell_index ~= index)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "exchange_btn_text", self.m_model.m_edit_status == 2 and "new_str_0884" or "new_str_0885")
    end
    local team_heros_data = data or {}
    local team_node = luaBehaviour:FindGameObject("team_node")
    if team_heros_data and _G.next(team_heros_data) then
        for index = 1,5 do
            local hero_node = UIUtil.findTrans(team_node.transform, "hero_node_" .. index)
            local hero_id = team_heros_data[index]
            if (hero_id == nil) or (hero_id == "") then
                local ui_element = GameUtil:updateItemElementNoData(hero_node)
                ui_element.add_img.gameObject:SetActive(false)
            else
                local hero = UserDataManager.hero_data:getHeroDataById(hero_id)
                local tempData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero.id, 0}) or {}
                GameUtil:updateItemElementByData(hero_node.gameObject,tempData,false,false)
            end
        end
    else
        for index = 1,5 do
            local hero_node = UIUtil.findTrans(team_node.transform, "hero_node_" .. index)
            local ui_element = GameUtil:updateItemElementNoData(hero_node)
            ui_element.add_img.gameObject:SetActive(false)
        end
    end
end

function M:setSpine()
    local avatar = UserDataManager.user_data:getUserStatusDataByKey("avatar")
    local cfg = ConfigManager:getPlayerPictureCfg(avatar)
    local hero_sk = self:findGameObject("hero_spine")
    GameUtil:updateSpineLoadSet(hero_sk, "RoleSpine/" .. tostring(cfg.hero_spine), "idle", 0, true)
    self:setObjectVisible("hero_spine", true)
end

function M:bindUI()
    self:setTextByLanKey("close_title_text", "fylt_str_0008")
    self:setTextByLanKey("text_put", "fylt_str_0009")
    self:setTextByLanKey("text_log", "fylt_str_0010")
    self:setTextByLanKey("text_title1", "fylt_str_0005")
    self:setTextByLanKey("text_title2", "fylt_str_0006")
    self:setTextByLanKey("text_allTitle", "fylt_str_0004")
    self:setTextByLanKey("text_modifyRank", "fylt_str_0031")
    self:setTextByLanKey("text_save", "fylt_str_0033")
    self:setTextByLanKey("text_cancel", "fylt_str_0032")
    self:setSpine()
end

function M:destroy()
    M.super.destroy(self)
end

return M


