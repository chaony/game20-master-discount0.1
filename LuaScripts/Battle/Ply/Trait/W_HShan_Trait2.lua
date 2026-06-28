--角色的专属装备
--衡山 战斗中 没击杀一个敌人，衡山便获得一层强化效果，该效果最多叠加3层，且会一直持续到战斗结束，
--1层时 衡山获得20%的攻击力提升 2层时 衡山额外获得30%的攻速提升 3层时 衡山额外获得20%的暴击率提升
--强化效果现在最多叠加4层 在第四层时，衡山额外获得35%的吸血效果
--强化效果现在最多叠加5层 在第五层时，衡山额外获得50%减伤效果

local W_HShan_Trait1 = require("Battle.Ply.Trait.W_HShan_Trait1")

---@class W_HShan_Trait2 : W_HShan_Trait1 @
---@field super W_HShan_Trait1 @W_HShan_Trait1
local M = class("W_HShan_Trait2", W_HShan_Trait1)



M.bufID_5 = 0



function M:init()
    M.super.init(self)
    self.maxnum = self:getValue(1)
    self.bufID_5 = self:getValue(6)
    
    table.insert(self.buf_table, 
    {
        count = 5,
        isBuf = false,
        buffId = self.bufID_4,
    })

end


return M