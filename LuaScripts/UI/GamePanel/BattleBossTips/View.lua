local M = class("BattleBossTipsView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "GamePanel/BattleBossTips"

function M:onEnter()
    audio:SendEvtUI("UI_QiangDiLaiXi")
    local class_str = Language:getTextByKey(self.m_model.m_hero_cfg.class)
    local name_str = Language:getTextByKey(self.m_model.m_hero_cfg.name)
    self:setTextByLanKey("main_title_text", string.cutTextForString(name_str .. "·" .. class_str))
    local common = GlobalConfig.HERO_QUALITY_COMMON_SETTING[self.m_model:getEvo()].icon
    GameUtil:setLanImgText(self:findRectTransform("souch_img"), common)
    local pro = GlobalConfig.TYPE_HERO_PROPERTY[self.m_model.m_hero_cfg.type].pro_icon
    self:setImg(pro, "hero_ui", "pro_img_btn")
    local race = GlobalConfig.TYPE_HERO_RACE[self.m_model.m_hero_cfg.race].big_race_icon
    self:setImg(race, ResourceUtil:getLanAtlas(), "camp_img_btn")

    self:setTextByLanKey("sub_title_text", self.m_model.m_hero_cfg.title)
    local poetry = string.gsub(Language:getTextByKey(self.m_model.m_hero_cfg.poetry), "\\n", "\n")
    local poe =  string.split(poetry,"\n")
    for i=1,4 do
        self:setText("des_text_" .. i, poe[i] or "")
    end
    --self:setTextByLanKey("des_text", poetry)
    self:setObjectVisible("des_text", false)
    self:setTextByLanKey("tips_text", self.m_model.m_hero_cfg.type_des03)
    self:setTextByLanKey("evo_text", "hero_ui_str_0009")
    self:setTextByLanKey("race_text", "hero_ui_str_0001")
    self:setTextByLanKey("pro_text", "hero_ui_str_0002")
    self:setTextByLanKey("race_value_text", GlobalConfig.TYPE_HERO_RACE[self.m_model.m_hero_cfg.race].name)
    self:setTextByLanKey("pro_value_text", GlobalConfig.TYPE_HERO_PROPERTY[self.m_model.m_hero_cfg.type].name)
    self.big_close_btn = self:findGameObject("big_close_btn")
    --动画里没有这个事件了
    --local function animEnd(msg)
    --    if msg == "active_close" then
    --        --self.big_close_btn:SetActive(true)
    --    elseif msg == "play_sound" then
    --        if self.m_model.m_hero_cfg.vo and self.m_model.m_hero_cfg.vo ~= "" then
    --            local path = self.m_model:subName()
    --            ResourceUtil:LoadRoleSound(path)
    --            self.cur_cv = audio:SendEvtUI(self.m_model.m_hero_cfg.vo)
    --            audio:PauseMusicBusVol()
    --        end
    --    end
    --end
    --LuaBehaviourUtil.addAnimEvent(self.m_luaBehaviour, animEnd)
    self:setParticleRenderOrder(self.content_node)
    self:setSpine()
    self:updateSkill()

    local cur_skin = 0
    if self.m_model.m_hero_cfg then
        local skin = self.m_model.m_hero_cfg.skin or {}
        cur_skin = skin[1]
    end
    local skinCfg = self.m_model:getHeroSkinCfg(cur_skin)
    if skinCfg then
        self:setTextByLanKey("hero_cv_name", "hero_ui_str_0043",Language:getTextByKey(skinCfg.cv))
    end
end

function M:setSpine()
    --local spine_name = self.m_model.m_hero_cfg.hero_spine or "hero_0001_SkeletonData"
    local spine_name = self.m_model.m_shin_data_cfg.hero_spine or "hero_0001_SkeletonData"
    local play_img = self:findGameObject("hero_spine")
    --local sg = play_img:GetComponent("SkeletonGraphic")
    --local hehe = ResourceUtil:GetSk(spine_name, "rolespine_"..string.lower(spine_name))
    --sg.skeletonDataAsset = hehe
    --sg:Initialize(true)
    GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "idle", 0, true)

    local pos_x = -8
    local pos_y = -8
    local spine_pos, spine_scale = self.m_model:getSpinePos(self.m_model.m_hero_cfg)
    local pos = play_img.transform.localPosition
    pos.x = spine_pos[1] or 0
    pos.y = spine_pos[2] or 0
    play_img.transform.localPosition = pos
    play_img.transform.localScale = Vector3(spine_scale,spine_scale,1)

end

function M:updateSkill()
    local skills = self.m_model.m_hero_cfg.skill
    for i = 1,4 do
        self:setObjectVisible("di_"..i, false)
    end
    for k,v in pairs(skills) do 
        if k <= 4 then
            self:setObjectVisible("di_"..k, true)
            local str_name = "skill"..k.."_img"
            local show_text = "skill_"..k.."_text"
            local cur_skill = GameUtil:getSkill(v[1][1])
            self:setTextByLanKey(show_text, cur_skill.show_type)
            self:setImg(cur_skill.icon, "skill_icon", str_name)
        end
    end
end

function M:getSkillTransByIndex(index)
    return self:findRectTransform("skill"..index.."_img")
end

function M:destroy()
    audio:StopPlayingID(self.cur_cv)
    self.cur_cv = nil
    if self.m_model.m_hero_cfg.join_sound and self.m_model.m_hero_cfg.join_sound ~= "" then
        ResourceUtil:UnLoadRoleSound(self.m_model:subName())
    end
    audio:ResumeMusicBusVol()
    M.super.destroy(self)
end

return M