---@class WorldScene4_Model : WorldSceneBase_Model @
---@field super WorldSceneBase_Model @WorldSceneBase_Model
local M = class("WorldScene4_Model",Battle.WorldSceneBase_Model)

function M:getCurSceneName()
    self:createSceneConfig(132)
    return self.scene_info.resource;
end

return M;