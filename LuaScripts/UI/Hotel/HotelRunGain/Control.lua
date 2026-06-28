local M = class("HotelRunGainControl", LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Hotel.HotelRunGain.Guide"
end

function M:onHandle(msg, data)
    if msg == 99999 or msg == "close_btn" then -- 关闭
        self:updateMsg("play_gain", self.m_model.m_outputs, "Hotel.HotelHall")
        --解锁房间飘字
        if self.m_model.m_unlock ~= nil then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("hotel_text_040", self.m_model.m_unlock), delay_close = 2})
        end
        self:closeView()
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M