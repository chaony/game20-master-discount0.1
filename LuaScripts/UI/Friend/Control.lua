local M = class("FriendPopControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("common_refresh", nil, "parent") 
        self:updateMsg("refresh_red_point", nil, "parent") 
        self:closeView()
    elseif msg == "back_btn" then
        self:updateMsg("common_refresh", nil, "parent") 
        self:closeView()
    elseif msg == "tab_btn" then
        if data == 5 then --游戏内公告
            self:openView("Notice.InGameNoticePop")
            self:closeView()
        end
        if data ~= self.m_model.m_tab_index then
            self.m_model:setTabIndex(data)
            local is_have_data = self.m_model:isHaveData()
            self.m_view:AddChildPanel()
            if is_have_data then
                self.m_view:refreshUI()
            else
                self:freshBaseData()
            end
        end
    elseif msg == "friend_tab_btn" then
        if data ~= self.m_model.m_friend_tab_index then
            if data == 2 then
            	-- if self.m_model.m_apply_data then
                --     self.m_view:switchFriendTab(data)
                -- else
                --     self:requestApplyBaseInfo(function ()
                --         self.m_view:switchFriendTab(data)
                --     end)
                -- end 
                self:requestApplyBaseInfo(function ()
                    self.m_view:switchFriendTab(data)
                end) 
            elseif data == 3 then    
                self:requestRecommendData(function ()
                    self.m_view:switchFriendTab(data)
                end) 
            elseif data == 4 then
                -- if self.m_model.m_blackes then
                --     self.m_view:switchFriendTab(data)
                -- else
                --     self:requestBlackData(function ()
                --         self.m_view:switchFriendTab(data)
                --     end)   
                -- end
                self:requestBlackData(function ()
                    self.m_view:switchFriendTab(data)
                end)  
            else
                self.m_view:switchFriendTab(data)
            end
        end
    elseif msg == "freshData" then
        self:freshBaseData()
    elseif msg == "refresh_ui" then
        self.m_view:refreshUI()
    elseif msg == "give_back" then
        self:freshBaseData()
    elseif msg == "applay_mercenary" then
        self.m_model:setHeroApplayed(data)
        self.m_view:refreshUI()
    elseif msg == "martial_tab" then
        self.m_model:setMercenaryRace(data)
        self.m_view:refreshUI()
    elseif msg == "masterFreshData" then
        self:masterfreshBaseData(data)
    elseif msg == "receive_mail" then
        self.m_model:setMailReceived(data)
        self.m_view:refreshUI()
    elseif msg == "load_mail" then
        self:requestMailLoadInfo()
    elseif msg == "add_btn" then
        self:agreeOne(data)
    elseif msg == "remove_btn" then
        self:ignoreOne(data)
    elseif msg == "remove_black" then
        self:removeBlack(data)
    elseif msg == "all_agree_btn" then
    	self:agreeAll()
    elseif msg == "all_ignore_btn" then
        self:ignoreAll()
    elseif msg == "find_btn" then
        self:requestSearchFriend()
    elseif msg == "send_apply_friend" then
        self:requestApplayFriend(data)
    elseif msg == "remove_black" then
        self:removeBlack(data)
    elseif msg == "change_btn" then
        self:requestRecommendData(function ()
            self.m_view:switchFriendTab(3)
        end)
    elseif msg == "all_apply_btn" then
        self:requestApplayAllFriend()
    end
end

function M:freshBaseData()
    if self.m_model.m_tab_index == 1 then
        self:requestFriendBaseInfo()
    elseif self.m_model.m_tab_index == 2 then 
        self:requestMercenaryBaseInfo()
    elseif self.m_model.m_tab_index == 3 then 
        self:requestMasterApprenticeBaseInfo()
    elseif self.m_model.m_tab_index == 4 then
        self:requestMailBaseInfo()
    end
end

function M:requestFriendBaseInfo()
    local function callback(response)
        self.m_model:setFriendsData(response)
        --self.m_view:AddChildPanel()
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("friend_friends_basic_info", nil, callback)
end

function M:requestSendGift(index)
    local data = self.m_model:getFriendDataByIndex(index)
    local params = {}
    params.f_uid = data.uid
    local function callback(response)
        self.m_model:setFriendsData(response)
        self.m_view:refreshUI()
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("friend_str_0022"), delay_close = 2})
    end
    self.m_model:getNetData("friend_send_friend_gift", params, callback)
end

function M:requestReceiveGift(index)
    local data = self.m_model:getFriendDataByIndex(index)
    local params = {}
    params.f_uid = data.uid
    local function callback(response)
        self.m_model:setFriendsData(response)
        self.m_view:refreshUI()
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("friend_str_0023"), delay_close = 2})
    end
    self.m_model:getNetData("friend_receive_friend_gift", params, callback)
end

function M:requestInviteFriend(index)
    if self.m_model.m_invite_callback then
        local data = self.m_model:getFriendDataByIndex(index)
        local params = {}
        params.f_uid = data.uid
        params.f_name = data.name
        --GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("castingSword_str_0026", tostring(data.uid)), delay_close = 2})
        self.m_model.m_invite_callback(params)
        self:closeView()
    end
end

function M:requestInviteFriendCheer(index) --登仙楼 助威
    if self.m_model.m_cheer_callback then
        local data = self.m_model:getFriendDataByIndex(index)
        local params = {}
        params.f_uid = data.uid
        params.f_name = data.name
        self.m_model.m_cheer_callback(params)
        self:closeView()
    end
end


function M:requestOneKeyGift()
    local function callback(response)
        if response.is_changed == 1 then
            self.m_model:setFriendsData(response)
            self.m_view:refreshUI()
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("friend_str_0019"), delay_close = 2})
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("friend_str_0020"), delay_close = 2})
        end
    end
    self.m_model:getNetData("friend_auto_send_receive_gift", nil, callback)
end

------------------------------------------------------------------------------------

function M:requestMercenaryBaseInfo()
    local function callback(response)
        self.m_model:setMercenaryData(response)
        --self.m_view:AddChildPanel()
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("apostle_index", nil, callback)
end

function M:requestApplyBaseInfo(cb)
    local function callback(response)
        self.m_model:setApplyData(response)
        if cb then
            cb()
        end
    end
    self.m_model:getNetData("friend_friend_apply_index", nil, callback)
end

function M:requestBlackData(cb)
    local function callback(response)
        self.m_model:setBlackesData(response)
        if cb then
            cb()
        end
    end
    self.m_model:getNetData("friend_blacklist_index", nil, callback)
    -- if self.m_model.m_blackes == nil then
      
    -- else
    --     self.m_view:refreshUI()
    -- end
end

function M:requestRecommendData(cb)
    local function callback(response)
        self.m_model:setRecommendFriendData(response)
        if cb then
            cb()
        end
    end
    self.m_model:getNetData("recommend_friend", nil, callback)
end

------------------------------------------------------------------------------------

function M:requestMasterApprenticeBaseInfo(data)
    local function callback(response)
        self.m_model:setMasterApprenticeData(response)
        self.m_view:AddChildPanel()
        self.m_view:refreshUI()
        if data then 
            if data.sort == 1 or data.sort == 2 then --1/2 拜师/收徒申请  3 解除关系
                local info = nil
                if self.m_model.m_master_status == 1 then
                    info = self.m_model.m_mastet_data
                else
                    info = self.m_model:getApprenById(data.uid)
                end
                self:openView("Pops.SuccessFromMasterPop", {status = self.m_model.m_master_status , info = info}) 
            end 
        end
    end
    self.m_model:getNetData("mentorship_index", nil, callback)
end

function M:masterfreshBaseData(data)
    --[[self.m_model:setMasterApprenticeData(data)
    self.m_view:AddChildPanel()
    self.m_view:refreshUI()]]
    self:requestMasterApprenticeBaseInfo(data)
end

function M:requestMasterApostle(data)
    local function callback(response)
        self.m_model.m_appostle = response.apostle
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("mentorship_doing_mentorship_apostle", {hero_oids = data }, callback, nil, nil, GlobalConfig.POST)
end

-------------邮件---------------------------------------------
function M:requestMailBaseInfo()
    self.m_model:mailOnEnter()
    local function callback(response)
        self.m_model:setMailData(response)
        --self.m_view:AddChildPanel()
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("mail_index" , {mail_ids = {}}, callback, nil, nil, GlobalConfig.POST )
end

function M:requestMailLoadInfo()
    local function callback(response)
        self.m_mail_load = true
        self.m_model:setMailData(response)
        self.m_view:refreshUI()
    end
    local load_mails = self.m_model:getLoadMail()
    if #self.m_model.m_mail_ids > 0 and #load_mails == 0 then
        return
    end
    self.m_model:getNetData("mail_index" , {mail_ids = load_mails}, callback, nil, nil, GlobalConfig.POST )
end

function M:openMail(index)
    local data = self.m_model:getMailByIndex(index)
    if data then
        if data.status == 0 then
            local params = {}
            params.mail_id = data.id
            local function readCallback(response)
                if response then
                    self.m_model:setMailStatus(response.mail_ids, 1)
                    self.m_model:setSelectIndex(index)
                    self.m_view:refreshUI()
                    --self:openView("Mail.MailDetail", data)
                end
            end
            self.m_model:getNetData("mail_read", params, readCallback)
        else
            -- self.m_model:setSelectIndex(index)
            -- self.m_view:refreshUI()
            --  self:openView("Mail.MailDetail", data)
        end
    end
end

function M:receiveAllMail()
    local function receiveCallback(response)
        if response then
            Logger.log(response,"receiveCallback response =====")
            if next(response.reward) ~= nil then
                self.m_model:setMailReceived(response.mail_ids)
                self.m_view:refreshUI()
                RewardUtil:rewardTipsByData(response.reward)
            else
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("mail_str_0007"), delay_close = 2})
            end
        end
    end
    if self.m_model then
        self.m_model:getNetData("mail_receive_all", nil, receiveCallback)
    end
end

function M:deleteAllMail()
    local function deleteCallback(response)
        if response then
            self.m_model:deleteMail(response.mail_ids)
            self.m_view:refreshUI()
        end
    end
    if self.m_model then
        self.m_model:getNetData("mail_delete_all", nil, deleteCallback)
    end
end

function M:receiveMail(data)
    local params = {}
    params.mail_id = data
    local function receiveCallback(response)
        if response then 
            local reward = response.reward or {}
            RewardUtil:rewardTipsByData(reward)
            self:updateMsg("receive_mail", response.mail_ids)
        end
    end
    self.m_model:getNetData("mail_receive", params, receiveCallback)
end

-------------------7341264--------------------------------------------------------------------------
function M:agreeOne(index)
    local data = self.m_model:getDataByIndex(index)
    if data == nil then return end
    local params = {}
    params.f_uid = data.uid
    if self.m_model:checkIsFriends(data.uid) == true then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("friend_str_0045"), delay_close = 2})
        self:ignoreOne(index)
        return 
    end
    local function callback(response)
        if response then
            self.m_model:setApplysData(response)
            self:freshBaseData()
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("friend_agree_friend", params, callback)
end

function M:ignoreOne(index)
    local data = self.m_model:getDataByIndex(index)
    local params = {}
    params.f_uid = data.uid
    local function callback(response)
        if response then
            self.m_model:setApplysData(response)
            self:freshBaseData()
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("friend_refuse_friend", params, callback)
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

function M:agreeAll()
    if #self.m_model.m_friends > 0 then
    	local function callback(response)
            if response then
                if response.target_full and response.target_full == 1 then
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("friend_str_0046"), delay_close = 2})
                end
    	        self.m_model:setApplysData(response)
                self:freshBaseData()
                self.m_view:refreshUI()
    	    end
        end
        self.m_model:getNetData("friend_agree_friend_all", nil, callback)
    else
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("friend_str_0010"), delay_close = 2})
    end
end

function M:ignoreAll()
    if #self.m_model.m_friends > 0 then
        local function callback(response)
            if response then
                self.m_model:setApplysData(response)
                self:freshBaseData()
                self.m_view:refreshUI()
            end
        end
        self.m_model:getNetData("friend_refuse_friend_all", nil, callback)
    else
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("friend_str_0010"), delay_close = 2})
    end
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
    if self.m_model.m_search_bl == true then
        params.apply_type = 1
    else
        params.apply_type = 2 
    end
    local function callback(response)
        if response then
            self.m_model:setSearchFriendApplyStatus(index)
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("friend_apply_friend", params, callback)
end

function M:requestApplayAllFriend()
    local recommend_data = self.m_model.m_recommend
    local data = {}
    for k,v in pairs(recommend_data) do
        table.insert( data, v.uid)
    end
    if next(data) == nil then
        return
    end
    local params = {}
    params.f_uid_list = data
    params.apply_type = 2
    local function callback(response)
        if response then
            self.m_model:updateAllRecommendFriendStatus()
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("friend_apply_friend", params, callback)
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

return M;
