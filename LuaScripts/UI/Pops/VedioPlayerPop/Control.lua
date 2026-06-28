local M = class("CommonItemTipsPopControl",LikeOO.OOControlBase)

function M:onEnter()
    audio:PauseMusicBusVol()
end

function M:onHandle(msg , data)
    if msg == 99999 then
        if self.m_model.m_close_view_flag == false then
            if self.m_model.m_callback then
                self.m_model.m_callback()
            end
        else
            if self.m_model.m_callback then
                self.m_model.m_callback()
            end
            self:closeView()
        end
    end
end

function M:destroy()
    audio:ResumeMusicBusVol()
    M.super.destroy(self)
end

return M;
