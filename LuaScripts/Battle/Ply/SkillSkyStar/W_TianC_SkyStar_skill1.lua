--"战八方：
--天策释放“天下无双”时，对近身范围敌人造成320%攻击力的外功伤害，在“无双”状态持续期间，敌方侠客每层“威慑”将提高天策6%的攻击力和10%的防御力"

---@class W_TianC_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_TianC_SkyStar_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)

    self.addAtk = self:getParam(1, 0)    --Fix[]    -- 每层威慑加攻击（定点数）
    self.addDef = self:getParam(2, 0)    --Fix[]    -- 每层威慑加防御（定点数）

    self.curAddAtk = 0
    self.curAddDef = 0
    
    EventDispatcher:registerEvent("add_W_TianC_skill3", {self,self.addBuffHandler})
    EventDispatcher:registerEvent("remove_W_TianC_skill3", {self,self.removeBuffHandler})
    
    self.isRunning = false
end

---@param eventData Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, eventData)
    if eventData.buff and self.player:equal(eventData.buff.source) then -- 
        
        if self.isRunning then
            Logger.logError("已经加过属性了")
            return
        end
        self.isRunning = true

        local enemies = SelectTargetUtil:findPlayerByParam(self.player, { camp = "enemy", ignoreSummon = true})
        local allCnt = 0
        enemies:safeWalkInverted(function(player)
            local buffs = player.bufMgr:findBufByType("W_TianC_skill2_1")
            allCnt = allCnt + #buffs
        end)

        self.curAddAtk = 0
        self.curAddDef = 0
        for i = 1, allCnt do
            self.curAddAtk = self.curAddAtk + self.addAtk
            self.curAddDef = self.curAddDef + self.addDef
        end

        self.player.data.atk:addToMulList(self.curAddAtk)
        self.player.data.def:addToMulList(self.curAddDef)
        self.isAddAttr = true
    end
end

---@param eventData Battle_HandleData_RemoveBuff
function M:removeBuffHandler(eventName, eventData)
    if eventData.buff and self.player:equal(eventData.buff.source) then -- 
        self.isRunning = false
        self.player.data.atk:removeFromMulList(self.curAddAtk)
        self.player.data.def:removeFromMulList(self.curAddDef)
        self.curAddAtk = 0
        self.curAddDef = 0
    end
end

function M:triggerStart(data)
    if self.player:isLive() then
        self.player.evtMgr:commonEventWorkByKey("Hit", 1)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_TianC_skill3", {self,self.addBuffHandler})
    EventDispatcher:unRegisterEvent("remove_W_TianC_skill3", {self,self.removeBuffHandler})
    M.super.destroy(self)
end

return M;