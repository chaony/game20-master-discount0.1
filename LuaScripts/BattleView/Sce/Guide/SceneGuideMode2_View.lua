--模式2
---@class SceneGuideMode2_View : GuideModeBase_View @
---@field super GuideModeBase_View @GuideModeBase_View
local M = class("SceneGuideMode2_View",Battle.GuideModeBase_View)

function M:init( obj, scene, mode )
    M.super.init(self, obj, scene, mode )
end

return M