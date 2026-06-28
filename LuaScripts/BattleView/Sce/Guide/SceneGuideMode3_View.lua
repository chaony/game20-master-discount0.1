--模式1
---@class SceneGuideMode1_View : GuideModeBase_View @
---@field super GuideModeBase_View @GuideModeBase_View
local M = class("SceneGuideMode1_View",Battle.GuideModeBase_View)

--模式1
function M:init( obj, scene, mode )
    M.super.init(self, obj, scene, mode )
end

return M