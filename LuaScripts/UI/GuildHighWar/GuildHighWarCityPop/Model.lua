local M = class("GuildHighWarCityPopModel", LikeOO.OODataBase)

M.BATTLE_STATUS = {
	PREPARE = 0, --准备阶段
	BATTLING = 1,--交战中
	ATK = 2,--进攻（派遣队伍）
	DEF = 3,--防守（驻守队伍）
	PRE_DECLARE = 4,--(可宣战)
	DECLARING = 5,--(宣战中)
	WATCH = 6,--(观战)
	MATCH = 8,--匹配阶段
	FORMULA = 9,--公式阶段
}
--
----服务器返回的当前阶段
--M.SERVER_GHW_STAGE = {
--	PREPARE = 3, --准备阶段
--	FORMATION = 4,--战斗布阵阶段
--	BATTLE = 5, --战斗中阶段
--	DECLARE = 6,-- 战斗宣战阶段
--	AFTER_BATTLE = 7,--战斗结束阶段
--}
local G_CFG = GlobalConfig
function M:onCreate()
	M.super.onCreate(self)
	self:getData("")
end

function M:onEnter()
	self.m_guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
	self.m_city_id = self.m_params.city_id
	self.m_city_data = self.m_params.city_data
	self.m_guild_data = self.m_params.guild_data
	self.m_ghw_stage = self.m_params.ghw_stage
	self.m_declare_times = self.m_params.m_declare_times or 0
	self.m_is_watch = 0
	self.m_position = self.m_params.position or 0
	local guild_high_war_build = ConfigManager:getCfgByName("guild_high_war_build") or {}
	self.m_city_cfg = guild_high_war_build[self.m_city_id] or {}
	self.m_cur_reward_cfg = self:getCurSeasonRewardCfg()
	self:initCityStatus()
	self:getCityRewards()
	local atk_name = self:getAtkGuildNameByCityId(self.m_city_id)
	self.m_have_atk = atk_name ~= ""
end

function M:updateCityData(citys)
	if citys and citys[self.m_city_id] then
		self.m_city_data = citys[self.m_city_id]
	end
	self:initCityStatus()
end

function M:isGuildManager()
	return self.m_position == G_CFG.UNION_POS.PRESIDENT or self.m_position == G_CFG.UNION_POS.PRESIDENT_VICE
end

function M:isWatch()
	return self.m_is_watch == 1
end

function M:isAtk()
	local is_atk = false
	local _, atk_guild_id = self:getAtkGuildNameByCityId()
	if self.m_guild_id > 0 and self.m_guild_id == atk_guild_id then
		is_atk = true
	end 
	return is_atk
end

function M:isDef()
	local is_def = false
	local _, def_guild_id = self:getOwnerNameByCityId()
	if self.m_guild_id > 0 and self.m_guild_id == def_guild_id then
		is_def = true
	end
	return is_def
end

--M.SERVER_GHW_STAGE = {
--	PREPARE = 3, --准备阶段
--	FORMATION = 4,--战斗布阵阶段
--	BATTLE = 5, --战斗中阶段
--	DECLARE = 6,-- 战斗宣战阶段
--	AFTER_BATTLE = 7,--战斗结束阶段
--}

--M.SERVER_GHW_STAGE = {
--	PREPARE = 3, --准备阶段
--	FORMATION = 4,--战斗布阵阶段
--	BATTLE = 5, --战斗中阶段
--	DECLARE = 3,-- 战斗宣战阶段
--	AFTER_BATTLE = 7,--战斗结束阶段
--}

function M:initCityStatus()
	if self.m_ghw_stage == G_CFG.SERVER_GHW_STAGE.PREPARE then
		self.m_city_stauts = self.BATTLE_STATUS.PREPARE
	elseif self.m_ghw_stage == G_CFG.SERVER_GHW_STAGE.FORMATION then
		if self:isDef() then
			self.m_city_stauts = self.BATTLE_STATUS.DEF
		elseif self:isAtk() then
			self.m_city_stauts = self.BATTLE_STATUS.ATK
		else 
			self.m_city_stauts = self.BATTLE_STATUS.WATCH
		end
	elseif self.m_ghw_stage == G_CFG.SERVER_GHW_STAGE.BATTLE then
		self.m_city_stauts = self.BATTLE_STATUS.BATTLING
	elseif self.m_ghw_stage == G_CFG.SERVER_GHW_STAGE.DECLARE then
		self.m_city_stauts = self.BATTLE_STATUS.DECLARING
	elseif self.m_ghw_stage == G_CFG.SERVER_GHW_STAGE.FORMULA then 
		self.m_city_stauts = self.BATTLE_STATUS.FORMULA
	end
end

function M:getCityStatusDes()
	local status_text = "kingsoft_text_0042"
	local atk_name = self:getAtkGuildNameByCityId(self.m_city_id)
	if self.m_ghw_stage == G_CFG.SERVER_GHW_STAGE.BATTLE then
		status_text = "fylt_str_0025"
	elseif self.m_ghw_stage == G_CFG.SERVER_GHW_STAGE.FORMATION then
		if atk_name ~= "" then
			status_text = Language:getTextByKey("guild_high_war_text_0052", atk_name) 
		else
			status_text = "guild_high_war_text_0023"
		end
	elseif self.m_ghw_stage == G_CFG.SERVER_GHW_STAGE.DECLARE then
		if atk_name ~= "" then
			status_text = Language:getTextByKey("guild_high_war_text_0052", atk_name)
		else
			status_text = "guild_high_war_text_0023"
		end
	end 
	return status_text
end

function M:getCfgValueByKey(cfg_key)
	if self.m_city_cfg[cfg_key] then
		return self.m_city_cfg[cfg_key]
	end
	return nil
end

--拆分出来的奖励
function M:getCityRewards2()
	if self.m_city_cfg then
		return self.m_city_cfg.display_rewards
	end
	return nil
end


function M:getCityRewards()
	local reward_box_id = self:getCfgValueByKey("reward_box_id")
	local rewards = {}
	for i = 1, #reward_box_id do
		local reward_id = reward_box_id[i]
		if  self.m_cur_reward_cfg[reward_id] and self.m_cur_reward_cfg[reward_id].box_reward then
			local box_rewards = self.m_cur_reward_cfg[reward_id].box_reward
			for j = 1, #box_rewards do
				rewards[#rewards+1] = box_rewards[j]
			end
		end
	end
	return rewards
end

function M:getCurSeasonRewardCfg()
	local cur_season = UserDataManager:getCurSeason() + 2
	local guild_high_war_reward_day = ConfigManager:getCfgByName("guild_high_war_reward_day") or {}
	local temp_season = 0
	for i, v in pairs(guild_high_war_reward_day) do
		if cur_season >= i then
			temp_season = math.max(temp_season, i)
		end
	end
	if temp_season ~= 0 then
		return guild_high_war_reward_day[temp_season]
	end
	return {}
end

function M:getGuildDataById(guild_id)
	guild_id = tostring(guild_id)
	if self.m_guild_data[guild_id] then
		return self.m_guild_data[guild_id]
	end
	return nil
end

function M:getOwnerNameByCityId(city_id)
	local owner_name, owner_guild_id = "", 0
	local city_data = self.m_city_data
	if city_data then
		local owner_guild = city_data.owner_guild or {}
		owner_guild_id = owner_guild.guild_id
		local guild_data = self:getGuildDataById(owner_guild_id)
		if guild_data then
			owner_name = guild_data.name
		end
	end
	return owner_name, owner_guild_id
end

function M:getAtkGuildNameByCityId()
	local atk_name, atk_guild_id = "", 0
	local city_data = self.m_city_data
	if city_data then
		local challenger_guild = city_data.challenger_guild or {}
		local challenger_guild_id = challenger_guild.guild_id or 0
		atk_guild_id = challenger_guild_id
		local guild_data = self:getGuildDataById(challenger_guild_id)
		if guild_data then
			atk_name = guild_data.name
		end
	end
	return atk_name, atk_guild_id
end

return M
     