local M = class("FulwinArenaSingleMainView", LikeOO.OOPopBase)

M.m_uiName = "FulwinArena/FulwinArenaSingleMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self:setTextByLanKey("close_title_text", "fylt_str_0020")
    self:setTextByLanKey("text_chat", "fylt_str_0064")
    self:setTextByLanKey("text_put", "options_str_0011")
    self:setTextByLanKey("text_btn_formation", "fylt_str_0065")
    self:setTextByLanKey("text_ok", "fylt_str_0068")
    self:setTextByLanKey("text_move", "fylt_str_0067")
    self:setTextByLanKey("text_battle", "fylt_str_0066")
    self:setTextByLanKey("right_no_rank_text", "new_str_0835")
    self:setTextByLanKey("left_qipao_text", "fylt_str_0074")
    self:setTextByLanKey("right_qipao_text", "fylt_str_0075")
    self:setTextByLanKey("duijue_text", "new_str_0297")
    
    self:refreshUI()

end

function M:refreshUI()
    self:setTextByLanKey("house_num_text", Language:getTextByKey("fylt_str_0070") .. self.m_model.m_ring_id)
    local is_president = self.m_model:isPresident()
    self:setObjectVisible("btn_put", is_president)
    self:setObjectVisible("btn_battle", is_president)
    self:setObjectVisible("btn_move", is_president)
    self:setObjectVisible("left_player_btn", not is_president)
    self:setObjectVisible("right_player_btn", is_president)

    if self.m_model:isFreshPresident() then
        self:setLeftSpine()
    end
    if self.m_model:isFreshPlayer() then
        self:setRightSpine()
    end

    if self.m_model:isFreshReady() then
        local user = self.m_model:getPlayerUser()
        if user then
            self:setObjectVisible("right_qipao_node", user.ready == 1)
            self:setObjectVisible("btn_ok", not is_president and user.ready == 0)
        else
            self:setObjectVisible("right_qipao_node", false)
            self:setObjectVisible("btn_ok", false)
        end
    end

    local races = self.m_model:getDisableRace()
    local jobs = self.m_model:getDisableJob()
    if #races == 0 and #jobs == 0 then
        self:setObjectVisible("ban_text", false)
        self:setObjectVisible("ban_bg_img", false)
    else
        self:setObjectVisible("ban_text", true)
        self:setObjectVisible("ban_bg_img", true)
        for i=1, 4 do
            local race = self.m_model:getDisableRaceByIndex(i)
            if race then
                self:setObjectVisible("race_img_" .. i, true)
                local race_cfg = GlobalConfig.TYPE_HERO_RACE[race]
                if race_cfg then
                    self:setImg(race_cfg.race_icon, ResourceUtil:getLanAtlas(), "race_img_" .. i)
                else
                    self:setObjectVisible("race_img_" .. i, false)
                end
            else
                self:setObjectVisible("race_img_" .. i, false)
            end
            local job = self.m_model:getDisableJobByIndex(i)
            if job then
                self:setObjectVisible("job_img_" .. i, true)
                local job_cfg = GlobalConfig.CLASS_MERIDIAN[job]
                if job_cfg then
                    self:setImg(job_cfg.arena_icon, ResourceUtil:getLanAtlas(), "job_img_" .. i)
                else
                    self:setObjectVisible("job_img_" .. i, false)
                end
            else
                self:setObjectVisible("job_img_" .. i, false)
            end
        end
    end

    local format_red = self.m_model:teamFormationRed()
    self:setObjectVisible("formation_red_img", format_red)
end

function M:setLeftSpine()
    local user = self.m_model:getPresidentUser()
    if user then
        local cfg = ConfigManager:getPlayerPictureCfg(user.user_info.avatar)
        local hero_sk = self:findGameObject("left_hero_spine")
        GameUtil:updateSpineLoadSet(hero_sk, "RoleSpine/" .. tostring(cfg.hero_spine), "idle", 0, true)
        self:setObjectVisible("left_hero_spine", true)
        self:setTextByLanKey("left_name_text", user.user_info.name)
        self:setObjectVisible("left_rank_text", false)
        local rank = user.arena_rank > 0 and user.arena_rank or Language:getTextByKey("fylt_str_0039")
        self:setTextByLanKey("left_rank_text", "fylt_str_0077", rank)
        local tx_rank = user.high_arena_rank <= 0 and 999999 or user.high_arena_rank
        local cfg = ConfigManager:getHighArenaCfgByRank(tx_rank)
        self:setTextByLanKey("left_tx_rank_text", "fylt_str_0078", Language:getTextByKey(cfg.division_name ))
        self:setText("left_power_text", GameUtil:formatValueToString(user.user_info.full_combat))
    end
end

function M:setRightSpine()
    local user = self.m_model:getPlayerUser()
    if user then
        local cfg = ConfigManager:getPlayerPictureCfg(user.user_info.avatar)
        local hero_sk = self:findGameObject("right_hero_spine")
        GameUtil:updateSpineLoadSet(hero_sk, "RoleSpine/" .. tostring(cfg.hero_spine), "idle", 0, true)
        self:setObjectVisible("right_hero_spine", true)
        self:setObjectVisible("right_name_text", true)
        self:setObjectVisible("right_rank_text", false)
        self:setObjectVisible("right_tx_rank_text", true)
        self:setObjectVisible("right_no_rank_text", false)
        self:setObjectVisible("btn_invite", false)
        self:setTextByLanKey("right_name_text", user.user_info.name)
        local rank = user.arena_rank > 0 and user.arena_rank or Language:getTextByKey("fylt_str_0039")
        self:setTextByLanKey("right_rank_text", "fylt_str_0077", rank)
        local tx_rank = user.high_arena_rank <= 0 and 999999 or user.high_arena_rank
        local cfg = ConfigManager:getHighArenaCfgByRank(tx_rank)
        self:setTextByLanKey("right_tx_rank_text", "fylt_str_0078", Language:getTextByKey(cfg.division_name ))
        self:setText("right_power_text", GameUtil:formatValueToString(user.user_info.full_combat))
    else
        self:setObjectVisible("right_hero_spine", false)
        self:setObjectVisible("right_name_text", false)
        self:setObjectVisible("right_rank_text", false)
        self:setObjectVisible("right_tx_rank_text", false)
        self:setObjectVisible("right_qipao_node", false)
        self:setObjectVisible("right_no_rank_text", true)
        self:setObjectVisible("btn_invite", true)
        self:setText("right_power_text", 0)
    end
end

return M














