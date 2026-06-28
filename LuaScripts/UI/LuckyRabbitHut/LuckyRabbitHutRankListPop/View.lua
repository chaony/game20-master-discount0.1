local M = class("LuckyRabbitHutRankListPopView", LikeOO.OOPopBase)

M.m_uiName = "LuckyRabbitHut/LuckyRabbitHutRankListPop"
M.m_iphoneXAdapter = true
M.m_size_type = 2

function M:onEnter()
	local rabbit_gacha_rank =  ConfigManager:getCfgByName("rabbit_gacha_rank")
	self.rank_cfg = rabbit_gacha_rank[self.m_model.m_version]
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
	self:updateSelfRank()
    self:setTextByLanKey("damage_text_","compare_sword_rise_title_007")
	self:setObjectVisible("CommonTipsNode" , false)
	if not next(self.m_model:getRankList()) then
		self:setObjectVisible("CommonTipsNode" , true)
	end
	self:setTextByLanKey("common_title_text","lucky_rabbit_hut_005")
end


--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getRankList() 
	self:setObjectVisible("CommonTipsNode" , #data<=0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateItemInfo(index , cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("item_click", { id = index ,data =cell_data})
			end,
			pull_refresh = function() -- 下拉刷新
				self.last_offsety = self.m_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view.m_scroll_rect.content.rect.height
				self:updateMsg("load_rank")
			end,
			ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
		if self.m_control.m_mail_load == true then
			self:pullRefreshListOffset()
		end
	end
end

function M:updateItemInfo(index , cell_object, celldata)
	local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
	if luaBehaviour then

		if celldata.rank <= 3 then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", true)
			LuaBehaviourUtil.setImg(luaBehaviour, "top_three_rank_img", "a_phb_icon_"..celldata.rank, "common_ui")
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", celldata.rank)
		end
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "server_name_text",  celldata.user.server_name or UserDataManager.server_data:getServerNameById(celldata.user.server))
		--luaBehaviour:FindGameObject("btn_showReport"):SetActive(false)
		local head_node = luaBehaviour:FindGameObject("head_node")
		GameUtil:setUserAvatar(head_node, celldata.user, false, false, {show_flag = true, scale = 1})
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text",celldata.user.name)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "race_score_text", GameUtil:formatValueToString(celldata.score))
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "ratio_text", self:getReturnRatio(index))
		--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "damage_text2", RANK_TXT[celldata.best_stage])
		--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "damage_text2", self.m_model.m_race_type == 2)

	end
end

function M:getReturnRatio(num)
	local ratio = 0
	if num <= 0 then return "0%" end
	for i, v in ipairs(self.rank_cfg) do
		if num <= v.rank[#v.rank] then
			ratio = v["return"]
			return (ratio * 100 ) .. "%"
		end
	end
	return 0
end

function M:updateSelfRank()
	local ownInfoItemGO = self:findGameObject("own_info_Item")
	local luaBehaviour = ownInfoItemGO:GetComponent("LuaBehaviour")
	
	local rank_bgGO = luaBehaviour:FindGameObject("rank_bg")
	local rank_text = luaBehaviour:FindText("rank_text")
	local top_three_rank_img = luaBehaviour:FindImage("top_three_rank_img")
	local none_rank_text = luaBehaviour:FindText("none_rank_text")
	none_rank_text.gameObject:SetActive(false)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "none_rank_text","qi_men_dun_jia_str_021")
	if self.m_model.self_rank==0 then --todo:
		top_three_rank_img.gameObject:SetActive(false)
		rank_bgGO.gameObject:SetActive(false)
		none_rank_text.gameObject:SetActive(true)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", false)
	elseif self.m_model.self_rank > 3 then
		rank_bgGO.gameObject:SetActive(true)
		top_three_rank_img.gameObject:SetActive(false)
		none_rank_text.gameObject:SetActive(false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text",true)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", self.m_model.self_rank)
	else
		rank_bgGO.gameObject:SetActive(false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", false)
		top_three_rank_img.gameObject:SetActive(true)
		if not self.m_model.self_rank then 
			top_three_rank_img.gameObject:SetActive(false)
		end
		local rankNum = self.m_model.self_rank
		self:setImg("a_phb_icon_" .. rankNum , "common_ui" , "top_three_rank_img")
	end
	local userData = UserDataManager.user_data:getOwnRankData({ rank = self.m_rank, score = self.m_score })
	local head_node = luaBehaviour:FindGameObject("head_node")
	GameUtil:setUserAvatar(head_node, userData.user, false, false, {show_flag = true, scale = 1})
	local server_name = UserDataManager.server_data:getServerName()
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text",userData.user.name)
	--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "server_text",server_name)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "race_score_text",GameUtil:formatValueToString(self.m_model.self_score))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "ratio_text", self:getReturnRatio(self.m_model.self_rank))
	--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "race_score_text2",RANK_TXT[self.m_model.self_best_stage] or "")
end

function M:pullRefreshListOffset()
	self.now_offsety = self.m_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view.m_scroll_rect.content.rect.height
	--local position = self.m_list_scroll:getVerticalNormalizedPosition()
	local position = (self.last_offsety - self.now_offsety) / self.m_loop_scroll_view.m_scroll_rect.content.rect.height
	self.m_loop_scroll_view:setVerticalNormalizedPosition(position)
	self.m_control.m_mail_load = false
end


function M:destroy()

	M.super.destroy(self)
end

return M