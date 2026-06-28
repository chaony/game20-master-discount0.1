local M = class("TotalWorldModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("world_index")
end

function M:onEnter()

end

function M:getAreaData( key )
	if key == "top_race_arena" then
		key = "race_arena"
	end
	return self.m_data[key];
end

--是否开启五行联赛
function M:isOpenFiveRace()
	if self.m_data["race_arena"] and self.m_data["race_arena"].match_type and self.m_data["race_arena"].match_type == 2 then
		return true
	end
	return false
end

--检查是否有赛季预告
function M:isHaveNextSeason()
	local cur_cfg = {}
	local cur_season = UserDataManager:getCurSeason() + 1
	local season_notice_cfg = ConfigManager:getCfgByName("season_notice")
	if season_notice_cfg and season_notice_cfg[cur_season] then
		return true
	end
	return false
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

function M:checkSeasonPreviewOpen()
	local openSeasonPreviewFlag = true
	local tips_str = ""
	local open_flag1, tips_str1 = BtnOpenUtil:isBtnOpen(218)
	if open_flag1 == false then
		openSeasonPreviewFlag = false
		tips_str = tips_str1
	end
	if openSeasonPreviewFlag and GameUtil:isSeasonPreviewOpen() == false then
		openSeasonPreviewFlag = false
		tips_str = Language:getTextByKey("new_str_1032")
	end
	local is_have_next = self:isHaveNextSeason()
	if openSeasonPreviewFlag and is_have_next == false then
		openSeasonPreviewFlag = false
		tips_str = Language:getTextByKey("new_str_1032")
	end
	return openSeasonPreviewFlag, tips_str
end

function M:getEndTimeByOpenID(open_id)
	if open_id == 246 then --奇门遁甲
		if self.m_data and self.m_data["gve"] then
			return self.m_data["gve"].end_time or 0
		end
	end
	return 0
end

return M
