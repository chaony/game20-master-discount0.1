local M = class("FiveLinesRankControl",LikeOO.OOControlBase)

function M:onEnter()
    self:switchTabBtn(1)
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif type(msg) == "number" and msg >= 1 and msg <= 2 then
        self:switchTabBtn(msg)
    end
end

-- tab按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_view:switchTabNode(index)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
