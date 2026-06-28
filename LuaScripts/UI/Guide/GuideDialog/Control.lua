---@class GuideDialogControl:OOControlBase
local M = class("GuideDialogControl", LikeOO.OOControlBase)


function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then -- 关闭
        if self.m_model.m_eventType == 2 or self.m_model.m_eventType == 4 then -- 做提示用
        	self.m_model.m_guide:doNextGuide()
        elseif self.m_model.m_eventType == 3 then
            local clickCallFunc = self.m_model.m_clickCallFunc
            self.m_model.m_guide:doNextGuide()
            if clickCallFunc then
                clickCallFunc()
            end
        end
        self:closeView()
    elseif msg == "skip_btn" then
        local params = {
            on_ok_call = function(msg)
                UserDataManager.guide_data:skipCurGuide()
                self:closeView()
           end,
           no_close_btn = false,
           tow_close_btn = true,
           text = Language:getTextByKey("new_str_0465")
       }
       static_rootControl:openView("Pops.CommonPop", params);
    end
end

return M;