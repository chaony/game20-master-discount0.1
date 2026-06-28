--苏袖每次使用skill2时，都会为自身叠加一层“薰风”buff，
--每层薰风buff可使自身受到的伤害减少10%，受到的治疗效果增加10%，持续到战斗结束，
--薰风buff最多可以叠加5层

---@class W_SuX_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_SuX_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)

    self.addBuff1 = self:getParam(1)  --Buff[] 熏风buff
    self.firstAddBuffCnt = self:getParam(2)  --Int[] 首次增加层数
    self.maxAddBuffCnt = self:getParam(3)  --Int[] 最大叠加层数
    --self.buffEffectId1 = self:getParam(4)
    --self.buffEffectId2 = self:getParam(5)
    --self.buffEffectId3 = self:getParam(6)
    --self.buffEffectId4 = self:getParam(7)
    --self.buffEffectId5 = self:getParam(8)
    --self.buffEffectId6 = self:getParam(9)
    self.buffEffectTab = {}
    for i = 1, 6 do
        self.buffEffectTab[i] = self:getParam(i + 3)
    end
    self.curAddBuffCnt = self.firstAddBuffCnt

    EventDispatcher:registerEvent("SkillEnter", {self,self.skillEnterHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    for i = 1, self.firstAddBuffCnt do
        self.player.bufMgr:addBufById(self.addBuff1, self.player, self.skill)
    end
    self:updateBuffEffect()
end

---@param eventData Battle_HandleData_SkillEnter
function M:skillEnterHandler(eventName, eventData)
    if self.player:equal(eventData.player) and eventData.skillConfig and eventData.skillConfig.anim_name == "skill2" then
       self:addXunFengBuff()
    end
end

function M:addXunFengBuff()
    if not self:hasMaxXunFengBuff() then
        self.curAddBuffCnt = self.curAddBuffCnt + 1
        self.player.bufMgr:addBufById(self.addBuff1, self.player, self.skill)
        self:updateBuffEffect()
    end
end

function M:removeXunFengBuff()
    if self.curAddBuffCnt > 0 then
        self.curAddBuffCnt = self.curAddBuffCnt - 1
        self.player.bufMgr:removeBufById(self.addBuff1, true, true)
        self:updateBuffEffect()
    end
end

function M:hasMaxXunFengBuff()
    return self.curAddBuffCnt >= self.maxAddBuffCnt
end

function M:getXunFengBuff()
    return self.curAddBuffCnt
end

function M:updateBuffEffect()
    local showEffectBuffId = self.buffEffectTab[self.curAddBuffCnt]
    self.player.bufMgr:removeBufByTag("W_SuX_skill0_effect")
    if showEffectBuffId then
        self.player.bufMgr:addBufById(showEffectBuffId, self.player, self.skill)
    end
    return nil
end

--销毁
function M:destroy()
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.skillEnterHandler})
    M.super.destroy(self)
end

return M