local M = class("KingsoftPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if self.m_model.m_is_show_logo then
        return
    end
    if msg == 99999 or msg == "close_btn2" then    -- 返回
        self:closeView()
    elseif msg == "change_game" then
        self.m_view:changeNode()
    elseif msg == "help" then
        self.m_view:changeNode()
    elseif msg == "about_game" then
        self.m_view:changeNode()
    elseif msg == "game_help" then
        self.m_view:changeNode()
    elseif msg == "open_change_pop" then
        audio:SendEvtUI("UI_DJSJLan")
        local cell_data = data
        self.m_view:refreshUi()
        local max_data = self.m_model:getMaxData()
        self:openView("Activities.Kingsoft.KingSoftChange", {vsn = self.m_model.m_version, cell_data = cell_data, max_data = max_data})
    elseif msg == "search_top_btn" then
        self.m_view:changeBarValue("search_bar", true)
    elseif msg == "search_bottom_btn" then
        self.m_view:changeBarValue("search_bar", false)
    elseif msg == "reaults_top_btn" then
        self.m_view:changeBarValue("result_bar", true)
    elseif msg == "reaults_bottom_btn" then
        self.m_view:changeBarValue("result_bar", false)
    elseif msg == "search_btn" then
        audio:SendEvtUI("UI_DJSSUO")
        local value = self.m_view:getMsg() or ""
        if value and value ~= "" then
            self:requestSearch(value)
        end
    elseif msg == "capture" then
        self.m_view:ShareShow(false)
        local show_call = function()
            self.m_view:ShareShow(true)
        end
        self:openView("SharePictureNoLogo", {picture_callback = show_call})
    elseif msg == "show_tips" then
        local index = data.index
        local tips_id = data.tips_id
        local target_obj = data.cell_object
        self.m_view:showTips(target_obj, tips_id)
    elseif msg == "select_data" then
        local show_id = data
        local can_select, tips_str = self.m_model:isCanSelect(show_id)
        audio:SendEvtUI("UI_DJSJLan")
        if can_select then
            self:requestSelect(show_id)
        else
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey(tips_str), delay_close = 2})
        end
    elseif msg == "refrehIndex" then
        if data and data.new_data then
            self.m_model:updateData(data.new_data)
            self.m_view:refreshUi()
        end
    elseif msg == "close_tips_btn" then
        self.m_view:closeTips()
    end
end

function M:requestSearch(value)
    local function searchCallback(response)
        self.m_model.m_select_total_times = self.m_model.m_select_total_times + 1
        self.m_model:updateData(response)
        self.m_view:refreshUi()
    end
    local params = {}
    params.value = tonumber(value)
    params.vsn = self.m_model.m_data.kingsoft_ranger and self.m_model.m_data.kingsoft_ranger.version or 1
    self.m_model:getNetData("active_kingsoft_find", params, searchCallback)
end

function M:requestSelect(show_id)
    local function selectCallback(response)
        self.m_model:updateData(response)
        self.m_view:refreshUi()
    end
    local params = {}
    params.date_id = show_id
    params.vsn = self.m_model.m_data.kingsoft_ranger and self.m_model.m_data.kingsoft_ranger.version or 1
    self.m_model:getNetData("active_kingsoft_select", params, selectCallback)
end

function M:requestIndex(show_id)
    local function indexCallback(response)
        self.m_model:updateData(response)
        self.m_view:refreshUi()
    end
    local params = {}
    self.m_model:getNetData("active_kingsoft_index", nil, indexCallback)
end

return M;
