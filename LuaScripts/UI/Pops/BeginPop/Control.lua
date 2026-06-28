local M = class("BeginPopControl", LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg, data)
    if msg == 99999 or msg == "close_btn" then -- 返回
        self:endTask()
    elseif msg == "jump_btn" or msg == "main_pic" then
        local popData = self.m_model.m_params.pop_data

        local doJump = false
        if popData.jump then
            local jump = ConfigManager:getCfgByName("jump")
            local jump_item = jump[popData.jump]
            if jump_item then
                QuickOpenFuncUtil:openFunc(popData.jump)
                doJump = true
            end
        end

        if not doJump then
            local url = popData.target_url
     
            local server_id = UserDataManager.server_data:getServerId()
            local role_id = UserDataManager.user_data:getUid()

            if url:find("?") then
                url = url.."&"
            else
                url = url.."?"
            end
            
            SDKUtil:openUrl(url .. "role_id=" .. role_id .. "&server_id=" .. server_id)
        end
        self:setOnceTimer(
            0.3,
            function()
                self:endTask()
            end
        )
    end
end

function M:endTask()
    local end_call = self.m_model.m_params.end_call

    self:closeView()

    if end_call then
        end_call()
    end
end

return M
