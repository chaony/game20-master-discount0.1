--段瑛谷
--战斗开始时，锻瑛谷会获得一个“熔金盾”，融金盾存在时， 锻瑛谷受到的伤害会减少50%，且每次受到伤害后都会恢复自身攻击力80%的血量，熔金盾会在受到10次伤害后消失
--lv2 每次释放必杀技后，锻瑛谷都会额外获得一个熔金盾
---@class W_DuanYG_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_DuanYG_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.beHitNums = self:getParam(1) --次数，
    self.buffId = self:getParam(2) --buffid
    self.curePer = self:getParam(3) --回血百分比
    self.curNums = 0
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    self:addShiledBuff()
end

function M:addShiledBuff()
    self.player.bufMgr:addBufById(self.buffId, self.player, self.skill)
    self.curNums = self.beHitNums
end

function M:reduceTimes()
    if self.curNums > 0 then
        self.curNums = self.curNums - 1
    end
    if self.curNums <= 0 then
        self.player.bufMgr:removeBufById(self.buffId, true)
    end
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if self.player:equal(eventData.victim) and self.curNums > 0 then
        local buff_list = self.player.bufMgr:findBufById(self.buffId)
        if #buff_list > 0 then
            self.player:cure("atk", self.player, self.curePer, self.skill)
            self:reduceTimes()
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M