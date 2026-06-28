local M = class("LanternFestivalRiddlesPopView",LikeOO.OOPopBase)

M.m_uiName = "LanternFestival/LanternFestivalRiddlesPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
    self.m_gray_image = self:findImage("gray_img")
    local question_data = self.m_model:getQuestion()

    if question_data then
        self:setTextByLanKey("question_text", question_data.question)
    end
    self:refreshUI(question_data)
    self:setTextByLanKey("common_title_text", "lantern_festival_text_0009")
    self:setTextByLanKey("reward_title_text", "new_str_0373")
    
end

function M:destroy()
    M.super.destroy(self)
end

function M:refreshUI(question_data)
    --快速导航
    --self:updateLoopScroll()
    self:refreshAnswerBtn(question_data)
    self:refreshRewardNode()
end

function M:updateLoopScroll()
    local data = ConfigManager:getCommonValueById(506, {  })
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            pos_center = true,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local data = cell_data
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                local reward_data = RewardUtil:getProcessRewardData(data)
                local item_node = luaBehaviour:FindGameObject("ItemNode")--LuaBehaviourUtil.FindGameObject("")
                local ui_element = GameUtil:updateItemElementByData(item_node, reward_data, true, true)
                ui_element.red_point_img:SetActive(false)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
            end,
            ui_name = self.m_uiName
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data)
    end
end

function M:refreshAnswerBtn(question_data)
    question_data = question_data or self.m_model:getQuestion()
    if question_data then
        for i = 1, 4 do
            self:setTextByLanKey("answer_btn_text" .. i, question_data["answer"][i])
            local right_index = question_data.correct
            if self.m_model.m_status_data.res == 0 then
                self:setObjectVisible("result_img" .. i, false)
            else
                self:setObjectVisible("result_img" .. i, i == right_index or i == self.m_model.m_cur_select)
                if i == right_index then
                    self:setImg("a_cdm_zhengque", "pub_ui", "result_img" .. i)
                elseif i == self.m_model.m_cur_select and self.m_model.m_cur_select ~= right_index then
                    self:setImg("a_cdm_cuowu", "pub_ui", "result_img" .. i)
                end
            end
        end
    else
        Logger.logError("riddles cfg have some error")
    end
end

function M:refreshRewardNode()
    for i = 1, 3 do
        local item_node = self:findGameObject("ItemNode" .. i)
        local reward = self.m_model:getRiddleRewardByIndex(i)
        if reward then
            local reward_data = RewardUtil:getProcessRewardData(reward)
            local ui_element = GameUtil:updateItemElementByData(item_node, reward_data, true, true)
            ui_element.red_point_img:SetActive(false)
        end
    end
end

return M