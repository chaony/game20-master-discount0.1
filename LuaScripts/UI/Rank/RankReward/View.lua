local M = class("RankRewardView",LikeOO.OOPopBase)

M.m_uiName = "Rank/RankReward"
M.m_size_type = 2

function M:onEnter()

	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getQuestsData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "look_btn" then
					self:updateMsg("look_top_player", {index = index})
				elseif click_name == "receive_btn" then
					self:updateMsg("receive_awards", {index = index})
				elseif click_name == "head_node" then
					self:updateMsg("look_player", {index = index})
				end
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	UIUtil.setTextByLanKey(transform, "first_title_text", "new_str_0078")
	UIUtil.setTextByLanKey(transform, "first_none_node/none_text", "new_str_0079")
	UIUtil.setTextByLanKey(transform, "name_text", data.cfg.name, data.cfg.target_value)
	local user = data.data.user or {}
	local value = data.data.value or 0 -- 是否完成 0 未完成 1 已完成
	local recv = data.data.recv or 0  -- 是否领奖 0 未领奖 1 已领奖
	local first_flag = _G.next(user)
	UIUtil.setObjectVisible(transform, not first_flag, "first_none_node")
	UIUtil.setObjectVisible(transform, first_flag, "first_player_node")
	if first_flag then
		local time = data.data.time or 0
		local tm = TimeUtil.gmTime(time)
		local time_str = string.format("%d-%02d-%02d %02d:%02d", tm.year, tm.month, tm.day, tm.hour, tm.min)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "player_name_text", "new_str_0499", tostring(user.name) .. "  " .. time_str)
	end
	--local finish_text = UIUtil.setTextByLanKey(transform, "finish_text", "new_str_0080")
	local head_node = luaBehaviour:FindGameObject("head_node")
	GameUtil:setUserAvatar(head_node, user,false,false, {show_flag = true, scale = 1})
	local finish = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "finish_img", false)
	--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unfinished_img", false)
	local can_click = false
	local show_reward = true
	if value == 0 then
		--未完成
		--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unfinished_img", true)
		can_click = true
	else
		if recv == 0 then
			--可领取
			can_click = false
		else
			--已完成
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "finish_img", true)
			can_click = true
			show_reward = false
		end
	end
	local finish_eff = luaBehaviour:FindGameObject("UI_RankReward_LingQu_01")
	-- 奖励
	local drop = data.cfg.drop or {}
	local reward_node = UIUtil.findRectTransform(transform, "reward_node")
	UIUtil.destroyAllChild(reward_node)
	if show_reward == true then
		GameUtil:createRewards(reward_node, drop, true, can_click, function ()
			if value ~= 0 and recv == 0 then
				self:lockTouch()
				finish:SetActive(true)
				finish_eff:SetActive(true)
				finish.transform.localScale = Vector3(2,2,2)
				local sequence = Tweening.DOTween.Sequence()
				sequence:Append(finish.transform:DOScale(1, 0.25):SetEase(Tweening.Ease.Linear))
				sequence:OnComplete(function ()
					finish_eff:SetActive(false)
					self.m_control:setOnceTimer(0.15, function ()
						self:updateMsg("receive_awards", {index = index})
						self:unlockTouch()
					end)
				end)
				sequence:SetAutoKill(true)
			end
		end)
		if value ~= 0 and recv == 0 then
			GameUtil:creatCommonItemEffect(reward_node, 7, 0.95)
		end
	end
end

return M