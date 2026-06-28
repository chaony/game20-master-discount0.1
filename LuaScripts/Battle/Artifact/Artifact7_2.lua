
--永恒圣杯 战斗开始后的45秒内，每秒回复生命上限的1%生命

local Artifact7_0 = require("Battle.Artifact.Artifact7_0")

---@class Artifact7_2 : Artifact7_0 @
---@field super Artifact7_0 @Artifact7_0
local M = class("Artifact7_2", Artifact7_0)


function M:init(player,data)
    M.super.init(self, player, data)
    self.time =self:getValue(1)
    
end



return M