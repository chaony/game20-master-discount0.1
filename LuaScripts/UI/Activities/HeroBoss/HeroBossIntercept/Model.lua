local M = class("HeroBossInterceptModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("hero_boss_loot_rivals")
end

function M:onEnter()

end

return M