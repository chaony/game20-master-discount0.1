---@class ArenaNormalRewardControl:OOControlBase
local M = class("ArenaNormalRewardControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "ok_btn" then
        self:updateMsg(99999)
    elseif msg == "tab_btn" then
        if data ~= self.m_model.m_tab_index then
            self.m_model:setTabIndex(data)
            self.m_view:refreshUI()
        end
    elseif msg == "time_update_end_refresh" then
        self:updateMsg(99999)
        self:updateMsg("refresh_ui",nil,"Arena.ArenaNormal.ArenaNormal")
    end
end

return M
