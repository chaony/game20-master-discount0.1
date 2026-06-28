--古墓召唤棺材砸向敌人，对敌人造成130%攻击力的外功伤害，并在原地召唤一个“幽魂魅影”，幽魂魅影拥有古墓80%的属性，且造成的伤害的50%会转化为古墓的生命值,
--释放技能时，若场上已经存在有“幽魂魅影”，则会使幽魂魅影释放绝技，对周范围内的敌人造成5段外功伤害，每段80%攻击力

--改 等级2：【战斗开始时，古墓会立刻召唤一个幽魂魅影】
---@class W_GuM_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_GuM_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hp = self:getParam(1)
    self.atk = self:getParam(2)
    EventDispatcher:registerEvent("SendForFinish", {self,self.sendForHandler})
end

--技能释放(仅当前技能调用)
function M:skillStart(data)
    local summon = {}
    --遍历宠物列表
    for i = 1, self.player.summonList.list.Count do
        local key = self.player.summonList.list:get(i-1)
        local plys = self.player.summonList:get(key)
        for i, v in ipairs(plys) do
            table.insert(summon, v)
            v.aiEngine:changeState("skill")
        end
    end
    if #summon > 0 then
        self.skill.extra_anim_name = "skill3_1"
    end
end

--召唤成功
function M:sendForHandler( eventName, data )
    local player = data["player"]
    if self.player:equal(player.master) == true then
        player.data.hp:setInitialValue(player.data:getCopyData(self.player.data.hp, true, self.hp))
        player.data.atk:setInitialValue(player.data:getCopyData(self.player.data.atk, true, self.atk))
        player.data.def:setInitialValue(player.data:getCopyData(self.player.data.def, true, self.atk))
        player.data:set_curHp(player.data:get_hp())
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("SendForFinish", {self,self.sendForHandler})
    M.super.destroy(self)
end

   

return M