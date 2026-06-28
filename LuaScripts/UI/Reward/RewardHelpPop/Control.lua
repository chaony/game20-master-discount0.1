--悬赏列表
local M = class("RewardHelpPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "select_hero" then
        self.m_model.m_select_oid = data
        self.m_view:refreshUI()
    elseif msg == "ok_btn" then
        if self.m_model.m_callback and self.m_model.m_select_oid ~= "" then
            self.m_model.m_callback(self.m_model.m_parent_index, self.m_model.m_select_oid)
        end
        self:updateMsg(99999)
    end
end


return M;
