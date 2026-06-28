--小乔施展恢复之力，为所有己方侠客恢复200%攻击力的血量，血量百分比低于50%的侠客收到的恢复效果会翻倍，若治疗效果溢出，则溢出部分的20%会转化为友军的最大生命值加成，持续到战斗结束
--受到恢复效果的友军还会获得30%的攻击力提升，持续5秒
--溢出治疗效果的转化比例提升至25%
--溢出治疗效果的转化比例提升至30%
---@class W_XiaoQ_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_XiaoQ_skill1_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hp = self:getParam(1)--血量百分比低于hp的侠客
    self.cureRate = self:getParam(2)--恢复效果会提升cureRate,同药王 福泽技能
    self.maxHpBuff = self:getParam(3)--若治疗效果溢出，则溢出部分的maxHpBuff会转化为友军的最大生命值加成
    self.cureList = Battle.List.new()
    EventDispatcher:registerEvent("cureOverflow", {self,self.cureOverflowHandler})
end
function M:skillStart(data)
    self.cureList:clear()
    local friendList = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
    for i = 1, friendList.Count do
        local friend = friendList:get(i - 1)
        if friend.data:get_hpRate() <= self.hp then
            self.cureList:add(friend)
        end
    end
end

--作为攻击者的属性临时调整
function M:killerDataChangeTemp(victim, skill)
    if skill ~= nil and skill.anim_name == "skill1" then
        if victim ~= nil and self.cureList:contains(victim) then
            self.player.data.cureRate:addToMulListTemp(self.cureRate)
        end
    end
end

function M:skillEnd(data)
end
function M:cureOverflowHandler(eventName, eventData)
    if eventData.sourceBuff and eventData.player ~= nil and self.skill == eventData.sourceBuff.sourceSkill  then -- 是本技能造成的治疗
        local maxHpValue = GlobalTools:Mul(eventData.overflow, self.maxHpBuff)
        --local newMaxHpValue = eventData.player.data:get_hp() + maxHpValue
        eventData.player.data.hp:addToAddList(maxHpValue)
        eventData.player.data:set_curHp( eventData.player.data.hp:getValue(), true )

       -- summon.data.hp:addToAddList(GlobalTools:Mul(self.attrAddRate, self.targetInitHp))
        --summon.data.atk:addToAddList(GlobalTools:Mul(self.attrAddRate, self.targetInitAtk))
        --summon.data.def:addToAddList(GlobalTools:Mul(self.attrAddRate, self.targetInitDef))
        --summon.data:set_curHp(summon.data.hp:getValue())

    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("cureOverflow", {self,self.cureOverflowHandler})
    M.super.destroy(self)
end

return M