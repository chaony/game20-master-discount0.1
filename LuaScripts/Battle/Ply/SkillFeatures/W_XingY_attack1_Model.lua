---@class W_XingY_attack1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_XingY_attack1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
end

function M:spawn()
    M.super.spawn(self)
end

--技能释放
function M:SkillEnterHandler( eventName, data )
    local ply = data["player"]
    local config = data["skillConfig"]

    if config ~= nil and self.player:equal(ply) then
        if config.anim_name == "skill3" then
            self:clearEffect()
            self.state = nil
            self.attackCount = 0
            self:setState(config)
        else
            if self.state ~= nil then
                self.player:set_curSkillConfig(self.skill)
                self.player.curSkillConfig.extra_anim_name = self.state.anim_name .. "_" .. self.player.curSkillConfig.anim_name
                self.attackCount = self.attackCount - 1
            end
        end
    end
end

function M:setState(skillConfig)
    self.state = skillConfig
    self.attackCount = skillConfig.featureParam[1] or 1
    if skillConfig.feature ~= nil then
        self.equip_hero_id = skillConfig.feature.equip_hero_id or 0
    end
end

--技能释放
function M:skillEnd()
    if self.state ~= nil and self.attackCount <= 0 then
        self:dispatchEvent_Local(Battle.SkillEventType.MV_W_XingY_attack1_Model_ClearStateEffect,{name = self.state.anim_name})
        self.state = nil
    end
end

function M:clearEffect()
    self:dispatchEvent_Local(Battle.SkillEventType.MV_W_XingY_attack1_Model_ClearEffect)
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
end

return M