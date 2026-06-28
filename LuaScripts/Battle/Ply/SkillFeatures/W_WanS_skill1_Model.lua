--万兽庄 skill1 攻击一位敌人，对其造成伤害并将为敌人附加一层“撕裂”状态 最多叠加3层
---@class W_WanS_skill1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WanS_skill1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffid = self:getParam(1)
end


function M:spawn( ... )
    self.injure_start = false
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:injureHandler(eventName, data)
    local ply = data["killer"]
    local victim = data["victim"]
    local skillConfig = data["attackData"]["skillConfig"]
    local wantdata = data["wantdata"]
    local dmg = wantdata["damage"]
    if victim ~= nil then
        if ply ~= nil and ply:equal(self.player)  then
            if skillConfig ~= nil and skillConfig.anim_name == "skill1" then
                if data["attackData"]["injureType"] ~= "buff" and data["attackData"]["type"] ~= 3 then
                    self:addBuf(victim)
                end
            end
        end
    end
end

function M:addBuf(victim)
    victim.bufMgr:addBufById(self.buffid,self.player)
end

function M:destroy()
    M.super.destroy(self)

    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end


return M