--嘲讽指定目标
---@class BufWorkTaunt : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkTaunt", BufWork_Model)


function M:initFinish()
	self.playerBuf.player:add_tauntList(self.playerBuf.source)
	self.playerBuf.player:lockEnemy(nil)
end

function M:update( time )
	M.super.update(self, time)
	if self.playerBuf.source == nil or self.playerBuf.source:isLive() ~= true then
		self.playerBuf.mgr:removeBuf(self.playerBuf)
	end
end

function M:stop()
	M.super.stop(self)
	self.playerBuf.player:remove_tauntList(self.playerBuf.source, true)
end

return M