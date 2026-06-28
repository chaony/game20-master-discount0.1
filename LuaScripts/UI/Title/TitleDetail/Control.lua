local M = class("TitleDetailControl",LikeOO.OOControlBase)

function M:onEnter()
    if SceneManager.curScene.showMove ~= nil then
        SceneManager.curScene.showMove:SetDepth(80)
    end
    audio:SendEvtUI("Play_UI_Popup_1")
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "buy_btn" then
        if self.m_model.m_cost then
            if self.m_model.m_ok_call_func then
                self:updateMsg(99999)
                if self.m_model.m_ok_call_func then
                    local params = {}
                    if self.m_model.m_isToday then
                        params = {isToday = self.m_view.today_callback,cur_server_ts = self.m_view.cur_server_ts,reward_isOk = true}
                    end
                    self.m_model.m_ok_call_func(params)
                end
                
            end
        end
    elseif msg == "today_btn" then
        self.m_view.today = not self.m_view.today
        self.m_view:todayIsActive()
    end
end

function M:destroy()
    M.super.destroy(self)
    if SceneManager.curScene.showMove ~= nil then
        SceneManager.curScene.showMove:SetDepth(120)
    end
end

return M
