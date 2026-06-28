local M = class("DragonswordQuestView", LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "Dragonsword/DragonswordQuest"

function M:onEnter()
    self:setTextByLanKey("common_title_text", "new_str_0778")
    self:refreshUI()
end

--刷新
function M:refreshUI()
    --更新列表
    self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    self.m_click_cell_object = nil
    local data = self.m_model:getCfgData()
    --数据为空时显示
    --self:setObjectVisible("CommonTipsNode", #data == 0)
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                --领取奖励活动
                local status = cell_data.quest_status
                self:updateMsg(status == -1 and "reward" or "goto_btn", cell_data)
                self.m_click_cell_object = cell_object
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, true)
    end
end

--内容更新
function M:updateScrollViewCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local transform = cell_object.transform
    local status = cell_data.quest_status
    local value = cell_data.quest_value or 0
    local target_value = cell_data.cfg.target_value or 0
    value = math.min(value, target_value)
    local progress_slider_text =
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "progress_slider_text", "new_str_0471", value, target_value)
    if cell_data.quest_value then
        local slider = luaBehaviour:FindSlider("progress_slider")
        local finish_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "finish_text", "new_str_0470")
        local isFin = status == -1
        finish_text.gameObject:SetActive(isFin)
        progress_slider_text.gameObject:SetActive(not isFin)
        if isFin then
            slider.value = 1
        else
            slider.value = value / target_value
        end
    else
        progress_slider_text.gameObject:SetActive(false)
    end
    --任务名称
    UIUtil.setTextByLanKey(transform, "Task_reward", cell_data.cfg.name)

    --设置文本文字
    local goto_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "goto_btn_text", "new_str_0029") --前往
    local receive_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "receive_btn_text", "new_str_0056") --领取
    local incomplete_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "incomplete_btn_text", "new_str_0057") --未完成
    local task_finish_text = UIUtil.setTextByLanKey(transform, "task_finish_text", "gf_str_0048") --已领取

    --初始化文字显示状态
    local goto_btn_text_show = false --前往
    local receive_btn_text_show = false --领取
    local incomplete_btn_text_show = false --未完成
    local goto_btn_show = false --前往按钮显示

    local goto_btn = UIUtil.findButton(transform, "goto_btn") --按钮

    --奖励领取
        --任务状态
        if status == 0 then --前往
            goto_btn_show = true
            local go_type = {}
            table.insert(go_type, cell_data.cfg.go_type)
            --有可跳转位置，显示前往，没有显示未完成
            if _G.next(go_type) then
                UIUtil.setImg(transform, "a_ui_currency_btn_small_3", "common_ui", "goto_btn")
                goto_btn.enabled = true
                goto_btn_text_show = true
            else
                UIUtil.setImg(transform, "a_ui_currency_btn_small_3", "common_ui", "goto_btn")
                goto_btn.enabled = false
                incomplete_btn_text_show = true
            end
        elseif status == -1 then --领取
            goto_btn_show = true
            goto_btn.enabled = true
            receive_btn_text_show = true
            UIUtil.setImg(transform, "a_ui_currency_btn_small_2", "common_ui", "goto_btn")
        else --已领取
            goto_btn_show = false
        end
        local txt = Language:getTextByKey("new_str_0812", cell_data.times)
        if cell_data.cfg.type == 2 then
            txt = Language:getTextByKey("new_str_0813", cell_data.times)
        end
        UIUtil.setTextByLanKey(transform, "task_finish_text", "new_str_0058") --已领取
    
    --设置文字显示状态
    goto_btn.gameObject:SetActive(goto_btn_show)
    goto_btn_text.gameObject:SetActive(goto_btn_text_show)
    receive_btn_text.gameObject:SetActive(receive_btn_text_show)
    incomplete_btn_text.gameObject:SetActive(incomplete_btn_text_show)
    --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cost_node", cost_node_show)

    --领取光效展示
    local btn_spine = UIUtil.findTrans(transform, "btn_spine")
    btn_spine.gameObject:SetActive(status == 1)

    --奖励
    local reward = cell_data.cfg.reward or {}
    local reward_node = UIUtil.findRectTransform(transform, "reward_node")
    GameUtil:createRewards(reward_node, reward, true, true, nil, 1)
    task_finish_text.gameObject:SetActive(status == 2) --已完成
end

function M:destroy()
    M.super.destroy(self)
end

return M
