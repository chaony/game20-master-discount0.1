---@class ArenaRTALogDetailModel:OODataBase
local M = class("ArenaRTALogDetailModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	--self:getData()
	self.m_transfer = "up_to_down"
	self.battle_time= self.m_params.log_time
	local match_id = self.m_params.match_id
	self:getData("rta_battle_log_detail", {match_id = match_id})
	--local battle_id = self.m_params.detail_data.battle_id
	--if battle_id then
	--	self:getData("battle_replay", {battle_id = battle_id})
	--end
end

function M:onEnter()
	self.detail_data=self.m_data
	self.battle_id=self.m_data.battle_id
	self:getWinerAndLoser()
end

function M:getWinerAndLoser()
	if self.detail_data.winer==self.detail_data.atker.uid then
		self.winer=self.detail_data.atker
		self.loser=self.detail_data.defer
	else
		self.winer=self.detail_data.defer
		self.loser=self.detail_data.atker
	end
end

return M
