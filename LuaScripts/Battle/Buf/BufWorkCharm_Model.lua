--魅惑
---@class BufWorkCharm : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkCharm", BufWork_Model)

M.buffId = nil

M.lock_data =
{
	["count"] = "one",
	["camp"] = "enemy",
	["posIndex"] = "all",
	["priority"] = false,
	["ignoreSummon"] = false,
	["campRace"] = "not",
	["pos"] = "distanceRecently",
	["profession"] = "all",
	["area"] = "all",
	["areaWidth"] = "",
	["areaHeight"] = "",
	["areaAngle"] = "",
	["areaRadius"] = "",
	["forceSelect"] = false,
	["selectLast"] = false
}

function M:initFinish()
	self.buffId = self.playerBuf:checkParam("buffId", 0)
	local enemyList = SelectTargetTool:findPlayerByType(self.lock_data, self.playerBuf.player)
	local enemy = enemyList:get(0)
	if enemy ~= nil then
		self.playerBuf.player:lockEnemy(enemy);
		self.playerBuf.player.enemyIndex = self.playerBuf.player.enemy.index
	else
		self.playerBuf.player:lockEnemy(nil);
	end
end

function M:work()
	M.super.work(self)
	self.playerBuf.player.bufMgr:addBufById(self.buffId, self.playerBuf.source)
end

function M:stop()
	self.playerBuf.player:lockEnemy(nil);
	M.super.stop(self)
end

return M