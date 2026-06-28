local M = class("InGameNoticePopControl",LikeOO.OOControlBase)

function M:onEnter()
    self:getSDKNotice()
end

--请求公告
function M:getSDKNotice()
    if SDKUtil.is_gmsdk then
        SDKUtil:getNotice(
                function(params)
                    if self.m_model then
                        self.m_model.m_notice = params.data
                        self.m_view:refreshUI()
                    end
                end,
                13
        )
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then
        if self.m_model.m_callback then
            self.m_model.m_callback(self.m_model.m_callback_new)
        end
        self:closeView()
    elseif msg == "gouxuan_di" then --公告显示提示
        self.m_model.callback_time = UserDataManager.local_data:getUserDataByKey("gameNotice", nil)
        if self.m_model.callback_time ~= nil then
            UserDataManager.local_data:setUserDataByKey("gameNotice",nil)
        else
            UserDataManager.local_data:setUserDataByKey("gameNotice",UserDataManager:getServerTime())
        end
        self.m_view:refreshGouXuan()
    elseif msg == "left_btn" then --上一个按钮
        self.m_model.current_id = self.m_model.current_id - 1
        self.m_view:refreshUI()
    elseif msg == "right_btn" then --下一个按钮
        self.m_model.current_id = self.m_model.current_id + 1
        self.m_view:refreshUI()
    elseif msg == "goto_btn" then --前往
        if self.m_model.targetUrl ~= nil then
            local url = self.m_model.targetUrl
            local token = UserDataManager.client_data:getSdkToken()
            local role_id = UserDataManager.user_data:getUid()
            local server_id = UserDataManager.server_data:getServerId()
            if url:find("?") then
                url = url.."&"
            else
                url = url.."?"
            end
            local new_url = url.."access_token="..token.."&role_id="..role_id.."&server_id="..server_id or ""
            SDKUtil:openUrl(new_url)
        end
    end
end

return M;
