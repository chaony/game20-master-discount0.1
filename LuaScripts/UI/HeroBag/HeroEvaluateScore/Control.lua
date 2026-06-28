local M = class("HeroEvaluateScoreControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "CloseBtn" then    -- 返回
        self:closeView()
    elseif msg == "ok_btn" then
        local params = {}
        params.m_num = self.m_model.m_num
        self:updateMsg("update_score", params, "HeroBag.HeroEvaluate")
        self:closeView()
    elseif string.find(msg,"star_")  then
        self.m_view:clickCallback(msg)

    end
end

return M