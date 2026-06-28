local M = class("GhostsShowSkillView",LikeOO.OOPopBase)

M.m_uiName = "GhostsOfPengLai/GhostsShowSkill"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self.skillname_obj = self:findGameObject("skillname_obj");
    self:setObjectVisible("explain_btn", false)
    self:refreshUI()
end

function M:refreshUI()
    self:setTextByLanKey("close_title_text", "new_str_1111")
    self:setTextByLanKey("show_skill_text", "new_str_1112")
    local hero_cfg = self.m_model:getHeroCfg(self.m_model.hero_cid)
    local class_str = Language:getTextByKey(hero_cfg.class)
    local name_str = Language:getTextByKey(hero_cfg.name)
    self:setTextByLanKey("main_title_text", string.cutTextForString(name_str .. "·" .. class_str))
    local race = GlobalConfig.TYPE_HERO_RACE[hero_cfg.race].big_race_icon
    self:setImg(race,  ResourceUtil:getLanAtlas(), "hero_race")
    local des = self.m_model.cfg_des ~= "" and self.m_model.cfg_des or hero_cfg.type_des03
    self:setTextByLanKey("show_des_text", des)
    self:updateHeroSpine()
    self:updateSkill()
end

function M:updateHeroSpine()
    local spine_name = self.m_model:getHeroSpineName()
    local hero_spine = self:findGameObject("hero_spine")
    GameUtil:updateSpineLoadSet(hero_spine, "RoleSpine/" .. spine_name, "idle", 0, true)
end

function M:updateSkill()
    local skills = self.m_model:getNormalSkill(self.m_model.hero_cid)
    for i = 1,6 do
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
    local plusSkills = self.m_model:getPlusSkill(self.m_model.hero_cid)
    for i,v in pairs(plusSkills) do
        local k = i + 4
        self:setObjectVisible("di_"..k, true)
        local str_name = "skill"..k.."_img"
        local show_text = "skill_"..k.."_text"
        local cur_skill = GameUtil:getSkill(v[1][1])
        self:setTextByLanKey(show_text, "awake_system_text_0010")
        self:setImg(cur_skill.icon, "skill_icon", str_name)
    end
end

function M:setPlayBtnVisible(visible)
    self:setObjectVisible("play_btn", visible)
end

function M:playerSkillName( player )
    local sceneInfo = Battle.BattleGlobalConfig.SCENE_ID_INFO[SceneManager.curScene.sceneId]
    if sceneInfo.showSkill3Effect ~= true then
        return
    end
    if self.skillname_obj and player.camp == 1 and player.curSkillConfig ~= nil then
        local skillname = player.curSkillConfig.data.skill_name_liberation
        if skillname ~= "" and skillname ~= nil then
            if not IsNull(self.m_skill_obj) then
                ResourceUtil:ReturnItem( self.m_skill_obj)
                self.m_skill_obj = nil
            end

            local skill_obj = GameUtil:createPrefab("GamePanel/BigSkillName", self.skillname_obj.transform)
            if not IsNull(skill_obj) then
                skill_obj.transform.localPosition = Vector3(500,50,0)
                local luaBehaviour = UIUtil.findLuaBehaviour(skill_obj)
                local skill_name_img = luaBehaviour:FindGameObject("skill_name_img")
                GameUtil:setTextureLoadSetLanImgText(skill_name_img, skillname)
                luaBehaviour:RunAnim("BigSkillName_Show", function()
                    if not IsNull(skill_obj) then
                        ResourceUtil:ReturnItem(skill_obj)
                        skill_obj = nil
                        self.m_skill_obj = nil
                    end
                end, 1)
            end
            self.m_skill_obj = skill_obj
        else
            Logger.logWarning(" 技能  Name = nil");
        end
        --end
    end
end

function M:destroy()
    if not IsNull(self.m_skill_obj) then
        ResourceUtil:ReturnItem( self.m_skill_obj)
        self.m_skill_obj = nil
    end
    M.super.destroy(self)
end

return M