local M = class("HeroBossTrainPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Activities.WorldBoss.HeroBossTrainPop.Guide"
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:startGuide()
    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(56, 3)
    if have_guide then
        if self.m_guide then
            self.m_guide:start()
        end
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if self.m_model.m_is_jump then
            self:updateMsg("common_refresh" ,nil ,"parent")
        end
        self:updateMsg("update_red_point", nil, "Activities.WorldBoss.WorldBossSelectMain")
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 78})
    elseif msg == "challenge_btn" then --挑战
        local params =
        {
            state = 1;
            m_boss_id = self.m_model:getwDay();
            m_mode = GlobalConfig.BATTLE_MODE.ACTIVE,
        }
        SceneManager:changeScene(SceneManager.SceneID.HeroTrainScene, params, true)
        local hero_train_cfg = self.m_model:getHeroTrainCfg()
        self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.ACTIVE,
                                   def_data = self.m_model.m_data.enemy_data,
                                   battle_id = hero_train_cfg.stage_battle,
                                   addition_race = hero_train_cfg.race,
                                   version = self.m_model.m_data.version,
                                   boss_id = self.m_model:getwDay()})
        SceneManager:scenestart()
    elseif msg == "rank_task_btn" then --挑战任务
        local params = {}
        params.data = self.m_model:getTasks()
        params.train_group = self.m_model.m_data.train_group or 0
        params.version = self.m_model.m_data.version or 0
        self:openView("GiftBag.HeroTrainTask", params)  
    elseif msg == "rank_reward_btn" then --排行奖励
        local params = {}
        params.data = self.m_model.m_data
        params.select_index = 2
        self:openView("GiftBag.HeroTrainRankList", params) 
    elseif msg == "check_rank_btn" then -- 查看榜单  
        local params = {}
        params.data = self.m_model.m_data
        params.select_index = 1
        params.version = self.m_model.m_data.version or 0
        self:openView("GiftBag.HeroTrainRankList", params) 
    elseif msg == "buf_img_1" then --buff  
        local btns = self.m_view:findGameObject(msg)
        local train_cfg = self.m_model:getHeroTrainCfg()
        local races = self.m_model:getRaces()
        local race_cft = GlobalConfig.TYPE_HERO_RACE[races[1]] 
        local per_num =  GameUtil:formatNum(train_cfg.percent*100)
        local show_str = Language:getTextByKey("gf_str_0079", Language:getTextByKey(race_cft.name),per_num)
        if btns then
            GameUtil:lookInfoTips(self.m_control, {click_transform = btns.transform, msg = show_str } )
        end
    elseif msg == "buf_img_2" then --buff   
        local btns = self.m_view:findGameObject(msg)
        local train_cfg = self.m_model:getHeroTrainCfg()
        local races = self.m_model:getRaces()
        local race_cft = GlobalConfig.TYPE_HERO_RACE[races[2]] 
        local per_num =  GameUtil:formatNum(train_cfg.percent*100)
        local show_str = Language:getTextByKey("gf_str_0079", Language:getTextByKey(race_cft.name),per_num)
        if btns then
            GameUtil:lookInfoTips(self.m_control, {click_transform = btns.transform, msg = show_str } )
        end  
    elseif msg == "hint_btn" then
        local train_cfg = self.m_model:getHeroTrainCfg()
        local params = {}
        params.title = "gf_str_0078"
        params.content = Language:getTextByKey(train_cfg.des)
        self:openView("Pops.CommonHelpPop", params)  
    elseif msg == "update_data" then   
         self.m_model.m_data = data
         GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0032"), delay_close = 2})
         self.m_model.end_ts = self.m_model:getDayEnd()
         self.m_view:refreshUI()
    elseif msg == "update_quest" then 
        self.m_model.m_data.quests = data   
        self.m_view:refreshRedPoint() 
    elseif msg == "update_hero_train" then
        local function callback(response)
            self.m_model:updateData(response)
            self.m_model.end_ts = self.m_model:getDayEnd()
            self.m_view:refreshUI()
        end
        self.m_model:getNetData("train_index", nil, callback)
    elseif msg == "to_active_obj" then
        if UserDataManager:getServerTime() < self.m_model.end_ts and self.m_model.end_ts - UserDataManager:getServerTime() <= 10 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            return
        end
        local jump_num = self.m_model:getJumpFunc()
        if jump_num == 10027 then
            self:closeView("GiftBag.GiftScrollPanel")
        elseif jump_num == 10026 then   
            self:closeView("GiftBag") 
        elseif jump_num == 10029 then   
            self:closeView("Summer") 
        end
        if jump_num > 0 then
            if static_rootControl:hasChild("Activities.WorldBoss.WorldBossSelectMain") == false then
                self:setOnceTimer(0.1, function ()
                    self:updateMsg(99999)
                end)
            end
            QuickOpenFuncUtil:openFunc(jump_num) 
        end

    end
end

function M:updateTime()
    self.m_view:updateTime()
end

return M
