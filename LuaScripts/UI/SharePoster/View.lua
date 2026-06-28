local M = class("SharePosterView",LikeOO.OOPopBase)

M.m_uiName = "SharePicture/SharePosterPop"
M.m_size_type = 2

function M:onEnter()
    local bundleid = SDKUtil.sdk_params.applicationId or ""
    self:setObjectVisible("wechatMoment_btn", bundleid == "com.hermes.wl")
    
    self.m_pic_name = self.m_model:getTexture()
    local shot_img = self:findImage("shot_img")
    GameUtil:updateResourcesImg(shot_img, "Texture/" .. self.m_pic_name)
    self.SharePoster = self:findGameObject("shot_node"):GetComponent("SharePoster")
    if self.SharePoster then
        self.SharePoster:SavePicture()
    else
        self:updateMsg(99999)
    end

    self:setObjectVisible("facebook_btn", false)
    self:setObjectVisible("line_btn", false)

end


function M:WechatMomentShare()
    if self.SharePoster and self.SharePoster.WechatMomentShare then
        self.SharePoster:WechatMomentShare(function(resut, code)
            if resut then
                self.m_control:shareRequest()
            else
                self:errorTips(code)
            end
        end)
    else
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_1043"), delay_close = 2})
    end
end

function M:WechatShare()
    if self.SharePoster and self.SharePoster.WechatShare then
        self.SharePoster:WechatShare(function(resut, code)
            if resut then
                self.m_control:shareRequest()
            else
                self:errorTips(code)
            end
        end)
    else
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_1043"), delay_close = 2})
    end
end

function M:SaveShare()
    if self.SharePoster and self.SharePoster.SaveImageShare then
        self.SharePoster:SaveImageShare(function(resut, code)
            if resut then
                GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_1044"), delay_close = 2})
            else
                self:errorTips(code)
            end
        end)
    else
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_1043"), delay_close = 2})
    end
end

function M:FacebookShare()
    if self.SharePoster and self.SharePoster.FacebookShare then
        self.SharePoster:FacebookShare(function(resut, code)
            if resut then
                self.m_control:shareRequest()
            end
            self:errorTips(code, true)
        end)
    else
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("sdk_update_fb"), delay_close = 2})
    end
end

function M:LineShare()
    if self.SharePoster and self.SharePoster.LineShare then
        self.SharePoster:LineShare(function(resut, code)
            if resut then
                self.m_control:shareRequest()
            end
            self:errorTips(code, false)
        end)
    else
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("sdk_update_line"), delay_close = 2})
    end
end

function M:errorTips(code, isFB)
    if code == 0 then
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("sdk_shared_succ"), delay_close = 2})
    elseif code == -410002 then
        if isFB then
            GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("sdk_update_fb"), delay_close = 2})
        else
            GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("sdk_update_line"), delay_close = 2})
        end    
    elseif code == -411002 then
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_1046"), delay_close = 2})
    elseif code == -419999 then
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_1052"), delay_close = 2})
    elseif code == -410001 then
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("sdk_share_cancel"), delay_close = 2})
    end
end

return M