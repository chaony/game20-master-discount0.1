-- 当慈航受到伤害时，会立即瞬移到一名随机友军背后，并为该友军和自己恢复100%攻击力的血量，该效果有10秒的冷却时间
---@class W_CiH_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_CiH_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId = self:getParam(1)
    self.already = false;
end

function M:canUse()
    return self.already
end

--攻击开始处理
function M:beforeAttack(attackData, killer)
    if self.player:get_curSkillConfig() == nil or self.player:get_curSkillConfig().anim_name ~= "skill3" then
        self.already = true
        if self.skill:canUse() then
            if self.player.aiEngine ~= nil  then
                self.player.aiEngine.skillConfig = self.skill
                self.player.aiEngine:changeState("attack")
            end
        end
        self.already = false
    end
end

function M:skillDispatch(data)
    if data.eventName == "skill2_move" then
        self.target = nil
        
        local list = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
        local friends = Battle.List.new() 
        for i = 1, list.Count do
            local friend = list:get(i - 1)
            if friend:equal(self.player) == false and friend.master == nil then
                friends:add(list:get(i - 1))
            end
        end
        if friends.Count > 0 then
            local random = WRandom:randomNum(0, friends.Count, true)
            self.target = friends:get(random)
            if self.target ~= nil then
                local pos = self.target:get_position() - self.target:getForward() * GlobalTools.base2
                pos = SceneManager.curScene:getAreaPosition(pos)

                self.player:setPos(pos, true)
            end
        end
    elseif data.eventName == "skill2_fire" then
        if self.target ~= nil then
            self.target.bufMgr:addBufById(self.buffId, self.player)
        end
        self.player.bufMgr:addBufById(self.buffId, self.player)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M