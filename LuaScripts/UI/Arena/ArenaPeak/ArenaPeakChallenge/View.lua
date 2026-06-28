---@class ArenaPeakChallengeView:OOPopBase
---@field m_model ArenaPeakChallengeModel
local M = class("ArenaPeakChallengeView",LikeOO.OOPopBase)

M.m_uiName = "Arena/ArenaPeak/ArenaPeakChallenge"
M.m_size_type = 2

function M:onEnter()
	self:setText("common_title_text", Language:getTextByKey("arena_str_0008"))
	self:setText("close_title_text", "new_str_0386")
	self:setTextByLanKey("refresh_text", "union_str_1035")
	self:setTextByLanKey("own_rank_title_text", "new_str_0077")
	self:refreshUI()
end

function M:refreshUI()
	local loopscroll = self:findGameObject("list_scroll")
	self:setObjectVisible("owner_content",  true )
	self:refreshOwnInfo()
	self:updateListScroll()
	local item_data = UserDataManager.item_data:getItemDataById(1033)
	self:setText("attr_text", tostring(item_data.num))
	if self.m_model.refresh_cd  then
		self:setObjectVisible("remain_time_text",self.m_model.refresh_cd>0)
		self:setObjectVisible("refresh_btn",self.m_model.refresh_cd==0)
	else
		self:setObjectVisible("remain_time_text",false)
		self:setObjectVisible("refresh_btn",true)
	end
	self:setTextByLanKey("max_times_text",  Language:getTextByKey("tid#limit_2") ..  self.m_model.m_daily_times .. "/" .. self.m_model:getMaxTimes())
end

function M:refreshListRemainTime()
	if self.m_model.refresh_cd ~= nil then
		self.m_model.refresh_cd=self.m_model.refresh_cd-1
		local time_end = self.m_model.refresh_cd
		self:setTextByLanKey("remain_time_text","arena_str_0041",GameUtil:formatTimeBySecond(time_end,999))
		if time_end <= 0 then
			self:setObjectVisible("remain_time_text",false)
			self:setObjectVisible("refresh_btn",true)
		end
	end
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
			ui_name = self.m_uiName,
 			update_cell = function(index, cell_object, cell_data)
 				local transform = cell_object.transform
 				local data = cell_data
 				self:listHandle(cell_object, index, cell_data)
 			end,
 			click_func = function(index, cell_object, cell_data, click_object, click_name)
 				self:updateMsg(click_name, cell_data)
 			end
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

	GameUtil:setUserAvatar(HeadNode, data.user, nil, nil, {show_flag = true, scale = 0.7})
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
	--local free_time = self.m_model:getFreeTimes()
	--local free_flag = free_time > 0
	--local quick_pass = data.quick_pass or 0 --快速通过 1. 可以 0. 不可以
	local attack_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attack_btn_text", "new_str_0219")
	--UIUtil.setLocalPosition(attack_btn_text.transform, free_flag and 0 or 20)
	--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cost_item_node", not free_flag)
	--attack_btn_text.gameObject:SetActive(free_flag)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "power_title_text", "friend_str_0041")

	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "forbidden_text", "arena_str_0049")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"forbiddenNode", self.m_model.ban_num>=1)
	local forbiddenNodeTrans=LuaBehaviourUtil.findGameObject(luaBehaviour,"forbiddenNode").transform
	if self.m_model.ban_num>=1 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "forbidden_text", "arena_str_0049")
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"forbiddenNode2", self.m_model.ban_num==2)
		if data.heros_ban then
			self:setBanHeroInfo(data.heros_ban[1],"forbiddenNode1",forbiddenNodeTrans)
			if self.m_model.ban_num==2 then
				self:setBanHeroInfo(data.heros_ban[2],"forbiddenNode2",forbiddenNodeTrans)
			end
		else
			self:setBanHeroInfo(nil,"forbiddenNode1",forbiddenNodeTrans)
			if self.m_model.ban_num==2 then
				self:setBanHeroInfo(nil,"forbiddenNode2",forbiddenNodeTrans)
			end
		end

	end
end

function M:setBanHeroInfo(id,node,parent)
	local forbiddenNode =UIUtil.findTrans(parent,node)
	UIUtil.setObjectVisible(forbiddenNode,id==nil,"blank_text")
	UIUtil.setObjectVisible(forbiddenNode,id~=nil,"tx_mask")
	if id then
		local hero_cfg=UserDataManager.hero_data:getHeroConfigByCid(id)
		UIUtil.setImg(forbiddenNode, hero_cfg.icon, "hero_head_ui","tx_mask/tx_img")
	end
end

function M:refreshOwnInfo()
	local rank = self.m_model.m_self_rank
	if rank < 1 then
		self:setTextByLanKey("owner_rank_text", "new_str_0076")
	else
		self:setTextByLanKey("owner_rank_text", "new_str_0381", rank)
	end
	local score = self.m_model.m_self_score
	self:setTextByLanKey("owner_score_text", tostring(score))
	local user_data = UserDataManager.user_data.user_status
	local own_head_node = self:findGameObject("own_head_node")
	GameUtil:setUserAvatar(own_head_node, user_data,false,false, {show_flag = true, scale = 1})
	self:setObjectVisible("own_des_text",rank >= 1)
	self:setText("own_des_text", self.m_model:getTopDes())
	local name = UserDataManager.user_data:getUserStatusDataByKey("name")
	self:setText("owner_name_text", name)
	
end

return M