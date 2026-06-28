
local M = class("FulwinArenaMainControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_list_cd = 0
    self:freshListData()
    if self.m_model.m_data.ring_id and tonumber(self.m_model.m_data.ring_id) > 0 then
        self:updateMsg("open_Ring")
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "btn_put" then
        -- 摆擂
        --self:openView("FulwinArena.FulwinArenaInvitePop", {zfljRank = self.m_model.m_zfljRank, txywRank = self.m_model.m_txywRank})
        self:openView("FulwinArena.FulwinArenaDoor")
    elseif msg == "btn_log" then
        -- 对战记录
        self:openView("FulwinArena.FulwinArenaBattleLogPop", {})
    --elseif msg == "btn_getBtn" then
    --    self.m_model:getNetData("double_twelve_receive_quest", data, function(response)
    --        if response then
    --            if self:activityOverExamine(response) then
    --                return
    --            end
    --            RewardUtil:rewardTipsByData(response.reward)
    --            EventDispatcher:dipatchEvent("forceRefresh_petardInfoData")
    --            self.m_view:refreshUI()
    --        end
    --    end, nil, nil, nil)
    elseif msg == "btn_modifyRank" then
        self.m_model:setEditStatus(2)
        self.m_view:refreshUI()
        audio:SendEvtUI("Play_UI_NormalClick")
    elseif msg == "exchange_btn" then
        -- 换位
        if self.m_model.m_edit_status == 2 then --选择要调整的队伍
            self.m_model:setEditStatus(3)
            self.m_model:setSelectIndex(data.index)
            self.m_view:refreshUI()
        elseif self.m_model.m_edit_status == 3 then -- 交换
            self.m_model:exchangeTeam(self.m_model.m_select_cell_index, data.index)
            self.m_model:setEditStatus(2)
            self.m_model:setSelectIndex(-1)
            self.m_view:refreshUI()
        end
        audio:SendEvtUI("Play_UI_NormalClick")
    elseif msg == "edit_team" then
        -- 编辑
        if data.index <= 0 then
            self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.FULWIN_AREA_ONE})
        else
            self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.FULWIN_AREA_THREE})
        end
        audio:SendEvtUI("Play_UI_BuZhen")
    elseif msg == "btn_cancel" then
        -- 取消
        self.m_model:setEditStatus(1)
        self.m_model:setSelectIndex(-1)
        self.m_model:initData()
        self.m_view:refreshUI()
    elseif msg == "btn_save" then
        -- 保存
        self:modifyArenaSetDefendTeams()
    elseif msg == "refresh_ui" then
        self.m_model:initData()
        self.m_view:refreshUI()
    elseif msg == "explain_btn" then
        self:openView("Pops.CommonHelpPop", { title = "fylt_str_0008", content = "Fengyun_challenge_tips_1" })
    elseif msg == "btn_defense" then -- 打开防御
        self.m_model:setDefense()
        if self.m_model.m_defense_open == false then
            self:updateMsg("btn_cancel")
        end
        self.m_view:refreshUI()
    elseif msg == "btn_fresh" then
        self:freshListData()
    elseif msg == "fresh_list_data" then
        if self.m_list_cd <= 0 then
            self.m_list_cd_timer = self:setTimer(1, function()
                self.m_list_cd = self.m_list_cd - 1
                if self.m_list_cd <= 0 then
                    self:removeTimer(self.m_list_cd_timer)
                    self.m_list_cd_timer = nil
                end
            end)
            self:freshListData()
            self.m_list_cd = 3
        end
    elseif msg == "tab_index" then
        self.m_model:setTabIndex(data)
        self.m_view:refreshUI()
    elseif msg == "btn_search" then
        self:searchRing()
    elseif msg == "btn_fight" then
        if data.typ == 1 then
            --local is_open, tips = BtnOpenUtil:isBtnOpen(334)
            --if not is_open then
            --    GameUtil:lookInfoTips(self, {msg = tips, delay_close = 2})
            --    return
            --end
        else
            local is_open, tips = BtnOpenUtil:isBtnOpen(335)
            if not is_open then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("Fengyun_challenge_tips_no"), delay_close = 2})
                return
            end
        end
        self:joinRing(data)
    elseif msg == "btn_password" then
        self:inputRingPswd(data)
    elseif msg == "btn_playerInfo" then
        self:openView("Pops.PlayerInfo", {uid = data.president_info.uid})
    elseif msg == "open_Ring" then
        if self.m_model.m_data.ring_typ == 1 then
            --local is_open, tips = BtnOpenUtil:isBtnOpen(334)
            --if is_open then
                self:openView("FulwinArena.FulwinArenaSingleMain", {ring_id = self.m_model.m_data.ring_id})
            --else
            --    GameUtil:lookInfoTips(self, {msg = tips, delay_close = 2})
            --end
        else
            local is_open, tips = BtnOpenUtil:isBtnOpen(335)
            if is_open then
                self:openView("FulwinArena.FulwinSecondMain", {ring_id = self.m_model.m_data.ring_id})
            else
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("Fengyun_challenge_tips_no"), delay_close = 2})
            end
        end
    end
end

-- teams: {1: [hero_oid], 2: [hero_oid], 3: [hero_oid]}
function M:modifyArenaSetDefendTeams()
    local function callfunc()
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0248"), delay_close = 2})
        if self.m_view then
            self.m_model.m_edit_status = 1
            self.m_model.m_select_cell_index = -1
            self.m_model:initData()
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("friend_arena_set_defend_teams",{sendType = 2, team_type = 3, teams = self.m_model.mult_main_teams, relics = self.m_model.mult_solts , deployments = nil}, callfunc,false,nil, GlobalConfig.POST)
end

-- 刷新擂台
function M:freshListData()
    local function callfunc(response)
        --Logger.log(response,"freshListData response =====")
        if self.m_view then
            self.m_model:updateListdata(response)
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("friend_arena_random_ring_list",{num = 50}, callfunc)
    self:updateRingListData()
end

-- 查找擂台
function M:searchRing()
    local str = self.m_view:getSearchText()
    if str == "" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("fylt_str_0071"), delay_close = 2})
        return
    end

    local function callfunc(response)
        --Logger.log(response,"searchRing response =====")
        if #response == 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("fylt_str_0072"), delay_close = 2})
        else
            if self.m_view then
                self.m_model:updateListdata(response)
                self.m_view:refreshUI()
            end
        end
    end
    self.m_model:getNetData("friend_arena_ring_list",{ring_ids = {str}}, callfunc)
end

-- 输入房间密码
function M:inputRingPswd(data)
    if data.typ == 1 then
        --local is_open, tips = BtnOpenUtil:isBtnOpen(334)
        --if not is_open then
        --    GameUtil:lookInfoTips(self, {msg = tips, delay_close = 2})
        --    return
        --end
    else
        local is_open, tips = BtnOpenUtil:isBtnOpen(335)
        if not is_open then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("Fengyun_challenge_tips_no"), delay_close = 2})
            return
        end
    end
    
    local params =
    {
        on_ok_call = function(msg)
            self:joinRing(data, msg)
        end,
        title = Language:getTextByKey("fylt_str_0061"),
        text = "",
        character_limit = 6,
    }
    self:openView("Pops.CommonInputPop", params)
end

-- 加入擂台
function M:joinRing(data, pswd)
    local pswd = pswd or ""
    local function callfunc(response)
        --Logger.log(response,"joinRing response =====")
        if self.m_view then
            if response and response.ring_id then
                self.m_model.m_data.ring_id = response.ring_id
                self.m_model.m_data.ring_typ = response.typ
                self:updateMsg("open_Ring")
            end
        end
    end
    local params = {}
    params.ring_id = data.ring_id
    params.pswd = pswd
    self.m_model:getNetData("friend_arena_join_ring", params, callfunc)
end

-- 定时更新擂台信息
function M:updateRingListData()
    if self.m_list_timer then
        self:removeTimer(self.m_list_timer)
        self.m_list_timer = nil
    end

    local function callfunc(response)
        --Logger.log(response,"updateRingListData response =====")
        self.m_model:updateListdata(response)
        self.m_view:refreshUI(true)
    end
    
    local function updateInfo()
        if self.m_view and self.m_view:isVisible() then
            local ids = self.m_model:getListId()
            if #ids > 0 then
                self.m_model:getNetData("friend_arena_ring_list", {ring_ids = ids}, callfunc, false, true)
            end
        end
    end
    self.m_list_timer = self:setTimer(30, updateInfo)
end

function M:destroy()
    M.super.destroy(self)
end

return M
