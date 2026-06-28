---@class ArenaAdvanceModel:OODataBase
local M = class("ArenaAdvanceModel", LikeOO.OODataBase)

function M:onCreate()
	-- self.m_transfer = "up_to_down"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()

	self.match_type=self.m_params.match_type
	self.callback=self.m_params.callback
	--1：成功晋级 0:晋级失败
	self.promote_flag=self.m_params.promote_flag

	local next_match_type=self.m_params.match_type+1
	local next_rise_arena_base_cfg =ConfigManager:getCfgByName("rise_arena_base")[next_match_type]
	self.ban_num=next_rise_arena_base_cfg.hero_ban_num
	self.team_num=next_rise_arena_base_cfg.team_num
	self.next_match_name=Language:getTextByKey(next_rise_arena_base_cfg.name)

	local cur_rise_arena_base_cfg =ConfigManager:getCfgByName("rise_arena_base")[self.m_params.match_type]

	self.promote_effects=cur_rise_arena_base_cfg.promote_effects
end

return M
