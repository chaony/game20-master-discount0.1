local M = class("WorldBossRewardView",LikeOO.OOPopBase)

M.m_uiName = "Activities/WorldBoss/WorldBossDanPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0224")
	self:setTextByLanKey("battle_text", "world_boss_str_0011")
	self:setTextByLanKey("rewards_text", "world_boss_str_0012")
	self:setTextByLanKey("ok_text", "new_str_0006")
	self.time_text = self:findText("time_text")

	self:refreshUI()
	self:initDownTime()
end

function M:refreshUI()
	self:setText("battle_value_text", self.m_model.m_params.max_damage)
	self:setText("rank_text", self.m_model.m_params.rank)
	local dan_data = self.m_model.m_params.dan_data
	self:setTextByLanKey("dan_name_text", dan_data.division_name)
	self:updateLoopScroll()
end

function M:updateLoopScroll()
	local data = self.m_model.m_params.dan_data.boss_rewards or {}
	Logger.log(data,"data =====")
	if self.m_loop_scroll_view == nil then
		local reward_scroll = self:findGameObject("reward_scroll")
		local params = {
			show_data = data,
			loop_scroll_object = reward_scroll,
			one_line_count = 6,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)

			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

function M:updateScrollViewCell(index, cell_object, cell_data)
    local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
    GameUtil:updateItemElement(cell_object, cell_data, true, true)
end

function M:initDownTime()
	local function tick(dt)
		local end_ts = UserDataManager.end_ts
		local down_time = end_ts - UserDataManager:getServerTime()
		if down_time >= 0 then
			local text = GameUtil:formatTimeBySecond(down_time)
			self.time_text.text = text .. Language:getTextByKey("world_boss_str_0004")
		end
	end
	self.tick_id = self.m_control:setTimer(1, tick)
	tick()
end

return M