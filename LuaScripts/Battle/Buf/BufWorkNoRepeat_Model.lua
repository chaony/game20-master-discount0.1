--不能重复的buff
---@class BufWorkNoRepeat : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkNoRepeat", BufWork_Model)


function M:initFinish()
	self.Count = 0
end

function M:reset(  )
	M.super.reset(self)
	self.Count = self.Count + 1
end

return M