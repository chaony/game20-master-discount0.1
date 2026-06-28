local M = class("AchievementOldSeasonPopView", LikeOO.OOPopBase)

M.m_uiName = "Achievement/AchievementOldSeasonPop"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("common_title_text", "achievement_text9")
    if self.m_scroll_view then
        self.m_scroll_view:moveToCellIndex(self.m_model.m_sel_tab_index)
        self:switchTabNode(self.m_model.m_sel_tab_index)
    else
        self:switchTabNode(1)
    end
    self:createLoopScroll()
end


function M:refreshUI()
    self:createLoopScroll()
end

--[[
    创建页签列表
]]
function M:createLoopScroll()
    self.cur_tab = self.m_model.old_season_list
    self.select_cell_obj = nil
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("tab_loopscroll")
        local params = {
            show_data = self.cur_tab,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:update_tag(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                if self.m_model.m_sel_tab_index ~= index then
                    self.m_model.m_sel_season = cell_data.season
                    self:updateMsg("switch_tab", { index =  index,cell_object =cell_object})
                end
            end,
            ui_name = self.m_uiName
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(self.cur_tab, true, nil, true)
    end
end

function M:update_tag(index, obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local tag_name = luaBehaviour:FindText("tag_name_text")
    tag_name.text = Language:getTextByKey(data.name)
    if index == self.m_model.m_sel_tab_index then
        self.select_cell_obj = obj
    end
    local light = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", index == self.m_model.m_sel_tab_index)
    local red_flag = self.m_model:checkRedPointBySeasonChapter(data.season)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point", red_flag == true)
end

function M:switchTabNode(index, cell_object)
    if not IsNull(cell_object) then
        if not IsNull(self.select_cell_obj) then
            local luaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", false)
        end
        self.select_cell_obj = cell_object
        local luaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", true)
    end
    self:refreshTaskLoopScroll() -- 任务列表
end

--[[
	任务列表
]]
function M:refreshTaskLoopScroll()
    self.m_click_cell_object = nil
    local data = self.m_model.list_data
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("task_loopscroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
            all_cell_size = self.m_model.all_cell_size,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local luaBehaviour = UIUtil.findLuaBehaviour(transform)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "task_item", cell_data.is_child)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "chapter_node", not cell_data.is_child)
                local bg_Obj = luaBehaviour:FindGameObject("middle_top_bg");
                if cell_data.is_child then
                    bg_Obj = luaBehaviour:FindGameObject("item_bg");
                    self:updateScrollViewCell(index, cell_object, cell_data)
                else
                    self:updateScrollViewChapterInfo(index, cell_object, cell_data)
                end
                local bg_rect = bg_Obj.transform:GetComponent('RectTransform')
                local size_value = bg_rect.sizeDelta;
                transform.sizeDelta = size_value
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "goto_btn" then
                    local status = cell_data.status
                    if status ~= -1 then
                        self:updateMsg("goto_btn", cell_data)
                        self.m_click_cell_object = cell_object
                    end
                else
                    cell_data.index = index
                    self:updateMsg("more_btn", cell_data)
                    self.m_move_to_id = cell_data.reward_chapter
                end
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        if self.m_move_to_id then
            local move_index = 1
            for k,v in ipairs(data) do
                if v.reward_chapter == self.m_move_to_id then
                    move_index = k
                    break
                end
            end
            self.m_loop_scroll_view:reloadData(data, nil, self.m_model.all_cell_size)
            self.m_loop_scroll_view:moveToCellIndex(move_index)
            self.m_move_to_id = nil
        else
            self.m_loop_scroll_view:reloadData(data, nil, self.m_model.all_cell_size)
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
    UIUtil.setTextByLanKey(node.transform, "task_item/name_text", Language:getTextByKey(cfg.name))
    -- 描述
    UIUtil.setTextByLanKey(node.transform, "task_item/tips_text", Language:getTextByKey(cfg.task_des))
    
    -- 进度条
    local slider = UIUtil.findSlider(node.transform, "task_item/progress_slider")
    slider.value = cur_progress/target_value

    local progress_slider_text = LuaBehaviourUtil.setTextByLanKey(luabe, "progress_slider_text", "new_str_0471", cur_progress, target_value)
    local finish_text = LuaBehaviourUtil.setTextByLanKey(luabe, "finish_text", "new_str_0470")
    local finish_text2 = LuaBehaviourUtil.setTextByLanKey(luabe, "finish_text2", "new_str_0562")
    -- 前往、领取按钮
    local goto_btn = UIUtil.findButton(node.transform, "task_item/goto_btn")

    local goto_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "goto_btn_text", "new_str_0029")
    local incomplete_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "incomplete_btn_text", "new_str_0057")
    local goto_btn_text_show = false
    local incomplete_btn_text_show = false

    if status == 0 then--前往
        local go_type = cfg.go_type or {}
        if _G.next(go_type) then
            goto_btn.gameObject:SetActive(not data.lock_flag)
            goto_btn.enabled = true
            goto_btn_text_show = true
        else
            goto_btn.gameObject:SetActive(false)
            goto_btn.enabled = false
            incomplete_btn_text_show = true
        end
    else-- 已领取
        goto_btn.gameObject:SetActive(false)
    end
    goto_btn_text.gameObject:SetActive(goto_btn_text_show and not data.lock_flag)
    incomplete_btn_text.gameObject:SetActive(incomplete_btn_text_show and not data.lock_flag)
    -- 解锁文本
    local lock_text = UIUtil.setTextByLanKey(node.transform, "task_item/lock_text", data.lock_text)

    local mask_show = data.lock_flag or status == -1
    UIUtil.setObjectVisible(node.transform, mask_show, "task_item/mask_img")
    lock_text.gameObject:SetActive(mask_show)
    finish_text.gameObject:SetActive(not data.lock_flag and status == 1)
    finish_text2.gameObject:SetActive(not data.lock_flag and status == 1)
    progress_slider_text.gameObject:SetActive(status ~= -1 and status ~= 1)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "more_btn", false)
end

-- 章节信息刷新
function M:updateScrollViewChapterInfo(index, cell_object, cell_data)
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    local node = luaBehaviour:FindGameObject("node")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "top_name_text", Language:getTextByKey(cell_data.name))
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "top_tips_text", Language:getTextByKey(cell_data.chapter_des))
    -- 章节成就完成情况
    local complete_num, quest_num, received = self.m_model:getCompleteQuestNum(cell_data.reward_chapter)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "top_jindu_text", Language:getTextByKey("achievement_text3",complete_num, quest_num))
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "top_time_text", "")
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Achievement_JiangLi_001", false)
    
    -- 章节奖励
    local rewards = cell_data.reward or {}
    local reward_node = luaBehaviour:FindRectTransform("top_reward_node")
    local function callFun()
        if cell_data.time_limit == 1 then
            if not received and complete_num>=quest_num then
                self:updateMsg("get_top_reward", {chapter_id =  cell_data.reward_chapter})
            end
        else
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("achievement_text19"), delay_close = 2})
        end
    end
    GameUtil:createRewards(reward_node, rewards, true, complete_num~=quest_num, callFun, 0.85)
    if received then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "top_jindu_text", Language:getTextByKey("achievement_text4"))
    elseif not received and complete_num >= quest_num and quest_num ~= 0 and cell_data.time_limit == 1 then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "top_jindu_text", Language:getTextByKey("achievement_text15"))
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Achievement_JiangLi_001", true)
    elseif quest_num == 0 or cell_data.time_limit == 0 then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "top_jindu_text", Language:getTextByKey("achievement_text17"))
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "more_btn", quest_num ~= 0 and cell_data.time_limit == 1)
    if cell_data.time_limit == 1 then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"top_reward_xianshi", false)
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"top_reward_xianshi", true)
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M
