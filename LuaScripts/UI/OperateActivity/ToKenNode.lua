local M = class("ToKenNode", LikeOO.OOUIbase)
--战令
M.m_uiName = "OperateActivity/ToKenNode"

function M:onEnter()
    self.m_content_panel = self:findGameObject("parent_obj")
    self.gray_img = self:findImage("gray_img")
    self.next_big_id = 0
    self:setTextByLanKey("dengji_text", "dengji_tex")
    self:setTextByLanKey("buyl_btn_text", "buy_royal_btn_tex")
    self:setTextByLanKey("Text", "hd_jingyan_tex")
    self:setTextByLanKey("buy_text", "buy_tex")
    self:setTextByLanKey("get_reward_text", "get_reward_tex")
    self:setTextByLanKey("quick_buy_btn_text", "mail_str_0017")
    self:setTextByLanKey("desc_text", "token_des")
    self:setTextByLanKey("common_zl_text", "common_zl_tex")
    self:setTextByLanKey("common_gj_text", "common_gj_tex")
    self:setTextByLanKey("buy_hight_text", "buy_hight_tex")
    
    self:setObjectVisible("quick_buy_btn", false)
    self:setObjectVisible("go_to", false)
end

function M:switchInit(url, data, id, callback)
    local function callFunc(data)
        if callback then
            callback(data)
        end
        self:refreshUI()
        if self.m_scroll_view ~= nil then
            local index = self:getTokenSelect()
            self.m_scroll_view:moveToCellIndex(index)
        end
        if self.m_scroll_view2 ~= nil then
            local index = self:getTokenSelect()
            self.m_scroll_view2:moveToCellIndex(index)
        end
        
    end
    self.c_sort = data -- 80:武林行侠令,  109:江湖行侠令  452 侠客岛令
    self.m_model:initData(url, callFunc)
end

function M:switchUI(data)
    self.c_sort = data -- 80:武林行侠令,  109:江湖行侠令  452 侠客岛令
    self:refreshUI()
    if self.m_scroll_view ~= nil then
        local index = self:getTokenSelect()
        self.m_scroll_view:moveToCellIndex(index)
    end
    if self.m_scroll_view2 ~= nil then
        local index = self:getTokenSelect()
        self.m_scroll_view2:moveToCellIndex(index)
    end
end

function M:refreshUI()
    local token_data = self.m_model.m_war_older_data 
    if token_data == nil then
        return
    end
    self:setObjectVisible("quick_buy_btn", true)
    self:setObjectVisible("go_to", true)

    self.m_open_status = token_data.is_open --(1开启, 0未开启)
    self.m_token_nums = token_data.num --# 代币数量
    self.m_end_ts = token_data.end_ts --结束时间戳
    self.m_free_received = token_data.free_received --已领免费奖励id数组
    self.m_pay_received = token_data.pay_received --已领付费奖励id数组
    self.m_pay_status = token_data.payment_status --购买令牌状态(1开启, 0未开启)
    self.m_token_lv = token_data.lv --令牌等级
    self.m_c_lv = self.m_model:getRoyalShowLv(self.c_sort )

    self.m_vsn = token_data.vsn
    local war_order_tab = self.m_model:get_war_order(self.c_sort)
    self:setTextByLanKey("desc2_text", war_order_tab.name)
    self:setTextByLanKey("rank_lv", "gf_str_0060",self.m_token_lv)
    self.lv = self.m_model:getRoyalShowLv(self.c_sort)
    local token_tab = self.m_model:get_royal_cfg(self.c_sort)
    self.max_lv = #token_tab or 30
    self:setObjectVisible("loopscroll",self.m_pay_status == 0)
    self:setObjectVisible("loopscroll_get",self.m_pay_status == 1)
    if self.m_pay_status == 0 then
        self:createLoopScroll()
    else
        self:createLoopScroll2()
    end
    self:setTextByLanKey("lv_text", self.m_c_lv)
    self:updateTime()
    local c_num, max_num = self.m_model:getTokenSlider(self.c_sort, self.m_c_lv)
    self:setTextByLanKey("slider_text", c_num.."/"..max_num)
    local slider_img = self:findSlider("slider_bg")
    slider_img.value = c_num/max_num
    self:setObjectVisible("hight_node", self.m_pay_status == 0)

	local show_price = GameUtil:getMoneyTypeNum(war_order_tab.price).. Language:getTextByKey("new_str_0037")
	self:setTextByLanKey("buy_royal_btn_text", show_price)
    local reward_all = self.m_model:getAllReward(self.m_c_lv,self.c_sort)
    local reward_can_get = self.m_model:getCanHaveReward(self.m_c_lv,self.c_sort)
    local reward_2 = self:findGameObject("reward_2")
    local reward_2_rect = reward_2:GetComponent("reward_2")
    if #reward_can_get >= 4 then
        reward_2.transform.pivot = Vector2(0,0.5)
    else
        reward_2.transform.pivot = Vector2(0.5,0.5) 
    end
    local reward_1 = self:findGameObject("reward_1")
	local reward_2 = self:findGameObject("reward_2")
    UIUtil.destroyAllChild(reward_1.transform)
    UIUtil.destroyAllChild(reward_2.transform)
	for i,v in pairs(reward_all) do
		local itemNode = GameUtil:createItemElement(v, true, true)
        UIUtil.setScale(itemNode.transform,0.8)
		itemNode.transform:SetParent(reward_1.transform, false)
	end
	for i,v in pairs(reward_can_get) do
		local itemNode = GameUtil:createItemElement(v, true, true)
        UIUtil.setScale(itemNode.transform,0.8)
		itemNode.transform:SetParent(reward_2.transform, false)
	end
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    self.m_gift_tab = {}
    self.m_obj_tab = {}
    self.cur_cfg_tab = self.m_model:get_royal_cfg(self.c_sort)
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll") 
        local params ={
            show_data = self.cur_cfg_tab,
            loop_scroll_object = loopscroll,
			update_cell =function(index, cell_obj, cell_data)
				self.m_gift_tab[index] = cell_obj
                self.m_obj_tab[cell_obj] = index
                self:getNextBigReward()
                self:update_Gift(index, cell_obj, cell_data)
            end,
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
    	self.m_scroll_view:reloadData(self.cur_cfg_tab, true)
    end 
end

function M:createLoopScroll2()
    self.m_gift_tab = {}
    self.m_obj_tab = {}
    self.cur_cfg_tab = self.m_model:get_royal_cfg(self.c_sort)
    if self.m_scroll_view2 == nil then
        local loopscroll = self:findGameObject("loopscroll_get") 
        local params ={
            show_data = self.cur_cfg_tab,
            loop_scroll_object = loopscroll,
			update_cell =function(index, cell_obj, cell_data)
				self.m_gift_tab[index] = cell_obj
                self.m_obj_tab[cell_obj] = index
                self:getNextBigReward()
                self:update_Gift(index, cell_obj, cell_data)
            end,
        }
        self.m_scroll_view2 = LoopScrollViewUtil.new(params)
    else
    	self.m_scroll_view2:reloadData(self.cur_cfg_tab, true)
    end 
end

function M:update_Gift(index, cell_obj, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    local free_data = self.m_model:getReceived(self.c_sort, index)
    local pay_data = self.m_model:getPayReceived(self.c_sort, index)
    local num = luaBehaviour:FindText("lv_title_text")
    num.text = index..Language:getTextByKey("new_str_0428") 
    local royal_tab = self.m_model:get_royal_cfg(self.c_sort)
    local free_obj = luaBehaviour:FindGameObject("free_prent")
    local pay_obj = luaBehaviour:FindGameObject("pay_prent")
    UIUtil.destroyAllChild(free_obj.transform)
    UIUtil.destroyAllChild(pay_obj.transform)
    --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_lv_bg", index == self.m_c_lv)
    local function callback(obj, data)
        if free_data == false then
            if self.m_token_nums >= cell_data.condition then
                self:getReward(index)
            end
        end
    end
    local function callback2(obj, data)
        if self.m_pay_status == 1 and pay_data == false then
            if self.m_token_nums >= cell_data.condition then
                self:getReward(index)
            end
        end
    end
    local can_click = true
    if self.m_token_nums >= cell_data.condition and free_data == false then
        can_click = false
    end
    local pay_click = true
    if self.m_token_nums >= cell_data.condition and pay_data == false and self.m_pay_status == 1  then
        pay_click = false
    end
    local freeItems = self:creatRewards(free_obj.transform, cell_data.free_reward, true, can_click, callback, 0.8)
    local payItems = self:creatRewards(pay_obj.transform, cell_data.fee_incentives, true, pay_click, callback2, 0.8)
    for i,v in ipairs(freeItems) do
        local ItemluaBehaviour = UIUtil.findLuaBehaviour(v)
        if free_data == false then
            --未领过
            if self.m_token_nums >= cell_data.condition then
                local r_data = RewardUtil:getProcessRewardData(cell_data.free_reward[i]) 
                GameUtil:creatCommonItemEffect(v, r_data.quality)
            else
                if ItemluaBehaviour then
                    LuaBehaviourUtil.setObjectVisible(ItemluaBehaviour, "lock_image", true)
                end
            end
        else
            --已领过
            if ItemluaBehaviour then
                LuaBehaviourUtil.setObjectVisible(ItemluaBehaviour, "duigoudi_img", true)
            end
        end
    end
    for i,v in ipairs(payItems) do
        local ItemluaBehaviour = UIUtil.findLuaBehaviour(v)
        if index%5 == 0 or index == 1 then
            local dataTable = cell_data.fee_incentives[i]
            local data = RewardUtil:getProcessRewardData(dataTable)
            GameUtil:creatCommonActiveEffect(v, data.quality)
        end
        if  self.m_pay_status == 0 then
            if ItemluaBehaviour then
                LuaBehaviourUtil.setObjectVisible(ItemluaBehaviour, "lock_image", true)
            end
        else
            if pay_data == false then
                --未领过
                if self.m_token_nums >= cell_data.condition then
                   local r_data = RewardUtil:getProcessRewardData(cell_data.fee_incentives[i]) 
                   GameUtil:creatCommonItemEffect(v, r_data.quality)
                else
                    if ItemluaBehaviour then
                        LuaBehaviourUtil.setObjectVisible(ItemluaBehaviour, "lock_image", true)
                    end 
               end
           else
               if ItemluaBehaviour then
                   LuaBehaviourUtil.setObjectVisible(ItemluaBehaviour, "duigoudi_img", true)
               end
           end
        end
       
    end
end

function M:getReward(index)
    if self.c_sort == 80 then
        self:updateMsg("get_royal_reward", {id = index, vsn =self.m_vsn})
    elseif self.c_sort == 109 then
        self:updateMsg("get_warrior_reward", {id = index, vsn =self.m_vsn})
    else
        self:updateMsg("get_goal_common_reward", {reward_id = index, vsn =self.m_vsn, open_id = self.c_sort})
    end
end

function M:getNextBigReward()
    local tab_big = 0
    local next_big = 0
    for k,v in pairs(self.m_obj_tab) do
        if v > tab_big then
            tab_big = v
        end
    end
    if tab_big >= #self.cur_cfg_tab then
        next_big = #self.cur_cfg_tab
    else
        for i = tab_big + 1, #self.cur_cfg_tab do
            if i%5 == 0 then
                next_big = i
                break
            end  
        end
    end
    if self.next_big_id == next_big or next_big <= 5 then
        return
    else
        self.next_big_id = next_big
        local next_obj = self:findGameObject("next_big")
        self:update_Gift(self.next_big_id, next_obj, self.cur_cfg_tab[self.next_big_id])
    end
end

function M:onButtonClick(obj, name)
    if name == "quick_buy_btn" then
        if self:checkCanQuickGet() == true then
            if self.c_sort == 80 then
                self:updateMsg("getall_royal", self.m_vsn)
            elseif self.c_sort == 109 then
                self:updateMsg("getall_warrior", self.m_vsn)
            else
                self:updateMsg("getall_goal_common", {open_id = self.c_sort, vsn = self.m_vsn})
            end
        else
            GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_0937"), delay_close = 2})
        end
        audio:SendEvtUI("Ui_NormalClick")
    elseif name == "buy_height_royal_btn" then --购买高级战令
        local war_order_cfg = self.m_model:get_war_order(self.c_sort)
        self:updateMsg("buy_high_token", war_order_cfg.charge_id)
    elseif name == "buy_level_btn" then
        if self.m_c_lv >= self.max_lv then
            GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0133"), delay_close = 2})
            return 
        end 
        local params = {
            token_id = self.c_sort,
            lv = self.m_c_lv,
            token_lv = self.m_token_lv,
            vsn = self.m_vsn,
            callback = function ()
                local war_order_cfg = self.m_model:get_war_order(self.c_sort)
                self:updateMsg("buy", war_order_cfg.charge_id )
            end
        }
        self.m_control:openView("OperateActivity.TokenLevelUpPop", params)
    elseif name == "tips_btn" then
        local tab_data = self.m_model:get_royal_cfg(self.c_sort)
        local data = tab_data[1]
        local params = {
            title = data.name1,
            content =  data.name2,
        }
        self.m_control:openView("Pops.CommonHelpPop", params)
        audio:SendEvtUI("Play_UI_Info")
    elseif name == "go_to"  then
        local war_order_tab = self.m_model:get_war_order(self.c_sort)
        static_rootControl:closeAllViewPop()
        local go_type = war_order_tab.go_type or {}
        QuickOpenFuncUtil:openFunc(go_type)
        audio:SendEvtUI("Play_UI_Popup_1")
    else
        M.super.onButtonClick(self, obj, name)
    end
end

function M:creatRewards(reward_node, rewards, is_show_num, is_show_detail, callback, scale, frame_effect)
    local rewards = rewards or {}
    scale = scale or 1
    local itemList = {}
    UIUtil.destroyAllChild(reward_node)
    for k,v in pairs(rewards) do
        local item = GameUtil:createItemElement(v, is_show_num, is_show_detail, callback, frame_effect)   
        item.transform:SetParent(reward_node, false)
        table.insert( itemList, item)
        UIUtil.setScale(item.transform, scale)
    end
    return itemList
end

function M:getTokenSelect(opne_id, version)
    local free_index = self.m_c_lv
    local pay_index = self.m_c_lv
    for i = 1 , self.m_c_lv do
        if self:checkCanGet(i, self.m_free_received) == true then
            free_index = i
            break
        end
    end
    for i = 1 , self.m_c_lv do
        if self:checkCanGet(i, self.m_pay_received) == true then
            pay_index = i
            break
        end
    end
    if self.m_pay_status == 1 then
        return math.min(free_index, pay_index)
    else
        return free_index
    end
end

function M:checkCanGet(lv, tab)
    for k,v in pairs(tab) do
        if v == lv then
            return false
        end
    end    
    return true
end

function M:checkCanQuickGet()
    if self.m_pay_status == 1 then
        for k = 1, self.m_c_lv  do
            if self:checkCanGet(k, self.m_pay_received) == true then
                return true
            end
        end
    end
    for k = 1, self.m_c_lv  do
        if self:checkCanGet(k, self.m_free_received) == true then
            return true
        end
    end
    return false
end


function M:updateTime()
    if self.m_end_ts and self.m_end_ts >= 0 then
        local cur_tim = UserDataManager:getServerTime()
        local tim = self.m_end_ts - cur_tim
        local show_tim = GameUtil:formatTimeBySecond(tim)
        local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(tim)
        self:setObjectVisible("buy_level_btn", day<4)
        if day > 0 then
            self:setTextByLanKey("tim_text", "gf_str_0042", day, hour, min, sec)
        else
            self:setTextByLanKey("tim_text", show_tim)
        end
    else
        self:setTextByLanKey("tim_text", " 00:00:00")
    end 
end

function M:updateActiveEndTs()
    if self.m_end_ts and self.m_end_ts >= 0 then
        if UserDataManager:getServerTime() > self.m_end_ts then
            self.m_end_ts = 0 
            self:updateMsg("buy_sdk_update")
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end


return M
