local M = class("MysticSelectPopView",LikeOO.OOPopBase)

M.m_uiName = "Mystic/MysticSelectPop"
M.m_size_type = 2

function M:onEnter()	
	self:setText("ok_text", Language:getTextByKey("new_str_0006"))
	self:setText("common_title_text", Language:getTextByKey("mystic_str_0020"))
    self:setTextByLanKey("no_text", "mystic_str_0021")
    self.no_panel = self:findGameObject("no_panel")
    self.no_panel:SetActive(false)
    
    self:setObjectVisible("no_wear_text", self.m_model.m_oid == nil)
    self:setObjectVisible("wear_panel", self.m_model.m_oid ~= nil)
	self:refreshUI()
end

function M:refreshUI()
    --self.no_panel:SetActive(#self.m_model.m_mystices <= 0)
    if self.m_model.m_oid then
        local data, cfg = UserDataManager.mystic_data:getMysticDataById(self.m_model.m_oid)
        local cur_cfg = cfg[data.evo]
        local obj = self:findGameObject("wearItemNode")
        GameUtil:updateItemElement(obj, {RewardUtil.REWARD_TYPE_KEYS.MYSTIC,data.id,data.evo, oid=self.m_model.m_oid}, false, false)
        self:setTextByLanKey("wear_name_text", cur_cfg.name)
        
        local attr_cfg = GameUtil:getAttrCfg(cur_cfg.attr[1][1])
        self:setTextByLanKey("wear_property_text", attr_cfg.name)
        self:setText("wear_property_value_text", (attr_cfg.is_percent == 1 and tostring(cur_cfg.attr[1][2]*100) .. "%" or tostring(cur_cfg.attr[1][2])))
        self.list_scroll = self:findGameObject("list_scroll")
        local scroll_rect = self.list_scroll:GetComponent("RectTransform")
        scroll_rect:SetInsetAndSizeFromParentEdge(U3DUtil:RectTransform_Edge("top"), 142,362)
    end
	self:updateListScroll()
end

function M:updateListScroll()
    local data = self.m_model.m_mystices
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                self:listHandle(cell_object, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                local oid = self.m_model:getMysticDataByIndex(index)
                self:updateMsg(click_name, oid)
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data, true)
    end
end

function M:listHandle(obj, id)
	local oid = self.m_model:getMysticDataByIndex(id)
	if oid then
		local data, cfg = UserDataManager.mystic_data:getMysticDataById(oid)
        local cur_cfg = cfg[data.evo]
        local attr_cfg = GameUtil:getAttrCfg(cur_cfg.attr[1][1])
		local luaBehaviour = obj:GetComponent("LuaBehaviour")
        local ItemNode = luaBehaviour:FindGameObject("ItemNode")
        GameUtil:updateItemElement(ItemNode, {RewardUtil.REWARD_TYPE_KEYS.MYSTIC,data.id,data.evo, oid=oid}, false, false)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cur_cfg.name)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "property_text", attr_cfg.name)
        LuaBehaviourUtil.setText(luaBehaviour, "property_value_text", (attr_cfg.is_percent == 1 and tostring(cur_cfg.attr[1][2]*100) .. "%" or tostring(cur_cfg.attr[1][2])))
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "ok_text", "mystic_str_0029")
        --local duigoudi_img = luaBehaviour:FindGameObject("duigoudi_img")
		--local is_select = self.m_model.m_select == oid
		--duigoudi_img:SetActive(is_select)

        --local count_text = luaBehaviour:FindGameObject("count_text")
        --count_text:SetActive(true)
        --luaBehaviour:FindText("count_text").text = data.id
	end
end

return M