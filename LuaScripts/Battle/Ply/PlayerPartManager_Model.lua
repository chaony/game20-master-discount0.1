---@class PlayerPartManager_Model @角色的附属物品管理器
local M = class("PlayerPartManager_Model")

M.player = nil

M.partList = nil

function M:init(ply)
	self.player = ply
	self.partList = {}
end

function M:update(dt)
	-- for k,v in pairs(self.partList) do
	-- 	v:update(dt)
	-- end
end

function M:add(data)
	local part = require("Battle.Ply.PlayerPart").new()
	part:init(self.player, data, self)
	table.insert(self.partList, part)
end

function M:remove(part)
	if table.keyof(self.partList, part) ~= nil then
		part:destroy()
		table.removebyvalue(self.partList, part)
	end
end

function M:destroy()
	for k,v in ipairs(self.partList) do
		v:destroy()
	end
	self.partList = {}
end
return M