local M = class("QiMenDunJiaBattleRecordView",LikeOO.OOPopBase)

M.m_uiName = "QiMenDunJia/QiMenDunJiaBattleRecord"
M.m_size_type = 2


function M:onEnter()
    self.m_gray_image = self:findImage("gray_image")
    self:setTextByLanKey("common_title_text", "qi_men_dun_jia_str_008")
    self:setTextByLanKey("right_title_text", "qi_men_dun_jia_str_027")
    self:setTextByLanKey("common_no_have_text", "qi_men_dun_jia_str_052")
    self:refreshUI()
end

function M:refreshUI()
    self:updateRecordLoopScroll()
    self:updateRewardInfo()
end

--记录
function M:updateRecordLoopScroll()
    local data = self.m_model:getRecordData()
    local all_cell_size = {}
    for i,v in ipairs(data or {}) do
        if i == self.m_model.m_active_target_index then
            all_cell_size[i] = Vector2(650, 190)
        else
            all_cell_size[i] = Vector2(650, 119)
        end
    end
    if self.m_loopscroll_record_view == nil then
        local list_scroll = self:findGameObject("loopscroll_record")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            all_cell_size = all_cell_size,
            update_cell = function(index, cell_object, cell_data)
                self:updateRecordLoopScrollCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {index = index, data = cell_data})
            end,
            ui_name = self.m_uiName
        }
        self.m_loopscroll_record_view = LoopScrollViewUtil.new(params)
    else
        self.m_loopscroll_record_view:reloadData(data, true, all_cell_size)
    end
end

function M:updateRecordLoopScrollCell(index, obj, data)
    local luaBehaviour = obj:GetComponent("LuaBehaviour")
    local HeadNode = luaBehaviour:FindGameObject("HeadNode")
    local name_text = luaBehaviour:FindText("name_text")
    local content_text = luaBehaviour:FindText("content_text")
    
    GameUtil:setUserAvatar(HeadNode, data.user, nil, nil, {show_flag = true, scale = 1})
    name_text.text = data.user.name
    
    local format_date = TimeUtil.gmTime(data.date)
    local date_str = Language:getTextByKey("qi_men_dun_jia_str_029", format_date.year, format_date.month, format_date.day, format_date.hour, format_date.min, format_date.sec)
    local cell_name_str = Language:getTextByKey(data.cell_name)
    local reward_name = ""
    if next(data.gifts) then
        for k, v in pairs(data.gifts) do
            local reward_data = RewardUtil:getProcessRewardData(data.gifts[k]) or {}
            reward_name = reward_name ..  reward_data.name .. "，"
        end
    end
    if index == self.m_model.m_active_target_index then
        content_text.text =  Language:getTextByKey("qi_men_dun_jia_str_026", date_str, data.kill2, cell_name_str, reward_name)
    else
        content_text.text = Language:getTextByKey("qi_men_dun_jia_str_025", date_str, data.kill1, cell_name_str)
    end
    
    local content_bg_obj = luaBehaviour:FindGameObject("content_bg")
    local content_bg_rec = content_bg_obj:GetComponent("RectTransform")
    local content_text_obj = luaBehaviour:FindGameObject("content_text")
    local content_text_rec = content_text_obj:GetComponent("RectTransform")
    local handle_point_img = luaBehaviour:FindGameObject("handle_point_img")
    local rect = obj:GetComponent("RectTransform")
    if index == self.m_model.m_active_target_index then
        rect.sizeDelta = Vector2(rect.rect.width, 190)
        content_bg_rec.sizeDelta = Vector2(370, 180)
        content_text_rec.sizeDelta = Vector2(350, 170)
        handle_point_img.transform.localRotation = Quaternion.Euler(0,0,180);
    else
        rect.sizeDelta = Vector2(rect.rect.width, 119)
        content_bg_rec.sizeDelta = Vector2(370, 104)
        content_text_rec.sizeDelta = Vector2(350, 100)
        handle_point_img.transform.localRotation = Quaternion.Euler(0,0,0);
    end
end

--奖励
function M:updateRewardInfo()
    local has_reward = self.m_model:hasRewardToGet()
    self:setObjectVisible("reward_btn", has_reward == true)
    self:setObjectVisible("CommonTipsNode", has_reward == false)
    self:updateRewardLoopScroll()
end

function M:updateRewardLoopScroll()
    local show_data = self.m_model:getRewardData()
    self:setObjectVisible("loopscroll_reward", #show_data > 0)
    if self.m_loopscroll_reward_view == nil then
        local loopscroll = self:findGameObject("loopscroll_reward")
        local params = {
            show_data = show_data,
            one_line_count = 3,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                GameUtil:updateItemElement(cell_object, cell_data, true, false)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)

            end,
            ui_name = self.m_uiName
        }
        self.m_loopscroll_reward_view = LoopScrollViewUtil.new(params)
    else
        self.m_loopscroll_reward_view:reloadData(show_data)
    end
end


return M