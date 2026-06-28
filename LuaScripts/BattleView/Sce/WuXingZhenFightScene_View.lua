--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-04-08 19:02:23
]]

--五行阵战斗场景
---@class WuXingZhenFightScene_View : FightScene_View @
---@field super FightScene_View @FightScene_View
local M = class("WuXingZhenFightScene_View",Battle.FightScene_View)

function M:init(model)
    M.super.init(self,model)
end

function M:setFog()
    U3DUtil:Set_RenderSettings_Fog_Distance(450)
end

function M:getCurSceneName()
    return "wuxingzhen";
end

function M:getCurSceneObjName()
    return "wuxingzhen_data_fight";
end

function M:loadFinish( data )
    M.super.loadFinish(self,data);
    
end

function M:createPlayerAndEnemyFinish()
    M.super.createPlayerAndEnemyFinish(self)
    self.gameover = false;
end

function M:setCameraPos( vec_pos )
    
end


function M:setCameraPosition(isZhanDou)
    
end

return M;