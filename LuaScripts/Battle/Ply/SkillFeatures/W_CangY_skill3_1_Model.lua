--苍云举起盾牌进入防御姿态，持续5s。防御期间自身所受伤害降低50%，且会为身后的队友阻挡所有飞行物。
---@class W_CangY_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_CangY_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.lastTime = self:getParam(1)
    --减伤buff
    self.buff1 = self:getParam(2)
    --回血buff
    self.buff2 = self:getParam(3)
    self.timer = GlobalTools.base0
    self.addBuff = false
end

--技能释放,只有当前技能会调用
function M:skillStart(data)
    local friends = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
    for i = 1, friends.Count do
        local friend = friends:get(i - 1)
        friend.resistBullet:add(self.player)
    end
    self.timer = self.lastTime
    self.addBuff = false
end

--技能结束,只有当前技能会调用
function M:skillEnd(data)
    local friends = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
    for i = 1, friends.Count do
        local friend = friends:get(i - 1)
        friend.resistBullet:remove(self.player)
    end
    self.player.bufMgr:removeBufById(self.buff1)
    self.player.bufMgr:removeBufById(self.buff2)
end

function M:update(dt)
    M.super.update(self, dt)
    if self.player.animator ~= nil and self.player.animator.curState ~= nil and self.player.animator.curState.name == "skill3_loop" then
        if self.addBuff == false then
            self.addBuff = true
            self.player.bufMgr:addBufById(self.buff1, self.player)
            self.player.bufMgr:addBufById(self.buff2, self.player)
        end
        if self.timer > 0 then
            self.timer = self.timer - dt
            if self.timer <= 0 then
                self.player.animator:changeState("skill3_end")
                self.player.bufMgr:removeBufById(self.buff1)
                self.player.bufMgr:removeBufById(self.buff2)
            end
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M