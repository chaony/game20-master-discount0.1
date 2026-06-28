--战斗开始时，武当会获得一个太极盾，当太极盾存在时，若武当受到了近战范围内的伤害，则太极盾会破碎，并使武当无敌2秒，太极盾破碎15秒后会重新出现
---@class W_WDang_skill1_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WDang_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    --护盾buffid(护盾buff的tag),无敌buffid,重新加盾的cd
    self.shiledBuff = self:getParam(1)
    self.wuDiBuff = self:getParam(2)
    self.addShiledCd = self:getParam(3)
    self.addShiledCd = GlobalTools:ToFix(self.addShiledCd) 
    self.cdFlag = true
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    self.player:useSkill("skill1_plus", true)
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if self.player:equal(eventData.victim) and self.player.bufMgr:hasBufByTag("WDang_skill1_plus") then
        local killer = eventData.killer
        if self:checkEnemyDis(killer) then
            -- 免疫本次伤害
            eventData.wantdata.damage = 0
            self.player.bufMgr:removeBufByTag("WDang_skill1_plus")
            self.player.bufMgr:addBufById(self.wuDiBuff, self.player, self.skill)
        end
    end
end

function M:checkEnemyDis(enemy)
    local dis = GlobalTools:Distance(self.player:get_position(), enemy:get_position())
    return dis <= GlobalTools:Mul(self.skill.skill_dis, self.skill.skill_dis) 
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end
return M