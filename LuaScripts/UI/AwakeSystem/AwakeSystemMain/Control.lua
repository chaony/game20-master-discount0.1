---
---@class AwakeSystemMainControl:OOControlBase
---@field m_model AwakeSystemMainModel
local M = class("AwakeSystemMainControl",LikeOO.OOControlBase)

function M:onEnter()
    M.super.onCreate(self)
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    EventDispatcher:registerEvent("send_cheer_msg", {self, self.shareCheerMsg})
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("refresh_entrances",nil,"PengLaiBazzar.PengLaiBazzarIsland")
        self:closeView()
    elseif msg == "help_btn" then
        local params = {}
        params.title = "awake_system_text_001"
        params.content = "tid#awakdes_21"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "asleep_btn" then
        if self.m_model.m_current_mode == 0 then
            return
        end
        local flag = self.m_model:countCurHeroFly()
        if flag then
            self:openView("AwakeSystem.AwakeSystemAsleepPop",{hero_id = self.m_model.m_cur_hero_id,stage_data = self.m_model.m_stage_data})
        else
            GameUtil:lookInfoTips(self,{msg = Language:getTextByKey("awake_system_text_0056"), delay_close = 2})
        end
    elseif msg == "smelt_btn" then
        if self.m_model.m_current_mode == 0 then
            return
        end
        local flag = self.m_model:countCurHeroGod()
        if flag then
            self:openView("AwakeSystem.AwakeSystemSmeltPop")
        else
            GameUtil:lookInfoTips(self,{msg = Language:getTextByKey("awake_system_text_0058"), delay_close = 2})
        end
    elseif msg == "select_hero" then
        self.m_model.m_currentHeroIndex = data.data
        self:refreshUI(0)
    elseif msg == "unlock_btn" then  -- 解锁前 先去放到台子上
        local hero_id = self.m_model:getHeroid(self.m_model.m_currentHeroIndex)
        if tostring(self.m_model.m_cur_hero_id) ~= tostring(hero_id) then
            if self.m_model:getFlyItemFlag() then
                GameUtil:lookInfoTips(self,{msg = Language:getTextByKey("awake_system_text_0051"), delay_close = 2})
                return
            end
            local function Callback(response)
                if response then
                    if response.reward and next(response.reward) then
                        RewardUtil:rewardTipsByData(response.reward)
                    end
                    self.m_view:ShowFX(2.5,"UI_AwakeSystem_Yun001")
                    self.m_model:initData(response)
                    self:refreshUI(1)
                    if not  self.m_model:countCurHeroFly() then
                        self:fly()
                    end
                end
            end
            local params = {}
            params.hero_oid = self.m_model.m_currentHeroIndex
            self.m_model:getNetData("awaken_change_hero", params, Callback)
        else
            self.m_model:dealState()
            self.m_view:refreshUI()
        end
    elseif msg == "submit_rank" then
        self.m_awaken_fly_quest = ConfigManager:getCfgByName("awaken_fly_quest")
        local cur_quest = self.m_awaken_fly_quest[data.data.quest_id]
        local can_flag = false
        for k,v in ipairs(cur_quest.cost) do
            local consItem = RewardUtil:getProcessRewardData(v)
            if consItem.user_num < consItem.data_num then
                can_flag = true
            end
        end
        if can_flag then
            GameUtil:lookInfoTips(self,{msg = Language:getTextByKey("awake_system_text_0051"), delay_close = 2})
            return
        end
        local function Callback(response)
            if response and next(response) then
                self.m_model:initData(response)
                if response.god_open and response.god_open == 1 then
                    self.m_view:ShowFX(2.5,"UI_AwakeSystem_BF002")
                    self:openResultPop(1)
                    self:setOnceTimer(2.5, function()
                        self:closeView("AwakeSystem.AwakeSystemResultPop")
                        self.m_view:ShowFX(2.5,"UI_AwakeSystem_Yun001")
                        self.m_view:refreshUI(false,true)
                    end)
                else
                    self.m_view:refreshUI(false,true)
                end
            end
        end
        local id = data.data.quest_id
        local params = {quest_id = id}
        local m_awaken_fly_quest = ConfigManager:getCfgByName("awaken_fly_quest")
        local cfg = m_awaken_fly_quest[id]
        self.m_view:flyMoveItem(cfg.cost,data.click_obj)
        self.m_model:getNetData("awaken_submit_quest", params, Callback)
    elseif msg == "change_btn" then  --更换
        if self.m_model.m_fly_quests_finish_all == 1 then
            GameUtil:lookInfoTips(self,{msg = Language:getTextByKey("awake_system_text_0044"), delay_close = 2})
            return
        end
        local params =
        {
            on_ok_call = function(params)
                self.m_view:ShowFX(2.5,"UI_AwakeSystem_Yun001")
                self.m_model:resetState()
                self:refreshUI(1)
            end,
            text = Language:getTextByKey( self.m_model.m_current_mode == 1 and "awake_system_text_0023" or "awake_system_text_0036"),
        }
        self:openView("Pops.CommonPop", params)
    elseif msg == "invite_btn" then  -- 邀请好友助威
        QuickOpenFuncUtil:openFunc(11, {type = 1,offline_invite = 0, cheer_callback = handler(self,self.friendInviteCallback),show_btn = {"invite_friend_cheer_btn"}})
    elseif msg == "submit_item" then  -- 登仙楼修炼
        self:cultivationHero(data)
    elseif msg == "upgrade_btn" then  --
        self:killSelf()
    elseif msg == "success_rate_btn" then  --显示成功率
        self:showRateTips()
    elseif msg == "handbook_btn" then  --显示成功率
        self:openView("AwakeSystem.AwakeSystemRecord")
    elseif msg == "skill_detail" then  --技能详情
        self:skillDetail(data)
    elseif msg == "blue_block_img" then  --物品详情
        local data, cfg = self.m_model:getSelectHeroData(self.m_model.m_currentHeroIndex)
        local cur_cfg = self.m_model.m_awaken_cfg[data.id]
        local consItem = RewardUtil:getProcessRewardData(cur_cfg.cost[1])
        static_rootControl:openView("Pops.CommonItemTipsPop", {data = consItem, target_obj = self.m_view.cost_img})
    elseif msg == "common_refresh" then  --刷新数据
        self:refreshIndex()
    elseif msg == "smelt_refresh" then  --刷新数据
        self:refreshIndex()
        self:refreshItemList()
    elseif msg == "update_data" then  --跨天刷新
        self:refreshIndexByrefresh()
    elseif msg == "skill1_img" then  --显示技能tips
        local select_id = self.m_model.m_select_id
        local hero_id =self.m_model:getHeroid(self.m_model.m_currentHeroIndex)
        local cur_cfg = self.m_model.m_awaken_cfg[hero_id]
        local cfg_awaken_skill = "awaken_skill"
        local cfg_replace_skill = "replace_skill"
        local select_pos = 1
        local cur_level = 1
        for i = 1,2 do
            local cur_awaken_skill_cfg = cur_cfg[cfg_awaken_skill .. i]
            local cur_replace_skill_pos = cur_cfg[cfg_replace_skill .. i]
            for k,v in pairs(cur_awaken_skill_cfg) do
                if select_id == v[1] then
                    select_pos = i
                    cur_level = k
                    break
                end
            end
        end
        local cur_awaken_skill_cfg = cur_cfg[cfg_awaken_skill .. select_pos]
        local cur_replace_skill_pos = cur_cfg[cfg_replace_skill .. select_pos]
        local show_skill = {}
        for k,v in ipairs(cur_awaken_skill_cfg) do
            if k <= cur_level then
                table.insert(show_skill,{v[1],1})
            else
                table.insert(show_skill,{v[1],v[3]})
            end
        end
        local click_obj = data
        local ordinary_skill = 3
        --local hero_lv = 100

        local hero_lv=self.m_model:getHero_lv()
        local lv4Unlock=self.m_model:checkSkillLv4Unlock(4)
        self:openView("Pops.SkillPop", {hero_id = hero_id,ordinary_skill = ordinary_skill,skill = show_skill, index = 4, cur_lv = hero_lv, click_transform = click_obj.transform,pivot = Vector2(0,1),lv4Unlock=lv4Unlock})
    end
end

function M:refreshItemList() 
    self.m_view:refreshTabNode()
    self.m_view:setLeftNode()
end

function M:refreshIndex()
    local function Callback(response)
        if response then
            self.m_model:initData(response)
            --self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("awaken_index",nil, Callback)
end

function M:refreshIndexByrefresh()
    local function Callback(response)
        if response then
            self.m_model:initData(response,handler(self,self.refreshUIByday))
        end
    end
    self.m_model:getNetData("awaken_index",nil, Callback)
end

function M:skillDetail(param)
    local skills = param.show_skill
    local click_obj = param.click_obj
    local hero_id =self.m_model:getHeroid(self.m_model.m_currentHeroIndex)
    local ordinary_skill = 3
    local hero_lv = self.m_model:getHero_lv()

    local skill_idx=param.skill_idx
    local lv4Unlock=self.m_model:checkSkillLv4Unlock(skill_idx)
    self:openView("Pops.SkillPop", {hero_id = hero_id,ordinary_skill = ordinary_skill,skill = skills, index = 4, cur_lv = hero_lv, click_transform = click_obj.transform,pivot = Vector2(0,1)})
end

function M:fly()
    local function Callback(response)
        if response then
            self.m_model:initData(response)
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("awaken_fly",nil, Callback)
end

function M:cultivationHero(data)
    local function Callback(response)
        if response and next(response) then
            local cost = {{103,data.id,1}}
            self.m_view:flyMoveItem(cost,data.obj)
            self.m_model:initData(response)
            self.m_view:refreshUI(true,true)
            --self.m_view:refreshUI(true)
        end
    end
    local params = {item_id = data.id or 0}
    self.m_model:getNetData("awaken_cultivation", params, Callback)
end

function M:shareToWorld()
    local send_data = self:getChatData()
    send_data.channel_type = tostring(2)
    ChatUtil:sendMsg(send_data,2)
    GameUtil:lookInfoTips(self,{msg = Language:getTextByKey("awake_system_text_0066"), delay_close = 2})
end

function M:friendInviteCallback(data)
    local send_data = self:getChatData()
    send_data.channel_type = "4"
    send_data.target_name = data.name
    send_data.channel_id = tostring(data.f_uid)
    ChatUtil:sendMsg(send_data,2)
    GameUtil:lookInfoTips(self,{msg = Language:getTextByKey("awake_system_text_0059"), delay_close = 2})
end

function M:getChatData()
    local ext_params = {}
    ext_params.invite_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
    ext_params.send_time = UserDataManager:getServerTime()
    ext_params.hero_id= self.m_model.m_cur_hero_id
    local send_data = {
        uid = UserDataManager.user_data:getUserStatusDataByKey("uid"),
        name = UserDataManager.user_data:getUserStatusDataByKey("name"),
        avatar = tostring(UserDataManager.user_data:getUserStatusDataByKey("avatar")),
        frame = tostring(UserDataManager.user_data:getUserStatusDataByKey("frame")),
        title = UserDataManager.user_data:getUserStatusDataByKey("title"),
        msg = Language:getTextByKey("awake_system_text_0067"),
        event = 5,
        event_ext = Json.encode(ext_params),
    }
    return send_data
end

function M:killSelf()
    --获取材料卡
    local item_data,can_flag = self.m_model:dealWithItemForServer()
    local function Callback(response)
        if response and next(response) then
            self.m_model:initData(response)
            self.m_view:ShowFX(2.5,"UI_AwakeSystem_JQ001")
            if response.success == 1 then
                self:setOnceTimer(2.5, function()
                    self.m_view:ShowFX(2.5,"UI_AwakeSystem_BF001")
                    self.m_view:refreshUI()
                end)
                self:setOnceTimer(2.5, function()
                    self:openResultPop(response.success)
                end)
            else
                self:setOnceTimer(2.0, function()
                    self:openResultPop(response.success)
                    self.m_view:refreshUI()
                end)
            end
        end
    end
    local params = {item_data = item_data}
    if can_flag then
        self.m_model:getNetData("awaken_kill_self", params, Callback)
    else
        GameUtil:lookInfoTips(self,{msg = Language:getTextByKey("awake_system_text_0051"), delay_close = 2})
    end
end

function M:refreshUI(times)
    self:setOnceTimer(times, function()
        self.m_view:refreshUI()
    end)
end

function M:refreshUIByday()
    self.m_view:refreshUI()
end

function M:showRateTips()
    local new_line = "\n"
    local v1,v2,v3 = self.m_model:getGodRate()
    local str1 = Language:getTextByKey("awake_system_text_0052",tostring(v1) .."%")
    local str2 = Language:getTextByKey("awake_system_text_0053",tostring(v2) .."%")
    local str3 = Language:getTextByKey("awake_system_text_0054",tostring(v3) .."%")
    local obj = self.m_view:findGameObject("desc_pos_cmp")
    local final_str = str1 .. new_line .. str2 .. new_line .. str3
    GameUtil:lookInfoTips(self, {click_transform = obj.transform, msg = final_str})
end


function M:dataUpdateEvent(event, data)
    local curEvent = data.event or ""     
    if curEvent == "fly_hero_data" then
        self.m_model:resetHeroFlyLevel(data)
        if not data.first then
            self:setOnceTimer(0.7, function()
                self:openResultPop(0)
            end)
            self.m_view:ShowFX(2.5,"UI_AwakeSystem_BF002")             
        end
    end
end

function M:openResultPop(result)
    local params = {result = result,oid = self.m_model.m_currentHeroIndex,mode = self.m_model.m_current_mode}
    --self.m_view:refreshUI()
    self:setOnceTimer(1, function()
        self:openView("AwakeSystem.AwakeSystemResultPop", params)
    end)
end

function M:shareCheerMsg(event,data)
    local event = data.event
    local friend_info = data.data or {}
    if event == "world" then
        self:shareToWorld()
    elseif event == "one_click" then
        for k,v in ipairs(friend_info) do
            local send_data = self:getChatData()
            send_data.channel_type = "4"
            send_data.target_name = v.name
            send_data.channel_id = tostring(v.uid)
            ChatUtil:sendMsg(send_data,2)             
        end
        GameUtil:lookInfoTips(self,{msg = Language:getTextByKey("awake_system_text_0059"), delay_close = 2})
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    EventDispatcher:unRegisterEvent("send_cheer_msg", {self, self.shareCheerMsg})
    M.super.destroy(self)
end

return M
