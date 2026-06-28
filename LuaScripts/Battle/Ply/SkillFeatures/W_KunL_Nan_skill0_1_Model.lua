--姐姐演奏琵琶鼓舞自己正在跟随的友军，为其提升15%的暴击率和30%的暴击伤害，持续5秒；
--弟弟演奏箜篌鼓舞自己正在跟随的友军，为其恢复230%攻击的生命值；
---@class W_KunL_Nan_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_KunL_Nan_skill0_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.critBuff = self:getParam(1)
    self.hpBuff = self:getParam(2)
end

function M:canUse()
    return self.target ~= nil
end

--查找敌人
function M:findPlayer(data)
    M.super.findPlayer(self, data)
    if self.target ~= nil and self.player:get_curSkillConfig() ~= nil and self.player:get_curSkillConfig() == self.skill then
        data:clear()
        data:add(self.target)
    end
    return data
end

function M:skillDispatch(data)
    if data.eventName == "skill0_use" then
        if self.target ~= nil then
            self.target.bufMgr:addBufById(self.hpBuff, self.player.master, self.skill)
        end
    end
end

function M:follow(target)
    self.target = target
end

--攻击者攻击结束处理
function M:killerAfterAttack(data)
    local dmg = data["damage"]
    local killer = data["killer"]
    local victim = data["victim"]
    local skill = data.attackData["skillConfig"]
    if self.player:equal(killer) and skill == nil or skill.anim_name == "skill0" then
        victim.bufMgr:addBufById(self.hpBuff, self.player, self.skill)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M