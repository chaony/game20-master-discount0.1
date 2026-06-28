--梁山 每场战斗一次，当梁山受到致命伤害时，会免疫本次伤害并立即进入“浴血”状态，进入“浴血”状态时
--梁山会立即回满生命值。“浴血”状态持续期间，梁山会获得25点吸血等级，但每秒会损失最大生命值的10%
--“浴血”状态持续期间，梁山的攻击力每秒提升10%，最高提升100%
local W_LiangS_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_LiangS_skill0_1_Model")
---@class W_LiangS_skill0_2_Model : W_LiangS_skill0_1_Model @
---@field super W_LiangS_skill0_1_Model @W_LiangS_skill0_1_Model
local M = class("W_LiangS_skill0_2_Model", W_LiangS_skill0_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.atk = self:getParam(5)  --攻击力提升值
    self.maxAtk = self:getParam(6)  --攻击力提升最大值
    self.cur_atk = GlobalTools.base0
    self.last_atk = GlobalTools.base0
end


function M:addAtkValue( ... )
    self.cur_atk = self.cur_atk + self.atk
    if self.cur_atk >= self.maxAtk then
        self.cur_atk = self.maxAtk
    end
    if self.last_atk > 0 then
        self.player.data.atk:removeFromMulList(self.last_atk)
    end
    self.player.data.atk:addToMulList(self.cur_atk)
    self.last_atk = self.cur_atk
end


return M