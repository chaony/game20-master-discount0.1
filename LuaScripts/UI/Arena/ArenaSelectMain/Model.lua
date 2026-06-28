---@class ArenaSelectMainModel:OODataBase
local M = class("ArenaSelectMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("arena_index")
end

function M:onEnter()
	--{
	--	'arena': 
	--	{          # 竞技场
	--		'rank': 0,          # 当前排名
	--		'last_time': 0,     # 结束时间
	--		'combat': 0,        # 战力 
	--	},
	--	'high_arena': 
	--	{          # 竞技场
	--		'rank': 0,          # 当前排名
	--		'last_time': 0,     # 结束时间
	--		'combat': 0,        # 战力
	--		'arena_coin_store': 0,  # 竞技场币库存
	--	},
	--	'race_arena': 
	--	{          # 种族竞技场
	--		'rank': 0,          # 当前排名
	--		'last_time': 0,     # 结束时间
	--		'combat': 0,        # 战力
	--	},
	--	'guild_war' :
	--  {
	--	
	--  }
	--}
	--"rise_arena": {     // 争锋联赛
	--"rise_id": 0,       // 赛事id
	--"rank": 0,          // 当前排名
	--"end_ts": 0,        // 结束时间戳
	--"combat": 0,        // 战力
	--}

	self:initData()
end

function M:initData(data)
	table.merge(self.m_data, data or {})
	--类型结束时间
	-- self.type_end_time = self.m_data["guild_war"].type_end_time
	-- self.type = self.m_data["guild_war"].type
end
--获取剩余时间
function M:getRemainTime()
	local time = self.type_end_time - UserDataManager:getServerTime()
	return time;
end

function M:getbgIndex(rise_id)
	if rise_id==1 then
		return 1
	elseif rise_id==2 or rise_id==3 then
		return 2
	elseif rise_id==4 or rise_id==5 then
		return 3
	end
end


--获取各个阶段结束时间
function M:getTypeEndTime()
	local time = self:getRemainTime();
	local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(time)
	if day > 0 then
		hour = hour + day * 24;
	end
	return string.format("%02d:%02d:%02d", hour, min, sec)
end

--获取竞技场数据
-- arena 		普通竞技场
-- high_arena   高阶竞技场
-- race_arena   种族竞技场
-- top_arena    天级赛
function M:getAreaData( key )
	if key == "top_race_arena" then
		key = "race_arena"
	end
	return self.m_data[key];
end

function M:getArenaDataByKey(key)
	if key == "top_race_arena" then
		key = "race_arena"
	end
	return self.m_data[key]
end

function M:setArenaDataByKey(key, key2, value)
	if key == "top_race_arena" then
		key = "race_arena"
	end
	if self.m_data[key] and  self.m_data[key][key2] then
		self.m_data[key][key2] = value
	end
end


--elseif key == "fylt" then
--return {}

function M:getFyltTime()
	local server_time = UserDataManager:getServerTime()
	local time = self.fylt_weekly_etime - server_time
	if time <= 0 then
		return
	end
	local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(time)
	return Language:getTextByKey("legend_str_026", day, hour)
end

--检查提前显示凌云阁
function M:getAheadShowTopArena()
	local cfg = BtnOpenUtil:getBtnCfg(34)
	local cur_stage = UserDataManager:getCurStage()
	if cur_stage >= cfg.unlock_condition_param then --关卡达到
		if cfg.unlock_days and cfg.unlock_days > 0 then
			local day = GameUtil:playerRegisterDays()
			if day < cfg.unlock_days then
				if (cfg.unlock_days - day) <= 2 then
					local server_ts = UserDataManager:getServerTime()
					local open_ts = server_ts + (86400*(cfg.unlock_days - day))
					local next_fresh_time = TimeUtil.getIntTimestamp(open_ts)
					self.open_top_arena_ts = next_fresh_time
					return true
				end
			end
		end
		return false
	end
	return false
end


return M
