local M = class("LanternFestivalFunPlayView",LikeOO.OOPopBase)

M.m_uiName = "LanternFestival/LanternFestivalFunPlay"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self.m_gray_image = self:findImage("gray_img")
    self.m_fire_image = self:findImage("fire_btn")
    self.m_fire_btn = self:findButton("fire_btn")
    self:refreshUI()
    self:setTextByLanKey("close_title_text", "lantern_festival_text_0002")
    self:setTextByLanKey("max_value_text", "lantern_festival_text_0011",self.m_model:getShowScore())
    self:setTextByLanKey("fire_btn_text", "lantern_festival_text_0010")
end

function M:destroy()
    M.super.destroy(self)
end

function M:refreshUI()
    self:setTextByLanKey("cur_value_text", "lantern_festival_text_0012",self.m_model.m_data.score or 0)
    local isCompleteReward = self.m_model:isCompleteReward()
    self:setObjectVisible("fire_red_point_img",self.m_model.m_data.score >= self.m_model:getShowScore() and isCompleteReward)
    if isCompleteReward then
        self.m_fire_image.material = nil
        self.m_fire_btn.interactable = true
    else
        self.m_fire_image.material = self.m_gray_image.material
        self.m_fire_btn.interactable = false
    end
    self:refreshRewardNode()
    self:updateLoopScroll()
end

function M:refreshRewardNode()
    for i = 1, 6 do
        local item_node = self:findGameObject("ItemNode" .. i)
        local reward = self.m_model:getRewardByIndex(i)
        if reward then
            local reward_data = RewardUtil:getProcessRewardData(reward)
            local ui_element = GameUtil:updateItemElementByData(item_node, reward_data, true, true)
            ui_element.red_point_img:SetActive(false)
            ui_element.duigoudi_img:SetActive(self.m_model:isHasReward(i))
        end
    end
end


--右上，传记详情
function M:updateLoopScroll()
    local data = self.m_model:getTaskDetailData(self.m_model.m_cur_day)
    if self.m_loop_scroll == nil then
        local loopscroll = self:findGameObject("task_loopscroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "goto_btn" then
                    local status = cell_data.status
                    if status ~= -1 then
                        self:updateMsg(status == 1 and "detail_reward_btn" or "detail_goto_btn", cell_data)
                    end
                elseif click_name == "jifen_obj" then
                    GameUtil:lookInfoTips(self.m_control, {click_transform = click_object.transform, msg = Language:getTextByKey("tid#EventPointDes_2")})
                end
            end
        }
        self.m_loop_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll:reloadData(data)
    end
end

-- 更新
function M:updateCell(index, cell_object, cell_data)
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    local node = luaBehaviour:FindGameObject("node")

    -- 名字
    UIUtil.setTextByLanKey(node.transform, "name_text", cell_data.name)
    UIUtil.setTextByLanKey(node.transform, "reward_num_text", tostring(cell_data.score))

    --进度
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "progress_text", "new_str_0471", math.min(cell_data.value, cell_data.target_value), cell_data.target_value)

    -- 前往、领取按钮
    local goto_btn = UIUtil.findButton(node.transform, "goto_btn")
    local goto_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "goto_btn_text", "new_str_0029")
    local receive_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "receive_btn_text", "new_str_0056")
    local incomplete_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "incomplete_btn_text", "new_str_0058")
    local goto_btn_text_show = false
    local receive_btn_text_show = false
    local incomplete_btn_text_show = false
    if cell_data.status == 0 then--前往
        goto_btn.gameObject:SetActive(not cell_data.lock_flag)
        local go_type = cell_data.go_type or {}
        if go_type then
            UIUtil.setImg(node.transform, "a_ui_currency_btn_small_3", "common_ui", "goto_btn")
            goto_btn.enabled = true
            goto_btn_text_show = true
        else
            UIUtil.setImg(node.transform, "a_ui_currency_btn_small_3", "common_ui", "goto_btn")
            goto_btn.enabled = false
            incomplete_btn_text_show = true
        end

    elseif cell_data.status == 1 then--可领取
        goto_btn.gameObject:SetActive(true)
        goto_btn.enabled = true
        receive_btn_text_show = true
        UIUtil.setImg(node.transform, "a_ui_currency_btn_small_2", "common_ui", "goto_btn")
    else-- 已领取
        goto_btn.gameObject:SetActive(false)
        incomplete_btn_text_show = true
    end

    goto_btn_text.gameObject:SetActive(goto_btn_text_show)
    receive_btn_text.gameObject:SetActive(receive_btn_text_show)
    incomplete_btn_text.gameObject:SetActive(incomplete_btn_text_show)

    local btn_spine = UIUtil.findTrans(node.transform, "btn_spine")
    btn_spine.gameObject:SetActive(not cell_data.lock_flag and cell_data.status == 1)

    -- 奖励
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "reward_node_1", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "reward_node_2", false)
    if cell_data.reward[1] ~= nil then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "reward_node_1", true)
        local reward_node_1 = luaBehaviour:FindRectTransform("reward_node_1")
        GameUtil:createRewards(reward_node_1, {cell_data.reward[1]}, true, true, nil, 1)
    end
    if cell_data.reward[2] ~= nil then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "reward_node_2", true)
        local reward_node_2 = luaBehaviour:FindRectTransform("reward_node_2")
        GameUtil:createRewards(reward_node_2, {cell_data.reward[2]}, true, true, nil, 1)
    end

    LuaBehaviourUtil.setText(luaBehaviour, "reward_num_text",tostring(cell_data.score) )
end

function M:refreshRedPoint()
end

return M