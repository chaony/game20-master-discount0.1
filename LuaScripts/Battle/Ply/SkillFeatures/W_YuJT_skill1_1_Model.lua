--解锁该技能后，御竞堂的普攻会得到强化，每次攻击都会对敌方及其周围的敌人造成150%攻击力的范围伤害，但御竞堂的攻速会减少100%，
--战斗中，御竞堂每次获得攻速提升时，便会将攻速提升数值的30%转换为攻击力提升
--伤害提升至200%攻击力，被命中的敌人有50%概率被施加一层破甲状态（破甲：防御力降低10%，持续8秒，最多可叠加5层）
---@class W_YuJT_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field skill1 W_YuJT_skill1_1_Model
local M = class("W_YuJT_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId1 = self:getParam(1)  --减少攻速的buff
    self.pojiaRate = self:getParam(2)--破甲概率
    self.buffId2 = self:getParam(3)  --破甲BUFF
    self.haste2Atk = self:getParam(4) --攻速转换攻击的比例
    self.origin_haste = self.player.data.haste:getInitialValue()
    self.listen_atr = "haste"
    self.listen_name = self.player.plyType .. "_" .. self.listen_atr ..  "_Changed"
    self.player.data:registerAtrChangedByName(self.listen_name, self.listen_atr)
    EventDispatcher:registerEvent(self.listen_name, {self,self.atrChangeHandler})
    --EventDispatcher:registerEvent("SkillEnd", {self,self.SkillEndHandler})
end

function M:spawn()
    self.player.bufMgr:addBufById(self.buffId1, self.player, self.skill)
end

--攻击者攻击结束处理
---@param data Battle_HandleData_Attack
function M:killerAfterAttack(data)
    if self.player:equal(data.killer) and data.attackData.skillConfig == self.skill and self.pojiaRate > 0 then
        if GlobalTools:CheckRandom1(self.pojiaRate) then
            data.victim.bufMgr:addBufById(self.buffId2, self.player, self.skill)
        end
    end
end

function M:atrChangeHandler(event_name, event_data)
    if event_data and event_data.after_value and self.origin_haste then
        local atter_value = event_data.after_value
        if atter_value < self.origin_haste then
            atter_value = self.origin_haste
        end
        local offset_value = atter_value - event_data.before_value
        local haste_rate = GlobalTools:Div(offset_value, self.origin_haste)
        local add_atk_rate = GlobalTools:Mul(haste_rate, self.haste2Atk)
        local add_atk_value = GlobalTools:Mul(self.player.data.atk:getValue(), add_atk_rate) 
        self.player.data.atk:addToAddList(add_atk_value)
    end
end


-- skill1技能结束后判断是否再放一次skill1
---@param data Battle_HandleData_SkillEnd
--function M:SkillEndHandler(eventName, data)
    --local ply = data["player"]
    --local config = data["skillConfig"]
    --if ply:equal(self.player) and config ~= nil and ("skill1" == config.anim_name ) then
    --    self.skill.cur_post_cd   = GlobalTools.base0
    --end
--end

function M:destroy()
    --EventDispatcher:unRegisterEvent("SkillEnd", {self,self.SkillEndHandler})
    EventDispatcher:unRegisterEvent(self.listen_name, {self,self.atrChangeHandler})
    M.super.destroy(self)
end

return M