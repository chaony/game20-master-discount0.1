--角色的专属装备
--绝情 若被技能“十面埋伏”命中的敌人在5秒内死亡，则绝情会恢复已损失生命值的30%，并额外获得100点能量
--我方友军会获得血量和能量的恢复效果的50%
--回复量提升至已损失生命值得50% 额外的能量提升至200
local W_JueQ_Trait1 = require("Battle.Ply.Trait.W_JueQ_Trait1")

---@class W_JueQ_Trait2 : W_JueQ_Trait1 @
---@field super W_JueQ_Trait1 @W_JueQ_Trait1
local M = class("W_JueQ_Trait2", W_JueQ_Trait1)



function M:init()
    M.super.init(self) 
    self.hp = self:getValue(1)  --回血
    self.anger = self:getValue(2)  --会怒
end





return M