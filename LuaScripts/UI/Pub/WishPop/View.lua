local M = class("WishPopView",LikeOO.OOPopBase)

M.m_uiName = "Pub/WishPop"
M.m_size_type = 2

function M:onEnter()
	self:setText("common_title_text", Language:getTextByKey("Pub_str_0006"))
	self:setText("pop_tips_text", Language:getTextByKey("Pub_str_0001"))
	self:setText("cards_title_text", Language:getTextByKey("Pub_str_0002"))
	self.cards_panel = self:findGameObject("cards_panel")
	self.m_list_cell = {}
	self.m_showCards = false
	self:refreshUI()
	self:refreshList()
	self:refreshCardsList()
end

function M:refreshUI()
	
end

function M:updateListScroll()
    local data = self.m_model.m_martialTable
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                self:listHandle(cell_object, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object.transform)
				local btn = luaBehaviour:FindGameObject("click_btn")
				self.index = index
				self:updateMsg("show_cards", index)
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data, true)
    end
end

function M:listHandle(obj, id)
	self.m_list_cell[id] = obj
	self:refreshOneListCell(id)
end

function M:refreshOneListCell(id)
	local martial, cards = self.m_control.m_model:getCardsbyIndex(id)
	local luaBehaviour = UIUtil.findLuaBehaviour(self.m_list_cell[id].transform)
	local bg_img = luaBehaviour:FindImage("bg_img")
	local select_img = luaBehaviour:FindGameObject("select_img")
	local click_btn = luaBehaviour:FindGameObject("click_btn")
	local name_text = luaBehaviour:FindText("name_text")
	LuaBehaviourUtil.setImg(luaBehaviour,"martial_icon_img", GlobalConfig.TYPE_HERO_RACE[tonumber(martial)].race_icon, ResourceUtil:getLanAtlas())
	name_text.text = Language:getTextByKey(GlobalConfig.TYPE_HERO_RACE[tonumber(martial)].name)
	--if self.m_model.m_martial == martial and self.m_showCards == true then
	if self.m_model.m_martial == martial then
		click_btn:SetActive(false)
		select_img:SetActive(true)
		-- LuaBehaviourUtil.setImg(luaBehaviour,"bg_img", "ui_tishineirongdi_h", "main_ui")
	else
		click_btn:SetActive(true)
		select_img:SetActive(false)
		-- LuaBehaviourUtil.setImg(luaBehaviour,"bg_img", "ui_tishineirongdi", "main_ui")
	end
	for i,v in ipairs(cards) do
		local node = luaBehaviour:FindGameObject("card_panel_" .. i)
		UIUtil.destroyAllChild(node.transform)

		if v > 0 then
			local function heroClick(click_object, click_name, idx, data)
				self:updateMsg("click_card", data.data_id)
			end
			local item = CommonUIUtil:createHeroElement({RewardUtil.REWARD_TYPE_KEYS.HEROS,v,1}, nil, nil, heroClick)
			--UIUtil.setButtonClick(item.transform, heroClick, nil, "head_btn")
			UIUtil.setScale(item.transform,0.8)
			item.transform:SetParent(node.transform, false)
			local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(v)
			local luaBehaviour = UIUtil.findLuaBehaviour(item.transform)
			--local lv_text = luaBehaviour:FindGameObject("lv_text")
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lv_text", hero_cfg.name)
			--lv_text:SetActive(false)
			local camp_bg = luaBehaviour:FindGameObject("camp_bg")
			camp_bg:SetActive(false)
			local type_bg = luaBehaviour:FindGameObject("type_bg")
			type_bg:SetActive(false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "quality_up_img", false)
		end
	end
end

function M:refreshList()
	self:updateListScroll()
end

function M:updateCardsScroll(keep_offset)
	self.cards_panel:SetActive(true)
    local data = self.m_model:getCardsCfg()
    if self.m_cards_scroll == nil then
        local list_scroll = self:findGameObject("cards_scroll")
        local params = {
            show_data = data,
            one_line_count = 3,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                self:cardsListHandle(cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("click_card", cell_data.id)
            end
        }
        self.m_cards_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_cards_scroll:reloadData(data, keep_offset)
    end
end

function M:cardsListHandle(obj, data)
	local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(data.id)
	CommonUIUtil:updateHeroElement(obj, {RewardUtil.REWARD_TYPE_KEYS.HEROS,data.id,1})
	local luaBehaviour = UIUtil.findLuaBehaviour(obj.transform)
	local duigou_img = luaBehaviour:FindGameObject("duigou_img")
	local selected = self.m_model:isSelected(data.id)
	duigou_img:SetActive(selected)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lv_text", hero_cfg.name)
	--local lv_text = luaBehaviour:FindGameObject("lv_text")
	--lv_text:SetActive(false)
	local camp_bg = luaBehaviour:FindGameObject("camp_bg")
	camp_bg:SetActive(false)
	local type_bg = luaBehaviour:FindGameObject("type_bg")
	type_bg:SetActive(false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "quality_up_img", false)
end

function M:refreshCardsList(keep_offset)
	self:updateCardsScroll(keep_offset)
end

function M:showCardsList(flag)
	self.m_showCards = flag
	local parent_rect = self.cards_panel.transform.parent.rect
	local rect = self.cards_panel.transform.rect
	if flag == true then
		self.cards_panel:SetActive(flag)
		self.cards_panel.transform:DOLocalMoveX(parent_rect.width/2 - rect.width,0.3)
		self.content_node.transform:DOLocalMoveX((parent_rect.width- rect.width)/2 - parent_rect.width/2  , 0.3)
	else
		self.cards_panel.transform:DOLocalMoveX(parent_rect.width/2,0.3)
		self.content_node.transform:DOLocalMoveX(0, 0.3)
		self.cards_panel:SetActive(flag)
		if self.index then
			self:refreshOneListCell(self.index)
		end
	end
end

return M