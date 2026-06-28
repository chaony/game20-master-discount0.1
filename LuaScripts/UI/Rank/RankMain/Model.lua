local M = class("RankMainModel", LikeOO.OODataBase)

local __score_rank_types = 
{
	{id = 1001, name = "new_str_0073", rece_type = 1 }, --"龙庭武神分数", 青龙
	{id = 1004, name = "new_str_0070", rece_type = 4 }, --"异族武神分数", 白虎 
	{id = 1002, name = "new_str_0071", rece_type = 2 }, --"草莽武神分数", 朱雀
	{id = 1003, name = "new_str_0072", rece_type = 3 }, --"世族武神分数", 玄武
	{id = 2, name = "new_str_0664", short_name = "new_str_0500"}, --"爬塔进度",
	--{id = 4, name = "new_str_0132", short_name = "new_str_0500"}, --"五行阵",
	{id = 1, name = "new_str_0665", short_name = "new_str_0501"}, --"完成章节",
}

function M:onCreate()
	M.super.onCreate(self)
	self:getData("rank_index")
end

function M:onEnter()

end

function M:getRankDataById(id)
	local ranks = self.m_data.ranks
	return ranks[tostring(id)] or {}
end

function M:getRankCfgByIndex(index)
	if __score_rank_types[index] then
		return __score_rank_types[index]
	end
end

function M:getAllRankTypes()
	return __score_rank_types
end

function M:getRankRedPointById(id)
	local red_dot = self.m_data.red_dot or {}
	local value = red_dot[tostring(id)] or 0
	return value == 1
end

function M:updateRedPoint(data)
	local red_dot = self.m_data.red_dot or {}
	red_dot[tostring(data.id)] = data.red_point
end

return M
