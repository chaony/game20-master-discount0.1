local M = class("TaoistMainControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Taoist.Guide"
end

function M:startGuide()
    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(55, 2)
    if have_guide then
        if self.m_guide then
            self.m_guide:start()
        end
    end
end

function M:onHandle(msg,data)
    if msg == 99999 then
        if self.m_model.m_is_jump then
            self:updateMsg("common_refresh" ,nil ,"parent")
        end
        self:closeView()
    elseif msg == "close_btn" then
        if self.m_model.m_is_jump then
            self:updateMsg("common_refresh" ,nil ,"parent")
        end
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 77})
    elseif msg == "playing" then --玩法切换
        self:switchPlaying(data)
    elseif msg == "level" then --关卡切换
        self:switchLevel(data)
    elseif msg == "goto_btn_all" then --挑战
        local isBattle = self.m_model:ishasBattle(self.m_model.current_level_battle)
        local next = self.m_model:getNextBattleOrder(self.m_model.current_level_battle)
        if isBattle and next == 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0957",data), delay_close = 2})
            return
        else
            local cell_data = self.m_model.current_level_battle_data
            self.battle_id = cell_data.cfg.battle
            self:openFormation(self.battle_id ,self.m_model.current_playing)
        end
    elseif msg == "receive_btn_all" then --碾压
        self:openRolling(self.m_model.current_level_battle_data.cfg.battle,self.m_model.current_playing)
    elseif msg == "Moppingup_btn_all" then --扫荡
        self:openMopping(self.m_model.current_playing,self.m_model.current_level_sweep)
    elseif msg == "Moppingup_btn_hui_all" then --扫荡置灰
        if not self.m_model.current_level_sweep then --完成任意关卡后可以使用扫荡
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0958",data), delay_close = 2})
        else --今日扫荡次数已用尽
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0959",data), delay_close = 2})
        end
    elseif msg == "Auto_sweep_btn" then --一键扫荡
        local isHasAutoSweepNum,cost = self.m_model:isHasAutoSweepNum(self.m_view.Tab_Node)
        self.m_model.callback_time = UserDataManager.local_data:getUserDataByKey("raid_auto_sweep", nil)
        if isHasAutoSweepNum then
            if self.m_model.callback_time ~= nil then
                local server_ts = UserDataManager:getServerTime()
                local day = GameUtil:NumberOfDaysInterval(self.m_model.callback_time,server_ts)
                if day >= 1 then
                    self.m_model.toDay_active = true
                else
                    self.m_model.toDay_active = false
                end
            end
            if self.m_model.toDay_active and cost > 0 then
                local params = {
                    isreward = true,
                    istoday = true,
                    today_isyes = true,
                    on_ok_call = function(msg)
                        if msg.cur_server_ts ~= nil then
                            self.m_model.callback_time = msg.cur_server_ts
                            UserDataManager.local_data:setUserDataByKey("raid_auto_sweep", self.m_model.callback_time or nil)
                        end
                        self:autoSweep()
                    end,
                    reward_text = Language:getTextByKey("new_str_0966",cost),
                }
                self:openView("Pops.CommonPop",params,nil,true)
            else
                self:autoSweep()
            end
            
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0964"), delay_close = 2})
        end
    elseif msg == "battle_end_refresh_ui" then --刷新界面
        if data ~= nil then
            local result = data.data.battle.result
            if result == 0 then
                self:openFormation(self.battle_id,self.m_model.current_playing)
            end
        end
        self:refreshData()
    end
end

--切换玩法
function M:switchPlaying(date)
    local race_open_flag, race_tips_str = BtnOpenUtil:isBtnOpen(date.open_id)
    if race_open_flag then --开启
        self.m_model.current_playing = date.cell_data.type
        self.m_view:CurrentComplet()
        self.m_view:refreshUI()
        self.m_view:setPicture(date.cell_data.picture)
    else --未开启
        GameUtil:lookInfoTips(self, { msg = race_tips_str, delay_close = 2})
    end
end

--切换关卡
function M:switchLevel(date)
    self.m_model.current_choice_level = date
    self.m_view:refreshUI()
    self.m_view:refreshBtn(date)
end

--挑战
function M:openFormation(battle_id, raid_sort)
    local params = {
        mode = GlobalConfig.BATTLE_MODE.RAID,
        battle_id = battle_id,
        raid_sort = raid_sort,
    }
    self:openView("Formation", params)
end

--刷新界面
function M:refreshData()
    local function netCallback(response)
        self.m_model:updateServerData(response)
        self.m_view:CurrentComplet()
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("raid_index", { }, netCallback)
end

--碾压
function M:openRolling(battle_id,raid_sort)
    local function netCallback(response)
        self:getReward(response)
        self.m_model:updateServerData(response)
        self.m_view:CurrentComplet()
        self.m_view:refreshUI()
    end
    local params = {
        raid_sort = raid_sort,
    }
    self.m_model:getNetData("raid_quick_pass_raid", params, netCallback)
end

--扫荡
function M:openMopping(raid_sort,raid_id)
    local function netCallback(response)
        --Logger.logError(response,"response数据")
        self:getReward(response)
        self.m_model:updateServerData(response)
        self.m_view:refreshUI()
    end
    local params = {
        raid_sort = raid_sort,
        raid_id = raid_id
    }
    self.m_model:getNetData("raid_sweep", params, netCallback)
end

--奖励展示
function M:getReward(response)
    local common_reward = response.reward --普通奖励
    local special_reward = response.special_reward or {} --特权奖励
    special_reward.extra_type = 1
    RewardUtil:rewardTipsByData(common_reward, special_reward) --展示领取奖励
end

--一键扫荡
function M:autoSweep()
    local function netCallback(response)
        self:getReward(response)
        self.m_model:updateServerData(response)
        self.m_view:CurrentComplet()
        self.m_view:refreshUI()
    end
    local params = {
        is_buy = self.m_view.is_buy
    }
    self.m_model:getNetData("raid_auto_sweep", params, netCallback)
end

return M;
	