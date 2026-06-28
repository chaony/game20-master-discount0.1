local M = class("BudoServerControl", LikeOO.OOControlBase)

function M:onEnter()
    --self.m_guide_file_name = "UI.BudoServer.Guide"
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
    --EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
end

--function M:startGuide()
--    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(31, 2)
--    if have_guide then
--        if self.m_guide then
--            self.m_guide:start()
--        end
--    end
--end

function M:onHandle(msg, data)
    if msg == 99999 then -- 返回
        self:updateMsg("common_refresh",nil,"parent")
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 86})
    elseif msg == "challenge_btn" then --快速挑战
        if self.m_model:getOpenStatus() ~= 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("budoServer_text_0018"), delay_close = 2})
            return
        end
        if self.m_model:checkCanQuick() == true then
            self:checkQuickPlay(
                function()
                    local battle_id = self.m_model:getCurbattleId()
                    if battle_id then
                        local params = {
                            mode = self.m_model:getBuZhenMode(),
                            battle_id = battle_id,
                            active_tower_heros = self.m_model.m_data.heros,
                            active_tower_heros_id = self.m_model.m_hero_id,
                            active_tower_day =  self.m_model:isShowBuff(),
                            version = self.m_model.m_version,
                        }
                        self.m_view:returnAllRole()
                        self:openView("Formation", params)
                    end
                end
            )
        else
            self.m_view:moveToNext(
                self.m_model.cur_floor + 1,
                function()
                    local battle_id = self.m_model:getCurbattleId()
                    self.m_view:unlockTouch()
                    if battle_id then
                    local params = {
                        mode = self.m_model:getBuZhenMode(),
                        battle_id = battle_id,
                        budo_floor = self.m_model:changeFloor(),
                        active_tower_heros = self.m_model.m_data.heros,
                        active_tower_heros_id = self.m_model.m_hero_id,
                        active_tower_day = self.m_model:isShowBuff(),
                        version = self.m_model.m_version,
                    }
                    self.m_view:returnAllRole()
                    self:openView("Formation", params)
                    end
                end
            )
        end
    elseif msg == "battle_end_refresh_ui" then
        self:refreshIndex(data)
    elseif msg == "hint" then
        self:openView("Pops.CommonHelpPop", {title = "budoServer_text_0007", content = "tid#TowerActiveDes_01"})
    elseif msg == "clickEnemy" then
        self.m_view:updateRightCount(data)
        self.m_view:updateSelectEnemy(data)
    elseif msg == "common_refresh" then
        self.m_model:refreshData()
        self.m_model:refreshEnemyData()
        self.m_view:refreshUI()
        self.m_view:moveToFloor(self.m_model.cur_floor)
        self.m_view:updateSelectEnemy(self.m_model.cur_floor + 1)
        self.m_view:refreshEnemyStatus()
    elseif msg == "quest_special_btn" then
        local quest_type = self.m_model:getQuestType()
        self:openView("Task.TaskMainChapter", {quest_type = quest_type, callback = function ()
            self.m_view:refreshUI()
        end})
    elseif msg == "rank_btn" then
        self:openView("BudoServer.BudoServerRankListPop", {temp_user = self.m_model.m_user})
    elseif msg == "hero_btn" then
        --self:openView("BudoServer.BudoServerGiftPop")
        self:openView("BudoServer.BudoServerHeroPop")
    elseif msg == "gift_btn" then
        self:openView("BudoServer.BudoServerGiftPop")
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint()
    end
end

function M:checkQuickPlay(call_b)
    local function callback(response)
        if response and response.need_battle ~= 1 then
            if response.reward and next(response.reward) then
                local last_floor = self.m_model.cur_floor
                self.m_model:refreshData()
                if last_floor < self.m_model.cur_floor then
                    self.m_view.temp_floor = last_floor
                    self.m_view:moveAnim(
                        function()
                            self.m_view:refreshUI()
                            RewardUtil:rewardTipsByData(response.reward)
                        end
                    )
                end
            end
            if self.m_model.m_tower_type ~= 0 then
                for k,v in pairs(response.race_floor_times) do
                    UserDataManager.race_floor_times[k] = v
                end
            end
        else
            if call_b then
                call_b()
            end
        end
    end
    self.m_model:getNetData("quick_pass_tower", {race = self.m_model.m_tower_type}, callback)
end

function M:dataUpdateEvent(event, data)
    --local curEvent = data.event
    --if curEvent == "quest_special_update" then
    --    self.m_view:updateQuestSpecial()
    --end
end

function M:updateTime()
    self.m_view:updateTime()
end

function M:refreshIndex(data)
    local function callfunc(response)
        self.m_model:refreshData(response)
        self.m_model:refreshEnemyData()
        --self.m_guide:checkGuide()
        if data then
            if data.open_formation and data.open_formation == 1 then
                local battle_id = self.m_model:getCurbattleId()
                if battle_id then
                    local params = {
                        mode = data.mode,
                        race = self.m_model.m_tower_type,
                        battle_id = battle_id,
                        enter_call_func = data.func,
                        auto_battle_flag = data.auto_battle_flag,
                        budo_floor = self.m_model:changeFloor(),
                        active_tower_heros = self.m_model.m_data.heros,
                        active_tower_heros_id = self.m_model.m_hero_id,
                        active_tower_day = self.m_model:isShowBuff(),
                        next_floor = true
                    }
                    self:openView("Formation", params)
                end
            elseif data.reward then
                RewardUtil:rewardTipsByRewards(data.reward)
                self.m_view:refreshEnemyStatus()
                self.m_view:refreshUI()
                self.m_view:moveToFloor(self.m_model.cur_floor)
                self.m_view:updateSelectEnemy(self.m_model.cur_floor + 1)
            end
        else
            self.m_view:refreshEnemyStatus()
            self.m_view:refreshUI()
            self.m_view:moveToFloor(self.m_model.cur_floor)
            self.m_view:updateSelectEnemy(self.m_model.cur_floor + 1)
        end
    end
    self.m_model:getNetData("tower_active_index", nil, callfunc,false,nil, GlobalConfig.POST)
end

function M:checkTeam()
	local cur_team = UserDataManager.hero_data:getTeamByKey("tower_active")
	for i = 1, #cur_team do
		local hero_id = cur_team[i]
        if not(self.m_model.m_data.heros[hero_id]) and hero_id ~= "" then
            UserDataManager.hero_data:updateTeams({tower_active = {}})
            return
        end
	end
end

function M:destroy()
    if self.m_timer_id then
        self:removeTimer(self.m_timer_id)
    end
    M.super.destroy(self)
end

return M
