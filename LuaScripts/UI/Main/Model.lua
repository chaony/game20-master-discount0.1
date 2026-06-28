---@class MainModel:OODataBase
local M = class("MainModel", LikeOO.OODataBase)
local __CHAT_CHANNEL = {LOCAL = 1,WORLD = 2,GUILD = 3,PRIVATE = 4}
function M:onCreate()
	M.super.onCreate(self)
    -- self:getData()
    --self.m_transfer = "animation"
    --self.m_anim_name = "Main_Enter"
    self:requestUserMain()
    self.question_url = nil --问卷
end

function M:onEnter()
    --侠客
    --self.m_hero_tab_index = 1
    --self.hero_list = self:getAllHeroIds()
    self.Filtrate_list = self:getHeroByRace(0,0)
    --UserDataManager.hero_data:heroIdsSort(hero_list, "team")
    --self.hero_list = hero_list
    self.on_hook_box_list = {} --挂机宝箱列表
    self.sort_type = 1
    self.m_open_tab_index = self.m_params.open_tab_index or 0
	self.m_open_bag_tab_index = 4
    self.m_grudge_tab_index = 1
	self.m_sel_tab_index =  nil
    self.m_bag_data_cache = {}
    local now_tim = UserDataManager:getServerTime()
    self.on_hook_time = 0 --挂机时间
    self.m_xian_interval = 5 --阿闲气泡切换间隔
    self.m_hangup_tim = now_tim - UserDataManager.idle_info.idle_start_time 
    self.m_hangup_tim2 = self.m_hangup_tim
    self.m_race = 0
    self.m_pro = 0
    self.m_seven_pop = false --七日首次
    self.m_common_zhaoyun = false --赵云壮胆
    self.m_common_anniversary = false --周年庆预热
    self.m_first_charge_pop = false --首充首次
    if SDKUtil.is_gmsdk then
        self.m_gameNotice_pop = true --公告弹窗
        self.m_nine_active = true --九尾拍脸
    else
        self.m_gameNotice_pop = false
        self.m_nine_active = false --九尾拍脸
    end
    self.m_player_back = false --老玩家回归
    self.m_player_back_reward = false --老玩家回归奖励
    self.m_player_back_status_request_count = 0 --8小时倒计时为0时请求刷新挂机页数据的次数
    self.m_fine_clothes = false --华服共赏
    self.m_game_notice = UserDataManager.local_data:getUserDataByKey("gameNotice", nil)
    self.m_old_stage_id = UserDataManager:getCurStage()
    self:checkPlayerBack(true)
    self:checkFineClothes()
    self:checkFirstLogin()
    self:checkCommonQuest()
    self:checkZhaoYun()
    self:checkAnniversary()
    self:checkCompareSwordInvitation() --剑试天下
    self:checkFirstCharge()
    self.m_push_gift_id = nil --限时奖励首次
    self.m_choice_gift_id = nil --限时三合一奖励首次
    self:checkFirstPushGift()
    self:checkFirstChoiceGift()
    self:checkFirstSeasonPreview() --赛季预告
    self.m_side_status = 1 -- 0关闭 1 开启
    self.m_chat_show = true -- false 关闭 true 开启
    self.m_cur_channel_id = 2
    self.m_cur_msg_id = "0"
    for k,v in pairs({9,11,13,44,29,30,21,22,49}) do
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(v)
        UserDataManager.local_data:setUserDataByKey("MainCity"..v, open_flag);
    end
    local open_compass_time = UserDataManager.local_data:getUserDataByKey("open_compass_time", nil)
    if open_compass_time then
        local server_ts = UserDataManager:getServerTime()
        local day = GameUtil:NumberOfDaysInterval(open_compass_time, server_ts)
        if day >= 1 then
            UserDataManager.local_data:setUserDataByKey("open_compass_time", nil)
        end
    end
    self:getMessiData()
    self.application_Id = SDKUtil.sdk_params.applicationId
    --九尾初始化角色信息
    if SDKUtil.is_gmsdk then
        local user_data = UserDataManager.user_data.user_status or {}
        local getServerData = UserDataManager.server_data:getServerData() or { }
        local roleid = user_data.uid or ""
        local rolename = user_data.name or ""
        local serverId = getServerData.server or ""
        SDKUtil:updateGameConfig(roleid,rolename,serverId) --初始化角色信息
        local params = {
            roleid = user_data.uid or "",
            rolename = user_data.name or "",
            serverId = getServerData.server or "",
            open_id = 6245
        }
        local json_string = Json.encode(params)
        SDKUtil:SetGameData(json_string) --游戏设置信息
        SDKUtil:SetGameFont("方正北魏楷书_GBK",CS.UIFontController.wordFont) --初始化字体设置
        SDKUtil:SetGameFont("方正行楷_GBK",CS.UIFontController.btnFont) --初始化字体设置
        SDKUtil:openFaceVerify(function(params)
            if params ~= nil and params.data ~= nil then
                self.home_show_data = params.data
            end
        end,"home_show")
    end
    UserDataManager.local_data:setLocalDataByKey("player_back_server_chose_flag", false) -- 老玩家回归选服标识
    
    --轮播
    --self.m_current_carousel_num = 1
    --self.m_all_carousel_num = #self:getCarsourelActiveData() or 0

    --立绘和背景
    self.m_set_hero_id = UserDataManager.local_data:getUserDataByKey("main_set_hero", 182)
    self.m_set_back_img = UserDataManager.local_data:getUserDataByKey("main_set_back", "main_bg2")
end

--获取聚合打包上报渠道数据
function M:getMessiData()
    if SDKUtil.is_gmsdk  or SDKUtil.is_oneSDK then
        local getServerData = UserDataManager.server_data:getServerData() or { }
        local user_data = UserDataManager.user_data.user_status or {}
        local params = {
            zoneid = getServerData.ZoneID or "",
            zonename = getServerData.ZoneName or "",
            roleid = user_data.uid or "",
            rolename = user_data.name or "",
            rolelevel = user_data.level or "",
            power = user_data.full_combat or "",
            vip = user_data.vip or "",
            partyid = user_data.guild_id or "",
            partyname = user_data.guild_name or "",
            chapter = UserDataManager:getCurStage() or "",
            serverId = getServerData.server or "",
            serverName = getServerData.server_name or "",
        }
        local json_string = Json.encode(params)
        SDKUtil:EnterGameUpload(json_string)
    end
end

function M:setChatChannelId(channel_id)
    self.m_cur_channel_id = channel_id
end

function M:getLeftTimeForPlayerBack()
    local min_unit = 60
    local hour_unit = min_unit * 60
    local day_unit = hour_unit * 24
    local time_left = hour_unit * 8 - (UserDataManager:getServerTime() - UserDataManager.comeback_ts or 0)
    local day_left = math.floor(time_left / day_unit)
    local hour_left = math.floor((time_left - day_unit * day_left) / (hour_unit))
    local min_left = math.floor((time_left - day_unit * day_left - hour_unit * hour_left) / min_unit)
    local sec_left = math.floor(time_left - day_unit * day_left - hour_unit * hour_left - min_unit * min_left)
    return day_left, hour_left, min_left, sec_left
end

function M:checkPlayerBack(need_update_member)
    local player_back_flag = false
    local player_back_reward_flag = false
    local current_day = 0
    
    --是否是老玩家回归
    if UserDataManager.comeback_status == 1 then
        player_back_flag = true
    end
    
    --是否是老玩家回归，选择旧服，截止到今天的回归奖励没领完
    if UserDataManager.comeback_status == 2 or UserDataManager.comeback_status == 1 then
        local reward_got = UserDataManager.comeback_rcvd or {} 
        current_day = math.floor((UserDataManager:getServerTime() - UserDataManager.comeback_ts or 0) / (60 * 60 * 24)) + 1
        local reward_got_flag = false
        if current_day and current_day >= 1 and current_day <= 7 then
            for day = 1, current_day do
                reward_got_flag = false
                for _, value in ipairs(reward_got) do
                    if value == day then
                        reward_got_flag = true
                        break
                    end
                end
                if reward_got_flag == false then
                    player_back_reward_flag = true
                    break
                end
            end
        end
    end
    
    -- 回归玩家 是否是在新服，截止到今天的回归奖励没领完
    local openConditionData = ConfigManager:getCfgByName("open_condition")
    local itemActiveData = openConditionData[241] or {}
    local passValue = itemActiveData.unlock_condition_param or 3
    local curStage = UserDataManager:getCurStage()
    if UserDataManager.comeback_status == 4 and curStage >= passValue then
        local reward_got = UserDataManager.comeback_rcvd or {}
        current_day = math.floor((UserDataManager:getServerTime() - UserDataManager.new_comeback_ts or 0) / (60 * 60 * 24)) + 1
        local reward_got_flag = false
        if current_day and current_day >= 1 and current_day <= 7 then
            for day = 1, current_day do
                reward_got_flag = false
                for _, value in ipairs(reward_got) do
                    if value == day then
                        reward_got_flag = true
                        break
                    end
                end
                if reward_got_flag == false then
                    player_back_reward_flag = true
                    break
                end
            end
        end
    end
    
    if need_update_member == true then
        self.m_player_back = player_back_flag
        self.m_player_back_reward = player_back_reward_flag
    end

    if (not need_update_member) and curStage == passValue then
        if not self.m_signPop then
            self.m_player_back_reward = true
            self.m_signPop = 1
        end
    end
    
    return UserDataManager.comeback_status, current_day, player_back_reward_flag
end

function M:checkFirstLogin()
    -- check tiktok 170
    RedPointUtil:hasRedPointById(170)
    --local day = GameUtil:dayCompute()
    local bl, tips = BtnOpenUtil:isBtnOpen(72)
    local can_get = RedPointUtil:hasRedPointById(48) == true or RedPointUtil:hasRedPointById(4801) == true
    if UserDataManager:getActivesByOpenId(72) == false then
        self.m_seven_pop = false
        return
    end
    if RedPointUtil:hasRedPointById(4802) == false then --本次登录是否弹出过
        self.m_seven_pop = false
        return 
    end
    if can_get == true then
        self.m_seven_pop = true
    else
        self.m_seven_pop = false    
    end
end

function M:sortNewChatMsg(private_msg, other_msg)
    local sort_tab = {} -- 
    if other_msg and next(other_msg) then
        for i = #other_msg - 4, #other_msg do
            if other_msg[i] then
                sort_tab[#sort_tab + 1] = {msg_time = other_msg[i].time, msg_index = i, is_private = false}
            end
        end
    end
    if private_msg and next(private_msg) then
        for i = #private_msg - 4, #private_msg do
            if private_msg[i] then
                sort_tab[#sort_tab + 1] = {msg_time = private_msg[i].time, msg_index = i, is_private = true}
            end
        end
    end
    table.sort(sort_tab, function(a, b)
        return a.msg_time < b.msg_time
    end)
    return sort_tab
end

function M:getChatMsgByChannel(channel_id)
    local other_msg, private_msg = {}, {}
    if channel_id == __CHAT_CHANNEL.PRIVATE then
        private_msg = ChatUtil:getLatestPrivateMsg(channel_id)
        
    else
        other_msg = ChatUtil:getChannelMsg(channel_id)
        private_msg =  ChatUtil:getLatestPrivateMsg()
    end
    
    local last_msg = {}
    local sort_tab = self:sortNewChatMsg(private_msg, other_msg)
    for i = #sort_tab - 4, #sort_tab do
        if sort_tab[i] and next(sort_tab) then
            local msg = sort_tab[i].is_private and private_msg[sort_tab[i].msg_index] or other_msg[sort_tab[i].msg_index]
            last_msg[#last_msg + 1] = msg
        end
    end
    local need_refresh = false
    local new_msg_id = last_msg[#last_msg] and last_msg[#last_msg].msg_id or "-1"
    if self.m_cur_msg_id ~= new_msg_id and new_msg_id ~= "-1" then
        self.m_cur_msg_id = last_msg[#last_msg].msg_id
        need_refresh = true
    end
    return last_msg, need_refresh
end

function M:checkTopArenaFinal()
    local top_arena_final = UserDataManager.local_data:getUserDataByKey("top_arena_final", {})
    if top_arena_final and next(top_arena_final) ~= nil then
        local cur_ts = UserDataManager:getServerTime()
        if cur_ts >= top_arena_final.start_ts and cur_ts <= top_arena_final.end_ts then
            return true
        end
    end
    return false
end

function M:checkCommonQuest()
    if self.m_common_quest_pop == true then
        return
    end
    local active = UserDataManager:getActivesDataByOpenId(347)
    if active and active.version then
        local lianliankan_quest = ConfigManager:getCfgByName("lianliankan_quest") or {}
        local cur_task_cfg = lianliankan_quest[347] or {}
        local cur_vsn_cfg = cur_task_cfg[active.version] or {}
        local task_id = 0
        for i, v in pairs(cur_vsn_cfg) do
            task_id = i
        end
        if task_id > 0 then
            local common_quest_data = UserDataManager.m_common_quest["347"] or {}
            local cur_vsn = common_quest_data[tostring(active.version)] or {}
            for i, v in pairs(cur_vsn) do
                if tostring(task_id) == i then
                    self.m_common_quest_pop = v.status == 1
                end
            end
        end
    end
end

function M:checkZhaoYun()
    if self.m_common_zhaoyun == true then
        return 
    end
    --小浣熊联动 赵云壮胆
    local active = UserDataManager:getActivesDataByOpenId(381)
    if active and active.version then
        self.m_common_zhaoyun = true
    end
end

function M:checkAnniversary()
    if self.m_common_anniversary == true then
        return
    end
    --周年庆预热
    local active = UserDataManager:getActivesDataByOpenId(418)
    if active and active.version then
        self.m_common_anniversary = true
    end
end

function M:checkFineClothes()
    if self.m_fine_clothes == true then
        return
    end
    --华服共赏，开启且今日未打开过
    if UserDataManager:getActivesRechargeByOpenId(371) == true and RedPointUtil:localRedPointJudge("FineClothes") == true then
        self.m_fine_clothes = true
    end
end

function M:checkFirstCharge()
    if self.m_first_charge_pop == true then
        return
    end
    if UserDataManager.charge_sum > 6 then
        return
    end
    local day = GameUtil:dayCompute()
    local stage_id = UserDataManager:getCurStage()
    local target_id = ConfigManager:getCommonValueById(436,101)
    if stage_id >= target_id then
        local first_charge_login = UserDataManager.local_data:getUserDataByKey("first_charge_day_first_"..day, 0)
        if first_charge_login == 0 then  
            self.m_first_charge_pop = true
        end
    end
end

function M:checkFirstPushGift()
    local push_gifts = self:getGiftPushs()
    self.m_push_gift_id = nil
    for k,v in pairs(push_gifts) do
        if self:checkPushGiftFirstOpen(k,v) ==  true then
            self.m_push_gift_id = k
            break
        end
    end
end

function M:checkFirstChoiceGift()
    local push_gifts = self:getGiftChoice()
    self.m_choice_gift_id = nil
    for k,v in pairs(push_gifts) do
        local three_charge_cfg = self:getThreeChargeCfgById(k) or {}
        if next(three_charge_cfg) then
            local ent_ts = v.ets
            local group_id = three_charge_cfg["group"] or -1
            if self:checkChoiceGiftFirstOpen(k,ent_ts) ==  true then
                self.m_choice_gift_id = k
                return group_id
            end
        end
    end
end

function M:checkCompareSwordInvitation()
    --剑试天下邀请函
    local invitation_index = UserDataManager.full_service_need_invitation
    if invitation_index == 1 or invitation_index == 2 then   --1天赛 2地赛
        --static_rootControl.updateMsg("open_compare_Sword_invitation",{idx = invitation_index})
        static_rootControl:openView("CompareSwordWithWorld.InvitationLetter",{invitation_index = invitation_index})
    end
end

--赛季预告自动弹出
function M:checkFirstSeasonPreview()
    self.m_is_first_season_preview = false
    local season = UserDataManager:getNextSeason() or UserDataManager:getCurSeason() + 1
    local first_season_preview = UserDataManager.local_data:getUserDataByKey("first_season_preview_" .. season, 0)
    if first_season_preview == 1 then
        return
    end
    local is_open = self:checkSeasonPreviewOpen()
    if is_open == true then
        self.m_is_first_season_preview = true
    end
end

-- 主页接口
function M:requestUserMain(callBack)
    if self.m_quest_net_flag then return end
    self.m_quest_net_flag = true
    local responseMethod = function(response)
        self.m_quest_net_flag = false
        if response then 
            if not self.m_data then
                self:initData(response)
                self:callBack(response)
            else
                self:initData(response)
                if callBack then
                    callBack()
                end
            end
        else
            local t_params =
            {
                on_ok_call = function(msg)
                    self:requestUserMain(callBack)
                end,   
                no_close_btn = true,
                text = Language:getTextByKey("new_str_0245"),
            }
            static_rootControl:openView("Pops.CommonPop",t_params, "main_request_pop");            
        end
    end
    self:getNetData("user_main", {}, responseMethod, nil, true)
end

function M:netData(data, tag)
	
end

function M:initData(data)
    self.m_data = data or self.m_data
    self:checkDoubleEarnId()
    UserDataManager.m_cur_calendar_id = self.m_data.cur_calendar_id or 0
    UserDataManager.m_season_data = self.m_data.season_data or {}
    UserDataManager.questions = self.m_data.questions or {}
    UserDataManager.troop_ids = self.m_data.troop_ids or {}
    UserDataManager.race_tower_status = self.m_data.race_tower_status or {}
    if self:isIgnore("actives") == false then
        UserDataManager.m_actives = self.m_data.actives
    end
    if self:isIgnore("recharge_actives") == false then
        UserDataManager.m_active_recharge = self.m_data.recharge_actives
    end
    UserDataManager.m_exchange_vsn = data.exchange_vsn or 0
    UserDataManager.m_limit_push = data.push_gifts or {}
    UserDataManager.m_choice_gifts = data.choice_gifts or {}
    UserDataManager.m_push_gifts_extra = data.push_gifts_extra or {}
    UserDataManager.charge_sum = data.charge_sum or 0
    UserDataManager.m_fund_status = data.fund_status or 0 -- 成长基金是否付费
    UserDataManager.m_fund_quests = data.fund_quests or {} -- 成长基金数据
    UserDataManager.m_sign_fund = data.sign_fund or {} -- 签到基金数据
    UserDataManager.m_war_order = data.war_order or {} --战令数据
    UserDataManager.m_common_quest = data.common_quest or {} --战令数据
    UserDataManager.m_active_cross_sid = data.active_cross_sid  --跨服组最大赛季
    self.main_quest_auto = data.main_quest_auto
    UserDataManager:setTempData("total_login_days", self.m_data.total_login_days or 0)
    UserDataManager.comeback_status = data.comeback_status or 0
    --UserDataManager:setPetPvpSeasonData(data.pet_pvp_season_data or {})
    UserDataManager.m_gacha_predestined_end = self:getPredestinedEndTime()
    --UserDataManager.m_gacha_predestined_end = data.high_gacha_end_ts
    UserDataManager.gacha_open_race_pools = data.gacha_open_race_pools
    UserDataManager.m_hero_isle_vsn = data.hero_isle_vsn
end

--为服务器性能，忽略部分数据的更新
function M:isIgnore(key)
    local keys = self.m_data.ignore_modules
    if keys == nil or #keys == 0 then
        return false
    end
    for k,v in pairs(keys) do
        if v == key then
            return true
        end
    end
    return false
end

function M:getAllHeroIds()
	local ids = UserDataManager.hero_data:getHerosId()
	UserDataManager.hero_data:heroIdsSort(ids,"lv")
	return ids
end

--根据种族和属性筛选英雄
function M:getHeroByRace(race,pro)
    self.hero_list = self:getAllHeroIds()
    self.m_race = race
    self.m_pro = pro
	if race == 0 and pro == 0 then
		self.Filtrate_list = {}
        self.Filtrate_list = clone(self.hero_list)
        self:heroSort(self.Filtrate_list)
		return
	end
	local heros = {}
	for k,v in pairs(self.hero_list) do
		local l_hero_data, l_hero_cfg = self:getHero(v)
		if race == 0 or race == l_hero_cfg.race then
			if pro == 0 or pro == l_hero_cfg.type then
				table.insert(heros, v)
			end
		end
	end
	self.Filtrate_list = {}
    self.Filtrate_list = clone(heros)
    self:heroSort(self.Filtrate_list)
end

function M:setSortType(type)
    self.sort_type = type or 2
end

function M:heroSort(list)
    if self.sort_type == 1 then -- 品阶
        UserDataManager.hero_data:heroIdsSort(self.Filtrate_list,"default")
    elseif self.sort_type == 2 then  --等级
        UserDataManager.hero_data:heroIdsSort(self.Filtrate_list,"lv")
    end
end

--获取英雄
function M:getFiltrateIdByIndex(index)
    return self.Filtrate_list[index]
end

--根据id获得英雄数据
function M:getHero(id)
	return UserDataManager.hero_data:getHeroDataById(id)
end

--获得所有英雄列表--图鉴使用
function M:getAllHeroList()
	local hero_list = ConfigManager:getCfgByName("hero_detail")
	return hero_list
end

--[[
    仓库数据
]]
function M:refreshBagListData(index, force_refresh)
    if force_refresh then
        self.m_bag_data_cache = {}
    end
    if self.m_bag_data_cache[index] == nil then
        local show_data = {}
        if index == 1 then-- 道具
            local function filterFunc(item_data, item_cfg)
                return item_cfg.sort == 1 and item_cfg.is_show == 1
            end
            GameUtil:insertProcessItemData(show_data, filterFunc)
        elseif index == 2 then-- 装备
            GameUtil:insertEquipsData(show_data)
        elseif index == 3 then-- 灵魂石
            local function filterFunc(item_data, item_cfg)
                return item_cfg.sort == 2 and item_cfg.is_show == 1
            end
            GameUtil:insertProcessItemData(show_data, filterFunc)
        elseif index == 4 then-- 全部
            local function filterFunc(item_data, item_cfg)
                return item_cfg.is_show == 1
            end
            GameUtil:insertProcessItemData(show_data, filterFunc)
            GameUtil:insertEquipsData(show_data)
            GameUtil:insertMysticesData(show_data)
        elseif index == 5 then-- 秘籍碎片
            local function filterFunc(item_data, item_cfg)
                return item_cfg.sort == 4 and item_cfg.is_show == 1
            end
            GameUtil:insertProcessItemData(show_data, filterFunc)
            GameUtil:insertMysticesData(show_data)
        end
        self.m_bag_data_cache[index] = show_data
    end
    self.m_show_bag_data = self.m_bag_data_cache[index] or {}
    return self.m_show_data
end

function M:getBagDataCount()
	return #self.m_show_bag_data
end

function M:getBagDataByIndex(index)
    return self.m_show_bag_data[index]
end

--挂机收益表
function M:getStagepIdle()
    local stage_id = UserDataManager:getCurStage()
    local stage_tab = ConfigManager:getCfgByName("stage")
    local stage_idle_tab = ConfigManager:getCfgByName("stage_idle")
    local idle_id =  stage_tab[stage_id].idle_id
    local idle_cfg = stage_idle_tab[idle_id]
    return idle_cfg
end
--掉落金币
function M:getIdleMoney()
    local cfg = self:getStagepIdle()
    return cfg.coin
end
--掉落英雄经验
function M:getIdleHeroExp()
    local cfg = self:getStagepIdle()
    return cfg.hero_exp
end
--掉落玩家经验
function M:getIdlePlayerExp()
    local cfg = self:getStagepIdle()
    return cfg.player_exp
end

--英雄图鉴数据
function M:getHeroTj()
    local book_tab = ConfigManager:getCfgByName("book")
    local b_list = {}
    local new_list = {}
    for k,v in pairs(book_tab) do
        if v.unlock == 1 then
            table.insert(b_list, k)
        end
    end
    self:heroIdsSort(b_list)
    return b_list
end

function M:heroIdsSort(bks)
    -- local function sortFunc(id_one, id_two)
    --     local sequence1 = id_one.data.sequence
    --     local sequence2 = id_two.data.sequence
    --     return sequence1 < sequence2
    -- end
    local function sortFunc(id_one, id_two)
        local cfg_1 = UserDataManager.hero_data:getHeroConfigByCid(id_one)
        local cfg_2 = UserDataManager.hero_data:getHeroConfigByCid(id_two)
        local race1 = cfg_1.race
        local race2 = cfg_2.race
        local evo1 = cfg_1.max_evo
        local evo2 = cfg_2.max_evo
        if race1 == race2 then
            if evo1 == evo2 then
                return id_one < id_two
            else
                return evo1 > evo2   
            end
        else
            return race1 < race2
        end
    end
    table.sort(bks, sortFunc)
end

--英雄编队
function M:getHeroBd()
    self.formation = {}
    local f_tab = table.copy(UserDataManager.hero_data:getFormation()) 
    for i = 1, 10 do 
        local index = tostring(i)
        if f_tab[index] == nil then
            f_tab[index] = {name = "编队"..i, team = {} }
        end
    end
    for k,v in pairs(f_tab) do
        local kk = tonumber(k)
        self.formation[kk] = v
    end
    return self.formation
end

--购买格子花费
function M:getByHeroGride_Price()
    local extra_hero_grid = UserDataManager.extra_hero_grid
    local reset_cost = GameUtil:getRefreshCost(extra_hero_grid, 9)
    return reset_cost[3] or 100
end

--格子数量
function M:getHeroGrideNum()
    local vip = ConfigManager:getCfgByName("vip")
	local vip_lv = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
	local vip_item = vip[vip_lv] or {}
    local num = vip_item.hero_limit + UserDataManager.extra_hero_grid
    return num
end

function M:getRaceTowerOpenByRace(race)
    local race_tower_status = self.m_data.race_tower_status or {} -- 种族开启状态 [种族类型], 有就开启
    if table.indexof(race_tower_status, race) then
        return true
    end
    return false
end

function M:checkGetBox()
    Logger.log( "<color=green>gg---</color>"..self.on_hook_time)
    if #self.on_hook_box_list < 3 then
        local box = {
            box_id = 1, --宝箱id
            is_start = false, --激活状态
            s_tim = UserDataManager:getServerTime() --激活时间
        }
        if self.on_hook_time%60 == 0 then
            table.insert(self.on_hook_box_list, box)
            Logger.log(box, "<color=red>生成一个宝箱---</color>")
        end
    end
end

--检查问卷开始
function M:checkQuestion()
    --[[
    local tab_data = ConfigManager:getCfgByName("question")
    local question_data = UserDataManager.questions -- {version: 问卷id, start_ts:开启时间， end_ts：结束时间 }
    if next(question_data) ~= nil then
        local now_tim = UserDataManager:getServerTime()
        local cur_question = tab_data[question_data.version]
        local cur_stage_id = UserDataManager:getCurStage()
        if now_tim >= question_data.start_ts and now_tim <= question_data.end_ts then
            return true
        end
    else
        return false    
    end
    ]]--
    return false
end

function M:getMaxlv(id)
    local cfg = UserDataManager.hero_data:getHeroConfigByCid(id)
    local tab_ = ConfigManager:getCfgByName("hero_evolution")
	local max_lv = tab_[cfg.max_evo]["level_max"]
	return max_lv
end

function M:checkActivesById(id)
    for k,v in pairs(self.m_data.actives) do
        -- if id == v.id and v.open_status == 1 then
        --     return true
        -- end
        if id == v.id then
            return true
        end
    end
    return false
end

function M:checkRechargeActivesById(id)
    for k,v in pairs(self.m_data.recharge_actives) do
        if id == v.id and v.open_status > 0 then
            return true
        end
    end
    return false
end

function M:getGiftPushs()
    local push_gifts = UserDataManager.m_limit_push -- UserDataManager.user_data:getUserStatusDataByKey("push_gifts")
    return push_gifts
end

function M:getGiftChoice()
    local choice_gifts = UserDataManager.m_choice_gifts -- UserDataManager.user_data:getUserStatusDataByKey("push_gifts")
    return choice_gifts
end

function M:getGiftPushTim(id)
    local gift_tab = self:getGiftPushs()
    return gift_tab[id]
end

function M:getGiftChoiceTim(id)
    local gift_tab = self:getGiftChoice()
    return gift_tab[id].ets
end

function M:getShowPushTime()
    local push_tab = table.copy(self:getGiftPushs())
    local new_tab = {}
    for k,v in pairs(push_tab) do
        table.insert(new_tab, {id = tonumber(k), time = v })
    end
    local function sortFunc(id_one, id_two)
        if id_one.time == id_two.time then
            return id_one.id < id_two.id
        else
            return id_one.time < id_two.time
        end
    end
    table.sort(new_tab, sortFunc)    
    if next(new_tab) ~= nil then
        local push_gift = new_tab[1]
        local end_tim = push_gift.time - UserDataManager:getServerTime()
        if end_tim >= 0 then
            return GameUtil:formatTimeBySecond(end_tim,999)
        else
            static_rootControl:updateMsg("common_refresh",nil,"parent")
        end
    end
    return nil
end

function M:getShowChoiceTime()
    local push_tab = table.copy(self:getGiftChoice())
    local new_tab = {}
    for k,v in pairs(push_tab) do
        table.insert(new_tab, {id = tonumber(k), time = v.ets })
    end
    local function sortFunc(id_one, id_two)
        if id_one.time == id_two.time then
            return id_one.id < id_two.id
        else
            return id_one.time < id_two.time
        end
    end
    table.sort(new_tab, sortFunc)
    if next(new_tab) ~= nil then
        local push_gift = new_tab[1]
        local end_tim = push_gift.time - UserDataManager:getServerTime()
        if end_tim >= 0 then
            return GameUtil:formatTimeBySecond(end_tim,999)
        else
            static_rootControl:updateMsg("common_refresh",nil,"parent")
        end
    end
    return nil
end

function M:getOnlineTime()
    local active_tab = ConfigManager:getCfgByName("active")
    for k,v in pairs(self.m_data.actives) do
        local c_cfg = active_tab[v.id]
        if c_cfg.open_id == 76 then
            return v.recv_time
        end
    end
    return nil
end

function M:checkActiveOpenInMain(id)
    if id == 74 then -- 问卷
        return self:checkQuestion()
    elseif id == 23 or id == 88 then --活动
        return true    
    elseif id == 71 then --大侠试炼
        return self:checkActivesById(1)
    elseif id == 76 then --在线
        return self:checkActivesById(5)
    elseif id == 78 then --首充
        return self:checkRechargeActivesById(1)
    elseif id == 87 then
        return true    
    end
    return true
end

function M:checkActiveRedPoint(open_id)
    if open_id == 23 then -- 福利
        for k,v in pairs(self.m_data.actives) do
            if v.id == 7 then
                return v.can_draw
            end
        end
    end
    return false
end

function M:checkPushGiftFirstOpen(id, end_ts)
    local first_login = UserDataManager.local_data:getUserDataByKey("push_gift_"..id.."_"..end_ts, 0)
    return first_login == 0
end

function M:checkChoiceGiftFirstOpen(id, end_ts)
    local first_login = UserDataManager.local_data:getUserDataByKey("choice_gift_"..id.."_"..end_ts, 0)
    return first_login == 0
end

function M:getStageNumByChapter(id)
    if id then
        local chapers_tab = self:getChapersTab(id)
        return table.nums(chapers_tab)
    end
    return 0
end

function M:getChapersTab(id)
    local stage_tab = ConfigManager:getCfgByName("stage")
    local cur_stage = stage_tab[id]
    local cur_chapers = {}
    for k, v in pairs(stage_tab) do
        if cur_stage.chapter_id == v.chapter_id then
            cur_chapers[k] = v
        end
    end
    return cur_chapers
end

function M:checkDoubleEarnId()
    local active_tab = ConfigManager:getCfgByName("active")
    UserDataManager.active_double_id = 0
    for k,v in pairs(self.m_data.actives) do
        local cfg = active_tab[v.id]
        if cfg and (cfg.open_id == 77) then
            UserDataManager.active_double_id = v.id
        end
    end
    return nil
end

function M:getNextWorldMap()
    local stage = UserDataManager:getCurStage()
    local stage_table = ConfigManager:getCfgByName("stage")
    local next_map = 0
    local stepCount = 0
    while(stage_table[stage] ~= nil) do
        if stage_table[stage].open_rivers ~= 0 then
            next_map = stage_table[stage].open_rivers
            break
        else
            stage = stage_table[stage].next_stage
            stepCount = stepCount + 1
        end
    end
    return next_map, stepCount
end

function M:checkNewStage()
    local stage_id = UserDataManager:getTempData("curStageId")
    local cur_stage_id = UserDataManager:getCurStage()
    --if stage_id ~= nil and stage_id ~= cur_stage_id then
    --    local event_data ={last_stage = stage_id, cur_stage = cur_stage_id}
    --    static_rootControl:updateMsg("stageGoForward",event_data,"Main")
    --end
    UserDataManager:setTempData("curStageId", cur_stage_id)
    return stage_id, cur_stage_id
end

function M:checkGoodFeelRewardsRedPoint()
    local item_ids = UserDataManager.item_data:getItemsId()
    for k,v in pairs(item_ids) do
        local data, cfg = UserDataManager.item_data:getItemDataById(v)
        if cfg and cfg.type == 16 then
            return true
        end
    end
    return false
end

function M:getNpcGuide()
    local npc_guide_list = {}
    local cur_stage = UserDataManager:getCurStage()
    local npc_guide_table = ConfigManager:getCfgByName("npc_guide")
    if cur_stage > 0 then
        for k,v in pairs(npc_guide_table) do
            if v.sort == 1 or v.sort == 2 then
                if v.guide_stage <= cur_stage and v.unlock_condition_param > cur_stage then
                    local unlock_days = v.unlock_days
                    if unlock_days then
                        if unlock_days == 0 then
                            table.insert(npc_guide_list, v)
                        elseif unlock_days > 0 then
                            local day = GameUtil:dayCompute()
                            if day >= unlock_days then
                                table.insert(npc_guide_list, v)
                            end
                        end
                    else
                        Logger.logWarningAlways("npc_guide cfg not found unlock_days ")
                    end
                end
            end
        end
    end
    return npc_guide_list
end

function M:soetGiftSort(tab)
    local function sortFunc(id_one, id_two)
        local gift_1 = id_one.gift_id ~= nil and 1 or 2 
        local gift_2 = id_two.gift_id ~= nil and 1 or 2
        local tim_1 = self:getGiftPushTim(id_one.gift_id)
        local tim_2 = self:getGiftPushTim(id_two.gift_id)
        if gift_1 == gift_2 then
            if tim_1 and tim_2 then
                return tim_1 < tim_2
            end
        else
            return gift_1 < gift_2
        end
    end
    table.sort(tab, sortFunc)    
    return tab
end

function M:gachaFingerCheck()
    local diamond = UserDataManager.user_data:getUserStatusDataByKey("diamond")
    local min_num = ConfigManager:getCommonValueById(314)
    if min_num and diamond >= min_num then
        local gacha_ten = UserDataManager.local_data:getUserDataByKey("gacha_ten", 0)
        return gacha_ten == 0
    end
    return false
end

--检查悬赏消耗的道具数量
function M:checkRewardConsume(data)
    local reward_consume = nil
    local common_reward = ConfigManager:getCommonValueById(324)
    for i,v in pairs(data.reward) do
        if v[1] == common_reward[1] and v[2] == common_reward[2] then
            reward_consume = v
        end
    end
    if reward_consume ~= nil then
        local reward_node = RewardUtil:getProcessRewardData(reward_consume)
        local max_hold = reward_node.item_cfg.max_hold or 20000
        if reward_node.user_num + reward_node.data_num > max_hold then
            return true
        end
    end
    return false
end

--检查快速挂机后悬赏令数量
function M:checkQuickRewardConsume()
    local quick_show_tab = self:getQuickShowReward()
    local reward_consume = nil
    local common_reward = ConfigManager:getCommonValueById(324)
    for i,v in pairs(quick_show_tab) do
        if v[1] == common_reward[1] and v[2] == common_reward[2] then
            reward_consume = v
        end
    end
    if reward_consume ~= nil then
        local reward_node = RewardUtil:getProcessRewardData(reward_consume)
        local max_hold = reward_node.item_cfg.max_hold or 20000
        if (reward_node.user_num + reward_node.data_num) > max_hold then
            return true
        end
    end
    return false
end

--快速挂机展示的奖励
function M:getQuickShowReward()
	local stage_id = UserDataManager:getCurStage()
	local stage_tab = table.copy(ConfigManager:getCfgByName("stage_idle_show"))
    local cur_stage_idle_cfg
	for k = 1, #stage_tab do 
		local cur_tab = stage_tab[k]
		if k < #stage_tab then
			local next_tab = stage_tab[k+1]
			if cur_tab.stage_id <= stage_id and next_tab.stage_id > stage_id then
                cur_stage_idle_cfg = cur_tab
                break
			end
		end
	end
    if cur_stage_idle_cfg == nil then
        cur_stage_idle_cfg = stage_tab[#stage_tab] or {}
    end

    local idle_reward_show = cur_stage_idle_cfg.idle_reward_show or {}
    --超前开启条件
    local cur_season = UserDataManager:getCurSeason()
    if cur_season < 2 then
        local cur_stage = UserDataManager:getCurStage()
        if cur_stage >= 3438 then
            local idle_reward_show3 = cur_stage_idle_cfg.idle_reward_show3
            if idle_reward_show3 and next(idle_reward_show3) then
                for i = 1, #idle_reward_show3 do
                    idle_reward_show[#idle_reward_show + 1] = idle_reward_show3[i]
                end
            end
        end
    end
    
	return idle_reward_show
end


--检查主界面开启的活动按钮
function M:getShowMainActive()
    local opne_tab = ConfigManager:getCfgByName("open_condition")
    local main_active_tab = opne_tab[135]
    local temp_tab = table.copy(main_active_tab.buttons)
    local remove_tab = {}
    for i,v in pairs(temp_tab) do
        if v == 178 or v == 453 then
            if self:checkHaveActive(v) then
                remove_tab[i] = false
            else
                remove_tab[i] = true
            end
        elseif self:checkHaveActive(v) == false then
            remove_tab[i] = true
        end
    end
    for i = #temp_tab, 1,-1 do
        if remove_tab[i] == true then
            table.remove(temp_tab, i)
        end
    end
    if self.question_url ~= nil then
        table.insert(temp_tab,74)
    end
    if NineActiveUtil.icon_click_data ~= nil then
        table.insert(temp_tab,399)
    end
    return temp_tab
end
--[[ {
        {group_id = group_id,choices = {id = id, ets = ets}   }

        }
]]--

function M:getThreeChargeCfgById(limit_cfg_id)
    local three_charge_cfg = {}
    local limit_cfg_id = tonumber(limit_cfg_id)
    local gift_tab = ConfigManager:getCfgByName("limit_gift")
    if gift_tab and gift_tab[limit_cfg_id] and gift_tab[limit_cfg_id]["show_type"] then
        local show_type = gift_tab[limit_cfg_id]["show_type"]
        if show_type == 0 then
            local three_charge_id = gift_tab[limit_cfg_id]["three_charge"] or 0
            if three_charge_id > 0 then
                local total_three_charge  = ConfigManager:getCfgByName("three_charge") or {}
                if total_three_charge[three_charge_id] then
                    three_charge_cfg = total_three_charge[three_charge_id]
                end
            end
        end
    end
    return three_charge_cfg
end

function M:checkChoiceGifts()
    local choice_gifts = UserDataManager.m_choice_gifts
    local choice_group_map = {}
    local choice_group_tab = {}
    for i, v in pairs(choice_gifts) do
        local limit_cfg_id = tonumber(i)
        local three_charge_cfg = self:getThreeChargeCfgById(limit_cfg_id)
        if three_charge_cfg and next(three_charge_cfg) then
            local group_id = three_charge_cfg["group"]
            if not(choice_group_map[tostring(group_id)]) then
                choice_group_map[tostring(group_id)] = {}
            end
            local main_name = three_charge_cfg["main_name"] or ""
            local icon = three_charge_cfg["icon"] or ""
            table.insert(choice_group_map[tostring(group_id)],{group_id = group_id, limit_cfg_id = limit_cfg_id, main_name = main_name, icon = icon, end_ts = v.ets } )
        end
    end
    for i, v in pairs(choice_group_map) do
        table.sort(v, function(a, b)
            if a.end_ts == b.end_ts then
                return a.limit_cfg_id < b.limit_cfg_id
            else
                return a.end_ts < b.end_ts
            end
        end)
        table.insert(choice_group_tab,v)
    end
    table.sort(choice_group_tab, function(a, b)
        return a[1].group_id < b[1].group_id
    end)
    return choice_group_tab
end

function M:getChoiceGiftsByGroup(cur_group_id)
    local choice_group_tab = self:checkChoiceGifts()
    local group_data = {}
    local choice_data = {}
    for i = 1, #choice_group_tab do
        local group_id = choice_group_tab[i][1].group_id
        if tonumber(group_id) == tonumber(cur_group_id) then
            group_data = choice_group_tab[i]
        end
    end
    for i = 1, #group_data do
        local limit_id = group_data[i].limit_cfg_id
        local choice_gifts = UserDataManager.m_choice_gifts
        if choice_gifts[tostring(limit_id)] then
            choice_data[tostring(limit_id)] = choice_gifts[tostring(limit_id)]["ets"]
        end 
    end
    return choice_data
end


--检查是否开启当前活动
function M:checkHaveActive(open_id)
    if open_id == 74 then
        return self:checkQuestion()
    elseif open_id == 87 then
        local push_gifts = self:getGiftPushs()
        if next(push_gifts) ~= nil then
            return true
        end
    elseif open_id == 217 then --支付宝红包 ios特有
        return (SDKUtil.sdk_params.app == 2)
    end
    local cfg = BtnOpenUtil:getBtnCfg(open_id)
    if cfg == nil then return false end
    local check_son = cfg.check_son or 0 -- 0检查子功能 1 不检查
    local buttons = cfg.buttons or {}
    -- 铸剑大会特殊处理，内部有子活动没结束不考虑，只要主入口时间到了就结束
    if #buttons > 0 and (open_id ~= 177) and check_son == 0 then
        for i, v in ipairs(buttons) do
            if open_id ~= v then
                if self:checkHaveActive(v) then
                    return true
                end
            else
                Logger.logError("open_condition cfg error, key is " .. tostring(open_id))
            end
        end
    end
    --江湖情缘特殊逻辑
    if open_id == 471 then
        for k, v in pairs(self.m_data.actives) do
            if open_id == v.open_id then
                return v.open_status == 1
            end
        end
        return false
    end
    return self:checkActive(open_id)
end

function M:checkActive(open_id)
    local active_tab = ConfigManager:getCfgByName("active")
    local recharge_actives_tab = ConfigManager:getCfgByName("active_recharge")
    local active_season_tab = ConfigManager:getCfgByName("active_season")
    for k,v in pairs(self.m_data.actives) do
        local c_cfg = active_tab[v.id]
        if c_cfg and open_id == c_cfg.open_id then
            return true
        end
        local s_cfg = active_season_tab[v.id]
        if s_cfg and open_id == s_cfg.open_id then
            return true
        end
    end
    for k,v in pairs(self.m_data.recharge_actives) do
        local c_cfg = recharge_actives_tab[v.id]
        if c_cfg and open_id == c_cfg.open_id then
            return true
        end
    end
    return false
end

function M:checkActiveDataByOpenId(open_id)
    local active_tab = ConfigManager:getCfgByName("active")
    local recharge_actives_tab = ConfigManager:getCfgByName("active_recharge")
    for k,v in pairs(self.m_data.actives) do
        local c_cfg = active_tab[v.id]
        if c_cfg and open_id == c_cfg.open_id then
            return c_cfg
        end
    end
    for k,v in pairs(self.m_data.recharge_actives) do
        local c_cfg = recharge_actives_tab[v.id]
        if c_cfg and open_id == c_cfg.open_id then
            return c_cfg
        end
    end
    return nil
end

--[[收起活动列表后需要展示的
    @desc: 1 固定展示充值、 
           2 展示有红点的活动、 
           3 当没有2时展示首充/问卷、 
           4 当没有2,3时按照新卡活动/大侠试炼/盗帅密宗顺序展示
    @return:
]]
function M:hideActivesShow()
    local show_tag = {149}
    local act_tab = self:getShowMainActive()
    --红点
    for k,v in pairs(act_tab) do
        local red_flag = RedPointUtil:isFuncRedPointById(v)
        if red_flag == true and v ~= 149 and #show_tag < 2 then
            table.insert(show_tag, v)
        end
    end
    if #show_tag > 1 then
        return show_tag
    end
    --首充/问卷
    for k,v in pairs(act_tab) do
        if v == 78 or v == 74 then
            if #show_tag < 2 then
                table.insert(show_tag, v)
            end
        end
    end
    --新卡活动/大侠试炼/盗帅密宗
    if #show_tag > 1 then
        return show_tag
    end
    for k,v in pairs(act_tab) do
        if v == 121 or v == 71 or v == 140 then
            if #show_tag < 2 then
                table.insert(show_tag, v)
            end
        end
    end
    return show_tag
end

function M:getActivePosByIndex(index)
    if index > 5 then
        return Vector3((index - 6)* -80, -32,0)
    else
        return Vector3((index-1) * -80, 42, 0)
    end
end

--获取开服红包活动url
function M:getRedPaperUrl(id)
    local active_tab = ConfigManager:getCfgByName("active")
    for i, v in pairs(active_tab) do
        if v.open_id == id then
            return v.link
        end
    end
    return nil
end

-- 检查发的消息是否是动图
function M:checkMsgIsEmojiGif(msg)
    local emoji = ConfigManager:getCfgByName("emoji")
    local emoji_gif_data = emoji[2] or {}
    for i, v in pairs(emoji_gif_data) do
        local str = "["..v.emoji .."]"
        if str == msg then
            return v
        end
    end
    return nil
end

--
function M:checkMagicWeaponOpen()
    local season_data = UserDataManager.m_season_data or {}
	if season_data and next(season_data) and season_data.season then
        if season_data.season < 2 then
            return self:getShareLv()
        end
    end
    return true
end

function M:getShareLv()
	local top_hero = UserDataManager.hero_data:getLevelTop()
	if next(top_hero) == nil then
		return true
	end
    local lock_lv = ConfigManager:getCommonValueById(577,160)
    self.weapon_lock_lv = lock_lv
	if #top_hero >= 5 then
		local cur_data = top_hero[5]
		if cur_data[2] >= lock_lv then
			return true	
		end
	else
		return false	
	end 
	return false
end

--获取开启活动信息
function M:getOpenActiveData(open_id)
    for i, v in pairs(UserDataManager.m_actives) do
        if v.open_id == open_id then
            return v
        end
    end
    return nil
end

--接了乐变SDK and 奖励没领取，就可以领奖励
function M:canGetDownloadReward()
    local getLeBianSDK = SDKUtil:getLeBianSDK() --是否接了乐变SDK
    if getLeBianSDK then
        local status = UserDataManager:getPlayAndDownloadStatus()
        return status == 0 --是否已经领取过下载奖励，0 未领取， 1 已领取
    end
    return false
end

--获取要轮播数据
function M:getCarsourelActiveData()
    local cfg = ConfigManager:getCfgByName("carousel_chart")
    if not cfg then
        return {}
    end
    local list = {}
    for k,v in pairs(cfg) do
        local active = nil
        if k == 218 then --赛季预告 特殊处理
            active = self:checkSeasonPreviewOpen()
        else
            active = UserDataManager:getActivesDataByOpenId(tonumber(k))
            if active == nil then
                active = UserDataManager:getActivesRechargeByOpenId(tonumber(k))
            end
        end
        if v.show == 1 and active then
            local data = {}
            data.open_id = tonumber(k)
            data.icon = v.pic
            data.show = v.show
            data.order = v.order
            data.jump_id = v.jump_id
            table.insert(list,data)
        end
    end
    table.sort(list,function(a, b) 
        return a.order < b.order
    end)
    return list
end

--获取前缘抽卡当前卡池结束时间戳
function M:getPredestinedEndTime()
    local all_cfg = ConfigManager:getCfgByName("high_gacha_aim")
    local cur_time = UserDataManager:getServerTime()
    for k,v in pairs(all_cfg) do
        local start_time = v.start_time
        local end_time = v.end_time
        if cur_time >= start_time and cur_time < end_time then
            return end_time
        end
    end
    return 0
end

--赛季预告
function M:checkSeasonPreviewOpen()
    local openSeasonPreviewFlag = true
    local tips_str = ""
    local open_flag1, tips_str1 = BtnOpenUtil:isBtnOpen(218)
    if open_flag1 == false then
        openSeasonPreviewFlag = false
        tips_str = tips_str1
    end
    if openSeasonPreviewFlag and GameUtil:isSeasonPreviewOpen() == false then
        openSeasonPreviewFlag = false
        tips_str = Language:getTextByKey("new_str_1032")
    end
    local is_have_next = self:isHaveNextSeason()
    if openSeasonPreviewFlag and is_have_next == false then
        openSeasonPreviewFlag = false
        tips_str = Language:getTextByKey("new_str_1032")
    end
    return openSeasonPreviewFlag, tips_str
end

--检查是否有赛季预告
function M:isHaveNextSeason()
    local cur_season = UserDataManager:getCurSeason() + 1
    local season_notice_cfg = ConfigManager:getCfgByName("season_notice")
    if season_notice_cfg and season_notice_cfg[cur_season] then
        return true
    end
    return false
end

return M