---@class DeliciousFeastBlessView: OOPopBase
---@field m_model DeliciousFeastBlessModel
local M = class("DeliciousFeastBlessView", LikeOO.OOPopBase)

M.m_uiName = "Activities/DeliciousFeast/DeliciousFeastBless"
M.m_size_type = 1
M.m_iphoneXAdapter = true

local TAB_BTN_NODE = {
    { btn_key = "tgl_btn1", btn_text = "tgl_text1", text_key = "feast_text_0006", red_img = "red_point1" }, -- 日常
    { btn_key = "tgl_btn2", btn_text = "tgl_text2", text_key = "feast_text_0007", red_img = "red_point2" }, -- 总计
}
function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, { self, self.everyDayRefreshEvent })
    self:bindUI()
    self:refreshUI()
    self:refreshBless()
    self:refreshRedPoint()
end

function M:refreshUI()
    self.m_content_panel = self:findGameObject("scroll_content")
    for k, v in pairs(TAB_BTN_NODE) do
        self:setTextByLanKey(v.btn_text, Language:getTextByKey(v.text_key))
        local tgl_btn = self:findToggle(v.btn_key)
        tgl_btn.isOn = k == self.m_model:getCurTabIndex()
        UIUtil.addToggleListener(tgl_btn, function(isOn)
            self:changeTab(isOn, v.btn_key)
        end, nil, self.m_uiName)
    end
    self:switchTabNode()
end

function M:bindUI()
    self:setTextByLanKey("bless_title_text", "feast_text_0001")
    self:setTextByLanKey("task_title_text", "feast_text_0008")
    self:setTextByLanKey("bless_text", "feast_text_0009")
    self:setTextByLanKey("close_title_text", "feast_text_0001")
    self:setTextByLanKey("need_text", "feast_text_0019", self.m_model:getNeedBless())
    local isOfficial = self.m_model:checkIsOfficial()
    local spine_name = self.m_model:getSpineName()
    local spine_img
    if isOfficial then
        spine_img = self:findGameObject("meituan_spine")
        GameUtil:updateSpineLoadSet(spine_img,"RoleSpine/" .. spine_name.meituan,"idle", 0,true)
    else
        spine_img = self:findGameObject("hero_spine")
        GameUtil:updateSpineLoadSet(spine_img,"RoleSpine/" .. spine_name.xian,"idle", 0,true)
    end
end

function M:refreshRedPoint()
    for k, v in pairs(TAB_BTN_NODE) do
        self:setObjectVisible(v.red_img, self.m_model:getRedPointFlag(k))
    end
end

function M:refreshBless()
    local num = self.m_model:getBlessNum()
    --local isCanBless = self.m_model:checkCanBless()
    --self:setObjectVisible("gray_img", not isCanBless)
    --self:setObjectVisible("normal_img", isCanBless)
    self:setTextByLanKey("num_text", "feast_text_0010", num)
end

function M:changeTab(isOn, update_key)
    if isOn and self.m_model:getCurTabIndex() ~= update_key then
        self:updateMsg(update_key)
    end
end

function M:switchTabNode()
    self:refreshTaskLoopScrollList()
end

function M:refreshTaskLoopScrollList()
    local data = self.m_model:getTaskData()
    if self.task_loopscroll == nil then
        self.task_loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = self.task_loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateQuestsScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                local status = cell_data.status
                if status ~= -1 and click_name == "go_btn" then
                    self:updateMsg(status == 2 and "recvReward" or "goto_btn", cell_data)
                end
            end
        }
        self.task_loopscroll = LoopScrollViewUtil.new(params)
    else
        self.task_loopscroll:reloadData(data, false)
    end
end

--Scroll内cell的回调
function M:updateQuestsScrollViewCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local data = cell_data
    local cfg = data.cfg
    local cur_progress = data.cur_progress
    local target_value = data.target_value
    local status = data.status
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title_text", cfg.name)     --任务标题
    local progress_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "progress_text", "new_str_0471", cur_progress, target_value)   --进度
    local finish_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "finish_text", "new_str_0058")   --已领取文字
    local goto_btn = luaBehaviour:FindButton("go_btn")    -- 前往、领取按钮
    local goto_btn_text
    --local receive_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "receive_btn_text", "new_str_0056")
    local incomplete_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "incomplete_btn_text", "new_str_0057")
    local goto_btn_text_show = false
    local incomplete_btn_text_show = false
    if status == 0 then
        --未完成
        goto_btn.gameObject:SetActive(not data.lock_flag)
        local go_type = cfg.go_type or {}
        LuaBehaviourUtil.setImg(luaBehaviour, "go_btn", "a_ui_currency_btn_small_3", "common_ui")
        if next(go_type) then
            --显示前往
            goto_btn.enabled = true
            goto_btn_text_show = true
            goto_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "goBtn_text", "new_str_0029")
        else
            --显示未完成
            goto_btn.enabled = false
            incomplete_btn_text_show = true
        end
    elseif status == 2 then
        --已完成可领取
        goto_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "goBtn_text", "new_str_0056")
        progress_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "progress_text", "new_str_0562") --已完成
        goto_btn.enabled = true
        goto_btn_text_show = true
        LuaBehaviourUtil.setImg(luaBehaviour, "go_btn", "a_ui_currency_btn_small_2", "common_ui")
    end
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "bless_num_text", "feast_text_0021", cfg.points)
    finish_text.gameObject:SetActive(status == -1)
    goto_btn.gameObject:SetActive(goto_btn_text_show)
    progress_text.gameObject:SetActive(not data.lock_flag and status ~= -1)
    incomplete_btn_text.gameObject:SetActive(incomplete_btn_text_show)
    local btn_spine = luaBehaviour:FindRectTransform("btn_spine")
    btn_spine.gameObject:SetActive(not data.lock_flag and status == 2)
    -- 奖励
    local drop = cfg.reward or {}
    local reward_node = luaBehaviour:FindRectTransform("itemParent")
    GameUtil:createRewards(reward_node, drop, true, true, nil, 1)
end

function M:everyDayRefreshEvent()
    self:updateMsg("daily_update_data")
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, { self, self.everyDayRefreshEvent })
    self.m_control:updateMsg("refreshRedPoint", nil, "Activities.DeliciousFeast.DeliciousFeastMain")
    M.super.destroy(self)
end

return M