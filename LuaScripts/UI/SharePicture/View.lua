local M = class("SharePictureView",LikeOO.OOPopBase)

M.m_uiName = "SharePicture/SharePicturePop"
M.m_size_type = 2

function M:onEnter()
    local shot_node = self:findRectTransform("shot_node")
    local shot_img_rect = self:findRectTransform("shot_img")
    shot_img_rect.sizeDelta = Vector2(shot_node.rect.width, shot_node.rect.height)
    local mask_node = self:findRectTransform("mask_node")
    local scale_x = mask_node.rect.width/ shot_node.rect.width
    local scale_y = mask_node.rect.height/ shot_node.rect.height
    self.scale = math.min(scale_x, scale_y)
    Logger.log(self.scale)
    shot_img_rect.localScale = Vector3(self.scale, self.scale, self.scale)
    self.shot_img_rect = shot_img_rect
    self:setObjectVisible("logo_img_2", false)
    local server_data = UserDataManager.server_data:getServerData()
    local name = UserDataManager.user_data:getUserStatusDataByKey("name")
    local bundleid = SDKUtil.sdk_params.applicationId or ""
    if bundleid == "com.hermes.wl" then
        self:setObjectVisible("wechatMoment_btn", true)
        --self:setObjectVisible("name_bg_QR", true)
        self:setObjectVisible("name_bg_QR_2", true)
        --self:setObjectVisible("name_bg", false)
        self:setObjectVisible("name_bg_2", false)
        self:setText("name_text_QR",name)
        self:setText("name_text_QR_2",name)
        self:setText("server_text_QR",server_data.server_name)
        self:setText("server_text_QR_2",server_data.server_name)
        --self:setImg( "a_fx_lgq","language_zh_cn","logo_img")
        self:setImg( "a_fx_lgq","language_zh_cn","logo_img_2")
    else
        self:setObjectVisible("wechatMoment_btn", false)
        --self:setObjectVisible("name_bg_QR", false)
        self:setObjectVisible("name_bg_QR_2", false)
        --self:setObjectVisible("name_bg", true)
        self:setObjectVisible("name_bg_2", true)
        self:setText("name_text",name)
        self:setText("name_text_2",name)
        self:setText("server_text",server_data.server_name)
        self:setText("server_text_2",server_data.server_name)
        --self:setImg( "a_fx_lgq","language_zh_cn","logo_img")
        self:setImg( "a_fx_lgq","language_zh_cn","logo_img_2")
    end
    
    self:setObjectVisible("content_node", false)
    self:setObjectVisible("logo_node", true)
    self.shot_img = self:findRawImage("shot_img")
    self.SharePicture = self:findGameObject("shot_node"):GetComponent("SharePicture")
    if self.SharePicture then
        self.SharePicture:ShotScreen(function()
            self:savePicture()
            self:setObjectVisible("logo_node", false)

            --self.SharePicture:ShotScreen(function()
            self:setObjectVisible("content_node", true)
            self:updateMsg("shot_end")
            local tex = self.SharePicture.tex
            if tex then
                self.shot_img.texture = tex
            end
            --end)
        end)
    else
        self:updateMsg("shot_end")
        self:updateMsg(99999)
    end

    self:setObjectVisible("facebook_btn", false)
    self:setObjectVisible("line_btn", false)

end

function M:savePicture()
    --self.SharePicture:CreateSaveTexture( math.floor(self.shot_img_rect.rect.width),  math.floor(self.shot_img_rect.rect.height))
    self.SharePicture:SavePicture()
end

function M:WechatMomentShare()
    if self.SharePicture and self.SharePicture.WechatMomentShare then
        self.SharePicture:WechatMomentShare(function(resut, code)
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
    if self.SharePicture and self.SharePicture.WechatShare then
        self.SharePicture:WechatShare(function(resut, code)
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
    if self.SharePicture and self.SharePicture.SaveImageShare then
        self.SharePicture:SaveImageShare(function(resut, code)
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
    if self.SharePicture and self.SharePicture.FacebookShare then
        self.SharePicture:FacebookShare(function(resut, code)
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
    if self.SharePicture and self.SharePicture.LineShare then
        self.SharePicture:LineShare(function(resut, code)
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