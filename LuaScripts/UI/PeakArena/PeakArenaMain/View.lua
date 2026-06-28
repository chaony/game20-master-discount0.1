local M = class("PeakArenaMainView",LikeOO.OOPopBase)

M.m_uiName = "PeakArena/PeakArenaMain"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 18})
	self:setTextByLanKey("close_title_text", "peak_str_0006")
	self:setTextByLanKey("shop_btn_text", "new_str_0861")
	self:setTextByLanKey("reward_btn_text", "new_str_0373")	
	self:setTextByLanKey("guess_btn_text", "peak_str_0016")	
	self:setTextByLanKey("down_time_title_text", "kaiqi_text")
	self:setTextByLanKey("peak_game_btn_text", "jinru_dfs_text")
		
	self:refreshUI()
end

--刷新UI
function M:refreshUI()
	for i = 1,3 do
		self:updatePlayerInfo(i)
	end
	self:setBottomUI()
	self:refreshRedPoint()
	--快速导航
	self:setObjectVisible("guide_btn", true)
end

function M:refreshRedPoint()
	self:setObjectVisible("guess_red_point", self.m_model:checkGuessRedPoint())
end

function M:setBottomUI()
	if self.m_model:checkOpenType() == false or self.m_model:checkHasData() == false then
		self:setTextByLanKey("cur_des_text", Language:getTextByKey("peak_str_0046"))
		self:setTextByLanKey("down_time_des_text", Language:getTextByKey("peak_str_0060"))
	elseif self.m_model.m_data.week and self.m_model.m_data.week > 7 then
		self:setTextByLanKey("cur_des_text", Language:getTextByKey("peak_str_0065"))	
		self:setTextByLanKey("down_time_des_text", self.m_model:getSeasonTime())
	else
		self:setTextByLanKey("cur_des_text", Language:getTextByKey("peak_str_0011")..self.m_model:getCurBattleStatus())	
		self:setTextByLanKey("down_time_des_text", self.m_model:getSeasonTime())
	end
	self:setTextByLanKey("last_des_text", Language:getTextByKey("peak_str_0012")..self.m_model:getPreRank())
	self:setTextByLanKey("history_des_text", Language:getTextByKey("peak_str_0013")..self.m_model:getBestRank())
end

function M:updatePlayerInfo(index)
	local player_data = self.m_model:getPlayerData(index)
	local rank_obj = self:findGameObject("rank_"..index)
	local luaBehaviour = UIUtil.findLuaBehaviour(rank_obj)
	if luaBehaviour then
		if next(player_data) ~= nil then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "zan_num_text", 0)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", player_data.user.name)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_brand", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "player_mask", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "none_obj", false)
			local rank_spine = luaBehaviour:FindGameObject("rank_spine_"..index)
			self:setSpine(rank_spine, player_data.user.avatar)
			self.m_model:checkLickData(player_data.user.uid)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "zan_btn_"..index, true)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "zan_num_text"..index, player_data.like)
			if self.m_model:checkLickData(player_data.user.uid) == true then
				LuaBehaviourUtil.setImg(luaBehaviour, "zan_btn_"..index, "a_dz_weidianliang", "common_ui")
			else
				LuaBehaviourUtil.setImg(luaBehaviour, "zan_btn_"..index, "a_dz_dianliang", "common_ui")	
			end
			local head_title_img = luaBehaviour:FindGameObject("head_title_img")
			local title_id = player_data.user.title
			if title_id and title_id ~= 0 then
				head_title_img:SetActive(true)
				self:setTitleImage(title_id,head_title_img)
			else
				head_title_img:SetActive(false)
			end
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_brand", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "player_mask", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "none_obj", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "zan_btn_"..index, false)
		end
	end
end

function M:setBrandData(obj, data)
	if data then
		UIUtil.setTextByLanKey(obj.transform, "name_text", data.user.name)
	else
		UIUtil.setTextByLanKey(obj.transform, "name_text", "new_str_0835")
	end
end

function M:setSpine(play_img, hero_id)
	local cfg = ConfigManager:getPlayerPictureCfg(tonumber(hero_id))
	local spine =  "hero_0101_SkeletonData"
	if cfg and next(cfg) ~= nil then
		spine = cfg.hero_spine
	else
		local cur_skin_cfg = ConfigManager:getHeroSkinCfg(hero_id)
		if cur_skin_cfg and next(cur_skin_cfg) ~= nil then
			spine = cur_skin_cfg.hero_spine
		end
	end
	GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" ..spine, "idle", 0, true)
end

-- 设置称号图片
function M:setTitleImage(title_id, titleObj)
	if title_id and title_id ~= 0 then
		titleObj:SetActive(true)
		local name_img = titleObj:GetComponent("Image")
		local cfg = UserDataManager.title_data:getTitleConfigById(title_id)
		UIUtil.destroyAllChild(name_img.gameObject.transform)
		if cfg.title_effect and cfg.title_effect ~= "" then
			ResourceUtil:GetUIEffectItem("Headtitle/" .. cfg.title_effect, name_img.gameObject)
			name_img.enabled = false
		else
			GameUtil:setTextureLoadTitleLanImgText(titleObj, cfg.icon) -- 设置称号图片
			name_img:SetNativeSize()
			name_img.enabled = true
		end
	else
		titleObj:SetActive(false)
	end
end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end


return M