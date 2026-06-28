local M = class("ArenaNormalLogControl",LikeOO.OOControlBase)

function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refreshRedPoint" ,nil ,"Arena.ArenaNormal.ArenaNormal")
        self:closeView()
    elseif msg == "cell_item_node" then
    	local item_data = data.cell_data
    	self:openView("Pops.PlayerInfo", {uid = item_data.user_info.uid, look_model = 1})
    elseif msg == "battle_btn" then
        local cell_data = data.cell_data
        self:arenaSelectDefendTeam(cell_data)
    elseif msg == "master_battle_btn"  then
        self:revengeBattleStart(data)
    elseif msg == "battle_end_refresh_ui" then
        self:arenaArenaLogs()
    elseif msg == "statistics_btn" then
        local item_data = data.cell_data
        self:openView("Pops.BattleStatistics", {battle_id = item_data.battle_id, round = 1, log_data = item_data})
    end
end

-- 战斗
function M:arenaSelectDefendTeam(data)
    local free_time = self.m_model:getFreeTimes()
    local item_data = UserDataManager.item_data:getItemDataById(1004)
    if free_time > 0 or item_data.num > 0 then
        local function netCallback(response)
          --  self:openView("Loading.BattleLoading", {callfunc = function(open_flag)
            --    if open_flag == "open_view" then
                    self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.LOCAL_ARENA, defend_uid = data.user_info.uid, def_data = response})
              --  end
          --  end })
        end
        local params = {defend_uid = data.user_info.uid}
        self.m_model:getNetData("arena_select_defend_team", params, netCallback)
    else
        self:openView("Arena.ArenaNormal.ArenaNormalTicketBuy")
    end
end

-- 刷新
function M:arenaArenaLogs()
    local function netCallback(response)
        if self.m_view then
            self.m_model:initData(response)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    self.m_model:getNetData("arena_arena_logs", params, netCallback)
end

function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "items_update" then
        self.m_view:refreshUI()
    end
end

--师傅复仇
function M:revengeBattleStart(data)
    local function netCallback(response)
        
        self.m_view:refreshUI()
    end
    local params = {battle_id = data.cell_data.battle_id}
    self.m_model:getNetData("arena_arena_logs", params, netCallback, nil, nil, GlobalConfig.POST)
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end




return M
