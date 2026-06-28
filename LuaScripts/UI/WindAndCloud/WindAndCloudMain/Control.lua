local M = class("WindAndCloudMainControl",LikeOO.OOControlBase)

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        --self:updateMsg("refresh_red_big_point", nil, "parent")
        self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensSelectGiftBagPop")
        self:closeView()
    --刷新红点
    elseif msg == "refresh_red_point" then
        local flag = false
        local active_data = UserDataManager:getActivesDataByOpenId(407)
        if active_data then
            local function netCallback(response)
                if self.m_view then
                    local states = response.status or 0
                    flag = states == 1
                    self.m_view:refreshRedPoint(flag)
                end
            end
            local params = {}
            params.open_id = active_data.open_id
            params.vsn = active_data.version
            self.m_model:getNetData("redbag_red_dot", params, netCallback)
        else
            flag = false
            self.m_view:refreshRedPoint(flag)
        end
    elseif msg == "explain_btn" then
        local title_name = ""
        if self.m_model.active_data then
            title_name = self.m_model.active_data.name
        end
        self:openView("Pops.CommonHelpPop", {title = title_name, content = "tid#DiamondEvent_1"})
    else
        self:tryOpenItem(msg)
    end
end

function M:tryOpenItem(btn_name)
    local item = self.m_model:getItem(btn_name)
    if self.m_model:getItemTimeLimit(btn_name) == 2 and not item.show_start_open then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_xi_050"), delay_close = 2})
        return
    end
    if not item.show_start_open then
        local active_data = self.m_model:getActiveData(item.open_id)
        if active_data then
            local server_time = UserDataManager:getServerTime()
            if  server_time >= GameUtil:stringToTimesTamp(active_data.end_time) then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_xi_050"), delay_close = 2})
                return
            end
        end
    end
    if item then
        if item.open_id == 375 then --团购狂欢
            local function netCallback(response)
                if response.update then
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
                    self:closeView()
                    return
                end
                if response["end"] then
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
                    self:closeView()
                    return
                end
                response.is_token = self.m_model:getTokenFlag()
                self:openView("WindAndCloud.WindAndCloudRedPacket", response)
            end
            self.m_model:getNetData("valentine_festival_box_index", nil, netCallback)
        else
            local show_active_data = self.m_model:getActiveData(item.open_id) or {}
            self:openView("WindAndCloud."..item.prefab_name, {is_token = self.m_model:getTokenFlag(),open_id = item.open_id,active_data = show_active_data})
        end
    end
end

return M
