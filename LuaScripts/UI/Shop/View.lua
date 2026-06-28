---@class ShopView:OOPopBase
---@field m_model ShopModel
---@field m_attr_node CommonAttrNode
local M = class("ShopView",LikeOO.OOPopBase)

M.m_uiName = "Shop/Shop"
M.m_size_type = 1
M.m_iphoneXAdapter = true
local __RACE_TAB_BTN_NODE = GlobalConfig.RACE_TAB_BTN_NODE

function M:onEnter()
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 2})
    self.m_attr_node:setBGVisible(false)
	self.m_toggle_btns = {}
    local show_btns_count = 0
    local tabBtns=self.m_model:getTabBtnNode()

    local max=#tabBtns
    local cur_vertical_index=0
    for k = 1, max do
        local v=tabBtns[k]
        -- local t_word = string.cutText(Language:getTextByKey(v.text_key))
        -- self:setText(v.btn_text, table.concat(t_word,"\n"))
        if self.m_model.m_shop_name and self.m_model.m_shop_name[tostring(v.shop_type)] then
            self:setTextByLanKey(v.btn_text, self.m_model.m_shop_name[tostring(v.shop_type)])
        else
            self:setTextByLanKey(v.btn_text, v.text_key)

        end
        local tog_btn = self:findToggle(v.btn_key)
        tog_btn.gameObject:SetActive(v.open)
        self.m_toggle_btns[k] = tog_btn
        UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end, nil, self.m_uiName)
        if k == self.m_model.m_open_tab_index then
            tog_btn.isOn = true
            cur_vertical_index=show_btns_count + 1
        end
        if v.open then
            show_btns_count = show_btns_count + 1
        end
    end
    self.refresh_free_zi_btn = self:findGameObject("refresh_btn_free_zi")
    self.refresh_zi_btn = self:findGameObject("refresh_btn_zi")
    local btns_toggles = self:findGameObject("btns_toggles")
    local btns_content_immediate_comp = btns_toggles:GetComponent("ContentImmediate")
    btns_content_immediate_comp:ForceRefreshSize()
    local buttons_content = self:findRectTransform("buttons_content")
    local btns_content_content_immediate_comp = buttons_content:GetComponent("ContentImmediate")
    btns_content_content_immediate_comp:ForceRefreshSize()
    if self.m_model.m_open_tab_index and show_btns_count > 0 then

        self.m_control:setOnceTimer(0.2,function()
            local btns_scroll_view = self:findGameObject("btns_scroll_view")
            local btns_scroll_view_comp = btns_scroll_view:GetComponent("ScrollRect")
            local pos=1-cur_vertical_index/show_btns_count
            btns_scroll_view_comp.verticalNormalizedPosition = pos
        end)
    end

    self.m_time_text = self:findText("time_text")
    self.m_maze_floor_tips_text = self:findText("maze_floor_tips_text")
    -- local title_text_img = self:findGameObject("title_text_img")
    -- GameUtil:setLanImgText(title_text_img.transform, "ui_txt_shangpu")
    self:setTextByLanKey("time_label_text", "new_str_0030")
    self:setTextByLanKey("close_title_text", "new_str_0371")
    self:setTextByLanKey("refresh_btn_text", "new_str_0439")
    self:setTextByLanKey("fixed_shop_title_text", "new_str_0685")
    self:setTextByLanKey("shop_title_text", "new_str_0684")
    self:setTextByLanKey("tips_text2", "shop_str_001")
    self.material_hui_btn = self:findImage("material_hui_btn")
    self:refreshUI()
    self:switchTabNode(self.m_model.m_open_tab_index)
    self.m_model.m_sel_tab_index = self.m_model.m_open_tab_index
    local des_sp = self:findGameObject("hero_sk")
	GameUtil:updateSpineLoadSet(des_sp, "RoleSpine/hero_0208_SkeletonData", "idle", 0, true)
    for i,v in ipairs(__RACE_TAB_BTN_NODE) do
        if v.btn == "martial_sp_toggle" then
            break
        end
        local tog_btn = self:findToggle(v.btn)
        local lan_text = i > 1 and GlobalConfig.TYPE_HERO_RACE[i-1].name or "new_str_0065"
        self:setTextByLanKey(v.name, lan_text)
        if i == self.m_model.m_select_race_index then
            tog_btn.isOn = true
            UIUtil.setObjectVisible(tog_btn.transform, true,"UI_ShareLv_Xuanze_01")
        else
            UIUtil.setObjectVisible(tog_btn.transform, false,"UI_ShareLv_Xuanze_01")
        end
        UIUtil.addToggleListener(tog_btn, function(is_on, index)
            if is_on then
                self:updateMsg("race_tab_btn", index)
            end
            UIUtil.setObjectVisible(tog_btn.transform, is_on,"UI_ShareLv_Xuanze_01")
        end, i, self.m_uiName)
    end
    self:updateMsg("clearRedPoint")
    if self.m_model.m_shop_type == 28 
            or self.m_model.m_shop_type == 29 
            or self.m_model.m_shop_type == 30 
            or self.m_model.m_shop_type == 31 
            or self.m_model.m_shop_type == 32 
            or self.m_model.m_shop_type == 35 then
        self:setObjectVisible("refresh_node", false)
    else
        self:setObjectVisible("refresh_node", true)    
    end
end

function M:switchTabUpdate(is_on, update_key)
	if is_on then
		self:updateMsg(update_key)
	end
end

function M:refreshUI()
    local data = RewardUtil:getProcessRewardData(self.m_model:getRefreshCost())
    self:setImg(data.icon_name, data.atlas_name or "item_icon", "money_img")
    self:setTextByLanKey("money_text", data.data_num)
    --快速导航
    self:setObjectVisible("guide_btn", true)
end

function M:setTimeText()
    if self.m_model.m_shop_type == 34 then
        local time = self.m_model:getGuildHighShopTime(295)
        self:setObjectVisible("time_text",time>0)
        local ft = GameUtil:formatTimeBySecond(time)
        self.m_time_text.text = Language:getTextByKey("guild_high_war_new_0048", ft)
    else
        local time = self.m_model:getRefreshRemainingTime()
        self:setObjectVisible("time_text",time>0)
        if time>0 then
            local ft = GameUtil:formatTimeBySecond(time)
            self.m_time_text.text = Language:getTextByKey("new_str_0879", ft)
        end

    end
end

function M:setMazeFloorTimeText()
    local time = self.m_model:getPeddlerNextTime()
    local ft = GameUtil:formatTimeBySecond(time)
    self.m_maze_floor_tips_text.text = Language:getTextByKey("new_str_0809", ft)
end

function M:switchTabNode(index, reset_race)
    self.loop_score_sequence = Tweening.DOTween.Sequence()
    self.sequence_time = 0
    local show_tips = true
    local shop_type = 1
    for k,v in pairs(self.m_model:getTabBtnNode()) do
        local sel_flag = k == index
        local cur_tab_text = self:findText(v.btn_text)         
        cur_tab_text.color = sel_flag and Color( 81/255, 52/255, 33/255) or Color( 163/255, 155/255, 132/255)         
        --local outline = UIUtil.findOutlineExt(cur_tab_text)
        if sel_flag then
            if v.open_condition_id == 146 then
                local version = UserDataManager:getOpenActiveVersion(140)
                StatisticsUtil:doPointActive(v.open_condition_id,version)
            end
            show_tips = v.show_tips
            shop_type = v.shop_type
            self:setObjectVisible("refresh_btn", v.show_refresh_btn ~= false)
            self:setTextByLanKey("common_no_have_text", v.shop_type == 5 and "new_str_0613" or "new_str_0351")
            local attr_node = v.attr_mode or self.m_model.m_shop_type
            if v.season_attr_mode and v.season_show_id then
                local open_season = ConfigManager:getCommonValueById(v.season_show_id,1)
                local cur_season = UserDataManager:getCurSeason()
                if cur_season >= open_season then
                    attr_node = v.season_attr_mode
                end
            end
            self.m_attr_node:changeAttrsByMode(attr_node)
            self:setTextByLanKey("fixed_shop_title_text", v.fix_shop_name or "new_str_0685")
            self:setTextByLanKey("shop_title_text", v.text_key)
            if v.fixed_tips_key then
                self:setTextByLanKey("tips_text3", v.fixed_tips_key)
            else
                self:setTextByLanKey("tips_text3", "new_str_0683", Language:getTextByKey(v.text_key))
            end
            self:setObjectVisible("race_toggle", v.show_select_race == true)
            self:setObjectVisible("select_race_bg", v.show_select_race == true)
            local show_shop_scroll = true
            if v.show_shop_scroll ~= nil then
                show_shop_scroll = v.show_shop_scroll
            end
            self:setObjectVisible("shop_huojia_bg", show_shop_scroll)
            self:setObjectVisible("shop_loopscroll", show_shop_scroll)
            self:setObjectVisible("hunt_treasures_loopscroll", not show_shop_scroll)
            
            if v.shop_type == 1 then
                local need_refresh_time, show_item = self.m_model:getOrdinaryShopRefreshTips()
                self:setTextByLanKey("ordinary_tips_text", "new_str_0876", need_refresh_time)
                if show_item then
                    local ordinary_tips_item = self:findRectTransform("ordinary_tips_item")
                    UIUtil.destroyAllChild(ordinary_tips_item)
                    local item = GameUtil:createItemElement(show_item, true, true)
                    item.transform:SetParent(ordinary_tips_item, false)
                end
                self:setObjectVisible("ordinary_tips_node", need_refresh_time > 0)
            else
                self:setObjectVisible("ordinary_tips_node", false)
            end
        end
    end
    self:refreshRedPoint()

    self:refreshRefreshRemainingTime()
    local tips_msg = self.m_model:getTipsMsg()
    self:setText("tips_text", tips_msg)
    self:setObjectVisible("tips_node", tips_msg ~= "" and show_tips == true)
    if reset_race and self.m_model.m_select_race_index ~= 1 then -- 重置到全部
        local tog_btn = self:findToggle(__RACE_TAB_BTN_NODE[1].btn)
        if tog_btn then
            tog_btn.isOn = true
        end
    else
        if self.m_model:checkIsHunt(shop_type) then
            self:refreshHuntLoopScroll()
        else
            self:refreshShopLoopScroll()
        end
    end
    if reset_race == true then
        if self.m_loop_scroll_view ~= nil then
            self.m_loop_scroll_view:moveToCellIndex(1)
        elseif self.m_hunt_treasures_loop_scroll_view ~= nil then
            self.m_hunt_treasures_loop_scroll_view:moveToCellIndex(1)
        end
    end
    local free_refresh_flag, free_count = self.m_model:getFreeRefreshFlag()
    local refresh_free_zi = false
    local refresh_zi = false
    if free_refresh_flag then
        self:setTextByLanKey("refresh_btn_text", "new_str_0878", free_count)
        refresh_free_zi = true
    else
        self:setTextByLanKey("refresh_btn_text", "new_str_0877")
        refresh_zi = true
    end
    self.refresh_free_zi_btn.gameObject:SetActive(refresh_free_zi)
    self.refresh_zi_btn.gameObject:SetActive(refresh_zi)
    self:refreshMazeFloorTips()
    if self.m_model.m_shop_type == 28 
            or self.m_model.m_shop_type == 29
            or self.m_model.m_shop_type == 30 
            or self.m_model.m_shop_type == 31 
            or self.m_model.m_shop_type == 32 
            or self.m_model.m_shop_type == 35 then
        self:setObjectVisible("refresh_node", false)
    else
        self:setObjectVisible("refresh_node", true)    
    end
end

function M:refreshRefreshRemainingTime()
    local time = self.m_model:getRefreshRemainingTime()
    local function tick(event, dt, remaining_time)
        self:setTimeText()
        if remaining_time <= 0 then
            --self:updateMsg("refresh")
        end
    end
    EventDispatcher:registerTimeEvent("ShopViewTime", tick, 1, time < 1 and 1 or time)
    self:setTimeText()
end

function M:refreshMazeFloorTips()
    local cur_shop_data = self.m_model:getCurShopData()
    if self.m_model.m_shop_type == 4 and cur_shop_data.show_shop_tips then -- 迷宫商店中的狐仙商人重置时间
        self.m_maze_floor_tips_text.gameObject:SetActive(true)
        local time = self.m_model:getRefreshRemainingTime()
        local function tick(event, dt, remaining_time)
            self:setMazeFloorTimeText()
            if remaining_time <= 0 then
                self:updateMsg("refresh")
            end
        end
        EventDispatcher:registerTimeEvent("MazeFloorShopViewTime", tick, 1, time < 1 and 1 or time)
        self:setMazeFloorTimeText()
    else
        EventDispatcher:unRegisterEvent("MazeFloorShopViewTime")
        self.m_maze_floor_tips_text.gameObject:SetActive(false)
    end
end

--[[
	创建商店列表
]]
function M:refreshShopLoopScroll()
    local data = self.m_model:getShowData()
    self:setObjectVisible("CommonTipsNode", #data == 0)
    if self.m_model.m_shop_type == 5 and #data == 0 then
        self:setObjectVisible("tips_node", false)
    end
    self.shop_items = {}
    self:setObjectVisible("mask_img", #data == 0)
    local loopscroll = self:findGameObject("shop_loopscroll")
    local fixed_shop_node = self:findGameObject("fixed_shop_node")
    local loopscroll_rt = UIUtil.findRectTransform(loopscroll)
    local fixed_shop_node_visible = fixed_shop_node.activeSelf
    local height = fixed_shop_node_visible and 346 or 520
    loopscroll_rt.sizeDelta = Vector2(loopscroll_rt.rect.width, height)
    self.m_temp_data = data
    if self.m_loop_scroll_view == nil then
		local params = {
			show_data = data,
			one_line_count = 4,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
                self.shop_items[cell_object] = index
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, {index = index, cell_data = cell_data})
			end,
            ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
        self.m_loop_scroll_view.m_scroll_rect.onValueChanged:AddListener(handler(self, self.onValueChanged))
	else
		self.m_loop_scroll_view:reloadData(data,true)
	end
    self:updateJianTou()
end

function M:onValueChanged(pos)
    self:updateJianTou()
end


--[[
	创建苗疆商店列表
]]
function M:refreshHuntLoopScroll()
    local data = self.m_model:getShowData()
    self:setObjectVisible("CommonTipsNode", #data == 0)
    if self.m_model.m_shop_type == 5 and #data == 0 then
        self:setObjectVisible("tips_node", false)
    end
    self:setObjectVisible("mask_img", #data == 0)
    if self.m_model.m_shop_type == 28 or self.m_model.m_shop_type == 29 or self.m_model.m_shop_type == 30 or self.m_model.m_shop_type == 31 or self.m_model.m_shop_type == 35 then
        self:setObjectVisible("refresh_node", false)
    else
        self:setObjectVisible("refresh_node", true)    
    end
    if self.m_hunt_treasures_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("hunt_treasures_loopscroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index,cell_object,cell_data)
                self:updateHuntTreasuresScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index,cell_object,cell_data,click_object,click_name)
                local remain_num = cell_data.data.max_purchase_time - cell_data.data.cur_purchased_time
                cell_data.data.remain = remain_num
                if self.m_model.m_refresh_flag then
                    self.m_model.m_refresh_flag = false
                end
                if self.m_model.m_shop_type == 31 then
                    local exchange_is_ok = 0
                    local remain_num = cell_data.data.max_purchase_time - cell_data.data.cur_purchased_time
                    local reward_left = cell_data.data.sell or {}
                    for i, v in ipairs(reward_left) do
                        local coin_data =  RewardUtil:getProcessRewardData(v)
                        if coin_data.user_num < coin_data.data_num and exchange_is_ok == 0 then
                            exchange_is_ok = 1
                        end
                    end
                    if exchange_is_ok == 1 then 
                        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("compass_str_002"), delay_close = 2})
                        return
                    end
                end
                self:updateMsg("shop_buy_btn", {index = index, cell_data = cell_data})
            end
        }
        self.m_hunt_treasures_loop_scroll_view = LoopScrollViewUtil.new(params)
        self.m_hunt_treasures_loop_scroll_view.m_scroll_rect.onValueChanged:AddListener(handler(self, self.onValueChanged))
    else
        self.m_hunt_treasures_loop_scroll_view:reloadData(data,true)
    end
    self:updateJianTou()
end

--设置苗疆商店数据
function M:updateHuntTreasuresScrollViewCell(index,cell_object,cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local transform = cell_object.transform
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_get_text", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "hunt_treasures_buy_btn", true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "remain_time", true)
    --兑换商品货物
    local reward_left = cell_data.data.sell or {}
    local reward_left_node = luaBehaviour:FindGameObject("consume_content")
    GameUtil:createRewards(reward_left_node.transform,reward_left,true,true,nil,1)
    --设置剩余文本
    local remain_num = cell_data.data.max_purchase_time - cell_data.data.cur_purchased_time
    local remain_text = Language:getTextByKey("castingSword_str_0031",remain_num)
    UIUtil.setTextByLanKey(transform,"remain_time", remain_text) 
    --设置兑换按钮文字
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "hunt_treasures_buy_text", "castingSword_str_0030")
    --兑换到的商品
    local reward_right_node = luaBehaviour:FindGameObject("obtain_img")
    UIUtil.destroyAllChild(reward_right_node.transform)
    local item = GameUtil:createItemElement(cell_data.data.item, true, true) 
    item.transform:SetParent(reward_right_node.transform, false)
    --设置兑换按钮状态
    local hunt_treasures_buy_btn = luaBehaviour:FindImage("hunt_treasures_buy_btn")
    local cur_tab_text = luaBehaviour:FindText("hunt_treasures_buy_text")
    local outline = UIUtil.findOutlineExt(cur_tab_text)
    local exchange_is_ok = 0
    for i, v in ipairs(reward_left) do
        local coin_data =  RewardUtil:getProcessRewardData(v)
        if coin_data.user_num < coin_data.data_num and exchange_is_ok == 0 then
            exchange_is_ok = 1
        end
    end
    local outline_width = 1
    if remain_num == 0 or exchange_is_ok == 1 then
        hunt_treasures_buy_btn.material = self.material_hui_btn.material
        outline_width = 0
    else
        hunt_treasures_buy_btn.material = nil
    end
    UIUtil.setOutlineExEffectColor(cur_tab_text, nil, outline.OutlineColor, outline_width)
    if self.m_model.m_shop_type == 31 then
        local hv_skin = self.m_model:getHeroSkins(cell_data.item_data.data_id)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "hunt_treasures_buy_btn", not hv_skin)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "remain_time", not hv_skin)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_get_text", hv_skin)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_get_text", "new_str_0841")
    end
end

--[[
	创建固定商店列表
]]
--function M:refreshFixedShopLoopScroll()
--    local data = self.m_model:getShowData(1)
--    self:setObjectVisible("fixed_shop_node", #data > 0)
--    if self.m_fixed_loop_scroll_view == nil then
--        local loopscroll = self:findGameObject("fixed_shop_loopscroll")
--        local params = {
--            show_data = data,
--            one_line_count = 4,
--            loop_scroll_object = loopscroll,
--            update_cell = function(index, cell_object, cell_data)
--                self:updateScrollViewCell(index, cell_object, cell_data)
--            end,
--            click_func = function(index, cell_object, cell_data, click_object, click_name)
--                self:updateMsg(click_name, {index = index, cell_data = cell_data})
--            end,
--            ui_name = self.m_uiName
--        }
--        self.m_fixed_loop_scroll_view = LoopScrollViewUtil.new(params)
--    else
--        self.m_fixed_loop_scroll_view:reloadData(data)
--    end
--end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    --local transform = cell_object.transform
    local data = cell_data
    --local item = data.data.item
    local sell = data.data.sell
    local remain = data.data.remain or 0
    local sell_count = data.data.num or 0 --售卖的总数
    local discount = data.data.discount or 0
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local node = luaBehaviour:FindGameObject("node")
    local cost_node = luaBehaviour:FindGameObject("cost_node")
    local item_node = UIUtil.findTrans(node.transform, "item_node")
    UIUtil.destroyAllChild(item_node)
    local item_data = data.item_data
    UIUtil.setText(cost_node.transform, "×" .. tostring(item_data.data_num), "reward_num")
    --UIUtil.setText(node.transform, "×" .. tostring(item_data.data_num), "cost_node/reward_num")
    local reward_inst, ui_element = GameUtil:createItemElementByData(item_data, true, true)
    local item_btn = UIUtil.findButton(reward_inst.transform)
    item_btn.enabled = false
    reward_inst.transform:SetParent(item_node, false)
    --local item_reward_data = RewardUtil:getProcessRewardData(item)
    local cost_data = RewardUtil:getProcessRewardData(sell)
    local cost_str = GameUtil:formatValueToString(cost_data.data_num)
    local cost_num_text = UIUtil.setText(cost_node.transform, cost_str, "cost_num_text")
    --local cost_num_text = UIUtil.setText(node.transform, cost_str, "cost_node/cost_num_text")
    cost_num_text.color = cost_data.data_num > cost_data.user_num and GlobalConfig.COMMON_COLLOR.COMMON_11 or Color.New(255 / 255, 255 / 255, 255 / 255)
    UIUtil.setImg(cost_node.transform, cost_data.icon_name, "item_icon", "cost_img")
    --UIUtil.setImg(node.transform, cost_data.icon_name, "item_icon", "cost_node/cost_img")
    
    local open_flag, tips_str = self.m_model:getShopCellOpenFlag(cell_data)
    UIUtil.setObjectVisible(node.transform, remain < 1 or false, "sell_max_node")
    UIUtil.setTextByLanKey(node.transform, "sell_max_node/sell_max_text", open_flag and "new_str_0095" or "worldMap_str_004")
    local cost_node_fitter = cost_node:GetComponent("ContentImmediate")
    if cost_node_fitter then
        cost_node_fitter:ForceRefreshSize()
    end
    local sell_max_img = UIUtil.findImage(node.transform, "sell_max_node")
    if remain < 1 or not open_flag then
        ui_element.item_img.material = sell_max_img.material
        ui_element.quality_img.material = sell_max_img.material
    else
        ui_element.item_img.material = nil
        ui_element.quality_img.material = nil
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "limit_text", sell_count > 1)
    if sell_count > 1 then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "limit_text", "new_str_0693", remain)
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cost_node", open_flag)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cost_di", open_flag)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unlock_text", not open_flag)
    local show_type = self.m_model:isLimit(cell_data)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "limit_img", show_type > 0)
    if show_type > 0 then
        local img_name = ""
        --争锋联赛
        if self.m_model.m_shop_type == 37 then
            img_name = "a_sh_zfliansai"..show_type
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "limit_text",open_flag and sell_count > 1)
        else
            if show_type == 1 then
                img_name = "a_sh_tianjisaixianding"
            elseif show_type == 2 then
                img_name = "a_sh_wuxingliansaixianding"
            elseif show_type == 3 then
                img_name = "a_sh_qimendunjia"
            elseif show_type == 4 then
                img_name = "a_sh_huashanlunjian"
            end
        end
        LuaBehaviourUtil.setImg(luaBehaviour,"limit_img", img_name,  "language_zh_cn")

        if self.m_model.m_shop_type == 37 then
            local img=luaBehaviour:FindImage("limit_img")
            img:SetNativeSize()
        end
    end
    UIUtil.setObjectVisible(node.transform, remain < 1 or not open_flag, "mask_Img")
    UIUtil.setObjectVisible(node.transform, remain < 1 or not open_flag, "discount_img")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "unlock_text", tostring(tips_str))
    UIUtil.setObjectVisible(node.transform, discount < 100, "discount_img")
    local format_srt = discount%10 == 0 and "%.0f" or "%.1f"
    UIUtil.setTextByLanKey(node.transform, "discount_img/discount_num_text", string.format(format_srt, discount/10))
    UIUtil.setTextByLanKey(node.transform, "discount_img/discount_text", "new_str_0096")
    if item_data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
        local hero_ids = data.hero_ids
        UIUtil.setObjectVisible(node.transform, #hero_ids > 0 and remain > 0, "red_point_img")
    else
        UIUtil.setObjectVisible(node.transform, false, "red_point_img")
    end
    
    --self:updateJianTou()
    if cost_data.data_type == RewardUtil.REWARD_TYPE_KEYS.COIN then
        if remain < 1 or not open_flag then
            UIUtil.setObjectVisible(node.transform, false, "red_point_img")
        else
            UIUtil.setObjectVisible(node.transform, true, "red_point_img")
        end
    end
end

function M:updateJianTou()
    local loop_view = self.m_loop_scroll_view
    local loop_view_num = 3
    if self.m_model:checkIsHunt(self.m_model.m_shop_type) == true then
        loop_view = self.m_hunt_treasures_loop_scroll_view
        loop_view_num = 4
    end
    if loop_view and loop_view.m_line_count > loop_view_num then
        if loop_view:getVerticalNormalizedPosition() < 0.1 then
            self:setObjectVisible("jiantou_img", false)
        else
            self:setObjectVisible("jiantou_img", true)
        end
        if loop_view:getVerticalNormalizedPosition() > 0.9 then
            self:setObjectVisible("jiantou_top_img", false)
        else
            self:setObjectVisible("jiantou_top_img", true)
        end
    else
        self:setObjectVisible("jiantou_img", false)    
        self:setObjectVisible("jiantou_top_img", false)  
    end
end

function M:refreshRedPoint()
    for k,v in pairs(self.m_model:getTabBtnNode()) do
        if v.red_point_id and v.red_point_img then
            local red_flag = RedPointUtil:hasRedPointById(v.red_point_id)
            self:setObjectVisible(v.red_point_img, red_flag == true)
        end
    end
end

function M:destroy()
	EventDispatcher:unRegisterEvent("MazeFloorShopViewTime")
	EventDispatcher:unRegisterEvent("ShopViewTime")
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end

return M