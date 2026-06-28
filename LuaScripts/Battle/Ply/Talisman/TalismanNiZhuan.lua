--- 逆转
--- 每次使用技能，如对方被强行控制，则有30%几率吸取对方30内力，多段攻击只生效1次（分身技能不算在内）
---@class TalismanNiZhuan : Talisman
---@field super Talisman
local M = class("TalismanAoXue", Talisman)

function M:init(player,data)
    M.super.init(self,player,data)
    self.triggerRate = self:getParam(1); --触发几率
    self.suckAngerBuffId = self:getParam(2); --吸取对方30内力
    self.triggerSkillTab = {}
end

function M:Attack( attackData, wantdata )
    --Logger.logError(attackData.attackData.skillConfig.anim_name, "Attack skill_config animname ------------------")
    local victim = attackData["victim"]
    if attackData.attackData and attackData.attackData.skillConfig and self.player.master == nil and BattleTool:isSkillInjure(attackData.attackData) and victim.bufMgr and GlobalTools:CheckRandom1(self.triggerRate) then
        local imprison = victim.bufMgr:findBufByType("Imprison")
        local isMyControl = false
        if #imprison > 0 then
            for i, v in ipairs(imprison) do
                if v.source ~= nil and v.source:isLive() and self.player:equal(v.source) then
                    isMyControl = true
                    break
                end
            end
        end
        if not isMyControl then
            local Charm = victim.bufMgr:findBufByType("Charm")
            if #Charm > 0  then
                for i, v in ipairs(Charm) do
                    if v.source ~= nil and v.source:isLive() and self.player:equal(v.source) then
                        isMyControl = true
                        break
                    end
                end
            end
        end
        
        if isMyControl and self.triggerSkillTab[attackData.attackData.skillConfig.anim_name] == 0 then
            victim.bufMgr:addBufById(self.suckAngerBuffId, self.player)
            self.triggerSkillTab[attackData.attackData.skillConfig.anim_name] = 1
        end
    end
end

function M:skillStart(ply, skill)
    if skill and skill.anim_name then
        self.triggerSkillTab[skill.anim_name] = 0
    end 
end

function M:destroy()
    self.triggerSkillTab = {}
    M.super.destroy(self)
end

return M;