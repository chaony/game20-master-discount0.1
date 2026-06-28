local M = class("MonthCardNode",LikeOO.OOUIbase)
--月卡
M.m_uiName = "OperateActivity/MonthCardNode"

function M:onEnter()
    self:setObjectVisible("get_com_btn", true)
    self:setObjectVisible("get_super_btn", true)
    UserDataManager:removeRedDotByKey("month_card_alert")
    RedPointUtil:saveLocalRedPointFreshTime("month_card_alert")
    self:setTextByLanKey("buy_com_text", "anecdote_select")
    self:setTextByLanKey("buy_sup_text", "anecdote_select")
    self:setTextByLanKey("reward_des", "gift_month_des")
    self:showUI(false)
end

function M:switchInit(url, callback)
    local function callFunc(data)
        if callback then
            callback(data)
        end
        if data and data["end"] == 1 then
			return
		end
        self:refreshUI()
    end
    self.m_model:initData2(url, callFunc)
end

function M:switchUI()
    self:refreshUI()
end

function M:refreshUI()
    if self.m_model.m_month_card_data == nil or next(self.m_model.m_month_card_data) == nil then
        return
    end
    self:showUI(true)
    local data = self.m_model.m_month_card_data
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
        local com_day_num = week_cfg.daily_reward[1][3]
        local com_reward_num = week_cfg.reward_show[1][3]
        local sp_day_num = month_cfg.daily_reward[1][3]
        local sp_reward_num = month_cfg.reward_show[1][3]
        self:setTextByLanKey("com_num1", com_reward_num - (com_day_num * week_cfg.effective_days) )
        self:setTextByLanKey("com_num2", com_day_num)
        self:setTextByLanKey("com_num3", com_reward_num)
        self:setTextByLanKey("sp_num1", sp_reward_num - (sp_day_num * month_cfg.effective_days))
        self:setTextByLanKey("sp_num2", sp_day_num)
        self:setTextByLanKey("sp_num3", sp_reward_num)
        if data then
            ---周卡---------------------------------------------------------------------------------------------
            self:setObjectVisible("get_com_btn", false)
            self:setObjectVisible("common_active_text", false)
            if next(data.week_card) == nil then
                self:setObjectVisible("common_active_text", true)
                self:setTextByLanKey("common_active_text", "gf_str_0054", GameUtil:getMoneyTypeNum(week_cfg.price))
                self:setTextByLanKey("com_countdown_text", "bounty_str_0018")
            else
                if data.week_card.status == 0 then --0 未开通   1 已开通
                    if data.week_card.sum >= GameUtil:switchMoneyType(week_cfg.price) then
                        self:setObjectVisible("get_com_btn", true)
                    else
                        self:setObjectVisible("common_active_text", true)
                        local num = GameUtil:switchMoneyType(week_cfg.price) - data.week_card.sum
                        self:setTextByLanKey("common_active_text", "gf_str_0054", GameUtil:formatNum(num)..GameUtil:getMoneyTypeStr())
                    end
                    self:setTextByLanKey("com_countdown_text", "bounty_str_0018")
                else
                    local time_end = data.week_card.end_ts - UserDataManager:getServerTime()
                    self:setTextByLanKey("com_countdown_text", GameUtil:formatTimeBySecond(time_end))
                    self:setObjectVisible("common_active_text", true)
                    self:setTextByLanKey("common_active_text", "bounty_str_0019")
                end  
            end
    
            ---月卡---------------------------------------------------------------------------------------------
            self:setObjectVisible("get_super_btn", false)
            self:setObjectVisible("super_active_text", false)
            if next(data.month_card) == nil then
                self:setObjectVisible("super_active_text", true)
                self:setTextByLanKey("super_active_text", "gf_str_0054", GameUtil:getMoneyTypeNum(month_cfg.price) )
                self:setTextByLanKey("super_countdown_text", "bounty_str_0018")
            else
                if data.month_card.status == 0 then
                    if data.month_card.sum >= GameUtil:switchMoneyType(month_cfg.price) then
                        self:setObjectVisible("get_super_btn", true)
                    else
                        self:setObjectVisible("super_active_text", true)
                        local num = GameUtil:switchMoneyType(month_cfg.price) - data.month_card.sum
                        self:setTextByLanKey("super_active_text", "gf_str_0054", GameUtil:formatNum(num)..GameUtil:getMoneyTypeStr() )
                    end
                    self:setTextByLanKey("super_countdown_text", "bounty_str_0018")
                else
                    local time_end = data.month_card.end_ts - UserDataManager:getServerTime()
                    self:setTextByLanKey("super_countdown_text", GameUtil:formatTimeBySecond(time_end))
                    self:setObjectVisible("super_active_text", true)
                    self:setTextByLanKey("super_active_text", "bounty_str_0019")
                end
            end
        end
    end
end

function M:onButtonClick(obj, name)
    if name == "get_com_btn" then
        self:updateMsg("active_month", 1)
    elseif name == "get_super_btn"  then
        self:updateMsg("active_month", 2)
    else
        M.super.onButtonClick(self, obj, name)
    end
end

function M:showUI(bl)
    self:setObjectVisible("com_countdown_text", bl)
    self:setObjectVisible("super_countdown_text", bl)
    self:setObjectVisible("common_active_text", bl)
	self:setObjectVisible("super_active_text", bl)
end

function M:destroy()
    M.super.destroy(self)
end


return M