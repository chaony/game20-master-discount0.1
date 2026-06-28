local M = class("GuJianQiTanDrawView",LikeOO.OOPopBase)

M.m_uiName = "GuJianQiTan/GuJianQiTanDraw"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self:setTextByLanKey("close_title_text", "gu_jian_qi_tan_str_001")
    self:setTextByLanKey("reward_title_text", "gu_jian_qi_tan_str_018")
    self:setTextByLanKey("reward_des_text", "gu_jian_qi_tan_str_019")
    self:setTextByLanKey("progress_des_text", "gu_jian_qi_tan_str_020")
    
    self:setTextByLanKey("spine_moon_name", "gu_jian_qi_tan_str_007")
    self:setTextByLanKey("spine_furnance_name", "gu_jian_qi_tan_str_008")
    self:setTextByLanKey("spine_ice_name", "gu_jian_qi_tan_str_062")
    
    self:refreshUI()
end

function M:refreshUI()
    self:displayWord(self.m_model:getContentWord())
    self:updateProgressSlider()
    self:updateRewardLoopScroll()
    self:updateActiveValue()
    self:updateTouchGuideEffect(true)
end

function M:displayWord(word, result)
    local touch_index = self.m_model:getTouchBtnIndex()
    for i = 1, 3 do
        self:setObjectVisible("display_node_" .. i, i == 1)
    end
    local color = Color(0/255, 0/255, 0/255)
    if result == true then
        color = Color(0/255, 0/255, 0/255)
    elseif result == false then
        color = Color(255/255, 0/255, 0/255)
    end
    local text_obj = self:setText("display_word_" .. 1 .. "_text", word)
    text_obj.color = color
end

--里程碑
function M:updateProgressSlider()
    local box_node = self:findGameObject("progress_box_node")
    local progress_slider = self:findSlider("progress_slider")
    local box_node_rtrans = UIUtil.findRectTransform(box_node)
    local box_node_trans = box_node.transform
    UIUtil.destroyAllChild(box_node_trans)
    
    local show_data, cur_num = self.m_model:getProgressData()
    local width = box_node_rtrans.rect.width
    local max_num = 0
    local box_num = #show_data
    if show_data[box_num] then
        max_num = show_data[box_num].score
    end
    max_num = max_num > 0 and max_num or 100
    progress_slider.value = cur_num / max_num
    for i = 1, box_num do
        local data = show_data[i]
        local task_box = GameUtil:createPrefab("GuJianQiTan/GuJianQiTanDrawBox", box_node_trans)
        local transform = task_box.transform
        --UIUtil.setLocalScale(transform, 0.7, 0.7, 1.0)
        local luaBehaviour = UIUtil.findLuaBehaviour(transform)
        UIUtil.setLocalPosition(task_box, width * data.score / max_num - width * 0.5, 0)
        local function btns(trans,params)
            if data.status == 1 then 
                self:updateMsg("box_reward", {click_transform = trans, data = data}) -- 可领取
            else
                self:updateMsg("box_click", {click_transform = trans, data = data}) -- 展示
            end
        end
        UIUtil.setButtonClick(transform, btns, i)
        UIUtil.setText(transform, tostring(data.score), "score_text")
        UIUtil.setTextByLanKey(transform,"finish_text", "new_str_0080")
        
        local reward_cfg = RewardUtil:getProcessRewardData(data.reward)
        local quality_item = GlobalConfig.QUALITY_COMMON_SETTING[reward_cfg.quality] or GlobalConfig.QUALITY_COMMON_SETTING[1]
        LuaBehaviourUtil.setImg(luaBehaviour, "box_bg", quality_item.frame_name, "equip_icon")
        LuaBehaviourUtil.setImg(luaBehaviour, "box_img", reward_cfg.icon_name, reward_cfg.atlas_name)
        --local box_img = luaBehaviour:FindImage("box_img")
        --box_img:SetNativeSize()
        --local box_bg = luaBehaviour:FindImage("box_bg")
        --box_bg:SetNativeSize()
        
        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"got_flag_img",data.status == 2)
        --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_img", i ~= box_num)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Arena_BX_01", data.status == 1)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Arena_BX_02", data.status == 1)
    end
end

--左侧奖励展示
function M:updateRewardLoopScroll()
    local show_data = self.m_model:getRewardData()
    self:setObjectVisible("reward_loopscroll", #show_data > 0)
    if self.m_loopscroll_reward_view == nil then
        local loopscroll = self:findGameObject("reward_loopscroll")
        local params = {
            show_data = show_data,
            one_line_count = 2,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                GameUtil:updateItemElement(cell_object, cell_data, true, true)
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

--动态值刷新
function M:updateActiveValue()
    self:updateSwordForgeCount()
    self:updateProgressText()
    self:updateActivityDate()
end

--铸剑次数
function M:updateSwordForgeCount()
    local total, cur = self.m_model:getSwordForgeCount()
    self:setTextByLanKey("sword_count_text", "gu_jian_qi_tan_str_023", total - cur, total)
end

--当前进度
function M:updateProgressText()
    local total, cur = self.m_model:getProgressTextData()
    self:setTextByLanKey("progress_count_text", "gu_jian_qi_tan_str_021", cur, total)
end

--活动时间
function M:updateActivityDate()
    local date_start, date_end = self.m_model:getActivityDate()
    self:setTextByLanKey("activity_date_text", "gu_jian_qi_tan_str_022", date_start, date_end)
end

--点击动画
function M:playTouchAnim(touch_btn_name, callback)
    local anim_data_name
    local duration_time
    if touch_btn_name == "btn_moon" then
        anim_data_name = "GuJianQiTan_Yueliang001_SkeletonData"
        duration_time = 11.0
    elseif touch_btn_name == "btn_furnace" then
        anim_data_name = "GuJianQiTan_Shan001_SkeletonData"
        duration_time = 6.5
    elseif touch_btn_name == "btn_ice" then
        anim_data_name = "GuJianQiTan_Jian001_SkeletonData"
        duration_time = 4.5
    end
    local anim_obj = self:findGameObject(touch_btn_name .. "_anim")

    if anim_obj and anim_data_name and duration_time then
        GameUtil:updateSpineLoadSet(anim_obj, "RoleSpine/" .. anim_data_name, "tap", 0, false)
        local function anim_back_func()
            GameUtil:updateSpineLoadSet(anim_obj, "RoleSpine/" .. anim_data_name, "idle", 0, true)
        end
        self.m_control:setOnceTimer(duration_time, anim_back_func)
        
        local function callback_func()
            if callback then
                callback()
            end
        end
        self.m_control:setOnceTimer(3.0, callback_func)
    end
end

--设置可点击特效
function M:updateTouchGuideEffect(init)
    local total, cur = self.m_model:getSwordForgeCount()
    local left = total - cur
    local play_flag = (self.m_lockNum <= 0 or init == true) and (left > 0)
    self:setObjectVisible("spine_node", play_flag)
end

return M


