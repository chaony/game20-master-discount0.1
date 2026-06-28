local M = class("BudoServerRankListPopControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint()
    elseif msg == "load_rank" then
        self:requestLoadRank()
    elseif msg == "check_tag" then
        self:switchTabBtn(data)
    elseif msg == "help_btn" then
        local params = {}
        params.title = "budoServer_text_0003"
        params.content = "tid#TowerActiveDes_04"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "self_node" then
        if data then
            if data.user then
                uid = data.user.uid
            else
                user = UserDataManager.user_data.user_status
                uid = user.uid
            end
            self:openView("Pops.PlayerInfo", {uid = uid})
        end
    elseif msg == "item_click" then
        if data and data.user then
            self:openView("Pops.PlayerInfo", {uid = data.user.uid})
        end
      
    end
end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_is_corss ~= index then
        self.m_model.m_is_corss = index
        self:changeRankCross(index)
    end
end

function M:destroy()
    M.super.destroy(self)
end

function M:changeRankCross(rank_cross)
    local need_request = self.m_model:isHaveRankDataByCross(rank_cross)
    if need_request then
        self:requestNewCrossRank(rank_cross)
    else
        self.m_model:setRankCross(rank_cross)
        self.m_view:refreshUI(true)
    end
end

function M:requestNewCrossRank(rank_cross)
    local start_pos, end_pos = 1, 10
    local function netCallback(response)
        if self.m_view then
            self.m_model:setRankCross(rank_cross)
            self.m_model:initRankData(response)
            self.m_view:refreshUI(true)
        end
    end
    local params = {}
    params.start = start_pos
    params.stop = end_pos
    local url = rank_cross == 1 and "tower_active_show_cross_rank" or "tower_active_show_rank"
    self.m_model:getNetData(url, params, netCallback)
end

function M:requestLoadRank()
    local start_pos, end_pos = self.m_model:getLoadIndex()
    if start_pos > 0 then
        local function netCallback(response)
            if self.m_view then
                self.m_model:insertRankData(response.ranks)
                self.m_view:updateLoopScroll()
            end
        end
        local params = {}
        params.start = start_pos
        params.stop = end_pos
        local url = self.m_model.m_is_corss == 1 and "tower_active_show_cross_rank" or "tower_active_show_rank"
        self.m_model:getNetData(url, params, netCallback)
    end
end
return M;
