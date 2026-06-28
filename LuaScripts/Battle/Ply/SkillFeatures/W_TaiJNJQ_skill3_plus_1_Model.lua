--当场上阵图为太阴阵图时，太极内家拳会释放太阴之力笼罩全场5秒，每秒对敌方侠客造成300%攻击力的伤害和0.5秒的眩晕效果
--当场上阵图为太阳阵图时，太极内家拳会释放太阳之力笼罩全场8秒，每秒对我方侠客施加一个200%攻击力的太阳护盾，持续3秒，太阳护盾消失时，剩余护盾值会转换为我方侠客的血量
--lv3 太阴阵图每次造成伤害，都有30的概率触发“极阴印记”的爆炸
---@class W_TaiJNJQ_skill3_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TaiJNJQ_skill3_plus_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    --护盾转换血量比例，触发爆炸概率，恢复内力，cd，触发次数
    --self.shiledPer = self:getParam(1, 0) -- 护盾转换血量比例
    self.boomRate = self:getParam(1)--触发爆炸概率
    self.angerBuff = self:getParam(2)--恢复内力
    self.angerTagBuff = self:getParam(3)--
    EventDispatcher:registerEvent("add_W_TaiJNJQ_sun_shiled", {self,self.addBuffHandler})
    EventDispatcher:registerEvent("remove_W_TaiJNJQ_sun_shiled", {self,self.removeBuffHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    self.skill0 = BattleTool:getSkillFeatureByName(self.player, "skill0")
    self.skill1 = BattleTool:getSkillFeatureByName(self.player, "skill1_plus")
    if self.skill1 == nil then
        self.skill1 = BattleTool:getSkillFeatureByName(self.player, "skill1")
    end
end

function M:skillStart(data)
    if self.skill1 then
        if self.skill1.curStatus == 2 then
            self.skill.extra_anim_name = "skill3_plus_1"
        else
            self.skill.extra_anim_name = "skill3_plus"
        end
    end
end

---@param eventData Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, eventData)
    if eventData.buff and self.player:equal(eventData.buff.source) then     -- 自己加的buff
        local target = eventData.buff.player
        if target.bufMgr and not target.bufMgr:hasBufByTag("W_TaiJNJQ_anger") then
            target.bufMgr:addBufById(self.angerBuff, self.player, self.skill)
            target.bufMgr:addBufById(self.angerTagBuff, self.player, self.skill)
        end
    end
end

function M:removeBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.source) then
        local player = buff.player
        if player and player.bufMgr then
            local sheildValue = buff.bufWork:get_value()
            player:cure("fix", self.player, sheildValue, self.skill)
        end
    end
end


function M:destroy()
    self.skillTargets = {}
    EventDispatcher:unRegisterEvent("add_W_TaiJNJQ_sun_shiled", {self,self.addBuffHandler})
    EventDispatcher:unRegisterEvent("remove_W_TaiJNJQ_sun_shiled", {self,self.removeBuffHandler})
    M.super.destroy(self)
end

return M