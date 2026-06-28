--无法被攻击
---@class BufWorkDisappear : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkDisappear", BufWork_Model)


function M:initFinish()
	self.type = self.playerBuf:checkParam("type", 1)
end

function M:stop()
	M.super.stop(self)
	local player = SceneManager.curScene.plyMgr:getPlayers(-self.playerBuf.player:get_camp())
	for i=player.Count,1,-1 do
		local player = player:get(i-1)
		player:removeKillerList()
	end
end

return M