local M = class("MedalInfoPopControl",LikeOO.OOControlBase)

function M:onEnter()
    --self.m_guide_file_name = "UI.SutraDepository.DepositoryPop.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "btn_ok" then
        if self.m_model.m_isWear then
            -- 卸下
        else
            -- 穿戴
        end
        self:closeView()
    end
end

return M
