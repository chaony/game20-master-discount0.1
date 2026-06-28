--若天策在“无双”状态下击杀了被“对决”选中的敌人，则提升的持续时间会翻倍 --旧
--新 无双持续期间，天策通过击杀恢复的怒气提高50%
local W_TianC_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_TianC_skill0_1_Model")
---@class W_TianC_skill0_2_Model : W_TianC_skill0_1_Model @
---@field super W_TianC_skill0_1_Model @W_TianC_skill0_1_Model
local M = class("W_TianC_skill0_2_Model", W_TianC_skill0_1_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.killAngerRate = self:getParam(2)
end


function M:spawn()
    M.super.spawn(self)
    local skill2 = self.player.plySkill:getSkillByName("skill2")
    if skill2 ~= nil and skill2.cur_skill_config ~= nil then
        self.skill2 = skill2.cur_skill_config.feature
    end
    --EventDispatcher:registerEvent("killPlayer", {self, self.killPlayerHandler})
    EventDispatcher:registerEvent("add_W_TianC_skill3", {self, self.addBuffHandler})
    EventDispatcher:registerEvent("remove_W_TianC_skill3", {self, self.removeBuffHandler})

end

--function M:killPlayerHandler(eventName, data)
--    if self.skill3 ~= nil and self.skill3.start == true then
--        local killer = data["killer"]
--        local victim = data["victim"]
--        --击杀
--        if self.player:equal(killer) then
--            self:killInSkill3(victim)
--        end
--    end
--end

function M:addBuffHandler(eventName, data)
    local buff = data.buff
    if buff.player ~= nil and buff.player:equal(self.player) then
        self.player.data.killAngerRate:addToMulList(self.killAngerRate)
    end
end

function M:removeBuffHandler(eventName, data)
    local buff = data.buff
    if buff.player ~= nil and buff.player:equal(self.player) then
        self.player.data.killAngerRate:removeFromMulList(self.killAngerRate)
    end
end

--function M:killInSkill3(victim)
--    if self.skill2:checkSelect(victim) == true then
--        if self.cureBuffId ~= 0 then
--            self.player.bufMgr:addBufById(self.cureBuffId)
--        end
--    end
--end

function M:destroy()
    M.super.destroy(self)
    --EventDispatcher:unRegisterEvent("killPlayer", {self, self.killPlayerHandler})
    EventDispatcher:unRegisterEvent("add_W_TianC_skill3", {self, self.addBuffHandler})
    EventDispatcher:unRegisterEvent("remove_W_TianC_skill3", {self, self.removeBuffHandler})
end

return M