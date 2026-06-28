--巨鲸 attack·1
---@class W_JuJ_attack1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JuJ_attack1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.attackCount = 0
    self.equip_hero_id = 0
    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
end

function M:spawn()
    M.super.spawn(self)
end

--技能释放
function M:SkillEnterHandler( eventName, data )
    local ply = data["player"]
    local config = data["skillConfig"]

    if config ~= nil and self.player:equal(ply) and config ~= self.skill then
        if config.anim_name == "skill1" then
            self.state = nil
            self.attackCount = 0
        end
        
        if self.state ~= nil then
            self.player:set_curSkillConfig(self.skill)
            --self.player.aiEngine:changeState("attack")
            self.skill:skillStart()
        else
            self.state = config
            self.attackCount = config.featureParam[1] or 1
            if config.feature ~= nil then
                self.equip_hero_id = config.feature.equip_hero_id or 0
            end
        end
    end
end

--技能释放
function M:skillStart()
    if self.state ~= nil and self.attackCount > 0 then
        self.player.curSkillConfig.extra_anim_name = self.player.curSkillConfig.anim_name .. "_" .. self.state.anim_name
        self.attackCount = self.attackCount - 1
        self.player.skillImprove:addItem("equip_hero",self.equip_hero_id)
        --if self.attackCount <= 0 then
        --    self.state = nil
        --end
    end
end

--技能释放
function M:skillEnd()
    if self.attackCount <= 0 then
        if self.state ~= nil then
            self.player.skillImprove:removeItem("equip_hero",self.equip_hero_id)
        end
        self.state = nil
    end
end


function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
end


return M