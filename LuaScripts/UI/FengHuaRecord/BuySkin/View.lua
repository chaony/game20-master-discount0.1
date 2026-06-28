local M = class("BuySkinView",LikeOO.OOPopBase)

M.m_uiName = "FengHuaRecord/BuySkin"
M.m_iphoneXAdapter = true
M.m_size_type = 1

function M:onEnter()
    --self.m_gray = self:findImage("tool_gray")
    
    local btn_go = self:findGameObject("tujian_upgrade")
    btn_go:SetActive(not self.m_model.have_flag)
    
    if self.m_model.select_skin_cfg.whether  == 1 then
        self:setTextByLanKey("levelup_btn_text", "fenghua_record_text8")
        local consItem = RewardUtil:getProcessRewardData(self.m_model.select_skin_cfg.cost[1])
        self:setImg(consItem.icon_name, consItem.atlas_name, "cons_img")
        local usernum = 0
        if consItem.user_num > 100000 then
            usernum = GameUtil:formatValueToString(consItem.user_num)
        else
            usernum = consItem.user_num
        end
        if consItem.user_num < consItem.data_num then
            self:setTextByLanKey("cons_num", "equip_str_033" ,tostring(usernum) ,tostring(consItem.data_num))
        else
            self:setTextByLanKey("cons_num", tostring(usernum).."/"..tostring(consItem.data_num))
        end
    else
        --self:setTextByLanKey("levelup_btn_text", "fenghua_record_text9")
        --local cons_go = self:findGameObject("cons_bg")
        --local btn_img = self:findImage("levelup_btn")
        --btn_img.material = self.m_gray.material
        --cons_go:SetActive(false)
        btn_go:SetActive(false)
    end
    
    self:setHeroInfo()
    self:setSpine()
end

function M:setSpine()
    local spine_name = self.m_model.select_skin_cfg.spine or "hero_0001_SkeletonData"
    local play_img = self:findGameObject("hero_spine")
    GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "", 0, true)
end

function M:setHeroInfo()
    local class_str = Language:getTextByKey(self.m_model.m_hero_cfg.class)
    local name_str = Language:getTextByKey(self.m_model.m_hero_cfg.name)
    self:setTextByLanKey("hero_name", name_str)
    self:setTextByLanKey("hero_name2", class_str)
    local race = GlobalConfig.TYPE_HERO_RACE[self.m_model.m_hero_cfg.race].big_race_icon
    self:setImg(race,  ResourceUtil:getLanAtlas(), "hero_race")
    --local frame_data = GlobalConfig.QUALITY_FRAME[self.m_model.m_hero_cfg.max_evo]
    self:setImg(GameUtil:get_lineframename(self.m_model.m_hero_cfg.Ex_hero,self.m_model.m_hero_cfg.max_evo), "common_ui","hero_evo")
end

return M