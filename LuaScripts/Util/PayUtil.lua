------------------- PayUtil
--[[
    支付使用方式  具体参数请参照具体方法
    PayUtil:rechargeByData(data, function (result)
        -- 支付结果处理
    end)
]]
local M = {
    m_callBack = nil, -- 支付结果回调
    m_ios_currency = "", -- ios返回的货币
    m_pay_test = GameVersionConfig.PAY_TEST -- 支付测试，不走sdk支付直接通知后端发奖励
}

local platform_channel = "unknow"

-- 需要向服务器获取支付sign的平台
local need_pay_sign = {}

-- 需要向服务器获取订单
local need_get_orderinfo = {}

---获取通用商品信息
function M:getCommonGoodsInfo(cfg)
    local goodsId = cfg.buy_id
    local cost = cfg.cost
    local price_show = ConfigManager:getCfgByName("price_show")
    local price_cfg = price_show[cfg.price]
    local currency = ConfigManager:getCommonValueById(331, "usd")
    local price = price_cfg[currency] or 9999
    Logger.log(price, "price ========")

    local serverData = UserDataManager.server_data:getServerData()
    local serverTime = UserDataManager:getServerTime()

    local params = {}
    local serverId = serverData.server --服务器id
    local userData =UserDataManager.user_data 
    local uid = userData:getUserStatusDataByKey("uid") --玩家uid

    local order_id =
        tostring(uid) .. "-" .. tostring(serverId) .. "-" .. tostring(goodsId) .. "-" .. tostring(os.time())
    params.uid = uid
    params.name = userData:getUserStatusDataByKey("name") 
    params.level = userData:getUserStatusDataByKey("level") 
    params.vip = userData:getUserStatusDataByKey("vip") 

    params.order_id = order_id
    params.cost_key = tostring(cost) --商品配置项标识

    -- android，ios都需要使用cost转换
    local charge_product = ConfigManager:getCfgByName("charge_product")
    local fff = Json.encode(charge_product)

    local bundleid = SDKUtil.sdk_params.applicationId or ""
    Logger.logAlways("charge_product key ====== " .. tostring(bundleid) .. "  _" .. fff)

    local charge_product_item = charge_product[tostring(bundleid) .. "_" .. params.cost_key]
    Logger.logAlways("charge_product key ====== " .. tostring(bundleid) .. "_" .. params.cost_key)
    params.cost = charge_product_item and charge_product_item.product_id or nil --商品真实项标识

    if not params.cost then
        local charge_product_item_def = charge_product["com.jxjh.default" .. "_" .. params.cost_key]
        params.cost = charge_product_item_def and charge_product_item_def.product_id or nil --商品真实项标识
    end

    Logger.logAlways("charge_product cost ====== " .. params.cost)

    params.price = tostring(price) --商品价格
    params.goods_id = tostring(goodsId) -- 支付项id
    params.goods_name = Language:getTextByKey(cfg.name) -- 支付项名字
    params.goods_des = Language:getTextByKey(cfg.des) -- 支付项描述
    params.currency = string.upper(currency) -- 货币类型
    params.count = 1
    --params.diamond   = tostring(cfg.diamond)
    params.format_price = string.format("%.2f", price)

    params.reg_ts = UserDataManager.reg_ts

    --params.gift_diamond  = cfg.gift_diamond or 0
    --if cfg.is_double then
    --    params.gift_diamond  = cfg.diamond + params.gift_diamond   -- 赠送金币
    --end

    params.server_id = tostring(serverId)
    params.server_name = tostring(serverData.server_name) -- 服务器名
    params.guide_name = UserDataManager.user_data:getUserStatusDataByKey("guild_name") or "" -- 公会名
    params.role_level = UserDataManager.user_data:getUserStatusDataByKey("level") or 1
    params.user_own_coin = UserDataManager.user_data:getUserStatusDataByKey("diamond") or 0
    params.vip_level = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
    params.role_name = UserDataManager.user_data:getUserStatusDataByKey("name") or ""
    params.guide_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id") or "" -- 公会id

    --params.get_order_url = tostring(BASEINFO_DIC.order_url) .. tostring(game_url.getExtUrlInfo())
    --params.notify_url = BASEINFO_DIC.notify_url

    params.openid = UserDataManager.client_data.openid -- sdk的唯一ID
    Logger.log(price, "price ========")
    params.serverTime = os.date("%Y%m%d%H%M%S", serverTime) -- 订单产生时间

    local extendInfo = {}
    --extendInfo.goods_name = params.goods_name

    extendInfo.sdkChannel = SDKUtil.sdkChannel
    extendInfo.env_name =  UserDataManager:getEnvName()
    extendInfo.cp_order_id = order_id
    -- cp_order_id|env_name|sdkChannel
    params.extendInfo =  order_id .. "|" .. UserDataManager:getEnvName() .. "|" .. SDKUtil.sdkChannel    --Json.encode( extendInfo )
    params.order_id = order_id


    return params
end

function M:gsdkPayRst(payInfo, rstType, cbFuncName)
    if payInfo and payInfo.goods_id then
        GameUtil:sendPayment(payInfo.goods_id, rstType,payInfo)
    end

    if type(self.m_callBack) == "function" then
        self.m_callBack({code = cbFuncName, payMsg = ""})
    end
end
--- 通用支付
function M:startPayCommon(goodsInfo)


    if GameUtil:getpPlatform() == "Ios" then
        static_rootControl:openView("Loading.SmallLoading", {delay_show = 0}, "ios_pay_small_loading")
	end


    local function buyResult(data)
        static_rootControl:closeView("Loading.SmallLoading", "ios_pay_small_loading")

        Logger.logAlways(data,"buyResult")
        local result = tonumber(data["result"])
        local errmsg = data["errmsg"]
        self.m_hidePayTips = true

        Logger.log(SDKUtil.sdk_params,"SDKUtil.sdk_params")

        if data.transaction_id and data.payInfo then

            if GameUtil:getpPlatform() == "Ios" then
--                static_rootControl:openView("Loading.SmallLoading", {delay_show = 0}, "ios_pay_small_loading")
            end
            
            local payInfoData = Json.decode(data.payInfo)
            local product_id = payInfoData["cost"]
            Logger.log(payInfoData,"payInfoData")
            Logger.log(product_id,"product_id")

            local cp_order_id = payInfoData.order_id

            Logger.log(SDKUtil,"SDKUtil")

            local params = {}
            params.platform = SDKUtil.sdk_params.platform
            params.channel = SDKUtil.configChannel
            params.game_order_id = cp_order_id
            params.order_id = data.transaction_id
            params.transaction_id = data.transaction_id
            params.environment = ""
            params.package_name = SDKUtil.sdk_params.applicationId
            params.product_id = product_id
            params.receipt_data = data.receipt
            params.original_transaction_id = data.original_transaction_id or ""


            local url = NetUrl.getUrlForKey("payment_ios")
            NetWork:httpRequest(function(data)
                Logger.logAlways(data,"payment_ios")

 --               static_rootControl:closeView("Loading.SmallLoading", "ios_pay_small_loading")

                if data.can_finish == 1 then
                    Logger.logAlways(data,"can_finish 1")
                    SDKUtil:sendIOSPayFinish(product_id)
                    Logger.logAlways(data,"can_finish 2 ")
                    self:paySuccess(goodsInfo, errmsg)
                    
                else
                    
                end
                EventDispatcher:registerTimeEvent(
                    "pay_delay_call_timer_pay_check",
                    function()
                        local url = NetUrl.getUrlForKey("user_heartbeat")
                        NetWork:httpRequest(nil,url,GlobalConfig.POST,nil,"user_heartbeat",0)
                        Logger.logAlways(data,"buyResult")
                    end,
                    2,
                    10)

            end,url,GlobalConfig.POST,params,"payment_ios",1,nil,0)



        else
            if result == 0 then
                SDKUtil:onEventPurchase(goodsInfo,true);
                self:paySuccess(goodsInfo, errmsg)
                EventDispatcher:registerTimeEvent(
                        "pay_delay_call_timer_pay_check",
                        function()
                            local url = NetUrl.getUrlForKey("user_heartbeat")
                            NetWork:httpRequest(nil,url,GlobalConfig.POST,nil,"user_heartbeat",0)
                            Logger.logAlways(data,"buyResult")
                        end,
                        2,
                        20)
            else
                self:payFailed(nil, errmsg)
                --if result == -1 then
                --    SDKUtil:onEventPurchase(goodsInfo,false);
                --end
            end
        end



    end

    -- local uid = UserDataManager.server_data.server_data.uid
    SDKUtil:pay(buyResult, goodsInfo)
end

---开始支付
--@params goodsId 商品id
--@act_id 活动id
--@act_item_id 活动中某一个id
function M:startPay(cfg)
    local goodsInfo = self:getCommonGoodsInfo(cfg) -- 获取商品信息
    self:payBegan(goodsInfo)
    self:startPayCommon(goodsInfo)
end

-- 虚拟充值
function M:testPay(cfg)
    local params = {}
    params.charge_id = cfg.buy_id
    cfg.goods_id = tostring(cfg.buy_id)
    local url = NetUrl.getUrlForKey("user_payment_charge")
    url = tostring(url) .. "&" .. NetUrl.getExtUrlParam()
    NetWork:httpRequest(
        function(data)
            if data.status == true then
                self:paySuccess(cfg)
            else
                self:payFailed()
            end
        end,
        url,
        GlobalConfig.POST,
        params,
        "user_payment_charge",
        0
    )
end

---支付购买
--@params data 商品配置
--@params callback 购买回调
function M:rechargeByData(data, callback)
    self.m_callBack = callback
    if (not data) then
        self:rechargeCallBack("no_item") --提示
    else
        if self.m_pay_test then
            self:testPay(data)
        else
            if SDKUtil.is_no_sdk then
                self:rechargeCallBack("invalid") --提示
            else
                self:startPay(data) --开始购买
            end
        end
    end
end

---支付购买
--@params data 商品配置id
--@params callback 购买回调
function M:rechargeByChargeId(charge_id, callback)
    local function check_charge_over(data)
        if data then
            local charge = ConfigManager:getCfgByName("charge")
            local cfg = charge[charge_id]
            if cfg then
                static_rootControl:openView("Loading.SmallLoading", {delay_show = 0}, "pay_small_loading")
                self:autoCloseLoading()
                GameUtil:sendPayment(charge_id, 1)
                local function rechargeBack(params)
                    if not self.m_hidePayTips then
                        GameUtil:lookInfoTips(static_rootControl, {msg = params.payMsg, delay_close = 2})
                    end
                    EventDispatcher:registerTimeEvent(
                        "pay_delay_call_timer2",
                        function()
                            if callback then
                                callback(params)
                            end
                        end,
                        2,
                        2
                    )
                end
                PayUtil:rechargeByData(cfg, rechargeBack)
            else
                GameUtil:lookInfoTips(static_rootControl, {msg = "new_str_0731", delay_close = 2})
            end
        end
    end
    local params = {}
    local charge = ConfigManager:getCfgByName("charge")
    local cfg = charge[charge_id]
    if cfg then
        local info = self:getCommonGoodsInfo(cfg);
        params.charge_id = charge_id
        params.product_id = info.cost
        params.cost_id = info.cost_key
        params.package_name = SDKUtil.sdk_params.applicationId
    end

    Logger.logAlways(params,"charge_check  params");

    local url = NetUrl.getUrlForKey("charge_check")
    NetWork:httpRequest(check_charge_over,url,GlobalConfig.POST,params,"charge_check",0)
end

--- 回调
function M:rechargeCallBack(payCode, payMsg, goodsId)
    self:autoCloseLoading(2)
    payMsg = payMsg or ""
    goodsId = goodsId or ""
    if payCode == "no_item" then -- 没有支付项配置
        payMsg = Language:getTextByKey("pay_invalid")
    elseif payCode == "invalid" then
        payMsg = Language:getTextByKey("pay_invalid")
    end
    if type(self.m_callBack) == "function" then
        self.m_callBack({code = payCode, payMsg = payMsg, goodsId = goodsId})
    end
    self:destory()
end

--- 开始支付
function M:payBegan(payInfo)
    self:payBeginToBi(payInfo)
end

--- 支付成功
function M:paySuccess(payInfo)

    Logger.logAlways(payInfo,"paySuccess game")

    local goods_id = ""
    if payInfo and payInfo.goods_id then
        GameUtil:sendPayment(payInfo.goods_id, 2,payInfo)
        goods_id = payInfo.goods_id
    end
    self:rechargeCallBack("success", Language:getTextByKey("new_str_0734"), goods_id)
    if self.m_pay_test ~= true then
        self:paySuccessToBi(payInfo)
    end
end

--- 支付取消
function M:payCancel(payInfo)
    if payInfo and payInfo.goods_id then
        GameUtil:sendPayment(payInfo.goods_id, 3,payInfo)
    end
    self:rechargeCallBack("cancel", Language:getTextByKey("new_str_0736"))
end

--- 支付失败
function M:payFailed(payInfo, errorMsg)
    if payInfo and payInfo.goods_id then
        GameUtil:sendPayment(payInfo.goods_id, 4,payInfo)
    end
    self:rechargeCallBack("failed", errorMsg or Language:getTextByKey("new_str_0735"))
end

--- 自动关掉loading
function M:autoCloseLoading(delay_time)
    delay_time = delay_time or 5
    local function closeLoading()
        if static_rootControl then
            static_rootControl:closeView("Loading.SmallLoading", "pay_small_loading")
        end
    end
    EventDispatcher:registerTimeEvent(
        "auto_close_loading_timer",
        function()
            closeLoading()
        end,
        delay_time,
        delay_time
    )
end

function M:payBeginToBi(payInfo)
end

function M:paySuccessToBi(payInfo)
end

--- 关闭支付
function M:close()
    self:destory()
end

function M:destory()
    self.m_callBack = nil
    self.m_ios_currency = nil
end

return M
