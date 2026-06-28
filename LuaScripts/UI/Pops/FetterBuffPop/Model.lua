local M = class("FetterBuffPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "up_to_down"
	self:getData()
end

function M:onEnter()
	self.m_buff_lv = self.m_params.buff_lv --buff等级
	self.m_demon_num = self.m_params.demon_num --恶魔等级
end

function M:getBuffNum(id, isPercent)
	if isPercent == nil then
		isPercent = true
	end
	local common = Battle.BattleGlobalConfig.ARRAY_ADDITION[id]
	local new_tab = {}
	if id < 10 then
		local data = ConfigManager:getBattleCommonValueById(common, {})
		for k, v in pairs(data) do
			if isPercent == true then
				new_tab[k] = v * 100
			else
				new_tab[k] = v
			end
		end
	else
		local data = ConfigManager:getBattleCommonValueById(common, 0)
		if isPercent == true then
			table.insert(new_tab, data * 100)
		else
			table.insert(new_tab, data)
		end
	end
	return new_tab
end

function M:checkIsInList(index)
	return self.m_buff_lv == index
end

function M:checkIsDemonList(index)
	return self.m_demon_num >= index
end

return M
