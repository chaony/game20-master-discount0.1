local M = class("LuckyDogMainControl",LikeOO.OOControlBase)

function M:onEnter()
    self:UpdateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.UpdateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "get_gift" then
        self:getGift(data)
    elseif msg == "shop_btn" then
        self:openView("LuckyDog.LuckyDogShop", {open_id = self.m_model:getOpenID(), version = self.m_model:getVersion(), library = self.m_model:getLibrary()})
    elseif msg == "refresh_data" then
        self:refreshData()
    elseif msg == "explain_btn" then
        local active_data = self.m_model:getActiveData() or {}
        local active_des = self.m_model:getActiveDes() or ""
        self:openView("Pops.CommonHelpPop", {title = active_data.name or "", content = active_des})
    end
end

function M:getGift(data)
    if self.m_model:isShowTime() then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("lucky_dog_019"), delay_close = 2})
        return 
    end
    if data.amount >= data.cfg.count then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("lucky_dog_016"), delay_close = 2})
        return
    end
    if data.loot_times >= data.cfg.limit then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("lucky_dog_018"), delay_close = 2})
        return
    end
    local amount_left = (data.cfg.count - data.amount) / data.cfg.push_count
    local count_left = data.cfg.limit - data.loot_times
    local min_num = amount_left
    if count_left < amount_left then
        min_num = count_left
    end
    local params =
    {
        --内容
        msg = Language:getTextByKey("lucky_dog_004"),
        --标题
        title = "",
        --最大购买次数
        max_buyNum = min_num,
        --消耗
        cost = data.cfg.push_count,
        --点击购买
        clickBuy = function(num)
            local function netCallback(response)
                if response.loot_faild == true then
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("lucky_dog_017"), delay_close = 2})
                else
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("lucky_dog_012"), delay_close = 2})
                end
                self.m_model:updateGiftData(response)
                self.m_view:refreshUI();
            end
            local params = {}
            params.open_id = self.m_model:getOpenID()
            params.vsn = self.m_model:getVersion()
            params.reward_id = data.id
            params.times = num
            self.m_model:getNetData("lucky_treasure_loot", params, netCallback)
        end
    }
    self:openView("LuckyDog.LuckyDogDrawPop", params)
end


function M:refreshData()
    local function netCallback(response)
        self.m_model:updateGiftData(response)
        self.m_view:refreshUI();
    end
    local params = {}
    params.open_id = self.m_model:getOpenID()
    params.vsn = self.m_model:getVersion()
    self.m_model:getNetData("lucky_treasure_index", params, netCallback)
end

--计时器
function M:UpdateTime(_, dt)
    dt = dt or 0
    self.m_view:updateActivityTimer()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
