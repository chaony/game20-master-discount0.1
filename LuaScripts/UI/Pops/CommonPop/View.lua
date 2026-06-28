local M = class("CommonPopView", LikeOO.OOPopBase)

M.m_uiName = "Pops/CommonMiniPop"
M.m_size_type = 2

function M:onEnter()
    self.start_tim = UserDataManager:getServerTime() --服务器时间
    self:setText("cancle_text", self.m_model.m_cancel_text)
    self:setText("ok_text", self.m_model.m_ok_text)
    self:setText("common_title_text", self.m_model.m_title)
    self.m_ok_btn = self:findButton("ok_btn")
    self.m_big_close_btn = self:findButton("big_close_btn")
    self.m_hui_Img = self:findImage("hui_Img")
    self.m_ob_btn_Img = self:findImage("ok_btn")
    
    if self.m_model.m_no_close_btn then
        self.m_big_close_btn.enabled = false
        self:setObjectVisible("cancle_btn", false)
        self:setObjectVisible("close_btn", false)
        self.m_ok_btn = self:findButton("ok_btn")
        UIUtil.setLocalPosition(self.m_ok_btn.transform, 0)
    else
        self.m_ok_btn = self:findButton("ok_btn")

        self:setObjectVisible("close_btn", true)
        if self.m_model.m_tow_close_btn then
            UIUtil.setLocalPosition(self.m_ok_btn.transform, 110)
            self:setObjectVisible("cancle_btn", true)
        else
            UIUtil.setLocalPosition(self.m_ok_btn.transform, 0)
            self:setObjectVisible("cancle_btn", false)
        end
    end

    if self.m_model.m_tips ~= nil then
        self:setObjectVisible("tips", true)
        self:setText("tips", self.m_model.m_tips)
    else
        self:setObjectVisible("tips", false)
    end

    if self.m_model.m_red_ok then
        self:setImg("a_ui_currency_btn_middle_1", "common_ui", "ok_btn")
    end

    if self.m_model.isreward ~= nil and self.m_model.isreward then
        self:setObjectVisible("reward_node", true)
        self:setObjectVisible("no_btn", true)
        self:setText("reward_text", self.m_model.reward_text)
        self:setText("no_text", self.m_model.m_no_text)
    else
        self:setObjectVisible("reward_node", false)
        self:setObjectVisible("no_btn", false)
    end
    if self.m_model.istoday ~= nil and self.m_model.istoday then
        self:setObjectVisible("today_btn", true)
        self:setText("today_text",self.m_model.m_today_text)
        self.today = false
        self.today_callback = false
        if self.m_model.m_today_isyes then
            self:todayIsActive()
        end
    else
        self:setObjectVisible("today_btn", false)  
    end
    if self.m_model.m_cost then
        self:setObjectVisible("own_node", self.m_model.m_show_own_flag ~= false)
        self:setText("own_title_text", Language:getTextByKey("new_str_0035"))
        local data = RewardUtil:getProcessRewardData(self.m_model.m_cost)
        local cost_num = GameUtil:formatValueToString(data.data_num)
        local user_num = GameUtil:formatValueToString(data.user_num)
        if self.m_model.m_show_cost and self.m_model.m_show_cost == true then
            self:setTextByLanKey("own_num_text", cost_num)
        else
            self:setTextByLanKey(
                "own_num_text",
                data.data_num > data.user_num and "new_str_0412" or "new_str_0410",
                    user_num,
                    cost_num
            )
        end
        self:setImg(data.icon_name, data.atlas_name or "item_icon", "own_icon")
    else
        self:setObjectVisible("own_node", false)
    end
    if self.m_model.m_consume then
        local data = RewardUtil:getProcessRewardData(self.m_model.m_consume)
        self:setObjectVisible("msg_text", false)
        local msg_img = self:setObjectVisible("msg_Img", true)
        local base_obj_fitter = msg_img:GetComponent("ContentImmediate")
        if base_obj_fitter then
            base_obj_fitter:ForceRefreshSize()
        end
        self:setTextByLanKey("need_text", "huafei_text")
        self:setImg(data.icon_name, data.atlas_name or "item_icon", "pric_img")
        local cost_num = GameUtil:formatValueToString(data.data_num)
        local user_num = GameUtil:formatValueToString(data.user_num)
        self:setTextByLanKey(
            "own_num_text",
            data.data_num > data.user_num and "new_str_0412" or "new_str_0410",
                user_num,
                cost_num
        )
        self:setTextByLanKey("price_num", data.data_num)
        self:setTextByLanKey("msg_text2", self.m_model.m_text)
    else
        self:setText("msg_text", self.m_model.m_text)
        self:setObjectVisible("msg_text", true)
        self:setObjectVisible("msg_doub_text", false)
        self:setObjectVisible("msg_Img", false)
    end
    
    self:setTextByLanKey("max_times_text", Language:getTextByKey("tid#limit_2") .. self.m_model.m_cur_times .. "/" .. self.m_model.m_max_times)
    self:setObjectVisible("max_times_text", self.m_model.m_is_show_limit)

    if self.m_model.m_cost2 then
        self:setObjectVisible("cost_node2", true)
        local data = RewardUtil:getProcessRewardData(self.m_model.m_cost2)
        local cost_num = GameUtil:formatValueToString(data.data_num)
        local user_num = GameUtil:formatValueToString(data.user_num)
        self:setImg(data.icon_name, data.atlas_name or "item_icon", "cost_icon")
        self:setTextByLanKey("cost_num_text", user_num.."/"..cost_num)
    else
        self:setObjectVisible("cost_node2", false)
    end

    local customTextHeight = self.m_model.m_params.custom_text_height
    if customTextHeight then
        local scroll_obj = self:findGameObject("Scroll View")
        local scroll_rectTrans = scroll_obj.transform:GetComponent("RectTransform")

        local delSize =scroll_rectTrans.sizeDelta 

        
        delSize.x =  505;
        delSize.y =  customTextHeight;

        scroll_rectTrans.sizeDelta = delSize

        local acPos = scroll_rectTrans.anchoredPosition 
        acPos.y = 0
        scroll_rectTrans.anchoredPosition = acPos 

        local text_obj = self:findGameObject("msg_text")
        local text = text_obj.transform:GetComponent("Text")
        text.alignment  = CS.UnityEngine.TextAnchor.MiddleLeft
        
        local rectTrans = text_obj.transform:GetComponent("RectTransform")
        
        local txtPos = rectTrans.anchoredPosition 
        txtPos.y = -customTextHeight*0.5
        rectTrans.anchoredPosition = txtPos 

        local txtSize = rectTrans.sizeDelta 
        txtSize.y =  customTextHeight 
        rectTrans.sizeDelta = txtSize

        local t = self.m_model.m_text:gsub("\n", "")
        text.text = t
    end
    
    
    local msg_text_content = self:findGameObject("msg_text_content")
    local msg_text_content_immediate_comp = msg_text_content:GetComponent("ContentImmediate")
    msg_text_content_immediate_comp:ForceRefreshSize()
    self:refreshUI()
end

function M:refreshUI()
end

function M:todayIsActive(...)
    if self.today then
        self.today = false
        self:setObjectVisible("yes", false)
        self.today_callback = false
        self.cur_server_ts = nil
    else
        self.today = true
        self:setObjectVisible("yes", true)
        self.today_callback = true
        self.cur_server_ts = UserDataManager:getServerTime()
    end
end

--刷新时间
function M:updateTime()
    if self.m_model.m_ontbn_light_time > 0 then
        local cur_tim = UserDataManager:getServerTime()
        local remain_tim = cur_tim - self.start_tim --差值时间
        local diff_time = self.m_model.m_ontbn_light_time - remain_tim
        local time_text =  self.m_model.m_ok_text
        if diff_time > 0 then
            local time = Language:getTextByKey("new_str_0945", diff_time)
            time_text = self.m_model.m_ok_text..time
            self.m_ok_btn.interactable = false
            self.m_ob_btn_Img.material = self.m_hui_Img.material
        else
            time_text =  self.m_model.m_ok_text
            self.m_ok_btn.interactable = true
            self.m_ob_btn_Img.material = nil
        end
        self:setTextByLanKey("ok_text", time_text) --重置剩余时间
    end
end

return M
