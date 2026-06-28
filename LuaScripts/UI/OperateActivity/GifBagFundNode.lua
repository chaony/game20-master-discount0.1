local M = class("GiftBagView",LikeOO.OOUIbase)
--基金
M.m_uiName = "OperateActivity/GifBagFundNode"

M.GRAY_RGBA = Color.New(88/255, 88/255, 88/255)
M.COM_RGBA = Color.New(131/255, 93/255, 48/255)

function M:onEnter()
    self.m_gray_img = self:findImage("gray_img")
    self.end_ts_tab = {}
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
    self.c_fund_id = data or 0
    self.m_model:initData(url, callFunc, {fund_id = data})
end


function M:switchUI()
    self:refreshUI()
end

function M:refreshUI()
    if self.m_model.m_fund_data == nil then
        return
    end
    self.end_ts_tab = {}
    local Sign_1 = self:findGameObject("fund_1")
    local Sign_2 = self:findGameObject("fund_2")
    local GrowUp = self:findGameObject("fund_3")
    self:updateSuperSignFundData(Sign_1, self.m_model.m_fund_data.normal_sign_fund)
    self:updateSubscribeSignFundData(Sign_2, self.m_model.m_fund_data.high_sign_fund)
    self:updateGrowFundData(GrowUp, self.m_model.m_fund_data)
    self:updateTime()
end

function M:updateSuperSignFundData(obj, data)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj) 
    if LuaBehaviour then
        local fund_cfg = self.m_model:get_sign_cfg(1)
        local get_item = RewardUtil:getProcessRewardData(fund_cfg.first_reward[1])
        local all_item = RewardUtil:getProcessRewardData(fund_cfg.reward_show[1])
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "title_text", fund_cfg.card_name )
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "com_num1", get_item.data_num )
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "com_num2", all_item.data_num )
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "buy_com_text", GameUtil:getMoneyTypeNum(fund_cfg.price))
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "quick_btn", data.opened == 1)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "buy_btn", data.opened == 0)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "get_text", false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "mingri_text", false)
        local remove_node = LuaBehaviour:FindGameObject("reward_node")
        local remove_node_one = LuaBehaviour:FindGameObject("reward_node_one")
        local remove_node_two = LuaBehaviour:FindGameObject("reward_node_two")
        UIUtil.destroyAllChild(remove_node.transform)
        UIUtil.destroyAllChild(remove_node_one.transform)
        UIUtil.destroyAllChild(remove_node_two.transform)
        local btn_img = LuaBehaviour:FindImage("quick_btn")
        local btn_text = LuaBehaviour:FindText("quick_btn_text")
        local reward_node = LuaBehaviour:FindGameObject("reward_node")
        UIUtil.destroyAllChild(reward_node.transform)
        local c_day = self.m_model:getDayDiff(data.start_ts)
        local end_text = LuaBehaviour:FindText("common_active_text")
        local show_rewards  = {} 
        local gray = false
        table.insert( self.end_ts_tab, {end_ts = data.end_ts, text = end_text})
        if data.opened == 0 then
            show_rewards = self.m_model:getCanAllNormalReward(data.vsn, data.days)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "show_money", true)
        else
            local can_get = self:checkReceived(c_day, data.received)
            if next(can_get) ~= nil then
                show_rewards = self.m_model:getDaysNormalReward(can_get, data.vsn, data.days)
                if #show_rewards == 2 then
                    reward_node = LuaBehaviour:FindGameObject("reward_node_two")
                elseif #show_rewards == 1 then  
                    reward_node = LuaBehaviour:FindGameObject("reward_node_one")
                end
                LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "mingri_text", "new_str_0655")
            else
                if c_day == data.days then
                    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "get_text", true)
                    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "quick_btn", false)
                    show_rewards = self.m_model:getDaysNormalReward({c_day} ,data.vsn, data.days)
                    reward_node = LuaBehaviour:FindGameObject("reward_node_one")
                    LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "mingri_text", "gf_str_0102")
                else
                    show_rewards = self.m_model:getDaysNormalReward({c_day+1} ,data.vsn, data.days)
                    gray = true
                    reward_node = LuaBehaviour:FindGameObject("reward_node_one")
                    LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "mingri_text", "gf_str_0103")
                end
            end
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "mingri_text", true)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "show_money", false)
        end
        
        if gray == true then
            btn_img.material = self.m_gray_img.material
            btn_text.color = M.GRAY_RGBA
        else
            btn_img.material = nil
            btn_text.color = M.COM_RGBA
        end
        self:creatRewards(reward_node,show_rewards )
		LuaBehaviour:RegistButtonClick(function (obj, name)
            if name == "buy_btn" then
                local fund_cfg = self.m_model:get_sign_cfg(1)
                self:updateMsg("buy", fund_cfg.charge_id)
            elseif name == "quick_btn" then
                if gray == true then
                    GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0095"), delay_close = 2})
                    return
                end
                self:updateMsg("quick_sign_fund", {high = 0, version = data.incr_vsn})
            elseif name == "check_btn" then
                self.m_control:openView("OperateActivity.SignInFundPop", {data = data, high = 0})
            end
        end)
    end
end

function M:updateSubscribeSignFundData(obj, data)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj) 
    if LuaBehaviour then
        local fund_cfg = self.m_model:get_sign_cfg(2)
        local get_item = RewardUtil:getProcessRewardData(fund_cfg.first_reward[1])
        local all_item = RewardUtil:getProcessRewardData(fund_cfg.reward_show[1])
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "title_text", fund_cfg.card_name )
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "com_num1", get_item.data_num )
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "com_num2", all_item.data_num )
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "buy_com_text", GameUtil:getMoneyTypeNum(fund_cfg.price))
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "quick_btn", data.opened == 1)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "buy_btn", data.opened == 0)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "get_text", false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "mingri_text", false)
        local btn_img = LuaBehaviour:FindImage("quick_btn")
        local btn_text = LuaBehaviour:FindText("quick_btn_text")
        local reward_node = LuaBehaviour:FindGameObject("reward_node")
        local remove_node = LuaBehaviour:FindGameObject("reward_node")
        local remove_node_one = LuaBehaviour:FindGameObject("reward_node_one")
        local remove_node_two = LuaBehaviour:FindGameObject("reward_node_two")
        UIUtil.destroyAllChild(remove_node.transform)
        UIUtil.destroyAllChild(remove_node_one.transform)
        UIUtil.destroyAllChild(remove_node_two.transform)
        local c_day = self.m_model:getDayDiff(data.start_ts)
        local end_text = LuaBehaviour:FindText("common_active_text")
        local show_rewards  = {} 
        local gray = false
        table.insert( self.end_ts_tab, {end_ts = data.end_ts, text = end_text})
        if data.opened == 0 then
            show_rewards = self.m_model:getCanAllHighReward(data.vsn, data.days)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "show_money", true)
        else
            local can_get = self:checkReceived(c_day, data.received)
            if next(can_get) ~= nil then
                show_rewards = self.m_model:getDaysHighReward(can_get, data.vsn, data.days)
                if #show_rewards == 2 then
                    reward_node = LuaBehaviour:FindGameObject("reward_node_two")
                elseif #show_rewards == 1 then  
                    reward_node = LuaBehaviour:FindGameObject("reward_node_one")
                end
                LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "mingri_text", "new_str_0655")
            else
                if c_day == data.days then
                    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "get_text", true)
                    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "quick_btn", false)
                    show_rewards = self.m_model:getDaysHighReward({c_day} ,data.vsn, data.days)
                    reward_node = LuaBehaviour:FindGameObject("reward_node_one")
                    LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "mingri_text", "gf_str_0102")
                else
                    show_rewards = self.m_model:getDaysHighReward({c_day+1} ,data.vsn, data.days)
                    gray = true
                    reward_node = LuaBehaviour:FindGameObject("reward_node_one")
                    LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "mingri_text", "gf_str_0103")
                end
            end
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "mingri_text", true)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "show_money", false)
        end
        if gray == true then
            btn_img.material = self.m_gray_img.material
            btn_text.color = M.GRAY_RGBA
        else
            btn_img.material = nil
            btn_text.color = M.COM_RGBA
        end
        self:creatRewards(reward_node,show_rewards )
		LuaBehaviour:RegistButtonClick(function (obj, name)
            if name == "buy_btn" then
                local fund_cfg = self.m_model:get_sign_cfg(2)
                self:updateMsg("buy", fund_cfg.charge_id)
            elseif name == "quick_btn" then
                if gray == true then
                    GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("请明日再来"), delay_close = 2})
                    return
                end
                self:updateMsg("quick_sign_fund", {high = 1, version = data.incr_vsn})
            elseif name == "check_btn" then
                self.m_control:openView("OperateActivity.SignInFundPop", {data = data, high = 1})
            end
        end)
    end
end

function M:creatRewards(parent, items)
    UIUtil.destroyAllChild(parent.transform)
    for k,v in pairs(items) do
        local itemNode = GameUtil:createItemElement(v, true, true)
        itemNode.transform:SetParent(parent.transform, false)
        GameUtil:creatChargeEffect(itemNode, v)
    end
end

function M:updateGrowFundData(obj, data)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj) 
    local end_ts = self.m_model:getActiveEndTimeByOpenID(data.actives, 85)
    if  end_ts == 0 and data.fund_status == 0 then
        self:setObjectVisible("fund_3", false)
        return
    end
    if self:checkOverStatus(data.fund_quests) == true and data.fund_status == 1 then
        self:setObjectVisible("fund_3", false)
        return
    end
    self:setObjectVisible("fund_3", true)
    if LuaBehaviour then
        local fund_cfg = self.m_model:get_growth_fund(85)
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "com_num2", "36000")
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "title_text", "gf_str_0093")
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "buy_com_text", GameUtil:getMoneyTypeNum(fund_cfg.price))
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "buy_btn", data.fund_status == 0)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "quick_btn", false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "no_get_btn", false)
        local btn_img = LuaBehaviour:FindImage("quick_btn")
        local end_text = LuaBehaviour:FindText("common_active_text")
        local can_get = self:checkStatus(data.fund_quests) 
        local end_ts = self.m_model:getActiveEndTimeByOpenID(data.actives, 85)
        local sum_num = self.m_model:getCanGetAll(data.fund_quests)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "status_1", data.fund_status == 1)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "status_0", data.fund_status == 0 )
        if end_ts > 0 and data.fund_status == 0 then
            table.insert( self.end_ts_tab, {end_ts = end_ts, text = end_text})
        else
            if data.fund_status == 0 then
                LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "common_active_text", "bounty_str_0018")
            else
                LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "common_active_text", "bounty_str_0019")
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "no_get_btn", false)
            end
        end
        if data.fund_status == 1 then
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "quick_btn", can_get)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "no_get_btn", not can_get)
            local stage_cfg = UserDataManager:getCurStageCfg()
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "no_get_text", "gf_str_0094", Language:getTextByKey(stage_cfg.map_point_name))
            if can_get == true then
                --local show_cfg = self:getNextFinish()
                LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "goumaitext", "new_str_0655")
                LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "com_num1", sum_num)
                -- if show_cfg then
                --     LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "goumaitext", show_cfg.name)
                --     LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "com_num1", show_cfg.reward[1][3])
                -- else
                --     LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "status_1", false)
                --     LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "status_0", true)  
                -- end
            else
                local show_cfg = self:getNextRecevied()
                if show_cfg and show_cfg.id == 10001 then
                    LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "common_active_text", "gf_str_0097")
                    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "status_1", false)
                    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "status_0", true)    
                end
                LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "goumaitext", show_cfg.name)
                LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "com_num1", show_cfg.reward[1][3])  
            end
        end
		LuaBehaviour:RegistButtonClick(function (obj, name)
            if name == "buy_btn" then
                self:updateMsg("buy", fund_cfg.charge_id)
            elseif name == "quick_btn" then
                self:updateMsg("get_quick_fund")
            elseif name == "check_btn" then
                self.m_control:openView("OperateActivity.GrowUpFundPop", data)
            end
        end)
    end
end

function M:checkStatus(fund_quests)
    for k,v in pairs(fund_quests) do
        if v.status == 1 then
            return true
        end
    end
    return false
end

function M:checkOverStatus(fund_quests)
    for k,v in pairs(fund_quests) do
        if v.status ~= 2 then
            return false
        end
    end
    return  true
end

function M:getNextFinish()
    local tab = self.m_model:get_linshi_fund(85)
    for i= 1, #tab do
        local cfg = tab[i]
        local data = self.m_model:getFundData(cfg.id)
        if data.status == 0 then
            return cfg
        end
    end
    return nil
end

function M:getNextRecevied()
    local tab = self.m_model:get_linshi_fund(85)
    return tab[1]
end

function M:checkReceived(day, received)
    local can_get_day = {}
    if day == #received then
        return can_get_day
    end
    for k = 1,day do
        table.insert(can_get_day, k)
    end
    local remove_tab = {}
    for i= 1,day do
        for k,v in pairs(received) do
            if i == v then
                remove_tab[v] = true
                break
            end
        end
    end
    for k = #can_get_day, 1,-1 do
        if remove_tab[k] == true then
            table.remove(can_get_day, k)
        end
    end
    return can_get_day
end

function M:updateTime()
    for k,v in pairs(self.end_ts_tab) do
        local time_end = v.end_ts - UserDataManager:getServerTime()
        if time_end > 0 then
            v.text.text = Language:getTextByKey("new_str_0485")..GameUtil:formatTimeBySecond(time_end)
        else
            v.text.text = Language:getTextByKey("new_str_0485")..GameUtil:formatTimeBySecond(0)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end


return M