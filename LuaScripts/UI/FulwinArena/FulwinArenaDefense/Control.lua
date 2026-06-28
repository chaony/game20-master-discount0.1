
local M = class("FulwinArenaMainControl",LikeOO.OOControlBase)

function M:onEnter()
    M.super.onCreate(self)
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "btn_put" then
        -- 摆擂
        self:openView("FulwinArena.FulwinArenaInvitePop", {zfljRank = self.m_model.m_zfljRank, txywRank = self.m_model.m_txywRank})
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
    elseif msg == "edit_team" then
        -- 编辑
        if data.index <= 0 then
            self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.FULWIN_AREA_ONE})
        else
            self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.FULWIN_AREA_THREE})
        end
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
    self.m_model:getNetData("friend_arena_set_defend_teams",{sendType = 2, normal_arrays = self.m_model.m_mult_normal_array,team_type = 3, teams = self.m_model.mult_main_teams, relics = self.m_model.mult_solts , deployments = nil}, callfunc,false,nil, GlobalConfig.POST)
end

function M:destroy()
    M.super.destroy(self)
end

return M
