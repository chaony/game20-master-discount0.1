local M = class("QiMenDunJiaTaskRewardPreviewView",LikeOO.OOPopBase)

M.m_uiName = "QiMenDunJia/QiMenDunJiaTaskRewardPreview"
M.m_size_type = 3
M.m_iphoneXAdapter = true

function M:onEnter()
	self.m_union_reward_loop_scroll_view_cache = {}
	self:setTextByLanKey("common_title_text", "qi_men_dun_jia_str_007")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
end

--帮会
function M:updateLoopScroll()
	local data = self.m_model:getExploreData()
	if self.m_loop_scroll_union == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateLoopScrollCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "goto_btn" then
					local status = cell_data.status
					if status ~= -1 then
						self:updateMsg(status == 1 and "reward_btn" or "goto_btn", cell_data)
					end
				end
			end
		}
		self.m_loop_scroll_union = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_union:reloadData(data)
	end
end

function M:updateLoopScrollCell(index, cell_object, cell_data)
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local node = luaBehaviour:FindGameObject("node")

	-- 名字
	UIUtil.setTextByLanKey(node.transform, "name_text", "qi_men_dun_jia_str_010", cell_data.score)
	
	-- 前往、领取按钮
	local goto_btn = UIUtil.findButton(node.transform, "goto_btn")
	local goto_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "goto_btn_text", "new_str_0056") --领取
	local receive_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "receive_btn_text", "new_str_0058") --已领取
	local incomplete_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "incomplete_btn_text", "new_str_0057") --未完成
	local goto_btn_text_show = false
	local receive_btn_text_show = false
	local incomplete_btn_text_show = false
	goto_btn.gameObject:SetActive(false)
	goto_btn.enabled = false
	if cell_data.status == 0 then--前往
		goto_btn.gameObject:SetActive(not cell_data.lock_flag)
		local go_type = cell_data.go_type or {}
		if _G.next(go_type) then
			UIUtil.setImg(node.transform, "a_ui_currency_btn_small_3", "common_ui", "goto_btn")
			goto_btn.enabled = true
			goto_btn_text_show = true
		else
			UIUtil.setImg(node.transform, "a_ui_currency_btn_small_3", "common_ui", "goto_btn")
			goto_btn.enabled = false
			goto_btn.gameObject:SetActive(false)
			incomplete_btn_text_show = true
		end

	elseif cell_data.status == 1 then--可领取
		goto_btn.gameObject:SetActive(true)
		goto_btn.enabled = true
		goto_btn_text_show = true
		UIUtil.setImg(node.transform, "a_ui_currency_btn_small_2", "common_ui", "goto_btn")
	else-- 已领取
		goto_btn.gameObject:SetActive(false)
		receive_btn_text_show = true
	end
	goto_btn_text.gameObject:SetActive(goto_btn_text_show)
	receive_btn_text.gameObject:SetActive(receive_btn_text_show)
	incomplete_btn_text.gameObject:SetActive(incomplete_btn_text_show)

	-- 奖励
	local loop_scroll_object_reward = luaBehaviour:FindGameObject("loopscroll_reward")
	self:updateLoopScrollCellRewardLoopScroll(tostring(cell_object), loop_scroll_object_reward, cell_data.reward)
end

function M:updateLoopScrollCellRewardLoopScroll(loop_scroll_key, loop_scroll_object, reward_data)
	if self.m_union_reward_loop_scroll_view_cache[loop_scroll_key] == nil then
		local params = {
			show_data = reward_data,
			one_line_count = 1,
			loop_scroll_object = loop_scroll_object,
			update_cell = function(index, cell_object, cell_data)
				local item_data = RewardUtil:getProcessRewardData(cell_data)
				GameUtil:updateItemElementByData(cell_object, item_data, true, true)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)

			end
		}
		self.m_union_reward_loop_scroll_view_cache[loop_scroll_key] = LoopScrollViewUtil.new(params)
	else
		self.m_union_reward_loop_scroll_view_cache[loop_scroll_key]:reloadData(reward_data)
	end
end

return M