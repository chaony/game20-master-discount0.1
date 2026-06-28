local M = class("DragonswordControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "story_active_btn" then --龙泉逸闻
        local open_flag,tips_str,active_data,open_data = self:isActiveOpen(msg)
        self:openView("Dragonsword.DragonswordStory",
                {version = self.m_model.m_data.version,active_data = active_data,open_data = open_data,login_recv = self.m_model.m_data.login_recv,current_day = self.m_model:setCurrentDay()})
    elseif msg == "star_light_active_btn" then  --铸剑龙渊
        local open_flag,tips_str,active_data,open_data = self:isActiveOpen(msg)
        local param = {
            version = self.m_model.m_data.version,
            active_data = active_data,
            open_data = open_data,
            score = self.m_model.m_data.score,
            score_done = self.m_model.m_data.score_done,
            quests = self.m_model.m_data.quests,
            current_day = self.m_model:setCurrentDay()
        }
        self:openView("Dragonsword.DragonswordMelting",param)
    elseif msg == "battle_active_btn" then  --剑池试炼
        local open_flag,tips_str,active_data,open_data = self:isActiveOpen(msg)
        if open_flag then
            local param = {
                version = self.m_model.m_data.version,
                active_data = active_data,
                open_data = open_data,
                max_damage = self.m_model.m_data.max_damage,
                enemys = self.m_model.m_data.enemys,
                assist_heros = self.m_model.m_data.assist_heros,
                current_day = self.m_model:setCurrentDay()
            }
            self:openView("Dragonsword.DragonswordBattle",param)
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
        end
    elseif msg == "refresh_data" then --刷新首页数据信息
        self:refreshData()
    elseif msg == "help_btn" then  --帮助
        local params = {}
        params.title = "tid#OpenConditionName_252"
        params.content = "tid#DragonDes_1"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "refresh_main" then --刷新主页
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    end
end

--获取活动开启信息
function M:isActiveOpen(btn_name)
    local open_id = self.m_model:getOpenId(btn_name)
    local open_flag, tips_str = BtnOpenUtil:isBtnOpen(open_id)
    local open_data = self.m_model:getActiveName(open_id)
    local active_data = self.m_model:getActiveData(open_id)
    local end_time = self.m_model.m_params.open_active_data.end_ts
    local start_time = self.m_model.m_params.open_active_data.start_ts
    if end_time < UserDataManager:getServerTime() or start_time > UserDataManager:getServerTime() then
        open_flag = false
    end
    return open_flag,tips_str,active_data,open_data
end

--刷新数据
function M:refreshData()
    local function netCallback(response)
        if response["end"] == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:closeView()
        end
        self.m_model:updateServerData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("active_dragonsword_quest_index", nil, netCallback)
end

return M;
