--聂隐娘在敌人半场召唤鞭刃阵，每秒对所有敌人造成170%的伤害，对术士和辅助侠客额外造成1.5倍伤害，阵法内每秒驱散一次敌人的无敌效果，阵法持续5秒
--对术士和辅助侠客额外造成2倍伤害
--每次造成伤害都会造成0.5秒的眩晕
--阵法持续时间，每有1名敌人死亡，聂隐娘恢复100点内力
---@class W_NieYN_skill3_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_NieYN_skill3_plus_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.existTime = self:getParam(1) --阵法持续5秒
    self.roleTypeArray = self:getParam(2) --职业
    self.extraHurtRate = self:getParam(3) --术士和辅助侠客额外造成1.5倍伤害
    self.anger = self:getParam(4) --恢复100点内力
    self.inSkillTime = GlobalTools.base0
    EventDispatcher:registerEvent("killPlayer", {self,self.killPlayerHandler})
end

function M:killerBeforeAttack(attackData, victim)
    M.super.killerBeforeAttack(self, attackData, victim)
    if attackData.skillConfig == self.skill and table.indexof(self.roleTypeArray, victim.plyData.role_type)  then
        attackData["damageFront"] = attackData["damageFront"] + self.extraHurtRate
    end
end

--技能释放(仅当前技能调用)
function M:skillStart(data)
    self.inSkillTime = self.existTime
    M.super.skillStart(self)
    self:clearInvincible()
end


function M:clearInvincible()
    if self.inSkillTime <= GlobalTools.base0 then
        return
    end
    local sceneCenter = SelectTargetTool:findFixPoint(self.player, "sceneCenter")
    local enemyCamp = self.player:get_camp() * -1
    local enemys = SceneManager.curScene.plyMgr:getPlayers(enemyCamp)
    for i = 1, enemys.Count do
        local enemy = enemys:get(i - 1)
        if (enemyCamp == -1 and enemy:get_position().x > sceneCenter.x) or (enemyCamp == 1 and enemy:get_position().x < sceneCenter.x) then
            if(enemy:isLive() and enemy.bufMgr ~= nil and enemy.bufMgr:hasBufByType("Invincible") ) then
                enemy.bufMgr:removeBufByType("Invincible")
            end
        end
    end
    self.inSkillTime = self.inSkillTime - GlobalTools.base1
    if self.inSkillTime > GlobalTools.base0 then
        TimeTools:delayTime(GlobalTools.base1,function()  self:clearInvincible() end)
    end
end

function M:killPlayerHandler(eventName, data)
    local victim = data["victim"]
    if self.isInSkill and  victim.camp ~= self.player.camp then
        self.player.data:addAnger(self.anger)
    end
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("killPlayer", {self, self.killPlayerHandler})
end

return M