--角色的专属装备
--衡山 战斗中 没击杀一个敌人，衡山便获得一层强化效果，该效果最多叠加3层，且会一直持续到战斗结束，
--1层时 衡山获得20%的攻击力提升 2层时 衡山额外获得30%的攻速提升 3层时 衡山额外获得20%的暴击率提升
--强化效果现在最多叠加4层 在第四层时，衡山额外获得35%的吸血效果

local W_HShan_Trait0 = require("Battle.Ply.Trait.W_HShan_Trait0")

---@class W_HShan_Trait1 : W_HShan_Trait0 @
---@field super W_HShan_Trait0 @W_HShan_Trait0
local M = class("W_HShan_Trait1", W_HShan_Trait0)



M.bufID_4 = 0



function M:init()
    M.super.init(self)
    self.maxnum = self:getValue(1)
    self.bufID_4 = self:getValue(5)
    
    table.insert(self.buf_table, 
    {
        count = 4,
        isBuf = false,
        buffId = self.bufID_4,
    })

end


return M