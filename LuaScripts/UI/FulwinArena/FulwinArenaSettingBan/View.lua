local M = class("FulwinArenaSettingBanView", LikeOO.OOPopBase)

M.m_uiName = "FulwinArena/FulwinArenaSettingBan"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("common_title_text", "fylt_str_0049")
    self:setTextByLanKey("tips_text_1", "fylt_str_0062")
    self:setTextByLanKey("tips_text_2", "fylt_str_0063")
    self:setTextByLanKey("text_ok", "new_str_0006")
    for i=1, 7 do
        local race_cfg = GlobalConfig.TYPE_HERO_RACE[i]
        self:setImg(race_cfg.race_icon, ResourceUtil:getLanAtlas(), "camp_btn_" .. i)
    end

    for i=1, 6 do
        local job_cfg = GlobalConfig.CLASS_MERIDIAN[i]
        self:setImg(job_cfg.arena_icon, ResourceUtil:getLanAtlas(), "job_btn_" .. i)
    end
    
    self:refreshUI()
end

function M:refreshUI()
    for i=1, 7 do
        local race_flag = self.m_model.m_ban_race[i]
        self:setObjectVisible("camp_select_" .. i, race_flag == true)
    end

    for i=1, 6 do
        local job_flag = self.m_model.m_ban_role_type[i]
        self:setObjectVisible("job_select_" .. i, job_flag == true)
    end
end

return M














