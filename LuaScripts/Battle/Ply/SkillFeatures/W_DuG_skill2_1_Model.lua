--对敌方单体造成240%攻击力的伤害，释放后若处于目标身前，则会将敌人原地束缚2秒，并瞬移至敌人身后；若处于目标身后，则会对目标额外造成一次200%攻击力的伤害
---@class W_DuG_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_DuG_skill2_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.shufuBuff = self:getParam(1) -- 束缚buff
    self.extHurtBuff = self:getParam(2) -- 额外伤害buff
    self.enemyTarget = nil -- 目标敌人
    --EventDispatcher:registerEvent("injure", {self,self.injureHandler}) --改成走策划编辑器了
end

function M:skillStart(data)
    if self.player.enemy and self.player.enemy:isLive() then
        local forWard = BattleTool:checkPlayerAndTargetForward(self.player, self.player.enemy)
        if forWard == false then -- 背对敌人
            self.skill.extra_anim_name = "skill2"
        else
            self.skill.extra_anim_name = "skill2_1"
        end
    end
    
    M.super.skillStart(self, data)
end
--改成走策划编辑器了
---@param data Battle_BeHitDirectData
function M:injureHandler(eventName, data)
    local killer = data["killer"]
    local attackData = data["attackData"]
    local victim = data["victim"]
    local skillConfig = attackData["skillConfig"]
    
    if self.player:equal(killer) and victim ~= nil and skillConfig and skillConfig.anim_name == "skill2" then -- 造成伤害的是自己
        local forWard = BattleTool:checkPlayerAndTargetForward(self.player, victim)
        if forWard == false then -- 背对敌人
            victim.bufMgr:addBufById(self.extHurtBuff, self.player)
        else
            victim.bufMgr:addBufById(self.shufuBuff, self.player)
            self:skill2_move()
        end
        self.enemyTarget = victim
    end
end

-- 瞬移到敌人身后
function M:skill2_move()
    if self.enemyTarget ~= nil then
        if self.enemyTarget:isLive() ~= true then
            self.enemyTarget = nil
        end
        if self.enemyTarget ~= nil and SceneManager.curScene.getAreaPosition ~= nil then
            local pos = self.enemyTarget:get_position() - self.enemyTarget:getForward() * GlobalTools.base1
            pos = SceneManager.curScene:getAreaPosition(pos)
            self.player:setPos(pos, true)
        end
    end
end

function M:destroy()
    --EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M