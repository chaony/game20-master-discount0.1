--会替古墓分担50%的伤害
---@class W_GuM1_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_GuM1_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hurtShareBuff = self:getParam(1)

    --self.cureHp = self:getParam(1)
    --EventDispatcher:registerEvent("injure", {self, self.injureHandler})

end

function M:spawn()
    M.super.spawn(self)
    self.player.bufMgr:addBufById(self.hurtShareBuff, self.player.master)
end

function M:injureHandler(eventName, data)
    --local ply = data["killer"]
    --local victim = data["victim"]
    --local skillConfig = data["attackData"]["skillConfig"]
    --local wantdata = data["wantdata"]
    --local dmg = wantdata["damage"]
    --if ply ~= nil and ply:equal(self.player) == true then
    --    ply.master:cure("fix", ply, GlobalTools:Mul(dmg, self.cureHp), self.skill)
    --end
end

function M:destroy()
    --EventDispatcher:unRegisterEvent("injure", {self, self.injureHandler})
    M.super.destroy(self)
end

   

return M