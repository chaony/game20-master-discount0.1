local M = class("GachaScorePopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "recruit_btn" then
        if self.m_model.m_score < self.m_model.m_score_consume then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("Pub_str_0048"), delay_close = 2})
            return
        end
        self:updateMsg("score_gacha", nil, "Pub")
    elseif msg == "refresh" then
        self.m_model.m_score = data
        self.m_view:refresh()
    end
end

return M