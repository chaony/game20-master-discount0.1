--技能打断
---@class BufWorkBreak : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkBreak", BufWork_Model)

function M:initFinish()
    
    local anim = self.playerBuf:checkParam("anim", "debuff")
    if anim ~= nil then
        self.playerBuf.player.aiEngine:changeState(anim)
    end
    
end

return M