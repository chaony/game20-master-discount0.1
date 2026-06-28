local M = class("MythArenaBattleDetailPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	local battle_id = self.m_params.battle_id
	self:getData("battle_replay", {battle_id = battle_id})
end

function M:onEnter()
	self.m_log_data = self.m_params.log_data
	self.m_top_arena = self.m_params.top_arena or false
end

function M:initData(data)
    table.merge(self.m_data, data)
end

function M:getShowData()
	local show_data = {}
	local battle = self.m_data.battle or {}
	local output = battle.output or {}
	local rounds = output.rounds or {}
	for k,v in ipairs(rounds) do
		local attacker_team = v.attacker_team or  {}
		local team = attacker_team.team or {}
		local heros = attacker_team.heros or {}
		local left_team_data = GameUtil:getFormatTeamData(team, heros)
		
		local defender_team = v.defender_team or {}
		local team = defender_team.team or {}
		local heros = defender_team.heros or {}
		local right_team_data = GameUtil:getFormatTeamData(team, heros)
		table.insert(show_data, {left_team_data = left_team_data, right_team_data = right_team_data, round_data = v})
	end
	return show_data
end

function M:getUserInfoBySort(sort)
	local battle = self.m_data.battle or {}
	local common = battle.common or {}
	if sort == 1 then -- 左边
		return common.attacker_user or {}
	else --  右边
		return common.defender_user or {}
	end
end

return M
