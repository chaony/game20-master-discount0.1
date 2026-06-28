---@class PrestigeAttributeControl : OOControlBase
local M = class("PrestigeAttributeControl", LikeOO.OOControlBase)

function M:onCreate()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
