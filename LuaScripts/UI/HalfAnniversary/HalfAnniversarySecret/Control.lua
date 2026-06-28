local M = class("HalfAnniversarySecretControl", LikeOO.OOControlBase)

function M:onEnter()
    --audio:SendEvtUI("UI_XLQB")
    self:updateTime()
    self.m_timer_id = self:setTimer(1,handler(self,self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then -- 关闭
        self:updateMsg("refresh_entrances", nil, "HalfAnniversary.HalfAnniversaryMain") 
		self:closeView()
    elseif msg == "open_scroll" then
        self:openScroll(data)
    elseif msg == "get_ace_pag_btn" then
        QuickOpenFuncUtil:openFunc(100001, { open_id = 327, level_up = 1 })
        self:closeView()
        --local params = {
        --    version = self.m_model.m_data.version,
        --    quests= self.m_model.m_data.quests,
        --    buy_times = self.m_model.m_data.buy_times,
        --}
        --self:openView("GiftBag.GiftScrollTaskPop", params)
    -- elseif msg == "yulan_btn" then    
    --     local params = {
    --         floor = self.m_model.m_data.layer,
    --         big_gift_id = self.m_model.m_data.big_gift_id,
    --         version = self.m_model.m_data.version,
    --         big_rcvd = self.m_model.m_data.big_rcvd
    --     }
    --     self:openView("GiftBag.GiftLookScrollPop", params)
    elseif msg == "yulan_btn" then    
        local params = {
            floor = self.m_model.m_data.layer,
            big_gift_id = self.m_model.m_data.big_gift_id,
            version = self.m_model.m_data.version,
            big_rcvd = self.m_model.m_data.big_rcvd
        }
        self:openView("HalfAnniversary.HalfAnniversarySecretSelectPop", params)
    elseif msg == "big_reward_btn" then
        local big_reward_cfg = self.m_model:checkBigRcvd()
        local rewardTable = big_reward_cfg.reward[1] or nil
        local big_reward_btn = self.m_view:findGameObject("big_reward_btn")
        if rewardTable then
            local item_data = RewardUtil:getProcessRewardData(rewardTable)
            if item_data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
                static_rootControl:openView("HeroInfo.EquipmentPop", {equip_cfg_id = item_data.data_id, race = item_data.race, look_model = 3})
            elseif item_data.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
                static_rootControl:openView("Item.ItemDetail", {show_data = item_data, display = true}, nil, true)
            elseif item_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or item_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT or item_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS_EXT then
                static_rootControl:openView("Pops.HeroLookInfo", {hero_id = item_data.data_id, is_new = false})
            elseif item_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HERO_SKIN then
                local hero_id = item_data.item_cfg.hero
                static_rootControl:openView("Pops.HeroLookInfo", {hero_id = hero_id, is_new = false, skin_id = item_data.data_id})
            elseif item_data.data_type == RewardUtil.REWARD_TYPE_KEYS.MYSTIC then
                static_rootControl:openView("SutraDepository.DepositoryPop", {oid = item_data.data_id, mode = 2, star = item_data.star})
            elseif item_data.data_type == RewardUtil.REWARD_TYPE_KEYS.TITLE then
                self:openView("Title.TitleDetail", {show_data = item_data, display = true})
            else
                static_rootControl:openView("Pops.CommonItemTipsPop", {data = item_data, target_obj = big_reward_btn})
            end
        end
    elseif msg == "next_layer" then
        self:nextScroll()
    elseif msg == "reward_btn" then
        local function callback()
            self.m_view:refreshUI()
        end
        self:openView("DoubleFestivalActivity.SmashEggBuyPop", {m_openId = self.m_model.m_open_id, m_version = self.m_model.m_data.version, callback = callback})
    elseif msg == "updateBigPrize" then
        self.m_model.m_data.big_gift_id = data or 0
        self.m_view:refreshUI()
        self.m_view:updateShuaXinEffect(true)
    elseif msg == "jinnang_ben" then
        local active_tab = ConfigManager:getCfgByName("active")
        local jn_cfg = nil
        for k,v in pairs(active_tab) do
            if v.open_id == self.m_model.m_open_id then
                jn_cfg = v
            end
        end
        local scroll_tab = ConfigManager:getCfgByName("monster")
        local scroll_cfg = scroll_tab[self.m_model.m_data.version]
        local params = {}
        params.content = scroll_cfg.des
        params.title = self.m_model:getPanelName()
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "updateScrollData" then
        --self.m_model.m_data.quests = data.quests
    elseif msg == "refreshUI" then
        self.m_view:refreshUI()
    elseif msg == "updateScrollBuyData" then
        self.m_model.m_data.buy_times = data
    elseif msg == "to_active_obj" then --侠客试炼
        --self:closeView("Activities.WorldBoss.HeroBossTrainPop")
        --self:setOnceTimer(0.1,function ()
        --    self:updateMsg(99999)
        --end)
        --QuickOpenFuncUtil:openFunc(78)  
    end
end

function M:openScroll(data)
    local comsume_data = self.m_model:getScrollConsume()
    if comsume_data == nil then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        return
    end
    audio:SendEvtUI("UI_XLQB_ClickChess")
    local scroll_cfg = self.m_model:getScrollCfg()
    if self.m_model.m_data.times >=  scroll_cfg.free_time  then
        if comsume_data.data_num > comsume_data.user_num then
            local params = {
                text = Language:getTextByKey("new_str_0700"),
                tow_close_btn = true,
                on_ok_call = function ()
                    self:updateMsg("get_ace_pag_btn")
                end
            }
            self:openView("Pops.CommonPop", params)
            return
        end
    end
    
    local function callback(response)
        self:netCheckEndTips(response)
        if response["end"] == 1  or response["update"] == 1 then
            return
        end
        self.m_model.m_data = response
        local function show_reward()
            if response.big_pos ~= 0 then
                self.m_view:playGetBigEffext(response.big_pos, function ()
                    local big_reward_cfg = self.m_model:checkBigRcvd()
                    RewardUtil:rewardTipsByRewards(big_reward_cfg.reward)
                    self.m_view:refreshUI()
                end)
            else
                if response.reward then
                    RewardUtil:rewardTipsByData(response.reward)
                    local last = self.m_model:checkLastFloor()
                    if last then
                        local get_num = 0
                        for i = 1, 16 do
                            local rcvd_gift = self.m_model:getScrollRcvdGift(i)
                            if rcvd_gift and next(rcvd_gift) ~= nil then
                                get_num = get_num + 1
                            end
                        end
                        if get_num >= 16 then
                            self.m_view:updateScrollItems()
                        else
                            if data.position and data.position > 0 then
                                self.m_view:updateOneRewardItem(data.position)
                            end
                        end
                    else
                        if data.position and data.position > 0 then
                            self.m_view:updateOneRewardItem(data.position)
                        end
                    end
                end
            end
            self.m_view:updateCostUI()
        end
        if response.bomb_data and next(response.bomb_data) ~= nil then
            audio:SendEvtUI("UI_XLQB_fx_1")
            self.m_view:setBoomEffect(response.bomb_data, show_reward) 
        else
            show_reward()
        end
    end
    local params = {}
    params.position = data.position
    params.vsn = data.vsn
    self.m_model:getNetData("active_open_monster", params, callback)
end

function M:nextScroll()
    local function callback(response)
        self:netCheckEndTips(response)
        if response["end"] == 1 or response["update"] == 1 then
            return
        end
        self.m_model.m_data = response
        self.m_view:refreshUI()
        self.m_view:pieceEnterAnim()
    end
    local params = {}
    params.vsn = self.m_model.m_data.version
    self.m_model:getNetData("active_monster_enter_next", params, callback)
end

function M:netCheckEndTips(response)
    if response["end"] == 1 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
        static_rootControl:closeAllViewPop()
    elseif response["update"] == 1 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("yinTower_text_0013"), delay_close = 2})
        static_rootControl:closeAllViewPop()
    end
end

function M:updateTime()
    self.m_view:updateTime()
end

function M:destroy()
    if self.m_timer_id then
        self:removeTimer(self.m_timer_id)
    end
    M.super.destroy(self)
end

return M;