local M = class("TowerStageModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_floor_players = {}
	-- self:initData(self.m_data)
end

function M:initData(data)
	self.m_data = data or self.m_data
	self:initStageData()
end

function M:initStageData()
	local cur_floor_id = self.m_data.cur_floor_id or 0
	local tower_stage = ConfigManager:getCfgByName("tower_stage")
	--local stage_battle = ConfigManager:getCfgByName("stage_battle")
	local show_data = {}
	for i=1,cur_floor_id + 3 do
		local tower_stage_item = tower_stage[i]
		if tower_stage_item then
			local battle_id = tower_stage_item.battle_id or -1
			local stage_battle_item = ConfigManager:getCfgStageBattle(battle_id)--stage_battle[battle_id]
			table.insert(show_data,{floor_id = i, cfg = tower_stage_item, stage_battle_cfg = stage_battle_item, cur_floor_id = cur_floor_id + 1})
		end
	end
	self.m_stage_data = show_data
	table.sort(self.m_stage_data, function(data1, data2)
		return data1.floor_id < data2.floor_id
	end)
end

function M:getStageData()
	return self.m_stage_data
end

function M:getStageDataCount()
	return #self.m_stage_data
end

function M:getStageDataByIndex(index)
    return self.m_stage_data[index]
end

function M:getCurFloorId()
	local cur_floor_id = self.m_data.cur_floor_id or 0
	return cur_floor_id
end

function M:initFloorPayersData(data)
	self.m_floor_players = data or {}
end

function M:getFloorPayersByFloorId(id)
	return self.m_floor_players[tostring(id)] or {}
end

return M
