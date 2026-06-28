local M = class("ArenaRaceRewardView",LikeOO.OOPopBase)

M.m_uiName = "Arena/ArenaRace/ArenaRaceReward"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0224")
	self:setTextByLanKey("time_titile_text", "new_str_0225")
	self:setTextByLanKey("rank_titile_text", "new_str_0226")
	self:setTextByLanKey("ok_btn_text", "new_str_0006")
	self.m_time_text = self:findText("time_text")
	self:refreshUI()
end

function M:refreshUI()
	self:setTextByLanKey("rank_text", tostring(self.m_model.m_rank))
	self:setTextByLanKey("next_rank_text", "new_str_0227", tostring(self.m_model:getNextRewardRank()))
	self:updateLoopScroll()
	self:setTimeText()
    local time = self.m_model:getRemainingTime()
    local function tick(event, dt, remaining_time)
		self:setTimeText()
        if remaining_time <= 0 then
            self:updateMsg("time_update_end_refresh")
        end
    end
    EventDispatcher:registerTimeEvent("ArenaRaceRewardTime", tick, 1, time)
end

function M:setTimeText()
    local time = self.m_model:getRemainingTime()
    local ft = GameUtil:formatTimeBySecond(time)
    self.m_time_text.text = ft
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getRankReward()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("item_click", {id = index})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    local transform = cell_object.transform
	local cur_rewards = data.cur_rewards or {}
	local next_rewards = data.next_rewards or {}
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "no_reward_text", "new_str_0230")
	local cur_item_node = luaBehaviour:FindGameObject("cur_item_node")
	if _G.next(cur_rewards) then
		cur_item_node:SetActive(true)
		GameUtil:updateItemElement(cur_item_node, cur_rewards[1], true, false)
	else
		cur_item_node:SetActive(false)
	end
	local next_item_node = luaBehaviour:FindGameObject("next_item_node")
	if _G.next(next_rewards) then
		next_item_node:SetActive(true)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_reward_text", false)
		GameUtil:updateItemElement(next_item_node, next_rewards[1], true, false)
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_reward_text", true)
		next_item_node:SetActive(false)
	end
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_name_text", index == 1 and "new_str_0228" or "new_str_0229")
end

function M:destroy()
    EventDispatcher:unRegisterEvent("ArenaRaceRewardTime")
    M.super.destroy(self)
end

return M