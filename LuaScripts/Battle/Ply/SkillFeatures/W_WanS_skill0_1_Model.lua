--战斗开始时，万兽会召唤一只狼王，狼王拥有万兽属性的80%

---@class W_WanS_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WanS_skill0_1_Model", SkillFeatures_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    local summonData = require("Battle.Ply.SkillFeaturesData.W_WanS_skill0_1_Data")
    self.summonData = table.copy(summonData)
    self.attrRate = self:getParam(1)
end

--角色出生结束
function M:spawnFinish()
    local SendForFuncframe = require("Battle.Ply.Fuc.SendForFunc").new()
    local ply = self.player
    SendForFuncframe:init(self.summonData, ply)
    self.summon = SendForFuncframe.player
    if self.summon ~= nil then
        self.summon.data:set_level( self.player.data:get_level() ) 
        self.summon.data:set_evo( self.player.data:get_evo() )
        self.summon.plySkill:refreshSkill(nil)
        self.summon.data.hp:setInitialValue(self.summon.data:getCopyData(self.player.data.hp, true, self.attrRate))
        self.summon.data.atk:setInitialValue(self.summon.data:getCopyData(self.player.data.atk, true, self.attrRate))
        self.summon.data.def:setInitialValue(self.summon.data:getCopyData(self.player.data.def, true, self.attrRate))
        self.summon.data:set_curHp(self.summon.data:get_hp())
        self.summon:setPos(self.player.position + self.player:getForward() * GlobalTools.base2);
        --self.summon.aiEngine:changeState("idle")

        self.summon:ShowHpBar(true)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M