--- 战令
local M = class("ToKenNode",LikeOO.OOUIbase)

M.m_uiName = "Task/TaskToKenNode"

function M:onEnter()
    self:setTextByLanKey("new_lv_text", Language:getTextByKey("dengji_tex").."：" )
    self:setTextByLanKey("lv_text (1)", Language:getTextByKey("dengji_tex").."：" )
    self:setTextByLanKey("buy_node_title", Language:getTextByKey("get_reward_tex"))
    self:setObjectVisible("normal_node",  false)
    self:refreshData()
end

function M:refreshData(slider_anim)
    self.m_model:getNetData("war_order_valor_index", nil, function(data, tag, status_code)
        self.m_token_data = data
        self.m_open_status = data.is_valor_open --(1开启, 0未开启)
        self.m_token_nums = data.valor_medals or 0--# 代币数量
        self.m_end_ts = data.valor_end_ts --结束时间戳
        self.m_free_received = data.vm_free_received --已领免费奖励id数组
        self.m_pay_received = data.vm_pay_received --已领付费奖励id数组
        self.m_pay_status = data.valor_payment_status --购买令牌状态(1开启, 0未开启)
        self.m_token_lv = data.vm_lv --令牌等级
        self.m_c_lv = self:getRoyalShowLv()
        self:refreshUI(slider_anim)
    end)
end

function M:refreshUI(slider_anim)
    if self.m_token_data == nil or self.m_token_data["end"] == 1 then
        self:setObjectVisible("active_token_btn_red_point", false)
        return
    end
    -- self:setTextByLanKey("lv_text", self.m_c_lv)
    -- local c_num, max_num = self:getTokenSlider()
    -- self:setTextByLanKey("slider_text", c_num.."/"..max_num)
    -- local slider_img = self:findSlider("slider_bg")
    -- local to_value = c_num/max_num
    -- if slider_anim then
    --     if self.m_temp_c_lv ~= self.m_c_lv then
    --         slider_img.value = 0
    --         self.m_temp_c_lv = self.m_c_lv
    --     end
    --     DOTweenModuleUI.DOValue(slider_img, to_value, 0.5)
    -- else
    --     self.m_temp_c_lv = self.m_c_lv
    --     slider_img.value = to_value
    -- end
    self.cur_cfg_tab = self:get_royal_cfg()
    -- self:update_Gift(self.m_c_lv, self.cur_cfg_tab[self.m_c_lv])
    self:setTextByLanKey("quick_buy_btn_text", "gf_str_0115")
    --self:setObjectVisible("active_token_btn", self:checkCanQuickGet() == true)
    self:setObjectVisible("active_token_btn", true)
    self:setObjectVisible("active_token_btn_red_point", self:checkCanQuickGet() == true)
    self:setObjectVisible("buy_node",  self.m_pay_status == 1)
    self:setObjectVisible("normal_node",  self.m_pay_status == 0)
    if self.m_pay_status == 1 then
        self:setHightUI(slider_anim)
    else
        self:setNormalUI(slider_anim)
    end
end

--显示未购买状态的奖励展示
function M:setNormalUI(slider_anim)
    self.cur_cfg_tab = self:get_royal_cfg()
    local cell_data = self.cur_cfg_tab[self.m_c_lv]
    local next_data = self.cur_cfg_tab[self.m_c_lv+1]
    local free_data = self:getReceived(self.m_c_lv) 
    self:setTextByLanKey("normal_node_title2", "gf_str_0123")
    local can_get_normal_rewards = self:getCanGetReward(self.m_c_lv)
    local free_obj = self:findGameObject("normal_free_parent") --可领
    if next(can_get_normal_rewards) == nil and next_data ~= nil then--当前等级已领
        self:setTextByLanKey("normal_node_title", "gf_str_0124")
        self:creatRewards(free_obj.transform, next_data.free_reward,true)
        free_obj.transform.pivot = Vector2(0.5,0.5) 
    elseif next(can_get_normal_rewards) ~= nil then
        self:setTextByLanKey("normal_node_title", "gf_str_0125")
        self:creatRewards(free_obj.transform, can_get_normal_rewards,true)
        if #can_get_normal_rewards >= 4 then
            free_obj.transform.pivot = Vector2(0,0.5)
        else
            free_obj.transform.pivot = Vector2(0.5,0.5) 
        end
    else
        self:setTextByLanKey("normal_node_title", "gf_str_0125")
        local obj_tab = self:creatRewards(free_obj.transform, cell_data.free_reward)  
        for k,v in pairs(obj_tab) do
            local luaBehaviour = UIUtil.findLuaBehaviour(v)
            if luaBehaviour then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", true)
            end
        end
        free_obj.transform.pivot = Vector2(0.5,0.5) 
    end
    local pay_obj = self:findGameObject("normal_pay_parent") --购买可领
    local can_get_reward = self:getCanHaveReward(self.m_c_lv)
    self:creatRewards(pay_obj.transform, can_get_reward, true, true)
    if #can_get_reward >= 4 then
        pay_obj.transform.pivot = Vector2(0,0.5)
    else
        pay_obj.transform.pivot = Vector2(0.5,0.5) 
    end

    self:setTextByLanKey("normal_lv_text", self.m_c_lv)
    local c_num, max_num = self:getTokenSlider()
    self:setTextByLanKey("normal_slider_text", c_num.."/"..max_num)
    local slider_img = self:findSlider("slider_normal")
    local to_value = c_num/max_num
    if slider_anim then
        if self.m_temp_c_lv ~= self.m_c_lv then
            slider_img.value = 0
            self.m_temp_c_lv = self.m_c_lv
        end
        DOTweenModuleUI.DOValue(slider_img, to_value, 0.5)
    else
        self.m_temp_c_lv = self.m_c_lv
        slider_img.value = to_value
    end
end

--显示已购买状态的奖励展示
function M:setHightUI(slider_anim)
    self.cur_cfg_tab = self:get_royal_cfg()
    local cell_data = self.cur_cfg_tab[self.m_c_lv]
    local next_data = self.cur_cfg_tab[self.m_c_lv+1]
    local get_obj = self:findGameObject("buy_node_parent") --可领
    local can_get_rewards = self:getAllCanGetReward(self.m_c_lv)
    if next(can_get_rewards) == nil and next_data ~= nil then--当前等级已领
        local next_get_reward = self:getAllCanGetReward(self.m_c_lv+1)
        self:creatRewards(get_obj.transform, next_get_reward, true)
        self:setTextByLanKey("buy_node_title", "gf_str_0124")
        get_obj.transform.pivot = Vector2(0.5,0.5) 
    elseif next(can_get_rewards) ~= nil then
        self:creatRewards(get_obj.transform, can_get_rewards, true)
        self:setTextByLanKey("buy_node_title", "gf_str_0125")
        if #can_get_rewards >= 4 then
            get_obj.transform.pivot = Vector2(0,0.5)
        else
            get_obj.transform.pivot = Vector2(0.5,0.5) 
        end
    else
        local get_rewards = table.copy(cell_data.fee_incentives)
        table.insertto(get_rewards, cell_data.free_reward)
        local pay_obj = self:creatRewards(get_obj.transform, get_rewards)
        for k,v in pairs(pay_obj) do
            local luaBehaviour = UIUtil.findLuaBehaviour(v)
            if luaBehaviour then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", true)
            end
        end
        self:setTextByLanKey("buy_node_title", "gf_str_0125")
        get_obj.transform.pivot = Vector2(0.5,0.5) 
    end
    self:setTextByLanKey("buy_lv_text", self.m_c_lv)
    local c_num, max_num = self:getTokenSlider()
    self:setTextByLanKey("hight_slider_text", c_num.."/"..max_num)
    local slider_img = self:findSlider("slider_buy")
    local to_value = c_num/max_num
    if slider_anim then
        if self.m_temp_c_lv ~= self.m_c_lv then
            slider_img.value = 0
            self.m_temp_c_lv = self.m_c_lv
        end
        DOTweenModuleUI.DOValue(slider_img, to_value, 0.5)
    else
        self.m_temp_c_lv = self.m_c_lv
        slider_img.value = to_value
    end
end


function M:update_Gift(index, cell_data)
    local luaBehaviour = self.m_luaBehaviour
    local free_data = self:getReceived(index)
    local pay_data = self:getPayReceived(index)
    local num = luaBehaviour:FindText("lv_title_text")
    num.text = Language:getTextByKey(index) 
    local royal_tab = self:get_royal_cfg()
    local free_obj = luaBehaviour:FindGameObject("free_prent")
    local pay_obj = luaBehaviour:FindGameObject("pay_prent")
    UIUtil.destroyAllChild(free_obj.transform)
    UIUtil.destroyAllChild(pay_obj.transform)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_lv_bg", index == self.m_c_lv)
    local function callback(obj, data)
        if free_data == false then
            if self.m_token_nums >= cell_data.condition then
                
            end
        end
    end
    local function callback2(obj, data)
        if self.m_pay_status == 1 and pay_data == false then
            if self.m_token_nums >= cell_data.condition then
                
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
    local freeItems = self:creatRewards(free_obj.transform, cell_data.free_reward, true)
    local payItems = self:creatRewards(pay_obj.transform, cell_data.fee_incentives, true)
    for i,v in ipairs(freeItems) do
        local ItemluaBehaviour = UIUtil.findLuaBehaviour(v)
        if free_data == false then
            --未领过
            if self.m_token_nums >= cell_data.condition then
                if ItemluaBehaviour then
                    LuaBehaviourUtil.setObjectVisible(ItemluaBehaviour, "select_image", true)
                end
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
        if index%5 == 0 then
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
                   if ItemluaBehaviour then
                       LuaBehaviourUtil.setObjectVisible(ItemluaBehaviour, "select_image", true)
                   end
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

function M:creatRewards(reward_node, rewards, can_get, show_bl)
    local rewards = rewards or {}
    local scale = #rewards > 1 and 0.8 or 0.9
    local itemList = {}
    UIUtil.destroyAllChild(reward_node)
    for k,v in pairs(rewards) do
        local item = GameUtil:createItemElement(v, true, true)   
        item.transform:SetParent(reward_node, false)
        table.insert( itemList, item)
        local data = RewardUtil:getProcessRewardData(v)
        if show_bl == true then
            GameUtil:creatCommonActiveEffect(item, data.quality)
        end
        if can_get == true then
            GameUtil:creatCommonItemEffect(item, data.quality)
        end
        UIUtil.setScale(item.transform, scale)
    end
    return itemList
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

function M:checkCanGet(lv, tab)
    for k,v in pairs(tab) do
        if v == lv then
            return false
        end
    end    
    return true
end




function M:onButtonClick(obj, name)
    if name == "active_token_btn" then
        self:updateMsg("war_order_btn")
    end
end

function M:destroy()
    M.super.destroy(self)
end








--------model---------------
function M:getRoyalShowLv()
    local tab = self:get_royal_cfg()
    local c_lv = 1
    for i = 1, table.nums(tab) do
        local c_cfg = tab[i]
        if self.m_token_nums and self.m_token_nums >= c_cfg.condition then
            c_lv = i
        end
    end
    return c_lv
end

function M:get_royal_cfg()
    local valor_tab = ConfigManager:getCfgByName("royal_reward")
    return valor_tab[self.m_token_lv or 1]
end

function M:getTokenSlider()
    local tab = self:get_royal_cfg()
    local c_cfg = tab[self.m_c_lv]
    local n_cfg = tab[self.m_c_lv+1]
    if n_cfg then
        return (self.m_token_nums - c_cfg.condition), (n_cfg.condition - c_cfg.condition)
    else
        return c_cfg.condition, c_cfg.condition
    end
end

function M:getReceived(id)
    for k, v in pairs(self.m_free_received) do
        if v == id then
            return true
        end
    end
    return false
end

function M:getPayReceived(id)
    for k, v in pairs(self.m_pay_received) do
        if v == id then
            return true
        end
    end
    return false
end

--购买高级可立即领取的
function M:getCanHaveReward(m_token_lv)
	local war_table = self:get_royal_cfg()
	local c_lv = m_token_lv > 0 and m_token_lv or 1
	local rewards = {}
	for i = 1, m_token_lv do
		local m_cfg = table.copy(war_table[i])
		if m_cfg then
			for k,v in pairs(m_cfg.fee_incentives) do
				if self:checkWarInTab(rewards, v) == true then
					self:checkInRewards(rewards, v)
				else	
					table.insert( rewards, v)
				end
			end
		end
	end
    local function sortFunc(id_one, id_two)
        local bl_1 = (id_one[1] == 101 or id_one[1] == 130) and 1 or 0
        local bl_2 = (id_two[1] == 101 or id_two[1] == 130) and 1 or 0
        return bl_1 > bl_2
    end
    table.sort(rewards, sortFunc)
	return rewards
end

function M:checkWarInTab(rewards, data)
	for k,v in pairs(rewards) do
		if v[1] == data[1] and v[2] == data[2] then
			return true
		end
	end	
	return false
end

function M:checkInRewards(rewards, data)
	for k,v in pairs(rewards) do
		if v[1] == data[1] and v[2] == data[2] then
			v[3] = v[3] + data[3]
		end
	end	
	return rewards
end

--普通战令当前可领的
function M:getCanGetReward(m_token_lv)
    local war_table = self:get_royal_cfg()
	local c_lv = m_token_lv > 0 and m_token_lv or 1
    local rewards = {}
    for i = 1, m_token_lv do
		local m_cfg = table.copy(war_table[i])
        local free_get = self:getReceived(i)
		if free_get == false and m_cfg then
			for k,v in pairs(m_cfg.free_reward) do
				if self:checkWarInTab(rewards, v) == true then
					self:checkInRewards(rewards, v)
				else	
					table.insert( rewards, v)
				end
			end
		end
	end
    local function sortFunc(id_one, id_two)
        if id_one[1] == 101 or id_one[1] == 130 then 
            return true
        else
            return false
        end
    end
    table.sort(rewards, sortFunc)
	return rewards
end

--所有战令当前可领的
function M:getAllCanGetReward(m_token_lv)
    local war_table = self:get_royal_cfg()
	local c_lv = m_token_lv > 0 and m_token_lv or 1
    local rewards = {}
    for i = 1, m_token_lv do
		local m_cfg = table.copy(war_table[i])
        local free_get = self:getReceived(i)
        local pay_get = self:getPayReceived(i)
		if free_get == false and m_cfg then
			for k,v in pairs(m_cfg.free_reward) do
				if self:checkWarInTab(rewards, v) == true then
					self:checkInRewards(rewards, v)
				else	
					table.insert( rewards, v)
				end
			end
		end
        if pay_get == false and m_cfg then
            for k,v in pairs(m_cfg.fee_incentives) do
				if self:checkWarInTab(rewards, v) == true then
					self:checkInRewards(rewards, v)
				else	
					table.insert( rewards, v)
				end
			end
        end
	end
    local function sortFunc(id_one, id_two)
        if id_one[1] == 101 or id_one[1] == 130 then 
            return true
        else
            return false
        end
    end
    table.sort(rewards, sortFunc)
	return rewards
end

return M