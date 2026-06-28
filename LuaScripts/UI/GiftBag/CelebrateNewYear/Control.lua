local M = class("CelebrateNewYearControl", LikeOO.OOControlBase)

function M:onEnter()
    audio:SendEvtBGM("Set_State_ZhuJianDaHui")
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensEntrancPop")
        if self.m_model.is_token then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensSelectGiftBagPop")
        end
        self:updateMsg("common_refresh" ,nil ,"parent")
        self:closeView()
    elseif msg == "refresh_data" then
        if data then
            self.m_model:updateData(data)
            self.m_view:refreshUI()
        end
    elseif msg == "update_data" then --主动刷新所有数据
        self:updateData()
        self.m_view:refreshUI()
    elseif msg == "help_btn" then
        local spring_festival = ConfigManager:getCfgByName("spring_festival")
        local versionData = spring_festival[self.m_model.version] or {}
        local content = versionData.des
        local open_data = self.m_model:getActiveCfgByOpenId(261)
        local titleName = open_data.name
        self:openView("Pops.CommonHelpPop", { title = titleName, content = content })
    elseif msg == "refresh_red_point" then
        self.m_view:refreshRedPoint()
    else
        for i, v in ipairs(self.m_view.LOCAL_TAB) do
            if msg == v.btn_name then
                local open_id = v.open_id
                local is_open, open_tips = self.m_model:isActOpenByOpenId(open_id)
                if self.m_model:checkActivesEnd(open_id) == false then
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
                    self:updateMsg(99999)
                    return
                end
                if is_open then
                    StatisticsUtil:doPointActive(is_open,v.enter_data.version)
                    v.enter_data.is_token = self.m_model.is_token or false
                    if open_id == 264 then
                        self:openNewYearTeam(v.lua_name, v.enter_data)
                    else
                        self:openView(v.lua_name, v.enter_data)
                    end
                else
                    if open_tips == "refresh_index" then
                        if self.m_model.m_refresh_times < self.m_model.m_max_refresh_times then
                            self.m_model.m_refresh_times = self.m_model.m_refresh_times + 1
                            local function callBack()
                                self.m_view:refreshUI()
                                self:updateMsg(msg)
                            end
                            self:updateData(callBack)
                        else
                            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_1087"), delay_close = 2})
                            self:updateMsg(99999)
                        end
                    else
                        GameUtil:lookInfoTips(self, {msg = open_tips, delay_close = 2})
                    end
                end
            end
        end
    end
end

function M:updateData(callBack)
    self.m_model:getNetData("spring_festival_index",nil, function( response )
        self.m_model:updateData(response)
        if callBack then
            callBack()
        end
    end)
end

function M:openNewYearTeam(lua_name, enter_data)
    local function netCallback(response)
        if response then
            self:netCheckEndTips(response)
            self:openView(lua_name, enter_data)
        end
    end
    self.m_model:getNetData("spring_festival_enter_check",{open_id = 264},netCallback)
end

function M:netCheckEndTips(response)
    if response and response["end"] == 1 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
        self:updateMsg(99999)
    end
end

function M:destroy()
    SceneManager:getCurSceneView():setBGMusic()
    M.super.destroy(self)
end

return M
