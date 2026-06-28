local M = class("HalfAnniversaryGroupingSharePop",LikeOO.OOControlBase)

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
        QuickOpenFuncUtil:openFunc(11, {type = 1, invite_callback = handler(self,self.friendInviteCallback)})
    elseif msg == "out_btn" then
        self:openView("HalfAnniversary.HalfAnniversaryGroupingSharePicture")
    end
end

function M:getChatData()
    local ext_params = {}
    ext_params.invite_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
    ext_params.create_time = self.m_model.m_params.create_time
    ext_params.group_id = self.m_model.m_params.group_id
    ext_params.version = self.m_model.m_params.version
    local send_data = {
        uid = UserDataManager.user_data:getUserStatusDataByKey("uid"),
        name = UserDataManager.user_data:getUserStatusDataByKey("name"),
        avatar = tostring(UserDataManager.user_data:getUserStatusDataByKey("avatar")),
        frame = tostring(UserDataManager.user_data:getUserStatusDataByKey("frame")),
        title = UserDataManager.user_data:getUserStatusDataByKey("title"),
        msg = Language:getTextByKey("gift_group_text_0020"),
        event = 3,
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
    if msgs and msgs.event and msgs.event == 3 and curPlayerId == msgs.uid then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gift_group_text_0019"), delay_close = 2})
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CHAT_REFRESH, {self, self.onRefreshChatInfo})
    M.super.destroy(self)
end

return M;
