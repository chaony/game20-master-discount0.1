--苏袖释放战意，立刻为自身恢复30%最大生命值的血量，并使自身进入“殺禪”状态6秒，该状态下，苏袖的攻击力提升40%，攻击速度提升40%，且普攻会得到升级，每次普攻时都会对周围大范围内的敌人造成伤害

---@class W_SuX_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field skill0 W_SuX_skill0_1_Model
local M = class("W_SuX_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.costBufNums = self:getParam(1)  --int 消耗熏风buff的层数
    self.buffid = self:getParam(2)  -- buffid
    EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
    EventDispatcher:registerEvent("SkillEnter", {self,self.skillEnterHandler})
end

function M:spawn()
    M.super.spawn(self)
    self.skill0 = BattleTool:getSkillFeatureByName(self.player,"skill0")
end

---@param eventData Battle_HandleData_KillPlayer
function M:killerPlayerHandler(eventName, eventData)
    local killer = eventData["killer"]
    if self.player.skyStar and self.player:equal(killer) and self.player.bufMgr:hasBufByTag("SuX_skill3") then
        self.player.skyStar:triggerStart()
    end
end

---@param eventData Battle_HandleData_SkillEnter
function M:skillEnterHandler(eventName, eventData)
    if self.player:equal(eventData.player) and eventData.skillConfig and eventData.skillConfig.anim_name == "skill3" and self.skill0 and self.skill0:getXunFengBuff() >= self.costBufNums then
        for i = 1, self.costBufNums do
            self.skill0:removeXunFengBuff()
        end
        self.player.bufMgr:addBufById(self.buffid, self.player, self.skill)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.skillEnterHandler})
    M.super.destroy(self)
end

return M