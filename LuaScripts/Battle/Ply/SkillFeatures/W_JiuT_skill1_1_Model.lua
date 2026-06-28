--若该技能至少命中了2个敌人，则九天的防御力会提升50%，持续5秒
---@class W_JiuT_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JiuT_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.defenseBuff = self:getParam(1) -- 防御力提升buf
    self.enemyCount = 0	-- 当前技能命中的人
    self.attackFlag = false -- 攻击
end

--查找敌人
function M:findPlayer(data)
    M.super.findPlayer(self, data)
    if self.player:get_curSkillConfig() ~= nil and self.player:get_curSkillConfig() == self.skill then
        self.enemyCount = data.Count
    end
    return data
end

function M:skillStart(data)
    M.super.skillStart(self, data)
    self.enemyCount = 0
    self.attackFlag = false
end

--技能结束(仅当前技能调用)
function M:skillEnd(data)
    M.super.skillEnd(self, data)
    self.enemyCount = 0
    self.attackFlag = false
end

--攻击者攻击结束处理
---@param data Battle_HandleData_Attack
function M:killerAfterAttack(data)
    if self.enemyCount > 2 and self.player:equal(data.killer) and data.attackData.skillConfig == self.skill and not self.attackFlag then
        self.player.bufMgr:addBufById(self.defenseBuff, self.player, self.skill)
        self.attackFlag = true
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M