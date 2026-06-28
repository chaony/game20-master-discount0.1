--武当选择随机3个敌方侠客，为其施加持续5秒的真武剑意，
--被施加了真武剑意的侠客，每秒会受到280%攻击力的伤害和0.5秒的眩晕效果，真武剑意会无视敌方护盾；
--当敌方人数不足3人时，真武剑意会重复施加到同一名侠客身上，最多叠加三层
---@class W_WDang_skill3_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WDang_skill3_plus_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    --随机人数
    self.addNums = self:getParam(1)
    self.buffId = self:getParam(2)
    self.player.skill3ClearAnger = true
end
--
----技能释放(仅当前技能调用)
function M:skillStart(data)
    M.super.skillStart(self, data)
    --self.start = true
    --self.timer = GlobalTools.base1
    --护盾击破
    local targets = SelectTargetUtil:findPlayerByParam(self.player, { camp = "enemy", ignoreSummon = true, priority = true})
    if targets.Count >= self.addNums then
        for i = self.addNums, 1, -1 do
            local enemy = targets:get(i - 1)
            if enemy and enemy.bufMgr then
                enemy.bufMgr:addBufById(self.buffId, self.player, self.skill)
            end
        end
    else
        for i = 1, self.addNums do
            local enemy = GlobalTools:RandomOneFromList(targets)
            if enemy and enemy.bufMgr then
                enemy.bufMgr:addBufById(self.buffId, self.player, self.skill)
            end
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end
return M