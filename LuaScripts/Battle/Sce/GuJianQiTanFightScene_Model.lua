--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-04-08 19:02:23
]]

--迷宫战斗场景
---@class GuJianQiTanFightScene_Model : FightScene_Model @
---@field super FightScene_Model @FightScene_Model
local M = class("GuJianQiTanFightScene_Model",Battle.FightScene_Model)

function M:init()
    M.super.init(self)
end

function M:setFog()
    
end


function M:loadFinish( data )
    M.super.loadFinish(self,data);
    self.gameover = true
end

function M:createPlayerAndEnemyFinish()
    M.super.createPlayerAndEnemyFinish(self)
end

function M:setCameraPos( vec_pos )
    
end


function M:setCameraPosition(isZhanDou)
    
end

return M;