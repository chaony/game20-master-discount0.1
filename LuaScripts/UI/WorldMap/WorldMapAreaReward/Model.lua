local M = class("WorldMapAreaRewardModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()

end

function M:getRegionalTaskDoneShowData()
	local map_area_cfg = ConfigManager:getCfgByName("map_area")
	local regional_task_done = UserDataManager:getRegionalTaskDoneData()
	local show_data = {}
	for k, v in pairs(map_area_cfg) do
		local data = regional_task_done[tostring(k)] or {}
		local unlock = v.unlock
		local open_flag, tips_str = GameUtil:getStageUnlock(unlock)
		table.insert(show_data, {id = k, cfg = v, data = data, open_flag = open_flag, tips_str = tips_str})
	end
	table.sort(show_data, function(data1, data2) 
		return data1.id < data2.id
	end)
	return show_data
end

return M
