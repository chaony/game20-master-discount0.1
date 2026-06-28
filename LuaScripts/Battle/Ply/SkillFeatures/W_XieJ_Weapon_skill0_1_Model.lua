-- 邪极傀儡

---@class W_XieJ_Weapon_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_XieJ_Weapon_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.player.data:set_moveSpeed( GlobalTools.base15 );
    EventDispatcher:registerEvent("ChangeAiState", {self,self.changeAiStateHandler})
end

----角色初始化结束
--function M:initFinish()
--    local state = self.player.aiEngine:getStateByName("idle")
--    state.anim_name = "battle_idle"
--    M.super.initFinish(self)
--end

function M:spawn()
    M.super.spawn(self)
    --self.player:ShowHpBar(false)
    --self.player.plyMgr:addHide(self.player)
end

-- 属于邪极武器的技能，此时不跟随主人
local xiej_weapon_skill_state = {
    skill = true,
}

--- 状态改变
---@param eventData Battle_HandleData_ChangeAiState
function M:changeAiStateHandler(eventName, eventData)
    if self.player.master and self.player.master:equal(eventData.player) then   -- 自己的主人状态改变
        local curState = self.player.aiEngine.curState
        if (not curState) or curState.animName ~= "skill3" then -- 释放大招时不能打断
            if eventData.targetState then
                if not xiej_weapon_skill_state[eventData.targetState.key] then
                    self.player.aiEngine:changeState(eventData.targetState.key)

                    -- 重置傀儡位置（瞬移至主人身边）
                    local position = self.player.master.position
                    local forward = FixVector3.Normalize(self.player.master.forward)
                    --local offset = forward * 0
                    self.player:setPos(position, true)
                    self.player:setForward(forward, true)
                end
            end
        else
            --Logger.logError("邪极此时处于大招状态，不能打断")
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("ChangeAiState", {self,self.changeAiStateHandler})
    M.super.destroy(self)
end


return M