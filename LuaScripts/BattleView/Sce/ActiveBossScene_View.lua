--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:32:47
]]

--Boss场景
---@class ActiveBossScene_View : SceneArrayBase_View @
---@field super SceneArrayBase_View @SceneArrayBase_View
local M = class("ActiveBossScene_View",Battle.SceneArrayBase_View)

--初始化场景
function M:init( model )
    M.super.init(self, model)
    self.isNeedResetCamera = false;
    --boss场景的状态 1 表示显示状态 2 表示布阵战斗状态
    self.bossState = 1;
end

--初始化场景物体完成  子类重写
function M:initSceneObjectsFinish()
    M.super.initSceneObjectsFinish(self )
    self:setCameraInfo(false)
end

return M