local M = class("FriendApplayPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "back_btn" then
        self:closeView()
    elseif msg == "tab_btn" then
        self.m_model:setTabIndex(data)
        if data == 1 then
            self:requestFriendData()
        elseif data == 2 then
            self.m_view:refreshUI()
        elseif data == 3 then
            self:requestBlackData()
        end
    elseif msg == "all_agree_btn" then
    	self:agreeAll()
    elseif msg == "all_ignore_btn" then
        self:ignoreAll()
    elseif msg == "find_btn" then
        self:requestSearchFriend()
    elseif msg == "send_apply_friend" then
        self:requestApplayFriend(data)
    elseif msg == "add_btn" then
        self:agreeOne(data)
    elseif msg == "remove_btn" then
        self:ignoreOne(data)
    elseif msg == "remove_black" then
        self:removeBlack(data)
    end
end

function M:agreeOne(index)
    -- Logger.log(index,"index ====")
    local data = self.m_model:getDataByIndex(index)
    if data == nil then return end
    local params = {}
    params.f_uid = data.uid
    local function callback(response)
        if response then
            self.m_model:setFriendsData(response)
            self.m_view:refreshUI()
            self:updateMsg("freshData", nil, "Friend")
        end
    end
    self.m_model:getNetData("friend_agree_friend", params, callback)
end

function M:agreeAll()
    if #self.m_model.m_friends > 0 then
    	local function callback(response)
            if response then
    	        self.m_model:setFriendsData(response)
    	        self.m_view:refreshUI()
                self:updateMsg("freshData", nil, "Friend")
    	    end
        end
        self.m_model:getNetData("friend_agree_friend_all", nil, callback)
    else
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("friend_str_0010"), delay_close = 2})
    end
end

function M:ignoreOne(index)
    local data = self.m_model:getDataByIndex(index)
    local params = {}
    params.f_uid = data.uid
    local function callback(response)
        if response then
            self.m_model:setFriendsData(response)
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("friend_refuse_friend", params, callback)
end

function M:ignoreAll()
    if #self.m_model.m_friends > 0 then
        local function callback(response)
            if response then
                self.m_model:setFriendsData(response)
                self.m_view:refreshUI()
            end
        end
        self.m_model:getNetData("friend_refuse_friend_all", nil, callback)
    else
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("friend_str_0010"), delay_close = 2})
    end
end

function M:requestFriendData()
    if self.m_model.m_friends == nil then
        local function callback(response)
            self.m_model:setFriendsData(response)
            self.m_view:refreshUI()
        end
        self.m_model:getNetData("friend_friend_apply_index", nil, callback)
    else
        self.m_view:refreshUI()
    end
end

function M:requestBlackData()
    if self.m_model.m_blackes == nil then
        local function callback(response)
            self.m_model:setBlackesData(response)
            self.m_view:refreshUI()
        end
        self.m_model:getNetData("friend_blacklist_index", nil, callback)
    else
        self.m_view:refreshUI()
    end
end

function M:removeBlack(index)
    local data = self.m_model:getDataByIndex(index)
    local params = {}
    params.f_uid = data.uid
    local function callback(response)
        if response then
            self.m_model:removeBlackesByIndex(index)
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("friend_delete_from_blacklist", params, callback)
end

function M:requestSearchFriend()
    local name = self.m_view:getSearchText()
    if name and name ~= "" then
        local params = {}
        params.name = name
        local function callback(response, tag, status_code)
            if response then
                if #response.user_info == 0 then
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("friend_str_0015"), delay_close = 2})
                end
                self.m_model:setSearchFriend(response)
                self.m_view:refreshUI()
            else
                if status_code == GlobalConfig.SENSITIVE_WORDS_CODE then
                    self.m_view:setSearchText("")
                end
            end
        end
        self.m_model:getNetData("friend_search_friend", params, callback, nil, true)
    end
end

function M:requestApplayFriend(index)
    local data = self.m_model:getDataByIndex(index)
    local params = {}
    params.f_uid = data.uid
    local function callback(response)
        if response then
            self.m_model:setSearchFriendApplyStatus(index)
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("friend_apply_friend", params, callback)
end

return M;
