--段瑛谷
--锻瑛谷攻击一名随机敌方角色，对其造成200%攻击力的伤害并为其添加“灭魂”标记，灭魂标记会存在10秒，存在期间每秒会造成80%攻击力的伤害，且锻瑛谷会恢复灭魂标记造成伤害50%的生命值
--lv2 当自身进入阎魔状态时，每秒还会对被施加了灭魂标记的敌人造成伤害
---@class W_DuanYG_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_DuanYG_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
	self.curePer = self:getParam(1) --治疗量
    self.buffId = self:getParam(2) --伤害buff
    EventDispatcher:registerEvent("SkillEnter", {self,self.skillEnterHandler})
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if self.player:equal(eventData.killer) then
        local attackData = eventData.attackData
        if attackData then
            local buff = attackData.sourceBuff
            if buff and buff:checkTag("Miehun") then
                local cure_value = GlobalTools:Mul(eventData.wantdata.damage, self.curePer)
                self.player:cure("fix", self.player, cure_value, self.skill)
            end
        end
    end
end

---@param eventData Battle_HandleData_SkillEnter
function M:skillEnterHandler(eventName, eventData)
    if self.player:equal(eventData.player) and eventData.skillConfig and eventData.skillConfig.anim_name == "skill2" then
        local YanMo = self.player.bufMgr:findBufByTag("YanMo")
        if table.nums(YanMo) > 0 and self.skill.level >= 2 then
            self.player.bufMgr:addBuf(self.buffId, self.player, self.skill)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.skillEnterHandler})
    M.super.destroy(self)
end

return M