local M = class("TXRankMainPopControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = -1})
    --elseif msg == "refreshRedPoint" then
        --self.m_view:refreshRedPoint()
    elseif msg == "local_server_btn" then
        if self.m_model.m_is_cross == 0 then
            return
        end
        self:requestRankData(0)
    elseif msg == "cross_server_btn" then
        if self.m_model.m_is_cross == 1 then
            return
        end
        self:requestRankData(1)
    elseif msg == "open_rank" then
        if data then
            local total_rank_data = self.m_model:getCurRankData()
            self:openView("TianXiaBattle.TXRankListPop", {total_rank_data = total_rank_data, is_cross = self.m_model.m_is_cross, sort = data})
        end
    elseif msg == "help_btn" then
        local params = {}
        params.title = "total_world_rank_text_02"
        params.content = "tid#TianXiaMainDes_01"
        self:openView("Pops.CommonHelpPop", params)
    end
end

function M:destroy()
    M.super.destroy(self)
end

function M:requestRankData(is_cross)
    if self.m_model:needRequest(is_cross) then
        local function netCallback(response)
            if self.m_view then
                self.m_model:setCurCross(is_cross)
                self.m_model:initData(response)
                self.m_view:refreshUI(true)
            end
        end
        self.m_model:getNetData("world_all_rank", { is_cross = is_cross }, netCallback)
    else
        self.m_model:setCurCross(is_cross)
        self.m_view:refreshUI(true)
    end
end

return M