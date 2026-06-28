local M = class("LittleGamesView",LikeOO.OOPopBase)

M.m_uiName = "LittleGames/LittleGames"
M.m_size_type = 2

function M:onEnter()
	if self.m_model.m_title then
		self:setTextByLanKey("common_title_text", self.m_model.m_title)
	else
		self:setTextByLanKey("common_title_text", "new_str_0921")
	end
	self:setTextByLanKey("rank_label_text", "new_str_0374")
	self:setTextByLanKey("player_label_text", "new_str_0372")
	self:setTextByLanKey("score_label_text", "new_str_0375")
	self:setTextByLanKey("own_rank_title_text", "new_str_0077")
	self:setTextByLanKey("start_btn_text", "new_str_0917")
	self:setTextByLanKey("rank_reward_btn_text", "new_str_0918")
	self:setTextByLanKey("time_title_text", "new_str_0919")
	self:setTextByLanKey("score_reward_box_text", "new_str_0920")
	self.m_time_text = self:findText("time_text")
	self.m_box_node = self:findGameObject("box_node")
	self.m_box_node_rt = UIUtil.findRectTransform(self.m_box_node)
	self.m_score_box_reward_slider = self:findSlider("score_box_reward_slider")
	self:setTextByLanKey("common_no_have_text", "new_str_0351")
	GameUtil:updateResourcesImg(self:findImage("show_big_img"), "Texture/little_games/" .. self.m_model.m_game_street_cfg.picture)
	self:setImg(self.m_model.m_game_street_cfg.game_name, "language_zh_cn", "show_big_img_text")
	local game_name_img = self:findImage("show_big_img_text")
	game_name_img:SetNativeSize()
	self:refreshUI()
end

function M:refreshUI()
	local end_time = self.m_model.m_data.end_ts or 0
	if self.m_model.is_mult == true then
		end_time = self.m_model.m_end_ts
	end
	GameUtil:remainingTimeUpdate(self.m_control, "little_game_time_update", self.m_time_text, end_time, "time_end", 1)
	self:updateLoopScroll()
	self:updateRankLoopScroll()
	self:updateScoreReward()
	local own_info_node = self:findGameObject("own_info_node")
	local self_data = self.m_model:getSelfRankData()
	self:updateRankScrollViewCell(-1, own_info_node, self_data)
	if self.m_model.is_mult == true then
		self:setObjectVisible("time_text", false)
		self:setObjectVisible("time_title_text", false)
	else
		self:setObjectVisible("time_text", true)
		self:setObjectVisible("time_title_text", true)
	end
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getShowData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 2, -- 行或列的数量
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, {id = index , cell_data = cell_data})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cell_data.name)
end

--[[
	创建列表
]]
function M:updateRankLoopScroll()
	local data = self.m_model:getRankData()
	self:setObjectVisible("CommonTipsNode", #data == 0)
	if self.m_rank_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("rank_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateRankScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("item_click", {index = index, cell_data = cell_data})
			end,
			ui_name = self.m_uiName
		}
		self.m_rank_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_rank_loop_scroll_view:reloadData(data)
	end
end

--Scroll内cell的回调
function M:updateRankScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	local user = data.user or {}
	local rank = data.rank or 0
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local top_three_flag = rank > 0 and rank < 4
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", top_three_flag)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", not top_three_flag)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", not top_three_flag)
	local top_three_item = GlobalConfig.RANK_TOP_THREE_IMG[rank]
	if top_three_item then
		LuaBehaviourUtil.setImg(luaBehaviour,"top_three_rank_img", top_three_item.rank, top_three_item.atlas)
	end
	if rank < 1 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "new_str_0076")
	else
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", tostring(rank))
	end
	local score = data.score or 0
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_text", tostring(score))
	if user.name == nil or user.name == "" then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(user.uid))
	else
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(user.name))
	end
	local head_node = luaBehaviour:FindGameObject("head_node")
	GameUtil:setUserAvatar(head_node, user,false,false,{show_flag = true, scale = 1})
end

function M:updateScoreReward()
	local box_trans = self.m_box_node.transform
	UIUtil.destroyAllChild(box_trans)
	local show_data, cur_num = self.m_model:getScoreRewardData()
	local width = self.m_box_node_rt.rect.width
	local max_num = 0
	local box_num = #show_data
	if show_data[box_num] then
		max_num = show_data[box_num].cfg.milepost
	end
	max_num = max_num > 0 and max_num or 100
	self:setTextByLanKey("score_reward_box_text", "new_str_0689", cur_num)
	self.m_score_box_reward_slider.value = cur_num/max_num
	for i=1,box_num do
		local data = show_data[i]
		local cfg = data.cfg
		local task_box = GameUtil:createPrefab("LittleGames/LittleGamesScoreRewardBox", box_trans)
		local transform = task_box.transform
		local luaBehaviour = UIUtil.findLuaBehaviour(transform)
		UIUtil.setLocalPosition(task_box, width*cfg.milepost/max_num - width*0.5 - 20, 0)
		local function btns(trans,params)
			if data.status == 2 then -- 可领取
				self:updateMsg("box_reward", {click_transform = trans, data = data})
			else
				self:updateMsg("box_click", {click_transform = trans, data = data})
			end
		end
		UIUtil.setButtonClick(transform, btns, i)
		local score_text = UIUtil.setText(transform, tostring(cfg.milepost), "score_text")
		local finish_text = UIUtil.setTextByLanKey(transform,"finish_text", "new_str_0080")
		local box_effect = UIUtil.findRectTransform(transform, "UI_Arena_BX_01")
		local box_effect2 = UIUtil.findRectTransform(transform, "UI_Arena_BX_02")
		local box_img = luaBehaviour:FindImage("box_img")
		if box_effect ~= nil then
			box_effect.gameObject:SetActive(false)
		end
		if box_effect2 ~= nil then
			box_effect2.gameObject:SetActive(false)
		end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Arena_BX_02", data.status == 2)
		local drop_show = cfg.reward or {}
		if #drop_show > 0 then
			if not IsNull(box_img) then
				UIUtil.setImgAlpha(box_img, 0)
			end
			local box_img = luaBehaviour:FindGameObject("box_img")
			local item, ui_element = GameUtil:createItemElement(drop_show[1], false, false)
			local canvas_group = item:GetComponent("CanvasGroup")
			canvas_group.blocksRaycasts = false
			canvas_group.interactable = false
			ui_element.duigoudi_img:SetActive(data.status == -1)
			UIUtil.setScale(item.transform, 0.7)
			UIUtil.setLocalPosition(item.transform, nil, 10)
			item.transform:SetParent(box_img.transform, false)
			if data.status == 2 then
				local quality = ui_element.process_data.quality
				GameUtil:creatCommonItemEffect(item, quality, 1)
			end
		end
	end
end

function M:destroy()
	EventDispatcher:unRegisterEvent("little_game_time_update")
	M.super.destroy(self)
end

return M