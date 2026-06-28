---@class ArenaSelectMainControl:OOControlBase
---@field m_model ArenaSelectMainModel
local M = class("ArenaSelectMainControl",LikeOO.OOControlBase)

function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    self.m_guide_file_name = "UI.Arena.ArenaSelectMain.Guide"
    --每隔1秒执行一次
    -- self:setTimer(1,function()
    --     self.m_view:refreshTimeUI(self.m_model:getTypeEndTime())
    --     --self.m_view:updateLockAreaTime()
    --     if self.m_model:getRemainTime() <= 0 then
    --         local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
    --         if guild_id > 0 then
    --             self.m_model:getNetData("gvg_index", nil, function(response)
    --                 --结束时间
    --                 self.m_model.type_end_time = response.type_end_time
    --                 -- 0:未开始，1：报名阶段，2：匹配阶段，3：驻扎阶段, 4: 战斗阶段，5：休赛阶段，下个赛季未开始
    --                 self.m_model.type = response.type;
    --             end)
    --         else
    --             self:arenaIndex()
    --         end
    --     end
    -- end)
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refreshRedPoint" ,nil ,"Main.Outskirts")
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 37})
    elseif msg == "normal_btn" then --竞技场
        --QuickOpenFuncUtil:openFunc(24)
        local server_data = self.m_model:getAreaData("rise_arena")
        if server_data.promote_flag==2  then
            local param={
                --自动晋级rise_id是晋级后的值，手动晋级时是晋级前的值
                match_type=server_data.rise_id,
                callback=nil,
                promote_flag=server_data.promote_flag
            }
            self:openView("Arena.ArenaPeak.ArenaAdvance",param)
        else
            self:openView("Arena.ArenaPeak.ArenaPeak",{promote_flag=server_data.promote_flag})
        end
    elseif msg == "race_btn" then --种族竞技场
        local race_arena = self.m_model:getArenaDataByKey("race_arena")
        
        if race_arena and race_arena.match_type and race_arena.match_type == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#TianJiSai_des_3"), delay_close = 2})
        --elseif race_arena and race_arena.match_type and race_arena.match_type == 2 then
        --   self:goFiveRace()
        else
            QuickOpenFuncUtil:openFunc(36)
        end
    elseif msg == "top_race_btn" then --天级赛竞技场  
        local race_arena = self.m_model:getArenaDataByKey("race_arena")
        if race_arena and  race_arena.match_type and  race_arena.match_type == 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#TianJiSai_des_4"), delay_close = 2})
        --elseif race_arena and race_arena.match_type and race_arena.match_type == 2 then
        --    self:goFiveRace()
        else
            QuickOpenFuncUtil:openFunc(36)
        end
    elseif msg == "guild_war_btn" then
        local function callback(response)
            local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
            if guild_id and guild_id > 0 then
                --工会战
                self:openView("UnionWar", { union_data = response })
            else
                --没有工会
                self:openView("Union.UnionIndex", response)
            end
        end
        self.m_model:getNetData("guild_index", nil, callback)
    elseif msg == "high_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(34)
        if open_flag == false then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey(tips_str), delay_close = 2})
            return
        end
        self:openView("LingCloud", {high_arena =  self.m_model:getAreaData("high_arena"),top_arena =  self.m_model:getAreaData("top_arena")})
    elseif msg == "refreshRedPoint" then    
        self.m_view:refreshUI()
    elseif msg == "refresh_ui" then
        self:arenaIndex()
    elseif msg == "refresh_top_race_rank" then
        if data and data.rank then
            self.m_model:setArenaDataByKey("top_race_arena", "rank", data.rank)
        end
        self.m_view:refreshUI()
    elseif msg == "update_arena_data" then --更新排名数据
        if self.m_model.m_data["arena"] then
            self.m_model.m_data["arena"].rank = data
            self.m_view:refreshUI()
        end
    elseif msg == "update_arenarace_data" then
        if self.m_model.m_data["race_arena"] then
            self.m_model.m_data["race_arena"].rank = data
            self.m_view:refreshUI()
        end
    elseif msg == "fylt_race_btn" then
        -- 风云擂台入口
        self:openView("FulwinArena.FulwinArenaMain")
    end
end

function M:goFiveRace()
    local tips = Language:getTextByKey("arena_str_0028")
    local params =
    {
        on_ok_call = function(msg)
            self:openView("Arena.ArenaFiveRace", {races = { 1,3,4 }})
            self:updateMsg(99999)
        end,
        title = "",
        no_close_btn = false,
        ok_text = Language:getTextByKey("new_str_0029"),
        text = tips,
    }
    static_rootControl:openView("Pops.CommonPop", params, nil, true)
end

function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "red_dot_update" then
        self.m_view:refreshUI()
    end
end
 
function M:arenaIndex()
    local function netCallback(response)
        self.m_model:initData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("arena_index", {}, netCallback)
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end

return M
