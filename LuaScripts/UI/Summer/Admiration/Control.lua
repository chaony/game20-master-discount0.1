local M = class("AdmirationControl", LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg, date)
    if msg == 99999 then
        if self.m_model.m_is_token == true then
            self:updateMsg("refresh_data", nil, "TopUpGiftBag.ToKensSelectGiftBagPop")
        end
        self:closeView()
    elseif msg == "btn_buy" then
        self:buyForSDK(self.m_model:getMoney().charge_id)
    elseif msg == "update_data" then --刷新
        self.m_model:updateServerData(date)
        self.m_view:refreshUI()
    else
        local click_obj = self.m_view:findGameObject(msg)
        if msg == "skill1_img" then
            self:openSkillPop(1, click_obj.transform)
        elseif msg == "skill2_img" then
            self:openSkillPop(2, click_obj.transform)
        elseif msg == "skill3_img" then
            self:openSkillPop(3, click_obj.transform)
        elseif msg == "skill4_img" then
            self:openSkillPop(4, click_obj.transform)
        end
    end
end

--技能获取信息
function M:openSkillPop(index, transform)
    local skills, hero_lv = self.m_model:getHeroSkill()
    self:openView(
        "Pops.SkillPop",
        {skill = skills[index], index = index, cur_lv = hero_lv, click_transform = transform, pivot = Vector2(0, 1)}
    )
end

--支付
function M:buyForSDK(charge_id)
    if self.m_model.m_is_token == true then
        self:buyUseVoucher(
            charge_id,
            function()
                self:updateMsg("refresh_ui", {ui_name = "Summer.Admiration"}, "Summer.SummerMain")
            end
        )
        return
    end
    local charge = ConfigManager:getCfgByName("charge")
    local cfg = charge[charge_id]
    if cfg then
        local function rechargeBack(params)
            -- GameUtil:lookInfoTips(self, {msg = params.payMsg, delay_close = 2})
            self:updateMsg("refresh_ui", {ui_name = "Summer.Admiration"}, "Summer.SummerMain")
        end
        PayUtil:rechargeByChargeId(charge_id, rechargeBack)
    end
end

--使用代金券购买
function M:buyUseVoucher(data, callback)
    local function receivetCallback(response)
        if callback then
            callback()
        end
        self:refresh()
        if response and response.reward then
            RewardUtil:rewardTipsByData(response.reward)
        end
    end
    local charge = ConfigManager:getCfgByName("charge")
    local cfg = charge[data]
    if cfg == nil then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0129", data), delay_close = 2})
        return
    end
    local voucher_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.VOUCHER, 0, 0})
    if voucher_data.user_num < cfg.price then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0130", data), delay_close = 2})
        return
    end
    local params = {
        charge_id = data
    }
    self.m_model:getNetData("voucher", params, receivetCallback)
end

--刷新购买数据
function M:refresh()
    local function netCallback(response)
        self:updateMsg("update_data", response)
    end
    self.m_model:getNetData("hero_chest_index", {}, netCallback)
end

--更新时间
function M:updateTime()
    self.m_view:updateTime()
end

return M
