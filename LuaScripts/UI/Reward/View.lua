---@class RewardView:OOPopBase
local M = class("RewardView", LikeOO.OOPopBase)

M.m_uiName = "Reward/Reward"
M.m_iphoneXAdapter = true
M.m_size_type = 1
M.cell_childList = nil
local __TAB_BTN_NODE = {
    {btn_key = "person_btn", lua_name = "", btn_text = "person_btn_text", text_key = "new_str_0495", open = true, red_point = "message_red_point_img", red_point_id = 1002}, 
    {btn_key = "underworld_btn", lua_name = "", btn_text = "underworld_btn_text", text_key = "new_str_0494", open = true, red_point = "details_red_point_img"} 
}
local TEST_TASK_LIST = {}

function M:onEnter()
    M.super.onEnter(self)
    self:setTextByLanKey("close_title_text", "new_str_0399")
    self:setTextByLanKey("consume_text", "new_str_1050")
    self:setTextByLanKey("main_title_text", "bounty_str_0001")
    self:setTextByLanKey("one_keyreward_text", "mail_str_0017")
    self:setTextByLanKey("main_title_text", "bounty_str_0001")
    self.opensend_btn = self:findGameObject("opensend_btn")
    self.m_loopScroll = LoopScrollUtil.new()
    local tiwn_tog_btn = self:findToggle("person_btn")
    local team_tog_btn = self:findToggle("underworld_btn")
    UIUtil.addToggleListener(
        tiwn_tog_btn,
        function(is_on)
            self:switchTabUpdate(is_on, "tiwn_tog")
        end,
        nil,
        self.m_uiName
    )
    UIUtil.addToggleListener(
        team_tog_btn,
        function(is_on)
            self:switchTabUpdate(is_on, "team_tog")
        end,
        nil,
        self.m_uiName
    )
    tiwn_tog_btn.isOn = true
    self:refreshUI()
end


M.titleColor = {
    --Color( 105/255, 110/255, 117/255),
    Color( 70/255, 148/255, 97/255),
    Color( 91/255, 124/255, 196/255), 
    Color( 134/255, 91/255, 215/255),
    Color( 182/255, 141/255, 64/255),
    Color( 200/255, 87/255, 67/255),
    Color( 200/255, 87/255, 67/255),
}


function M:refreshUI()
    local renovate_tab = ConfigManager:getCfgByName("renovate")
    self:setText("reset_btn_text", "刷新")
    self:setText("aid_btn_text", "我的外援")
    self:setText("tog_1_text", "个人悬赏")
    --self:setTextByLanKey("aid_btn_text2", "bounty_str_0007")
    self:setTextByLanKey("title_text", "bounty_str_0017")
    self:setText("Lev_text", "Lv"..self.m_model.bounty_lv)
     --当前等级
    self:setObjectVisible("tog1_hint", false)
    self:setObjectVisible("tog2_hint", false)

    local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(414)
    local play_img = self:findGameObject("hero_spine")
    GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..hero_cfg.hero_spine, "idle", 0, true)

    --text_oneKeyreward
    local item_data,item_cfg = UserDataManager.item_data:getItemDataById(self.m_model.common[323].value[2])
    local item_data1,item_cfg1 = UserDataManager.item_data:getItemDataById(self.m_model.common[324].value[2])
    self.order_img = self:findGameObject("order_img")
    self.refresh_img = self:findGameObject("refresh_img")
    self.diamond_img = self:findGameObject("diamond_img")
    
    local order_num = GameUtil:formatValueToString(item_data1.num)
    local refresh_num = GameUtil:formatValueToString(item_data.num)

    self:setTextByLanKey("order_text", tostring(order_num))-- 悬赏令
    self:setTextByLanKey("refresh_text", tostring(refresh_num))--刷新令

    self:setText("reset_order_text", "x"..self.m_model.common[323].value[3]) --消耗刷新令
    local reset_btn_text_obj = self:findGameObject("reset_btn_text")

    self:setImg(item_cfg.icon, "item_icon", "reset_btn_img") --按钮s刷新
    self:setImg(item_cfg.icon, "item_icon", "refresh_img") --s刷新

    self:setImg(item_cfg1.icon, "item_icon", "order_img") --悬赏
    local yb_data = {RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0}
    local diamond_data = RewardUtil:getProcessRewardData(yb_data)  
    local user_num = GameUtil:formatValueToString(diamond_data.user_num)
    self:setImg(diamond_data.icon_name, diamond_data.atlas_name, "diamond_img")--元宝
    self:setTextByLanKey("diamond_text", tostring(user_num))
    self:setText("max_times_text", Language:getTextByKey("tid#limit_2") ..  self.m_model.m_data.pay_refresh .. "/" .. self.m_model:getMaxTimes())
    self:setObjectVisible("max_times_text", false)

    if self.m_model.free_refresh < self.m_model.common[326].value then
        self:setTextByLanKey("reset_btn_text", "bounty_str_0016")
        reset_btn_text_obj.transform.anchoredPosition = Vector2.New(0, 0)
       -- local rect = imgRect.sizeDelta;
        self:setObjectVisible("reset_order_text", false)
        self:setObjectVisible("reset_btn_img", false)
    else
        self:setTextByLanKey("reset_btn_text", "bounty_str_0015")
        self:setObjectVisible("reset_btn_img", true)
        self:setObjectVisible("reset_order_text", true)
        reset_btn_text_obj.transform.anchoredPosition =  Vector2.New(30, 0)
        if item_data.num <= 0 then
            self:setImg("DJ_yuanbao", "item_icon", "reset_btn_img")
            local num = self.m_model.pay_refresh
            if num > 20 then
                num = 20
            end 
            self:setObjectVisible("max_times_text", true)
            self:setText("reset_order_text", renovate_tab[13].cost[num][3]) --消耗的元宝
        end
    end
    self:setResetTim()

    if UserDataManager:hasRewardSubscribe() then
        self:setTextByLanKey("intelligence_btn_text", "bounty_str_0017")
        self:findImage("intelligence_btn").material = nil
    else
        self:setTextByLanKey("intelligence_btn_text", "bounty_str_0018")
    end

    --快速导航
    self:setObjectVisible("guide_btn", true)
    self:setOneAwardBtnState()
end

function M:setOneAwardBtnState()
    local isCanGot = self.m_model:isCanGotTask()
    local isShowBtn = true
    if isCanGot then
        self:setTextByLanKey("text_oneKeyreward", "offerAward_str_0001")
        isShowBtn = true
    else
        local isDispatchCondition = self.m_model:isSatisfyDispatchCondition()
        if isDispatchCondition then
            self:setTextByLanKey("text_oneKeyreward", "offerAward_str_0002")
            isShowBtn = true
        else
            self:setTextByLanKey("text_oneKeyreward", "offerAward_str_0001")
            isShowBtn = false
        end
    end
    local one_keyreward_btn = self:findButton("one_keyreward_btn")
    one_keyreward_btn.interactable = isShowBtn
end

function M:setLoopScrollOffset(ismove)
    if self.m_loop_scroll_view ~= nil then
        local get_value = self.m_loop_scroll_view:getContentOffset()
        local v = get_value
        if ismove == true then
            v.x = get_value.x - 20
        elseif ismove == false then
            v.x = get_value.x + 20
        end
        v.y = 0
        self.m_loop_scroll_view:setContentOffset(v)
    end
end

function M:refreshTask(data)
    -- local pos = self.m_loop_scroll_view:getContentOffset()
    self:refreshUI()
    self:updateLoopScroll(data)
    -- if data then
    --     self.m_loop_scroll_view:setContentOffset(pos)
    -- end
end

function M:refreshLoopScroll()
    if self.m_loop_scroll_view then
        local data = self.m_model:getTaskList()
        if #data >= 5 then
            self.m_loop_scroll_view:moveToCellIndex(1)
        end
    end
end

function M:switchTabUpdate(is_on, update_key)
    if is_on then
        self:updateMsg(update_key)
    end
end

--切换页签
function M:seleteTag(index)
    self:setResetTim()
    self:updateLoopScroll()
    local tog_1_text = self:findText("person_btn_text")
    local tog_2_text = self:findText("underworld_btn_text")
    tog_1_text.color = index == 1 and GlobalConfig.COMMON_COLLOR.COMMON_1 or GlobalConfig.COMMON_COLLOR.COMMON_7
    tog_2_text.color = index == 2 and GlobalConfig.COMMON_COLLOR.COMMON_1 or GlobalConfig.COMMON_COLLOR.COMMON_7
    if index == 1 then
        self:setObjectVisible("reset_btn", true)
    elseif index == 2 then
        self:setObjectVisible("reset_btn", false)
    end
end
function M:updateLoopScroll(cell_send_data)
    self.isCommon = false
    self.maxRank = 3
    local data = self.m_model:getTaskList()
    data = table.shallow_copy(data)
    local next_btn = self:findGameObject("next_btn")
    local loopscroll = self:findGameObject("loopscroll")

    local loopscrollRect = loopscroll:GetComponent("RectTransform")
    local scroll_content = self:findGameObject("scroll_content")
    local scroll_contentRect = scroll_content:GetComponent("RectTransform")
    --local HorizontalLayoutGroup = scroll_content:GetComponent("HorizontalLayoutGroup")

    if #data > 5 then
        --HorizontalLayoutGroup.enabled = false
        self.m_control:setTimer(0.5, function()
            next_btn:SetActive(scroll_contentRect.anchoredPosition.x > loopscrollRect.sizeDelta.x - scroll_contentRect.sizeDelta.x + 3)
        end)
    else
        --HorizontalLayoutGroup.enabled = true
        next_btn:SetActive(false)
    end
    TEST_TASK_LIST = {}
    if self.m_loop_scroll_view == nil then
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            --pos_center = true,
            update_cell = function(index, cell_object, cell_data)
                self:setTaskCell(cell_data, cell_object)
                TEST_TASK_LIST[cell_object] = cell_data
                if index == 1 then
                    self.m_guide_cell = cell_object
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "opensend_btn" or click_name == "open_send" then
                    self:updateMsg("open_send", {reward = cell_data.data.reward, id = cell_data.id, cell_data = cell_data, lifetime = self.lifetime_text,index = index})
                end
                if click_name == "reward_btn" or click_name == "accomplish_send" then
                    self:updateMsg("get_reward", cell_data.id)
                end
                if click_name == "chakan_btn" then
                    self:updateMsg("chakan_btn", {cell_data = cell_data})
                end

                if click_name == "speed_send" then
                    self:updateMsg("speed_send", {cell_data = cell_data,index = index})
                end
            end,
            ui_name = self.m_uiName,
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, true)
    end
    if #data > 0 then
        self:setObjectVisible("nil_caneqp", false)
    else
        self:setObjectVisible("nil_caneqp", true)
    end
end
M.lifetime_text = nil
   
function M:setTaskCell(task, obj, cell_send_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local name = luaBehaviour:FindText("offer_name_text")
     --任务名字
    name.text = Language:getTextByKey(task.cfg.name)
   

    --任务奖励
    local drop = task.data.reward or {}
    if #drop <= 0 then
        drop = task.cfg.reward
    end
    local rewadd_item = GameUtil:createItemElement(drop[1], true, true, nil)
    local tim_text = luaBehaviour:FindText("tim_text")
    local slider = luaBehaviour:FindGameObject("slider")
    local fill = luaBehaviour:FindImage("Fill")
    local reward_btn = luaBehaviour:FindGameObject("reward_btn")
    local opensend_btn = luaBehaviour:FindGameObject("opensend_btn")
    local life_time_text = luaBehaviour:FindText("life_time_text")
    local finish_bg = luaBehaviour:FindGameObject("finish_bg")
    local rw_time_text = luaBehaviour:FindText("rw_time_text")
    local value_text = luaBehaviour:FindText("value_text")
    local quality_up_img = luaBehaviour:FindGameObject("quality_up_img")
    local type_img = luaBehaviour:FindGameObject("type_img")
    local ItemNode = luaBehaviour:FindGameObject("ItemNode")
    local slider_tx = luaBehaviour:FindGameObject("UI_Reward_JinDuTiao")
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num_bg", true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "finish_text", false)
    local node = luaBehaviour:FindGameObject("node")
    local order_count_text = luaBehaviour:FindText("order_count_text")
    local open_send = luaBehaviour:FindGameObject("open_send")
    local speed_send = luaBehaviour:FindGameObject("speed_send")
    local accomplish_send = luaBehaviour:FindGameObject("accomplish_send")
    local receive_kuang = luaBehaviour:FindGameObject("receive_kuang")
    
    local item_tx = {}
    quality_up_img:SetActive(false)
    slider_tx:SetActive(false)
    type_img:SetActive(false)
    rw_time_text.gameObject:SetActive(false)
    open_send:SetActive(true)
    speed_send:SetActive(false)
    accomplish_send:SetActive(false)
    receive_kuang:SetActive(false)

    --order_count_text.text = "x"..self.m_model.common[324].value[3]--悬赏令消耗
    order_count_text.text = self.m_model.common[324].value[3]--悬赏令消耗
    local item_data,item_cfg = UserDataManager.item_data:getItemDataById(self.m_model.common[324].value[2])
    LuaBehaviourUtil.setImg(luaBehaviour, "or_img", item_cfg.icon, "item_icon")


    local data = RewardUtil:getProcessRewardData(drop[1])
    local quality_item = GlobalConfig.BOUNTY_RANK[task.cfg.rank] or GlobalConfig.QUALITY_COMMON_SETTING[1]
    local itemObj = GameUtil:updateItemElementByData(ItemNode, data, false, true)
    local itemLuabehaviour = UIUtil.findLuaBehaviour(ItemNode)
    if itemLuabehaviour then
        LuaBehaviourUtil.setTextByLanKey(itemLuabehaviour, "center_text", data.data_num)
        LuaBehaviourUtil.setObjectVisible(itemLuabehaviour, "center_text", true)
        local tx_1 = itemLuabehaviour:FindGameObject("UI_ItemNode_Glow_001")
        table.insert( item_tx, tx_1)
        local tx_2 = itemLuabehaviour:FindGameObject("UI_ItemNode_Glow_002")
        table.insert( item_tx, tx_2)
        if GameUtil:checkDoubleActiveByType(3) == true then
            LuaBehaviourUtil.setObjectVisible(itemLuabehaviour, "double_earn", true)
        else
            LuaBehaviourUtil.setObjectVisible(itemLuabehaviour, "double_earn", false)
        end
    end
    LuaBehaviourUtil.setImg(luaBehaviour, "item_img", data.icon_name, data.atlas_name)
    --LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", quality_item.frame, "equip_icon")
    if task.cfg.type == 2 then
        LuaBehaviourUtil.setImg(luaBehaviour, "type_img", "a_xuansahng_paiqian_bangpai", "common_ui")
        type_img:SetActive(true)
    elseif task.cfg.type == 3 or task.cfg.type == 4 then
        LuaBehaviourUtil.setImg(luaBehaviour, "type_img", "a_xuanshang_paiqian_shitu", "common_ui")
        type_img:SetActive(true)
    end
    if task.cfg.bounty_type == 1 then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg_type_1", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg_type_2", true)
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg_type_1", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg_type_2", false)
    end
    if task.cfg.rank == 6 then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg_type_1", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg_type_2", true)
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg_type_1", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg_type_2", false) 
    end
    tim_text.gameObject:SetActive(false)
    life_time_text.gameObject:SetActive(false)
   -- slider:SetActive(false)
    reward_btn:SetActive(false)
    local finish_bg = luaBehaviour:FindGameObject("finish_bg")
    finish_bg:SetActive(false)
    for k,v in pairs(item_tx) do
        v:SetActive(false)
    end
    --任务状态
    if task.data.quest_status == 0 then --未派遣
        open_send:SetActive(true)
        speed_send:SetActive(false)
        if task.cfg.rank >= 3 or task.cfg.bounty_type == 1 then
            if task.cfg.rank > self.maxRank then
                self.maxRank = task.cfg.rank
            end
            self.isCommon = true
        end

        opensend_btn:SetActive(true)
        local tim = GameUtil:formatTimeBySecond(task.cfg.duration_time * 60)
        value_text.gameObject:SetActive(true)
        --rw_time_text.gameObject:SetActive(true)
        value_text.text = tim
        LuaBehaviourUtil.setImg(luaBehaviour, "type_bg", "a_xs_weikaishi_di", "common_ui")
        --rw_time_text.text = Language:getTextByKey("new_str_0123")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "open_send_text", "bounty_str_0013")
        if self.m_model.cur_type == 2 then
        else
        end
    elseif task.data.quest_status == 1 then --派遣中
        --rw_time_text.gameObject:SetActive(false)
        opensend_btn:SetActive(false)
        value_text.gameObject:SetActive(false)
        if task.count_down then
            if task.count_down <= 0 then
                rw_time_text.text = Language:getTextByKey("new_str_0063")
                rw_time_text.gameObject:SetActive(true)
               -- tim_text.text = Language:getTextByKey("new_str_0063")
                --tim_text.gameObject:SetActive(true)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "finish_text", true)
                reward_btn:SetActive(true)
                --slider:SetActive(true)
                fill.fillAmount = 1
                LuaBehaviourUtil.setImg(luaBehaviour, "Fill", "a_rw_jindu_lv", "main_ui")
                task.data.quest_status = 2
            else
                local ratio = task.count_down / (task.cfg.duration_time * 60)
                fill.fillAmount = 1 - ratio
                LuaBehaviourUtil.setImg(luaBehaviour, "Fill", "a_rw_jindu_cheng", "main_ui")
                tim_text.text = GameUtil:formatTimeBySecond(task.count_down,999)
                tim_text.gameObject:SetActive(true)
                LuaBehaviourUtil.setImg(luaBehaviour, "type_bg", "a_xs_jinxingzhong_di", "common_ui")
                --slider:SetActive(true)
                if self.m_model.cur_type == 2 and self.m_model:chechMasterStatue() == true then
                end
            end
            local open_send_text = luaBehaviour:FindText("speed_text")
            open_send_text.text = Language:getTextByKey("new_str_0705")
            local speed_count_text = luaBehaviour:FindText("speed_count_text")
            --speed_count_text.text = "x"..self.m_model.common[335].value[1][3]--悬赏令消耗
            speed_count_text.text = self.m_model.common[335].value[1][3]--悬赏令消耗
            LuaBehaviourUtil.setImg(luaBehaviour, "speed_img", "DJ_yuanbao", "item_icon")
            open_send:SetActive(false)
            speed_send:SetActive(true)

        end
    elseif task.data.quest_status == 2 then --待领取
        open_send:SetActive(false)
        speed_send:SetActive(false)
        accomplish_send:SetActive(true)
        receive_kuang:SetActive(true)
        local accomplish_text = luaBehaviour:FindText("accomplish_text")
        accomplish_text.text = Language:getTextByKey("new_str_0056")
        --rw_time_text.gameObject:SetActive(false)
        opensend_btn:SetActive(false)
        value_text.gameObject:SetActive(false)
        -- tim_text.text = Language:getTextByKey("new_str_0063")
        tim_text.gameObject:SetActive(false)
        rw_time_text.text = Language:getTextByKey("new_str_0063")
        rw_time_text.gameObject:SetActive(true)
        if self.m_model.cur_type == 2 then
            reward_btn:SetActive(not self.m_model:chechMasterStatue())
        else
            reward_btn:SetActive(true)
        end
        --slider:SetActive(true)
        fill.fillAmount = 1
        LuaBehaviourUtil.setImg(luaBehaviour, "type_bg", "a_xs_yiwancheng_di", "common_ui")
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "finish_text", true)
        LuaBehaviourUtil.setImg(luaBehaviour, "Fill", "a_rw_jindu_lv", "main_ui")
        slider_tx:SetActive(true)
        for k,v in pairs(item_tx) do
            v:SetActive(true)
        end
    end
    local star_tab = {}
    local st = luaBehaviour:FindGameObject("star_1")
    st:SetActive(false)
    for i = 1, 6 do
        local st = luaBehaviour:FindGameObject("star_" .. i)
        st:SetActive(false)
        table.insert(star_tab, i, st)
    end
    for k, v in pairs(star_tab) do
        if task.cfg.rank >= k then
            local st = luaBehaviour:FindGameObject("str_obj")
            st:SetActive(true)
            v:SetActive(true)
        end
    end
    name.color = self.titleColor[task.cfg.rank]
    self.lifetime_text = life_time_text.text
   
end

-- function M:openSelectHero( ... )
-- 	local tab_cls = CustomRequire("UI.WorldMap.WorldMapReward.WorldMapHeroSelectNode")
--     self.m_cur_tab_node = tab_cls.new(self.m_control)
-- end

function M:changeImg(img)
end

-- end
--更新刷新时间
function M:setResetTim()
    -- local tim = GameUtil:formatTimeBySecond(self.m_model.dataTime)
    -- if self.m_model.cur_type == 1 then
    --     local time_show = " " .. tim
    --     self:setText("reset_time_text", time_show)
    -- elseif self.m_model.cur_type == 2 then
    --     local time_show = " " .. tim
    --     self:setText("reset_time_text", time_show)
    -- end
    self:updateItemTime()
    self:setOneAwardBtnState()
end

function M:updateItemTime()
    for k, v in pairs(TEST_TASK_LIST) do
        local obj = k
        local data = v
        if data.data.quest_status == 1 then --派遣中
            if IsNull(obj) then
                return
            end
            local luaBehaviour = UIUtil.findLuaBehaviour(obj)
            data.count_down = data.count_down - 1
            local fill = luaBehaviour:FindImage("Fill")
            local tim_text = luaBehaviour:FindText("tim_text")
            if data.count_down <= 0 then
            --if time <= 0 then
                fill.fillAmount = 1
                LuaBehaviourUtil.setImg(luaBehaviour, "Fill", "a_rw_jindu_lv", "main_ui")
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "finish_text", true)
                UIUtil.setObjectVisible(obj.transform, true, "reward_btn")
                --UIUtil.setObjectVisible(obj.transform, true, "slider")
				data.data.quest_status = 2
				self:updateLoopScroll()
                break
            end
            local ratio = data.count_down / (data.cfg.duration_time * 60)
            fill.fillAmount = 1 - ratio
            LuaBehaviourUtil.setImg(luaBehaviour, "Fill", "a_rw_jindu_cheng", "main_ui")
            tim_text.text = GameUtil:formatTimeBySecond(data.count_down ,999)
            UIUtil.setObjectVisible(obj.transform, true, "time_text")
            --UIUtil.setObjectVisible(obj.transform, true, "slider")
        end
    end
end

-- function M:switchTabNode(index)
-- 	self.m_model.m_open_tab_index = index
-- 	-- for k,v in pairs(__TAB_BTN_NODE) do
-- 	-- 	local cur_tab_text = self:findText(v.btn_text)
-- 	-- 	cur_tab_text.color = index == k and GlobalConfig.COMMON_COLLOR.COMMON_1 or GlobalConfig.COMMON_COLLOR.COMMON_3
-- 	-- 	local outline_width = index == k and 2 or 0
-- 	-- 	UIUtil.setOutlineExEffectColor(cur_tab_text, nil, GlobalConfig.COMMON_COLLOR_OUTLINE.COMMON_3, outline_width)
-- 	-- 	local red_flag = RedPointUtil:hasRedPointById(v.red_point_id)
-- 	-- 	self:setObjectVisible(v.red_point, red_flag == true)
-- 	-- end

-- 	self:updateLoopScroll()
-- end
-- --[[
-- 	创建列表
-- ]]
-- --初始化队伍界面
-- function M:initialHeroData(data)
--     for k,v in pairs(self.m_model.m_data.station_list) do
--     	if data.building_id == v.building_id then
--     		for k1,v1 in pairs(v.team) do
--            		self:initialHeroView(k1,v1[1])
--         	end
--     	end

--     end
-- end

-- function M:updateLoopScroll()
-- 	self.m_cell_tab = {}
-- 	local data = self.m_model.m_show_data
-- 	self.m_select_index = -1
-- 	TEST_TASK_LIST = {}
-- 	if self.m_loop_scroll_view == nil then
-- 		local loopscroll = self:findGameObject("loopscroll")
-- 		local params = {
-- 			show_data = data,
-- 			one_line_count = 1,
-- 			loop_scroll_object = loopscroll,
-- 			update_cell = function(index, cell_object, cell_data)
-- 			table.insert(TEST_TASK_LIST, {data = cell_data, obj = cell_object})
-- 				local transform = cell_object.transform
-- 				self.m_cell_tab[index] = cell_object
-- 				local data = cell_data
-- 				local is_new = nil
-- 				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)

-- 			end,
-- 			click_func = function(index, cell_object, cell_data, click_object, click_name)

-- 					if click_name == "dispatch_btn" then
-- 						self:updateMsg("dispatch_btn",{reward = cell_data.cell_data.reward , id = cell_data.id})

-- 					elseif click_name == "chakan_btn" then

-- 						self:updateMsg("chakan_btn",{cell_data = cell_data})
-- 					else

-- 						self:updateMsg("select_Item_click", {index = index, cell_data = cell_data})
-- 					end

-- 			end,
-- 			ui_name = self.m_uiName
-- 		}
-- 		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
-- 		--self:runCellAnim()
-- 	else
-- 		self.m_loop_scroll_view:reloadData(data)
-- 	end
-- end

--

function M:destroy()
    M.super.destroy(self)
end

return M
