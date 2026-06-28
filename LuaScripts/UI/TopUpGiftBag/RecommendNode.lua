local M = class("RecommendNode",LikeOO.OOUIbase)
--推荐
M.m_uiName = "TopUpGiftBag/RecommendNode"

function M:onEnter()
    --设置文本文字
    self:setTextByLanKey("goto_text_1","gf_str_0025") --特惠礼包
    self:setTextByLanKey("get_text_1","gf_str_0048") --领取
    self:setTextByLanKey("get_text_2","gf_str_0048") --已购买
    self:setTextByLanKey("btn_one_text","new_str_0794") --累计充值
    self:setTextByLanKey("btn_two_text","gf_str_0023") --连续充值
    self:setTextByLanKey("Received_text_1","new_str_0080") --已领取
    self:setTextByLanKey("go_to_get_text","gf_str_0122") --前往领取
    self:setTextByLanKey("go_to_get_text2","gf_str_0122") --前往领取
    self:setTextByLanKey("shop_text","gf_str_0011") --元宝商店
    self:setObjectVisible("btn_one_red_point", false)
    self:setObjectVisible("btn_two_red_point", false)
    for i = 1, 3 do
        self:setObjectVisible("node_" .. i, false)
    end
    self.m_end_ts = 0
    self.actives = self.m_model.actives
end

function M:updateGetRewardData( data )
    --Logger.logError( data," 获取奖励回调 ")
    self.m_status_1 = data.status
    self.m_model.m_incr_vsn = data.incr_vsn
end

--初始化数据
function M:switchInit(url, data, id, callback)
    local function callFunc(data)
        if callback then
            callback(data)
        end
        self:init(data)
        --Logger.logError(data,"活动数据")
    end
    self.m_model:initData(url, callFunc)
end

function M:switchUI(data, id)
    self:init(self.m_model.m_recommend_data)
end

--获取累计充值时间
function M:getEndTime()
    for i, v in ipairs(self.actives) do
        local id = v.id
        if id == 11 then
            self.m_end_ts = v.end_ts
            --Logger.logError(self.m_end_ts,"结束时间")
        end
    end
end

--刷新
function M:refreshUI()
    --self:getEndTime()
    if self.server_data == nil then
        return
    end
    self.m_control:updateTime()
    self:setNodeOne()
    self:setNodeTwe()
    self:setNodeThree()
    self:setObjectVisible("btn_one_red_point", RedPointUtil:hasRedPointById(55))
    self:setObjectVisible("btn_two_red_point", RedPointUtil:hasRedPointById(103))
    local total_charge_btn = self.m_model:checkHaveActive(130) -- 累充
    local totll_pay_btn = self.m_model:checkHaveActive(79) -- 连充\
    self:setObjectVisible("btn_one", totll_pay_btn == true)
    self:setObjectVisible("btn_two", total_charge_btn == true)
    if totll_pay_btn == true then
        local cfg = self.m_model:getActiveByOpenId(79)
        self:setTextByLanKey("totll_pay_text", cfg.name_2)
    end
    local btn_two_Img = self:findImage("btn_two_Img")
    local btn_two = self:findImage("btn_two")
    if UserDataManager:getCurOffSeasonDays() == true then
        GameUtil:updateResourcesImg(btn_two_Img,"Texture/zh_cn/a_cz_mrcz_zt")
        GameUtil:updateResourcesImg(btn_two,"Texture/a_cz_mrcz_bg")
    else
        GameUtil:updateResourcesImg(btn_two_Img,"Texture/zh_cn/a_tj_leijichongzhi_zi")
        GameUtil:updateResourcesImg(btn_two,"Texture/a_tj_leijichongzhi_di")
    end
end

--初始化获取数据
function M:init(data)
    if data == nil then
        return
    end
    self.server_data = data;
    self.m_end_ts = self.m_model:getActiveNearEndTime(data.actives) or 0
    local activity_limit = ConfigManager:getCfgByName("activity_limit")
    --第一位置数据
    self.data_1 = data["recommend"]["1"]
    self.m_version_1 = self.data_1.version
    self.m_open_id_node_1 = self.data_1.open_id
    if (self.m_open_id_node_1 == 201) or (self.m_open_id_node_1 == 200) then
        -- 每周阶梯礼包
        self.m_weekLadderBagData1 = self.m_model:trimReCommendEveryWeekLadderBagData(self.m_version_1, self.data_1.cid, 
                    self.data_1.pos, self.data_1.times,data.charge_sum,self.m_open_id_node_1)
    else
        -- 限时礼包、新手礼包(原逻辑)
        self.m_gid_1 = self.data_1.gid
        self.m_detail_1 = self.data_1.detail
        self.m_reward_config_1 = activity_limit[self.m_version_1] or {}
        self.m_end_ts_1 = self.data_1.end_ts
        self.n_version = self.data_1.version --新手礼包
        self.n_gift_id = self.data_1.gift_id --新手礼包
    end
    
    
    --第二位置数据
    self.data_2 = data["recommend"]["2"]
    self.m_version_2 = self.data_2.version
    self.m_open_id_node_2 = self.data_2.open_id
    if (self.m_open_id_node_2 == 201) or (self.m_open_id_node_2 == 200) then
        -- 每周阶梯礼包
        self.m_weekLadderBagData2 = self.m_model:trimReCommendEveryWeekLadderBagData(self.m_version_2, self.data_2.cid, 
                    self.data_2.pos, self.data_2.times,data.charge_sum,self.m_open_id_node_2)
    elseif self.m_open_id_3 == 116 then --推送礼包
        -- 限时礼包
        self.m_gid_2 = self.data_2.gid
        self.m_detail_2 = self.data_2.detail
        self.m_reward_config_2 = activity_limit[self.m_version_2]
        self.m_end_ts_2 = self.data_2.end_ts
    end
    
    --第三位置数据
    self.data_3 = data["recommend"]["3"]
    self.m_open_id_3 = self.data_3.open_id
    if self.m_open_id_3 == 116 then --限时礼包
        self.m_version_3 = self.data_3.version
        self.m_gid_3 = self.data_3.gid
        self.m_reward_config_3 = self.data_3.reward_config
        self.m_detail_3 = self.data_3.detail
        self.m_end_ts_3 = self.data_3.end_ts
    elseif self.m_open_id_3 == 87 then --推送礼包
        self.m_gift_id = self.data_3.gift_id
        self.m_gift_expire_ts = self.data_3.gift_expire_ts
    end
    self:refreshUI()
end

--设置node1的状态
function M:setNodeOne()
    local node_1 = self:findGameObject("node_1")
    local node_1_show = false
    if self.m_open_id_node_1 ~= nil then
        node_1_show = true
        local reward = {}
        local price = nil
        local Purchased_btn_show = false
        local limitText = nil
        local PurchaseTimes_text_show = true
        local PurchaseTimes_text = self:findGameObject("PurchaseTimes_text_1")
        if (self.m_open_id_node_1 == 201) or (self.m_open_id_node_1 == 200) then
            --- 每周礼包
            local m_weekLadderBagData = nil
            m_weekLadderBagData, limitText = self:refreshEveryWeekLadderNode(1)
            if m_weekLadderBagData then
                local xlsxData = m_weekLadderBagData.xlsxData
                reward = xlsxData.reward
                local isCanBuy = m_weekLadderBagData.isCanBuy
                Purchased_btn_show = (not isCanBuy)
            end
        else
            local limint_info = { }
            if self.n_gift_id and self.n_version then
                local gift_new = ConfigManager:getCfgByName("gift_new")
                limint_info = gift_new[self.n_version][self.n_gift_id]
                reward = limint_info.reward
                price =  GameUtil:getMoneyTypeNum(limint_info.price)
                self:setTextByLanKey("return_per_text_1", (tonumber(limint_info.return_per) *100).."%"  )
            else
                --加载奖励
                reward = self.m_reward_config_1[self.m_gid_1].reward
                limint_info = self.m_reward_config_1[self.m_gid_1]
                self:setTextByLanKey("return_per_text_1", (tonumber(limint_info.return_per) *100).."%"  )
                price = GameUtil:getMoneyTypeNum(limint_info.price)
                --补充奖励添加
                local exchange_reward_id =limint_info.exchange_reward
                local exchange_reward = ConfigManager:getCfgByName("exchange_reward")
                local ex_tab = exchange_reward[UserDataManager.m_exchange_vsn]
                if ex_tab then
                    if ex_tab[exchange_reward_id] then
                        local other_reward = ex_tab[exchange_reward_id].reward or {}
                        local reward_lenght = #reward
                        if reward_lenght >= 4 then
                            for i, v in ipairs(other_reward) do
                                local pos = 4+i-1
                                table.insert(reward,pos,v)
                            end
                        else
                            for i, v in ipairs(other_reward) do
                                table.insert(reward,v)
                            end
                        end
                    end
                end
            end
            self:setTextByLanKey("price_text_1",price)
            self.m_model.recommend_node1_charge_id = limint_info.charge_id
            --设置显示状态
            local buy_btn = self:findGameObject("buy_btn_1")
            local Purchased_btn = self:findGameObject("Purchased_btn_1")
            local buy_btn_show = false
            if self.m_detail_1 and self.m_detail_1[tostring(self.m_gid_1)] ~= nil then
                local buy_time = self.m_detail_1[tostring(self.m_gid_1)]
                local max_time = limint_info.time_limit
                if max_time == 0 then --不限购，可购买
                    buy_btn_show = true
                    limitText = Language:getTextByKey("gf_str_0105")
                elseif max_time - buy_time >0 then --有购买次数
                    buy_btn_show = true
                    limitText = Language:getTextByKey("gf_str_0050", (max_time - buy_time))
                else --没购买次数
                    PurchaseTimes_text_show = false
                    Purchased_btn_show = true
                end
            else
                buy_btn_show = true
                -- 新手礼包都限购1次
                limitText = Language:getTextByKey("gf_str_0050", 1)
            end
            buy_btn.gameObject:SetActive(buy_btn_show)
            Purchased_btn.gameObject:SetActive(Purchased_btn_show)
        end
        PurchaseTimes_text.gameObject:SetActive(PurchaseTimes_text_show)
        self:setNode(1,"gf_str_0026",nil,reward,limitText,Purchased_btn_show)
    end
    --设置第二位置显示状态
    node_1.gameObject:SetActive(node_1_show)
end


--设置node2的状态
function M:setNodeTwe()
    --第二位置状态
    local node_2 = self:findGameObject("node_2")
    local node_2_show = false
    if self.m_open_id_node_2 ~= nil then
        node_2_show = true
        local limitText = nil
        local reward = {}
        local Purchased_btn_show = false
        local PurchaseTimes_text = self:findGameObject("PurchaseTimes_text_2")
        local PurchaseTimes_text_show = true
        if self.m_open_id_2 == 116 then --限时礼包
            limitText = nil
            --加载奖励
            reward = self.m_reward_config_2[self.m_gid_2].reward
            local limint_info = self.m_reward_config_2[self.m_gid_2]
            local price = GameUtil:getMoneyTypeNum(limint_info.price)
            self:setTextByLanKey("return_per_text_2", (tonumber(limint_info.return_per) *100).."%"  )
            --补充奖励添加
            local exchange_reward_id =limint_info.exchange_reward
            local exchange_reward = ConfigManager:getCfgByName("exchange_reward")
            local ex_tab = exchange_reward[UserDataManager.m_exchange_vsn]
            if ex_tab then
                if ex_tab[exchange_reward_id] then
                    local other_reward = ex_tab[exchange_reward_id].reward or {}
                    local reward_lenght = #reward
                    if reward_lenght >= 4 then
                        for i, v in ipairs(other_reward) do
                            local pos = 4+i-1
                            table.insert(reward,pos,v)
                        end
                    else
                        for i, v in ipairs(other_reward) do
                            table.insert(reward,v)
                        end
                    end
                end
            end
            self.m_model.recommend_node2_charge_id = limint_info.charge_id
            --设置显示状态
            local buy_btn = self:findGameObject("buy_btn_2")
            local Purchased_btn = self:findGameObject("Purchased_btn_2")
            local buy_btn_show = false
            if self.m_detail_2[tostring(self.m_gid_2)] ~= nil then
                local buy_time = self.m_detail_2[tostring(self.m_gid_2)]
                local max_time = limint_info.time_limit
                if max_time == 0 then --不限购，可购买
                    buy_btn_show = true
                    limitText = Language:getTextByKey("gf_str_0105")
                elseif max_time - buy_time >0 then --有购买次数
                    buy_btn_show = true
                    limitText = Language:getTextByKey("gf_str_0050", (max_time - buy_time))
                else --没购买次数
                    Purchased_btn_show = true
                    PurchaseTimes_text_show = false
                end
            else
                buy_btn_show = true
                -- 新手礼包都限购1次
                limitText = Language:getTextByKey("gf_str_0050", 1)
            end
            buy_btn.gameObject:SetActive(buy_btn_show)
            Purchased_btn.gameObject:SetActive(Purchased_btn_show)
            self:setTextByLanKey("price_text_2",price)
        elseif (self.m_open_id_node_2 == 201) or (self.m_open_id_node_2 == 200) then
            --- 每周礼包
            local m_weekLadderBagData = nil
            m_weekLadderBagData, limitText = self:refreshEveryWeekLadderNode(2)
            if m_weekLadderBagData then
                local xlsxData = m_weekLadderBagData.xlsxData
                reward = xlsxData.reward
                local isCanBuy = m_weekLadderBagData.isCanBuy
                Purchased_btn_show = (not isCanBuy)
            end
        end
        PurchaseTimes_text.gameObject:SetActive(PurchaseTimes_text_show)
        self:setNode(2,"gf_str_0026",nil,reward,limitText,Purchased_btn_show)
    end
    --设置第二位置显示状态
    node_2.gameObject:SetActive(node_2_show)
end

-- 刷新每日，每周阶梯礼包节点
function M:refreshEveryWeekLadderNode(index)
    local m_weekLadderBagData = self["m_weekLadderBagData"..index]
    if not m_weekLadderBagData then
        return nil
    end
    local xlsxData = m_weekLadderBagData.xlsxData
    reward = xlsxData.reward
    local isCanBuy = m_weekLadderBagData.isCanBuy
    Purchased_btn_show = (not isCanBuy)
    -- 限购
    local limitText = nil
    if xlsxData.time_limit == 0 then
        limitText = Language:getTextByKey("gf_str_0105")
    else
        local residueCount = (xlsxData.time_limit-m_weekLadderBagData.buyCount)
        residueCount = isCanBuy and residueCount or 0
        limitText = Language:getTextByKey("gf_str_0050", residueCount)
    end
    --设置显示状态
    self:setObjectVisible("buy_btn_"..index, isCanBuy)
    self:setObjectVisible("Purchased_btn_"..index, (not isCanBuy))
    self:setTextByLanKey("return_per_text_"..index, (tonumber(xlsxData.return_per) *100).."%")
    self:setObjectVisible("PurchaseTimes_text_"..index, (not isCanBuy))
    if xlsxData.price == 0 then
        self:setTextByLanKey("price_text_"..index,"new_str_0278")
    else
        self:setTextByLanKey("price_text_"..index,GameUtil:getMoneyTypeNum(xlsxData.price))
    end
    self.m_model["recommend_node"..index.."_charge_id"] = xlsxData.charge_id
    return m_weekLadderBagData, limitText
end

--设置node3的状态
function M:setNodeThree()
    local node_3 = self:findGameObject("node_3")
    local node_3_show = false
    local PurchaseTimes_text_3 = self:findGameObject("PurchaseTimes_text_3")
    local PurchaseTimes_text_3_show = false
    local gift_time_text = 0;
    if  self.m_open_id_3 ~= nil then
        --显示奖励
        local reward = {}
        if self.m_open_id_3 == 116 then
            reward = self.m_reward_config_3[tostring(self.m_gid_3)].reward
        end
        local price = 1
        local title_name = 1
        if self.m_open_id_3 == 116 then --限时礼包
            local activity_limit = ConfigManager:getCfgByName("activity_limit")
            local limint_info = table.copy(activity_limit[self.m_version_3][self.m_gid_3])
            self:setTextByLanKey("return_per_text_3", GameUtil:formatNum(tonumber(limint_info.return_per) *100).."%"  )
            title_name = "gf_str_0007"
            price =  GameUtil:getMoneyTypeNum(limint_info.price)
            self.m_model.recommend_node3_charge_id = limint_info.charge_id
            --是否有礼包可领取
            if self.m_detail_3[self.m_gid_3] ~= nil then
                local buy_time = self.m_detail_3[self.m_gid_3]
                local max_time = limint_info.time_limit
                if max_time == 0 then --不限购，可购买
                    node_3_show = true
                elseif max_time - buy_time >0 then --有购买次数
                    node_3_show = true
                else --没购买次数
                    --node_3_show = false
                end
            else
                node_3_show = true
            end
        elseif self.m_open_id_3 == 87 then --推送礼包
            node_3_show = true
            PurchaseTimes_text_3_show = true
            local limit_gift = ConfigManager:getCfgByName("limit_gift")
            title_name = "new_str_0800"
            local limint_info = limit_gift[self.m_gift_id]
            if not limint_info then
                Logger.logErrorAlways(self.m_gift_id,"RecommendNode not find limint_info, self.m_gift_id == ")
                return
            end
            self:setTextByLanKey("return_per_text_3", GameUtil:formatNum(tonumber(limint_info.return_per) *100).."%"  )
            reward = table.copy(limit_gift[self.m_gift_id].reward) or {}
            local ex_resards = self:getExtraRewards(self.m_gift_id)
            if next(ex_resards) ~= nil then
				if #reward >= 1 then
					for i = 1, #ex_resards do
						table.insert(reward, i+1, ex_resards[i] )
					end
				else
					for i = 1, #ex_resards do
						table.insert(reward, ex_resards[i] )
					end
				end
			end
            price = GameUtil:getMoneyTypeNum(limit_gift[self.m_gift_id].price)
            self.m_model.recommend_node3_charge_id = limit_gift[self.m_gift_id].charge_id
            gift_time_text = self:setGiftTime()
        end
        self:setTextByLanKey("price_text_3",price)
        self:setNode(3,title_name,nil,reward,gift_time_text)
    end
    
    --设置第三位置显示状态
    PurchaseTimes_text_3.gameObject:SetActive(PurchaseTimes_text_3_show)
    node_3.gameObject:SetActive(node_3_show)
end

--获取最大奖励id
function M:getMaxGiftsID(gift_off)
    local max_gift_id = 1;
    if self.m_gifts ~= nil then
        for i, v in ipairs(gift_off) do
            if v.type == 1 then
                local has_gift_id = self:GetGiftValue(i);
                if has_gift_id == nil then
                    if max_gift_id < i then
                        max_gift_id = i;
                    end
                end
            end
        end
    end
    return max_gift_id;
end

--获取奖励值
function M:GetGiftValue( id )
    for i, v in ipairs(self.m_gifts) do
        if id == v then
            return id;
        end
    end
end


--设置node内容
function M:setNode(item_num,title_name,title_icon,reward,limint_text, get)
    --Logger.logError(title_name,"name")
    local name = "name_text_"..item_num
    self:setTextByLanKey(name,title_name) --标题名称
    local icon = "icon_Img_"..item_num
    --self:setImg(title_icon,"active_ui",icon) --设置图片
    local reward_parent_name = "itemParent_"..item_num
    local reward_node = self:findGameObject(reward_parent_name)
    local rewards = self:createRewards(reward_node.transform,reward,true,true,nil,1) --奖励
    local PurchaseTimes = "PurchaseTimes_text_"..item_num
    self:setTextByLanKey(PurchaseTimes,limint_text) --限购文字
    if get and get == true then
        for k,v in pairs(rewards) do
            local luaBehaviour = UIUtil.findLuaBehaviour(v)
            if luaBehaviour then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", true)
            end
        end
    end
end

--创建reward
function M:createRewards(reward_node, rewards, is_show_num, is_show_detail, callback, scale, frame_effect)
    local rewards = rewards or {}
    local items = {}
    scale = scale or 1
    UIUtil.destroyAllChild(reward_node)
    for k,v in pairs(rewards) do
        --Logger.logError( v," 奖励数据 ~~~~~~~~~~ ")
        local item = GameUtil:createItemElement(v, is_show_num, is_show_detail, callback, frame_effect)
        item.transform:SetParent(reward_node, false)
        GameUtil:creatChargeEffect(item, v)
        table.insert( items, item)
        UIUtil.setScale(item.transform, scale)
    end
    return items
end

--更新时间
function M:updateTime()
    if self.m_end_ts ~= nil then
        --local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(self.m_end_ts - UserDataManager:getServerTime(),999)
        --local time_text = "new_str_0485"..hour..":"..min..":"..sec
        local time_text = Language:getTextByKey("new_str_0485")..GameUtil:formatTimeBySecond(self.m_end_ts - UserDataManager:getServerTime(),999)
        self:setTextByLanKey("time_down",time_text)
    end
    if self.m_gift_expire_ts ~= nil then
        self:setGiftTime()
    end
end

--用于检测礼包是否到期
function M:updateActiveEndTs()
    local change_bg = false
    local total_bg = false --累计充值 因为需要刷新赛季信息、所以延后一秒刷新
    if self.m_gift_expire_ts and self.m_gift_expire_ts > 0 then --限时礼包
        local last_tim = self.m_gift_expire_ts - UserDataManager:getServerTime()
        if last_tim <= 0 then
            change_bg = true
        end
    end 
    if change_bg == false and self.m_end_ts and self.m_end_ts > 0 then --累计充值
        local last_tim = self.m_end_ts - UserDataManager:getServerTime()
        if last_tim <= 0 then
            total_bg = true
        end
    end
    if change_bg == false and  self.m_end_ts_3 and self.m_end_ts_3 > 0 then
        local last_tim = self.m_end_ts_3 - UserDataManager:getServerTime()
        if last_tim <= 0 then
            change_bg = true
        end
    end
    if change_bg == false and  self.m_end_ts_2 and self.m_end_ts_2 > 0 then
        local last_tim = self.m_end_ts_2 - UserDataManager:getServerTime()
        if last_tim <= 0 then
            change_bg = true
        end
    end
    if change_bg == true then
        self.m_gift_expire_ts = 0
        self.m_end_ts = 0
        self.m_end_ts_3 = 0
        self.m_end_ts_2 = 0
        self:updateMsg("buy_sdk_update")
    end
    if total_bg == true then
        self.m_end_ts = 0
        --服务器赛季信息刷新有一个延迟 所以延迟两秒请求刷新
        self.m_control:setOnceTimer(2,function ()
            self:updateMsg("common_refresh", nil, "parent")
        end)
        self.m_control:setOnceTimer(3,function ()
            self:updateMsg("updateNewNet")
        end)
    end
end

function M:getExtraRewards(id)
	return UserDataManager.m_push_gifts_extra[tostring(id)] or {}
end

--设置推送礼包时间
function M:setGiftTime()
    local gift_time_text = "剩余时间："..GameUtil:formatTimeBySecond(self.m_gift_expire_ts - UserDataManager:getServerTime(),999)
    self:setTextByLanKey("PurchaseTimes_text_3",gift_time_text)
    return gift_time_text
end

function M:destroy()
    M.super.destroy(self)
end


return M