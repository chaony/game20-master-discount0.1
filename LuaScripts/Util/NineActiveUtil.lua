local M = {}

local ACTIVE_NINE_TAB = {
    {ingameId = "4001",open_view_name = "Xian",refresh_fun_name = "refreshNineActiveRedPoint"}
}

function M:linstenNineActive()
    SDKUtil:listenNativeNotification(function(params)
        --监听消息
        if params ~= nil and params.data ~= nil then
            local active_data = Json.decode(params.data)
            if active_data.action ~= nil then
                if active_data.action == "refresh_icon" then --刷新活动红点接口
                    --刷新活动  刷新活动红点和活动数据
                    if self.active_id then
                        for i, v in pairs(ACTIVE_NINE_TAB) do
                            if v.ingameId == self.active_id then
                                static_rootControl:updateMsg(v.refresh_fun_name,nil,v.open_view_name)
                            end
                        end
                    end
                elseif active_data.action == "error_message" then --错误提示
                    if active_data.params.error_code == "3001" then --活动已下线
                        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
                        --刷新活动
                        self:setIconActive()
                    else
                        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0245"), delay_close = 2})
                    end
                elseif active_data.action == "jump_unity" then --跳转
                    if active_data.params.data.pageID ~= nil then
                        QuickOpenFuncUtil:openFunc(active_data.params.data.pageID)
                    end
                elseif active_data.action == "window_status_change" then --关闭事件监听
                    if active_data.params ~= nil and active_data.params.pageType ~= nil then
                        if active_data.params.pageType == 1 then --拍脸
                            if self.face_callback then
                                self.face_callback(self.face_callback_new)
                            end
                        elseif active_data.params.pageType == 2 then  --活动中心
                            static_rootControl:closeView("Activities.NineActiveMain.NineActiveMain",nil,false)
                        end
                    end
                end
            end
        end
    end)
end

--设置拍脸回调
function M:setFaceClose(callback,callback_new)
    self.face_callback = callback
    self.face_callback_new = callback_new
end

function M:setIconActive(activityId)
    self:getIconClickList()
    self:getIconClickRedPoint(activityId)
    if self.active_id then
        for i, v in pairs(ACTIVE_NINE_TAB) do
            if v.ingameid == self.active_id then
                static_rootControl:updateMsg(v.refresh_fun_name,nil,v.open_view_name)
            end
        end
    end
end

--获取活动中心列表
function M:getIconClickList()
    SDKUtil:openFaceVerify(function(params)
        if params ~= nil and params.data ~= nil then
            self.icon_click_data = params.data
        end
    end,"icon_click")
end

--获取是否有对应的活动
function M:isHasIconData(ingameid)
    if self.icon_click_data then
        for i, v in ipairs( self.icon_click_data) do
            if v.inGameId == ingameid then
                return v
            end
        end
    end
    return nil
end

--获取活动中心红点
function M:getIconClickRedPoint(activityId)
    local activityIds = activityId or "icon_click"
    if activityId ~= nil then
        SDKUtil:queryActivityNotifyDataById(function(params)
            if params ~= nil and params.data ~= nil then
                for i, v in ipairs(params.data) do
                    if v.type == 0 then
                        self.icon_click_red_point = false
                    else
                        if v.count > 0 then
                            self.icon_click_red_point = true
                        end
                    end
                end
            end
        end,activityIds)
    else
        SDKUtil:queryActivityNotifyDataByType(function(params)
            if params ~= nil and params.data ~= nil then
                for i, v in ipairs(params.data) do
                    if v.type == 0 then
                        self.icon_click_red_point = false
                    else
                        if v.count > 0 then
                            self.icon_click_red_point = true
                        end
                    end
                end
            end
        end,activityIds)
        --static_rootControl:updateMsg("refresh_red_point", nil, "parent")
    end
end



return M