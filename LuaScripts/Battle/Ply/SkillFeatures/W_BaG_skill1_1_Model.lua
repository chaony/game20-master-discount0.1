---瞬移至目标另一侧，对目标造成120%攻击力并施加一层破甲效果，释放该技能后，八卦会提升自身20%暴击率，持续5秒（破甲：防御力降低10%，持续8秒，最多可叠加5层）
---战斗开始时释放技能1隐身0.5秒后释放此技能,之后再释放技能不隐身
---@class W_BaG_skill1_1_Model : SkillFeatures_Model
---@field super SkillFeatures_Model
local M = class("W_BaG_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hideTime = self:getParam(1)  --  + GlobalTools.base15
    self.hideBuff = self:getParam(2)  -- 隐身buff
    self.use_skill_cnt = 0
end

---隐藏角色，暂停角色动作
function M:skillStart(data)
    self.use_skill_cnt = self.use_skill_cnt + 1
    M.super.skillStart(self, data)
    if self.use_skill_cnt == 1 and self.hideTime > 0 and self.player:isLive() then -- 首次释放技能
        self:doDisappearBeforeSkill()
    end
end

-- 执行消失
function M:doDisappearBeforeSkill()
    self.player.bufMgr:addBufById(self.hideBuff, self.player, self.skill)
    --self.player:pauseAnim()
    --self.player:dispatchEvent_Local(Battle.EventType.MV_PlayerModelHideBody,{show = false})
    --self.player:ShowHpBar(false)
    self.disappearTimer = TimeTools:delayTime(self.hideTime, function()
        self.disappearTimer = nil
        --if(self.player and  self.player:isLive())then
            self.player.bufMgr:removeBufById(self.hideBuff, true)
        --    self.player:hideBody(self.player.isHide)
        --    self.player:ShowHpBar(self.player.isHide)
        --    self.player:resumeAnim()
        --end
    end)
end

function M:destroy()
    if self.disappearTimer then
        TimeTools:stopTask(self.disappearTimer)
        self.disappearTimer = nil
    end
    M.super.destroy(self)
end

return M