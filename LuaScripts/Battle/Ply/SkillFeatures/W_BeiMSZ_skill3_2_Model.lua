--悲魔山庄	烈火情天
--lv2 该技能成功命中敌人后，会为自身添加5层破天劲，且每额外命中一个敌人，还会多添加一层

---@class W_BeiMSZ_skill3_2_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_BeiMSZ_skill3_2_Model", SkillFeatures_Model)

--初始化
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)

    self.firstHitAddStack = self:getParam(1) -- Fix[1-100] 首次命中增加层数
    self.extraHitAddStack = self:getParam(2) -- Fix[1-100] 额外命中增加层数

    self.beHitPlayer = {}	-- 当前技能命中的人
end

function M:spawnFinish()
    self.mySkill1 = self.player.plySkill:getSkillByName("skill1")
    M.super.spawnFinish(self)
end

function M:skillStart(data)
    M.super.skillStart(self, data)
    self.isInSkill = true
    self.beHitPlayer = {}
end

function M:skillEnd(data)
    self.isInSkill = false
    self.beHitPlayer = {}
    M.super.skillEnd(self, data)
end

--攻击者攻击结束处理
---@param data Battle_HandleData_Attack
function M:killerAfterAttack(data)
    if self.player:equal(data.killer) and data.attackData.skillConfig == self.skill then
        self:onHitSomeBody(data.victim)
    end
end

---@param player PlayerModel
function M:onHitSomeBody(player)
    if not self.beHitPlayer[player] then  -- 命中敌人
        local isFirst = (table.nums(self.beHitPlayer) == 0)
        self.beHitPlayer[player] = true
        self:onRealHitSomeBody(player, isFirst)
    end
end

---@return W_BeiMSZ_skill1_1_Model
function M:getSelfSkill1()
    if self.mySkill1 then
        return self.mySkill1.cur_skill_config and self.mySkill1.cur_skill_config.feature
    end
end

function M:onRealHitSomeBody(player, isFirst)
    local feature = self:getSelfSkill1()
    if feature and feature.improvePtStack then
        if isFirst then
            feature:improvePtStack(self.firstHitAddStack)
        else
            feature:improvePtStack(self.extraHitAddStack)
        end
    end
    --悲魔山庄 大招命中敌人
    if self.player.skyStar ~= nil then
        self.player.skyStar:triggerStart( player )
    end
end

return M