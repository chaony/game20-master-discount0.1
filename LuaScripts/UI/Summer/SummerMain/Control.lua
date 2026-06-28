local M = class("SummerMainControl", LikeOO.OOControlBase)

function M:onEnter()
    audio:SendEvtUI("UI_BuYiXiongShi")
    self:setOnceTimer(0.1, function ()
        if self.m_model and self.m_model.m_open_sub_id and self.m_model.m_open_sub_id > 0 then
            if self.m_model.m_open_sub_id == 122 then
                self:updateMsg("btn_Admiration")
            elseif self.m_model.m_open_sub_id == 123 then
                self:updateMsg("btn_LouYueCaiYun")
            elseif self.m_model.m_open_sub_id == 124 then
                self:updateMsg("btn_LuckyCharm")
            elseif self.m_model.m_open_sub_id == 125 then
                self:updateMsg("btn_TreasureBox")
            end
        end
    end)
end

function M:onActiveEnd()
    UserDataManager.active_121_end = true
    static_rootControl:closeAllViewPop()
end

function M:onHandle(msg, date)
    if msg == 99999 then
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
        return
    end

    if (date and date["end"]) or UserDataManager.active_121_end then
        UserDataManager.active_121_end = true
        static_rootControl:closeAllViewPop()
        static_rootControl:updateMsg("refresh_red_point")

        return
    end
    local servTime = UserDataManager:getServerTime()

    if self.m_model and self.m_model.is_end then
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "btn_Admiration" then --飞龙乘云
        if self.m_model:getActive() ~= nil then
            StatisticsUtil:doPointActive(122,self.m_model.m_data.hero_vsn)
            local active_times = self.m_model:getActive()[122]
            if active_times.end_ts <= servTime or active_times.remain_ts == -1 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
                if active_times.show_ts <= servTime then
                    self:onActiveEnd()
                end
            else
                local m_params = {
                    hero_cfg = self.m_model:getHero(),
                    skin_cfg = nil,
                    hero_bought = self.m_model.m_data.hero_bought,
                    hero_vsn = self.m_model.m_data.hero_vsn,
                    active_time = active_times,
                    back_name = self.m_titleName[122]
                }
                if self.m_model.m_is_token == true and self.m_model.m_open_sub_id > 0 then
                    m_params.is_token = true
                end
                self:openView("Summer.Admiration", m_params)
            end
            if self.m_model.m_is_token == true and self.m_model.m_open_sub_id > 0 then
                self:closeView()
            end
        end
    elseif msg == "btn_TreasureBox" then --天机觅宝
        if self.m_model:getActive() ~= nil then
            StatisticsUtil:doPointActive(125,self.m_model.m_data.draw_vsn)
            local active_times = self.m_model:getActive()[125]
            if active_times.show_ts <= UserDataManager:getServerTime() then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
                self:onActiveEnd()
            else
                local params = {
                    draw_vsn = self.m_model.m_data.draw_vsn,
                    draw_box = self.m_model.m_data.draw_box,
                    draw_times = self.m_model.m_data.draw_times,
                    active_time = active_times,
                    tab_info = self.m_view:getTab(125),
                }
                self:openView("Summer.TreasureBox", params)
            end
        end
    elseif msg == "btn_LouYueCaiYun" then --乘龙有礼
        if self.m_model:getActive() ~= nil then
            StatisticsUtil:doPointActive(123,self.m_model.m_data.clothes_vsn)
            local active_times = self.m_model:getActive()[123]
            if active_times.end_ts <= UserDataManager:getServerTime() or active_times.remain_ts == -1 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
                if active_times.show_ts <= servTime then
                    self:onActiveEnd()
                end
            else
                local heroCfg, skinCfg = self.m_model:getSkin()
                local m_params = {
                    hero_cfg = heroCfg,
                    skin_cfg = skinCfg,
                    skin_bought = self.m_model.m_data.clothes_bought,
                    skin_vsn = self.m_model.m_data.clothes_vsn,
                    active_time = active_times,
                    back_name = self.m_titleName[123]
                }
                if self.m_model.m_is_token == true and self.m_model.m_open_sub_id > 0 then
                    m_params.is_token = true
                end
                self:openView("Summer.SkinShop", m_params)
                if self.m_model.m_is_token == true and self.m_model.m_open_sub_id > 0 then
                    self:closeView()
                end
            end
        end
    elseif msg == "btn_LuckyCharm" then --天降祥瑞
        --self:openView("Recharge.EverydayRechargePop")
        if self.m_model:getActive() ~= nil then
            StatisticsUtil:doPointActive(124,self.m_model.m_data.gift_vsn)
            local active_times = self.m_model:getActive()[124]
            if active_times.end_ts <= UserDataManager:getServerTime() or active_times.remain_ts == -1 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
                if active_times.show_ts <= servTime then
                    self:onActiveEnd()
                end
            else
                local m_params = {
                    gift_vsn = self.m_model.m_data.gift_vsn,
                    gift_buy_log = self.m_model.m_data.gift_buy_log,
                    active_time = active_times
                }
                if self.m_model.m_is_token == true and self.m_model.m_open_sub_id > 0 then
                    m_params.is_token = true
                end
                self:openView("Summer.LuckyCharm", m_params)
                if self.m_model.m_is_token == true and self.m_model.m_open_sub_id > 0 then
                    self:closeView()
                end
            end
        end
    elseif msg == "btn_LimitedTimeLogin" then --限时登录
        if self.m_model:getActive() ~= nil then
            StatisticsUtil:doPointActive(127,self.m_model.m_login_vsn)
            local active_times = self.m_model:getActive()[127]
            if active_times.end_ts <= UserDataManager:getServerTime() or active_times.remain_ts == -1 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
                if active_times.show_ts <= servTime then
                    self:onActiveEnd()
                end
            else
                local m_params = {
                    m_login_rcvd = self.m_model.m_login_rcvd,
                    m_verson = self.m_model.m_login_vsn,
                    m_active_time = active_times
                }
                self:openView("Summer.LimitedTimeLogin", m_params)
            end
        end
    elseif msg == "btn_MaterialAcquisition" then --材料获取
        if self.m_model:getActive() ~= nil then
            StatisticsUtil:doPointActive(126,self.m_model.m_data.quest_vsn)
            local active_times = self.m_model:getActive()[126]
            if active_times.end_ts <= UserDataManager:getServerTime() or active_times.remain_ts == -1 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
                if active_times.show_ts <= servTime then
                    self:onActiveEnd()
                end
            else
                local m_params = {
                    m_quest_vsn = self.m_model.m_data.quest_vsn,
                    m_quests = self.m_model.m_quests,
                    m_quest_buy_times = self.m_model.m_quest_buy_times
                }
                self:openView("Summer.MaterialAcquisition", m_params)
            end
        end
    elseif msg == "refresh_ui" then --刷新礼包购买
        self:refresh(date)
    elseif msg == "refreshUI_dayReward" then --刷新限时登录
        self.m_model.m_login_rcvd = date.login_rcvd
        self.m_model.m_login_vsn = date.login_vsn
    elseif msg == "refreshUI_Material" then --刷新材料获取购买项
        -- self.m_data.m_quests = self.m_data.date
        self.m_model.m_quest_buy_times = date.quest_buy_times
    elseif msg == "material_quest" then --刷新材料获取quest
        self.m_model.m_quests = date.quests
    elseif msg == "draw" then --抽奖数据更新
        self.m_model.m_data.draw_box = date
        self:draw(date)
    elseif msg == "redPoint_update" then --rp
        self.m_view:updateRP()
    end
end

--刷新抽奖
function M:draw(date)
    local function netCallback(response)
        if response and response["end"] then
            UserDataManager.active_121_end = true
            static_rootControl:updateMsg("end_summer", nil, "Summer.SummerMain")
            return
        end

        --self.m_model.m_data = response
        self.m_model:updateDrawData(response)
    end
    self.m_model:getNetData("hero_chest_index", {}, netCallback)
end

--刷新购买数据
function M:refresh(date)
    local function netCallback(response)
        self.m_model.m_data = response
        self:updateMsg("update_data", self.m_model.m_data, date.ui_name)
    end
    self.m_model:getNetData("hero_chest_index", {}, netCallback)
end

return M
