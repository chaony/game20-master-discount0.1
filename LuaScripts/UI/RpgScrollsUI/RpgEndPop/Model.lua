local M = class("RpgEndPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_chapter_id = self.m_params.c_id
	self.m_ending_list = self.m_params.ending_list or {}
	self.m_show_list = self:getList()
end

function M:getList()
	local tab = ConfigManager:getCfgByName("roleplaying_ending")
	local c_end = tab[self.m_chapter_id]
	local list = {}
	for k,v in pairs(c_end) do
		table.insert( list, {id = k , cfg = v})
	end
	return list
end

function M:getEndDataByCId(e_id)
	return self.m_ending_list[tostring(e_id)]
end

--[[
    排序
]]
function M:sort(pros)
    pros = pros or {}
    local function sortFunc(one, two)
        return one.id < two.id
    end
    table.sort(pros, sortFunc)
end

return M
