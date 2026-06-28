local M = class("MercenaryHandlePopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:updateMsg("refresh_ui", nil, "Friend")
        self:closeView()
    elseif msg == "back_btn" then
        self:closeView()
    elseif msg == "tab_btn" then
        self.m_model:setTabIndex(data)
        if self.m_model:isHaveData() then
            self.m_view:refreshUI()
        else
            self:freshData()
        end
    elseif msg == "agree_btn" then
        self:agreeRequest(data)
    elseif msg == "all_agree_btn" then
        self:agreeRequest()
    elseif msg == "cancel_btn" then
        self:rejectRequest(data)
    elseif msg == "all_ignore_btn" then
        self:rejectRequest()
    elseif msg == "refresh_data" then
        self:freshData()    
    end
end

function M:freshData()
    if self.m_model.m_tab_index == 1 then
        self:requestApplaydata()
    else
        self:requestLendData()
    end
end

function M:requestApplaydata()
    local function callback(response)
        self.m_model:setApplayListData(response.apply_list)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("apostle_apply_info", nil, callback)
end

function M:requestLendData()
    local function callback(response)
        self.m_model:setOutListData(response.lend_list)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("apostle_lend_info", nil, callback)
end

function M:agreeRequest(data)
    local function agreeBack(response)
        self.m_model:setApplayListData(response.apply_list)
        self.m_model:setOutListData(response.lend_list)
        self.m_view:refreshUI()
    end
    local params = {}
    if data then
        params.target_uid = data.user.uid
        params.hero_oid = data.hero_oid
    else
        params.is_all = 1
    end
    self.m_model:getNetData("apostle_agree", params, agreeBack)
end

function M:rejectRequest(data)
    local function rejectBack(response)
        self.m_model:setApplayListData(response.apply_list)
        self.m_model:setOutListData(response.lend_list)
        self.m_view:refreshUI()
    end
    local params = {}
    if data then
        params.target_uid = data.user.uid
        params.hero_oid = data.hero_oid
    else
        params.is_all = 1
    end
    self.m_model:getNetData("apostle_reject", params, rejectBack)
end

return M;
