local M = class("GuJianQiTanMazeMainModel", LikeOO.OODataBase)

--- 网络数据回调
function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	--Logger.logError(self.m_params.data," 进入到迷宫选择界面 ~~~ ")
	--Logger.logError(self.m_params.data.entered_group," entered_group ~~~ ")
	--Logger.logError(self.m_params.data.max_group," max_group ~~~ ")
	--Logger.logError(self.m_params.data.double_floors," double_floor ~~~ ")
	--Logger.logError(self.m_params.data.max_floor," max_floor ~~~ ")
	self.verson = self.m_params.data.mver;
	self.max_floor = self.m_params.data.max_floor;
	self.max_group = self.m_params.data.max_group;
	self.entered_group = self.m_params.data.entered_group;
end

function M:hasGroupId( groupId )
	for i, v in ipairs(self.entered_group) do
		if v == groupId then
			return true;
		end
	end
	return false;
end

--当前迷宫是否通关过
function M:isFirstComplete(group_id)
	local cur_group = group_id
	if self.m_params.data.finished_groups and next(self.m_params.data.finished_groups) then
		for i, v in pairs(self.m_params.data.finished_groups) do
			if tonumber(v) == tonumber(cur_group) then
				return true
			end
		end
	end
	return false
end

function M:getFinalReward(floor_id)
	local group = self.maze_map_group[self.max_group]
	local maze_floor = ConfigManager:getCfgByName("maze_map_floor")
	local floor_ids = group.floor_id;
	local floor_data = maze_floor[self.max_floor];
	local max_floor_id = floor_ids[#floor_ids];
	local max_floor_data = maze_floor[floor_id];
	local finish_reward = max_floor_data.finish_reward and max_floor_data.finish_reward or {}
	return finish_reward, max_floor_id
end

--最大的组是否解锁
function M:unlockMaxGroup()
	self.maze_map_group = ConfigManager:getCfgByName("maze_map_group");
	local group_data = self.maze_map_group[self.max_group];
	local floors = group_data.floor_id;
	if self.max_floor > group_data.floor_id[1] then
		return true;
	end
	return false;
end

function M:getShowData()
	--本地数据
	self.maze_map_group = ConfigManager:getCfgByName("maze_map_group");
	local result = {}
	for k,v in ipairs(self.maze_map_group) do
		v.is_unlock_level_name = nil;
		if k > 0 and k <= self.max_group then
			if self:hasGroupId(k) == false then
				v.double = 1;
			else
				v.double = nil;
			end
			v.is_complete = self:isFirstComplete(k)
			table.insert(result, v);
		end
	end
	--if self.max_group < #self.maze_map_group then
	--	table.insert(result, {stage = self.maze_map_group[self.max_group + 1].stage});
	--else
	--	table.insert(result, {stage = self.maze_map_group[self.max_group].stage});
	--end
	if self.max_group < #self.maze_map_group then
		local data = self.maze_map_group[self.max_group + 1];
		data.is_unlock_level_name = self.maze_map_group[self.max_group].name;
		data.is_complete = false
		table.insert( result, data );
	end
	return result;
end


function M:getRefreshRemainingTime()
	local end_time = self.m_params.data.end_time or 0
	return end_time - UserDataManager:getServerTime()
end

return M
