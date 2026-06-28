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
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
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
	local hero_node = LuaBehaviour:FindGameObject("ItemNode")
	if self.m_model.m_heros[data.id] then
		if next(m_hero.users) ~= nil then
			local num = math.random (6) 
			LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "type_text", "teahouse_state"..num)
		end
		local hero_id = self.m_model.m_heros[data.id].oid
		local data, cfg = self.m_model:getHero(hero_id)
		local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, data.id, 1, hero_id})
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "count", true)
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "nil_text", false)
		LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "name_text", cfg.name)
		local evo = self.m_model:getNameByEvo(data.evo) 
		local evo_text = LuaBehaviour:FindText("evo_text")
		evo_text.text = Language:getTextByKey(evo.evo_name) 
		local com = GlobalConfig.HERO_QUALITY_COMMON_SETTING[data.evo]
		evo_text.color = com.RGBA
		self:updateItemNode(hero_node, itemData)
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
	end
	if LuaBehaviour then
		
	end
end

return M