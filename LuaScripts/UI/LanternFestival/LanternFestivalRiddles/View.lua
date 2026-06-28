local M = class("LanternFestivalRiddlesView",LikeOO.OOPopBase)

M.m_uiName = "LanternFestival/LanternFestivalRiddles"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self.m_gray_image = self:findImage("gray_img")
    self:refreshUI()
    self:setTextByLanKey("close_title_text", "lantern_festival_text_0003")
    self:setTextByLanKey("question_text", "this is a question , please choose an answer...")
    self:setTextByLanKey("reward_title_text", "")
    
end

function M:destroy()
    M.super.destroy(self)
end

function M:refreshUI()
    self:updateDailyNode()
    self:updateLanternNode()
    --快速导航
    --self:setObjectVisible("guide_btn", true)
    --local guide_btn_obj = self:findGameObject("guide_btn")
    --if guide_btn_obj then
    --    guide_btn_obj.transform.localPosition = Vector3(273, -22.9, 0)
    --end
    --self:updateLoopScroll()
    --self:refreshAnswerBtn()
end

function M:updateDailyNode()
    for i = 1, 7 do
        self:setObjectVisible("cur_img" .. i, i == self.m_model.m_cur_day)
        local is_get = self.m_model:isDoneByDay(i)
        self:setObjectVisible("get_img" .. i, is_get)
        self:setTextByLanKey("daily_sign_text" .. i, "day_str_" .. i)
        local item_node = self:findGameObject("ItemNode" .. i)
        self:refreshRewardNode(item_node, i, is_get)
    end
end

function M:updateLanternNode()
    for i = 1, 7 do
        --status 0 不可答 1可答 2 答对 3 答错 
        local status = self.m_model:getLatternStatusByIndex(i)
        local lantern_image = self:findImage("lantern_btn" .. i)
        local lantern_result_img = self:findImage("lantern_result_img" .. i)
        local dengmi_img = self:findImage("dengmi_img" .. i)
        self:setObjectVisible("lantern_result_img" .. i, status == 2 or status == 3)
        if status == 2 then
            GameUtil:updateResourcesImg( lantern_image, "Texture/lantern_festival/a_hdcm_denglong")
            self:setImg("a_hdcm_denglonggou", "pub_ui", "lantern_result_img" .. i)
        elseif status == 3 then
            GameUtil:updateResourcesImg( lantern_image, "Texture/lantern_festival/a_hdcm_denglong_cuowu")
            self:setImg("a_hdcm_denglongcha", "pub_ui", "lantern_result_img" .. i)
            self:setImg("a_hdcm_dengmi_cuowu", "language_zh_cn", "dengmi_img" .. i)
        end
        if i > self.m_model.m_cur_day then
            lantern_image.color = Color( 150/255, 150/255, 150/255)
        else
            lantern_image.color = Color( 255/255, 255/255, 255/255)
        end
        lantern_image:SetNativeSize()
        lantern_result_img:SetNativeSize()
        dengmi_img:SetNativeSize()
    end
end

function M:refreshRewardNode(item_node, day, is_get)
    local reward = self.m_model:getDailyRewardByDay(day)
    local reward_data = RewardUtil:getProcessRewardData(reward)
    local ui_element = GameUtil:updateItemElementByData(item_node, reward_data, true, true)
    ui_element.red_point_img:SetActive(false)
    if is_get  then
        --ui_element.duigoudi_img:SetActive(true)
        --LuaBehaviourUtil.setObjectVisible(ui_element.luaBehaviour,"duigou_img",false)
        LuaBehaviourUtil.setObjectVisible(ui_element.luaBehaviour,"duigoudi_img",true)
    end
end

function M:updateActivityTimer()
    local end_ts = self.m_model:getEndTs()
    if end_ts >= 0 then
        local text = GameUtil:formatTimeBySecond(end_ts, 999)
        text = Language:getTextByKey("new_str_0919") .. text
        self:setTextByLanKey("count_time_text", text)
    end
end

return M