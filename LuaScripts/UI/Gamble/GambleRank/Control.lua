local M = class("GambleRankControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "check_tag" then
        self:switchTabBtn(data)
    elseif msg == "load_rank" then
        self:loadRank()
    end
end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_view:switchNode(index)
    end
end

function M:loadRank()
    local cur_num, total_num = self.m_model:getRankNums()
    if cur_num >= 50 or cur_num >= total_num then
        return
    end
    self.m_view:lockTouch()
    local function netCallback(response)
        self.m_view:unlockTouch()
        self.m_model:updateRankData(response)
        self.m_load_end = true
        self.m_view:refreshUI()
    end
    local params = {}
    params.open_id = self.m_model:getOpenID()
    params.version = self.m_model:getVersion()
    params.start = cur_num + 1
    params.stop = cur_num + 20
    if params.stop > 50 then
        params.stop = 50
    end
    self.m_model:getNetData("world_cup_ranks", params, netCallback, true, true)
end


return M
