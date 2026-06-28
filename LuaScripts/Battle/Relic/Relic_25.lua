--能量基座
--能量碎块发挥的效果增加一倍
---@class Relic_25 : Relic @
---@field super Relic @Relic
local M = class("Relic_25", Relic)

M.value = 0

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)

	--忽略叠加次数，所以未用统一接口
	self.value = self:getValueSimple(1)
end

return M