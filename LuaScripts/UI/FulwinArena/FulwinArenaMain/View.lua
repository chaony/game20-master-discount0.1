
local M = class("FulwinArenaMainView",LikeOO.OOPopBase)
-- 风云擂台主界面
M.m_uiName = "FulwinArena/FulwinArenaMain"  -- prefab name
M.m_size_type = 1
M.m_iphoneXAdapter = true

local __TAB_BTN_NODE = {
    {btn_key = "all_togglebtn", btn_text = "all_btn_text", lan_key = "new_str_0044"},
    {btn_key = "one_togglebtn", btn_text = "one_btn_text", lan_key = "fylt_str_0020"},
    {btn_key = "team_togglebtn", btn_text = "team_btn_text", lan_key = "fylt_str_0021"},
}

function M:onEnter()
    for k,v in pairs(__TAB_BTN_NODE) do
        self:setText(v.btn_text, string.cutTextForString(Language:getTextByKey(v.lan_key)))

        local tog_btn = self:findToggle(v.btn_key)
        if k == self.m_model.m_tab_index then
            tog_btn.isOn = true
        end
        UIUtil.addToggleListener(tog_btn, function(is_on)
            if is_on then
                self:updateMsg("tab_index", k)
            end
        end, nil, self.m_uiName)
    end
    self.search_input = self:findInputField("search_input")
    self.search_input.placeholder.text = Language:getTextByKey("fylt_str_0095")

    self:setTextByLanKey("text_fresh", "union_str_1035")
    self:setTextByLanKey("text_allTitle_right", "fylt_str_0004")
    
    self:bindUI()
    self:refreshUI()  
end

function M:refreshUI(list_flag)
    self:setObjectVisible("rightNode", self.m_model.m_defense_open)
    self:setObjectVisible("listNode", not self.m_model.m_defense_open)
   
    if self.m_model.m_defense_open then
        self:setTextByLanKey("text_btn_defense", "fylt_str_0042")
        self:refreshRightNode()
    else
        self:setTextByLanKey("text_btn_defense", "fylt_str_0041")
        for k,v in pairs(__TAB_BTN_NODE) do
            if k == self.m_model.m_tab_index then
                self:setTextColor(v.btn_text, GlobalConfig.COMMON_COLLOR.COMMON_25)
            else
                self:setTextColor(v.btn_text, GlobalConfig.COMMON_COLLOR.COMMON_24)
            end
        end
        self:refreshListNode(list_flag)
    end
    self:refreshLeftNode()
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
                if hero then
                    local tempData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero.id, 0}) or {}
                    tempData.quality = hero.evo
                    tempData.oid = hero_id
                    tempData.hero_data = hero
                    GameUtil:updateItemElementByData(hero_node.gameObject,tempData,false,false)
                else
                    local ui_element = GameUtil:updateItemElementNoData(hero_node)
                    ui_element.add_img.gameObject:SetActive(false)
                end
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

function M:refreshListNode(flag)
    local data = self.m_model:getListData()
    Logger.log(#data,"data =====")
    self:setObjectVisible("text_no_list", #data == 0)
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("scrollview")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateCell(cell_object, cell_data, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, cell_data)
            end,
            ui_name = self.m_uiName,
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, flag)
    end
end

function M:updateCell(cell_object, cell_data, index)
    local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"img_you", cell_data.is_friend == 1)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"img_bang", cell_data.same_guild == 1)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"img_mode_1", cell_data.fair == 1)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "img_mode_2", #cell_data.ban_race > 0)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "img_mode_3", #cell_data.ban_role_type > 0)
    LuaBehaviourUtil.setText(luaBehaviour,"text_number", Language:getTextByKey("fylt_str_0070") .. cell_data.ring_id)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"text_count", "fylt_str_0069",cell_data.players_count, cell_data.max_member)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"text_type_name", cell_data.typ == 1 and "fylt_str_0020" or "fylt_str_0021")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"text_fight", "fylt_str_0073")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"text_password", "fylt_str_0061")
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"btn_fight", cell_data.has_password ~= 1)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"btn_password", cell_data.has_password == 1)
    LuaBehaviourUtil.setText(luaBehaviour,"text_name", cell_data.president_info.name)
    local head_node = luaBehaviour:FindGameObject("head_node")
    GameUtil:setUserAvatar(head_node, cell_data.president_info)
end

function M:getSearchText()
    return self.search_input.text
end

function M:destroy()
    M.super.destroy(self)
end

return M


