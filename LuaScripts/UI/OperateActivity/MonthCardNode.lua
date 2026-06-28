local M = class("MonthCardNode",LikeOO.OOUIbase)
--月卡
M.m_uiName = "OperateActivity/MonthCardNode"

function M:onEnter()
    self:setObjectVisible("get_com_btn", false)
    self:setObjectVisible("get_super_btn", false)
    self:setTextByLanKey("reward_des", "gift_month_des")
    self:setTextByLanKey("subscribe_text_1", "gf_str_0153")
    self:setTextByLanKey("subscribe_text_2", "gf_str_0154")
    self.m_subscribe_check = false
end

function M:switchInit(url, data, id, callback)
    local function callFunc(data)
        if callback then
            callback(data)
        end
        if data and data["end"] == 1 then
			return
		end
        self:refreshUI()
    end
    self.m_model:initData(url, callFunc)
end

function M:switchUI()
    self:refreshUI()
end

function M:refreshRewards(key, cfg)
    for i = 1, 2 do
        if cfg.daily_reward[i] == nil then
            self:setObjectVisible(key .. "_num1_" .. i, false)
            self:setObjectVisible(key .. "_num2_" .. i, false)
            self:setObjectVisible(key .. "_num3_" .. i, false)
            return
        end
        local type = cfg.daily_reward[i][1]
        local id = cfg.daily_reward[i][2]
        local day_num = cfg.daily_reward[i][3]
        --local reward_token_id = cfg.reward_show[i][1]
        local reward_num = cfg.reward_show[i][3]
        local days = cfg.effective_days
        self:setTextByLanKey(key .. "_num1_" .. i, reward_num - (day_num * days) )
        self:setTextByLanKey(key .. "_num2_" .. i, day_num)
        self:setTextByLanKey(key .. "_num3_" .. i, reward_num)
        local icon = ""
        if type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
            local item_cfg = ConfigManager:getCfgByName("item")
            icon = item_cfg[id].icon
        else
            local money_guide = ConfigManager:getCfgByName("money_guide")
            icon = money_guide[type].icon
        end
        self:setImg(icon, "item_icon", key .. "_icon1_" .. i)
        self:setImg(icon, "item_icon", key .. "_icon2_" .. i)
        self:setImg(icon, "item_icon", key .. "_icon3_" .. i)
    end
end

function M:refreshUI()
    if self.m_model.m_month_card_data == nil then
        return
    end
    local data = self.m_model.m_month_card_data
    --ios
    local is_subscribe = SDKUtil.sdk_params.app == 2 and data.open_subscribe and data.open_subscribe == 1 --ios显示订阅
    --is_subscribe = true
    self.m_is_subscribe = is_subscribe
    local btn_text = is_subscribe == true and "gf_str_0156" or "new_str_0789" --订阅 or 购买
    local not_active_text = is_subscribe == true and "gf_str_0157" or "bounty_str_0018" -- 未订阅 or 未激活
    local active_text = is_subscribe == true and "gf_str_0155" or "bounty_str_0019" --已订阅 or 已激活
    self:setObjectVisible("subscribe", is_subscribe == true)
    self:setObjectVisible("subscribe_check", self.m_subscribe_check == true)
    --
    self:setObjectVisible("get_com_btn", true)
    self:setObjectVisible("get_super_btn", true)
    local cfg = self.m_model:get_month_card_cfg()
    self:setTextByLanKey("goumaitext", "gf_str_0061")
    self:setTextByLanKey("goumaitext3", "gf_str_0062")
    self:setTextByLanKey("goumaitext5", "gf_str_0063")
    self:setTextByLanKey("goumaitext2", "gf_str_0061")
    self:setTextByLanKey("goumaitext4", "gf_str_0062")
    self:setTextByLanKey("goumaitext6", "gf_str_0063")
    if cfg then
        local week_cfg = cfg[1] --周卡
        local month_cfg = cfg[2] --月卡
        self:setTextByLanKey("common_text", week_cfg.card_name)
        self:setTextByLanKey("super_text", month_cfg.card_name)
        self:refreshRewards("com", week_cfg)
        self:refreshRewards("sp", month_cfg)
        if data then
            ---周卡---------------------------------------------------------------------------------------------
            self:setObjectVisible("get_com_btn", false)
            self:setTextByLanKey("buy_com_text", btn_text, week_cfg.price)
            self:setObjectVisible("common_countdown_text", false)
            if next(data.week_card) == nil then
                self:setObjectVisible("get_com_btn", true)
                self:setTextByLanKey("common_active_text", not_active_text)
                --self:setObjectVisible("common_active_text", true)
                --self:setTextByLanKey("common_active_text", "gf_str_0054", GameUtil:getMoneyTypeNum(week_cfg.price))
                --self:setTextByLanKey("com_countdown_text", not_active_text)
            else
                if data.week_card.status == 0 then --0 未开通   1 已开通
                    --if data.week_card.sum >= GameUtil:switchMoneyType(week_cfg.price) then
                        self:setObjectVisible("get_com_btn", true)
                    --else
                        --self:setObjectVisible("common_active_text", true)
                        --local num = GameUtil:switchMoneyType(week_cfg.price) - data.week_card.sum
                        --self:setTextByLanKey("common_active_text", "gf_str_0054", GameUtil:formatNum(num)..GameUtil:getMoneyTypeStr())
                    --end
                    self:setTextByLanKey("common_active_text", not_active_text)
                else
                    self:setObjectVisible("common_countdown_text", true)
                    local time_end = data.week_card.end_ts - UserDataManager:getServerTime()
                    self:setTextByLanKey("common_countdown_text", "gf_str_0161", GameUtil:formatTimeBySecond(time_end))
                    --self:setObjectVisible("common_active_text", true)
                    self:setTextByLanKey("common_active_text", active_text)
                end  
            end
    
            ---月卡---------------------------------------------------------------------------------------------
            self:setObjectVisible("get_super_btn", false)
            self:setTextByLanKey("buy_sup_text", btn_text, month_cfg.price)
            self:setObjectVisible("super_countdown_text", false)
            if next(data.month_card) == nil then
                self:setObjectVisible("get_super_btn", true)
                self:setTextByLanKey("super_active_text", not_active_text)
                --self:setObjectVisible("super_active_text", true)
                --self:setTextByLanKey("super_active_text", "gf_str_0054", GameUtil:getMoneyTypeNum(month_cfg.price) )
                --self:setTextByLanKey("super_countdown_text", not_active_text)
            else
                if data.month_card.status == 0 then
                    --if data.month_card.sum >= GameUtil:switchMoneyType(month_cfg.price) then
                        self:setObjectVisible("get_super_btn", true)
                    --else
                        --self:setObjectVisible("super_active_text", true)
                        --local num = GameUtil:switchMoneyType(month_cfg.price) - data.month_card.sum
                        --self:setTextByLanKey("super_active_text", "gf_str_0054", GameUtil:formatNum(num)..GameUtil:getMoneyTypeStr() )
                    --end
                    self:setTextByLanKey("super_active_text", not_active_text)
                else
                    self:setObjectVisible("super_countdown_text", true)
                    local time_end = data.month_card.end_ts - UserDataManager:getServerTime()
                    self:setTextByLanKey("super_countdown_text", "gf_str_0161", GameUtil:formatTimeBySecond(time_end))
                    --self:setObjectVisible("super_active_text", true)
                    self:setTextByLanKey("super_active_text", active_text)
                end
            end
        end
    end
end

function M:onButtonClick(obj, name)
    if name == "get_com_btn" then
        if self.m_is_subscribe == true then
            if self.m_subscribe_check == false then
                GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("gf_str_0158"), delay_close = 2})
                return
            end
            local cfg = self.m_model:get_month_card_cfg()
            self:updateMsg("active_month", cfg[1].ios_subscribe_charge_id)
        else
            local cfg = self.m_model:get_month_card_cfg()
            self:updateMsg("active_month", cfg[1].charge_id)
        end
        --self:updateMsg("active_month", 1)
    elseif name == "get_super_btn"  then
        if self.m_is_subscribe == true then
            if self.m_subscribe_check == false then
                GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("gf_str_0158"), delay_close = 2})
                return
            end
            local cfg = self.m_model:get_month_card_cfg()
            self:updateMsg("active_month", cfg[2].ios_subscribe_charge_id)
        else
            local cfg = self.m_model:get_month_card_cfg()
            self:updateMsg("active_month", cfg[2].charge_id)
        end
        --self:updateMsg("active_month", 2)
    elseif name == "subscribe_help_btn" then
        local params = {title = "gf_str_0160", content = Language:getTextByKey("gf_str_0159")}
        self:openView("Pops.CommonHelpPop", params)
    elseif name == "subscribe_check_btn" then
        if self.m_subscribe_check == true then
            self.m_subscribe_check = false
        else
            self.m_subscribe_check = true
        end
        self:setObjectVisible("subscribe_check", self.m_subscribe_check == true)
    elseif name == "subscribe_hide_btn" then
        CS.UnityEngine.Application.OpenURL("https://ycimg-m.duoku.com/cimages/img/promo/source/pages/gamesite/privacy_jxjh.html")
    elseif name == "subscribe_auto_btn" then
        CS.UnityEngine.Application.OpenURL("https://ycimg-m.duoku.com/cimages/img/promo/page/protocol/agi0Hz3g6_protocol.html")
    else
        M.super.onButtonClick(self, obj, name)
    end
end

function M:destroy()
    M.super.destroy(self)
end


return M