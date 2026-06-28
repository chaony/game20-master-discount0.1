local M = class("UnionHandleModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
 	self.m_guild = self.m_params.guild or {}
 	self.m_target_uid = self.m_params.target_uid
 	self.m_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
 	self.m_position = self:getPos(self.m_uid)
 	self.m_target_position = self:getPos(self.m_target_uid)
 	self.m_handle_list = GlobalConfig.UNION_POS_HANDLE[self.m_position][self.m_target_position] or {}
 	for i=#self.m_handle_list,1, -1 do
 		if self.m_handle_list[i] == GlobalConfig.UNION_HANDLE_ID.BLACK then
 			if self.m_uid == self.m_target_uid then
 				table.remove(self.m_handle_list, i)
 			end
 			break
 		end
 	end
end

function M:getPos(uid)
	for i,v in ipairs(self.m_guild.players) do
		if v.uid == uid then
			return v.position
		end
	end
	return 0
end

function M:getMemberData()
	for i,v in ipairs(self.m_guild.players) do
		if v.uid == self.m_target_uid then
			return v
		end
	end
end

function M:isNPC()
	for i,v in ipairs(self.m_guild.guild.npc) do
		if v == self.m_target_uid then
			return true
		end
	end
	return false
end

return M
