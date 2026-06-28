local M = class("TrialPanelControl", LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1,handler(self,self.updateTime))
    audio:SendEvtUI("UI_DaXiaShiLian")
end

function M:onHandle(msg , data)
    if msg == 99999 then -- 关闭
        self:updateMsg("common_refresh", nil, "parent") 
		self:closeView()
	elseif type(msg) == "number" then
        self:switchTabBtn(msg)
    elseif msg == "task_tag" then
        self:switchTabBtn2(data)
    elseif msg == "buy_btn" then
        local count = data
        local params =
        {  
            no_close_btn = false,
            cost = {RewardUtil.REWARD_TYPE_KEYS.DIAMOND,0,data},
            on_ok_call = function(msg)
                self:getNetShopBuy()
            end,   
            text = Language:getTextByKey("gf_str_0132",count)
        }
        self:openView("Pops.CommonPop",params)
    elseif msg == "refreshRedPoint" then
        self.m_model:updateCheckPoint()
        self.m_view:refreshRedPoint()    
    elseif msg == "buy_score" then
        self:getNetScoreBuy(data)
    elseif msg == "get_reward" then
        self:getNetQuestBuy(data)    
    elseif msg == "mask_btn" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0535"), delay_close = 2}) 
    elseif msg == "sign_btn" then
        self:getNetSign()
    elseif msg == "go_to" then
        local func_id = data[1]
        if func_id then
            local jump = ConfigManager:getCfgByName("jump")
            local jump_item = jump[func_id]
            if jump_item then
                local open_condition_id = jump_item.open_condition_id or 0
                local open_flag, tips_str = BtnOpenUtil:isBtnOpen(open_condition_id)
                if open_flag == true then
                    self:updateMsg("common_refresh", nil, "parent") 
                    static_rootControl:closeAllViewPop()
                    local go_type = data or {}
                    QuickOpenFuncUtil:openFunc(go_type)
                else
                    GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2}) 
                end
            end
        end
    elseif msg == "tag_1" then
        self:checkVersion(1)
    elseif msg == "tag_2" then
        self:checkVersion(2)
    elseif msg == "tag_3" then 
        self:checkVersion(3)
    end
end

function M:checkVersion(index)
    if self.m_model.m_sel_tag_index == index then
        return 
    end
    if self.m_model:checkVersionOpen(index) == true then
        self.m_model.m_sel_tag_index = index
        self.m_model:refreshData()
        self.m_view:refreshUI()
        self.m_model.m_sel_tab_index = 0
        self:switchTabBtn(1)
        self:updateTime()
    else
        if index > self.m_model.m_cur_version then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("world_boss_str_0030"), delay_close = 2}) 
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2}) 
        end
      
    end
end

function M:tipsAndClose()
    local params = {
        on_ok_call = function(msg)
            self:updateMsg(99999)
        end,
        on_cancel_call = function(msg)
            self:updateMsg(99999)
        end,
        no_close_btn = true,
        text = Language:getTextByKey("new_str_0558")
    }
    self:openView("Pops.CommonPop", params, nil, true)
end

-- tab按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        RedPointUtil:recruitSetRedPoint(self.m_model.m_sel_tag_index,self.m_model.m_sel_tab_index)
        self.m_model.m_sel_task_index = 1
        self.m_view:refreshUI()
    end
end

-- tab按钮切换
function M:switchTabBtn2(index)
    if self.m_model.m_sel_task_index ~= index then
        self.m_model.m_sel_task_index = index
        self.m_view:switchTabNode2(index)
    end
end

--大侠试炼折扣商品购买
function M:getNetShopBuy()
    local function callback(response)
        self:netCheckEndTips(response)
        if response["end"] == 1 then
            return
        end
        self.m_model:refreshData(response)
        local rec_shop = UserDataManager.m_recruit_shop[tostring(self.m_model.m_sel_tag_index)]
        if rec_shop then
            for k,v in pairs(rec_shop) do
                if v == self.m_model.m_sel_tab_index then
                    rec_shop[k] = nil
                    break
                end
            end
        end
        RewardUtil:rewardTipsByData(response.reward)
        self.m_view:refreshUI()
    end
    local params = {}
    params.shop_id = self.m_model.m_sel_tab_index
    params.vsn = self.m_model.m_sel_tag_index
    self.m_model:getNetData("recruit_shop_buy", params, callback)
end

--大侠试炼试炼奖励
function M:getNetQuestBuy(data)
    local function callback(response)
        self:netCheckEndTips(response)
        if response["end"] == 1 then
            return
        end
        self.m_model:refreshData(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_view:refreshUI()
    end
    local params = {}
    params.quest_id = data
    params.vsn = self.m_model.m_sel_tag_index
    self.m_model:getNetData("quest_recv_recruit_reward", params, callback)
end

--大侠试炼积分奖励
function M:getNetScoreBuy(id)
    local function callback(response)
        self:netCheckEndTips(response)
        if response["end"] == 1 then
            return
        end
        self.m_model:refreshData(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_view:refreshUI()
    end
    local params = {}
    params.score_id = id
    params.vsn = self.m_model.m_sel_tag_index
    self.m_model:getNetData("recv_recruit_score", params, callback)
end

--大侠试炼签到
function M:getNetSign(id)
    local function callback(response)
        self:netCheckEndTips(response)
        if response["end"] == 1 then
            return
        end
        self.m_model:refreshData(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_view:refreshUI()
    end
    local params = {}
    params.day = self.m_model.m_sel_tab_index
    params.vsn = self.m_model.m_sel_tag_index
    self.m_model:getNetData("recv_login_reward", params, callback)
end

function M:updateTime()
    self.m_model.down_Tim = self.m_model.down_Tim - 1
    self.m_view:updateTime()
    self.m_model:dayCompute(self.m_model.star_ts)
    if self.m_model.down_Tim <= 0 then
        self.m_model:dayCompute(self.m_model.star_ts)
        local day = self.m_model.m_day
        if day > 8 then
            self.m_model.active_open = false
            self:removeTimer(self.m_timer_id)
        end
    end
end

function M:netCheckEndTips(response)
    if response["end"] == 1 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
        self:updateMsg(99999)
    end
end

return M;