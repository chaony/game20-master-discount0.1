---@class ArenaNormalChallengeView:OOPopBase
---@field m_model ArenaNormalChallengeModel
local M = class("ArenaNormalChallengeView",LikeOO.OOPopBase)

M.m_uiName = "Arena/ArenaNormal/ArenaNormalChallenge"
M.m_size_type = 2

function M:onEnter()
	self:setText("common_title_text", Language:getTextByKey("arena_str_0008"))
	self:setText("close_title_text", "new_str_0386")
	self:setTextByLanKey("refresh_text", "union_str_1035")
	self:refreshUI()
end

function M:refreshUI()
	self:updateListScroll()
	local item_data = UserDataManager.item_data:getItemDataById(1004)
	self:setText("attr_text", tostring(item_data.num))
	self:setTextByLanKey("max_times_text",  Language:getTextByKey("tid#limit_2") ..  self.m_model.m_daily_times .. "/" .. self.m_model:getMaxTimes())
end

 function M:updateListScroll()
	 local data = self.m_model:getListData()
 	if self.m_list_scroll == nil then
 		local list_scroll = self:findGameObject("list_scroll")
 		local params = {
 			show_data = data,
 			one_line_count = 1,
 			loop_scroll_object = list_scroll,
 			pos_center = true,
 			update_cell = function(index, cell_object, cell_data)
 				local transform = cell_object.transform
 				local data = cell_data
 				self:listHandle(cell_object, index, cell_data)
 			end,
 			click_func = function(index, cell_object, cell_data, click_object, click_name)
 				self:updateMsg(click_name, cell_data)
 			end,
			ui_name = self.m_uiName,
 		}
 		self.m_list_scroll = LoopScrollViewUtil.new(params)
 	else
 		self.m_list_scroll:reloadData(data)
 	end
 end


function M:listHandle(obj, id, data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local rank_text = luaBehaviour:FindText("rank_text")
	local rank_img = luaBehaviour:FindImage("rank_img")
	local HeadNode = luaBehaviour:FindGameObject("HeadNode")
	local name_text = luaBehaviour:FindText("name_text")
	local score_text = luaBehaviour:FindText("score_text")
	local power_text = luaBehaviour:FindText("power_text")
	local power_title_text = luaBehaviour:FindText("power_title_text")
	local grading_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "grading_text", "new_str_0262")

	GameUtil:setUserAvatar(HeadNode, data.user, nil, nil, {show_flag = true, scale = 1})
	local title_id = data.user.title
	if title_id and title_id ~= 0 then
		name_text.transform.anchoredPosition = Vector3.New(-225, 0, 0)
		power_title_text.transform.anchoredPosition = Vector3.New(-250, -30, 0)
		power_text.transform.anchoredPosition = Vector3.New(-70, -30, 0)
	else
		name_text.transform.anchoredPosition = Vector3.New(-225, 17, 0)
		power_title_text.transform.anchoredPosition = Vector3.New(-250, -14, 0)
		power_text.transform.anchoredPosition = Vector3.New(-70, -14, 0)
	end
	local room_id = 1 -- 定级暂时又不需要了
	if room_id == 0 then -- 定级中
		grading_text.gameObject:SetActive(true)
		rank_text.gameObject:SetActive(false)
		rank_img.gameObject:SetActive(false)
		score_text.transform.parent.gameObject:SetActive(false)
	else
		grading_text.gameObject:SetActive(false)
		if data.rank >= 1 and data.rank <= 3 then
			rank_text.gameObject:SetActive(false)
			rank_img.gameObject:SetActive(true)
			local top_three_item = GlobalConfig.RANK_TOP_THREE_IMG[data.rank]
			LuaBehaviourUtil.setImg(luaBehaviour,"rank_img", top_three_item.rank, top_three_item.atlas)
		else
			rank_text.gameObject:SetActive(true)
			rank_img.gameObject:SetActive(false)
			rank_text.text = data.rank
		end
		score_text.transform.parent.gameObject:SetActive(true)
	end
	name_text.text = Language:getTextByKey(data.user.name)
	score_text.text = data.score
	power_text.text = data.user.full_combat
	local own_combat = self.m_model.m_combat or 0
	if own_combat > 0 and data.user.full_combat > own_combat*1.1 then
		power_text.color = GlobalConfig.COMMON_COLLOR.COMMON_11
	else
		power_text.color = GlobalConfig.COMMON_COLLOR.COMMON_10
	end
	local free_time = self.m_model:getFreeTimes()
	local free_flag = free_time > 0
	local quick_pass = data.quick_pass or 0 --快速通过 1. 可以 0. 不可以
	local attack_btn_text = nil
	if quick_pass == 0 then
		attack_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attack_btn_text", free_flag and "new_str_0231" or "new_str_0219")
	else
		attack_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attack_btn_text", "new_str_0811")
	end
	UIUtil.setLocalPosition(attack_btn_text.transform, free_flag and 0 or 20)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cost_item_node", not free_flag)
	--attack_btn_text.gameObject:SetActive(free_flag)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "power_title_text", "friend_str_0041")
end

return M