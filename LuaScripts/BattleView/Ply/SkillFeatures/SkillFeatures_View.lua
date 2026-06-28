--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-14 15:32:45
]]

---@class SkillFeatures_View : ViewBase 技能的特殊功能处理
---@field player Player_View
---@field skill SkillDataConfig
---@field model SkillFeatures_Model
local M = class("SkillFeatures_View",Battle.ViewBase)

--初始化
function M:init(player, skill, model)
    self.player = player
    self.skill = skill
    self.model = model;
    --技能开始
    self:addEventListener_Local(Battle.EventType.MV_SkillFeaturesModelSkillStart,{self,self.MV_SkillFeaturesModelSkillStart});
    --技能结束
    self:addEventListener_Local(Battle.EventType.MV_SkillFeaturesModelSkillEnd,{self,self.MV_SkillFeaturesModelSkillEnd});
    --技能出生
    self:addEventListener_Local(Battle.EventType.MV_SkillFeaturesModelSpawn,{self,self.MV_SkillFeaturesModelSpawn});
    --技能销毁
    self:addEventListener_Local(Battle.EventType.MV_SkillFeaturesModelDestroy,{self,self.MV_SkillFeaturesModelDestroy});
    --技能出生完成
    self:addEventListener_Local(Battle.EventType.MV_SkillFeaturesModelSpawnFinish,{self,self.MV_SkillFeaturesModelSpawnFinish})
    --技能更新
    self:addEventListener_Local(Battle.EventType.MV_SkillFeaturesModelUpdate,{self,self.MV_SkillFeaturesModelUpdate})
end

--技能开始
function M:MV_SkillFeaturesModelSkillStart( eventName, data) 
    self:skillStart(data);
end
--技能结束
function M:MV_SkillFeaturesModelSkillEnd( eventName, data)
    self:skillEnd(data);
end
--技能出生时
function M:MV_SkillFeaturesModelSpawn( eventName, data)
    self:spawn();
end
--技能出生时
function M:MV_SkillFeaturesModelDestroy( eventName, data)
    self:destroy();
end
--技能更新时
function M:MV_SkillFeaturesModelUpdate( eventName, data)
    self:update(data.dt);
end

function M:MV_SkillFeaturesModelSpawnFinish( eventName, data)
    self:spawnFinish();
end

--出生时
function M:spawn()

end

--出生时
function M:spawnFinish()

end

function M:update(dt) 
    
end

--技能结束时
function M:skillEnd(data)

end

--技能开始时
function M:skillStart(data)
    
end

--玩家模型加载完成
function M:loadFinish(data)
end

--获取玩家视图
function M:getPlayerView( model )
    if self.player ~= nil then
        return self.player.plyMgr:GetPlayerViewByModel(model)
    end
    return nil;
end

--销毁
function M:destroy()
    M.super.destroy(self)
    self.model = nil;
end

return M