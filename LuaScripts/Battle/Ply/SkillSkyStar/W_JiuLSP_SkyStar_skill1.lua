--"灵压威严：
--飞雪每4次普攻，会对敌人造成10%的最大生命值伤害

---@class W_JiuLSP_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_JiuLSP_SkyStar_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.attackCount = self:getParam(1)
    self.hurtBuff = self:getParam(2)
    self.attackTick = 0
end

---@param data Battle_HandleData_Attack
function M:triggerStart(data)
    self.attackTick = self.attackTick + 1
    if self.attackTick >= self.attackCount then
        self.attackTick = 0
        if data.victim ~= nil and data.victim:isLive()  then
            data.victim.bufMgr:addBufById(self.hurtBuff, data.killer)
        end
    end
end

--function M:hitFrame(frameData, data)
--    if frameData.evtAction.animName == "attack1" and self.player:equal(frameData.player and frameData.player.master) then
--        -- 改为范围攻击
--        data = table.copy(data)
--        data.count.count = "all"
--        data.count.camp = "enemy"
--        data.count.area = "rectangle"
--        data.count.areaWidth = self.attackAreaWidth
--        data.count.areaHeight = self.attackAreaHeight
--    end
--    return data
--end

return M;