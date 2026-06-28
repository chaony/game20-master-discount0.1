local M = class("DaySevenSPCardPopControl", LikeOO.OOControlBase)

function M:onEnter()
    audio:SendEvtUI("UI_Popup_N1")
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        if self.m_model.m_callback then
            self.m_model.m_callback(self.m_model.m_callback_new)
        end
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "get_day_btn" then
        local type = self.m_model:getStatus(self.m_model.m_day)
        if type == 2 or type == 4 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0058"), delay_close = 2})
            return
        end
        local index = self.m_model:getCurCanGotAwardDay()
        if (self.m_model.m_version == 1) and (index == 7) then
            self.m_view:specialDayBtnEvent()
        else
            self:getSeven_Tour(index)
        end
    end
end

function M:getSeven_Tour(index, heroIndex)
    local function callback(response)
        if response then
            if self.m_model.m_version == 1 and index == 2 or index == 7 then
                GameUtil:openAppRating() -- appStore评价
            elseif self.m_model.m_version == 2 and index == 7 then
                GameUtil:openAppRating() -- appStore评价
            end
            if response["end"] == 1 then
                if response.reward then
                    RewardUtil:rewardTipsByData(response.reward,nil, function ()
                        self:updateMsg(99999)
                        self:openAppRating(index)
                    end)
                end
                return
            end
            self.m_model:updateData(response)
            RewardUtil:rewardTipsByData(response.reward, nil, function ()
                if self.m_model:nextCanGet() == false then
                    self:updateMsg(99999)
                    self:openAppRating(index)
                end
            end)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.day = index
    params.version = self.m_model.m_version
    if heroIndex then
        -- 服务器从0开始
        params.item_index= (heroIndex - 1)
    end
    self.m_model:getNetData("active_receive_seven_tour", params, callback)
end

function M:openAppRating(index)
    if self.m_model.m_version == 1 and index == 2 or index == 7 then
        GameUtil:openAppRating() -- appStore评价
    elseif self.m_model.m_version == 2 and index == 7 then
        GameUtil:openAppRating() -- appStore评价
    end
end

return M
