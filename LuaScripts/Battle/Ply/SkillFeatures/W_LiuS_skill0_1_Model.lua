--六扇攻击被“悬赏”标记的敌人时，造成的伤害提升15%
---@class W_LiuS_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LiuS_skill0_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.physicaldamage = self:getParam(1)
    self.lastDamage = self:getParam(2)
end


function M:spawn()
    M.super.spawn(self)
end

function M:skillDispatch(data)
    if data.eventName == "attack1_fire" then
        self.fire = true
        local frame = self.player.evtMgr:getCommonEvent("Shoot", 1 )
        if frame ~= nil then
            frame.data.frontdamagePercent = self.frontDamage
            frame.data.lastdamagePercent = self.lastDamage
            frame.isWork = true
            self.player:set_forceSkillConfig(self.skill)
            frame:work()
            self.player:set_forceSkillConfig(nil)
        end
        self.fire = false
    end
end

--查找敌人
function M:findPlayer(data)
    if self.fire == true then
        for i = data.Count, 1, -1 do
            local enemy = data:get(i - 1)
            local buffs = enemy.bufMgr:findBufByTag("W_LiuS_skill1")
            if #buffs <= 0 then
                data:removeAt(i - 1)
            end
        end        
    end
    return data
end


--攻击者的攻击开始处理
function M:killerDataChangeTemp(victim, skill)
    if victim ~= nil then
        local buffs = victim.bufMgr:findBufByTag("W_LiuS_skill1")
        if #buffs > 0 then
            self.player.data.physicaldamage:addToMulListTemp( self.physicaldamage )
            self.player.data.magicdamage:addToMulListTemp( self.physicaldamage )
        end
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M