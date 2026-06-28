local M = class("MythArenaRewardPopView",LikeOO.OOPopBase)

M.m_uiName = "MythArena/MythArenaRewardPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0284")
	self:setTextByLanKey("common_no_have_text", "new_str_0351")

	self.m_toggle_btns = {}
	for k,v in pairs(self.m_model:getTabBtnNode()) do
		self:setTextByLanKey(v.btn_text, string.cutTextForString(Language:getTextByKey(v.text_key)))
		local tog_btn = self:findToggle(v.btn_key)
		tog_btn.gameObject:SetActive(v.open)
		self.m_toggle_btns[k] = tog_btn
		if k == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
		end
		UIUtil.addToggleListener(tog_btn, function(is_on) 
			if is_on then
				self:updateMsg(k)
			end
		end,nil,self.m_uiName)
	end
	self:updateMsg(self.m_model.m_open_tab_index)
	self:setTextByLanKey("title_text", "new_str_0270")
	self:refreshUI()
end

function M:refreshUI()
	self:setObjectVisible("rank_node", self.m_model.m_sel_tab_index == 1)
	self:setObjectVisible("des_panel", self.m_model.m_sel_tab_index == 2)
	local str = string.gsub(Language:getTextByKey("tid#myth_tips"), "\\n", "\n")
	self:setText("des_text",str)
end

function M:switchTabNode(index)
	local sel_btn_key = nil
	self:setObjectVisible("rank_node", self.m_model.m_sel_tab_index == 1)
	self:setObjectVisible("des_panel", self.m_model.m_sel_tab_index == 2)
	for k,v in pairs(self.m_model:getTabBtnNode()) do
		local cur_tab_text = self:findText(v.btn_text)
		cur_tab_text.color = index == k and GlobalConfig.COMMON_COLLOR.COMMON_1 or GlobalConfig.COMMON_COLLOR.COMMON_5
		if index == k then
			sel_btn_key = v.btn_key
			self:setTextByLanKey("common_title_text", v.text_key)
		end
		self:setObjectVisible("tab_node_" .. k, index == k)
	end
	self:updateRankLoopScroll()
	self:refreshRedPoint()
end

--[[
	创建排行列表
]]
function M:updateRankLoopScroll()
	local data = self.m_model:getRankData()
	local max_index = #data
	self:setObjectVisible("common_tips_node", #data == 0)
	if self.m_rank_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("rank_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateRankScrollViewCell(index, cell_object, cell_data, max_index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, {id = index, cell_data = cell_data})
			end
		}
		self.m_rank_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_rank_loop_scroll_view:reloadData(data, true)
	end
end

--Scroll内cell的回调
function M:updateRankScrollViewCell(index, cell_object, cell_data, max_index)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local reward = cell_data.reward or {} 	-- 奖励
	local reward_node = luaBehaviour:FindRectTransform("reward_node")
	GameUtil:createRewards(reward_node, reward, true, true, nil, 1)
	local rank = cell_data.rank or {}
	local first_rank = rank[1] or 0
	local second_rank = rank[2] or 0

	local top_three_flag = first_rank > 0 and first_rank < 4
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", top_three_flag)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", not top_three_flag)
	local top_three_item = GlobalConfig.RANK_TOP_THREE_IMG[first_rank]
	if top_three_item and top_three_flag then
		LuaBehaviourUtil.setImg(luaBehaviour,"top_three_rank_img", top_three_item.rank, top_three_item.atlas)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "")
	else
		if cell_data.show_name and cell_data.show_name ~= "" then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", cell_data.show_name)
 		elseif index == max_index then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "new_str_0894", first_rank)
		else
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", first_rank .. "-" .. second_rank)
		end
	end
end

function M:refreshRedPoint()
	self:setObjectVisible("togglebtn_red_point_1", false)
	self:setObjectVisible("togglebtn_red_point_2", false)
end

return M