--扈三娘进入“战舞”状态8秒，立即恢复自身20%最大生命值的血量；“战舞”状态下，扈三娘的攻击力会提升50%，
--受到的伤害会减少50%，且skill2的冷却时间会减少50%
---@class W_HuSN_skill3_1_Model : SkillFeatures_Model
---@field super SkillFeatures_Model
local M = class("W_HuSN_skill3_1_Model", SkillFeatures_Model)
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.cdTime = self:getParam(1);
end

function M:spawn()
    M.super.spawn(self)
    self.skill2 = nil
    ---@type PlayerSkillItem
    local skill2 = self.player.plySkill:getSkillByName("skill2")
    if skill2 ~= nil then
        ---@type SkillDataConfig
        self.skill2 = skill2.cur_skill_config
    end
    EventDispatcher:registerEvent("SkillEnd", {self,self.SkillEndHandler})
end

function M:skillEnd(data)
    if self.skill2 then
        self.skill2.cur_post_cd = GlobalTools:Mul(self.skill2.cur_post_cd, self.cdTime)
    end
    M.super.skillEnd(self, data)
end

-- 大招状态下减skill2cd
---@param data Battle_HandleData_SkillEnd
function M:SkillEndHandler(eventName, data)
    local ply = data["player"]
    local config = data["skillConfig"]
    if ply:equal(self.player) and config ~= nil and "skill2" == config.anim_name then
        if self.player.bufMgr:hasBufByTag("W_HuSN_skill3") and self.skill2 then
            self.skill2.cur_post_cd = GlobalTools:Mul(self.skill2.cur_post_cd, self.cdTime)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("SkillEnd", {self,self.SkillEndHandler})
    self.skill2 = nil
    M.super.destroy(self)
end

return M