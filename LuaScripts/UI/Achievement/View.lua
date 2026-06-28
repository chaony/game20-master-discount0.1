local M = class("AchievementView", LikeOO.OOPopBase)

M.m_uiName = "Achievement/AchievementMain"
M.m_size_type = 1 
M.m_iphoneXAdapter = true

function M:onEnter()
    local cur_mode = self.m_model:getCurAttrModeBySeason()
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = cur_mode})
    self:setTextByLanKey("close_title_text", "achievement_text23")
    self:setTextByLanKey("rank_btn_text", "achievement_text18")
    self:setTextByLanKey("season_shop_btn_text", "achievement_text24")
    self:setTextByLanKey("buff_btn_text", "achievement_text25")
    self:setTextByLanKey("buff_title", "achievement_text22")
    self:setTextByLanKey("fengyunlu_btn_text", "fengyunlu_btn_text")
    self:createLoopScroll(true)
    if self.m_scroll_view then
        self.m_scroll_view:moveToCellIndex(self.m_model.m_sel_tab_index)
        self:switchTabNode(self.m_model.m_sel_tab_index)
    else
        self:switchTabNode(1)
    end
    self.m_rank_behaviour = {}
    for i = 1, 3 do
        self.m_rank_behaviour[i] = self:findGameObject("rank_"..i):GetComponent("LuaBehaviour");
    end
    self:updateTopData()
    self:setSpine()
    self:refreshWQLCRedPoint()
    self:setObjectVisible("buff_btn", false)
    self:setObjectVisible("season_buff_count", false)
    self:refreshSeasonBuffUI()
end


function M:refreshUI()
    self:createLoopScroll(false)
    self:refreshWQLCRedPoint()
end

--赛季加成
function M:refreshSeasonBuffUI()
    self:setObjectVisible("buff_btn", self.m_model:checkSeasonBuffOpen() == true)
    local heros = {}
    local season_notice = self.m_model:getSeasonNotice()
    heros = season_notice.hero or {}
    for i = 1,3 do
        local hero_node = self:findGameObject("hero_head_"..i)
        if heros[i] then
            self:setObjectVisible("hero_head_"..i, true)
        else
            self:setObjectVisible("hero_head_"..i, false)
        end
        local luaBehaviour = UIUtil.findLuaBehaviour(hero_node)

        local data = RewardUtil:getProcessRewardData({101,heros[i],1})
        LuaBehaviourUtil.setImg(luaBehaviour,"hero_icon", data.icon_name, data.atlas_name or "hero_head_ui")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "hero_name", data.name)
        luaBehaviour:RegistButtonClick(function (obj,name)
            self.m_control:openView("Pops.HeroLookInfo", {hero_id = heros[i], is_new = false})
        end)
    end
    self:setTextByLanKey("buff_count_text", season_notice.add_des)
end


-- 排行榜信息刷新
function M:updateTopData()
    local top_data = self.m_model.m_rank_info
    local rank_data = {}
    for i, v in ipairs(top_data) do
        rank_data[v.rank] = v;
    end
    for i = 1, 3 do
        if rank_data[i] ~= nil then
            self:updateRank(self.m_rank_behaviour[i], rank_data[i]);
        else
            self:hideRank(self.m_rank_behaviour[i], i)
        end
    end
end

--[[
    创建页签列表
]]
function M:createLoopScroll(first)
    self.cur_tab = self.m_model.chapter_season_list
    self.select_cell_obj = nil
    self.first_into = first
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("tab_loopscroll")
        local params = {
            show_data = self.cur_tab,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:update_tag(index, cell_obj, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
                if luaBehaviour then
                    if self.first_into and self.first_into == true then
                        luaBehaviour:RunAnim("OperateActivity_cell", nil, 1)
                    end
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                if self.m_model.m_sel_tab_index ~= index then
                    self:updateMsg("switch_tab", { index =  index,cell_object =cell_object})
                end
            end,
            ui_name = self.m_uiName
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(self.cur_tab, true, nil, true)
        self:lockTouch()
        self.m_control:setOnceTimer(0.5, function ()
            self.m_scroll_view.m_do_tween_reload_play = false
            self:unlockTouch()
        end)
    end
    if first == true then
        self:lockTouch()
        self.m_control:setOnceTimer(0.5, function ()
            self.first_into = false
            self:unlockTouch()
        end)
    end
end

function M:update_tag(index, obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local tag_name = luaBehaviour:FindText("tag_name_text")
    tag_name.text = Language:getTextByKey(data.name)
    if index == self.m_model.m_sel_tab_index then
        self.select_cell_obj = obj
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", index == self.m_model.m_sel_tab_index)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Achievement_XuanZ_001", index == self.m_model.m_sel_tab_index)
    
    local red_flag = self.m_model:doesChapterHadRewardToGet(data.chapter)
    local lock_flag = self.m_model:checkChapterLockState(data.chapter) --true 没锁，false 锁住
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point",  red_flag == 1 or red_flag == 2 and lock_flag)--有任务奖励可领取，或者有章节奖励可领取且本章没被锁住
end

function M:switchTabNode(index, cell_object)
    if not IsNull(cell_object) then
        if not IsNull(self.select_cell_obj) then
            local luaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Achievement_XuanZ_001", false)
        end
        self.select_cell_obj = cell_object
        local luaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Achievement_XuanZ_001", true)
    end
    self:refreshTaskLoopScroll() -- 任务列表
    self:refreshTopInfo() -- 章节信息刷新
end

-- 隐藏排行信息（虚位以待）
function M:hideRank( cur_LuaBehaviour, rank )
    local HeadNode = cur_LuaBehaviour:FindGameObject("HeadNode");
    HeadNode:SetActive(false);
    local good_num_bg = cur_LuaBehaviour:FindGameObject("good_num_bg");
    good_num_bg:SetActive(false);
    local player_name_txt = cur_LuaBehaviour:FindText("player_name");
    player_name_txt.text = Language:getTextByKey("new_str_0079");
end

-- 更新排行信息
function M:updateRank( cur_LuaBehaviour, rank_data )
    if cur_LuaBehaviour ~= nil then
        --玩家名字
        --rank_data.user = UserDataManager.user_data.user_status
        
        local player_name_txt = cur_LuaBehaviour:FindText("player_name");
        player_name_txt.text = rank_data.user.name;
        local HeadNode = cur_LuaBehaviour:FindGameObject("HeadNode")
        GameUtil:setUserAvatar(HeadNode, rank_data.user, nil, nil, {show_flag = true, scale = 0.7})
        local good_num_bg = cur_LuaBehaviour:FindGameObject("good_num_bg")
        local title_id = rank_data.user.title
        if good_num_bg then
            if title_id and title_id ~= 0 then
                good_num_bg.transform.anchoredPosition = Vector3.New(0, -273, 0)
                player_name_txt.transform.anchoredPosition = Vector3.New(0, -250, 0)
            else
                good_num_bg.transform.anchoredPosition = Vector3.New(0, -263, 0)
                player_name_txt.transform.anchoredPosition = Vector3.New(0, -225, 0)
            end
        end
        --上榜时间
        local starT = TimeUtil.gmTime(rank_data.time)
        local timerFormat = Language:getTextByKey("achievement_text14", starT.year, starT.month, starT.day)
        local good_num_txt = cur_LuaBehaviour:FindText("good_num_txt");
        good_num_txt.text = timerFormat;
    end
end


--[[
	任务列表
]]
function M:refreshTaskLoopScroll()
    self.m_click_cell_object = nil
    local data = self.m_model:getQuestSeasonByChapter(self.m_model.m_sel_tab_index)
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
                        self:updateMsg(status == 1 and "reward_btn" or "goto_btn", cell_data)
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
            self.m_loop_scroll_view:reloadData(data)
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
    UIUtil.setTextByLanKey(node.transform, "name_text", Language:getTextByKey(cfg.name))
    -- 描述
    UIUtil.setTextByLanKey(node.transform, "tips_text", Language:getTextByKey(cfg.task_des))
    -- 积分
    --UIUtil.setTextByLanKey(node.transform, "achievement_score_text", Language:getTextByKey("achievement_text21") .. (data.cfg.money_count))
    local score_item_node = luaBehaviour:FindGameObject("achievement_score_item_node")
    score_item_node:SetActive(true)
    if data.cfg.money_count > 0 then
        GameUtil:updateItemElement(score_item_node, { 149, 0, data.cfg.money_count}, true, true)
    else
        score_item_node:SetActive(false)
    end
    
    -- 进度条
    local slider = UIUtil.findSlider(node.transform, "progress_slider")
    slider.value = cur_progress/target_value

    local progress_slider_text = LuaBehaviourUtil.setTextByLanKey(luabe, "progress_slider_text", "new_str_0471", cur_progress, target_value)
    local finish_text = LuaBehaviourUtil.setTextByLanKey(luabe, "finish_text", "new_str_0470")
    local finish_text2 = LuaBehaviourUtil.setTextByLanKey(luabe, "finish_text2", "new_str_0562")
    -- 前往、领取按钮
    local goto_btn = UIUtil.findButton(node.transform, "goto_btn")
    local goto_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "goto_btn_text", "new_str_0029")
    local receive_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "receive_btn_text", "new_str_0056")
    local incomplete_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "incomplete_btn_text", "new_str_0057")
    local goto_btn_text_show = false
    local receive_btn_text_show = false
    local incomplete_btn_text_show = false
    UIUtil.setImg(node.transform, "a_ui_currency_btn_small_3", "common_ui", "goto_btn")
    if status == 0 then--前往
        local go_type = data.cfg.go_type or {}
        if _G.next(go_type) then
            if go_type[1] == 0 then --open_id为0，则前往任何地方
                goto_btn.gameObject:SetActive(false)
                goto_btn.enabled = false
            else
                goto_btn.gameObject:SetActive(not data.lock_flag)
                goto_btn.enabled = true
                goto_btn_text_show = true
            end
        else
            goto_btn.gameObject:SetActive(false)
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
    end
    goto_btn_text.gameObject:SetActive(goto_btn_text_show and not data.lock_flag)
    incomplete_btn_text.gameObject:SetActive(incomplete_btn_text_show and not data.lock_flag)
    receive_btn_text.gameObject:SetActive(receive_btn_text_show and not data.lock_flag)
    -- 解锁文本
    local lock_text = UIUtil.setTextByLanKey(node.transform, "lock_text", data.lock_text)

    local mask_show = data.lock_flag or status == -1
    UIUtil.setObjectVisible(node.transform, mask_show, "mask_img")
    lock_text.gameObject:SetActive(mask_show)
    finish_text.gameObject:SetActive(not data.lock_flag and status == -2)
    finish_text2.gameObject:SetActive(not data.lock_flag and status == -2)
    progress_slider_text.gameObject:SetActive(status ~= -1 and status ~= -2)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "more_btn", false)
end

-- 章节信息刷新
function M:refreshTopInfo()
    local chapter_season_info = self.m_model.chapter_season_list[self.m_model.m_sel_tab_index] or {}
    local chapter_info = self.m_model:getChapterInfoByChapterId(chapter_season_info.chapter)
    if chapter_info then
        self:setTextByLanKey("top_name_text", Language:getTextByKey(chapter_info.name))
        self:setTextByLanKey("top_tips_text", Language:getTextByKey(chapter_info.chapter_des))
        self:setTextByLanKey("top_reward_xianshi_text", Language:getTextByKey("achievement_text16"))
        
        self:setObjectVisible("top_reward_suo", false)
        if chapter_info.time_limit == 1 then
            self:setObjectVisible("top_reward_xianshi", false)
        else
            self:setObjectVisible("top_reward_xianshi", true)
        end
        
        -- 章节成就完成情况
        local complete_num, quest_num, received = self.m_model:getCompleteQuestNum(chapter_season_info.chapter)
        local lock_flag = self.m_model:checkChapterLockState()
        if lock_flag then
            self:setTextByLanKey("top_jindu_text", Language:getTextByKey("achievement_text3",complete_num, quest_num))
        else
            self:setObjectVisible("top_reward_suo", true)
            self:setTextByLanKey("top_jindu_text", Language:getTextByKey("achievement_text12"))
        end
        self:setTextByLanKey("top_time_text", Language:getTextByKey("achievement_text2",tostring(self.m_model.remainingDays)))
        -- 章节奖励
        local rewards = chapter_info.reward or {}
        local reward_node = self:findRectTransform("top_reward_node")
        local function callFun()
            if not received and complete_num>=quest_num then
                self:updateMsg("get_top_reward", {chapter_id =  self.m_model.m_sel_tab_index})
            end
        end
        GameUtil:createRewards(reward_node, rewards, true, complete_num~=quest_num, callFun, 0.85)
        self:setObjectVisible("UI_Achievement_JiangLi_001", false)
        if received then
            self:setTextByLanKey("top_jindu_text", Language:getTextByKey("achievement_text4"))
        elseif not received and complete_num >= quest_num then
            if lock_flag then
                self:setTextByLanKey("top_jindu_text", Language:getTextByKey("achievement_text15"))
            end
            self:setObjectVisible("UI_Achievement_JiangLi_001", true)
        end
    else
        Logger.logError("achievement_rewards 表 没有 赛季 "..self.m_model.m_season_id.. " 的数据")
    end
end

--英雄spine显示
function M:setSpine()
    local season_notice_cfg = ConfigManager:getCfgByName("season_notice")
    if season_notice_cfg and season_notice_cfg[self.m_model.m_season_id] then
        local spine_name = season_notice_cfg[self.m_model.m_season_id].travel_hero or "hero_0506_SkeletonData"
        local play_img = self:findGameObject("hero_sk")
        GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "idle", 0, true)
    end
end

function M:refreshWQLCRedPoint()
    if self.m_model:doesOldSeasonHadRewardToGet() == true then
        self:setObjectVisible("old_season_red_point", true)
    else
        self:setObjectVisible("old_season_red_point", false)
    end
    
    local season_red_point = RedPointUtil:hasRedPointById(336)
    self:setObjectVisible("season_red_point", season_red_point == true)
end

function M:destroy()
    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
    M.super.destroy(self)
end

return M
