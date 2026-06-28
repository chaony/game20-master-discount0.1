local M = class("DragonBoatControl",LikeOO.OOControlBase)

function M:onEnter()
    audio:SendEvtBGM("Set_State_Spring")
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if self.m_model.is_tokens == true then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensEntrancPop")
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensSelectGiftBagPop")
        end
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "btn_1" then --粽情好礼（签到活动）
        if (self.m_model:getItemTimeLimit(msg) == 2 or self.m_model:getItemTimeLimit(msg) == 0)  then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_xi_050"), delay_close = 2})
            return
        end
        if self.m_model:getActStatus() == 1 then
            RedPointUtil:saveLocalRedPointFreshTime("dragonBoat_signIn_once")
            local params = {
                openId = 353,
                version = self.m_model.m_data.version
            }
            self:openView("Activities.DragonBoat.DragonBoatSignIn",params)
            self.m_view:refreshRedPoint()
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        end
        -- self:openView("Activities.EnjoySpring.LiteratureSharePop")
    elseif msg == "btn_2" then--粽意礼包（礼包） 
        if (self.m_model:getItemTimeLimit(msg) == 2 or self.m_model:getItemTimeLimit(msg) == 0)  then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_xi_050"), delay_close = 2})
            return
        end
        if self.m_model:getActStatus() == 1 then
            self:openView("Activities.DragonBoat.DragonBoatGiftBag", {is_token = self.m_model.m_is_token,openId = 354,versionId = self.m_model.m_data.version})
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        end
    elseif msg == "btn_3" then --美味兑换（兑换活动）
        if (self.m_model:getItemTimeLimit(msg) == 2 or self.m_model:getItemTimeLimit(msg) == 0)  then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_xi_050"), delay_close = 2})
            return
        end
        if self.m_model:getActStatus() == 1 then
            local params = {
                openId = 355,
                versionId = self.m_model.m_data.version
            }
            self:openView("Activities.DragonBoat.DragonBoatExchange", params)
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        end
    elseif msg == "btn_4" then --流觞曲水
        if (self.m_model:getItemTimeLimit(msg) == 2 or self.m_model:getItemTimeLimit(msg) == 0)  then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_xi_050"), delay_close = 2})
            return
        end
        if self.m_model:getActStatus() == 1 then
            local params = {}
            params.version = self.m_model.m_data.version
            params.openId = 356
            self:openView("Activities.DragonBoat.DragonBoatLinkGame", params)
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        end
    elseif msg == "btn_5" then --厨神争霸(排行榜)
        if (self.m_model:getItemTimeLimit(msg) == 2 or self.m_model:getItemTimeLimit(msg) == 0)  then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_xi_050"), delay_close = 2})
            return
        end
        if self.m_model:getActStatus() == 1 or self.m_model:getActStatus() == 2  then
            local params = {}
            params.version = self.m_model.m_data.version
            params.openId = 326
            self:openView("Activities.DragonBoat.DragonBoatRank", params)
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        end
    elseif msg == "btn_6" then --做饭
        if (self.m_model:getItemTimeLimit(msg) == 2 or self.m_model:getItemTimeLimit(msg) == 0)  then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_xi_050"), delay_close = 2})
            return
        end
        local show_mode = self.m_model:getCurrentActiveMode()
        if self.m_model:getActStatus() == 1 then
            local params = {}
            params.versionId = self.m_model.m_data.version
            params.openId = 323
            params.got_milepost_reward = self.m_model.m_data.got_milepost_reward
            params.total_cook_times = self.m_model.m_data.total_cook_times
            if show_mode == 1 then
                self:openView("Activities.DragonBoat.DragonBoatCookThree", params)
            else
                self:openView("Activities.DragonBoat.DragonBoatCook", params)
            end
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        end
    elseif msg == "update_data" then
        self:updateData(data)
    elseif msg == "update_question" then
        self.m_model.m_data.cur_question = data
    elseif msg == "refresh_literatureRedDot" then
        self.m_view:refreshRedPoint()
    end
end

function M:updateData(data)
    local function callback(response)
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
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("feast_main_index", nil, callback)
end

--计时器
function M:updateTime()
    self.m_view:updateActivityTimer()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    SceneManager:getCurSceneView():setBGMusic()
    M.super.destroy(self)
end

return M;
