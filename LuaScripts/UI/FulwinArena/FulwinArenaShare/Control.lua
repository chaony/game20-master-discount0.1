local M = class("FulwinArenaShareControl",LikeOO.OOControlBase)

function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CHAT_REFRESH, {self, self.onRefreshChatInfo})
end

function M:onHandle(msg, data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "world_chat_btn" then
        self:shareToChat(2)
    elseif msg == "union_chat_btn" then
        self:shareToChat(3)
    elseif msg == "friend_chat_btn" then
        QuickOpenFuncUtil:openFunc(11, {type = 1,offline_invite = 0, invite_callback = handler(self,self.friendInviteCallback)})
    elseif msg == "local_btn" then
        self:shareToChat(1)
    end
end

function M:getChatData()
    local ext_params = {}
    ext_params.typ = self.m_model.m_params.typ
    ext_params.ring_id = self.m_model.m_params.ring_id
    ext_params.send_time = UserDataManager:getServerTime()
    local msg_text = ""
    if self.m_model.m_params.typ == 1 then
        msg_text = Language:getTextByKey("fylt_str_0020")
    else
        msg_text = Language:getTextByKey("fylt_str_0021")
    end
    local send_data = {
        uid = UserDataManager.user_data:getUserStatusDataByKey("uid"),
        name = UserDataManager.user_data:getUserStatusDataByKey("name"),
        avatar = tostring(UserDataManager.user_data:getUserStatusDataByKey("avatar")),
        frame = tostring(UserDataManager.user_data:getUserStatusDataByKey("frame")),
        title = UserDataManager.user_data:getUserStatusDataByKey("title"),
        msg = msg_text,
        event = 2,
        event_ext = Json.encode(ext_params),
    }
    return send_data
end

function M:shareToChat(channel_type)
    local send_data = self:getChatData()
    send_data.channel_type = tostring(channel_type)
    self.channel_type = channel_type
    ChatUtil:sendMsg(send_data,2)
end

function M:friendInviteCallback(data)
    self.channel_type = 4
    local send_data = self:getChatData()
    send_data.channel_type = "4"
    send_data.target_name = data.name
    send_data.channel_id = tostring(data.f_uid)
    ChatUtil:sendMsg(send_data,2)
end

function M:onRefreshChatInfo()
    local msgs = self.m_model:getChatMsgByChannel(self.channel_type)
    local curPlayerId = UserDataManager.user_data:getUserStatusDataByKey("uid") or 0
    -- 当前玩家才能看到提示
    self.channel_type = nil
    if msgs and msgs.event and msgs.event == 2 and curPlayerId == msgs.uid then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("fylt_str_0096"), delay_close = 2})
    end
    self:closeView()
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CHAT_REFRESH, {self, self.onRefreshChatInfo})
    M.super.destroy(self)
end

return M;
