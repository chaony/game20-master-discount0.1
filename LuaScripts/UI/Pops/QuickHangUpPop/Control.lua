local M = class("QuickHangUpPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self:UpdateTime()
    self:setTimer(1,handler(self,self.UpdateTime))
    --self.m_view:setDountDown(self.m_model.m_tim)
    self.m_guide_file_name = "UI.Pops.QuickHangUpPop.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "ok_btn" then
        self:get_quick_reward()
	elseif msg == "cancle_btn" then
	    self:closeView()
    end
end

--伪计时器
function M:UpdateTime()
    if self.m_model.m_tim >= 0 then
        self.m_model.m_tim = self.m_model.m_tim - 1
        self.m_view:setDountDown(self.m_model.m_tim)
    end
end

--领取快速挂机
function M:get_quick_reward()
    if self.m_model.m_quick_idle_times <= 0 then
        GameUtil:lookInfoTips(self,  {msg =  Language:getTextByKey("new_str_0451"), delay_close = 2})
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
        RewardUtil:rewardTipsByData(data.reward,nil,callback)
        UserDataManager:setQuickIdleTimes(data)
        -- self.m_model:getNum()
        -- self.m_view:refreshUI()
        self:updateMsg(99999)
	end
	self.m_model:getNetData("get_quick_idle_reward",nil, callfunc)	
end

return M;
