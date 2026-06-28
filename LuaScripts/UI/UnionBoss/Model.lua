local M = class("UnionBossPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_init_function = nil
	self:getData("guild_boss_index")
end

function M:onEnter()
	self:updateDanData()
	self.m_battle_enemy_id = 1
end

function M:getMaxBattleDamage()
	local value = 0
	return value
end

function M:updateData(data)
	self.m_data = data
	self:updateDanData()
end

function M:updateDanData()
	self.killed_status = self.m_data.killed_status or 0  --被击杀状态  0 未击杀   1 击杀
	self.guild_boss_id = self.m_data.guild_boss_id or 1 --公会boss id
	self.boss_hp = self.m_data.boss_hp or 0 --boss血量
	self.battle_times = self.m_data.battle_times or 0 --今天挑战次数
	self.killers = self.m_data.killers or {} --参与攻击普通状态boss的uid
	self.heirlooms = self.m_data.heirlooms or {} --今日可用的遗物 {'cid': 12, 'param': {'win': 0 },}
	self.guild_heirlooms = self.m_data.guild_heirlooms or {} --今日可用的公会遗物 {'cid': 12, 'param': {'win': 0 },}
	self.restore_heirlooms = self.m_data.restore_heirlooms or {} --第二天可用的遗物id
	self.free_heirloom_pool = self.m_data.free_heirloom_pool or {} --每日进入公会boss赠送的遗物库, 3选1   ## 进游戏需要判断是否有数据, 有数据需要让玩家三选一
	self.battle_heirloom_pool = self.m_data.battle_heirloom_pool or {} --# 战后根据伤害获得的遗物库, 3选1    ## 战斗完需要从这个字段中让玩家三选一
	self.max_damage = self.m_data.max_damage or 0  --# 最大伤害   [最大伤害值, 回放id]
	self.end_day_ts = self.m_data.end_day_ts or 0  --当日结束时间戳
	self.end_week_ts = self.m_data.end_week_ts or 0  --当周结束时间戳
	local guild_boss_reward = ConfigManager:getCfgByName("guild_boss")
	local reward_cfg = guild_boss_reward[self.guild_boss_id]
	self.m_reward = reward_cfg.reward_show
end

function M:getLeftTimes()
	local vip_tab =  ConfigManager:getCfgByName("vip")
	local cur_vip = UserDataManager.user_data.user_status.vip
	local vip_cfg = vip_tab[cur_vip]
	local boss_times = vip_cfg.guild_boss_challenge_times
	return boss_times - self.battle_times or 0
end

function M:checkFirstEnter()
	if next(self.free_heirloom_pool)  then
		return true
	else	
		return false
	end	
end	

function M:checkKillReward()
	
end	

function M:showBossHp()
	local num = self.boss_hp or 0
	local guild_boss_reward = ConfigManager:getCfgByName("guild_boss")
	local boss_reward_data = guild_boss_reward[self.guild_boss_id]
	local max_num = boss_reward_data.real_hp
	return num.."/"..max_num
end

function M:showBossHpPercentage()
	local num = self.boss_hp or 0
	local guild_boss_reward = ConfigManager:getCfgByName("guild_boss")
	local boss_reward_data = guild_boss_reward[self.guild_boss_id]
	local max_num = boss_reward_data.real_hp
	return num/max_num
end

--- 网络数据回调，需要复写
function M:netData(data, tag)
	if tag == "guild_boss_select_heirloom" then
		self:updateData(data)
	end
end

function M:getDefenderUserData()
	local guild_boss = ConfigManager:getCfgByName("guild_boss")[self.guild_boss_id]
	--local stage_battle = ConfigManager:getCfgByName("stage_battle")
	local battle_cfg = ConfigManager:getCfgStageBattle(guild_boss.battle_id)--stage_battle[guild_boss.battle_id]
	local boss = battle_cfg.monster[battle_cfg.boss_position]
	local hero_detail = ConfigManager:getCfgByName("hero_detail")
	local boss_cfg = hero_detail[boss.id]
	local user = {}
	user.avatar = boss.id
	user.level = boss.lv
	user.name = boss_cfg.name
	return user
end

return M
