local M = class("FulwinArenaSingleSettingView", LikeOO.OOPopBase)

M.m_uiName = "FulwinArena/FulwinArenaSingleSetting"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("common_title_text", "fylt_str_0048")
    self:setTextByLanKey("text_1", "fylt_str_0049")
    self:setTextByLanKey("text_2", "fylt_str_0050")
    self:setTextByLanKey("text_3", "fylt_str_0051")
    self:setTextByLanKey("text_4", "fylt_str_0052")
    self:setTextByLanKey("text_5", "fylt_str_0053")
    self:setTextByLanKey("text_6", "fylt_str_0054")
    self:setTextByLanKey("text_7", "fylt_str_0055")
    self:setTextByLanKey("text_8", "fylt_str_0056")
    self:setTextByLanKey("text_9", "fylt_str_0057")
    self:setTextByLanKey("text_10", "fylt_str_0058")
    self:setTextByLanKey("text_11", "legend_str_014", 60)
    self:setTextByLanKey("text_12", "legend_str_014", 120)
    self:setTextByLanKey("text_13", "fylt_str_0059")
    self:setTextByLanKey("text_14", "fylt_str_0060")
    self:setTextByLanKey("text_ok", "new_str_0006")
    if self.m_model.m_typ == 1 then
        self:setTextByLanKey("text_title", "fylt_str_0020")
    else
        self:setTextByLanKey("text_title", "fylt_str_0021")
    end
    
    self.ban_add_img = self:findGameObject("ban_add_img")
    self.ban_node = self:findGameObject("ban_node")

    self.pswd_input = self:findInputField("pswd_input")
    self.pswd_input.placeholder.text = Language:getTextByKey("fylt_str_0061")
    self.pswd_input.text = self.m_model.m_pswd

    for i,v in pairs(self.m_model.m_team_type_toggle) do
        local tog_btn = self:findToggle(v.toggle)
        if v.value == self.m_model.m_team_type then
            tog_btn.isOn = true
        end
        UIUtil.addToggleListener(tog_btn, function(is_on)
            if is_on then
                self:updateMsg("set_team_type", v.value)
            end
            audio:SendEvtUI("Play_UI_NormalClick")
        end, nil, self.m_uiName)
    end

    --for i,v in pairs(self.m_model.m_arraying_time_toggle) do
    --    local tog_btn = self:findToggle(v.toggle)
    --    if v.value == self.m_model.m_arraying_time then
    --        tog_btn.isOn = true
    --    end
    --    UIUtil.addToggleListener(tog_btn, function(is_on)
    --        if is_on then
    --            self:updateMsg("set_arraying_time", v.value)
    --        end
    --    end, nil, self.m_uiName)
    --end

    for i,v in pairs(self.m_model.m_pswd_toggle) do
        local tog_btn = self:findToggle(v.toggle)
        if v.value == self.m_model.m_pswd_type then
            tog_btn.isOn = true
        end
        UIUtil.addToggleListener(tog_btn, function(is_on)
            if is_on then
                self:updateMsg("set_pswd_type", v.value)
            end
            audio:SendEvtUI("Play_UI_NormalClick")
        end, nil, self.m_uiName)
    end

    local fair_toggle = self:findToggle("fair_toggle")
    fair_toggle.isOn = self.m_model.m_fair == 1
    UIUtil.addToggleListener(fair_toggle, function(is_on)
        self:updateMsg("set_fair", is_on)
        audio:SendEvtUI("Play_UI_NormalClick")
    end, nil, self.m_uiName)
    
    self:refreshUI()
    
    local share_toggle = self:findToggle("share_toggle")
    UIUtil.addToggleListener(share_toggle, function(is_on)
        audio:SendEvtUI("Play_UI_NormalClick")
    end, nil, self.m_uiName)
end

function M:getShareToggleStatus()
    local share_toggle = self:findToggle("share_toggle")
    if share_toggle then
        return share_toggle.isOn
    end
end

function M:getPswd()
    local text = self.pswd_input.text
    return text
end

function M:refreshUI()
    UIUtil.destroyAllChild(self.ban_node.transform)
    if #self.m_model.m_ban_race == 0 and #self.m_model.m_ban_role_type == 0 then
        local img = GameUtil:instanceObject(self.ban_add_img, self.ban_node)
        img:SetActive(true)
    else
        for i,v in ipairs(self.m_model.m_ban_race) do
            local img = GameUtil:instanceObject(self.ban_add_img, self.ban_node)
            img:SetActive(true)
            local race_cfg = GlobalConfig.TYPE_HERO_RACE[v]
            UIUtil.setImg(img.transform, race_cfg.race_icon, ResourceUtil:getLanAtlas())
        end

        for i,v in ipairs(self.m_model.m_ban_role_type) do
            local img = GameUtil:instanceObject(self.ban_add_img, self.ban_node)
            img:SetActive(true)
            local job_cfg = GlobalConfig.CLASS_MERIDIAN[v]
            UIUtil.setImg(img.transform, job_cfg.arena_icon, ResourceUtil:getLanAtlas())
        end
    end

    self:setObjectVisible("pswd_input", self.m_model.m_pswd_type == 1)
end

return M














