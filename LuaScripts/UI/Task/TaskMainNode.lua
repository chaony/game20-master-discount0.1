--- 主线任务
local M = class("TaskMainNode",LikeOO.OOUIbase)

M.m_uiName = "Task/TaskMainNode"

function M:onEnter()
    self:refreshUI()

end

function M:refreshUI()
    self.loop_score_sequence = Tweening.DOTween.Sequence()
    self.sequence_time =0
	self:refreshTaskLoopScroll()
end

--[[
	任务列表
]]
function M:refreshTaskLoopScroll()
    self.m_click_cell_object = nil
	local data = self.m_model:getMainQuestsData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("task_loopscroll")
		local params = {
            ui_name = self.m_uiName,
            show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "goto_btn" then
                    local status = cell_data.status
                    if status ~= -1 then
                        self:updateMsg(status == 2 and "main_reward" or "goto_btn", cell_data)
                        self.m_click_cell_object = cell_object
                    end
                else
                    self:updateMsg("more_btn", cell_data)
                    self.m_move_to_id = cell_data.id
                end
            end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
        if self.m_move_to_id then
            local move_index = 1

            for k,v in ipairs(data) do
                if v.id == self.m_move_to_id then
                    move_index = k
                    break
                end 
            end
           self.m_loop_scroll_view:reloadData(data)
           self.m_loop_scroll_view:moveToCellIndex(move_index)
            
            self.m_move_to_id = nil
        else
            self.m_loop_scroll_view:reloadData(data, true)
        end
	end
end

-- 更新
function M:updateScrollViewCell(index, cell_object, cell_data)
    local luabe = UIUtil.findLuaBehaviour(cell_object)
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    local node = luaBehaviour:FindGameObject("node")
    local data = cell_data
    local cfg = data.cfg
    local cur_progress = data.cur_progress
    local target_value = data.target_value
    local status = data.status
    -- 名字
    UIUtil.setTextByLanKey(node.transform, "name_text", cfg.name)
    -- 进度条
    local slider = UIUtil.findSlider(node.transform, "progress_slider")
    slider.value = cur_progress/target_value
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "reward_title_text", "UnionWar_str_025")
    local progress_slider_text = LuaBehaviourUtil.setTextByLanKey(luabe, "progress_slider_text", "new_str_0471", cur_progress, target_value)
    local finish_text = LuaBehaviourUtil.setTextByLanKey(luabe, "finish_text", "new_str_0470")
    -- 前往、领取按钮
    local goto_btn = UIUtil.findButton(node.transform, "goto_btn")

    local goto_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "goto_btn_text", "new_str_0029")
    local receive_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "receive_btn_text", "new_str_0056")
    local tx_obj = self:findGameObject("UI_Task_TiShi_001")
    local incomplete_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "incomplete_btn_text", "new_str_0057")
    local goto_btn_text_show = false
    local receive_btn_text_show = false
    local incomplete_btn_text_show = false
    
    if status == 0 then--前往
        local go_type = cfg.go_type or {}
        if _G.next(go_type) then
            goto_btn.gameObject:SetActive(not data.lock_flag and data.is_child ~= true)
            UIUtil.setImg(node.transform, "a_ui_currency_btn_small_3", "common_ui", "goto_btn")
            goto_btn.enabled = true
            goto_btn_text_show = true
        else
            goto_btn.gameObject:SetActive(false)
            UIUtil.setImg(node.transform, "a_ui_currency_btn_small_3", "common_ui", "goto_btn")
            goto_btn.enabled = false
            incomplete_btn_text_show = true
        end
        --UIUtil.setImg(node.transform, "a_rw_jindu_lv", "main_ui", "progress_slider/Fill Area/Fill")
    elseif status == 2 then--领取
        goto_btn.gameObject:SetActive(data.is_child ~= true)
        goto_btn.enabled = true
        receive_btn_text_show = true
        UIUtil.setImg(node.transform, "a_ui_currency_btn_small_2", "common_ui", "goto_btn")
        --UIUtil.setImg(node.transform, "a_rw_jindu_cheng", "main_ui", "progress_slider/Fill Area/Fill")
    else-- 已领取
        goto_btn.gameObject:SetActive(false)
        --UIUtil.setImg(node.transform, "a_rw_jindu_cheng", "main_ui", "progress_slider/Fill Area/Fill")
    end
    goto_btn_text.gameObject:SetActive(goto_btn_text_show and data.is_child ~= true)
    receive_btn_text.gameObject:SetActive(receive_btn_text_show and data.is_child ~= true)
    incomplete_btn_text.gameObject:SetActive(incomplete_btn_text_show and data.is_child ~= true)
    -- 解锁文本
    local lock_text = UIUtil.setTextByLanKey(node.transform, "lock_text", data.lock_text)
    
    local mask_show = data.lock_flag or status == -1
    UIUtil.setObjectVisible(node.transform, mask_show, "mask_img")
    lock_text.gameObject:SetActive(mask_show)
    --slider.gameObject:SetActive(not mask_show)
    --slider.gameObject:SetActive(false)
    --goto_btn_text.gameObject:SetActive(not data.lock_flag)
    finish_text.gameObject:SetActive(not data.lock_flag and status == 2)
    --progress_slider_text.gameObject:SetActive(not data.lock_flag and status ~= 2)
    progress_slider_text.gameObject:SetActive(status ~= 2)
    local btn_spine = UIUtil.findTrans(node.transform, "btn_spine")
    --tx_obj.gameObject:SetActive(not data.lock_flag and status == 2)
    btn_spine.gameObject:SetActive(not data.lock_flag and status == 2 and data.is_child ~= true)
    -- 奖励
    local drop = cfg.drop or {}
    local reward_node = UIUtil.findRectTransform(node.transform, "reward_node")
    GameUtil:createRewards(reward_node, drop, true, true, nil, 0.85)
    --local out_color = data.lock_flag and Color( 120/255, 125/255, 132/255, 100/255) or Color( 184/255, 132/255, 19/255, 100/255)
    --UIUtil.setOutlineExEffectColor(progress_slider_text, nil, out_color, 2)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "more_btn", data.show_more_status ~= 0)
    LuaBehaviourUtil.setImg(luaBehaviour, "more_btn", data.show_more_status == 1 and "a_ui_currency_xiala" or "a_ui_currency_shouqi", "common_ui")
    local item_bg = LuaBehaviourUtil.setImgAlpha(luaBehaviour, "item_bg", data.is_child == true and 0.3 or 1)
    local item_bg_rt = UIUtil.findRectTransform(item_bg.gameObject)
    item_bg_rt.sizeDelta = Vector2(data.is_child == true and 791.8 or 791.8, item_bg_rt.rect.height)
end

function M:runAnimRewardFly(response)
    self:refreshUI()
    self:showRewardPop(response)
end

function M:showRewardPop(response)
    if response then
        local function callback()
            self.m_control.m_view:lockTouch()
            self.m_control:setOnceTimer(1, function()
                self:updateMsg("update_task_token")
                self.m_control.m_view:unlockTouch()
            end)
        end
        RewardUtil:rewardTipsByData(response.reward, nil, callback, {fly = true, target_control = self.m_control, fly_target = "war_order_btn_icon", fly_reward_types = {[RewardUtil.REWARD_TYPE_KEYS.VALOR_MEDALS] = 1}})
    end
end

function M:runAnim(response)
    if self.m_click_cell_object then
        self:killAnim()
        self.m_control.m_view:lockTouch()
        self.m_control:setOnceTimer(0.3, function()
            self.m_control.m_view:unlockTouch()
        end)
        local luabe = UIUtil.findLuaBehaviour(self.m_click_cell_object)
        local cell_pos = self.m_click_cell_object.transform.localPosition
        local sequence = Tweening.DOTween.Sequence()
        sequence:Append(self.m_click_cell_object.transform:DOLocalMoveX(cell_pos.x - 920,0.22))
        --sequence:Join(self.m_click_cell_object.transform:DOScale(0,0.2))
        sequence:OnComplete(function()
             UIUtil.setLocalScale(self.m_click_cell_object.transform, 1, 1, 1)
            self:refreshUI()
            if response then
                RewardUtil:rewardTipsByData(response.reward)
            end
            self.m_sequence = nil

        end)
        sequence:SetAutoKill(true)
        self.m_sequence = sequence
    end
end

function M:killAnim()
    if self.m_sequence then
        self.m_sequence:Kill()
        self.m_sequence = nil
    end
end

function M:destroy()
    self:killAnim()
    M.super.destroy(self)
end

return M