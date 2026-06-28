local M = class("PeakArenaResultPopView",LikeOO.OOPopBase)

M.m_uiName = "PeakArena/PeakArenaResultPop"
M.m_size_type = 2

function M:onEnter()
	self:refreshUI()
end

--刷新UI
function M:refreshUI()
	for i = 1,3 do
		self:updatePlayerInfo(i)
	end
	self:setTextByLanKey("des_text", Language:getTextByKey("peak_str_0044"))
	self:setTextByLanKey("tips_text", "new_str_0243")
	local str = self.m_model:getSeasonTime()
	self:setTextByLanKey("time_text", Language:getTextByKey("peak_str_0045",str))
end

function M:updatePlayerInfo(index)
	local player_data = self.m_model:getPlayerData(index)
	local rank_obj = self:findGameObject("rank_"..index)
	local luaBehaviour = UIUtil.findLuaBehaviour(rank_obj)
	if luaBehaviour then
		if next(player_data) ~= nil then
			local server_name = UserDataManager.server_data:getServerNameById(player_data.server)
			local str = Language:getTextByKey("peak_str_0058", server_name)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", str..player_data.name)
			local rank_spine = luaBehaviour:FindGameObject("rank_spine_"..index)
			self:setSpine(rank_spine, player_data.avatar)
			self:setObjectVisible("rank_"..index, true)
		end
	end
end

function M:setSpine(play_img, hero_id)
	local cfg = ConfigManager:getPlayerPictureCfg(tonumber(hero_id))
	local spine =  "hero_0101_SkeletonData"
	if cfg and next(cfg) ~= nil then
		spine = cfg.hero_spine
	else
		local cur_skin_cfg = ConfigManager:getHeroSkinCfg(hero_id)
		if cur_skin_cfg then
			spine = cur_skin_cfg.hero_spine
		end	
	end
	GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" ..spine, "idle", 0, true)
end


return M