
--神圣之刃 战斗开始每3秒增加1%攻击力和2命中

local Artifact5_0 = require("Battle.Artifact.Artifact5_0")

---@class Artifact5_2 : Artifact5_0 @
---@field super Artifact5_0 @Artifact5_0
local M = class("Artifact5_2", Artifact5_0)


M.hr = nil


function M:init(player,data)
    M.super.init(self, player, data)
    self.hr = self:getValue(3)
end



function M:addData()
    M.super.addData(self)
   self.player.data.hr:addToAddList(self.hr)
end

return M