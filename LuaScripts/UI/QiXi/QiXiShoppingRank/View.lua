local M = class("QiXiShoppingRankView",LikeOO.OOPopBase)

M.m_uiName = "QiXi/QiXiShoppingRank"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("common_title_text", "qi_xi_040")
	self:setTextByLanKey("inside_rank_label_text", "qi_xi_041")
	self:setTextByLanKey("player_label_text", "qi_xi_042")
	self:setTextByLanKey("lv_label_text", "qi_xi_043")
	self:setTextByLanKey("score_label_text", "qi_xi_044")
	self:setTextByLanKey("inside_rank_own_rank_title_text", "qi_men_dun_jia_str_057")
	
	self:refreshUI()
end

function M:refreshUI()
	self:updateInsideRankLoopScroll()
	local own_data = self.m_model:getMyInsideRankData()
	local won_cfg = own_data.cfg
	local own_info = self:findGameObject("inside_rank_own_info")
	if won_cfg and won_cfg.rank and won_cfg.score then
		own_info:SetActive(true)
		self:updateInsideRankLoopScrollCell(own_info, own_data)
	else
		own_info:SetActive(false)
	end
end

--帮内排行
function M:updateInsideRankLoopScroll()
	local data = self.m_model:getInsideRankData()
	if self.m_inside_rank_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("inside_rank_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateInsideRankLoopScrollCell(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self.m_control:openView("Pops.PlayerInfo", {uid = cell_data.cfg.user.uid, look_model = 1})
			end
		}
		self.m_inside_rank_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_inside_rank_loop_scroll_view:reloadData(data)
	end
end

function M:updateInsideRankLoopScrollCell(cell_object, cell_data, my)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local cfg = cell_data.cfg
	if luaBehaviour and cfg then
		if next(cfg) ~= nil then
			if cfg.rank <= 3 and cfg.rank > 0 then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", true)
				LuaBehaviourUtil.setImg(luaBehaviour, "top_three_rank_img", "a_phb_icon_"..cfg.rank, "common_ui")
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false)
			end
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", cfg.rank)
			local head_node = luaBehaviour:FindGameObject("head_node")
			GameUtil:setUserAvatar(head_node, cfg.user,nil,nil,{show_flag = true, scale = 1})
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cfg.user.name)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "level_text", cfg.score)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "race_score_text", "qi_xi_049", (cell_data.pay_back or 0) * 100)
			if cfg.rank == 0 then
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "kingsoft_text_0042")
			end
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", false)
			if my and my == true then
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "none_rank_text", "未上榜")
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", UserDataManager.user_data:getUserStatusDataByKey("name"))
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "level_text", UserDataManager.user_data:getUserStatusDataByKey("level"))
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "race_score_text", "0")
				local head_node = luaBehaviour:FindGameObject("head_node")
				local user = UserDataManager.user_data.user_status
				GameUtil:setUserAvatar(head_node, user, nil, nil, {show_flag = true, scale = 1})
			end
		end
	end
end

return M