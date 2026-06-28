
---@class PrivilegeControl:OOControlBase
---@field m_view PrivilegeView
---@field m_model PrivilegeModel
local M=class("PrivilegeControl",LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))

end

function M:onHandle(msg, data)
    if msg==99999 then
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()

    elseif msg=="help_btn" then
        self:openHelpPop()
    elseif msg=="right_buy_btn" then
        if self.m_model.privilege_bought==0 then
            local chargeId=self.m_model:getPrivilegeChargeId()
            local callback=function()
                --self.m_view:setRightBtnGray()
                --self.m_model.privilege_bought=1

                local function netCallback(response)
                    self.m_model.m_data=response
                    self.m_model:refreshData()
                    self.m_view:refreshBuyBtnState()
                end
                self.m_model:getNetData("hero_isle_privilege_show", nil, netCallback)
            end
            if self.m_model.m_params.is_token == true then
                self:buyUseVoucher(chargeId, callback)
                return
            end
            PayUtil:rechargeByChargeId(chargeId,callback)
        end
    elseif msg=="left_buy_btn" then
        if self.m_model.visitor_bought==0 and self.m_model.privilege_bought==1 then
            local chargeId=self.m_model:getVisitorChargeId()
            local callback=function()
                local function netCallback(response)
                    self.m_model.m_data=response
                    self.m_model:refreshData()
                    self.m_view:refreshBuyBtnState()
                end
                self.m_model:getNetData("hero_isle_privilege_show", nil, netCallback)
            end
            if self.m_model.m_params.is_token == true then
                self:buyUseVoucher(chargeId, callback)
                return
            end
            PayUtil:rechargeByChargeId(chargeId,callback)

        elseif self.m_model.privilege_bought==0 then
            local params =
            {
                no_close_btn = false,
                text = Language:getTextByKey("new_str_1129")
            }
            self:openView("Pops.CommonPop", params)
        end
    end
end

--使用代金券购买
function M:buyUseVoucher(data, callback)
    local function receivetCallback(response)
        if callback then
            callback()
        end
        if response and response.reward then
            RewardUtil:rewardTipsByData(response.reward)
        end
    end
    local charge = ConfigManager:getCfgByName("charge")
    local cfg = charge[data]
    if cfg == nil then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0129",data), delay_close = 2})
        return
    end
    local voucher_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.VOUCHER,0,0})
    if voucher_data.user_num < cfg.price then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0130",data), delay_close = 2})
        return
    end
    local params = {
        charge_id = data
    }
    self.m_model:getNetData("voucher", params, receivetCallback)
end

--打开帮助页面
function M:openHelpPop()
    local params = {
        title = "tid#tower1",
        content = "tid#NfourtowerDes_8"
    }
    self:openView("Pops.CommonFiveLineHelpPop", params)
end

function M:updateTime()
    self.m_view:updateTime()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
