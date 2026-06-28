local M = class("ShiguangModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_team_id = self.m_params.team_id or 101
	self.m_chapter_id = self.m_params.chapter_id or 1001
	self:getData("rpg_map_index",{chapter_id = self.m_chapter_id},nil,GlobalConfig.POST)
	self.m_data = {}
end

--设定服务器数据
function M:onEnter()

end

function M:getHeirloomNum()
	local heirlooms = self.m_data.heirlooms or {}
	return GameUtil:getHeirloomNum(heirlooms)
end

-- 遗物战斗力加成计算
function M:getHeirloomCombatAddRatio()
	local team = UserDataManager.hero_data:getTeamByKey("rpg_map") or {}
	local assist_heros = self.m_data.assist_heros or {} --雇佣的英雄
	local heirlooms = self.m_data.heirlooms or {}
	return GameUtil:getHeirloomCombatAddRatio(team, assist_heros, heirlooms)
end

--- 网络数据回调
function M:netData(data, tag)
	table.merge(self.m_data.blocks or {}, data.blocks or {})
	data.blocks = nil
	table.merge(self.m_data, data)
end

function M:getBlockDataById(id)
	local cells = self.m_data.blocks or {}
	local cell_data = cells[tostring(id)]
	return cell_data
end

return M
