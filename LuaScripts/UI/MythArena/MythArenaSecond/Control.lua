
local M = class("MythArenaSecondControl",LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then
        if self.m_model.m_open_type == "last" and self.m_model.m_big_stage < 8 then
            self:updateMsg("look_now")
        else
            self:closeView()
        end
    elseif msg == "shop_btn" then --商店
        self:openView("Shop", {shop_type = 32, show_one = true})
    elseif msg == "go_btn" then
        self:openView("MythArena.MythArenaDefendTeamPop")
    elseif msg == "select_team_btn" then --布阵
        self.m_model:setDropDownStatus()
        self.m_view:refreshUI()
    elseif msg == "select_group" then
        if data then
            if self.m_model.m_cur_group_id == data.id then
                self.m_model:setDropDownStatus()
                self.m_view:refreshUI()
            else
                self.m_model.m_cur_group_id = data.id
                self:changeGroup(data.id)
            end
        end
    elseif msg == "player_btn" then -- 查看玩家
        local user = self.m_model:getPlayerData(data)
        if user then
            self:openView("Pops.PlayerInfo", {uid = user.user_info.uid})
        end
    elseif msg == "update_guess_data" then
        if data then
            self.m_model:updateGuessData(data)
            self.m_view:refreshUI()
        end
    elseif msg == "help_btn" then
        local params = {}
        params.title = self.m_model.m_stage_name
        params.content = "tid#myth_jinji_tips"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "log_btn" then
        self:openView("MythArena.MythArenaSecondRecordPop", {big_stage = self.m_model.m_big_stage})
    elseif msg == "record_btn" then
        if data then
            local log_data = self.m_model:getLogsByIndex(data)
            local cur_stage = self.m_model:getCurStageId()
            if log_data then
                local guess_uid = log_data.uid
                local user_data = self.m_model.m_user_info
                self:openView("MythArena.MythArenaSecondDetailsPop", {cur_stage = cur_stage, log_data = log_data, user_data = user_data, guess_uid = guess_uid})
            end
        end
    elseif msg == "jc_btn" then
        if data then
            local log_data = self.m_model:getLogsByIndex(data)
            if log_data then
                local guess_uid = log_data.uid
                local group_id = self.m_model.m_cur_group_id
                local user_data = self.m_model:getUserInfoByUid( guess_uid )
                local stage_id = self.m_model.m_big_stage
                self:openView("MythArena.MythArenaSecondGuessPop", {stage_id = stage_id, user_data = user_data, guess_uid = guess_uid, group_id = group_id})
            end
        end
    elseif msg == "stage_end" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("wlsh_text_0006"), delay_close = 2})
        self:closeView()
    elseif msg == "look_history" then
        self.m_model.m_open_type = "last" -- last 历史
        self.m_model.m_last_stage = data.last_stage
        self.m_model.m_cur_group_id = data.last_group_id or 0
        self:changeGroup(data.last_group_id, data.last_stage)
    elseif msg == "look_now" then
        self.m_model.m_open_type = "now" -- last 历史
        self:changeGroup(self.m_model.m_self_group_id, self.m_model.m_big_stage)
    else
        local temp = string.split(msg,'player_data_')
        if temp[1] == "" and temp[2] then
            local index = temp[2]
            local log_data = self.m_model:getLogsByIndex(tonumber(index))
            if log_data then
                local uid = log_data.uid
                self:openView("Pops.PlayerInfo", {uid = uid, look_model = 10})
            end
        end
    end
end

-- 准备
function M:changeGroup(group_id, big_stage_id)
    local function callfunc(response)
        --Logger.log(response,"playerReady response =====")
        if response["end"] == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:closeView()
            return true
        end
        self.m_model:updateData(response)
        self.m_model:initData()
        self.m_model.m_show_drop_down = false
        self.m_view:initUI()
        self.m_view:refreshUI()
    end
    local params = {}
    params.group_id = group_id or 1
    if self.m_model.m_open_type == "last" then
        params.stage_id = big_stage_id and big_stage_id or self.m_model.m_last_stage
    else
        params.stage_id = big_stage_id and big_stage_id or self.m_model.m_big_stage
    end
    self.m_model:getNetData("myth_arena_group_logs", params, callfunc)
end

--计时器
function M:updateTime()
    self.m_view:updateActivityTimer()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end
return M
