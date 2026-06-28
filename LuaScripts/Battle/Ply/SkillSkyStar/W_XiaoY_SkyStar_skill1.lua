--- 北冥：鲲鹏击对布甲类侠客造成额外20%的伤害。

---@class W_XiaoY_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_XiaoY_SkyStar_skill1", SkillSkyStar)


function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.extraDmg = self:getParam(1, 0)
end

--触发开始
---@param data Battle_HandleData_Attack
function M:triggerStart(data)
    if data.victim and data.victim.plyData.type == 3 then     -- 被击方是布甲
        data.damage = data.damage + GlobalTools:Mul(data.damage, self.extraDmg)
    end
end

--触发结束
function M:triggerEnd( data )
    
end


return M;