local M = class("GuildHighNewMainModel", LikeOO.OODataBase)

local PLAYOFF_TYPE = {
	[1] = 4,
	[2] = 6,
	[3] = 8,
	[4] = 10,
}
function M:onCreate()
	M.super.onCreate(self)
	--self:getData("arena_outer_index")
	self:getData()
end

function M:onEnter()
	--Logger.logError(self.m_data, "----------巅峰--")
	self.guild_high_war = self.m_params.guild_high_war
	self.m_sel_tab_index = 1
	self.chapter_season_list ={{name = "guild_high_war_new_007",type = 4},{name = "guild_high_war_new_008",type= 6},{name = "guild_high_war_new_009",type = 8},{name = "guild_high_war_new_0010",type = 10},{name = "guild_high_war_new_0019",type = 2}}
	self.m_reward_data = {}
	self.m_rank_info = self.guild_high_war.rank_info
	self.is_sign_up = self.guild_high_war.is_sign_up --是否报名 0 未报名 1 报名
	self.big_stage = self.guild_high_war.big_stage --大阶段  1:报名, 2:常规赛, 3:季后赛, 4:展示期
	self.cycle = self.guild_high_war.cycle --第几轮
	self.round_id = self.guild_high_war.round_id --第几回合
	self.playoff_type = self.guild_high_war.playoff_type or 0 --季后赛后使用 -- 1:天级赛, 2:地级赛, 3:玄级赛, 4:人级赛, 5:后备赛
	self.cycle_end_ts =  self.guild_high_war.cycle_end_ts
	self.type_end_time = self.guild_high_war.type_end_time
	self.ghw_stage = self.guild_high_war.ghw_stage -- 游戏阶段
	self.is_condition = self.guild_high_war.is_condition or 1--是否够资格
	self.m_reward_type = self:setRewardType() --默认常规赛 帮会奖励
	self.all_round_id = self:getBattleTimes()
	self.is_can_updata = false
	self.m_is_watch = 0 --不是观战
	self.m_guild_info = nil
	self.m_city_data = nil
	self:InitData()
end

function M:getPlayerData(index)
	if self.big_stage == 3 then --季后赛
		return self.m_rank_info[tostring(self.m_sel_tab_index)][index] or {}
	elseif self.big_stage == 2 then
		return self.m_rank_info[tostring(self.playoff_type)][index] or {}
	else
		return {}
	end
end

function M:checkHaveTop()
	if self.m_data.pre_top_n == nil or next(self.m_data.pre_top_n) == nil then
		return false
	end 
	return true
end

function M:checkLickData(uid)
	for k,v in pairs(self.m_data.like_data) do
		if uid == v then
			return true
		end
	end
	return false
end

function M:getTopPlayerByIndex(index)
	local c_data = self.m_data.pre_top_n[tostring(index)]
	return c_data.user.uid
end

function M:updateLikeNumByIndex(index, num)
	local c_data = self.m_data.pre_top_n[tostring(index)]
	c_data.like = num or 0
end


function M:checkTeamLock()
	local c_tim = UserDataManager:getServerTime()
	local end_ts = self:getDownTime()
	local last_tim = end_ts - c_tim
	if last_tim < 3600 then
		return false
	end
	return true
end

function M:getDownTime()
	return UserDataManager.end_ts
end


---------------------------------------
function M:InitData()
	self.m_reward_data = {}
	local cfg = ConfigManager:getCfgByName("guild_high_war_reward_rank")
	if cfg then
		for k,v in ipairs(cfg) do 
			local list = {}
			for m,n in pairs(v) do 
				n.index = m
				table.insert(list,n)
			end
			table.sort(list,function(a, b) 
				return a.index < b.index
			end)
			self.m_reward_data[k] = list
		end
	end
end

function M:UpdateWarData(data)
	self.guild_high_war = data
	self.chapter_season_list ={{name = "guild_high_war_new_007",type = 4},{name = "guild_high_war_new_008",type= 6},{name = "guild_high_war_new_009",type = 8},{name = "guild_high_war_new_0010",type = 10},{name = "guild_high_war_new_0019",type = 2}}
	self.m_reward_data = {}
	self.m_rank_info = self.guild_high_war.rank_info
	self.is_sign_up = self.guild_high_war.is_sign_up --是否报名 0 未报名 1 报名
	self.big_stage = self.guild_high_war.big_stage --大阶段  1:报名, 2:常规赛, 3:季后赛, 4:展示期
	self.cycle = self.guild_high_war.cycle --第几轮
	self.round_id = self.guild_high_war.round_id --第几回合
	self.playoff_type = self.guild_high_war.playoff_type --季后赛后使用
	self.cycle_end_ts =  self.guild_high_war.cycle_end_ts
	self.type_end_time = self.guild_high_war.type_end_time
	self.ghw_stage = self.guild_high_war.ghw_stage -- 游戏阶段
	self.is_condition = self.guild_high_war.is_condition or 0--是否够资格
	self.m_reward_type = self:setRewardType() --默认常规赛 帮会奖励
	self.all_round_id = self:getBattleTimes()
	self:InitData()
end

function M:getRewardData(type)
	return self.m_reward_data[type]
end

function M:getEndTs()
	local end_ts = self.type_end_time - UserDataManager:getServerTime()
	return end_ts
end

function M:getCycleEndTs()
	local end_ts = self.cycle_end_ts - UserDataManager:getServerTime()
	return end_ts
end

function M:setRewardType()
	if self.big_stage == 1 or self.big_stage == 2 then
		--第一种
		--return 2 -- 常规赛 
		--第二种
		return PLAYOFF_TYPE[self.m_sel_tab_index]
	elseif self.big_stage == 3 then
		return PLAYOFF_TYPE[self.m_sel_tab_index]
	end
end

function M:getGuildHighWarData()
    return self.guild_high_war
end

function M:getBattleTimes()
	local cfg  = ConfigManager:getCfgByName("guild_high_war_base")
	local time = 10
	if cfg then
		for k,v in pairs(cfg) do
			if v.cycle == self.cycle and v.type == self.big_stage then
				time = v.battle_time
			end
		end
	end
	return time
end
return M
