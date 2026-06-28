---@class FamilyDinnerControl:OOControlBase
---@field m_view FamilyDinnerView
---@field m_model FamilyDinnerModel
local M = class("FamilyDinnerControl", LikeOO.OOControlBase)

function M:onEnter()
    self:UpdateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.UpdateTime))
    self:switchPanel( 0 )
end

-- 处理
function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensEntrancPop")
        if self.m_model.is_tokens then
            self:updateMsg("refresh_data",nil,"TopUpGiftBag.ToKensSelectGiftBagPop")
        end
        self:updateMsg("common_refresh" ,nil ,"parent")
        self:updateMsg("refresh_red_point", nil, "Activities.FamilyDinner.TinShotSkipShop")
        self:closeMyView();
    elseif msg == "btn_closeBtn" then
        self:closeMyView();
    elseif msg == "prepare_food_btn" or msg == "prepare_food_btn_new_year" then
        self:switchPanel(1)
    elseif msg == "rank_btn" or msg == "rank_btn_new_year" then
        local params = {}
        params.version = self.m_model.version
        params.day = self.m_model.day
        self:openView("Activities.FamilyDinner.FamilyDinnerRankListPop",params)
    elseif msg == "yulan" or msg == "yulan_new_year" then
        local params = {}
        params.version = self.m_model.version
        params.day = self.m_model.day
        params.guild_score = self.m_model.m_guild_score
        params.own_score = self.m_model.m_own_score
        params.dinner_done = self.m_model.m_dinner_done
        self:openView("Activities.FamilyDinner.FamilyDinnerTaskPop",params)
    elseif msg == "buy_btn1" then
        self:buyFreeGift()
    elseif msg == "buy_btn2" then
        self:buyDiamondGift()
    elseif msg == "buy_btn3" then
        --local voice_id = self.m_model:getDinnerVoice(3)
        --self.m_view:talk(voice_id)
        self.m_view:lockTouch()
        --local dinner_cfg = self.m_model:getDinnerGiftCfg(3)
        --local charge_id = dinner_cfg.charge_id
        self:buyForSDK(data.cfg.charge_id)
        self.m_view:unlockTouch()
    elseif msg == "score_tips_btn" or msg == "score_tips_btn_new_year" then
        local params = {}
        params.title = "sdk_txt_002"
        params.content = "tid#hejiatuanyuan2_2"
        params.title = self.m_model.m_active_name
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "refresh_data" then
        table.merge(self.m_model.m_dinner_done, data.dinner_done)
        self.m_view:refreshRedPoint()
    elseif msg == "help_btn" then
        local spring_festival = ConfigManager:getCfgByName("spring_festival")
        local versionData = spring_festival[self.m_model.version] or {}
        local content = "tid#hejiatuanyuan2_2"
        local titleName = self.m_model.m_active_name
        self:openView("Pops.CommonHelpPop", { title = titleName, content = content })
    elseif msg == "update_end_ts" then
        self:updateData()    
    elseif msg == "reward_btn" then  --礼包
        local params = {}
        params.m_data = self.m_model.m_server_data
        params.version = self.m_model.version
        params.day = self.m_model.day
        self:openView("Activities.FamilyDinner.FamilyDinnerShop",params)
    end
end

-- 购买元宝礼包
function M:buyDiamondGift()
    self.m_model:getNetData("spring_festival_buy_dinner_gift",
            { version = self.m_model.version, place_id = 2, gift_id = self.giftIds[2]}, function( data )  
                local voice_id = self.m_model:getDinnerVoice(2)
                self:netCheckEndTips(data)
                self.m_view:talk(voice_id)
                self.m_view:lockTouch()
                RewardUtil:rewardTipsByData(data.reward);
                self.m_model.m_server_data = data.dinner_gifts;
                self.m_model.m_guild_score = data.guild_score;
                self.m_model.m_own_score = data.personal_score
                self.m_model.m_dinner_done = data.dinner_done;
                self:updateMsg("refresh_data", data, "GiftBag.CelebrateNewYear")
                self:refreshAllGifts();
                self.m_view:unlockTouch()
            end)
end

-- 购买免费礼包
function M:buyFreeGift()
    self.m_model:getNetData("spring_festival_buy_dinner_gift",
            { version = self.m_model.version, place_id = 1, gift_id = self.giftIds[1]}, function( data )     
                local voice_id = self.m_model:getDinnerVoice(1)
                self:netCheckEndTips(data)
                self.m_view:talk(voice_id)
                self.m_view:lockTouch()
                RewardUtil:rewardTipsByData(data.reward);
                self.m_model.m_server_data = data.dinner_gifts;
                self.m_model.m_guild_score = data.guild_score;
                self.m_model.m_own_score = data.personal_score
                self.m_model.m_dinner_done = data.dinner_done;
                self:updateMsg("refresh_data", data, "GiftBag.CelebrateNewYear")
                self:refreshAllGifts();
                self.m_view:unlockTouch()
            end)
end

--调用sdk充值
function M:buyForSDK(charge_id)
    if self.m_model.is_tokens == true then
        self:buyUseVoucher(charge_id, function ()
            self:RefreshOneTagData(charge_id)
        end)
        return
    end
    if self.timer_id then
        Logger.logWarningAlways(self.timer_id, "-------------IsPay-----------")
        return
    end
    self.m_view:lockTouch()
    self.timer_id = self:setOnceTimer(2, function ()
        self.m_view:unlockTouch()
        self.timer_id = nil
    end)
    PayUtil:rechargeByChargeId(charge_id, function ()
        if self.m_view then
            self.m_view:unlockTouch()
            if self.timer_id then
                self:removeTimer(self.timer_id)
                self.timer_id = nil
            end
            self:RefreshOneTagData(charge_id)
        end
    end)
end

--计时器
function M:UpdateTime()
    self.m_view:updateActivityTimer()
end


-- 关闭当前页面
function M:closeMyView()
    if self.mode == 0 then
        self:closeView()
    else
        self.mode = self.mode - 1;
        self:switchPanel(self.mode)
    end
end


-- 切换界面
function M:switchPanel( mode )
    self.mode = mode;
    self.m_view:switchPanel( mode )
    if mode == 0 then
        --进入聚会
        self:enterJuHui();
    else
        --进入备菜
        self:enterBeiCai();
    end
end

-- 进入备菜
function M:enterBeiCai()
    self.m_view:creatRole3D()
    self.m_view:talk( 999 )
    self:refreshAllGifts()
end


function M:refreshAllGifts()
    self.giftIds = {}
    for i = 1, 3 do
        local key = tostring(i);
        local data = self.m_model.m_server_data[key];
        self.m_view:refreshGiftView(i, data);
        if data ~= nil then
            table.insert(self.giftIds,data.gift_id)
        end
    end
end

-- 进入聚会
function M:enterJuHui()
    local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
    if guild_id == 0 then
        --没有工会
        self.m_view:refreshUI();
    else
        --有工会
        --请求服务器数据
        self.m_model:getServerData(function( data )
            self.m_view:refreshUI(data);
        end)
    end
end

function M:RefreshOneTagData()
    self.m_model:getNetData("spring_festival_index",nil, function( data )
        self:netCheckEndTips(data)
        self:updateMsg("refresh_data", data, "GiftBag.CelebrateNewYear")
        self:updateMsg("update_data",data.dinner_gifts,"Activities.FamilyDinner.FamilyDinnerShop")
        self.m_model.day = data.cur_day
        table.merge(self.m_model.m_server_data, data.dinner_gifts) 
        self.m_model.m_guild_score = data.guild_score
        self.m_model.m_own_score = data.personal_score
        table.merge(self.m_model.m_dinner_done, data.dinner_done)
        self:refreshAllGifts()
    end)
end

function M:buyPlayAXianVoice()

end

--夸轮刷新
function M:updateData(callBack)
    self.m_model:getNetData("spring_festival_index",nil, function( response )
        self:netCheckEndTips(response)
        table.merge(self.m_model.m_server_data, response.dinner_gifts) 
        self.m_model.day = response.cur_day
        self.m_model.m_guild_score = response.guild_score
        self.m_model.m_own_score = response.personal_score
        table.merge(self.m_model.m_dinner_done, response.dinner_done) 
        self.m_model:InitData()
        self:updateMsg("refresh_data", response, "GiftBag.CelebrateNewYear")
        self:enterJuHui();
    end)
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

function M:netCheckEndTips(response)
    if response and response["end"] == 1 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
        self:updateMsg(99999)
    end
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
