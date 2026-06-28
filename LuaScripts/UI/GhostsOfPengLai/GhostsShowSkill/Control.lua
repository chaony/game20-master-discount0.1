local M = class("GhostsShowSkillControl",LikeOO.OOControlBase)

function M:onEnter()
    SceneManager:changeScene(SceneManager.SceneID.GhostsShowSkillScene, { mode = GlobalConfig.BATTLE_MODE.GHOSTS_SHOW_SKILL})    
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.BATTLE_EVENT, {self, self.battleEvent})
    self.is_battle_end = true
    self.play_skill_index = 0
    self:setOnceTimer(0.2, function()
        audio:ResumeSkillsBusVol()
        self.m_model.touch_skill_flag = true
    end)
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh" ,nil ,"parent")
        self:closeView()
    elseif msg == "play_btn" then
        if self.start_battle_callback ~= nil then
            self:setOnceTimer(0.05, function()
                if self.m_view then
                    self.is_battle_end = false
                    self.start_battle_callback()
                    self.start_battle_callback = nil
                    self.m_view:setPlayBtnVisible(false)
                end
            end)
        end
    elseif msg == "skill1_img" then
		self:openSkillPop(1, msg)
    elseif msg == "skill2_img" then
		self:openSkillPop(2, msg)
    elseif msg == "skill3_img" then
		self:openSkillPop(3, msg)
    elseif msg == "skill4_img" then
		self:openSkillPop(4, msg)
    elseif msg == "skill5_img" then
        self:openSkillPop(5, msg)
    elseif msg == "skill6_img" then
        self:openSkillPop(6, msg)
    elseif msg == "explain_btn" then
        --TODO: 填写策划多语言字段
		local params = {}
		params.title = "hero_role_upgrade_text4"
		params.content = "tid#HeroroleTips_1"
		self:openView("Pops.CommonHelpPop", params)
    end
end


function M:closeViewEvent(event, data)
    local view_name = data.name or ""
    if view_name == "Loading.SyncLoadBigLoading" then
        self:initBattle()
    end
end

function M:battleEvent(event, data)
    local event_name = data.event
    local params = data.data
    if event_name == "battle_anim" then
        self.start_battle_callback = params.callback
        if self.m_model.first_init then
            self.m_model.first_init = false
            self:updateMsg("play_btn")
        end
        self:autoPlaySkill()
    elseif event_name == "battle_end" then
        if not self.is_battle_end then
            self.is_battle_end = true
            self:setOnceTimer(2, function()
                self.m_view:setPlayBtnVisible(false)
                SceneManager.curScene.plyMgr:destroyAllPlayer()
                self:initBattle()
                self:updateMsg("play_btn")
            end)
        end
    elseif event_name == "playerSkillName" then
        self.m_view:playerSkillName(data.data);
    end
end

function M:initBattle()
    local battle_data = self.m_model:getBattleData()
    if battle_data then
        SceneManager.curScene:battleStart(battle_data)
    end
end
 
function M:openSkillPop(index, msg)
    if self.m_model.touch_skill_flag then
        local click_obj = self.m_view:findGameObject(msg)
        local skills, hero_lv = {}
        if index < 5 then
            skills = self.m_model:getNormalSkill(self.m_model.hero_cid)
        else
            index = index - 4
            skills = self.m_model:getPlusSkill(self.m_model.hero_cid)
        end
        self:openView("Pops.SkillPop",{skill = skills[index], pivot =Vector2(0.5,1), index = index, cur_lv = 999 , click_transform = click_obj.transform})
    end
end

function M:playNextSkill()
    if self.is_battle_end then
        self.play_skill_index = self.play_skill_index + 1
        local index = self.play_skill_index%4
        local skills = self.m_model:getHeroSkill(self.m_model.hero_cid)
        local play_skill = skills[index + 1]
        if play_skill then
            local skill_cfg_item = GameUtil:getSkill(play_skill[1][1])
            local player = SceneManager.curScene:playPlayerSkill(skill_cfg_item.anim_name)
            if player and player.animator.curState then
                local fix_skill_time = player.animator.curState.animLength
                local skill_time = GlobalTools:ToFloat(fix_skill_time)
                self:setOnceTimer(skill_time, function()
                    if self.is_battle_end then
                        player.animator:changeState("idle")
                        self:autoPlaySkill()
                    end
                end)
            else
                self:autoPlaySkill()
            end
        else
            self:autoPlaySkill()
        end
    end
end

function M:autoPlaySkill()
    self:setOnceTimer(0.3, function()
        self:playNextSkill()
    end)
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.BATTLE_EVENT, {self, self.battleEvent})
    M.super.destroy(self)
end

return M;
