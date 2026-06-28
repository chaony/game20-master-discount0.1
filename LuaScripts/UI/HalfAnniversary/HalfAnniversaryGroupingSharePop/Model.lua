local M = class("HalfAnniversaryGroupingSharePopModel", LikeOO.OODataBase)

local __CHAT_CHANNEL = {LOCAL = 1,WORLD = 2,GUILD = 3,PRIVATE = 4}

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()

end

function M:sortNewChatMsg(private_msg, other_msg)
	local sort_tab = {} -- 
	if other_msg and next(other_msg) then
		for i = #other_msg - 1, #other_msg do
			if other_msg[i] then
				sort_tab[#sort_tab + 1] = {msg_time = other_msg[i].time, msg_index = i, is_private = false}
			end
		end
	end
	if private_msg and next(private_msg) then
		for i = #private_msg - 1, #private_msg do
			if private_msg[i] then
				sort_tab[#sort_tab + 1] = {msg_time = private_msg[i].time, msg_index = i, is_private = true}
			end
		end
	end
	table.sort(sort_tab, function(a, b)
		return a.msg_time < b.msg_time
	end)
	return sort_tab
end

function M:getChatMsgByChannel(channel_id)
	if channel_id == nil then
		return
	end
	local other_msg, private_msg = {}, {}
	if channel_id == __CHAT_CHANNEL.PRIVATE then
		private_msg = ChatUtil:getLatestPrivateMsg(channel_id)

	else
		other_msg = ChatUtil:getChannelMsg(channel_id)
		private_msg =  ChatUtil:getLatestPrivateMsg()
	end

	local last_msg = {}
	local sort_tab = self:sortNewChatMsg(private_msg, other_msg)
	for i = #sort_tab - 1, #sort_tab do
		if sort_tab[i] and next(sort_tab) then
			local msg = sort_tab[i].is_private and private_msg[sort_tab[i].msg_index] or other_msg[sort_tab[i].msg_index]
			last_msg = msg
		end
	end

	return last_msg
end

return M
