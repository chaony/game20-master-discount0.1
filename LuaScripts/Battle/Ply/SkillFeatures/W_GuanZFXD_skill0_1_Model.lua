--飞雪刀进入看破状态2秒，期间受到的伤害会减少90%，且免疫控制，之后挥剑前刺，造成200%攻击力的伤害，
--若看破期间受到了来自敌方的控制效果，则会在技能结束时反击施加控制的敌方角色，对其造成200%攻击力的伤害并使其眩晕3秒
---@class W_GuanZFXD_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_GuanZFXD_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hurtBuff = self:getParam(1) -- 看破期间受到敌人控制效果技能结束后敌人的BUFF
    self.pozhanBuff = self:getParam(2) -- 破绽buff
    self.immunityTargetList = {} -- 期间控制飞雪刀的人的列表
end

function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("BufWorkImmunityTakeEffect", {self,self.BufWorkImmunityTakeEffectHandler})
end


function M:skillEnd(data)
    ---@param target PlayerModel
    for i, target in pairs(self.immunityTargetList) do
        if target then
            target.bufMgr:addBufById(self.hurtBuff, self.player)
        end
    end
    self.immunityTargetList = {}
    M.super.skillEnd(self, data)
end

-- 控制自己的人
function M:BufWorkImmunityTakeEffectHandler(eventName, data)
    ---@type PlayerModel
    local killer = data.data
    ---@type PlayerBuf_Model
    local playerBuf = data.playerBuf
    local buffs = self.player.bufMgr:findBufByTag("W_GuanZFXD_skill0") -- 看破标记
    if #buffs>0 then
        if self.player:equal(playerBuf.player) then
            self.immunityTargetList[#self.immunityTargetList+1] = killer
        end 
    end
end

function M:destroy()
    self.immunityTargetList = {}
    EventDispatcher:unRegisterEvent("BufWorkImmunityTakeEffect", {self,self.BufWorkImmunityTakeEffectHandler})
    M.super.destroy(self)
end

return M