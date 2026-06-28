local M = class("UnionMemberModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_data = self.m_params.data or {}
	self.m_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
	self.m_position = self:getPos(self.m_uid)
	self.m_target_uid = nil
	self.m_is_trans = false
end

function M:updateData(data)
	table.merge(self.m_data, data)
	self.m_position = self:getPos(self.m_uid)
end

function M:getListData()
	return self.m_data.players or {}
end

function M:getPresidentData()
	for i,v in ipairs(self:getListData()) do
		if v.uid == self.m_data.guild.president then
			return v
		end
	end
end

function M:getSelfUnionData()
	local self_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
	for i,v in ipairs(self:getListData()) do
		if self_uid == v.uid then
			return v
		end
	end
end

function M:getIsNPC(uid)
	for i,v in ipairs(self.m_data.guild.npc) do
		if v == uid then
			return true
		end
	end
	return false
end

---------------------------------------------------------------------------------
--- 成员管理

function M:setTargetMember(uid)
	if self.m_target_uid == uid then
		self.m_target_uid = nil
		return
	end
	self.m_target_uid = uid
	self.m_target_position = self:getPos(self.m_target_uid)
	self.m_handle_list = {}
	if GlobalConfig.UNION_POS_HANDLE[self.m_position] then
		self.m_handle_list = table.copy(GlobalConfig.UNION_POS_HANDLE[self.m_position][self.m_target_position] or {})
	end
	if self.m_uid == self.m_target_uid then --不能给自己拉黑名单、发邮件
		for i=#self.m_handle_list,1, -1 do
			if self.m_handle_list[i] == GlobalConfig.UNION_HANDLE_ID.BLACK or self.m_handle_list[i] == GlobalConfig.UNION_HANDLE_ID.SEND_MAIL then
				table.remove(self.m_handle_list, i)
			end
		end
	end
end

function M:getPos(uid)
	for i,v in ipairs(self:getListData()) do
		if v.uid == uid then
			return v.position
		end
	end
	return 0
end

function M:getMemberData()
	for i,v in ipairs(self:getListData()) do
		if v.uid == self.m_target_uid then
			return v
		end
	end
end

return M
