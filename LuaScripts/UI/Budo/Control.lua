---@class BudoControl:OOControlBase
---@field m_model BudoModel
---@field m_view BudoView
local M = class("BudoControl", LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Budo.Guide"
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
end

function M:startGuide()
    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(31, 2)
    if have_guide then
        if self.m_guide then
            self.m_guide:start()
        end
    end
end

function M:onHandle(msg, data)
    Logger.logWarningAlways(msg, "msgx-------------------")
    if msg == 99999 then -- 返回
        self:updateMsg("refreshData", nil, "Budo.BudoSelectPop")
        self:updateMsg("refreshRedPoint" ,nil ,"Main.Outskirts")
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 86})
    elseif msg == "challenge_btn" then --快速挑战
        if self.m_model:checkCanQuick() == true then
            self:checkQuickPlay(
                function()
                    local battle_id = self.m_model:getCurbattleId()
                    if battle_id then
                        local params = {
                            mode = self.m_model:getBuZhenMode(),
                            battle_id = battle_id,
                            race = self.m_model.m_tower_type,
                            budo_floor = self.m_model:changeFloor()
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
                        race = self.m_model.m_tower_type,
                        budo_floor = self.m_model:changeFloor()
                    }
                    self.m_view:returnAllRole()
                    self:openView("Formation", params)
                    end
                end
            )
        end
    elseif msg == "battle_end_refresh_ui" then
        self.m_model:refreshData()
        self.m_model:refreshEnemyData()
        self.m_guide:checkGuide()
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
    elseif msg == "hint" then
        self:openView("Pops.CommonHelpPop", {title = "world_str_009", content = "tid#towerdes_01"})
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
    local curEvent = data.event
    if curEvent == "quest_special_update" then
        self.m_view:updateQuestSpecial()
    end
end

function M:saveFormationTeam()
	local team = {}
	for i = 1, 5 do
		team[i]= self.m_model.main_team[i] or ""
	end
	local function callfunc()
		--if self.m_view.m_multi_formation_node then
		--	self.m_view.m_multi_formation_node:showFormationList()
		--end
        self:updateMsg("showFormationList", nil, "Formation.MultiFormation")

		self.m_view:updateMultiFormationBtnLoopScroll()
	end
	self.m_model:getNetData("hero_set_team",{type = "formation", index = self.m_model.m_sel_formation_index,team = team, deployment = self.m_model.m_atk_deployment}, callfunc,false,nil, GlobalConfig.POST)
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end

return M
