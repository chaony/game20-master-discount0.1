local M = class("LanternFestivalView",LikeOO.OOPopBase)

M.m_uiName = "LanternFestival/LanternFestival"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})

    self.m_gray_image = self:findImage("gray_img")
    self:refreshUI()
    self:setTextByLanKey("close_title_text", "lantern_festival_text_0001")
    self:setTextByLanKey("fun_play_text", "lantern_festival_text_0002")
    self:setTextByLanKey("guess_text", "lantern_festival_text_0003")
    self:setTextByLanKey("market_text", "lantern_festival_text_0004")
    self:setTextByLanKey("shop_text", "lantern_festival_text_0005")
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})
    M.super.destroy(self)
end

function M:everyDayRefreshEvent()
    self:updateMsg("refresh_index")
end

function M:refreshUI()
    --快速导航
    --self:setObjectVisible("guide_btn", true)
    --local guide_btn_obj = self:findGameObject("guide_btn")
    --if guide_btn_obj then
    --    guide_btn_obj.transform.localPosition = Vector3(273, -22.9, 0)
    --end
    self:refreshLantern()
    self:refreshDailyNode()
    self:refreshRedPoint()
end

function M:refreshLantern()
    for i = 1, 7 do
        self:setTextByLanKey("lantern_btn_text" .. i , "lantern_festival_text_0006")
    end
end

function M:refreshDailyNode()
    self:setObjectVisible("daily_sign_node", true)
    for i = 1, 7 do
        self:setTextByLanKey("daily_sign_text" .. i, "day_str_" .. i)
    end
end

function M:updateActivityTimer()
    local end_ts = self.m_model:getEndTs()
    if end_ts >= 0 then
        local text = GameUtil:formatTimeBySecond(end_ts, 999)
        text = Language:getTextByKey("new_str_0919") .. text
        self:setTextByLanKey("count_time_text", text)
    else
        self:updateMsg("refresh_index")
    end
end

function M:refreshRedPoint()
    local open_status = self.m_model:getActStatus()
    local guess_flag = self.m_model:getRiddlesRedPoint()
    self:setObjectVisible("guess_red_point_img", guess_flag and open_status == 1)
    
    local market_flag = RedPointUtil:hasRedPointById(273)
    self:setObjectVisible("market_red_point_img",market_flag and open_status == 1)
    
    local gift_flag = RedPointUtil:hasRedPointById(275)
    self:setObjectVisible("shop_red_point_img",gift_flag and open_status == 1)
    
    local fun_play_flag =  self.m_model:getFunPlayRedPoint()
    self:setObjectVisible("fun_play_red_point_img", fun_play_flag and open_status == 1)
end

return M