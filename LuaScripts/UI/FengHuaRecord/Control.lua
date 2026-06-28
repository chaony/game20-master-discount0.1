local M = class("FengHuaRecordControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "close_btn" then    -- 返回
        self:updateMsg("fenghua_close", nil, "Xian")
        self:closeView()
    elseif msg == "level_toggle" then
        self.m_view:refreshUI()
    elseif msg == "image" then
        self.m_model.m_select_skin_id = data
        local have_flag = self.m_model:getSkinHave(data)
        self:updateMsg("select_skin", {skin_id = data,flag = have_flag}, "Xian")
        --self:openView("FengHuaRecord.BuySkin",{skin_id = data,flag = have_flag})
    elseif msg == "updateFengHualist" then
        self:refreshData()
    elseif msg == "help_btn" then
        local content = Language:getTextByKey("tid#fenghuaRuleDes_1")
        local cfg = ConfigManager:getCfgByName("open_condition")
        local name_key = cfg[372].name
        local name = Language:getTextByKey(name_key)
        self:openView("Pops.CommonHelpPop", { title = name, content = content})
    elseif msg == "set_btn" then
        local id = self.m_model.m_select_skin_id
        local have_flag = self.m_model:getSkinHave(id)
        if have_flag == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("fenghua_record_text11"), delay_close = 2})
            return
        end
        self:requestChangeSkin(id)
    end
end

function M:refreshData()
    local function callbcak(response)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("fenghua_record_index", nil, callbcak)
end

function M:requestChangeSkin(skin_id)
    local function callbcak(response)
        self.m_view:refreshSkinCheck()
        self:updateMsg("set_skin", response.skin_id, "Xian")
    end
    local params = {}
    params.skin_id = skin_id
    self.m_model:getNetData("fenghua_record_change_skin", params, callbcak)
end

return M