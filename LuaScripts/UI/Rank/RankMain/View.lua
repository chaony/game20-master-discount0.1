local M = class("RankMainView",LikeOO.OOPopBase)

M.m_uiName = "Rank/RankMain"
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("close_title_text","new_str_0385")
	self.m_rank_prefabs = {}
	for i=1,6 do
		local item_node = self:findGameObject("player_item_node_" .. i)
		local rank_cfg = self.m_model:getRankCfgByIndex(i)
		if item_node and rank_cfg then
			local id = rank_cfg.id
			local prefab =GameUtil:createPrefab("Rank/RankMainItem",item_node.transform)
			table.insert(self.m_rank_prefabs, {prefab = prefab, id = id})
			local luaBehaviour = UIUtil.findLuaBehaviour(prefab)
			local data = self.m_model:getRankDataById(id)
			local user = data.user or {}
			local own_head_node = luaBehaviour:FindGameObject("own_head_node")
			GameUtil:setUserAvatar(own_head_node, user, nil, nil,{show_flag = true, scale = 1})
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"rank_player_text",user.name or "")
			local score = data.score or 0
			if id == 1 then--"完成章节"
				local _, _, stage_item = GameUtil:getChapterIdByStageId(score)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"rank_score_text", tostring(stage_item.map_point_name))
			elseif id == 2 then----"爬塔进度"
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"rank_score_text", "new_str_0951", score)
			else
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"rank_score_text", tostring(score))
			end
			if rank_cfg.rece_type then
				local race_item = GlobalConfig.TYPE_HERO_RACE[rank_cfg.rece_type]
				LuaBehaviourUtil.setImg(luaBehaviour, "race_img", race_item.race_icon, ResourceUtil:getLanAtlas())
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "race_img", true)
				self:setTextByLanKey("rank_name_text_" .. i, tostring(race_item.name))
				self:setTextByLanKey("rank_title_text_" .. i, "new_str_0502")
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "race_img", false)
				self:setTextByLanKey("rank_name_text_" .. i, tostring(rank_cfg.short_name))
				self:setTextByLanKey("rank_title_text_" .. i, "new_str_0503")
			end
			--local rol = self:findGameObject("rol_" .. i)
			--CommonUIUtil:createPlayerModel(rol, user)
		end
	end
	self:refreshUI()
end

function M:refreshUI()
	self:refreshRedPoint()

	--快速导航
	self:setObjectVisible("guide_btn", true)
end

function M:refreshRedPoint()
	for k, v in pairs(self.m_rank_prefabs) do
		local luaBehaviour = UIUtil.findLuaBehaviour(v.prefab)
		local red_point = self.m_model:getRankRedPointById(v.id)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"reward_red_point_img",red_point)
	end

end

return M