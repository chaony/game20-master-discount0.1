--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-04-08 15:37:07
]]

--天机楼战斗场景
---@class TianjiLouFightScene_Model : FightScene_Model @
---@field super FightScene_Model @FightScene_Model
local M = class("TianjiLouFightScene_Model",Battle.FightScene_Model)

function M:init()
    M.super.init(self)
end

function M:enter(data)
    M.super.enter(self,data)
end

function M:loadFinish( data )
    M.super.loadFinish(self,data);
    self.gameover = true
end

return M;