local M = class("AdvancedSmartPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_list_data = {}
	self.m_select = {}
	for i,v in ipairs(self.m_params.data) do
		local material = {}
		for i = 2, #v do
			material[#material + 1] = v[i]
		end
		self.m_list_data[i] = {v[1],material, selected = true}
		-- self.m_select[#self.m_select + 1] = true
	end

	-- function sortFunc(data1, data2)
	-- 	local heroData1 = UserDataManager.hero_data:getHeroDataById(data1[1])
	-- 	local heroData2 = UserDataManager.hero_data:getHeroDataById(data2[1])
	-- 	return heroData1.evo > heroData2.evo
	-- end
	-- table.sort(self.m_list_data,sortFunc)
end

function M:changeSelect(index)
	self.m_list_data[index].selected = not self.m_list_data[index].selected
end

function M:getSelectData()
	local data = {}
	for i,v in ipairs(self.m_list_data) do
		if v.selected then
			data[v[1]] = v[2]
		end
	end
	return data
end

function M:searchMaterialIsLock()
	local data = {}
	for i,v in ipairs(self.m_list_data) do
		if v.selected then
			for k,vv in pairs(v[2]) do
				local data = UserDataManager.hero_data:getHeroDataById(vv)
				if data and data.lock == true then
					return true
				end
			end
		end
	end
	return false
end

return M
