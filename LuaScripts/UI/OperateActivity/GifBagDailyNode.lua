local M = class("GifBagDailyNode", LikeOO.OOUIbase)
--每日登录
M.m_uiName = "GiftBag/GifBagDailyNode"

M.Tab_Slider = {
    {day = 3, value = 0.08},
    {day = 7, value = 0.25},
    {day = 14, value = 0.5},
    {day = 21, value = 0.73},
    {day = 28, value = 1}
}

function M:onEnter()
    self:setObjectVisible("sign_in_btn", false)
end

function M:switchInit(url, callback)
    local function callFunc(data)
        if callback then
            callback(data)
        end
        if data and data["end"] == 1 then
			return
		end
        self:refreshUI()
    end
    self.m_model:initData(url, callFunc)
end

function M:switchUI()
    self:refreshUI()
end


function M:refreshUI()
    if self.m_model.m_sign_daily_data then
        self:setObjectVisible("sign_in_btn", true)
        self.m_sign_daily_reward = self.m_model.m_sign_daily_data.sign_daily_reward
        local month_num = self.m_model.m_sign_daily_data.sign_daily_reward.month
        self.m_month_day = self.m_model.m_sign_daily_data.sign_daily_reward.month_day
        self:setImg("month_" .. month_num, "active_ui", "month_num_img")
        self:setObjectVisible("month_num_img", true)
        self:setTextByLanKey("count_text", "gf_str_0031")
        self.open_double = ConfigManager:getCommonValueById(271) == 1
        self:createLoopScroll()
        if self.m_scroll_view then
            self.m_scroll_view:moveToCellIndex(self.m_sign_daily_reward.day)
        end
        local reward_slider = self:findSlider("slider")
        if reward_slider then
            reward_slider.value = self:getSliderValue()
        end
        local sign_in_btn = self:findButton("sign_in_btn")
        if self.open_double == true then
            local double_data = self.m_model:getDailyDoubleData(self.m_sign_daily_reward.day) --可领双倍
            local get_recharge_data = self.m_model:getDailyRechargeData(self.m_sign_daily_reward.day) -- 已领双倍
            if self.m_sign_daily_reward.receive == 0 then
                self:setTextByLanKey("sign_in_btn_text", self.m_sign_daily_reward.receive == 0 and "gf_str_0039" or "gf_str_0040")
            else
                if double_data then
                    if get_recharge_data then
                        self:setTextByLanKey("sign_in_btn_text", "gf_str_0040")
                        sign_in_btn.interactable = false
                    else
                        self:setTextByLanKey("sign_in_btn_text", "gf_str_0039")
                        sign_in_btn.interactable = true
                    end
                else
                    if get_recharge_data == nil then
                        -- 在签一次
                        sign_in_btn.interactable = true
                        self:setTextByLanKey("sign_in_btn_text", "gf_str_0089" )
                        sign_in_btn.interactable = true
                    else
                        self:setTextByLanKey("sign_in_btn_text", "gf_str_0040" )
                        sign_in_btn.interactable = false
                    end
                end
            end
        else
            self:setTextByLanKey("sign_in_btn_text", self.m_sign_daily_reward.receive == 0 and "gf_str_0039" or "gf_str_0040")
            sign_in_btn.interactable = self.m_sign_daily_reward.receive == 0
        end
      end
    self:setRiversBtnRed()
end
function M:setRiversBtnRed()
    local red = false
    local activeData = UserDataManager:getActivesDataByOpenId(401)
    if not activeData then
        red =  false
        self:setObjectVisible("rivers_btn_red",red)
        self:setTextByLanKey("srivers_btn_text","fukubukuroku_text_0007")
        return 
    end
    local common_questData = UserDataManager:getRedDotByKey("luckybag")
    if type(common_questData) ~= "number" then
        for _, itemData in pairs(common_questData) do
            -- 290是里边的任务子活动
            if itemData[1] == 401 and itemData[2] == activeData.version then
                red =  true
            end
        end
    end
    self:setObjectVisible("rivers_btn_red",red)
    local active_tab = ConfigManager:getCfgByName("active")
    local title = Language:getTextByKey("fukubukuroku_text_0007")
    for k,v in pairs(active_tab) do
        if v.open_id == activeData.open_id and v.version == activeData.version then
            title = v.name
        end
    end
    self:setTextByLanKey("srivers_btn_text",title)
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    self.m_gift_tab = {}
    local data = {}
    self.sliderReward = {}
    for i = 1, self.m_month_day do
        local cur_data = self.m_sign_daily_reward.config[tostring(i)]
        data[tonumber(i)] = cur_data
        if next(cur_data.extra_reward) then
            self.sliderReward[tonumber(i)] = cur_data
        end
    end
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            one_line_count = 5,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self.m_gift_tab[index] = cell_obj
                self:updateItemNode(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                --self:updateMsg("sign_in", cell_data)
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end
    self:creatSliderReward()
end

function M:updateItemNode(index, obj, data)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    if LuaBehaviour then
        local item_parent = LuaBehaviour:FindGameObject("bg")
        local num_text = string.format("%02d", index)
        local day_text = LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "day_text", num_text)
        UIUtil.destroyAllChild(item_parent.transform)
        local double_data = self.m_model:getDailyDoubleData(index) --可领双倍
        local get_recharge_data = self.m_model:getDailyRechargeData(index) -- 已领双倍
        if self.m_sign_daily_reward.day == index and get_recharge_data == nil then
            day_text.color = Color.New(255 / 255, 237 / 255, 184 / 255)
        else
            day_text.color = Color.New(76 / 255, 54 / 255, 52 / 255)
        end
        local item_objs = self:creatRewards(index,item_parent.transform, data.reward, true, true)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "again_text", false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "get_text", false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "light_img", false)
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "again_text", "gf_str_0089")
        LuaBehaviourUtil.setImg(LuaBehaviour, "show_bg", "a_yyhd_mrdl_yiqiandaozhezhao", "active_ui")
        if self.m_sign_daily_reward.day == index then
            if self.m_sign_daily_reward.receive == 0 then
                for k, v in pairs(item_objs) do
                    local ItemluaBehaviour = UIUtil.findLuaBehaviour(v)
                    if ItemluaBehaviour then
                        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "light_img", true)
                    end
                end
            else
                if get_recharge_data ~= nil or self.open_double == false then
                    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "get_text", true)
                    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "bg_img", true)
                    for k, v in pairs(item_objs) do
                        UIUtil.setOpacity(v, 0.3)
                    end
                else
                    if double_data == nil and self.open_double == true then
                        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "again_text", true)
                        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "bg_img", true)
                        for k, v in pairs(item_objs) do
                            UIUtil.setOpacity(v, 0.3)
                        end
                    else
                        for k, v in pairs(item_objs) do
                            local ItemluaBehaviour = UIUtil.findLuaBehaviour(v)
                            if ItemluaBehaviour then
                                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "light_img", true)
                            end
                        end
                    end
                end
            end
            LuaBehaviourUtil.setImg(LuaBehaviour, "show_bg", "a_yyhd_mrdl_dangqiandi", "active_ui")
        elseif self.m_sign_daily_reward.day > index then
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "bg_img", true)
            for k, v in pairs(item_objs) do
                UIUtil.setOpacity(v, 0.3)
            end
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "get_text", true)
        end
    end
end

function M:creatSliderReward()
    for k, v in pairs(self.sliderReward) do
        local box_img = "box_" .. k
        local box_tx = "tx_" .. k
        local have = self.m_model:getDailyBoxData(k)
        if have then
            self:setImg("a_rw_xiangzi_kai", "main_ui", box_img)
            self:setObjectVisible(box_tx, false)
        else
            if self.m_model.m_sign_daily_data.sign_daily_reward.day > k then
                self:setObjectVisible(box_tx, true)
            elseif self.m_model.m_sign_daily_data.sign_daily_reward.day == k and self.m_model.m_sign_daily_data.sign_daily_reward.receive ~= 0 then
                self:setObjectVisible(box_tx, true)
            else
                self:setObjectVisible(box_tx, false)
            end

            self:setImg("a_rw_xiangzi_weikai", "main_ui", box_img)
        end
    end
end

function M:creatRewards(index, reward_node, rewards, is_show_num, is_show_detail, callback, scale, frame_effect)
    local rewards = rewards or {}
    scale = scale or 1
    local itemList = {}
    UIUtil.destroyAllChild(reward_node)
    for k, v in pairs(rewards) do
        local item = GameUtil:createItemElement(v, is_show_num, is_show_detail, callback, frame_effect)
        item.transform:SetParent(reward_node, false)
        table.insert(itemList, item)
        UIUtil.setScale(item.transform, scale)
        local data = RewardUtil:getProcessRewardData(v)
        if index%5 == 0 then
            GameUtil:creatCommonActiveEffect(item, data.quality, 1)
        end
    end
    return itemList
end

function M:getSliderValue()
    local cur_day = self.m_sign_daily_reward.day
    if self.m_sign_daily_reward.receive == 0 then
        cur_day = cur_day - 1
        if cur_day < 0 then
            cur_day = 0
        end
    end
    local cur_value = 0
    for i = 1, table.nums(self.Tab_Slider) do
        local cur_data = self.Tab_Slider[i]
        if i < table.nums(self.Tab_Slider) then
            local next_data = self.Tab_Slider[i + 1]
            if cur_day >= cur_data.day and cur_day < next_data.day then
                cur_value = cur_data.value
                local jg_day = next_data.day - cur_data.day
                local jg_value = next_data.value - cur_data.value
                local d_day = cur_day - cur_data.day
                local add_value = (d_day / jg_day) * jg_value
                cur_value = cur_value + add_value
                break
            elseif cur_day < cur_data.day then
                local jg_day = cur_data.day
                local jg_value = cur_data.value
                local add_value = (cur_day / jg_day) * jg_value
                cur_value = cur_value + add_value
                break
            end
        else
            cur_value = 1
        end
    end
    return cur_value
end

function M:onButtonClick(obj, name)
    if name == "sign_in_btn" then
        if self.m_sign_daily_reward.receive > 0 and self.open_double == true then
            local double_data = self.m_model:getDailyDoubleData(self.m_sign_daily_reward.day) --可领双倍
            local get_recharge_data = self.m_model:getDailyRechargeData(self.m_sign_daily_reward.day) -- 已领双倍
            if double_data == nil and get_recharge_data == nil then
                local params = {
                    text = Language:getTextByKey("gf_str_0107"),
                    tow_close_btn = true,
                    on_ok_call = function ()
                        static_rootControl:closeAllViewPop()
                        QuickOpenFuncUtil:openFunc(999)
                    end
                }
                self:openView("Pops.CommonPop", params)
                return
            end
        end
        local day = self.m_sign_daily_reward.day
        if self.m_sign_daily_reward.receive ~= 0 and self.open_double == true then
            self:updateMsg("recharge_daily_reward", day)
        elseif self.m_sign_daily_reward.receive == 0 then
            self:updateMsg("get_daily_reward", day)
        elseif self.m_sign_daily_reward.receive ~= 0 and self.open_double == true then
            self:updateMsg("goto_recharge", 8, "parent")
        end
    else
        self:updateMsg(name)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
