local M = class("LoyaltyMainControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    --刷新红点
    elseif msg == "refresh_red_point" or msg == "refreshRedPoint" or msg == "refresh_data" then
        self.m_view:refreshRedPoint()
    elseif msg == "explain_btn" then
        local title_name = ""
        if self.m_model.active_data then
            title_name = self.m_model.active_data.name
        end
        self:openView("Pops.CommonHelpPop", {title = title_name, content = "tid#SpringFestivalDes"})
    else
        self:tryOpenItem(msg)
    end
end

function M:tryOpenItem(btn_name)
    local item = self.m_model:getItem(btn_name)
    if (self.m_model:getItemTimeLimit(btn_name) == 2 or self.m_model:getItemTimeLimit(btn_name) == 0) and not item.show_start_open then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_xi_050"), delay_close = 2})
        return
    end
    if item then
        local show_active_data = self.m_model:getActiveData(item.open_id) or {}
        local version = self.m_model:getActVsn(item.open_id,item.is_recharge)
        local params = {
            is_token = self.m_model:getTokenFlag(),
            open_id = item.open_id,
            active_data = show_active_data,
            version = version,
            is_show = self.m_model:getItemTimeLimit(btn_name),
            refresh_main = "Loyalty.LoyaltyMain",
            refresh_name = "Loyalty.LoyaltyMain"}
        if item.open_id == 438 then --武圣试炼
            params.is_show_break_btn = 1
        elseif item.open_id == 426 then
            params.items_table = {
                {open_id = 426, btn_name = "item_1_btn", prefab_folder = "NationalBeautiful",prefab_name = "NationalBeautifulDailyReward",show_name = true,show_name_text = "national_beautiful_text_0005",is_close_view = false}, 	--养成竞速
                {open_id = 438, btn_name = "item_2_btn", prefab_folder = "Chivalry",prefab_name = "ChivalryBattle",show_name = false,is_close_view = true}, 	--神都机关令
                {open_id = 314, btn_name = "item_3_btn", prefab_folder = "LuckyDraw",prefab_name = "LuckyDraw",show_name = false,is_close_view = true,jump_id = 100002}, 	--天香召唤
                {open_id = 420, btn_name = "item_4_btn", prefab_folder = "NationalBeautiful",prefab_name = "NationalBeautifulXkz",show_name = false,is_close_view = true}, 	--风起神都
            }
        end
        self:openView(item.prefab_folder.."."..item.prefab_name, params)
    end
end

function M:updateTime()
    self.m_view:updateActivityTimer()
end

return M
