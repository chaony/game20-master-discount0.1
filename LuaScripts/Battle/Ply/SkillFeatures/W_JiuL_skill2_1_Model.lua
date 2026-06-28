--召唤飞雪到场上，飞雪会继承自身50%的属性并存在15s；若自身存在“祈灵”buff，飞雪还会对附近的敌人进行攻击，每次造成自身250%攻击力的伤害；
---@class W_JiuL_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field attack1 W_JiuL_attack1_1_Model
local M = class("W_JiuL_skill2_1_Model", SkillFeatures_Model)

M.summoned = nil

M.timer = 0
function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.existTime = self:getParam(1)
    self.attr = self:getParam(2)
    
    self.timer = 0
    EventDispatcher:registerEvent("add_W_JiuL_skill3", {self,self.addBuffHandler})
    EventDispatcher:registerEvent("remove_W_JiuL_skill3", {self,self.removeBuffHandler})
end

function M:spawn()
    local attack1 = self.player.plySkill:getSkillByName("attack1")
    if attack1 ~= nil then
        self.attack1 = attack1.cur_skill_config.feature
    end
    local frame = self.player.evtMgr:getCommonEvent("Sendfor", 1)
    self.SendforData = frame.data
end

--技能事件
function M:skillDispatch(data)
    if data.eventName == "skill2_move" then
        if self.attack1 ~= nil and self.attack1.summoned_cat ~= nil and self.attack1.summoned_cat:isLive() then
            self.attack1.summoned_cat:lockEnemy(self.player:get_enemy())
            self.attack1.summoned_cat.aiEngine:changeState("skill", {animName = self.skill.anim_name})
        end
    elseif data.eventName == "skill2_active" then
        if self.attack1 ~= nil then
            self.attack1:active()
        end
    end
end

--技能释放(仅当前技能调用)
function M:skillStart(data)
    M.super.skillStart(self, data)
    if self.attack1 ~= nil and self.attack1.summoned_cat ~= nil then
        self.attack1.summoned_cat.summonData.follow = false
        self.timer = self.existTime
    end
end


function M:update(dt)
    if self.timer > 0 then
        self.timer = self.timer - dt
        if self.timer <= 0 then
            if self.attack1 ~= nil and self.attack1.summoned_cat ~= nil then
                self.attack1:deactive()
            end
        end
    end
end

function M:addBuffHandler(eventName, data)
    --local buff = data["buff"]
    --if buff ~= nil and self.player:equal(buff.source) then
    --    if self.attack1 ~= nil then
    --        self.attack1:changeToTiger()
    --    end
    --end
end

function M:removeBuffHandler(eventName, data)
    --local buff = data["buff"]
    --if buff ~= nil and self.player:equal(buff.source) then
    --    if self.timer > 0 then
    --        if self.attack1 ~= nil and self.attack1.summoned_cat ~= nil then
    --            self.attack1:changeToCat()
    --        end
    --    end
    --end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_JiuL_skill3", {self,self.addBuffHandler})
    EventDispatcher:unRegisterEvent("remove_W_JiuL_skill3", {self,self.removeBuffHandler})
    M.super.destroy(self)
end

return M