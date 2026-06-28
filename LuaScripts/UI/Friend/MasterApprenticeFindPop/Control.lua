local M = class("MasterApprenticeFindPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()   
    elseif msg == "CloseBtn" then
        self:closeView()    
    elseif msg == "tab_btn" then
        if data ~= self.m_model.m_tab_index then
            self.m_model:setTabIndex(data)
            self.m_view:AddChildPanel()
            self.m_view:refreshUI()
        end 
    elseif msg == "refresh_btn" then
        self:requestRecommend()
    elseif msg == "doing_apply" then
        self:requestDoingApply(data)
    elseif msg == "handle_apply" then
        self:requestHandleApply(data)
    elseif msg == "clear_btn" then
        self:requestClearHandleApply()
    elseif msg == "cell_tab_btn" then
        if data ~= self.m_model.m_flag + 1 then
            self:requestSetFlag()   
        end
    elseif msg == "change_desc_btn" then
        local params = {
            title = Language:getTextByKey("master_apprentice_str_0014") ,
            on_cancel_call = handler(self, self.requestSetDesc)
        }
        self:openView("Pops.CommonEditContentPop", params)    
    end
end

--设置宣言
function M:requestSetDesc(str)
    local function callback(response)
        self.m_model.m_desc =str
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("mentorship_set_desc", {desc = str } , callback)
end

--设置免打扰
function M:requestSetFlag()
    local function callback(response)
        self.m_model.m_flag = response.flag
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("mentorship_set_flag", nil, callback)
end

--刷新
function M:requestRecommend()
    local function callback(response)
        self.m_model.m_recommend  = response.recommend
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("mentorship_recommend", nil, callback)
end

--申请
function M:requestDoingApply(data)
    local function callback(response)
        local params =
        {
            no_close_btn = true,
            text = Language:getTextByKey("master_apprentice_str_0013") 
        }
        self:openView("Pops.CommonPop", params) 
    end
    self.m_model:getNetData("mentorship_doing_apply", {invite_uid = data}, callback)
end

--处理申请 
function M:requestHandleApply(data)
    local function callback(response)
        self.m_model:disposeApply(response.invite_uid)
        if response.status == 0 then --拒绝
            self.m_view:refreshUI()
        elseif response.status == 1 then --同意
            self:updateMsg("masterFreshData", data, "Friend")
            self:closeView()   
        end
    end
    local params = {
        invite_uid = data.uid,
        status = data.status
    }
    self.m_model:getNetData("mentorship_handle_apply", params, callback)
end

--清空申请 
function M:requestClearHandleApply()
    local function callback(response)
        self.m_model:disposeApply()
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("mentorship_handle_apply", {clear = 1}, callback)
end

--更新
function M:requestBaseData()
    local function callback(response)
        self.m_model:initData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("mentorship_info", nil, callback)
end

return M;
