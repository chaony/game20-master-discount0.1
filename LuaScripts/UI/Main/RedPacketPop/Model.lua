---@class RedPacketPopModel: OODataBase
local M = class("RedPacketPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

--读取配置后，增加两个null的作为未开启的选项
function M:onEnter()
	self.m_state = 1 -- 1代表封面
	self.m_data = {}
	self.m_red_packet_data = self.m_params or {} 
	self.m_auto = self.m_params.auto or false
	self.m_open = self.m_params.open or false
	self.m_red_packet_cfg= ConfigManager:getCfgByName("red_envelope")
	self.m_money_guide_cfg= ConfigManager:getCfgByName("money_guide")
	
end

function M:refreshData(callback)
	local function netCallback(response)
	 	self.m_data = response
		callback()
	end
	local params = {incr_id = self.m_red_packet_data.red_id}
	self:getNetData("red_envelope_recv_envelope",params,netCallback)
end

function M:getListData()
	return self.m_data.ranks or {{}}
end

function M:getMoneyTypeData()
	local cur_red_packet_cfg = self.m_red_packet_cfg[self.m_red_packet_data.red_packet_id] or {}
	local money_id = cur_red_packet_cfg.money_guide
	local cur_money_guide_cfg = self.m_money_guide_cfg[money_id] or {}
	return  cur_money_guide_cfg
end

return M
