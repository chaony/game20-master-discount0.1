local M = class("HuntTreasuresMyTeamPop",LikeOO.OOControlBase)

function M:onEnter()
    for i = 1, 4 do
        if self.m_model:getRewardReceiveTime(i) > 0 then
            self:updateTime()
            self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
            break
        end
    end

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "reward_btn" then -- 保存
        local team_id = data.index
        self:requestGetReward(team_id)
    elseif msg == "recall_btn" then
        local team_id = data.index
        local start_time = self.m_model:getOccupyTime(team_id)
        local occ_time = UserDataManager:getServerTime() - start_time
        local min_time = ConfigManager:getCommonValueById(625,4)--最少占领时间 
        if occ_time < min_time * 60 *60 then
            self:popTips(team_id)
        else
            self:requestRecall(team_id)
        end
    elseif msg == "cancle_btn" then -- 取消
        self.m_model.m_edit_status = 1
        self.m_model.m_select_cell_index = -1
        self.m_model:initData()
        self.m_view:refreshUI()
    elseif msg == "formation_btn" or msg == "formation_edit_btn" then
        local races = GameUtil:getRacesByRegionId(1)
        self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.MINING_DEFENSE, formation_index = data.index, races = races})
    elseif msg == "exchange_btn" then
        if self.m_model.m_edit_status == 2 then --选择要调整的队伍
            self.m_model.m_edit_status = 3
            self.m_model.m_select_cell_index = data.index
            self.m_view:refreshUI()
        elseif self.m_model.m_edit_status == 3 then -- 交换
            self.m_model:exchangeTeam(self.m_model.m_select_cell_index, data.index)
            self.m_model.m_edit_status = 2
            self.m_model.m_select_cell_index = -1
            self.m_view:refreshUI()
        end
    elseif msg == "refresh_ui" then
        self.m_model:initData()
        self.m_view:refreshUI()
    elseif msg == "signatrue_btn" then
        self:openEditSignatrue()
    elseif msg == "go_to_btn" then
        local oid = data.oid
        if oid > 0 then
            local region_id =  math.modf(oid / 10000)
            local location_id = math.modf((oid - region_id * 10000) / 100)
            self:updateMsg("change_area", { region_id = region_id, location_id = location_id, close_view_name = "HuntTreasuresMyTeamPop"  }, "HuntTreasures")
        end
    elseif msg == "go_to_btn2" then
        local index = data.index
        self:requestLocationIndex(index)
    elseif msg == "box_reward" then
        if data and data.data then
            local function callfunc(response)
                RewardUtil:rewardTipsByData(response.reward or {})
                self.m_model:initData(response)
                self.m_view:refreshUI()
            end
            self.m_model:getNetData("mining_receive_scale", { scale = data.data }, callfunc)
        end
    elseif msg == "box_click" then
        if data and data.data then
            local itemData = {data.data}
            self:openView("Pops.LookRewardTips",{rewards = itemData, click_transform = data.click_transform, show_check_mark = false})
        end
    elseif msg == "battle_log_btn" then
        self:openView("HuntTreasures.HuntTreasuresLogPop")
        self:closeView()
    end
end

function M:popTips(team_id)
    local min_time = ConfigManager:getCommonValueById(625,4)--最少占领时间 
    local atk_cd = ConfigManager:getCommonValueById(626,60)--进攻惩罚时间
    local params =
    {
        on_ok_call = function(msg)
            self:requestRecall(team_id)
        end,
        new_cancel_call = function(msg)
        end,
        tow_close_btn = true,
        --cancel_text = Language:getTextByKey("hunt_treasure_str_061",min_time, atk_cd),
        title = Language:getTextByKey("sdk_txt_002"),
        --no_close_btn = true,
        text = Language:getTextByKey("hunt_treasure_str_061",min_time, atk_cd),
    }
    static_rootControl:openView("Pops.CommonPop", params, nil, true)
end

function M:requestLocationIndex(map_id)
    local region_id, location_id = map_id, 1
    self:openView("HuntTreasures.HuntTreasuresAreaPop",  { region_id = region_id })
    --self:updateMsg("refresh_cur_page", { region_id = region_id, location_id = location_id },"HuntTreasures")
    self:updateMsg(99999)
end

function M:openEditSignatrue()
    local sign_desc = Language:getTextByKey("options_str_0027")--self.m_model:getSginDesc()
    local params =
    {
        on_ok_call = function(msg)
            self:requestSign(msg)
        end,
        title = Language:getTextByKey("hunt_treasure_str_034"),
        text = sign_desc,
    }
    static_rootControl:openView("Pops.CommonInputBigPop", params)
end

function M:requestSign(m_msg)
    local desc = m_msg
    if desc == self.m_model.m_cur_desc then return end
    local function signCallback(response, tag, status_code)
        if response then
            self.m_model.m_cur_desc = desc
            self:updateMsg("refresh_cur_page",nil,"HuntTreasures")
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0462"), delay_close = 2})
        else
            if status_code == GlobalConfig.SENSITIVE_WORDS_CODE then
                self.m_model.m_cur_desc = ""
                --self.m_view:setSignText("")
            end
        end
    end
    local params = {}
    params.desc = desc
    self.m_model:getNetData("mining_set_desc", params, signCallback, nil, true)
end

function M:requestGetReward(team_id)
    --local oid = self.m_model:getMineOid(team_id)
    local function callfunc(response)
        RewardUtil:rewardTipsByData(response.reward or {})
        self.m_model:initData(response)
        self.m_model:setRewardStatus(team_id, false)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("mining_receive_income", { team_id = team_id }, callfunc)
end

function M:requestRecall(team_id)
    local function callfunc(response)
        RewardUtil:rewardTipsByData(response.reward or {})
        self:updateMsg("refresh_cur_page",nil,"HuntTreasures")
        self.m_model:initData(response, true)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("mining_recall_team", { team_id = team_id }, callfunc)
end

function M:updateTime()
    self.m_view:updateTime()
end

function M:destroy()
    if self.m_timer_id then
        self:removeTimer(self.m_timer_id)
    end
    M.super.destroy(self)
end

return M;
