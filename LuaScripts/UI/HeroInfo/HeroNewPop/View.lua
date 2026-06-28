local M = class("HeroNewPopView",LikeOO.OOPopBase)


M.m_size_type = 2
M.m_uiName = "HeroInfo/NewHeroPop"


function M:onEnter()
    audio:SendEvtUI("ui_GetHero")
    self:setObjectVisible("new_img", self.m_model.m_is_new)
    self:setTextByLanKey("main_title_text", self.m_model.m_hero_cfg.class )
    --self:setTextByLanKey("class_name", self.m_model.m_hero_cfg.class )
    local common = GlobalConfig.HERO_QUALITY_COMMON_SETTING[self.m_model:getEvo()].icon
    GameUtil:setLanImgText(self:findRectTransform("souch_img"), common)
    local pro = GlobalConfig.TYPE_HERO_PROPERTY[self.m_model.m_hero_cfg.type].pro_icon
    self:setImg(pro, "hero_ui", "pro_img_btn")
    local race = GlobalConfig.TYPE_HERO_RACE[self.m_model.m_hero_cfg.race].big_race_icon
    self:setImg(race,  ResourceUtil:getLanAtlas(), "camp_img_btn")
    --self:setTextByLanKey("detail_text", self.m_model.m_hero_cfg.life or "")
    local detail_text = self:findGameObject("des_text")
    local poetry = string.gsub(Language:getTextByKey(self.m_model.m_hero_cfg.poetry), "\\n", "\n")
    local poe =  string.split(poetry,"\n")
    for i=1,4 do
        self:setText("des_text_" .. i, poe[i] or "")
    end
    --detail_text:GetComponent("VerticalText"):setText(poetry)
    -- detail_text.transform:GetComponent('ContentSizeFitter'):SetLayoutVertical()
    self:setTextByLanKey("sub_title_text", self.m_model.m_hero_cfg.title)

    local card_hero = ConfigManager:getCfgByName("card_hero")
    local card_hero_item = card_hero[self.m_model.m_hero_cfg.id] or {}
    local quality = card_hero_item.hero_evo or 0
    local frameData = GlobalConfig.QUALITY_FRAME[quality] or GlobalConfig.QUALITY_FRAME[1]
    --self:setImg(frameData.line_frame_name, "common_ui", "name_quality_bg_img")
    self:setTextByLanKey("tips_text", self.m_model.m_hero_cfg.type_des03)
    self:setTextByLanKey("evo_text", "hero_ui_str_0009")
    self:setTextByLanKey("race_text", "hero_ui_str_0001")
    self:setTextByLanKey("pro_text", "hero_ui_str_0002")
    self:setTextByLanKey("race_value_text", GlobalConfig.TYPE_HERO_RACE[self.m_model.m_hero_cfg.race].name)
    self:setTextByLanKey("pro_value_text", GlobalConfig.TYPE_HERO_PROPERTY[self.m_model.m_hero_cfg.type].name)
    self.big_close_btn = self:findGameObject("big_close_btn")

    -- local function animEnd(msg) --动画没做、暂时屏蔽
    --     if msg == "active_close" then
    --         self.big_close_btn:SetActive(true)
    --     elseif msg == "play_sound" then
    --         if self.m_model.m_hero_cfg.vo and self.m_model.m_hero_cfg.vo ~= "" then
    --             local path = self.m_model:subName()
    --             ResourceUtil:LoadRoleSound(path)
    --             self.cur_cv = audio:SendEvtUI(self.m_model.m_hero_cfg.vo)
    --             audio:PauseMusicBusVol()
    --         end
    --     end
    -- end
    -- LuaBehaviourUtil.addAnimEvent(self.m_luaBehaviour, animEnd)
    
    local show_share = true
    if self.m_model.m_hero_cfg.evo == 5 then
        self:setObjectVisible("xia_img",true)
    else
        self:setObjectVisible("xia_img",false)
        show_share = false
    end
    self:setParticleRenderOrder(self.content_node)
    self:setSpine()
    self:updateSkill()
    self:updateProType()
    local class_name_img = self:findImage("class_name_img")
    GameUtil:updateResourcesImg(class_name_img, "Texture/HeroIcon/a_name_"..self.m_model.m_hero_cfg.id)
    class_name_img:SetNativeSize()

    local guide_info = UserDataManager.guide_data:getCurGuideInfo()
    local isGuiding = UserDataManager.guide_data:isGuiding()
    if isGuiding and guide_info then -- 引导屏蔽调整阵容操作 转为引导强制换位
        if guide_info.key == "HeroNewPop" then
            show_share = false
        end
    end
    if GameVersionConfig.BYTE_DANCE_SERVER_VERSION == "1.0.1" then -- 屏蔽不删档测试包
        show_share = false
    end
    self:ShareShow(show_share)
    
    local cur_skin = 0
    if self.m_model.m_hero_cfg then
        local skin = self.m_model.m_hero_cfg.skin or {}
        cur_skin = skin[1]
    end
    local skinCfg = self.m_model:getHeroSkinCfg(cur_skin)
    if skinCfg then
        self:setTextByLanKey("hero_cv_name", "hero_ui_str_0042",Language:getTextByKey(skinCfg.cv))
        if skinCfg.vo and skinCfg.vo ~= "" then
            local path = self.m_model:subName()
            ResourceUtil:LoadRoleSound(path)
            self.cur_cv = audio:SendEvtUI(skinCfg.vo)
            audio:PauseMusicBusVol()
        end
    end
    self:refreshSP()
end

function M:refreshSP()
    local is_sp,sp_bg_name,sp_mul_lan_name,sp_efffect_name = self.m_model:getHero_SPInfo()
    self:setObjectVisible("hero_sp_flag", is_sp)
    if is_sp then
        self:setImg(sp_bg_name,"hero_ui","hero_sp_bg")
        self:setTextByLanKey("hero_sp_name",sp_mul_lan_name)
        if self.cur_sp_eff_go then
            self.cur_sp_eff_go:SetActive(false)
        end
        if sp_efffect_name then
            self.cur_sp_eff_go=self:setObjectVisible(sp_efffect_name,true)
        end
    end
end

function M:setSpine()
    local spine_name = self.m_model.m_hero_cfg.hero_spine or "hero_0001_SkeletonData"

    local play_img = self:findGameObject("hero_spine")
    --local sg = play_img:GetComponent("SkeletonGraphic")
    --local hehe = ResourceUtil:GetSk(spine_name, "rolespine_"..string.lower(spine_name))
    --sg.skeletonDataAsset = hehe
    --sg:Initialize(true)
    GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "idle", 0, true)

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

--英雄类型
function M:updateProType()
    local temp_cfg = self.m_model.m_hero_cfg
    if temp_cfg then
        local type_data = GlobalConfig.TYPE_HERO_PROPERTY[temp_cfg.type]
        local locate1_data = GlobalConfig.TYPE_HERO_LOCATION_1[temp_cfg.locate[1] or 1]
        local locate2_data = GlobalConfig.TYPE_HERO_LOCATION_2[temp_cfg.locate[2] or 1]
        self:setImg(type_data.pro_icon, "hero_ui", "pro_img_1")
        self:setImg(locate1_data.loc_icon, "hero_ui", "pro_img_2")
        self:setImg(locate2_data.loc_icon, "hero_ui", "pro_img_3")
        self:setTextByLanKey("pro_text_1", type_data.name)
        self:setTextByLanKey("pro_text_2", locate1_data.name)
        self:setTextByLanKey("pro_text_3", locate2_data.name)
    end
end

function M:ShareShow(flag)
    --self:setObjectVisible("share_node", flag)
end

function M:destroy()
    audio:StopPlayingID(self.cur_cv)
    self.cur_cv = nil
    local skinCfg = self.m_model:getNewHeroSkinCfg()
    if skinCfg then
        if skinCfg.vo and skinCfg.vo ~= "" then
            ResourceUtil:UnLoadRoleSound(self.m_model:subName())
        end
    end
    audio:ResumeMusicBusVol()
    M.super.destroy(self)
end

return M