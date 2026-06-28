local M = class("MagicWeaponSelectMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.weapon_lock_lv = ConfigManager:getCommonValueById(577,160) 
	self:getShareLv()
end

function M:getShareLv()
	local top_hero = UserDataManager.hero_data:getLevelTop()
	if next(top_hero) == nil then
		return true
	end
	if #top_hero >= 5 then
		local cur_data = top_hero[5]
		if cur_data[2] >= self.weapon_lock_lv then
			return true	
		end
	else
		return false	
	end 
	return false
end

return M
