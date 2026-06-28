--- 好感属性信息
local M = class("LookInfoTips",LikeOO.OOUIbase)

M.m_uiName = "Common/GoodFeelProPop"
M.m_sortOrder = 19999

function M:onCreate()
	self.m_content = self:findGameObject("content_node")
	self.m_content:SetActive(false)
end

function M:setParent(parent)
	if static_root_node then
		self.m_rootView.transform:SetParent(static_root_node.transform, false)
	end
end

function M:onButtonClick(obj, name)
	if name == "close_btn" then
		self:destroy()
	end
end

function M:onEnter()
	local hero_id = self.m_params.hero_id
	self.new_data = UserDataManager.m_friendliness[tostring(hero_id)] 
	self.m_hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_id)
	self.cur_cfg = self:getOrderFetterLv()
	self.next_cfg = self:getNextFetterLv()
	self:updateListScroll(self.cur_cfg,self.next_cfg)
	self:setTextByLanKey("title_text", "hero_ui_str_0031", self.new_data.lv,self.cur_cfg.name)
	self:refreshUI()
end


function M:getOrderFetterLv()
	local fetters_level_tab = ConfigManager:getCfgByName("fetters_level")
	if fetters_level_tab then
		local fet_tab = fetters_level_tab[self.m_hero_cfg.role_type or 1]
		return fet_tab[self.new_data.lv]
	end
	return nil
end

function M:getNextFetterLv()
	local fetters_level_tab = ConfigManager:getCfgByName("fetters_level")
	if fetters_level_tab then
		local fet_tab = fetters_level_tab[self.m_hero_cfg.role_type or 1]
		return fet_tab[self.new_data.lv+1]
	end
	return nil
end

function M:refreshUI()
	self.m_content:SetActive(true)
end

function M:updateListScroll(cur_cfg, next_cfg)
    local data = {}
	if cur_cfg then
		for i = 1, #cur_cfg.Meridian_attr do
			table.insert(data, {type = 2, data = cur_cfg.Meridian_attr[i]} )
		end
	end
	if next_cfg then
		table.insert(data, {type = 1, data = self.new_data.lv+1} )
		for i = 1, #next_cfg.Meridian_attr do
			table.insert(data, {type = 2, data = next_cfg.Meridian_attr[i]} )
		end
	end
	local dia_id = self:unlockDialogue()
	if dia_id and #dia_id > 0 then
		table.insert(data, {type = 3, data = dia_id} )
	end
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                self:setCellHander(cell_object, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:cellBtnHandle(click_name, index)
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data)
    end
end

function M:setCellHander(obj, id, cell_data)
	if id % 2 == 0 then
		UIUtil.setObjectVisible(obj.transform, true, "cell_bg_img")
	else
		UIUtil.setObjectVisible(obj.transform, false, "cell_bg_img")
	end
	--type{1:等级 2:属性 3:音效}
	if cell_data.type == 2 then
		local data = cell_data.data 
		local key = GameUtil:getAttrsKey(data[1])
		local name = GameUtil:getAttrsName(key)
		UIUtil.setTextByLanKey(obj.transform, "name_text", name)
		local num = data[2]
		if GameUtil:canPerAttrTransition(key) == true then
			num = GameUtil:formatNum(num * 100) 
		end
		if GameUtil:attrTransition(key) == true then
			UIUtil.setText(obj.transform, tostring(num).."%", "num_text")
		else
			UIUtil.setText(obj.transform, tostring(num), "num_text")
		end
		UIUtil.setObjectVisible(obj.transform, true, "name_text")
		UIUtil.setObjectVisible(obj.transform, true, "num_text")
		UIUtil.setObjectVisible(obj.transform, false, "cell_title_text")
	elseif cell_data.type == 3 then
		local data = cell_data.data 
		UIUtil.setTextByLanKey(obj.transform, "name_text", "hero_ui_str_0035")
		UIUtil.setTextByLanKey(obj.transform, "num_text", self:getDoalogueName(data))
		UIUtil.setObjectVisible(obj.transform, true, "name_text")
		UIUtil.setObjectVisible(obj.transform, true, "num_text")
		UIUtil.setObjectVisible(obj.transform, false, "cell_title_text")
	else
		UIUtil.setObjectVisible(obj.transform, false, "cell_bg_img")
		UIUtil.setTextByLanKey(obj.transform, "cell_title_text", "hero_ui_str_0031", self.new_data.lv+1,self.next_cfg.name)
		UIUtil.setObjectVisible(obj.transform, false, "name_text")
		UIUtil.setObjectVisible(obj.transform, false, "num_text")
		UIUtil.setObjectVisible(obj.transform, true, "cell_title_text")
	end
end

function M:unlockDialogue()
    local str = ""
	local hero_fetters_tab = ConfigManager:getCfgByName("hero_fetters")
	local hero_tab = hero_fetters_tab[self.m_params.hero_id] or hero_fetters_tab[101]
	if hero_tab[self.new_data.lv+1] then
		return hero_tab[self.new_data.lv+1].dialogue
	end 
    return nil
end

function M:getDoalogueName(id)
	local fetters_tab = ConfigManager:getCfgByName("random_disposition")
	if fetters_tab[tonumber(id)] then
		local cur_fetter = fetters_tab[tonumber(id)]
		return cur_fetter.name
	else
		return id	
	end
end

function M:destroy()
	M.super.destroy(self)
	GameUtil:resetGoodFeelLookInfoTips()
end

return M