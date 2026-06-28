local M = class("GuideGameDialogControl", LikeOO.OOControlBase)


function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "mask_img" then -- 关闭
        self.m_model.m_guide:doNextGuide()
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