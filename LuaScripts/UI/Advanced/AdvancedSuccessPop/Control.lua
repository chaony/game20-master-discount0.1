local M = class("AdvancedSuccessPopControl",LikeOO.OOControlBase)

function M:onEnter()
    audio:SendEvtUI("Ui_JinJie")
    self.m_guide_file_name = "UI.Advanced.AdvancedSuccessPop.Guide"
end

function M:startGuide()
    M.super.startGuide(self)
    --self:triggerGuide()
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "big_close_btn2" then
        self:closeView()
    end
end

function M:triggerGuide()
    local guide_info = UserDataManager.guide_data:getCurGuideInfo()
    if guide_info == nil or guide_info.key ~= "AdvancedSuccessPop" then
        if self.m_model:checkExclusive() then
            local id = ConfigManager:getCommonValueById(280)
            local have_guide = UserDataManager.guide_data:setAnyTeamGuide(id)
            if have_guide then
                local skip_flag = self.m_model:isSkipGuide()
                if skip_flag then
                    UserDataManager.guide_data:skipCurGuide()
                else
                    self.m_guide:checkGuide()
                end
            end
        end
    end
end

return M;
