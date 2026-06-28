--赵云施展枪出如龙时，无视敌方防御30%，且造成敌人攻速降低30%持续5秒

---@class W_ZhaoY_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_ZhaoY_SkyStar_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.bufId1 = self:getParam(1)
end

--触发开始
---@param victim PlayerModel
function M:triggerStart(victim)
    if victim and victim.bufMgr then
        victim.bufMgr:addBufById(self.bufId1, self.player)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M;