local M = class("XianControl", LikeOO.OOControlBase)

function M:onEnter()
    self:setTimer(1, handler(self, self.updateTimer))
    self.talk_index = 1
    self.isTalking = false
    audio:SendEvtBGM("Set_State_AXian")
    self:enterGreeting()
    if self.m_model.m_open_npc_guide then
        self:updateMsg("bulim_book_btn")
    end
    SceneManager:getCurSceneModel():setCameraShow(false)
    self.can_lv_up = false
    self:setOnceTimer(0.5, function ()
        self.can_lv_up = true
    end)
    if SDKUtil.is_gmsdk then
        self:getActiveRedPoint()
    end
end

function M:onHandle(msg, data)
    if msg == 99999 or msg == "CloseBtn" then -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        if NineActiveUtil.active_id then
            NineActiveUtil.active_id = nil
        end
        if SceneManager then
            SceneManager:getCurSceneView():setBGMusic()
        end
        self:closeView()
    elseif msg == "player_img" then
    elseif msg == "updateData" then
        self.m_model:updateData(data)
    elseif msg == "updateOneMail" then
        self.m_model:updateOnMail(data)
    elseif msg == "updateOneNotice" then
        self.m_model:updateOnNotice(data)
    elseif msg == "updateOneCode" then
        self.m_model:updateOneCode(data)
    elseif msg == "updateUI" then
        self.m_view:refreshUI()
    elseif msg == "xian_touch_btn" then
        self.m_model.m_dataTime = 10
        local talkData = self.m_model:getTouchRandomTalkData()
        self.m_view:talkView(talkData)
    elseif msg == "play_anim" then
        -- self:setOnceTimer(
        --         data.tim,
        --         function()
        --             self.m_view:setAnim("idle")
        --         end
        -- )
        -- self.m_view:setAnim(data.anim)
    elseif msg == "reward_1" or msg == "reward_2" or msg == "reward_3" then
        local data = nil
        if msg == "reward_1" then
            data = self.m_model.m_welf_table[1]
        elseif msg == "reward_2" then
            data = self.m_model.m_welf_table[2]
        elseif msg == "reward_3" then
            data = self.m_model.m_welf_table[3]
        end
        if data then
            -- self:playerTalk(data)
            -- self:getWelfares(data.id) --领奖
            self:openView("Xian.ServiceGetRewardPop", {data=data, callback = function ()
                self:getWelfares(data.id) --领奖
            end})
        end
    elseif msg == "mail_btn" then
        self:openView("Xian.ServiceMailPop", self.m_model.m_data.codes)
    elseif msg == "notice_btn" then
        self:openView("Xian.ServiceNoticePop", self.m_model.m_data.notices)
    elseif msg == "add_qq_btn" then
        SDKUtil:openUrl("https://jq.qq.com/?_wv=1027&k=lAVc7lsd")
    elseif msg == "talk_mask_btn" then
        self.talk_index = self.talk_index + 1
        self:playTalkForCallback()
    elseif msg == "haogan_btn" then
        self:openView("Xian.ServiceGoodFeelPop")
    elseif msg == "songli_btn" then
        if self.can_lv_up and self.m_view.gift_status_changing == false and self.can_lv_up == true then
            self.m_view:updateSendGift(true)
        end
    elseif msg == "send_mask" then
        if self.m_view.gift_status_changing == false then
            self.m_view:updateSendGift(false)
        end
    elseif msg == "send_reward" then
        self:sendOneGift(data)
    elseif msg == "send_all_gift" then
        self:sendAllGift()
    elseif msg == "bulim_book_btn" then
        self:openView("Xian.ServiceNpcGuide")
    elseif msg == "world_progress_btn" then --江湖进度
        local curStage = UserDataManager:getCurStage()
        local startStage = self.m_model:getStartStage()
        if curStage < startStage then
            local big = math.floor(startStage/100);
            local small = startStage - big * 100;
            local stage_str = big.."-"..small;
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0823",stage_str), delay_close = 2})
        else
            self:openView("Xian.ServiceWorldProgress")
        end
    elseif msg == "player_community_btn" then --玩家社区
        --local url = "https://gcommunity.nvsgames.cn"
        local url = self.m_model:getRechargeRebateURL("https://gcommunity.nvsgames.cn")
        SDKUtil:openUrl(url,function()
            self:getActiveRedPoint()
        end)--玩家社区链接
        --SDKUtil:openUrl("https://act.bytedance.net/gms/5ddcaf9110?from_source=h5&orientation=landscape")--每日红包链接
    elseif msg == "remove_code" then
        self.m_model:removeCode(data)
    elseif msg == "recharge_rebate_btn" then --充值返利
        StatisticsUtil:doPointActive(219,0)
        local url = self.m_model:getRechargeRebateURL()
        SDKUtil:openUrl(url)
    elseif msg == "nineActive_rebate_btn" then
        if self.m_model.nine_active_data ~= nil then
            self:openView("Activities.NineActiveMain.NineActiveMain",{nine_active_data = self.m_model.nine_active_data})
        end
    elseif msg == "refreshNineActiveRedPoint" then --刷新九尾页面红点
        self.m_view:setNineActive()
    elseif msg == "fenghua_btn" then
        self:openView("FengHuaRecord")
    elseif msg == "fenghua_close" then
        self.m_view:setSpine(self.m_model.m_skin_id)
    elseif msg == "select_skin" then
        local skin_id = data.skin_id
        local skin_flag = data.flag
        self.m_view:setSpine(skin_id)
    elseif msg == "set_skin" then
        self.m_model.m_skin_id = data
        self.m_model:resetGreetList()
    end
end

function M:updateTimer()
    if self.m_model.m_curFristInTime > 0 then
        self.m_model.m_curFristInTime = self.m_model.m_curFristInTime - 1
        if self.m_model.m_curFristInTime <= 0 then
            self.m_model.m_curFristInTime = 0
        end
    end
    if self.m_model.m_curFristInTime <= 0 then
        self.m_model.m_curRandomTime = self.m_model.m_curRandomTime - 1
        if self.m_model.m_curRandomTime <= 0 then
            self:setTalk()
            self.m_model.m_curRandomTime = self.m_model.m_randomTime
        end
        if self.m_model.m_curShowTime > 0 then
            self.m_model.m_curShowTime = self.m_model.m_curShowTime - 1
            if self.m_model.m_curShowTime <= 0 then
                self.m_view:hideTalk()
                self.m_model.m_curShowTime = 0
            end
        end
    end
end

--首次打招呼
function M:enterGreeting()
    local greet_cfg = self.m_model:getEnterGreeting()
    self.m_view:talkView(greet_cfg)
    --if table.nums(self.m_model.npc_guide_tab) > 0 then
    --    self:setOnceTimer(5, handler(self, self.opneTiShi))
    --end
end

function M:opneTiShi()
    local greet_cfg = self.m_model.npc_guide_tab[1]
    self.m_model:resetRandomTime()
    self.m_view:talkView(greet_cfg)
end

function M:setTalk()
    local talk_msg = self.m_model:getGreeting()
    if talk_msg ~= nil then
        self.m_view:talkView(talk_msg)
    end
end

function M:playTalkForCallback()
    if table.nums(self.m_model.priority_hight_list) > 0 and table.nums(self.m_model.priority_hight_list) >= self.talk_index then
        self.m_model:resetRandomTime()
        local talkCfg = self.m_model.priority_hight_list[self.talk_index]
        self.m_view:talkView(talkCfg, true)
        self:setOnceTimer(
            3.5,
            function()
                self.talk_index = self.talk_index + 1
                self:playTalkForCallback()
            end
        )
        return
    elseif table.nums(self.m_model.priority_hight_list) > 0 then
        self.talk_index = 1
        self.isTalking = false
        self.m_model.priority_hight_list = {}
    end
end

function M:playerTalk(cell_data)
    if self.isTalking == true then
        return false
    end
    if cell_data then
        if cell_data.data.guide and cell_data.data.guide ~= 0 then
            local dia_cfg = self.m_model:getDiaById(cell_data.data.guide)
            self.m_view:talkView(dia_cfg)
        end
        --self:playTalkForCallback()
    end
end

function M:getWelfares(data, call_back)
    if data then
        local function callback(response)
            self.m_model:updateWelfares( data, response.welfare)
            self.m_view:updateWelfares( response.welfare )
            self.m_view:refreshUI()
            --self.m_view:hideTalk()
            self.talk_id = nil
            if next(response.reward) then
                RewardUtil:rewardTipsByData(response.reward)
                if call_back then
                    call_back()
                end
            end
        end
        local params = {}
        params.welfare_id = data
        self.m_model:getNetData("receive_welfare", params, callback)
    end
end

function M:sendOneGift(data)
    -- if self.m_model.m_vip >= self.m_model.max_vip then
    --     GameUtil:lookInfoTips(self, {msg = "xian_str_0013", delay_close = 2})
    --     return
    -- end
    if data then
        local function callback(response)
            self.m_model:updateVipData()
            self.m_view:refreshUI()
            local item_send, cfg = UserDataManager.item_data:getItemDataById(data)
            self:sendGiftTalk(cfg.effect)
            if response.up_lv > 0 then
                self:openView("Xian.GoodFeelRewardPop")
            end
        end
        local params = {}
        params.items = {}
        params.items[data] = 1
        self.m_model:getNetData("send_gifts", params, callback)
    end
end

function M:sendAllGift(data)
    local params = {}
    params.items = {}
    -- if self.m_model.m_vip >= self.m_model.max_vip then
    --     GameUtil:lookInfoTips(self, {msg = "xian_str_0013", delay_close = 2})
    --     return
    -- end
    local effect_num, items = self.m_model:getQuickItemList()
    if table.nums(items) == 0 then
        GameUtil:lookInfoTips(self, {msg = "xian_str_0004", delay_close = 2})
        return
    end
    params.items = items
    local function callback(response)
        if response then
            self.m_model:updateVipData()
            self.m_view:refreshUI()
            self.talk_id = nil
            self:updateMsg("send_mask")
            self:sendGiftTalk(effect_num)
            if response.reward and next(response.reward) then
                RewardUtil:rewardTipsByData(response.reward)
            end
            if response.up_lv > 0 then
                self:openView("Xian.GoodFeelRewardPop")
            end
        end
    end
    self.m_model:getNetData("send_gifts", params, callback, nil, true)
end

--发送奖励
function M:sendGiftTalk(num)
    self.m_model:resetRandomTime()
    local dialog_cfg = self.m_model:getXianGiftDialogData(num)
    if dialog_cfg ~= nil then
        self.m_view:talkView(dialog_cfg);
    end
end

--玩家社区红点--拉取式获取方式
function M:getActiveRedPoint()
    local params = {
        ["x-token"] = UserDataManager.client_data:getSdkToken(),
        ["x-server-id"] = UserDataManager.server_data:getServerId(),
        ["x-role-id"] = UserDataManager.user_data:getUid(),
        ["x-appid"] = 6245
    }
    local url = "https://gcommunity.nvsgames.cn/cp/reddot/get" --正式服链接
    --local url = "https://gcommunity-sandbox.nvsgames.cn/cp/reddot/get"  --沙箱环境链接
    --self.m_model:getNetData(url)
    NetWork:httpRequest(
            function(params)
                if params ~= nil then
                    if params.show ~= nil then
                        self.m_view:setActiveRedPoint(params.show)
                    end 
                end
            end,
            url,
            GlobalConfig.POST,
            params,
            "",
            0,
            true,nil,nil,nil,nil,params
    ) --正式服链接地址
end

function M:onDestroy()
    if self.cur_cv then
        audio:StopPlayingID(self.cur_cv)
        self.cur_cv = nil
    end
    SceneManager:getCurSceneModel():setCameraShow(true)
    if self.bank then
        ResourceUtil:UnLoadRoleSound(self.bank)
        self.bank = nil
    end
end

return M