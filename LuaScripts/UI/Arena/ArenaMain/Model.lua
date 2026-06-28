local M = class("ArenaMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("arena_index")
end

function M:onEnter()
	
end

function M:getArenaDataByKey(key)
	return self.m_data[key]
end

return M
