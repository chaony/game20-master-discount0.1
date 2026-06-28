local M = class("MasterApprenticeRedPacketPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData("red_packet")
end

function M:onEnter()
	local red_p = self.m_params.red_packet or {}
	self.m_red_packet = {}
	for k,v in pairs(red_p) do
		table.insert( self.m_red_packet, v)
	end
end

function M:setStatus(id)
	for k,v in pairs(self.m_red_packet) do
		if id == v.id then
			v.status = 1
		end
	end
end

function M:removeData(data)
    for k,v in pairs(self.m_red_packet) do
		if data == v.id then
			table.remove( self.m_red_packet, k)
			break
		end
	end
end

return M
