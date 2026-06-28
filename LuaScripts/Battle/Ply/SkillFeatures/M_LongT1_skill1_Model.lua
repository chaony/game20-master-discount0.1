--举盾进入防御姿态8s，期间自己受到的伤害减少30%，，举盾结束后反击，对敌人造成举盾期间所受伤害的【100%】的外功伤害
---@class M_LongT1_skill1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("M_LongT1_skill1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.duration = self:getParam(1)
    self.atk = self:getParam(2)
    self.timer = self.duration
    self.start = false
    self.damage = 0;
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:update(dt,unsdt)
    M.super.update(self, dt, unsdt)
    if self.start == true and self.timer > 0  then
        self.timer = self.timer - dt
        if self.timer <= 0 then
            self.timer = 0
            self.player.animator:changeState("skill1_end")
            self.start = false
        end
    end
end

--攻击者攻击结束处理
function M:killerAfterAttack(data)
    local dmg = data["damage"]
    local killer = data["killer"]
    if killer ~= nil and killer:equal(self.player) and self.damage > GlobalTools.base0 then
        data["damage"] = self.damage
        self.damage = 0
    end
end

--当前技能释放
function M:skillStart()
    M.super.skillStart(self)
    self.start = true
    self.timer = self.duration
    self.damage = 0
end

--当前技能释放
function M:skillEnd()
    M.super.skillEnd(self)
    
end

function M:injureHandler(eventName, data)
    local ply = data["killer"]
    local victim = data["victim"]
    local wantdata = data.wantdata
    if self.start == true and victim ~= nil and victim:equal(self.player) then
        self.damage = self.damage + wantdata.damage
    end
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    self.start = false
end

return M