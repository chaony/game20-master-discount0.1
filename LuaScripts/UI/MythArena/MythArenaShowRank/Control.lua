local M = class("MythArenaShowRankControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
        --local not_close_tab = {}
        --not_close_tab = {["Loading.SyncLoadBigLoading"] = 1, ["Loading.SmallLoading"] = 1, ["Loading.BattleLoading"] = 1, ["Loading.BigLoading"] = 1, ["Main.TotalWorld"] = 1}
        --static_rootControl:closeAllViewPop(not_close_tab)
    elseif msg == "go_btn" then --快速导航
        self:openView("MythArena.MythArenaPromotion")
        --self:openView("MythArena.MythArenaMain")
    elseif msg == "shop_btn" then
        --RedPointUtil:saveLocalRedPointFreshTime("huashan_shop_once")
        self:openView("Shop", {shop_type = 32, show_one = true})
    elseif msg == "record_btn" then
        self:openView("MythArena.MythArenaSecondRecordPop", {big_stage = self.m_model.m_big_stage})
    elseif msg == "pop_promotino" then
        self:openView("MythArena.MythArenaPromotion")
    elseif msg == "rank_record_btn" then
        if data then
            self:getRankBattleLog(data)
        end
    elseif msg == "help_btn" then
        local params = {}
        params.title = "wlsh_text_0004"
        params.content = "tid#myth_tips"
        self:openView("Pops.CommonHelpPop", params)
    else
        local temp = string.split(msg,'rank_img')
        if temp[1] == "" and temp[2] then
            local rank_index = temp[2]
            local rank_data = self.m_model.m_ranks[tonumber(rank_index)] or {}
            if rank_data.user then
                self:openView("Pops.PlayerInfo", {uid = rank_data.user.uid, look_model = 10})
            end
        end
    end
end

function M:getRankBattleLog(rank)
    local params = {}
    params.group_id = 1
    params.stage_id = 7

    local function callfunc(response)
        local log_data = response.logs[rank] or {}
        if log_data then
            local guess_uid = log_data.uid
            local user_data = response.user_info or {}
            self:openView("MythArena.MythArenaSecondDetailsPop", {cur_stage = 7, log_data = log_data, user_data = user_data, guess_uid = guess_uid})
        end
    end
    self.m_model:getNetData("myth_arena_group_logs", params, callfunc)
end

function M:destroy()
    M.super.destroy(self)
end

return M;
