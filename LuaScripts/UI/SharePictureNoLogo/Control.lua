local M = class("SharePictureControl",LikeOO.OOControlBase)

function M:onEnter()
    if GameMain.screen_effect then
        GameMain.screen_effect:setFrameVisibleStatus(false)
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "shot_end" then
        if self.m_model.m_picture_callback then
            self.m_model.m_picture_callback()
        end
    elseif msg == "save_btn" then
        self.m_view:SaveShare()
    elseif msg == "wechat_btn" then
        self.m_view:WechatShare()
    elseif msg == "wechatMoment_btn" then
        self.m_view:WechatMomentShare()
    elseif msg == "facebook_btn" then
        self.m_view:FacebookShare()

    elseif msg == "line_btn" then
        self.m_view:LineShare()
    end
end

function M:shareRequest()
    local function Callback(response)

    end
    local params = {}
    params.sort = self.m_model.m_sort
    self.m_model:getNetData("user_share", params, Callback)
end

function M:destroy()
    if GameMain.screen_effect then
        GameMain.screen_effect:setFrameVisibleStatus(true)
    end
	M.super.destroy(self)
end

return M;
