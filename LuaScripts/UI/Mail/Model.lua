local M = class("MailPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "up_to_down"
	self:getData( "mail_index" , {mail_ids = {}}, false, GlobalConfig.POST)
end

function M:onEnter()
	self.m_mail_ids = self.m_data and self.m_data.all_mail_ids or {}
	self.m_list_data = self.m_data and self.m_data.mail or {}
	self.m_select_index = 1
	self.m_rewards = {}
end

function M:setSelectIndex(index)
	self.m_select_index = index;
end

function M:AddMailData(data)
	for i,v in ipairs(data or {}) do
		self.m_list_data[#self.m_list_data + 1] = v
	end
end

function M:getMailByIndex(index)
	return self.m_list_data[index]
end

-- 邮件已读状态设置
function M:setMailStatus(ids, status)
	for i,v in ipairs(ids) do 
		for ii,vv in ipairs(self.m_list_data) do
			if vv.id == v then
				vv.status = status
				break
			end
		end
	end
end

-- 邮件领取状态设置
function M:setMailReceived(ids)
	for i,v in ipairs(ids) do 
		for ii,vv in ipairs(self.m_list_data) do
			if vv.id == v then
				vv.is_received = true
				vv.status = 1
				break
			end
		end
	end
end

function M:deleteMail(ids)
	for i,v in ipairs(ids) do
		for m,n in ipairs(self.m_mail_ids) do
			if v == n then
				table.remove(self.m_mail_ids,m)
				break
			end
		end

		for m,n in ipairs(self.m_list_data) do
			if v == n.id then
				table.remove(self.m_list_data,m)
				break
			end
		end
	end
end

----------邮件内容------------------------------------------

function M:getContent()
	local mail = self:getMailByIndex(self.m_select_index)
	for k,v in pairs(mail.content) do
		return k,v
	end
end

return M
