--毁殇状态下，天墉城的普攻将变为玄天炽焰
local W_TianYC_skill3_1_Model = require("Battle.Ply.SkillFeatures.W_TianYC_skill3_1_Model")
---@class W_TianYC_skill3_4_Model : W_TianYC_skill3_1_Model @
---@field super W_TianYC_skill3_1_Model @W_TianYC_skill3_1_Model
local M = class("W_TianYC_skill3_4_Model", W_TianYC_skill3_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

function M:spawn()
    M.super.spawn(self)
    self.skill1 = nil
    ---@type PlayerSkillItem
    local skill1 = self.player.plySkill:getSkillByName("skill1")
    if skill1 ~= nil then
        ---@type SkillDataConfig
        self.skill1 = skill1.cur_skill_config
    end
    EventDispatcher:registerEvent("SkillEnd", {self,self.SkillEndHandler})
end

-- skill1技能结束后判断是否再放一次skill1
---@param data Battle_HandleData_SkillEnd
function M:SkillEndHandler(eventName, data)
    local ply = data["player"]
    local config = data["skillConfig"]
    if ply:equal(self.player) and config ~= nil and ("skill1" == config.anim_name or "skill3" == config.anim_name) then
        local W_TianYC_skill3 = self.player.bufMgr:findBufByTag("W_TianYC_skill3")
        if table.nums(W_TianYC_skill3) > 0 and self.skill1 then
            self.skill1.cur_post_cd = GlobalTools.base0
        end
    end
end

function M:update(dt,unsdt)
    M.super.update(self, dt, unsdt)
end


function M:destroy()
    EventDispatcher:unRegisterEvent("SkillEnd", {self,self.SkillEndHandler})
    self.skill1 = nil
    M.super.destroy(self)
end

return M