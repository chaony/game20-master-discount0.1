---@class HalfAnniversaryTotalTaskView: OOPopBase
---@field m_model HalfAnniversaryTotalTaskModel
local M = class("HalfAnniversaryTotalTaskView", LikeOO.OOPopBase)

M.m_uiName = "HalfAnniversary/HalfAnniversaryTotalTask"
M.m_size_type = 1
M.m_iphoneXAdapter = true


function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, { self, self.everyDayRefreshEvent })
    self:bindUI()
    self:refreshUI()
end

function M:refreshUI()
    self:refreshActivityTimer()
    self:refreshAwardNode()
    self:refreshScoreAndSlider()
    self:refreshMiddleNode()
end

function M:bindUI()
    self:setTextByLanKey("close_title_text", "half_year_text_0003")
    self:setTextByLanKey("text_title", "half_year_text_0008")
    self:setTextByLanKey("text_previewTitle", "half_year_text_0009")
    self.m_new_box_reward_slider = self:findSlider("progress_slider")
end


function M:refreshScoreAndSlider()
    -- 进度条，总积分，我的积分
    self:setTextByLanKey("totalScoreNum_text", "half_year_text_0008", GameUtil:formatValueToString(self.m_model.m_score))
    self:setTextByLanKey("myScoreNum_text", "half_year_text_0009", GameUtil:formatValueToString(self.m_model.m_self_score))
    self:refreshSlider()
end

function M:refreshAwardNode()
    local awardData = self.m_model.m_allAwardsData
    if #awardData ~= 5 then
        Logger.logError("please check config half_year_reward whether the length is 5")
        return
    end
    for i = 1, 5 do
        local itemData = awardData[i]
        local xlsxData = itemData.xlsxData
        local score = xlsxData.score ~= nil and xlsxData.score or 0
        local isCanRecv = (self.m_model.m_score >= score) and (not itemData.isReceived)
        local item_parent = self:findRectTransform("Award" .. i)
        UIUtil.destroyAllChild(item_parent)
        GameUtil:createRewards(item_parent, { xlsxData.reward[1] }, true, true, nil, 1)
        self:setObjectVisible("canReceived" .. i, isCanRecv)
        self:setObjectVisible("Received" .. i, itemData.isReceived)
        self:setText("num_text" .. i, GameUtil:formatValueToString(score))
    end
end

function M:refreshTaskList()
    -- 任务列表
    local data = self.m_model.m_taskData.allTaskData
    if self.m_taskScroll_view == nil then
        local loopscroll = self:findGameObject("task_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:refreshTaskItem(cell_obj, cell_data, false)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                audio:SendEvtUI("Play_UI_NormalClick")
                if click_name == "btn_goBtn" then
                    local xlsxData = cell_data.xlsxData
                    local jumpId = xlsxData.go_type
                    static_rootControl:closeAllViewPop()
                    QuickOpenFuncUtil:openFunc(jumpId)
                elseif click_name == "btn_getBtn" then
                    local params = { vsn = self.m_model.m_version, quest_id = cell_data.id }
                    self.m_model:getNetData("half_year_quest_reward", params, function(response)
                        if response then
                            if self.m_control:activityOverExamine(response) then
                                return
                            end
                            local tempAwardIndex = clone(self.m_model.m_curAwardIndex)
                            RewardUtil:rewardTipsByData(response.reward)
                            self.m_model:refreshActivityData(response)
                            self.m_model:setAllTaskData()
                            self:refreshTaskList()
                            self:refreshScoreAndSlider()
                        end
                    end, nil, nil, nil)
                elseif click_name == "jifen_obj" then
                    -- 点击积分弹出
                    GameUtil:lookInfoTips(self.m_control, { click_transform = click_object.transform, msg = Language:getTextByKey("half_year_text_0020") })
                end
            end
        }
        self.m_taskScroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_taskScroll_view:reloadData(data, true)
    end
end

function M:refreshSlider()
    local awardData = self.m_model.m_allAwardsData
    local max_index = 0
    local cur_stage_num = 0
    local stage = 0.2   --一共5个
    local left_num = self.m_model.m_score
    local slider_value = 0.0
    for index, awardItemData in ipairs(awardData) do
        local itemXlsxData = awardItemData.xlsxData
        cur_stage_num = itemXlsxData.score
        if left_num >= cur_stage_num then
            max_index = index
        else
            break
        end
    end
    if max_index == 0 then
        slider_value = (left_num / awardData[1].xlsxData.score) * stage
    elseif max_index >= 5 then
        slider_value = 1.0
    else
        local stage_num = awardData[max_index + 1].xlsxData.score -  awardData[max_index].xlsxData.score
        left_num = left_num - awardData[max_index].xlsxData.score
        slider_value = stage * max_index + (left_num / stage_num) * stage
    end
    self.m_new_box_reward_slider.value = slider_value
end

function M:refreshTaskBtns(luaBehaviour, status)
    if luaBehaviour then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "btn_goBtn", status == 0)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "btn_gotBtn", status == 2)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "btn_getBtn", status == 1)
    end
end

function M:refreshTaskItem(cell_obj, cell_data, isCurDayTask)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaviour then
        local xlsxData = cell_data.xlsxData
        local serverData = cell_data.serverData
        if not serverData then
            Logger.logError("serverData没有数据,id is" .. cell_data.id)
        end
        local targetValue = xlsxData.target_value
        local curValue = (serverData.value ~= nil) and serverData.value or 0
        curValue = curValue > targetValue and targetValue or curValue
        local value_text = Language:getTextByKey("half_year_text_0021", curValue, targetValue)
        local name_text= Language:getTextByKey(xlsxData.name)
        LuaBehaviourUtil.setText(luaBehaviour,"text_taskTitle", name_text .. value_text) 
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "text_goBtnText", "castingSword_str_0004")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "text_gotBtnText", "castingSword_str_0005")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "text_getBtnText", "castingSword_str_0014")
        self:refreshTaskBtns(luaBehaviour, serverData.status)
        -- 积分道具
        local isExistProp = xlsxData.score and (xlsxData.score > 0)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "jifen_obj", isExistProp)
        local awardPoint = luaBehaviour:FindGameObject("awardPoint")
        local posX = isExistProp and (60.9) or (-0.9)
        if isCurDayTask then
            posX = isExistProp and (-3.4) or (-65.4)
        end
        UIUtil.setLocalPosition(awardPoint.transform, posX)
        local transform = awardPoint.transform
        if isExistProp then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "reward_num_text", xlsxData.score)
        end

        -- 奖励
        for i = 1, 3 do
            local awardData = xlsxData.reward or {}
            local reward_node = UIUtil.findRectTransform(transform, "taskAwardNode" .. i)
            UIUtil.destroyAllChild(reward_node)
            if awardData[i] then
                local itemNode = GameUtil:createItemElement(awardData[i], true, true)
                itemNode.transform:SetParent(reward_node.transform, false)
            end
        end
    end
end

function M:refreshMiddleNode()
    self:refreshTaskList()
    self:refreshCurDayItem()
end


function M:everyDayRefreshEvent()
    self:updateMsg("everyDayRefresh")
   
end

function M:refreshCurDayItem()
    local myTaskItem = self:findGameObject("myTaskItem")
    local luaBehaviour = UIUtil.findLuaBehaviour(myTaskItem)
    local curDayIndex = self.m_model:getActivityOpenDay()
    curDayIndex = math.floor(curDayIndex)
    local isOver = curDayIndex > self.m_model:getMaxTaskDay()
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "jifen_obj", not isOver)
    curDayIndex = curDayIndex <= 0 and 1 or curDayIndex
    local itemData = self.m_model.m_taskData.dayTaskData[curDayIndex] or {}
    if not itemData.serverData or not itemData.serverData.status then
        self:everyDayRefreshEvent()
        Logger.log("庆典装扮serverData没有第" .. curDayIndex.."天数据,重新请求数据")
        return
    end
    self:refreshTaskItem(myTaskItem, itemData, true)
end

function M:refreshActivityTimer()
    local startTimer = self.m_model.m_activityData.start_ts
    local endTimer = self.m_model.m_activityData.end_ts
    local starT = TimeUtil.gmTime(startTimer)
    local endT = TimeUtil.gmTime(endTimer)
    local timerFormat = Language:getTextByKey("castingSword_str_0012", starT.year, starT.month, starT.day,
            endT.year, endT.month, endT.day)
    self:setTextByLanKey("text_timer", "castingSword_str_0011", timerFormat)
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, { self, self.everyDayRefreshEvent })
    M.super.destroy(self)
end

return M