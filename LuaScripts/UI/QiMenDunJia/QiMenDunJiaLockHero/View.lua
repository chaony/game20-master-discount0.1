local M = class("QiMenDunJiaLockHeroView",LikeOO.OOPopBase)

M.m_uiName = "QiMenDunJia/QiMenDunJiaLockHero"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "qi_men_dun_jia_str_011")
	self.m_cell_cache = {}
	self:refreshUI()
end

function M:refreshUI()
	self:updateHeroLoopScroll()
	self:updateRewardLoopScroll()
end

function M:updateHeroLoopScroll()
	local hero_data = self.m_model:getHeroData()
	if self.m_hero_loopscroll_view == nil then
		local loopscroll = self:findGameObject("hero_loopscroll")
		local params = {
			show_data = hero_data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				local luaBehaviour = UIUtil.findLuaBehaviour(transform)
				local item_node = luaBehaviour:FindGameObject("item_node")
				local ui_element = CommonUIUtil:updateHeroElementByData(item_node, cell_data, nil , true)
				CommonUIUtil:updateHeroLvByData(item_node, data.hero_data)
				
				local item_node_transform = item_node.transform
				UIUtil.setObjectVisible(item_node_transform,cell_data.is_lock_custom == true, "duigou_img")
				if self.m_cell_cache[tostring(item_node)] == nil then
					self.m_cell_cache[tostring(item_node)] = item_node
				end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				for k, v in pairs(self.m_cell_cache) do
					UIUtil.setObjectVisible(v.transform, false, "duigou_img")
				end
				for k, v in pairs(hero_data) do
					v.is_lock_custom = false
				end
				
				local transform = cell_object.transform
				local luaBehaviour = UIUtil.findLuaBehaviour(transform)
				local item_node = luaBehaviour:FindGameObject("item_node")
				UIUtil.setObjectVisible(item_node.transform,true, "duigou_img")
				cell_data.is_lock_custom = true
			end
		}
		self.m_hero_loopscroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_hero_loopscroll_view:reloadData(hero_data)
	end
end

function M:updateRewardLoopScroll()
	local reward_data = self.m_model:getRewardData()
	if self.m_reward_loopscroll_view == nil then
		local params = {
			show_data = reward_data,
			one_line_count = 1,
			loop_scroll_object = self:findGameObject("reward_loopscroll"),
			update_cell = function(index, cell_object, cell_data)
				local item_data = RewardUtil:getProcessRewardData(cell_data)
				GameUtil:updateItemElementByData(cell_object, item_data, true, true)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
			end
		}
		self.m_reward_loopscroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_reward_loopscroll_view:reloadData(reward_data)
	end
end

return M