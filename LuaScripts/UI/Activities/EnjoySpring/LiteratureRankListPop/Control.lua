local M = class("LiteratureRankListPopControl",LikeOO.OOControlBase)

function M:onEnter()
    --每隔1秒执行一次
    self:setTimer(1,function()

    end)
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
    if cur_num >= 100 or cur_num >= total_num then
        return
    end
    self.m_view:lockTouch()
    local function netCallback(response)
        --Logger.log(response,"loadRank ====")
        self.m_view:unlockTouch()
        self.m_model:updateRank(response)
        self.m_load_end = true
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("enjoy_spring_rank_info", {start = cur_num + 1, stop = cur_num + 20}, netCallback, true, true)
end

return M
