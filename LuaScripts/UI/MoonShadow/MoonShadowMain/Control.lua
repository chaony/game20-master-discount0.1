local M = class("MoonShadowMainControl",LikeOO.OOControlBase)

function M:onEnter()
   
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refresh_red_point", nil, "parent")
        self:closeView()
    elseif msg == "date_btn" then
        if self:checkOpenStatus(self.m_model.m_activity_openID_Date) then
            self:openView("MoonShadow.MoonShadowDate", {version = self.m_model:getVersion(self.m_model.m_activity_openID_Date), current_day = self.m_model:getCurrentDay(), score = self.m_model:getScore(), score_done = self.m_model:getScoreDone(), task_detail_data = self.m_model:getTaskDetailData()})
        end
    elseif msg == "gift_btn" then
        local open_status, tip_str = self.m_model:getActivityOpenStatus(self.m_model.m_activity_openID_Gift)
        if open_status == 2 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            return
        end
        local activity_item = self.m_model:getActivityData(self.m_model.m_activity_openID_Gift) or {}
        if self:checkOpenStatus(self.m_model.m_activity_openID_Gift) then
            self:openView("MoonShadow.MoonShadowGift", {version = self.m_model:getVersion(self.m_model.m_activity_openID_Gif), 
                                                        current_day = self.m_model:getCurrentDay(), gift_data = self.m_model:getGiftData(),
            end_ts = activity_item.end_ts})
        end
    elseif msg == "battle_btn" then
        local open_status, tip_str = self.m_model:getActivityOpenStatus(self.m_model.m_activity_openID_Battle)
        if self:checkOpenStatus(self.m_model.m_activity_openID_Battle) then
            self:openView("MoonShadow.MoonShadowBattle", {version = self.m_model:getVersion(self.m_model.m_activity_openID_Battle), 
                                                          enemy = self.m_model:getEnemy(), heirloom = self.m_model:getHeirloom(), 
                                                          max_damage = self.m_model:getMaxDamage(),
                                                          open_status = open_status})
        end
    elseif msg == "look_hero_info" then
        self:showHeroInfo()
    elseif msg == "share_btn" then
        self:openView("SharePoster", {version = 1, sort = 2, picture_id = 4, moon_shadow_flag = true, callback = function() self:updateMsg("refreshRedPointDate") end})--分享回来，刷新数据，确保月影之约中任务数据是最新的
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint()
    elseif msg == "refreshRedPointDate" or msg == "refreshRedPointGift" or msg == "refreshRedPointBattle" then
        local function netCallback(response)
            self.m_model:updateData(response)
            self.m_view:refreshRedPoint()
        end
        self.m_model:getNetData("mood_shadow_index", nil, netCallback)
    end
end

function M:checkOpenStatus(open_id)
    local status, tip_str = self.m_model:getActivityOpenStatus(open_id)
    if status == 0 then
        GameUtil:lookInfoTips(self, {msg = tip_str, delay_close = 2})
    end
    return status ~= 0
end

function M:showHeroInfo()
    self:closeView("Pops.HeroLookInfo",nil, false)
    self:openView("Pops.HeroLookInfo", {hero_id = 607, is_new = false})
end

return M
