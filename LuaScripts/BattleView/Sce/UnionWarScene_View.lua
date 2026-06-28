---@class UnionWarScene_View : Scene_View @
---@field super Scene_View @Scene_View
local M = class("UnionWarScene_View",Battle.Scene_View)
M.BUILDINGS_COUNT = 19

function M:init(model)
    M.super.init(self,model)
end

function M:getCurSceneObjName()
    return "unionwarscene_data"
end

--进入场景
function M:enter( data )
    M.super.enter(self, data)    
end


function M:sceneLoadFinish()

end

function M:getCurSceneName()
    self:createSceneConfig(117)
    return self.scene_info.resource;
end

return M
