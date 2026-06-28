---@class ArenaNormalRewardView:OOPopBase
---@field m_model ArenaNormalRewardModel
local M = class("ArenaNormalRewardView",LikeOO.OOPopBase)

M.m_uiName = "Arena/ArenaNormal/ArenaNormalReward"
M.m_size_type = 2

local __TAB_BTN_NODE = {
	{btn = "reward_toggle", text = "reward_toggle_text", language = "new_str_0373", red_point_img = "reward_red_point_img" },
	{btn = "help_toggle", text = "help_toggle_text", language = "compass_str_006", red_point_img = "help_red_point_img"},
}

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0224")
	if self.m_model.m_open_type > 0 then
		self:setTextByLanKey("time_titile_text", "new_str_1058")
	else
		self:setTextByLanKey("time_titile_text", "new_str_0225")
	end
	self:setTextByLanKey("rank_titile_text", "new_str_0226")
	self:setTextByLanKey("ok_btn_text", "new_str_0006")
	self.m_time_text = self:findText("time_text")
	self.m_cur_scroll_tab = {}
	self.m_next_scroll_tab = {}
	for i, v in ipairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.text, v.language)
		local tog_btn = self:findToggle(v.btn)
		UIUtil.addToggleListener(
				tog_btn,
				function(is_on, data)
					if is_on then
						self:updateMsg("tab_btn", data)
						self:setTextColor(__TAB_BTN_NODE[data].text, GlobalConfig.COMMON_COLLOR.COMMON_25)
					else
						self:setTextColor(__TAB_BTN_NODE[data].text, GlobalConfig.COMMON_COLLOR.COMMON_24)
					end
				end,
				i,
				self.m_uiName
		)
		self:setObjectVisible(v.red_point_img, false)
	end
	local str = string.gsub(Language:getTextByKey(self.m_model.m_content or "???"), "\\n", "\n")
	self:setText("des_text",str)
	self:refreshUI()
end

function M:refreshUI()
	self:setTextByLanKey("common_title_text", self.m_model.m_tab_index == 1 and "new_str_0224" or "compass_str_006")
	self:setObjectVisible("reward_panel", self.m_model.m_tab_index == 1)
	self:setObjectVisible("des_panel", self.m_model.m_tab_index == 2)
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
    EventDispatcher:registerTimeEvent("ArenaNormalRewardTime", tick, 1, time)
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
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cur_loopscroll", false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "next_loopscroll", false)
	if _G.next(cur_rewards) then
		if #cur_rewards == 1 then
			cur_item_node:SetActive(true)
			GameUtil:updateItemElement(cur_item_node, cur_rewards[1], true, false)
		else
			cur_item_node:SetActive(false)
			local parent = luaBehaviour:FindGameObject("cur_loopscroll")
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cur_loopscroll", true)
			self:updateRewardLoopScroll(true, parent, cur_rewards, index)
		end
		
	else
		cur_item_node:SetActive(false)
	end
	local next_item_node = luaBehaviour:FindGameObject("next_item_node")
	if _G.next(next_rewards) then
		if #next_rewards == 1 then
			next_item_node:SetActive(true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_reward_text", false)
			GameUtil:updateItemElement(next_item_node, next_rewards[1], true, false)
		else
			next_item_node:SetActive(false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "next_loopscroll", true)
			local parent = luaBehaviour:FindGameObject("next_loopscroll")
			self:updateRewardLoopScroll(false, parent, next_rewards, index)
		end
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_reward_text", true)
		next_item_node:SetActive(false)
	end
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_name_text", index == 1 and "new_str_0228" or "new_str_0229")
end

function M:updateRewardLoopScroll(isCur, parent, show_data, index)
	local data = show_data or {}
	local reward_scroll = nil
	if isCur then
		reward_scroll = self.m_cur_scroll_tab[index]
	else
		reward_scroll = self.m_next_scroll_tab[index]
	end
	if reward_scroll == nil then
		local loopscroll = parent
		
		local params = {
			show_data = data,
			pos_center = true,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local data = cell_data
				local reward_data = RewardUtil:getProcessRewardData(data)
				local ui_element = GameUtil:updateItemElementByData(cell_object, reward_data, true, true)
				ui_element.red_point_img:SetActive(false)
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
			end,
			ui_name = self.m_uiName
		}
		if isCur then
			self.m_cur_scroll_tab[index] = LoopScrollViewUtil.new(params)
		else
			self.m_next_scroll_tab[index] = LoopScrollViewUtil.new(params)
		end
	else
		reward_scroll:reloadData(data, false, nil, nil, true)
	end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("ArenaNormalRewardTime")
    M.super.destroy(self)
end

return M