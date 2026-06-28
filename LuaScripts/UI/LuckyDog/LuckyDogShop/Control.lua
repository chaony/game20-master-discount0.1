local M = class("LuckyDogShopControl", LikeOO.OOControlBase)

function M:onHandle(msg, data)
    if msg == 99999 then
        if self.m_view.start then
            return
        end
        self:updateMsg("refresh_data", nil, "LuckyDog.LuckyDogMain")
        self:closeView()
    elseif msg == "btn_one" then
        self:requestGacha(1)
    elseif msg == "btn_ten" then
        self:requestGacha(10)
    elseif msg == "btn_refresh" then
        self:requestRefresh()
    end
end

function M:requestGacha(times)
    if self.m_view.start then
        return
    end
    if self.m_model:hasEnoughScore(times * 10) == false then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("lucky_dog_011"), delay_close = 2})
        return
    end
    local function netCallback(response)
        if response then
            self.m_model:updateGiftData(response)
            self.m_view.m_fTime = 0
            self.m_view.m_fVelocity = 0
            self.m_view.time = nil
            audio:SendEvtUI("UI_TanCeLuoPan")
            self.m_view.start = true
            self:setOnceTimer(0.65, function()
                self.m_view.go = true
                self.m_view.is_play = false
            end)
        end
    end
    local params = {}
    params.open_id = self.m_model:getOpenID()
    params.vsn = self.m_model:getVersion()
    params.times = times
    self.m_model:getNetData("lucky_treasure_draw", params, netCallback)
end

function M:requestRefresh()
    if self.m_view.start then
        return
    end
    if self.m_model:hasEnoughScore(1) == false then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("lucky_dog_011"), delay_close = 2})
        return
    end
    local function netCallback(response)
        if response then
            self.m_model:updateGiftData(response)
            self.m_view:refreshUI()
            audio:SendEvtUI("UI_TanBao_Refresh")
        end
    end
    local params = {}
    params.open_id = self.m_model:getOpenID()
    params.vsn = self.m_model:getVersion()
    self.m_model:getNetData("lucky_treasure_refresh", params, netCallback)
end

return M