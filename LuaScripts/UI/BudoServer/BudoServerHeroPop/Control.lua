local M = class("BudoServerHeroPopControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint()
    elseif msg == "item_click" then
        if data and data.uid then
            self:openView("Pops.PlayerInfo", {uid = data.uid})
        end
    elseif msg == "look_hero" then
        local heros = {}
        heros[data.hero.oid] = data.hero
        if data and data.hero then 
            self:openView("HeroBag", {player_data = {heros = heros} , mode = 3, oid = data.hero.oid})
        end
    elseif msg == "help_btn" then
        local params = {}
        params.title = "budoServer_text_0010"
        params.content = "tid#TowerActiveDes_02"
        self:openView("Pops.CommonHelpPop", params)
    end
end

function M:destroy()
    M.super.destroy(self)
end

function M:changeRankSort(rank_sort)
    local need_request = self.m_model:isHaveRankDataBySort(rank_sort)
    if need_request then
        self:requestNewSortRank(rank_sort)
    else
        self.m_model:setRankSort(rank_sort)
        self.m_view:refreshUI(true)
    end
end

function M:requestNewSortRank(rank_sort)
    local start_pos, end_pos = 1, 10
    local function netCallback(response)
        if self.m_view then
            self.m_model:setRankSort(rank_sort)
            self.m_model:initRankData(response)
            self.m_view:refreshUI(true)
        end
    end
    local params = {}
    params.is_cross = self.m_model.m_params.is_cross
    params.sort = rank_sort
    params.start = start_pos
    params.stop = end_pos
    self.m_model:getNetData("world_rank_info", params, netCallback)
end

function M:requestLoadRank()
    local start_pos, end_pos = self.m_model:getLoadIndex()
    if start_pos > 0 then
        local function netCallback(response)
            if self.m_view then
                self.m_mail_load = true
                self.m_model:insertRankData(response.ranks)
                self.m_view:updateLoopScroll()
            end
        end
        local params = {}
        params.is_cross = self.m_model.m_params.is_cross
        params.sort = self.m_model.m_cur_rank_sort
        params.start = start_pos
        params.stop = end_pos
        self.m_model:getNetData("world_rank_info", params, netCallback)
    end
end
return M;
