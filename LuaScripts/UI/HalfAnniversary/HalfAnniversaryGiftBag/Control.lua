---@class HalfAnniversaryGiftBagControl: OOControlBase
---@field m_model HalfAnniversaryGiftBagModel
---@field m_view HalfAnniversaryGiftBagView
local M = class("HalfAnniversaryGiftBagControl", LikeOO.OOControlBase)

function M:onEnter()
    self:UpdateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.UpdateTime))
end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        self:updateMsg("refreshRedPoint", nil, "Activities.EnjoySpring")
        if self.m_model.is_tokens == true then
            self:updateMsg("refresh_data", nil, "TopUpGiftBag.ToKensEntrancPop")
            self:updateMsg("refresh_data", nil, "TopUpGiftBag.ToKensSelectGiftBagPop")
        else
            self:updateMsg("refresh_entrances", nil, "HalfAnniversary.HalfAnniversaryMain")
        end

        self:closeView()
    elseif msg == "help_btn" then
        local info_data = self.m_model:BasicInfo() --获取配置
        local params = {}
        params.title = info_data.name
        params.content = info_data.des
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "refresh_index" then
        self:updateGiftData(function()
            self.m_view:updateBagNode()
        end)
    elseif msg == "buy" then
        audio:SendEvtUI("UI_Pay_6_198")
        self:buyForSDK(data)
    elseif msg == "btn_buySkinBtn" then
        if self.m_model:checkClothGift() == 0 then
            self:buyItemByChargeId(self.m_model.m_hero_gift_cfg.charge_id)
        end
    end
end

function M:buyItemByChargeId(charge_id)
    if charge_id then
        self.m_view:lockTouch()
        self.timer_id = self:setOnceTimer(8, function()
            if self.m_view then
                self.m_view:unlockTouch()
            end
            self.timer_id = nil
        end)
        --代金券
        if self.m_model.is_tokens == true then
            self:buyUseVoucher(charge_id, function()
                if self.m_view then
                    self:refreshIndexData()
                    self.m_view:unlockTouch()
                end
            end)
            --常规购买      
        else
            PayUtil:rechargeByChargeId(charge_id, function()
                if self.m_view then
                    self:refreshIndexData()
                    self.m_view:unlockTouch()
                end
            end)
        end
    end
end

--调用sdk充值
function M:buyForSDK(data)
    if data then
        --免费
        if data.xlsxData.price == 0 then
            local function netCallback(response)
                if response.update then
                    GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("new_str_0558"), delay_close = 2 })
                    self:closeView()
                    return
                end
                if response["end"] then
                    GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("new_str_0558"), delay_close = 2 })
                    self:closeView()
                    return
                end
                self.m_model:initData(response)
                self.m_view:refreshUI()
                RewardUtil:rewardTipsByData(response.reward)
            end
            local params = {}
            params.open_id = self.m_model.m_open_id
            params.vsn = self.m_model.m_version
            params.paper_id = 1
            params.place = data.index
            self.m_model:getNetData("active_common_gift_buy", params, netCallback)
            --付费    
        elseif data.xlsxData.charge_id then
            self:buyItemByChargeId(data.xlsxData.charge_id)
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
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("gf_str_0129", data), delay_close = 2 })
        return
    end
    local voucher_data = RewardUtil:getProcessRewardData({ RewardUtil.REWARD_TYPE_KEYS.VOUCHER, 0, 0 })
    if voucher_data.user_num < cfg.price then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("gf_str_0130", data), delay_close = 2 })
        return
    end
    local params = {
        charge_id = data
    }
    self.m_model:getNetData("voucher", params, receivetCallback)
end

function M:showHeroInfo()
    self:closeView("Pops.HeroLookInfo", nil, false)
    self:openView("Pops.HeroLookInfo", { hero_id = self.m_model.m_hero_skin_data.hero, is_new = false })
end

--  刷新
function M:refreshIndexData()
    local function netCallback(response)
        self.m_model:initData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("active_common_gift_index", { open_id = self.m_model.m_open_id, vsn = self.m_model.m_version }, netCallback)
end

--计时器
function M:UpdateTime(_, dt)
    dt = dt or 0
    self.m_view:updateActivityTimer()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end
return M