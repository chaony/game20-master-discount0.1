--每场战斗一次,当布阵在后排的友军受到致命伤害时,立即跳跃至该友军身边保护其免于死亡,并在之后10秒内代替该友军承受一切伤害,保护期间自身免疫控制效果

---@class W_CangY_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_CangY_skill2_1_Model", SkillFeatures_Model)

M.useCount = 1

M.friendData = {}

M.buffId1 = nil

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.useCount = 1;
    --伤害承担buff
    self.buffId1 = self:getParam(1)
    --减伤buff
    self.buffId2 = self:getParam(2)
end

function M:spawn()
    M.super.spawn(self)
    local list = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
    for i = 1, list.Count do
        if list:get(i - 1):equal(self.player) == false and (list:get(i - 1).index == 2 or list:get(i - 1).index == 4 or list:get(i - 1).index == 3) then
            table.insert(list:get(i - 1).avoidDeath, self)
        end
    end
end


function M:checkSkill(player)
    if self.player:isLive() and self.useCount > 0 then
        local imprisonBuff = self.player.bufMgr:findBufByType("Imprison")
        local charmBuff = self.player.bufMgr:findBufByType("Charm")
        if #imprisonBuff > 0 or #charmBuff > 0 or (self.player.curSkillConfig ~= nil and self.player.curSkillConfig.anim_name == "skill3") then
            return false
        else
            self.useCount = self.useCount - 1
            
            self.player.aiEngine.skillConfig = self.skill
            self.player.aiEngine:changeState("attack")

            self.player.friend = player
            self.player.friend.bufMgr:addBufById(self.buffId1, self.player)
            self.player.bufMgr:addBufById(self.buffId2, self.player)
            player.data:set_curHp(GlobalTools.base1)
            return true
        end
    else
        return false
    end
end

function M:destroy()
    local list = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
    for i = 1, list.Count do
        if list:get(i - 1):equal(self.player) == false and (list:get(i - 1).index == 2 or list:get(i - 1).index == 4 or list:get(i - 1).index == 3) then
            table.removebyvalue(list:get(i - 1).avoidDeath, self, true)
        end
    end
    M.super.destroy(self)
end

return M