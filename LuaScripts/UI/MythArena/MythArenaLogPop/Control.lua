local M = class("MythArenaLogPopControl",LikeOO.OOControlBase)

function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refreshRedPoint" ,nil ,"MythArena.MythArenaMain")
        self:closeView()
    elseif msg == "cell_item_node" then
    	local item_data = data.cell_data
    	self:openView("Pops.PlayerInfo", {uid = item_data.user_info.uid, look_model = 10})
    elseif msg == "battle_btn" then
        local cell_data = data.cell_data
        self:arenaSelectDefendTeam(cell_data)
    elseif msg == "master_battle_btn"  then
        self:revengeBattleStart(data)
    elseif msg == "battle_end_refresh_ui" then
        self:arenaArenaLogs()
    elseif msg == "statistics_btn" then
        local item_data = data.cell_data
        self:openView("MythArena.MythArenaBattleDetailPop", {battle_id = item_data.battle_id, log_data = item_data})
    end
end

-- 战斗
function M:arenaSelectDefendTeam(data)
    local function netCallback(response)
      --  self:openView("Loading.BattleLoading", {callfunc = function(open_flag)
        --    if open_flag == "open_view" then
                self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.MYTH_ARENA, defend_uid = data.user_info.uid, def_data = response})
          --  end
      --  end })
    end
    local params = {defend_uid = data.user_info.uid}
    self.m_model:getNetData("myth_arena_set_defend_teams", params, netCallback)
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
    self.m_model:getNetData("myth_arena_arena_logs", params, netCallback)
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
    self.m_model:getNetData("myth_arena_arena_logs", params, netCallback, nil, nil, GlobalConfig.POST)
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end

return M
