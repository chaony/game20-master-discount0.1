--为所有己方角色施加“庇佑”效果，被施加了“庇佑”效果的友军，受到的伤害减少50%，且每秒会恢复120%攻击力的生命值，持续8秒
--为所有己方角色随机清除一层负面状态
---@class W_CiH_skill3_1_Model : SkillFeatures_Model
local M = class("W_CiH_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.removeCnt = self:getParam(1)
    if self.removeCnt > 10 then
        self.removeCnt = 10
    end
    ----庇佑值比例
    --self.protectRate = self:getParam(1)
    ----范围伤害消耗减少
    --self.rangeReduce = self:getParam(2)
    ----剩余庇佑值转化比例
    --self.changeRate = self:getParam(3)
    ----庇佑值列表
    --self.protectList = {}
    EventDispatcher:registerEvent("add_W_CiH_skill3", {self,self.addBuffHandler})
    --EventDispatcher:registerEvent("remove_W_CiH_skill3", {self,self.removeBuffHandler})
    --EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:findPlayer(data)
    if self.skill == self.player.curSkillConfig then
        local x = 1;
        x = x + 1
    end
    return M.super.findPlayer(self, data)
end

---@param data Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, data)
    if data.buff and self.player:equal(data.buff.source) and self.skill == data.buff.sourceSkill then
        ---@type PlayerModel
        local friend = data.buff.player
        if friend then
            for i = 1, self.removeCnt do
                if friend.bufMgr:removeRandomOneBufByTag("debuff", false) == 0 then  -- 没有debuf可移除
                    break
                end
            end
        end
    end
end
--
--function M:removeBuffHandler(eventName, data)
--    local buff = data["buff"]
--    if buff ~= nil and self.player:equal(buff.source) then
--        local playerInstanceId = buff.player:get_playerInstanceId()
--        if self.protectList[playerInstanceId] ~= nil then
--            if self.protectList[playerInstanceId].value > 0 then
--                local cureHp = GlobalTools:Mul(self.protectList[playerInstanceId].value, self.changeRate)
--                buff.player:cure("fix", self.player, cureHp, self.skill)
--            end
--            self.protectList[playerInstanceId] = nil
--            
--            local headUIData = {}
--            headUIData.player = buff.player
--            self:dispatchEvent_Local(Battle.EventType.MV_SkillFeaturesModelRemoveHeadUI, headUIData)
--        end
--    end
--end
--
--function M:injureHandler(eventName, data)
--    local victim = data["victim"]
--    local damage = data["wantdata"]["damage"]
--    local attackData = data["attackData"]
--    local skillConfig = attackData["skillConfig"]
--    if victim ~= nil then
--        local playerInstanceId = victim:get_playerInstanceId()
--        if self.protectList[playerInstanceId] ~= nil and self.protectList[playerInstanceId].value > 0 and damage > GlobalTools.base0 then
--            local cost = damage
--            if (skillConfig ~= nil and skillConfig.is_aoe == true) or attackData.isSingleTarget == false then
--                cost = GlobalTools:Mul(cost, GlobalTools.base1 - self.rangeReduce)
--            end
--
--            local cureHp = damage
--            if self.protectList[playerInstanceId].value > cost then
--                self.protectList[playerInstanceId].value = self.protectList[playerInstanceId].value - cost
--                
--                local headUIData = {}
--                headUIData.player = victim
--                headUIData.value = GlobalTools:Div(self.protectList[playerInstanceId].value, self.protectList[playerInstanceId].max_value)
--                self:dispatchEvent_Local(Battle.EventType.MV_SkillFeaturesModelUpdateHeadUI, headUIData)
--            else
--                cureHp = self.protectList[playerInstanceId].value
--                victim.bufMgr:removeBuf(self.protectList[playerInstanceId].buff)
--            end
--            TimeTools:delayTime(GlobalTools.base0_1, function()
--                if victim:isLive() == true then
--                    victim:cure("fix", self.player, cureHp, self.skill)
--                end
--            end)
--        end
--    end
--end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_CiH_skill3", {self,self.addBuffHandler})
    --EventDispatcher:unRegisterEvent("remove_W_CiH_skill3", {self,self.removeBuffHandler})
    --EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M