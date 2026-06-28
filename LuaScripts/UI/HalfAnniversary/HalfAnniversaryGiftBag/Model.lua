---@class HalfAnniversaryGiftBagModel: OODataBase
local M = class("HalfAnniversaryGiftBagModel", LikeOO.OODataBase)

function M:onCreate1()
    M.super.onCreate(self)
   
end

function M:onEnter()
    self:initData(self.m_data)
end

function M:onCreate()
    M.super.onCreate(self)
    local param = {}
    self.m_open_id = self.m_params.openId or 329
    self.m_version = self.m_params.version or self:getVersion()
    self:getData("active_common_gift_index", {open_id = self.m_open_id, vsn = self.m_version})
end

function M:getVersion()
    local activeXlsxData = UserDataManager:getActivesRechargeDataByOpenId(self.m_params.openId)
    if activeXlsxData then
        return activeXlsxData.version
    end
    return 1
end

function M:onEnter()
    self.is_tokens = self.m_params.is_token or 1
    self.cur_page = "1" -- 页签本功能只有1
    self:initData(self.m_data)
    self:initHeroSkinCfg()
end

function M:initData(response)
    if response then
        self.m_gifts_data = response.gifts_data or {}
        self.m_day = response.config_day[self.cur_page] or 1
        self.m_clothes_gifts = response.clothes_gifts or {}
    end
end

function M:updateGiftDataFree(data)
    self.m_gift_data = data or {}
    self:getGiftShowData()
end

function M:getXlsxActivityByOpenId(openId, isRechargeActivity)
    local xlsxName = isRechargeActivity and "active_recharge" or "active"
    local active = ConfigManager:getCfgByName(xlsxName)
    for _,itemData in pairs(active) do
        if (itemData.version == self.m_version) and (openId == itemData.open_id) then
            return itemData
        end
    end
    return nil
end

--阶梯礼包配置数据
function M:get_ladderGiftData()
    local gift_value_tab = ConfigManager:getCfgByName("tongyong_gift")
    local version_tab = gift_value_tab[self.m_open_id][self.m_version][tonumber(self.cur_page)] or {}
    local new_tab = {}
    local giftData = self.m_gifts_data[self.cur_page] or {}
    for index, data in pairs(giftData) do
        index = tonumber(index)
        local xlsxSeatGiftDatas = version_tab[self.m_day][index] or {}
        local cid = data.cid
        local curGiftData = xlsxSeatGiftDatas[cid]
        if curGiftData then
            -- 限购次数，VIP等级，累计金额，章节限制，章节范围限制
            local isCanBuy = true
            cid, isCanBuy = self:trimEveryDayLadderBagData(curGiftData, data)
            -- <=0, 表示第一个礼包，第一个礼包不符合购买需求则隐藏礼包
            if cid > 0 then
                curGiftData = xlsxSeatGiftDatas[cid]
                table.insert(new_tab,{
                    xlsxData = curGiftData,
                    cid = data.cid,
                    buyCount = data.times,
                    isCanBuy = isCanBuy,
                    index = index,
                })
            end
        end
    end

    table.sort(new_tab,function(itemData1,itemData2)
        local canBuyIndex1 = itemData1.isCanBuy and 1 or 2
        local canBuyIndex2 = itemData2.isCanBuy and 1 or 2
        if canBuyIndex1 ~= canBuyIndex2 then
            return canBuyIndex1 < canBuyIndex2
        else
            return itemData1.index < itemData2.index
        end
    end)
    return new_tab
end


-- 修改阶梯礼包数据，判断规则：限购次数，VIP等级，累计金额，章节限制，章节范围限制
function M:trimEveryDayLadderBagData(curGiftData, data)
    local cid = data.cid
    local isCanBuy = true
    if (curGiftData.time_limit > 0) then
        isCanBuy = data.times < curGiftData.time_limit
    end
    local userDataManager = UserDataManager
    local curVipLevel = userDataManager.user_data:getUserStatusDataByKey("vip")
    if isCanBuy and (curGiftData.vip > 0) then
        isCanBuy = curVipLevel >= curGiftData.vip
    end
    if isCanBuy and (curGiftData.add_recharge > 0) then
        isCanBuy = userDataManager.charge_sum >= curGiftData.add_recharge
    end
    local curChapterId = userDataManager:getCurStage()
    if isCanBuy and (curGiftData.stage > 0) then
        isCanBuy = curChapterId >= curGiftData.stage
    end
    if isCanBuy and curGiftData.stage_limit and #curGiftData.stage_limit > 0 then
        local chapterLimit = curGiftData.stage_limit
        isCanBuy = curChapterId >= chapterLimit[1] and curChapterId <= chapterLimit[2]
    end
    cid = isCanBuy and cid or (cid - 1)
    -- 1. 只有一层，买完后要显示已售罄
    -- 2. 只有一层，不符合条件要隐藏
    if cid <= 0 then
        cid = (data.times <= 0) and 0 or 1  --times 买没买过
    end
    return cid, isCanBuy
end

function M:getEndTs()
    local server_time = UserDataManager:getServerTime()
    local next_fresh_time = TimeUtil.getIntTimestamp(server_time)
    local end_times = next_fresh_time + 24 * 3600
    return end_times
end


----数据初始化-英雄皮肤/宝箱
function M:initHeroSkinCfg()
    local clothes_tab = ConfigManager:getCfgByName("tongyong_hero_gift")[self.m_open_id] or {}
    local clothes_version_tab = clothes_tab[self.m_version] or {}
    self.m_hero_gift_cfg = clothes_version_tab[1] or {}
end

--展示活动时间
function M:getActiveShowTime()
    local activity_Data = UserDataManager:getActivesRechargeDataByOpenId(self.m_open_id)
    if activity_Data then
        local function __timeToTs(txt)
            return os.date("%Y.%m.%d",txt)
        end
        return Language:getTextByKey("moon_shadow_str_005", __timeToTs(activity_Data.start_ts), __timeToTs(activity_Data.end_ts))
    end
    return ""
end

function M:checkClothGift()
    if self.m_hero_gift_cfg then
        --id默认1  只有有两个皮肤的时候会有2
        return self.m_clothes_gifts[tostring(1)] or 0
    end
    return 0
end

return M