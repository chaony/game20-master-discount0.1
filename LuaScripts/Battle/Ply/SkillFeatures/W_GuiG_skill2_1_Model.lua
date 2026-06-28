--鬼谷 skill3被动
--开局将我方后排血量最多的队友和敌人后排血量最少的敌人互换位置
---@class W_GuiG_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_GuiG_skill2_1_Model", SkillFeatures_Model)


local table_data = require("Battle.Ply.SkillFeaturesData.W_GuiG_skill2_1_Data");
local friendData = table_data.friendData
local enemyData = table_data.enemyData

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.updateData = {}
    self.no_control_flag = false
end

function M:spawnFinish()
    self.enemyPos_target = self:get_playerPos_target(enemyData,self.player)
    if self.enemyPos_target ~= nil and self.enemyPos_target.plyData.weight < GlobalTools.base2000 then
        --以敌人取到的我方后排血量最多的人
        self.friendPos_target = self:get_playerPos_target(friendData,self.player)
        if self.friendPos_target ~= nil and self.friendPos_target.plyData.weight < GlobalTools.base2000 then
            self.temp_time = GlobalTools.base0_5
            self.friendPos_target.aiEngine.states["debuff"].extra_anim_name = "battle_idle"
            self.enemyPos_target.aiEngine.states["debuff"].extra_anim_name = "battle_idle"
            self.friendPos_target.inDebuff = true
            self.enemyPos_target.inDebuff = true
            self.no_control_flag = true
            self.friendPos_target.aiEngine:changeState("debuff")
            self.enemyPos_target.aiEngine:changeState("debuff")
            
            self:line()
            self:PlayerEffectOnPoint(self.enemyPos_target.position, "W_GuiG_Skill2_Hit_001")
            self:PlayerEffectOnPoint(self.friendPos_target.position, "W_GuiG_Skill2_Hit_002")
            
            --TimeTools:delayTime(GlobalTools.base0_5,
            --function()
                if self.friendPos_target ~= nil then
                    self:PlayerEffectOnPoint(self.enemyPos_target.position, "W_GuiG_Skill2_ShanXian01")
                    self:PlayerEffectOnPoint(self.friendPos_target.position, "W_GuiG_Skill2_ShanXian01")
                    local enemyPos = self.enemyPos_target.position:Clone()
                    self.enemyPos_target:setPos(self.friendPos_target.position, true)
                    self:addcamp_Buf(self.enemyPos_target)

                    self.friendPos_target:setPos(enemyPos, true)
                    self:addcamp_Buf(self.friendPos_target)

                    if self.player.skyStar then
                        self.player.skyStar:triggerStart(self.enemyPos_target)
                    end
                end
            --end)
        end
    end
end

function M:update(dt, unsdt)
    M.super.update(self,dt, unsdt)
    if self.no_control_flag then
        if self.temp_time > 0 then
            self.temp_time = self.temp_time - dt
        else
            self.no_control_flag = false
            if self.friendPos_target ~= nil then
                self.friendPos_target.inDebuff = false
                self.enemyPos_target.inDebuff = false
            end
            self:destroyLineEffect()
        end
    end
end

function M:addcamp_Buf(player)
    
end

function M:get_playerPos_target(data,player)
    local count = data["count"]
    local target = nil
    local enemys = SelectTargetTool:findPlayerByType(count,player)
    if enemys ~= nil and enemys:get(0) ~= nil then
        target = enemys:get(0)
        return target
    end
    return nil
end

function M:destroyLineEffect()
    self:dispatchEvent_Local(Battle.SkillEventType.MV_W_GuiG_skill2_1_DestroyLineEffect);
end

function M:PlayerEffectOnPoint(pos, effectName)
    local data = {pos = pos, effectName = effectName};
    self:dispatchEvent_Local(Battle.SkillEventType.MV_W_GuiG_skill2_1_PlayerEffect, data);
end


function M:line()
    self:dispatchEvent_Local(Battle.SkillEventType.MV_W_GuiG_skill2_1_Line);
end

return M