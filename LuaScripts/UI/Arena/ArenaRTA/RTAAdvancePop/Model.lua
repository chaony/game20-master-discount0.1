---@class RTAAdvanceModel:OODataBase
local M = class("RTAAdvanceModel", LikeOO.OODataBase)

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
	--local next_rise_arena_base_cfg =ConfigManager:getCfgByName("rise_arena_base")[next_match_type]
	--self.ban_num=next_rise_arena_base_cfg.hero_ban_num
	--self.team_num=next_rise_arena_base_cfg.team_num
	--self.next_match_name=Language:getTextByKey(next_rise_arena_base_cfg.name)
	local rta_tier_cfg=ConfigManager:getCfgByName("rta_tier")
	local cur_base_cfg =rta_tier_cfg[self.match_type]
	self.promote_effects= cur_base_cfg.promote_effects

	self:initLimitCfg()
end

function M:initLimitCfg()
	if self.promote_effects then
		for i, effect in pairs(self.promote_effects) do
			local _type=effect[2]
			if _type==2 then
				local id=effect[3]
				local rule_cfg=ConfigManager:getCfgByName("rta_rule")
				self.m_limit_cfg=rule_cfg[id]
			end
		end
	end
end

return M
