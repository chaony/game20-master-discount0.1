local M = class("SharePosterControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then
        if self.m_model.m_moon_shadow_flag == true and self.m_model.m_callback then
            self.m_model.m_callback()
        end
        self:closeView()
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
	M.super.destroy(self)
end

return M;
