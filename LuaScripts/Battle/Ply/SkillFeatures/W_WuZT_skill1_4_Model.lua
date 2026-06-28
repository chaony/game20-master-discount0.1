--四海臣服
--战斗开始15秒后，该技能会替换为武则天的普攻
local W_WuZT_skill1_3_Model = require("Battle.Ply.SkillFeatures.W_WuZT_skill1_3_Model")

---@class W_WuZT_skill1_4_Model : W_WuZT_skill1_4_Model @
---@field super W_WuZT_skill1_3_Model @W_WuZT_skill1_3_Model
local M = class("W_WuZT_skill1_4_Model", W_WuZT_skill1_3_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.changeCd = self:getParam(8)
    self.postCd = self:getParam(9)
    self.changeAttack = false
    EventDispatcher:registerEvent("SkillEnd", {self,self.SkillEndHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
   
    if self.changeCd > 0 then
        TimeTools:delayTime(self.changeCd,function()
            self.changeAttack = true
        end)
    end
end

-- skill1技能结束后判断是否再放一次skill1
---@param data Battle_HandleData_SkillEnd
function M:SkillEndHandler(eventName, data)
    local ply = data["player"]
    local config = data["skillConfig"]
    if ply:equal(self.player) and config ~= nil and ("skill1" == config.anim_name ) then
        if self.changeAttack and self.postCd > 0 then
            local attack1 = self.player.plySkill:getSkillByName("attack1")
            if attack1 ~= nil then
                self.attack1 = attack1.cur_skill_config.feature
                local cd = self.player.data:getAttackCd(self.attack1.skill.post_cd)
                self.skill.cur_post_cd = cd
            end
        end
    end
end

--销毁
function M:destroy()
    EventDispatcher:unRegisterEvent("SkillEnd", {self,self.SkillEndHandler})
    M.super.destroy(self)
end
return M
