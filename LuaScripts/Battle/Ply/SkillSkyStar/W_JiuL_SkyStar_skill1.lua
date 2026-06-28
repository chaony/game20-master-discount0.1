--"兽王决：
--飞雪现在会继承九黎自身属性的120%，并且飞雪的攻击变为近战范围伤害"

---@class W_JiuL_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_JiuL_SkyStar_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.attrPercent = self:getParam(1, 0)   --int[0, 5]

    self.attackAreaHeight = self:getParam(2, 0)   --int[0, 100]
    self.attackAreaWidth = self:getParam(3, 0)   --int[0, 100]
end

---@param data W_JiuL_attack1_1_Model
function M:triggerStart(data)
    if self.attrPercent < data.attr then
        Logger.logError("天命化星后飞雪的属性反而降低")
    end
    data.attr = self.attrPercent
end

function M:hitFrame(frameData, data)
    if frameData.evtAction.animName == "attack1" and self.player:equal(frameData.player and frameData.player.master) then
        -- 改为范围攻击
        data = table.copy(data)
        data.count.count = "all"
        data.count.camp = "enemy"
        data.count.area = "rectangle"
        data.count.areaWidth = self.attackAreaWidth
        data.count.areaHeight = self.attackAreaHeight
    end
    return data
end

return M;