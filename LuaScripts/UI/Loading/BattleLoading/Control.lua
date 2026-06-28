local M = class("BattleLoadingControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_cur_rate = 0
    self.m_total_rate = self.m_model.m_show_time
    self.m_rate = self.m_total_rate / 50
    if self.m_rate then
        self:setTimer(self.m_rate,handler(self,self.UpdateSlider))
    end
    self:setOnceTimer(0.01, function()
        if type(self.m_model.m_callfunc) == "function" then
            self.m_model.m_callfunc("open_view")
        end
    end)
end

function M:UpdateSlider()
    self.m_cur_rate = self.m_cur_rate + self.m_rate
    local progress = self.m_cur_rate / self.m_total_rate
    self.m_view:updateSlider(progress)
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "formation_callback" then    -- 返回
        if type(self.m_model.m_callfunc) == "function" then
            self.m_model.m_callfunc()
        end
        self:closeView()
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
