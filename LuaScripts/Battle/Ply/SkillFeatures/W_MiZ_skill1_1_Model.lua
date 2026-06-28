--密宗    金轮返生
-- 当密宗首次死亡时，会暂时离开战场10秒，10秒后，若场上仍存在友方侠客，密宗会回满血量重新进入战场，并进入“涅槃”状态。涅槃状态下，密宗的攻击、防御、血量、攻速属性会提升35%，涅槃状态会一直持续到战斗结束。在密宗离开战场期间，若己方侠客全部阵亡，则密宗会立即回到战场

---@class W_MiZ_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_MiZ_skill1_1_Model", SkillFeatures_Model)

---@class 密宗状态
local EMiZStatus = {
    Alive = 0,
    WillNirvana = 1,
    Nirvana = 2,
}

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)

    self.reenterTime = self:getParam(1)  -- Fix[0-100] 重新进入战场时间
    self.nirvanaBuffId = self:getParam(2)  -- Buff 涅槃buffid

    self.curLeaveTime = 0
    self.isLeaveField = false   -- 离开战场
    self.selfStatus = EMiZStatus.Alive
    
    EventDispatcher:registerEvent("relive", {self,self.reliveHandler})
    EventDispatcher:registerEvent("leave_battlefield", {self,self.leaveHandler})
end

function M:spawn()
    M.super.spawn(self)
    self.selfStatus = EMiZStatus.Alive
end

function M:dead(data)
    if self.selfStatus == EMiZStatus.Alive then
        self:willNirvana(data)
    end
    return M.super:dead(self,data)
end

function M:update(dt, unsdt)
    if self.selfStatus == EMiZStatus.WillNirvana then
        self.curLeaveTime = self.curLeaveTime + dt
        if self.isLeaveField then   
            if self.curLeaveTime >= self.reenterTime or (not self:haveLiveFriend()) then -- 计时结束或没有队友
                self:intoNirvana()
            end
        end
    end
end

-- 进入涅槃
function M:intoNirvana()
    self.player.canRelive = false
    self.selfStatus = EMiZStatus.Nirvana
    self.player.data:set_curHp(self.player.data:get_hp())   -- 生命回满
    self.player.aiEngine:changeState("relive")
end

-- 进入涅槃状态
function M:willNirvana(data)
    self.selfStatus = EMiZStatus.WillNirvana
    self.curLeaveTime = 0
    self.player.canRelive = true
    --self.player.data:set_curHp(GlobalTools.base1)
    --self.player.aiEngine:changeState("die_into")
end

---@return boolean 是否处于涅槃状态
function M:isInNirvana()
    return self.selfStatus == EMiZStatus.Nirvana
end

---@param data Battle_HandleData_Relive
function M:reliveHandler(eventName, data)
    if self.player:equal(data.player) then
        self.isLeaveField = false
        self:onRelive()
    end
end

-- 复活后
function M:onRelive()
    self.player.bufMgr:addBufById(self.nirvanaBuffId, self.player, self.skill)
    if self.player.skyStar then
        self.player.skyStar:triggerStart(self)
    end
end

---@param data Battle_HandleData_LeaveField
function M:leaveHandler(eventName, data)
    if self.player:equal(data.player) then
        self.isLeaveField = true
    end
end

---获取存活队友数量
function M:haveLiveFriend()
    ---@type Battle_List
    local friends = self.player.plyMgr:getPlayers(self.player:get_camp())
    if friends.Count > 0 then
        for i = 0, friends.Count-1 do
            ---@type PlayerModel
            local player = friends:get(i)
            if not self.player:equal(player) then
                if player:isLive() then
                    return true
                end
            end
        end
    end
    return false
end

function M:destroy()
    EventDispatcher:unRegisterEvent("relive", {self,self.reliveHandler})
    EventDispatcher:registerEvent("leave_battlefield", {self,self.leaveHandler})
    M.super.destroy(self)
end

return M