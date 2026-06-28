local M = class("SummerMainModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData("hero_chest_index")
end

function M:onEnter()
    self.is_end = false

    if self.m_data["end"] or self.m_data["update"] then
        self.is_end = true

        if self.m_data["end"] then
            UserDataManager.active_121_end = true
            static_rootControl:updateMsg("end_summer", nil, "Summer.SummerMain")
        end
    else
        --获取材料数据
        self.m_quests = self.m_data.quests
        self.m_quest_buy_times = self.m_data.quest_buy_times
        self.m_hero_cfg = self:getHero()
        --限时登录数据
        self.m_login_rcvd = self.m_data.login_rcvd
        self.m_login_vsn = self.m_data.login_vsn
        self.m_actives = self.m_data.actives
        self.m_charge_actives = self.m_data.charge_actives
        self.m_is_token = self.m_params.is_token or false --代金券进入
        self.m_open_sub_id = self.m_params.open_sub_id or 0
        --天机觅宝数据
        --self.m_draw_box = self.m_data.draw_box
        --self.m_draw_times = self.m_data.draw_times
        --self.m_draw_vsn = self.m_data.draw_vsn
        --获取活动名称与活动时间
        self.m_active_condition = ConfigManager:getCfgByName("open_condition")
    end
end

function M:refreshRPData(update_cb)
    local rpData = {}
    -- login7
    local active_time_prd = self:getActive()[127]
    local cur_active_time = active_time_prd.end_ts - active_time_prd.start_ts
    local remain_ts = active_time_prd.remain_ts

    local active_day = GameUtil:getTimeLayoutBySecond(cur_active_time)
    local remain_day, hour = GameUtil:getTimeLayoutBySecond(remain_ts)

    local day = active_day - remain_day + 1

    local function findRecv(idx)
        for k, v in pairs(self.m_login_rcvd) do
            if v == idx then
                return true
            end
        end
        return false
    end

    if remain_ts > 0 then
        for i = 1, 7 do
            if i <= day then
                if not findRecv(i) then
                    rpData.login7 = 1
                end
            end
        end

        if day > 6 then
            if not findRecv(0) then
                rpData.login7 = 1
            end
        end
    end
    -- openBox
    local srvTime = UserDataManager:getServerTime()
    local curnumbox = 0
    local boxList = self.m_data.draw_box
    for i = 1, 5 do
        local box = boxList[i]
        if box then
            if box.ts then
                curnumbox = i
                if box.ts < srvTime then
                    rpData.openBox = 1
                end
            end
        end
    end

    if remain_ts > 0 then
        if not rpData.openBox then
            local chest = ConfigManager:getCfgByName("chest")
            local verson = self.m_data.draw_vsn
            --Logger.logError(chest,"self.m_draw_vsn "..self.m_draw_vsn )
            local list_chest = chest[verson]

            local score = list_chest.score[1]
            local itemData = RewardUtil:getProcessRewardData(score)

            local curNum = itemData.user_num
            local needNum = itemData.data_num

            if curNum >= needNum and curnumbox < 5 then
                rpData.openBox = 1
            end
        end
    end

    -- buyMaterial
    -- m_quest_vsn = self.m_model.m_data.quest_vsn,
    -- m_quests = self.m_model.m_quests,
    if remain_ts > 0 then
        local chest_shop = ConfigManager:getCfgByName("chest_shop")

        local quest_buy_times = self.m_quest_buy_times

        for k, v in pairs(chest_shop) do
            if quest_buy_times < v.times then
                rpData.buyMaterial = 1
            end
        end

        -- getMaterial

        local chest_quset = ConfigManager:getCfgByName("chest_quest")
        for k, v in pairs(chest_quset[1]) do
            local status = self.m_quests[tostring(k)]["status"]

            if status == 1 then
                rpData.getMaterial = 1
            end
        end
    end

    if update_cb and type(update_cb) == "function" then
        update_cb(rpData)
    end
    -- RedPointUtil:__update_summerRP(rpData)
end

--更新抽奖数据（天机觅宝）
function M:updateDrawData(data)
    if data and data["end"] then
        UserDataManager.active_121_end = true
        static_rootControl:updateMsg("end_summer", nil, "Summer.SummerMain")
    end

    table.merge(self.m_data, data)
    --self.m_draw_box = data.draw_box
    --self.m_draw_times = data.draw_times
    --self.m_draw_vsn = data.draw_vsn
end

--活动中的活动时间转换
function M:getActiveTime()
    local active_time = {}
    local charge_active_time = {}
    for k, v in pairs(self.m_charge_actives) do
        local id = v["id"]
        charge_active_time[id] = v
    end
    for k, v in pairs(self.m_actives) do
        local id = v["id"]
        active_time[id] = v
    end
    return active_time, charge_active_time
end

--获取活动配置
function M:getActive()
    local function __timeToTs(txt)
        local _, _, y, moth, d, h, mi, s = string.find(txt, "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)")
        return os.time({year = y, month = moth, day = d, hour = h, min = mi, sec = s})
    end

    local currentActive = {}
    local active_time, charge_active_time = self:getActiveTime()
    --获取充值活动配置

    local svrTime = UserDataManager:getServerTime()

    local active_recharge = ConfigManager:getCfgByName("active_recharge")
    for k, v in pairs(active_recharge) do
        if charge_active_time[k] ~= nil then
            local time = {}
            local end_txt = active_recharge[k]["end_time"]
            time.time_text = active_recharge[k]["start_time"] .. "~~" .. end_txt

            time.start_ts = charge_active_time[k].start_ts --服务器返回的活动开始时间
            time.end_ts = charge_active_time[k].end_ts --__timeToTs(end_txt) --服务器返回的活动结束时间
            time.remain_ts = charge_active_time[k].remain_ts -- svrTime --服务器返回的活动剩余时间
            time.show_ts = charge_active_time[k].end_ts
            -- 活动展示开始时间，活动结束需要关闭红点，上方show_ts之前程序赋值成了活动结束时间，现做法保留之前参数，新加参数处理红点
            time.newShow_start_ts = charge_active_time[k].show_start_ts

            local open_id = v["open_id"]
            currentActive[open_id] = time
        end
    end
    local active = ConfigManager:getCfgByName("active")
    --获取活动配置

    for actiev_id, active_val in pairs(active_time) do
        local curActive = active[actiev_id]
        local open_id = curActive["open_id"]
        local time = {}
        local end_txt = active_val.end_ts -- curActive["end_time"]

        time.time_text = curActive["start_time"] .. "~~" .. end_txt

        time.start_ts = active_val.start_ts
        time.end_ts = end_txt-- __timeToTs(end_txt)
        time.remain_ts = active_val.remain_ts--time.end_ts - svrTime
        time.show_ts = active_val.end_ts
        -- 活动展示开始时间，活动结束需要关闭红点，上方show_ts之前程序赋值成了活动结束时间，现做法保留之前参数，新加参数处理红点
        time.newShow_start_ts = active_val.show_start_ts

        currentActive[open_id] = time
    end

    return currentActive
end

--获取英雄
function M:getHero()
    local check_table = ConfigManager:getCfgByName("chest_hero")
    -- local check_table_verson = check_table.check_table_verson or 1
    local check_table_verson = self.m_data.hero_vsn or 1
    local hero_id = check_table.hero_id or 1
    self.hero_info = check_table[check_table_verson][hero_id]
    self.reward = self.hero_info.reward
    local reward_data = RewardUtil:getProcessRewardData(self.reward[1])
    if
        reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or
            reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT
     then
        self.hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(reward_data.data_id)
    end
    return self.hero_cfg
end

-- get skin
function M:getSkin()
    local check_table = ConfigManager:getCfgByName("chest_clothes")
    -- local check_table_verson = check_table.check_table_verson or 1
    local check_table_verson = self.m_data.clothes_vsn or 1
    local hero_id = check_table.hero_id or 1
    self.skin_info = check_table[check_table_verson][hero_id]
    self.skin_reward = self.skin_info.reward
    local reward_data = RewardUtil:getProcessRewardData(self.skin_reward[1])
    self.skin_cfg = reward_data
    if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HERO_SKIN then
        self.hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(reward_data.item_cfg["hero"])
    end
    return self.hero_cfg, self.skin_cfg
end

--获取英雄位置
function M:getSpinePos(cfg)
    if cfg == nil then
        return Vector3(0, 0, 0)
    end

    local id = cfg.id
    local hero_tab = ConfigManager:getCfgByName("hero_detail")
    local data_pos = hero_tab[id]["spine_position"]
    local data_scale = hero_tab[id]["hero_scale"] or 1
    return data_pos, data_scale
end

return M
