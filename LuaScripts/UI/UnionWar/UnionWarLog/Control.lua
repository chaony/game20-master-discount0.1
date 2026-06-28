local M = class("UnionWarLogControl",LikeOO.OOControlBase)

function M:onEnter()
    self.clickTime = 0;
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "check_tag" then
        self:switchTabBtn(data)
    elseif msg == "play_btn" then
        self:requestVideo(data.cell_data.battle_log_id)
    elseif msg == "good1" then
        self:goodUser();
    elseif msg == "lan1" then
        local m_data = self.m_view.labelData[1]
        if m_data ~= nil then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey(m_data.text), delay_close = 2})
        end
    elseif msg == "lan2" then
        local m_data = self.m_view.labelData[2]
        if m_data ~= nil then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey(m_data.text), delay_close = 2})
        end
    elseif msg == "lan3" then
        local m_data = self.m_view.labelData[3]
        if m_data ~= nil then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey(m_data.text), delay_close = 2})
        end
    elseif msg == "my_btn" then
        self.m_model.showIndex = 1;
        self.m_model.log_type = 1;
        if self.m_model.log_type_sub == 0 then --我方战报，我的战报状态切换
            self.m_model.log_type_sub = 1
        else
            self.m_model.log_type_sub = 0
        end
        self:refreshLog()
    elseif msg == "all_btn" then
        self.m_model.showIndex = 2;
        self.m_model.log_type = 2;
        self:refreshLog()
    elseif msg == "cell_btn" then
        self:openView("Pops.PlayerInfo", {uid = data.data.uid, guild = self.m_model.m_active_data, look_model = 3})
    elseif msg == "handle_point_btn" then
        self.m_model:setTargetMemberActive(data.data.uid)
        self.m_view:refreshUI()
        self.m_view.m_active_list_scroll:moveToCellIndex(data.index)
    elseif msg == "handle_btn" then
        self:memberHandleActive(data)
    elseif msg == "update_data" then
        self.m_model:updateDataActive(data)
        local uid = self.m_model.m_active_target_uid
        self.m_model.m_active_target_uid = nil
        if not(self.m_model.m_active_is_trans) then
            self.m_model:setTargetMemberActive(uid)
        end
        self.m_view:refreshUI()
    end
end

function M:refreshLog()
    if #self.m_model:getLogData() > 0 then
        self.m_view:refreshUI()
    else
        self.m_model:getBattleData(function()
            self.m_view:refreshUI()
        end)
    end
end

--点赞
function M:goodUser()
    --点赞
    self.m_model:getNetData("gvg_report_like", nil, function(data)
        RewardUtil:rewardTipsByData(data.reward, nil, function()
        end, {allDouble = false})
        self.m_model:setLikeCount(data.like)
        self.m_view:updateLike(data);
    end)
end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        if index == 2 then
            if #self.m_model:getLogData() > 0 then
                self.m_view:switchNode(index)
            else
                local function battleDatacallback(response)
                    self.m_view:switchNode(index)
                end
                self.m_model:getBattleData(battleDatacallback)
            end
        else
            self.m_view:switchNode(index)
        end
    end
end

function M:requestVideo(battle_log_id)
    self:openView("Pops.BattleStatistics",  {mode = self.m_model.m_mode, battle_id = battle_log_id, round = 1})
end

--- 成员管理

function M:memberHandleActive(data)
    local member = self.m_model:getMemberDataActive()
    if data == GlobalConfig.UNION_HANDLE_ID.PROMOTE_ELDER  then
        local guild = ConfigManager:getCfgByName("guild")
        local guild_cfg = guild[self.m_model.m_active_data.guild.level]
        local have = guild_cfg.elder - #self.m_model.m_active_data.guild.elders
        if have <= 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_1064"), delay_close = 2})
            return
        end

        local params =
        {
            on_ok_call = function(msg)
                self:promoteElderActive()
            end,
            no_close_btn = false,
            text = string.format(Language:getTextByKey("union_str_1059"), member.name)
        }
        static_rootControl:openView("Pops.CommonPop", params)
    elseif data == GlobalConfig.UNION_HANDLE_ID.CHANGE_ELITE then
        local flag = self.m_model:getIsNPCActive(self.m_model.m_active_target_uid)
        local text = string.format(Language:getTextByKey("union_str_1060"), member.name)
        local guild = ConfigManager:getCfgByName("guild")
        local guild_cfg = guild[self.m_model.m_active_data.guild.level]
        if flag then
            --local server_time = UserDataManager:getServerTime()
            --local time = self.m_model.m_data.guild.weekly_etime - server_time
            --if time <= 0 then
            --	return
            --end
            --local str_time = GameUtil:formatTimeBySecond2(time)
            --local have = guild_cfg.npc - self.m_model.m_data.guild.npc_lock - #self.m_model.m_data.guild.npc
            --have = have > 0 and have or 0
            --text = string.format(Language:getTextByKey("union_str_1061"), str_time, have)
            text = Language:getTextByKey("union_str_1069", member.name)
        else
            local have = guild_cfg.npc - self.m_model.m_active_data.guild.npc_lock - #self.m_model.m_active_data.guild.npc
            if have <= 0 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_1063"), delay_close = 2})
                return
            end
        end
        local params =
        {
            on_ok_call = function(msg)
                self:changeEliteActive()
            end,
            no_close_btn = false,
            text = text
        }
        static_rootControl:openView("Pops.CommonPop", params)
    elseif data == GlobalConfig.UNION_HANDLE_ID.DEMOTE then
        local params =
        {
            on_ok_call = function(msg)
                self:demoteActive()
            end,
            no_close_btn = false,
            text = string.format(Language:getTextByKey("union_str_1062"), member.name)
        }
        static_rootControl:openView("Pops.CommonPop", params)
    elseif data == GlobalConfig.UNION_HANDLE_ID.DELETE then
        local params =
        {
            on_ok_call = function(msg)
                self:deleteMemberActive()
            end,
            no_close_btn = false,
            text = string.format(Language:getTextByKey("union_str_1058"), member.name)
        }
        static_rootControl:openView("Pops.CommonPop", params)
    elseif data == GlobalConfig.UNION_HANDLE_ID.BLACK then
        local params =
        {
            on_ok_call = function(msg)
                self:blackActive()
            end,
            no_close_btn = false,
            text = Language:getTextByKey("friend_str_0021")
        }
        static_rootControl:openView("Pops.CommonPop", params)
    elseif data == GlobalConfig.UNION_HANDLE_ID.ABDICATE then
        local params =
        {
            on_ok_call = function(msg)
                self:abdicateOwnerActive()
            end,
            no_close_btn = false,
            text = string.format(Language:getTextByKey("union_str_1071"), member.name)
        }
        static_rootControl:openView("Pops.CommonPop", params)
    elseif data == GlobalConfig.UNION_HANDLE_ID.SEND_MAIL then
        local params =
        {
            on_ok_call = function(msg)
                self:sendMailActive()
            end,
            no_close_btn = false,
            text = string.format(Language:getTextByKey("union_str_1075"), member.name)
        }
        static_rootControl:openView("Pops.CommonPop", params)
    end
end

-- 刷新成员列表
function M:refreshMemberActive()
    local function refreshMemberRequest(response)
        self:updateMsg("update_data", response, "Union.UnionMain")
        self:updateMsg("update_data", response)
    end
    local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
    local params = {guild_id = guild_id}
    self.m_model:getNetData("guild_guild_members", params, refreshMemberRequest)
end
-- 提升为长老
function M:promoteElderActive()
    local function promoteElderRequest(response)
        self:updateMsg("update_data", response, "Union.UnionMain")
        self:updateMsg("update_data", response)
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0023"), delay_close = 2})
    end
    local params = {}
    params.member = self.m_model.m_active_target_uid
    self.m_model:getNetData("guild_promote_elder", params, promoteElderRequest)
end
-- 转让帮主
function M:abdicateOwnerActive()
    local function abdicateOwnerRequest(response)
        if response then
            self:updateMsg("update_data", response, "Union.UnionMain")
            self.m_model.m_active_is_trans = true
            self:updateMsg("update_data", response)
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0023"), delay_close = 2})
        else
            self:refreshMemberActive()
        end
    end
    local params = {}
    params.member = self.m_model.m_active_target_uid
    self.m_model:getNetData("guild_guild_transfer", params, abdicateOwnerRequest, false, true)
end
-- 设置无谓之手
function M:changeEliteActive()
    local function changeEliteRequest(response)
        self:updateMsg("update_data", response, "Union.UnionMain")
        self:updateMsg("update_data", response)
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0023"), delay_close = 2})
    end
    local params = {}
    params.member = self.m_model.m_active_target_uid
    self.m_model:getNetData("guild_change_npc", params, changeEliteRequest)
end

-- 撤职
function M:demoteActive()
    local function demoteRequest(response)
        self:updateMsg("update_data", response, "Union.UnionMain")
        self:updateMsg("update_data", response)
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0023"), delay_close = 2})
    end
    local params = {}
    params.member = self.m_model.m_active_target_uid
    self.m_model:getNetData("guild_demote_member", params, demoteRequest)
end

-- 踢出公会
function M:deleteMemberActive()
    local function kickRequest(response)
        self:updateMsg("update_data", response, "Union.UnionMain")
        --self:updateMsg("update_data", response, "Union.UnionHall")
        self:updateMsg("update_data", response)
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0023"), delay_close = 2})
    end
    local params = {}
    params.member = self.m_model.m_active_target_uid
    self.m_model:getNetData("guild_kick_member", params, kickRequest)
end

-- 加入黑名单
function M:blackActive()
    local function blackCallback(response)
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0115"), delay_close = 2})
    end
    local params = {}
    params.f_uid = self.m_model.m_active_target_uid
    self.m_model:getNetData("friend_add_to_blacklist", params, blackCallback)
end

-- 发送邮件
function M:sendMailActive()
    local member = self.m_model:getMemberDataActive()
    self:openView("Union.UnionMailPop", {target_uid = member.uid})
end

return M