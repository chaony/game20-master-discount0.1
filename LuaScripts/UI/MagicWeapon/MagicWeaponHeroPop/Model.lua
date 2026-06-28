local M = class("MagicWeaponHeroPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_heros = self.m_params.heros
    local function sortFunc(id_one, id_two)
        local is_hav1 = UserDataManager.hero_data:checkHeroCollect(id_one) == true and 1 or 0
        local is_hav2 = UserDataManager.hero_data:checkHeroCollect(id_two) == true and 1 or 0
		local cfg_1 = UserDataManager.hero_data:getHeroConfigByCid(id_one)
		local cfg_2 = UserDataManager.hero_data:getHeroConfigByCid(id_two)
        if is_hav1 == is_hav2 then
            return cfg_1.evo  < cfg_2.evo
        else
            return is_hav1 > is_hav2
        end
    end
    table.sort(self.m_heros, sortFunc)
	
end


return M
