--段瑛谷
--锻瑛谷每受到一次恢复效果，便会获得一层“锻铁”效果，每层锻铁效果会使自身防御力提升2%，最多提升50%
--lv 4 当锻瑛谷受到致命伤害时，会消耗当前锻铁层数的一半，免疫本次伤害并无敌2秒，每消耗一层锻铁层数，便恢复最大生命值1%的血量
---@class W_DuanYG_skill0_4_Model : SkillFeatures_Model @
local W_DuanYG_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_DuanYG_skill0_1_Model")
---@field super W_DuanYG_skill0_1_Model @W_DuanYG_skill0_1_Model
local M = class("W_DuanYG_skill0_4_Model", W_DuanYG_skill0_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId2 = self:getParam(2) --无敌buff
    self.cureHpPer = self:getParam(3) --恢复血量百分比
    self.interval = self:getParam(4) --免死cd
    self.m_cd_flag = false
    self.can_use_flag = true
    self.remove_buff_nums = 0
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    --EventDispatcher:registerEvent("add_W_DuanYG_skill0", {self,self.addBuffHandler})
end

function M:canUse()
    return self.can_use_flag
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if self.player:equal(eventData.victim) and self:canUse() and not self.m_cd_flag then
        if self.player:isAttackCauseDeath(eventData.attackData, eventData.wantdata) then   -- 本次伤害将会造成击杀
            -- 免疫本次伤害
            local bufflist = self.player.bufMgr:findBufByTag("Duantie")
            local buff_nums = #bufflist
            if buff_nums > 0  then
                self.m_cd_flag = true
                self.can_use_flag = false
                -- 免疫本次伤害
                eventData.wantdata.damage = 0
                local remove_nums = math.floor(buff_nums * 0.5)
                remove_nums = GlobalTools:Clamp(remove_nums, 1, remove_nums)
                for i = 1, remove_nums do
                    self.player.bufMgr:removeBufById(self.buffId1, true, true)
                end
                local cure_value = GlobalTools:Mul(self.cureHpPer, GlobalTools:ToFix(remove_nums))
                self.player:cure("hp", self.player, cure_value, self.skill)
                --self.player.bufMgr:addBufById(self.buffId3, self.player, self.skill)
                self.player.bufMgr:addBufById(self.buffId2, self.player, self.skill)
                -- 开始内部冷却
                TimeTools:delayTime(self.interval, function()
                    self.m_cd_flag = false
                    self.can_use_flag = true
                end)
            end
        end
    end
end

---@param eventData Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, eventData)
    if eventData.buff and self.player:equal(eventData.buff.source) then
        local buff = eventData["buff"]
        buff.bufWork.curblood = GlobalTools:Mul(buff.bufWork.curblood, GlobalTools:ToFix(self.remove_buff_nums))
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    --EventDispatcher:unRegisterEvent("add_W_DuanYG_skill0", {self,self.addBuffHandler})
    M.super.destroy(self)
end

return M