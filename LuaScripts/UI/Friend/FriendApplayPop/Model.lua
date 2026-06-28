local M = class("FriendApplayPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("friend_friend_apply_index")
end

function M:onEnter()
	self.m_tab_index = 1
	self.m_friend_num = 0
	self.m_apply_msg_num = 0
	self.m_list_num = 0

	self.m_friends = nil
	self.m_blackes = nil
	self:setFriendsData(self.m_data)
end

function M:setTabIndex(index)
	self.m_tab_index = index
end

function M:getDataByIndex(index)
	-- Logger.log(self.m_tab_index,"m_tab_index ===")
	if self.m_tab_index == 1 then
		return self.m_friends[index]
	elseif self.m_tab_index == 2 then
		return self.m_searchFriend[index]
	elseif self.m_tab_index == 3 then
		return self.m_blackes[index]
	end
end

function M:getListNum()
	if self.m_tab_index == 1 then
		return self.m_apply_list_num, self.m_friends
	elseif self.m_tab_index == 2 then
		return self.m_search_list_num, self.m_searchFriend
	elseif self.m_tab_index == 3 then
		return self.m_black_list_num, self.m_blackes
	end
end

function M:setFriendsData(data)
	self.m_friends = data.messages or {}
	self.m_friend_num = data.friends_num or 0
	self.m_apply_msg_num = #self.m_friends or 0
	self.m_apply_list_num = self.m_apply_msg_num
end

function M:setSearchFriend(data)
	self.m_searchFriend = data.user_info
	self.m_search_list_num = #self.m_searchFriend
end

function M:setSearchFriendApplyStatus(index)
	if self.m_searchFriend[index] then
		self.m_searchFriend[index].is_applied = 1
	end
end

function M:setBlackesData(data)
	self.m_blackes = data.blacklist_infos
	self.m_black_list_num = #self.m_blackes
end

function M:removeBlackesByIndex(index)
	table.remove(self.m_blackes, index)
	self.m_black_list_num = #self.m_blackes
end

return M
