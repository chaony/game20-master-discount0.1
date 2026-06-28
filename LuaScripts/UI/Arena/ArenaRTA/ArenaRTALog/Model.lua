---@class ArenaRTALogModel:OODataBase
local M = class("ArenaRTALogModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	--self.m_match_type = self.m_params.match_type or 0
	--self.races = self.m_params.races or {}
	--if self.m_match_type == 2 then
	--	self:getData("race_arena_season_arena_logs")
	--elseif self.m_params.is_zf then
	--	self:getData("rise_arena_battle_logs")
	--	self.team_num=self.m_params.team_num
	--else
	--	self:getData("race_arena_arena_logs")
	--end
	self:getData("rta_self_battle_logs")
end

function M:onEnter()
	--self.m_free_times = self.m_params.free_times or 0
	--self.m_master_uid = self.m_data.mentor or 0 --师傅Uid
	--self.m_revenge_times = self.m_data.revenge_times --使用过的复仇次数
	--
	--self.ban_num=self.m_params.ban_num
	--self.m_is_zf=self.m_params.is_zf
	--self.m_battle_mode=self.m_params.battle_mode
	--self.rise_id=self.m_params.rise_id
	--self.m_week_rule=self.m_params.week_rule

	local data=self.m_data
	Logger.log(data)
end

function M:getShowData()
	local logs = self.m_data.logs or {}
	return logs
end

--function M:getFreeTimes()
--	if self.m_is_zf then
--		return self.m_free_times
--	else
--		local arena_free_times = ConfigManager:getVipValueByKey("arena_free_times", 0)
--		return arena_free_times - self.m_free_times
--	end
--
--end

--判断己方胜负
function M:isVictory(uid)
	local own_uid=UserDataManager.user_data:getUid()
	return own_uid==uid
end



function M:initData(data)
    table.merge(self.m_data, data)
end

return M
