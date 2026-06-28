--- 每日任务
local M = class("TaskDailyNode",LikeOO.OOUIbase)

M.m_uiName = "Task/TaskDailyNode"

function M:onEnter()
    self:setTextByLanKey("title_time_text", "new_str_0064")
    self.m_active_point_slider = self:findSlider("active_point_slider")
    self.m_box_node = self:findGameObject("box_node")
    self.m_fly_icon = self:findGameObject("fly_icon")
    self.m_fly_icon:SetActive(false)
    self.m_score_btn = self:findGameObject("score_btn")
	self.m_box_node_rt = UIUtil.findRectTransform(self.m_box_node)
    self.m_time_text = self:findText("time_text")
    self:setTextByLanKey("score_title_text", "new_str_0569")
    self.loop_score_sequence = Tweening.DOTween.Sequence()
    self.sequence_time =0
    self.onceOpen = true
    local tips_str = self.m_model:getRewardUpgradeTipsStr(398)
    self:setTextByLanKey("reward_upgrade_tips_text", tips_str)
    self:refreshUI()
end

function M:onButtonClick(obj, name)
    if name == "score_btn" then
        self:updateMsg("score_btn",{click_transform = obj.transform, msg = Language:getTextByKey("new_str_0060"), top = true})
    end
end

function M:refreshUI()
    local time = self.m_model:getDaliyRemainingTime()
    local function tick(event, dt, remaining_time)
        self:setTimeText()
        if remaining_time <= 0 then
            self:updateMsg("refresh")
        end
    end
    EventDispatcher:registerTimeEvent("TaskDailyNodeTime", tick, 1, time)
    self:setTimeText()
    self:refreshQuestsScore()
    self:refreshTaskLoopScroll()
end

function M:setTimeText()
    local time = self.m_model:getDaliyRemainingTime()
    local ft = GameUtil:formatTimeBySecond(time)
    self.m_time_text.text = ft
end

function M:refreshQuestsScore()
    local box_trans = self.m_box_node.transform
    UIUtil.destroyAllChild(box_trans)
    local show_data, cur_score = self.m_model:getDailyQuestsScoreData()
    local width = self.m_box_node_rt.rect.width
    local max_score = 0
    local box_num = #show_data
    if show_data[box_num] then
        max_score = show_data[box_num].cfg.score
    end
    max_score = max_score > 0 and max_score or 100
    self.score_text = self:findText("score_text")
    if self.onceOpen == true then
         self:setText("score_text", cur_score)
         self.onceOpen = false
    else
         if self.m_control then
            self.m_control:setOnceTimer(0.5, function()
                self.m_control.m_view:setValue(tonumber(self.score_text.text), cur_score,self.score_text)
            end)
             if self.m_cur_score ~= cur_score then
                 self:setObjectVisible("Ui_Task_HuoYue_04", false)
                 self:setObjectVisible("Ui_Task_HuoYue_04", true)
                 self.m_control:setOnceTimer(2, function()
                     self:setObjectVisible("Ui_Task_HuoYue_04", false)
                 end)
             end
         end
    end
    self.m_cur_score = cur_score
    
    self.m_active_point_slider.value = cur_score/max_score
    for i=1,box_num do
        local data = show_data[i]
        local cfg = data.cfg
        local task_box = GameUtil:createPrefab("Task/TaskBox", box_trans)
        local transform = task_box.transform
        local luaBehaviour = UIUtil.findLuaBehaviour(transform)
        UIUtil.setLocalPosition(task_box, width*cfg.score/max_score - width*0.5, 0)
        local function btns(trans,params)
            if data.status == 2 then -- 可领取
                self:updateMsg("daily_box_reward", {click_transform = trans, data = data})
            else
                self:updateMsg("box_click", {click_transform = trans, data = data})
            end
        end
        UIUtil.setButtonClick(transform, btns, i)
        local score_text = UIUtil.setText(transform, tostring(cfg.score), "score_text")
        local finish_text = UIUtil.setTextByLanKey(transform,"finish_text", "new_str_0080")
        --finish_text.gameObject:SetActive(data.status == -1)
        --score_text.gameObject:SetActive(data.status ~= -1)
        score_text.color = data.status == 0 and GlobalConfig.COMMON_COLLOR.COMMON_1 or Color( 255/255, 235/255, 68/255)
        local box_effect = UIUtil.findRectTransform(transform, "UI_Task_BaoXiang_001")
        local box_img = nil
        if data.status == 0 then
            --UIUtil.setImg(transform, "a_rw_baoxiang_di_n2", "main_ui", "box_bg")
            box_img = UIUtil.setImg(transform, "a_rw_xiangzi_weikai", "main_ui", "box_img")
        elseif data.status == 2 then
            --UIUtil.setImg(transform, "a_rw_baoxiang_di_h", "main_ui", "box_bg")
            box_img = UIUtil.setImg(transform, "a_rw_xiangzi_weikai", "main_ui", "box_img")
        elseif data.status == -1 then
            --UIUtil.setImg(transform, "a_rw_baoxiang_di_n1", "main_ui", "box_bg")
            box_img = UIUtil.setImg(transform, "a_rw_xiangzi_kai", "main_ui", "box_img")
        end
        box_img:SetNativeSize();
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_img", i ~= box_num)
        box_effect.gameObject:SetActive(false)
        local drop_show = cfg.drop_show or {}
        --if #drop_show > 0 then
            --if not IsNull(box_img) then
            --    UIUtil.setImgAlpha(box_img, 0)
            --end
            --local box_img = luaBehaviour:FindGameObject("box_img")
            --local item, ui_element = GameUtil:createItemElement(drop_show[1], false, false)
            --local canvas_group = item:GetComponent("CanvasGroup")
            --canvas_group.blocksRaycasts = false
            --canvas_group.interactable = false
            --ui_element.duigoudi_img:SetActive(data.status == -1)
            --UIUtil.setScale(item.transform, 0.7)
            --UIUtil.setLocalPosition(item.transform, nil, 10)
            --item.transform:SetParent(box_img.transform, false)
            --if data.status == 2 then
            --    local quality = ui_element.process_data.quality
            --    GameUtil:creatCommonItemEffect(item, quality, 1)
            --end
        --else
            if data.status == 2 then
                self.m_control:setOnceTimer(0.1, function()
                    if not IsNull(task_box) then
                        luaBehaviour:RunAnim("UI_TaskBox_BaoXiang_001", nil , 1)
                    end
                end)
                box_effect.gameObject:SetActive(true)
            end
        --end
    end
end

--[[
	创建任务列表
]]
function M:refreshTaskLoopScroll()
    self.m_click_cell_object = nil
	local data = self.m_model:getDailyQuestsData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("task_loopscroll")
		local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                local status = cell_data.status
                if status ~= -1 then
                    self:updateMsg(status == 2 and "daliy_reward" or "goto_btn", cell_data)
                    self.m_click_cell_object = cell_object
                end
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

-- 更新
function M:updateScrollViewCell(index, cell_object, cell_data)
    local luabe = UIUtil.findLuaBehaviour(cell_object)
    --local reward_icon = luabe:FindGameObject("reward_icon")
    --reward_icon:SetActive(true)
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    local node = luaBehaviour:FindGameObject("node")
    local go_to_tips = luaBehaviour:FindGameObject("go_to_tips")
    go_to_tips:SetActive(false)
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
    local progress_slider_text = LuaBehaviourUtil.setTextByLanKey(luabe, "progress_slider_text", "new_str_0471", cur_progress, target_value)
    UIUtil.setTextByLanKey(node.transform, "reward_num_text", tostring(cfg.score))
    local finish_text = LuaBehaviourUtil.setTextByLanKey(luabe, "finish_text", "new_str_0063")
    -- 前往、领取按钮
    local goto_btn = UIUtil.findButton(node.transform, "goto_btn")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "reward_title_text", "UnionWar_str_025")
    local goto_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "goto_btn_text", "new_str_0029")
    local receive_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "receive_btn_text", "new_str_0056")
    local incomplete_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "incomplete_btn_text", "new_str_0057")
    local tx_obj = self:findGameObject("UI_Task_TiShi_001")
    local goto_btn_text_show = false
    local receive_btn_text_show = false
    local incomplete_btn_text_show = false
    if status == 0 then--前往
        goto_btn.gameObject:SetActive(not data.lock_flag)
        local go_type = cfg.go_type or {}
        if _G.next(go_type) then
            UIUtil.setImg(node.transform, "a_ui_currency_btn_small_3", "common_ui", "goto_btn")
            goto_btn.enabled = true
            goto_btn_text_show = true
        else
            UIUtil.setImg(node.transform, "a_ui_currency_btn_small_3", "common_ui", "goto_btn")
            goto_btn.enabled = false
            incomplete_btn_text_show = true
        end
        if cfg.play_guide == 1 then
            go_to_tips:SetActive(true)
        end
        --UIUtil.setImg(node.transform, "a_rw_jindu_lv", "main_ui", "progress_slider/Fill Area/Fill")
    elseif status == 2 then--领取
        goto_btn.gameObject:SetActive(true)
        goto_btn.enabled = true
        receive_btn_text_show = true
        UIUtil.setImg(node.transform, "a_ui_currency_btn_small_2", "common_ui", "goto_btn")
        --UIUtil.setImg(node.transform, "a_rw_jindu_cheng", "main_ui", "progress_slider/Fill Area/Fill")
    else-- 已领取
        goto_btn.gameObject:SetActive(false)
        --UIUtil.setImg(node.transform, "a_rw_jindu_cheng", "main_ui", "progress_slider/Fill Area/Fill")
    end
    goto_btn_text.gameObject:SetActive(goto_btn_text_show)
    receive_btn_text.gameObject:SetActive(receive_btn_text_show)
    incomplete_btn_text.gameObject:SetActive(incomplete_btn_text_show)
     local task_finish_text = UIUtil.setTextByLanKey(node.transform, "task_finish_text", "new_str_0058")
    -- 解锁文本
    local lock_text = UIUtil.setTextByLanKey(node.transform, "lock_text", data.lock_text)
    
    local mask_show = data.lock_flag or status == -1
    UIUtil.setObjectVisible(node.transform, mask_show, "mask_img")
    lock_text.gameObject:SetActive(mask_show)
    --slider.gameObject:SetActive(not mask_show)
    --goto_btn_text.gameObject:SetActive(not data.lock_flag and status ~= -1)
     task_finish_text.gameObject:SetActive(not data.lock_flag and status == -1)
    --LuaBehaviourUtil.setObjectVisible(luabe, "task_finish_img", not data.lock_flag and status == -1)
    finish_text.gameObject:SetActive(not data.lock_flag and status == 2)
    --progress_slider_text.gameObject:SetActive(not data.lock_flag and status == 0)
    progress_slider_text.gameObject:SetActive(status ~= 2)
    local btn_spine = UIUtil.findTrans(node.transform, "btn_spine")
    --tx_obj.gameObject:SetActive(not data.lock_flag and status == 2)
    btn_spine.gameObject:SetActive(not data.lock_flag and status == 2)
    --local out_color = data.lock_flag and Color( 120/255, 125/255, 132/255, 100/255) or Color( 184/255, 132/255, 19/255, 100/255)
    --UIUtil.setOutlineExEffectColor(progress_slider_text, nil, out_color, 2)
    -- 奖励
    local rewards = data.rewards or {}
    local reward_node = luaBehaviour:FindRectTransform("reward_node")
    GameUtil:createRewards(reward_node, rewards, true, true, nil, 0.85)
end

function M:runAnim(response)
    if self.m_click_cell_object then
        self:killAnim()
        self.m_control.m_view:lockTouch()
        self.m_control:setOnceTimer(0.72, function()
            self.m_control.m_view:unlockTouch()
        end)
        --self.m_fly_icon:SetActive(true)
        local luabe = UIUtil.findLuaBehaviour(self.m_click_cell_object)
        local reward_icon = luabe:FindGameObject("reward_icon")
        local trans = self.m_fly_icon.transform
        local start_pos = trans.parent:InverseTransformPoint(reward_icon.transform.position)
        -- self.m_click_cell_object:SetActive(false)
        local cell_pos = self.m_click_cell_object.transform.localPosition
        UIUtil.setLocalPosition(trans, start_pos.x, start_pos.y, start_pos.z)
        local end_pos = trans.parent:InverseTransformPoint(self.m_score_btn.transform.position)
        local sequence = Tweening.DOTween.Sequence()
        sequence:Append(self.m_click_cell_object.transform:DOLocalMoveX(cell_pos.x - 920,0.22))
        -- sequence:AppendInterval(0.5)
        --sequence:Append(trans:DOLocalMove(Vector3(start_pos.x,start_pos.y - 50,start_pos.z),0.22))
       -- sequence:Join(trans:DOScale(0.6,0.2))
        -- sequence:Join(self.m_click_cell_object.transform:DOLocalMoveX(cell_pos.x - 720,0.2))
       -- sequence:Join(self.m_click_cell_object.transform:DOScale(0,0.2))
        sequence:AppendCallback(function()
            -- UIUtil.setLocalPosition(self.m_click_cell_object.transform, 0)
            UIUtil.setLocalScale(self.m_click_cell_object.transform, 1, 1, 1)
            self:refreshUI()
            self:showRewardPop(response)
        end)
        --sequence:Append(trans:DOLocalMove(Vector3(end_pos.x,end_pos.y,end_pos.z),0.3))
        self:pointSliderAnim()
        sequence:OnComplete(function()
            self.m_sequence = nil
            self.m_fly_icon:SetActive(false)
        end)
        sequence:SetAutoKill(true)
        self.m_sequence = sequence
    end
end

function M:runAnimRewardFly(response)
    self:refreshUI()
    self:showRewardPop(response)
    self:pointSliderAnim()
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

function M:pointSliderAnim()
    local show_data, cur_score = self.m_model:getDailyQuestsScoreData()
    local max_score = 0
    if show_data[#show_data] then
        max_score = show_data[#show_data].cfg.score
    end
    max_score = max_score > 0 and max_score or 100
    DOTweenModuleUI.DOValue(self.m_active_point_slider, cur_score/max_score, 0.5)
end

function M:killAnim()
    if self.m_sequence then
        self.m_sequence:Kill()
        self.m_sequence = nil
    end
end

function M:destroy()
    self:killAnim()
    EventDispatcher:unRegisterEvent("TaskDailyNodeTime")
    M.super.destroy(self)
end

return M