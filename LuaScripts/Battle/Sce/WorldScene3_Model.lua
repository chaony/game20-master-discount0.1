---@class WorldScene3_Model : WorldSceneBase_Model @
---@field super WorldSceneBase_Model @WorldSceneBase_Model
local M = class("WorldScene3_Model",Battle.WorldSceneBase_Model)

function M:getCurSceneName()
    self:createSceneConfig(124)
    return self.scene_info.resource;
end

return M;