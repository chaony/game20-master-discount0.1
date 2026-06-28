---@class PlayerInfoControl:OOControlBase
local M = class("PlayerInfoControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif type(msg) == "number" and msg >= 1 and msg <= 3 then
        self:switchTabBtn(msg)
    elseif msg == "add_blacklist_btn" then -- 添加黑名单
        if self.m_model.m_data.user.is_black == 0 then
            self:friendAddToBlacklist()
        else
            self:removeFromBlacklist()
        end
    elseif msg == "add_firend_btn" then -- 添加好友
        self:friendApplyFriend()
    elseif msg == "rem_firend_btn" then -- 删除好友
        self:friendRemoveFriend()
    elseif msg == "send_msg_btn" then -- 发送信息
        local data = self.m_model:getDataByIndex(self.m_model.m_params.index)
        local friend_id = data.user.uid
        local friend_name = data.user.name
        local avatar = data.user.avatar
        if static_rootControl:hasChild("Chat2") == true then
            self:closeView()
            self:updateMsg("open_friend", {['id'] = friend_id, ['name'] = friend_name, ['avatar'] = avatar}, "Chat2")
        else
            static_rootControl:closeAllViewPop()
            SceneManager:changeScene(SceneManager.SceneID.HangUpScene)
            self:openView("Chat2", {['id'] = friend_id, ['name'] = friend_name, ['avatar'] = avatar})
        end
    elseif msg == "look_hero" then
        --self:openView("HeroInfo", {player_data = data.data, look_model = 1, oid = data.oid})
        self:openView("HeroBag", {player_data = data.data, mode = 3, oid = data.oid, sig = data.sig})
    elseif msg == "union_handle_btn" then
        self:openView("Union.UnionHandlePop", {target_uid = self.m_model.m_uid, guild = self.m_model.m_guild_data})
    elseif msg == "unmaster_btn" then   
        self:unmaster()
    elseif msg == "unmaster_btn2" then   
        self:revokeUnmaster()
    elseif msg == "copy_uid_btn" then
        local data = self.m_model:getDataByIndex()
        if data and data.user then
            CS.UnityEngine.GUIUtility.systemCopyBuffer = data.user.name or ""
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0698"), delay_close = 2})
        else
            CS.UnityEngine.GUIUtility.systemCopyBuffer = ""
        end
    elseif msg == "report_btn" then -- 举报
        local data = self.m_model:getDataByIndex()
        local user = data.user or {}
        local params = {}
        params.uid = user.uid
        params.name = user.name or ""
        params.module_id = 1
        self:openView("Pops.ReportPop", params)
    elseif msg == "btn_flowerBtn" then
        local curPlayerId = UserDataManager.user_data:getUserStatusDataByKey("uid")
        if self.m_model.m_data.user.uid == curPlayerId then
            local activityData = UserDataManager:getActivesDataByOpenId(289)
            if not activityData then
                return
            end
            self:openView("FlowerFestival.FlowerGiveRank",{version = activityData.version})
        else
            -- 赠送
            self:openView("FlowerFestival.FlowerGivePop", {playerId = self.m_model.m_data.user.uid, existFlowerCount = self.m_model.m_data.user.flower})
        end
    elseif msg == "refresh_flowerEvent" then
        self.m_model:getNetData("user_user_detail_info", {target_uid = data.playerId}, function(response)
            if response then
                self.m_model:initData(response)
                if self.m_view.m_cur_tab_node and self.m_view.m_cur_tab_node.showFlowerNode then
                    self.m_view.m_cur_tab_node:showFlowerNode()
                end
            end
        end, nil, nil, nil)
    end
end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        if self.m_model:getDataByIndex(index) then
            self.m_view:switchTabNode(index)
            self.m_model.m_sel_tab_index = index
        else
            -- local tab_btn_node = self.m_model:getTabBtnNode()
            -- local btn_tab = tab_btn_node[index]
            -- local function netCallback(response)
            --     if response and self.m_model then
                    -- self.m_model:initData(response, index)
                    self.m_view:switchTabNode(index)
                    self.m_model.m_sel_tab_index = index
                -- end
            -- end
            -- local params = {[btn_tab.param_key] = self.m_model.m_uid, team_sort = "local_arena_defense"}
            -- self.m_model:getNetData("user_user_detail_info", params, netCallback)
        end
    end
end

--申请好友 f_uid: 好友uid
function M:friendApplyFriend()
    local function netCallback(response)
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0116"), delay_close = 2})
    end
    local uid = self.m_model.m_uid
    self.m_model:getNetData("friend_apply_friend", {f_uid = uid, apply_type=3}, netCallback)
end

--删除好友 f_uid: 好友uid
function M:friendRemoveFriend()
    local function netCallback(response)
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0139"), delay_close = 2})
        self:updateMsg("freshData", nil, self.m_model.m_parent_view)
        self:updateMsg("refresh_data", self.m_model.m_uid, "Chat2")
        self:updateMsg(99999)
    end
    
    local data = self.m_model:getDataByIndex()
    local params =
    {
        on_ok_call = function(msg)
            local uid = self.m_model.m_uid
            self.m_model:getNetData("friend_remove_friend", {f_uid = uid}, netCallback)
        end,
        no_close_btn = false,
        text = string.format(Language:getTextByKey("friend_str_0040"), data.user.name)
    }
    static_rootControl:openView("Pops.CommonPop", params)
end

--添加到黑名单 f_uid: 好友uid
function M:friendAddToBlacklist()
    local function netCallback(response)
        Logger.logError(self.m_model.m_uid)
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0115"), delay_close = 2})
        self:updateMsg("freshData", nil, self.m_model.m_parent_view)
        self:updateMsg("refresh_data", self.m_model.m_uid, "Chat2")
        self:updateMsg(99999)
    end
    local params =
    {
        on_ok_call = function(msg)
            local uid = self.m_model.m_uid
            self.m_model:getNetData("friend_add_to_blacklist", {f_uid = uid}, netCallback)
        end,
        no_close_btn = false,
        text = Language:getTextByKey("friend_str_0021")
    }
    static_rootControl:openView("Pops.CommonPop", params)
end

--删除黑名单 f_uid: 好友uid
function M:removeFromBlacklist()
    local function netCallback(response)
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0307"), delay_close = 2})
        self:updateMsg("freshData", nil, self.m_model.m_parent_view)
        self:updateMsg("refresh_data", self.m_model.m_uid, "Chat2")
        self:updateMsg(99999)
    end
    local params =
    {
        on_ok_call = function(msg)
            local uid = self.m_model.m_uid
            self.m_model:getNetData("friend_delete_from_blacklist", {f_uid = uid}, netCallback)
        end,
        no_close_btn = false,
        text = Language:getTextByKey("new_str_0308")
    }
    static_rootControl:openView("Pops.CommonPop", params)
end

--解除师徒关系
function M:unmaster()
    local function netCallback(response)
        self:updateMsg("freshData", nil, self.m_model.m_parent_view)
        self:updateMsg(99999)
    end
    local uid = self.m_model.m_uid
    if self.m_model.m_status == 1 then 
        self.m_model:getNetData("mentorship_relieve_mentor", nil, netCallback)
    elseif self.m_model.m_status == 2 then   
        self.m_model:getNetData("mentorship_relieve_pupil", {pupil_uid = uid}, netCallback)
    end
end

--取消解除师徒关系
function M:revokeUnmaster()
    local function netCallback(response)
        self:updateMsg("freshData", nil, self.m_model.m_parent_view)
        self:updateMsg(99999)
    end
    local uid = self.m_model.m_uid
    if self.m_model.m_status == 1 then 
        self.m_model:getNetData("revoke_relieve_mentor", nil, netCallback)
    elseif self.m_model.m_status == 2 then   
        self.m_model:getNetData("revoke_relieve_pupil", {pupil_uid = uid}, netCallback)
    end
end


return M
