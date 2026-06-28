local M = class("SkinExchangePopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self:initShowData()
end

--- 网络数据回调，需要复写
function M:netData(data, tag)
	self:initShowData()
end

function M:initShowData()
	local show_data = {}
	local hero_skin_cfg = ConfigManager:getCfgByName("hero_skin")
	for i, v in pairs(hero_skin_cfg) do
		local convert = v.convert
		if convert and #convert > 0 then
			table.insert(show_data, {id = i, cfg = v})
		end
	end
	self.m_show_heros = show_data
end

function M:getShowData()
	return self.m_show_heros or {}
end

return M
