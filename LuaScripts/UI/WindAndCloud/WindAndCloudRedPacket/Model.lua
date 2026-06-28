local M = class("WindAndCloudRedPacketModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self.m_transfer = "scale"
	self.open_id = 407
	local cfg = ConfigManager:getCfgByName("redbag_draw")
	self.m_active_data = UserDataManager:getActivesDataByOpenId(self.open_id) or {}
	self.m_version = self.m_active_data.version or 1
	self.m_redpacket_nums = cfg and cfg[self.open_id][self.m_version].limit or 10 --可以领取的数量是limit  10个
	self.m_bag_show = cfg and cfg[self.open_id][self.m_version].redbag_show or 20 -- 展示的数量是20个
	self:getData("red_packet_index",{open_id =self.open_id,vsn =  self.m_version,num = self.m_bag_show})
	local red_packer_cfg = ConfigManager:getCfgByName("redbag_sent")
	if red_packer_cfg[self.open_id] then
		self.cur_red_packer_cfg = red_packer_cfg[self.open_id][self.m_version] or {}
	end
	self.is_main_open = self.m_params.is_main_open or false --是否重主界面打开
end

function M:onEnter()
	self.m_mode = 1
	self.m_send_redpacker_list = self.m_data.sent or {}
	self.m_receive_redpacker_list = self.m_data.receive or {}
	self.m_has_sent = #self.m_data.has_sent or 0
	self.m_left_rec = #self.m_data.day_received or 0
	self.is_send_redbag = false --是否发送红包
end

--红包列表
function M:getRedPacketList()
	return  self.m_mode == 1 and self.m_send_redpacker_list or self.m_receive_redpacker_list 
end

--刷新数据
function M:updateSendRedPacker(data)
	self.m_send_redpacker_list = data.can_sent or {}
	self.m_receive_redpacker_list = data.can_receive or {}
	self.m_has_sent = #data.has_sent or 0
end

return M