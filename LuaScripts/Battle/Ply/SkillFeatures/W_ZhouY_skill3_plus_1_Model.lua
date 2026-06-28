--周瑜对随机2名敌人造成280%攻击力的伤害，使其眩晕2秒并立即进入“极·焚烬”状态，每秒会造成400%攻击力的伤害，内伤减免降低50%，且无法恢复内力，持续4秒。
--该状态结束时，会额外造成一次爆炸，对所有的敌人造成280%攻击力的伤害。
--并使其立即进入“焚烬”状态，该次焚烬状态不会造成额外爆炸
--伤害提升至300%攻击力
--被爆炸命中的敌人，还会眩晕2秒
--若场上存在小乔，极·焚烬 状态下还会每秒额外造成3%最大生命值的伤害。
---@class W_ZhouY_skill3_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ZhouY_skill3_plus_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.extaAttackBuff = self:getParam(1)--额外造成3%最大生命值的伤害。
    if self.extaAttackBuff > 0 then
        EventDispatcher:registerEvent("add_W_ZhouY_FenJin", {self,self.addFenJinBuffHandler})
    end
end
function M:addFenJinBuffHandler(eventName, data)
    if data.buff and self.player:equal(data.buff.source) and self.skill == data.buff.sourceSkill then
        local hasXiaoQ = false
        local friends = self.player.plyMgr:getPlayers(self.player:get_camp())
        friends:safeWalkInverted(function(ply)
            if ply ~= nil and ply:isLive() and ply.playerId == Battle.EnumData.BATTLE_SPECIAL_HERO_ID.XiaoQ then
                hasXiaoQ = true
            end
        end)
        if hasXiaoQ then
            data.buff.player.bufMgr:addBufById(self.extaAttackBuff, self.player)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
    if self.extaAttackBuff > 0 then
        EventDispatcher:unRegisterEvent("add_W_ZhouY_FenJin", {self,self.addFenJinBuffHandler})
    end

end

return M