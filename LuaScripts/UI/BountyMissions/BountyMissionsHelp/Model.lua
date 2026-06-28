local M = class("BountyMissionsHelpModel", LikeOO.OODataBase)


function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData("mercenary")
end

function M:onEnter()
	self:initData(self.m_data)
end

function M:initData(data)
	if data then
		self.m_heros = data.mercenarys
	else
		self.m_heros = {}
	end
end

function M:resfreshData(callback)
	self:getNetData("mercenary", nil, callback)
end

--根据id获得英雄数据
function M:getHero(id)
	return UserDataManager.hero_data:getHeroDataById(id)
end

function M:getNameByEvo(evo)
	local evos = ConfigManager:getCfgByName("hero_evolution")
	return evos[evo]
end

--- 网络数据回调，需要复写
function M:netData(data, tag)
	if tag == "mercenary" then
		self:initData(data)
	end
end

return M
