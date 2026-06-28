--==================================
-- file:  View.lua
-- brief:  巅峰帮会战结算界面
-- author:  LiuMiao
-- date:  2022/7/28
--==================================
local M = class("GuildHighWarSettlementPopView",LikeOO.OOPopBase)

M.m_uiName = "GuildHighWar/GuildHighWarSettlementPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	--self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 18})
	self:setTextByLanKey("close_title_text", "guild_high_war_text_0082")

	self:setTextByLanKey("cur_des_text", "guild_high_war_text_0085")
	self:setTextByLanKey("last_des_text", "guild_high_war_text_0086")
	self:setTextByLanKey("big_close_btn_txt", "guild_high_war_text_0087")
	self:setObjectVisible("guide_btn",false)
	self:refreshUI()
end

--刷新UI
function M:refreshUI()
	--刷新界面
	self:updateButtonAndScreen()
	
end

function M:updateButtonAndScreen()
	self:setObjectVisible("right_btn", self.m_model.m_current_index == 1)
	self:setObjectVisible("left_btn", self.m_model.m_current_index==2)
	self:setObjectVisible("guild_node", self.m_model.m_current_index==1)
	self:setObjectVisible("own_node", self.m_model.m_current_index==2)
	self:setObjectVisible("rank_des",self.m_model.m_current_index==1)
	local icon_path = self.m_model.m_current_index==1 and "a_dfbhz_dianfengbanghuipaiming_txt" or "a_dfbhz_dianfengzhangongpaiming_txt"
	local union_icon_img = self:findImage("Image_title2")
	GameUtil:updateResourcesImg(union_icon_img, "Texture/guildHighWar/" .. icon_path)
	if self.m_model.m_current_index == 1 then
		self:updateDianFenGuildView()
	elseif self.m_model.m_current_index == 2 then 
		self:updateDianFenOwnView()
	end
end

function M:updateDianFenGuildView()
	local data = self.m_model:GetEndGuildRank()
	for i = 1,3 do
		local current_data = data[i]
		if current_data then 
			local user = current_data.user
			--设置帮会名字
			self:setTextByLanKey("guild_name_txt"..i,user.guild_name or "")
			
			--设置会长名字
			self:setTextByLanKey("player_name_txt"..i,user.name or "")
			
			--设置服务器
			local server_name = UserDataManager.server_data:getServerNameById(data[i].guild_info.server)
			self:setTextByLanKey("server_name_txt"..i,server_name or "")
			
			--设置头像
			--local head_node = luaBehaviour:FindGameObject("head_node")
			local head_node = self:findGameObject("head_node"..i)
			GameUtil:setUserAvatar(head_node, user, false, false, {show_flag = true, scale = 1})
			
			--设置会徽
			local gender = data[i].guild_info.flag or 0
			local flag_cfg = ConfigManager:getCfgByName("guild_flag")[gender]
			if flag_cfg then
				local union_icon_img = self:findImage("Image_icon"..i)
				GameUtil:updateResourcesImg(union_icon_img, "Texture/union_emblem/" .. flag_cfg.icon)
			end
			self:setObjectVisible("Image_icon"..i, gender > 0 and flag_cfg)
			self:setObjectVisible("guild_name_empty"..i,false)
		else 
			self:setObjectVisible("guild_icon"..i,false)
			self:setObjectVisible("Image_rank"..i,false)
			self:setObjectVisible("palyer_name"..i,false)
			self:setObjectVisible("guild_name"..i,false)
			self:setObjectVisible("guild_name_empty"..i,true)
			self:setTextByLanKey("guild_name_empty_txt"..i,"guild_high_war_text_0084")
		end
	end
end

function M:updateDianFenOwnView()
	local data = self.m_model:GetEndSelfRank()
	for index = 1,3 do
		local player_data = data[index]
		local rank_obj = self:findGameObject("rank_own_"..index)
		local luaBehaviour = UIUtil.findLuaBehaviour(rank_obj)
		if luaBehaviour then
			if player_data and next(player_data) ~= nil   then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_brand", true)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "player_name_text", player_data.user.name or "") --玩家名称
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "server_name_text", UserDataManager.server_data:getServerNameById(player_data.user.server) or "") --服务器名称
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "guild_name_text", player_data.user.guild_name or "") --帮会名称
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "player_mask", true)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "none_obj", false)
				local rank_spine = luaBehaviour:FindGameObject("rank_spine_"..index)
				self:setSpine(rank_spine, player_data.user.avatar)
				--self.m_model:checkLickData(player_data.user.uid)
				--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "zan_btn_"..index, true)
				--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "zan_num_text"..index, player_data.like)
				--if self.m_model:checkLickData(player_data.user.uid) == true then
					--LuaBehaviourUtil.setImg(luaBehaviour, "zan_btn_"..index, "a_dz_weidianliang", "common_ui")
				--else
					--LuaBehaviourUtil.setImg(luaBehaviour, "zan_btn_"..index, "a_dz_dianliang", "common_ui")
				--end
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
				--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "zan_btn_"..index, false)
			end
		end
	end
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

function M:destroy()

    M.super.destroy(self)
end


return M