local M = class("BountyMissionsHelpView",LikeOO.OOPopBase)

M.m_uiName = "BountyMissions/BountyMissionsHelp"
M.m_size_type = 2

local SLOT_TAB = {
	{id = 1},
	{id = 2},
	{id = 3},
	{id = 4},
	{id = 5},
	{id = 6},
}

function M:onEnter()	
	self:setTextByLanKey("common_title_text", "bounty_str_0007")
	self:setTextByLanKey("top_text", "bounty_str_0008")
	self:resfreshUI()
end

function M:resfreshUI()
	self:setTextByLanKey("top2_text", "bounty_str_0009", #self.m_model.m_heros ,6)
	self:updateLoopScroll()
end


--[[
	创建槽位列表
]]
function M:updateLoopScroll()
	local data = SLOT_TAB
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateSlotData(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "remove_btn" then
					if  self.m_model.m_heros[cell_data.id] then
						local hero_da = self.m_model.m_heros[cell_data.id]
						self:updateMsg("remove_hero", hero_da.oid)
					end
				elseif click_name == "add_hero_btn" then
					self:updateMsg("add_hero")
				end
			end,
			ui_name = self.m_uiName,
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
	if #data > 0 then
		self:setObjectVisible("nil_caneqp",false)
	else
		self:setObjectVisible("nil_caneqp",true)
	end
end

function M:updateSlotData(obj, data)
	local LuaBehaviour = UIUtil.findLuaBehaviour(obj.transform)
	local hero_parent = LuaBehaviour:FindGameObject("itemParent")
	LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "count", false)
	LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "nil_text", true)
	LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "nil_text", "bounty_str_0011")
	LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "type_text", "bounty_str_0010")
	LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "check_btn_text", "friend_str_0014")
	local m_hero = self.m_model.m_heros[data.id]
	local hero_node = LuaBehaviour:FindGameObject("ItemNode2")
	if self.m_model.m_heros[data.id] then
		if next(m_hero.users) ~= nil then
			local num = math.random (6) 
			LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "type_text", "teahouse_state"..num)
		end
		local hero_id = self.m_model.m_heros[data.id].oid
		local c_id = self.m_model.m_heros[data.id].id
		local data, cfg = self.m_model:getHero(hero_id)
		local itemData = nil
		local com = nil
		if data ~= nil then
			itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, data.id, 1, hero_id})
			com = GlobalConfig.HERO_QUALITY_COMMON_SETTING[data.evo]
		else
			cfg = UserDataManager.hero_data:getHeroConfigByCid(c_id)
			itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, c_id, 1})
			com = GlobalConfig.HERO_QUALITY_COMMON_SETTING[cfg.evo]
		end
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "count", true)
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "nil_text", false)
		local name_text = LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "name_text", cfg.name)
		name_text.color = com.RGBA
		GameUtil:updateItemElementByData(hero_node, itemData)
		hero_node:SetActive(true)
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "remove_btn", true)
	else
		self:updateItemNode(hero_node, nil)
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "remove_btn", false)
	end
end

function M:updateItemNode(obj, data)
	local LuaBehaviour = UIUtil.findLuaBehaviour(obj.transform)
	if data == nil then
		obj:SetActive(false)
	else
		obj:SetActive(true)
		self:alterData(obj, data)
	end
end

function M:alterData(obj, data)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local item = luaBehaviour:FindGameObject("item_img")--任务名字
    local quality_up_img = luaBehaviour:FindGameObject("quality_up_img")
    local item_img = LuaBehaviourUtil.setImg(luaBehaviour,"item_img", data.icon_name, data.atlas_name or "item_icon")
    item:SetActive(true)
    local camp_img = luaBehaviour:FindGameObject("camp_img")
    local frame = GlobalConfig.QUALITY_COMMON_SETTING[data.quality]
    quality_up_img:SetActive(frame.is_add == true)
    if frame.is_add == true then
        LuaBehaviourUtil.setImg(luaBehaviour, "quality_up_img", frame.add_img, "hero_head_ui")
    end
    LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", frame.hero_item_frame, "hero_head_ui")
    local race_data = GlobalConfig.TYPE_HERO_RACE[data.race]
    local type_data = GlobalConfig.TYPE_HERO_PROPERTY[data.item_cfg.type]
    if race_data then
        LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", race_data.race_icon,  ResourceUtil:getLanAtlas())
    end
end

return M