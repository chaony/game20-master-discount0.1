local M = class("BossFightRewardControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()

    elseif msg == "race" then
        self.m_view.m_race_type = data.value.type
        self.m_view:refreshUI()
    elseif msg == "type" then
        self.m_view.m_type_type = data.value.type
        self.m_view:refreshUI()
    end
end

return M
