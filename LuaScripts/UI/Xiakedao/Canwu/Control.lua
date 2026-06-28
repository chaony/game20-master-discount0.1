---@class CanwuControl:OOControlBase
---@field m_model CanwuModel
---@field m_view CanwuView
local M = class("CanwuControl",LikeOO.OOControlBase)

function M:onEnter()
    self:UpdateTime()
    self:setTimer(1,handler(self,self.UpdateTime))
    self.m_view:switchTabNode(self.m_model.m_open_tab_index)
    --self.m_guide_file_name = "UI.HangReward.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "CloseBtn" or msg == "cancle_btn" then    -- 返回	
        UserDataManager.local_data:setUserDataByKey("quick_hangreward_pop"..self.m_model.m_day,  self.m_model.m_no_get_pop)
        if self.m_model.m_mode == 1 then
            self:get_idle_reward()
        else
            self:closeView()
        end
        --self:closeView()
    elseif msg == "check_tag" then
        if self.m_model.m_sel_tab_index then
            if self.m_model.m_sel_tab_index ~= data then
                self.m_model.m_sel_tab_index = data
                self.m_model.m_open_tab_index = self.m_model.m_sel_tab_index
                self.m_view:switchTabNode(data)
            end
        else
            self.m_model.m_sel_tab_index = data
            self.m_model.m_open_tab_index = self.m_model.m_sel_tab_index
            self.m_view:switchTabNode(data)
        end
    elseif msg == "get_reward_btn" then
        self:get_idle_reward()
    elseif msg == "no_pop" then
        if self.m_model.m_no_get_pop == 0 then
            self.m_model.m_no_get_pop = 1
        else
            self.m_model.m_no_get_pop = 0
        end
        self.m_view:refreshQuickPop()
    elseif msg == "get_quick_btn" then
        self:get_quick_reward()
    elseif msg == "privilege_btn" then
        local params = {top = true}
        params.click_transform = self.m_view.m_cur_tab_node:findGameObject("privilege_btn").transform
        local cfg = ConfigManager:getCfgByName("auto_subscribe")
        params.title = cfg[3].name
        params.msg = cfg[3].des
        if UserDataManager:hasHangRewardSubscribe() then
            params.status_text = "bounty_str_0019"
        else
            params.btn_text = "new_str_0801"
            params.callback = function()
                QuickOpenFuncUtil:openFunc(10038)
                self:closeView()
            end
        end
        GameUtil:lookInfoTips(self.m_control, params)
    end
end

--伪计时器
function M:UpdateTime()
    self.m_model.netDataTime = self.m_model.netDataTime - 1
    if self.m_model.netDataTime <= 0 then
        self.m_model.netDataTime = self.m_model.dataTime
        local function callfunc(response)
            self.m_model:initData(response)
            self.m_view:refreshUI()
        end
       --self.m_model:getNetData("idle_reward_show",nil, callfunc)
       self.m_model:getNetData("hero_isle_idle_show",nil, callfunc)
    end
    self.m_view:setTime()
end


--领取挂机奖励
function M:get_idle_reward()
    if #self.m_model.reward >0 then
        local function callfunc(data)
            if data then
                --UserDataManager.idle_info.idle_start_time = data.idle_start_time
                --UserDataManager.idle_info.idle_end_time = data.idle_end_time
                self.m_model:refreshTime(data.idle_start_ts,data.idle_end_ts)
                local params = {}
                params.clear_tim = true
                for k,v in pairs(data.reward) do
                    local key = string.upper(k)
                    local key_value = RewardUtil.REWARD_TYPE_KEYS[key]
                    if key_value == RewardUtil.REWARD_TYPE_KEYS.COIN then
                        params.coin = true
                    elseif key_value == RewardUtil.REWARD_TYPE_KEYS.EXP then
                        params.exp = true
                    elseif key_value == RewardUtil.REWARD_TYPE_KEYS.HERO_EXP then
                        params.hero_exp = true
                    end
                end
                --local function call_addmoney()
                --    self:updateMsg("addMoney",params, "parent")
                --end
                --RewardUtil:rewardTipsByData(data.reward,nil, call_addmoney, {delay = 0, double = false, fly = false})
                RewardUtil:rewardTipsByData(data.reward,nil, nil, {delay = 0, double = false, fly = false})
                --self:updateMsg("common_refresh", nil, "parent")
                if self.m_model.m_callback then
                    self.m_model.m_callback()
                end
                self:closeView()
            else
                GameUtil:lookInfoTips(self,  {msg =  Language:getTextByKey("new_str_0004"), delay_close = 2})  
            end
    	end
    	self.m_model:getNetData("hero_isle_idle_reward",nil, callfunc, nil, true)
    else
        self:closeView()
    end
end


--领取快速挂机
function M:get_quick_reward()
    if self.m_model.m_quick_idle_times <= 0 then
        GameUtil:lookInfoTips(self,  {msg =  Language:getTextByKey("new_str_0451"), delay_close = 2})
        audio:SendEvtUI("UI_GuaJi_Limited")
        return
    end
    local bl,desc = BtnOpenUtil:isBtnOpen(8) 
    if bl == false then
        GameUtil:lookInfoTips(self,  {msg = string.format(desc), delay_close = 2})
        return
    end
    local function callfunc(data)
        local function callback()
            local params = {}
            for k,v in pairs(data.reward) do
                local key = string.upper(k)
                local key_value = RewardUtil.REWARD_TYPE_KEYS[key]
                if key_value == RewardUtil.REWARD_TYPE_KEYS.COIN then
                    params.coin = true
                elseif key_value == RewardUtil.REWARD_TYPE_KEYS.EXP then
                    params.exp = true
                elseif key_value == RewardUtil.REWARD_TYPE_KEYS.HERO_EXP then
                    params.hero_exp = true
                end
            end
            self:updateMsg("addMoney",params,"parent")
        end
        self:updateMsg("common_refresh", nil, "parent")
        if self.m_model.m_no_get_pop == 0 then
            RewardUtil:rewardTipsByData(data.reward, nil, callback, {delay = 0, double = false, fly = true})
        else
            self.m_view:creatReward(data.reward)
        end
        UserDataManager:setQuickIdleTimes(data)
        --self:updateMsg(99999)
        self.m_model:getNum()
        self.m_view:refreshUI()
	end
    self.m_model:getNetData("get_quick_idle_reward",nil, callfunc)	
    
end

return M