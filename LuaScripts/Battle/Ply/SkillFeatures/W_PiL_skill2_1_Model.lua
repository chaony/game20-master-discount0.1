--霹雳为自身制造一件火药护甲，持续5秒，护甲存在期间，霹雳受到的伤害减少50%，
--且每次受到攻击时，会在自身周围引发爆炸，每次造成130%攻击力的伤害，最多爆炸6次。
---@class W_PiL_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_PiL_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId = self:getParam(1)
    self.maxCount = self:getParam(2)
    self.cur_count = 0
    self.dmgStart = false
    self.timer = 0;
    self.cd = 0;
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end


function M:spawn()
    M.super.spawn(self)
    if self.player ~= nil and self.player.trait ~= nil then
        self.cd = self.player.trait.maxTime
    end
end

--技能释放
function M:skillStart(data)
    self.cur_count = 0
end


function M:injureHandler(eventName, data)
    local ply = data["killer"]
    local victim = data["victim"]
    local attackData = data["attackData"]
    local skillConfig = attackData["skillConfig"]
    if victim ~= nil and victim:equal(self.player) and attackData.type ~= 3 then
        local W_PiL_skill2 = self.player.bufMgr:findBufByTag("W_PiL_skill2")
        if table.nums(W_PiL_skill2) > 0  then
            if self.cd > 0 then
                self.timer = self.cd
            end
            if self:controlCondion() then
                self.cur_count = self.cur_count + 1
                self.player.bufMgr:addBufById(self.buffId, self.player)
            end
        end
    end
end

function M:update(dt,unsdt) 
    if self.timer > GlobalTools.base0 then 
        self.timer = self.timer - dt 
        if self.timer <= GlobalTools.base0 then
            self.dmgStart = true 
        end 
    end
end

function M:controlCondion( ... )
    if self.cd > 0 then
        return self.dmgStart
    end
    return self.cur_count <= self.maxCount
end


function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    self.cur_count = 0
    M.super.destroy(self)
end

return M