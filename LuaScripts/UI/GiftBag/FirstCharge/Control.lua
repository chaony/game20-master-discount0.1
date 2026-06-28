local M = class("FirstChargeControl", LikeOO.OOControlBase)

function M:onEnter()
    audio:SendEvtUI("UI_FirstPay")
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        if self.m_model.m_callback then
            self.m_model.m_callback(self.m_model.m_callback_new)
        end
        self:updateMsg("common_refresh", nil, "parent") 
        self:closeView()
    elseif msg == "get_reward" then
        self:getFirstReward()
    elseif msg == "privilege_btn" then -- 特权按钮
        local params = {top = true}
        params.click_transform = self.m_view:findGameObject("privilege_btn").transform
        local cfg = ConfigManager:getCfgByName("auto_subscribe")
        params.title = cfg[2].name
        params.msg = cfg[2].des
        if UserDataManager:hasGachaSubscribe() then
            params.status_text = "bounty_str_0019"
        else
            params.callback = function()
                QuickOpenFuncUtil:openFunc(10038)
            end
        end
        GameUtil:lookInfoTips(self.m_control, params)
    elseif msg == "quality_btn" then    
        local params = {top = true}
        params.click_transform = self.m_view:findGameObject("quality_btn").transform
        local cfg = ConfigManager:getCfgByName("auto_subscribe")
        params.title = cfg[2].name
        params.msg = cfg[2].des
        if UserDataManager:hasGachaSubscribe() then
            params.status_text = "bounty_str_0019"
        else
            params.callback = function()
                QuickOpenFuncUtil:openFunc(10038)
            end
        end
    elseif msg == "day_btn_1" then
        self.m_model.m_select_day_index = 1
        self.m_view:refreshUI()
    elseif msg == "day_btn_2" then
        self.m_model.m_select_day_index = 2
        self.m_view:refreshUI()
    elseif msg == "day_btn_3" then
        self.m_model.m_select_day_index = 3
        self.m_view:refreshUI()
    elseif msg == "change_tag" then
        if self.m_model.m_select_tag_index == data then
            return
        end
        self.m_model.m_select_tag_index = data
        self.m_model.m_select_day_index = self.m_model:getDefDayIndex() 
        self.m_view:updateTagUI()
        self.m_view:refreshUI()
    elseif msg == "go_to_btn" then
        QuickOpenFuncUtil:openFunc(10037)
        self:updateMsg(99999)
    elseif msg == "charge_btn1" then
        self:updateMsg("change_tag", 1)
    elseif msg == "charge_btn2" then
        local num = self.m_model:getLockNum(2)
        if self.m_model:getPayNum() >= num then
            self:updateMsg("change_tag", 2)
        else
            GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0117",num), delay_close = 2})
        end
    elseif msg == "charge_btn3" then
        local num = self.m_model:getLockNum(3)
        if self.m_model:getPayNum() >= num then
            self:updateMsg("change_tag", 3)
        else
            GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0117",num), delay_close = 2})
        end
    elseif msg == "charge_btn4" then
        local num = self.m_model:getLockNum(4)
		if self.m_model:getPayNum() >= num then
            self:updateMsg("change_tag", 4)
        else
            GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0117",num), delay_close = 2})
        end
    elseif msg == "buy_sdk_update" then 
        local function receivetCallback(response)
            self.m_model:updateData(response)
            self.m_view:refreshUI()
        end
        self.m_model:getNetData("first_payment_index", nil, receivetCallback)
    end
end

function M:getFirstReward(index)
    local function callback(response)
        if response["end"] == 1 then
            if response.reward then
                RewardUtil:rewardTipsByData(response.reward)
            end
            self:updateMsg(99999)  
            return
        end
        if response.reward then
            RewardUtil:rewardTipsByData(response.reward)
        end
        self.m_model.m_data.first_payment = response.first_payment
        self.m_model.m_select_day_index = self.m_model:getDefDayIndex() 
        self.m_view:refreshUI()
    end
    local check_index = self.m_model:checkLastGet()
    if self.m_model.m_select_day_index ~= check_index then
        self.m_model.m_select_day_index = check_index
        self.m_view:refreshUI()
    end
    local day_list = self.m_model:getDayList()
    local params = {}
    params.reward_id = self.m_model.m_select_tag_index
    params.day = day_list[check_index]
    self:checkRewardSelect(function (index)
        if index > 1 then
            params.item_index = index --下标从0开始
            self.m_model:getNetData("receive_first_payment", params, callback)
        else
            self.m_model:getNetData("receive_first_payment", params, callback)    
        end
    end)
end


function M:checkRewardSelect(callback)
    local c_reward = self.m_model:getSelectReward()
    local item_data = nil
    for k,v in pairs(c_reward) do
        local reward_data = RewardUtil:getProcessRewardData(v)
        if reward_data.item_cfg.type == 20 then
            item_data = v
        end
    end
    if item_data then
        local parms = {}
        local reward_data = RewardUtil:getProcessRewardData(item_data)
        GameUtil:updateItemEffect(reward_data)
        parms.show_data = reward_data
        parms.use_num = reward_data.data_num
        parms.isShowBtnType = 1
        parms.callBack = function(heroIndex)
            local data = reward_data.item_effect[heroIndex]
            callback(data.id)
        end
        self:openView("Item.HeroBox", parms)
    else
        callback(-1)
    end
end


return M
