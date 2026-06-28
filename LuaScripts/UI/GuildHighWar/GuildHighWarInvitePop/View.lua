local M = class("GuildHighWarInvitePopView",LikeOO.OOPopBase)

M.m_uiName = "GuildHighWar/GuildHighWarInvitePop"
M.m_size_type = 2
--M.m_iphoneXAdapter = true

function M:onEnter()
	--self:setTextByLanKey("title_text1", "guild_high_war_text_0015")
	--self:setTextByLanKey("title_text2", "guild_high_war_text_0016")
	--self:setTextByLanKey("title_text3", "guild_high_war_text_0017")
	self:refreshUI()
	self:setTextByLanKey("common_title_text", "guild_high_war_text_0014")
end

function M:destroy()
	M.super.destroy(self)
end

function M:refreshUI()
	--self:updateLoopScroll()
	--local data = UserDataManager.user_data:getOwnRankData({ rank = 1, score = 1 })
	local data = self.m_model.invite_data
	if not data or data == {} then return end
	local starT = TimeUtil.gmTime(self.m_model.end_time + 1 or 0)
	local timerFormat = Language:getTextByKey("achievement_text5", starT.year, starT.month, starT.day, starT.hour, starT.min)
	self:setTextByLanKey("des_text","tid#guild_high_yaoqing",timerFormat)
	self:setTextByLanKey("server_text",UserDataManager.server_data:getServerNameById(data.server) or "")
	self:setTextByLanKey("name_text",data.name)
	self:setTextByLanKey("guild_text","guild_high_war_text_0098")
	self:setTextByLanKey("guild_name_text",data.guild_name)
	local rank_spine = self:findGameObject("rank_spine_2")
	self:setSpine(rank_spine, data.avatar)
	local head_title_img = self:findGameObject("head_title_img")
	local title_id = data.title
	if title_id and title_id ~= 0 then
		head_title_img:SetActive(true)
		self:setTitleImage(title_id,head_title_img)
	else
		head_title_img:SetActive(false)
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

return M