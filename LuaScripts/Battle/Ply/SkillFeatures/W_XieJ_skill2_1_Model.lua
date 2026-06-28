-- 邪极操控傀儡，对前方范围内的所有单位造成200%攻击力的伤害，释放若当自身的“邪灵”效果累计了5层以上，则该技能的伤害范围会得到提升，
-- 当场上有侠客死亡时，邪极会立刻释放一次该技能

---@class W_XieJ_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_XieJ_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)

    self.roundAddLevel = self:getParam(1) -- int[0-20] 技能范围提升的层数
    self.damageAddLevel = self:getParam(2) -- int[0-20] 技能伤害提升的层数
    self.afterDamageAddValue = self:getParam(3) -- Fix[0-100] 后伤害提升百分比
    self.addAreaRadius = self:getParam(4) -- Fix[0-100] 后伤害提升百分比

    EventDispatcher:registerEvent("PlayerDead", {self, self.playerDeadHandle})
end

---@param eventData Battle_HandleData_PlayerDead
function M:playerDeadHandle(eventName, eventData)
    if (not self.player:equal(eventData.data)) then  -- 非是自己死亡,立即释放一次技能
        if eventData.data.master == nil then
            if self.player.aiEngine ~= nil  then
                self.player.aiEngine.skillConfig = self.skill
                self.player.aiEngine:changeState("attack")
            end
        end
    end
end

---@param frameData AnimEvtFrame_Model
---@param data Battle_Frame_Data_Event_Hit
function M:hitFrame(frameData, data)
    if frameData.evtAction.animName == self.skill.anim_name then
        if self:getResLevel() >= self.damageAddLevel then
            data = table.copy(data)
            --增加的攻击范围
            data.count.areaRadius = data.count.areaRadius + self.roundAddLevel
        end
    end
    return data
end

---@return number
function M:getResLevel()
    if not self.mySkill1 then
        local  skill1 = self.player.plySkill:getSkillByName("skill1")
        if skill1 and skill1.cur_skill_config then
            self.mySkill1 = skill1.cur_skill_config.feature
        end
    end

    if self.mySkill1 then
        return self.mySkill1.curResLevel
    end

    return 0
end

--查找敌人
---@param data Battle_List<PlayerModel>
function M:findPlayer(data)
    return data
end

function M:destroy()
    EventDispatcher:unRegisterEvent("PlayerDead", {self, self.playerDeadHandle})
    M.super.destroy(self)
end

return M