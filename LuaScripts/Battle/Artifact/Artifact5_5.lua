
--神圣之刃 战斗开始每3秒增加1.5%攻击力和3命中

local Artifact5_2 = require("Battle.Artifact.Artifact5_2")

---@class Artifact5_5 : Artifact5_2 @
---@field super Artifact5_2 @Artifact5_2
local M = class("Artifact5_5", Artifact5_2)



function M:init(player,data)
    M.super.init(self, player, data)
    self.atk = self:getValue(2)
    self.hr = self:getValue(3)
end


return M