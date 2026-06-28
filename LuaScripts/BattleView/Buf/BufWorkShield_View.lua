--额外护盾
---@class BufWorkShield_View : BufWork_View @
---@field super BufWork_View @BufWork_View
local M = class("BufWorkShield_View", BufWork_View)

M.value = 0

M.buff = nil

function M:init(buf, model)
    M.super.init(self,buf, model)
    self.value = GlobalTools:ToFloat(self.model:get_value());
    --显示UI护盾
    self.playerBuf.player:createHpNumberLabel("+", Mathf.Floor(self.value), 3)
end

function M:update(time)
    M.super.update(self, time)
end

function M:stop()
    M.super.stop(self)
end

return M