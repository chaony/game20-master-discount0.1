---@class SeasonPreviewModel
local M = class("SeasonPreviewModel", LikeOO.OODataBase)
--对应配置里的解锁功能id
local __season_btn_id = {
	jianghu_btn = 1,
	high_arena_btn = 2,
	mystic_btn = 3,
	union_war_btn = 4,
	top_race_arena_btn = 5,
	--wxlm_btn = 8,--6,
	wxlm_btn = 9,--6,
	mj_btn = 25,--7,
	jianghu2_btn = 6,--8,
	magic_weapon_btn = 11,--9,
	qmdj_btn = 10,
	tmhx_btn = 7,
	xsty_btn = 12,
	xtmm_btn = 13,
	tmxx_btn = 14,
	sjjm_btn = 15,
	hslj_btn = 16,
	wdsl_btn = 17,
	qcjy_btn = 18,
	xxxz_btn = 19,
	s6_tmxx_btn = 20,
	s6_xxsh_btn = 21,
	s7_cwmz_btn = 22,
	s7_tdzz_btn = 23,
	s13_dfbz_btn = 24,
	s13_jstx_btn = 25,
}
function M:onCreate()
	M.super.onCreate(self)
	self:getData("")
end

function M:getSeasonBtnId()
	return __season_btn_id
end

function M:onEnter()
	local max_season = 13
	self.m_cur_season = UserDataManager:getNextSeason() or UserDataManager:getCurSeason() + 1
	if self.m_cur_season > max_season then
		self.m_cur_season = max_season
	end
	self.m_season_notice_cfg = ConfigManager:getCfgByName("season_notice")
	self.m_season_upgrade_cfg = ConfigManager:getCfgByName("season_upgrade")
	self.m_is_show_func_node = false
	self.m_is_show_reward_node = false
	self.m_can_get_reward = self:getRewardStatus()
	self.m_cur_season_notice_cfg = self:getCurSeasonCfg()
	self.m_end_time = UserDataManager:getCurSeasonEndTime() + 1
	self.m_show_gift_btn_flag = ConfigManager:getCommonValueById(722, 1) == 0
	--本地保存赛季预告自动弹出记录
	UserDataManager.local_data:setUserDataByKey("first_season_preview_" .. self.m_cur_season, 1)
end

function M:getRewardStatus()
	local red_flag = false
	local season_data = UserDataManager.m_season_data or {}
	local season_recv = 1 -- 0 是可领取 1不可领取
	if season_data and next(season_data) and season_data.season_recv then
		season_recv = season_data.season_recv
	end
	red_flag = season_recv == 0 and GameUtil:isSeasonPreviewOpen()
	return red_flag
end

function M:getCurSeasonCfg()
	local cur_cfg = {}
	if self.m_season_notice_cfg and self.m_season_notice_cfg[self.m_cur_season] then
		cur_cfg = self.m_season_notice_cfg[self.m_cur_season]
	end
	return cur_cfg
end

function M:getFuncCfgById(id)
	local func_cfg = {}
	if self.m_season_upgrade_cfg and self.m_season_upgrade_cfg[id] then
		func_cfg = self.m_season_upgrade_cfg[id]
	end
	return func_cfg
end

function M:getShowHeroId()
	local hero_id_tab = {}
	if self.m_cur_season_notice_cfg and next(self.m_cur_season_notice_cfg) then
		hero_id_tab = self.m_cur_season_notice_cfg.hero
	end
	return hero_id_tab
end

function M:setFuncNodeStatus(status)
	self.m_is_show_func_node = status
end

function M:setRewardNodeStatus(status)
	self.m_is_show_reward_node = status
end

function M:getSeasonReward()
	local reard_tab = {}
	if self.m_cur_season_notice_cfg and next(self.m_cur_season_notice_cfg) then
		reard_tab = self.m_cur_season_notice_cfg.rewards
	end
	return reard_tab
end

function M:getSeasonDailyReward()
	local reard_tab = {}
	if self.m_cur_season_notice_cfg and next(self.m_cur_season_notice_cfg) then
		reard_tab = self.m_cur_season_notice_cfg.day_rewards
	end
	return reard_tab
end

function M:getShowData()
end

return M
