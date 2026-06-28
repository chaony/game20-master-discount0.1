local M = class("UnionFindPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("guild_recommend")
end

function M:onEnter()
	self:updateListData(self.m_data.summary)
end

function M:updateListData(data)
	self.m_select = 1
	self.m_list_data = data
	table.sort(self.m_list_data,function(data1,data2)
		if data1.level == data2.level then
			return data1.exp > data2.exp
		else
			return data1.level > data2.level
		end
	end)
end

function M:setSelectIndex(index)
	self.m_select = index
end

function M:getSelectUnionData()
	return self.m_list_data[self.m_select]
end

function M:getTripodsLv(tripods)
	tripods = tripods or {}
	local guild_tripod = ConfigManager:getCfgByName("guild_tripod")
	local lvs = {}
	for i = 1, 6 do
		local tripod = tripods[tostring(i)]
		if tripod then
			local cfg = guild_tripod[tripod.id]
			lvs[i] = cfg.lv
		else
			lvs[i] = 0
		end
	end
	return lvs
end

return M
