--吕布释放战神之威环绕自身，立即恢复自身30%最大生命值的血量，并进入“天下无双”状态，天下无双状态持续期间，吕布会保留1点血量且不会死亡，
--并使自身增加50%攻击速度和攻击力，释放该技能不会消耗内力，但会在天下无双状态持续期间每秒消耗150点内力，当内力消耗完时，状态结束，
--且天下无双状态期间，吕布无法通过任何手段恢复内力

local W_LvB_skill3_1_Model = require("Battle.Ply.SkillFeatures.W_LvB_skill3_1_Model")
---@class W_LvB_skill3_4_Model : W_LvB_skill3_1_Model @
---@field super W_LvB_skill3_4_Model @W_LvB_skill3_1_Model
local M = class("W_LvB_skill3_4_Model", W_LvB_skill3_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

function M:spawn()
    M.super.spawn(self)
    self.skill0  = nil
    ---@type PlayerSkillItem
    local skill0 = self.player.plySkill:getSkillByName("skill0")
    if skill0 ~= nil then
        ---@type SkillDataConfig
        self.skill0 = skill0.cur_skill_config
    end
    EventDispatcher:registerEvent("SkillEnd", {self,self.SkillEndHandler})
end

-- skill1技能结束后判断是否再放一次skill1
---@param data Battle_HandleData_SkillEnd
function M:SkillEndHandler(eventName, data)
    local ply = data["player"]
    local config = data["skillConfig"]
    if ply:equal(self.player) and config ~= nil and ("skill0" == config.anim_name or "skill3" == config.anim_name) then
        local W_LvB_skill3 = self.player.bufMgr:findBufByTag("LvB_Skill3")
        if table.nums(W_LvB_skill3) > 0 and self.skill0 then
            self.skill0.cur_post_cd = GlobalTools.base0
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("SkillEnd", {self,self.SkillEndHandler})
    self.skill0 = nil
    M.super.destroy(self)
end

return M