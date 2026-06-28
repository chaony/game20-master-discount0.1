local M = class("UnionWarRewardPopControl",LikeOO.OOControlBase)


function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "recall_btn" then 
        self:requestRecall(data.team_id)
    elseif type(msg) == "number" and msg >= 1 and msg <= 3 then
        self:switchTabBtn(msg)
    end
end

function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_view:switchTabNode(index)
    end
end


return M