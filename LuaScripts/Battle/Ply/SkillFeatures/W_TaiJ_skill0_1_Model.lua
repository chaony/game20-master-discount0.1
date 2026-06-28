--被阴阳轮转伤害命中的敌人，会被添加一层阴阳标记，每层阴阳标记会使敌人的防御降低5%，标记会存在10秒，且最多叠加4层
---@class W_TaiJ_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TaiJ_skill0_1_Model", SkillFeatures_Model)
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    --markbuff
    self.buff1 = self:getParam(1)
    --防御buff
    self.buff2 = self:getParam(2)
    --EventDispatcher:registerEvent("add_W_TaiJ_skill0", {self,self.addBuffHandler})
end

--function M:addBuffHandler(eventName, data)
--    local buff = data["buff"]
--    if buff ~= nil and self.player:equal(buff.source) then
--        buff.source.bufMgr:addBufById(self.buff, self.player)
--    end
--end

--攻击者攻击结束处理
function M:killerAfterAttack(data)
    local skill = data.attackData.skillConfig
    local damage = data.damage
    local victim = data.victim
    if skill ~= nil and (skill.anim_name == "skill1" or skill.anim_name == "skill3") then
        victim.bufMgr:addBufById(self.buff1, self.player)
        victim.bufMgr:addBufById(self.buff2, self.player)
    end
end

function M:destroy()
    --EventDispatcher:unRegisterEvent("add_W_TaiJ_skill0", {self,self.addBuffHandler})
    M.super.destroy(self)
end

return M