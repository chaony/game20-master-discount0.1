---@class PlayerTrait @角色的专属装备
local M = class("PlayerTrait")

M.player = nil

M.params = nil

function M:initData(ply, param)
    self.player = ply
    self.params = param
    self:init()
end

function M:init()
    
end

function M:spawn()
end

function M:update(dt)

end

--作为攻击者的属性临时调整
function M:killerDataChangeTemp(victim)
end

--作为受伤者的属性临时调整
function M:victimDataChangeTemp(killer)
end

function M:destroy()

end

function M:getValue(index)
    if self.params[index] ~= nil then
        return self.params[index]
    end
    return 0
end

return M