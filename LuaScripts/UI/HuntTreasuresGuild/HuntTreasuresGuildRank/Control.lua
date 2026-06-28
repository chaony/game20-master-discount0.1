local M = class("HuntTreasuresGuildRankControl",LikeOO.OOControlBase)

function M:onEnter()
    self:questForInsideRankData()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "check_tag" then
        self:switchTabBtn(data)
    end
end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_view:switchNode(index)
    end
end

--请求帮内排行的数据
function M:questForInsideRankData()
    local function netCallback(response)
        if response then
            self.m_model:initInsideRankData(response)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.ver = self.m_model.m_params.version or 1
    params.start = 1
    params.stop = 20
    params.sort = 2
    self.m_model:getNetData("active_mining_rank", params, netCallback)
end

return M
