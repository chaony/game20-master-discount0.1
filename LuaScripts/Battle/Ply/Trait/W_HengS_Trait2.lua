--角色的专属装备
--恒山
--普通攻击命中敌人会随机为一名友军回复80%攻击力的生命值
--治疗效果提升至120%攻击力，优先对最虚弱的友军释放
local W_HengS_Trait1 = require("Battle.Ply.Trait.W_HengS_Trait1")
---@class W_HengS_Trait2 : W_HengS_Trait1 @
---@field super W_HengS_Trait1 @W_HengS_Trait1
local M = class("W_HengS_Trait2", W_HengS_Trait1)

function M:init()
    M.super.init(self)
    self.hp = self:getValue(1)
    self.herotable = 
    {
      ["count"] = "one",
      ["camp"] = "friendExceptSelf",
      ["posIndex"] = "all",
      ["priority"] = false,
      ["ignoreSummon"] = false,
      ["targetNoRepeat"] = false,
      ["campRace"] = "not",
      ["pos"] = "bloodLeast",
      ["profession"] = "all",
      ["area"] = "all",
      ["areaWidth"] = 0,
      ["areaHeight"] = 0,
      ["areaAngle"] = 0,
      ["areaRadius"] = 0,
      ["forceSelect"] = false,
      ["selectLast"] = false,
      ["isFixPoint"] = false,
      ["fixpoint"] = "enemyBackCenter"
    }
   
end


return M