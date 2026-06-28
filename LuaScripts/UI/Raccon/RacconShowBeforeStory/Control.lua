local M = class("RacconShowBeforeStoryControl",LikeOO.OOControlBase)

function M:onEnter()
    self:handlerScene();
end

--处理场景问题
function M:handlerScene()
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RACCON  then
        local level = UserDataManager:getBattleStage();
        local key = "cjq_"..tostring(level)
        local is_battle = self.m_model.is_battle
        UserDataManager.local_data:setUserDataByKey(key,1)
        --获取当前关卡
        --创建剧情人物
        local level = UserDataManager:getBattleStage();
        local common = { param = level }
        SceneManager:changeScene(SceneManager.SceneID.FightScene, { mode = self.m_model.m_mode, common = common }, self.m_model.new_chapter)
        --当前的章节数据
        local chapter = ConfigManager:getCfgByName("stage")[level];
        --得到当前的无视关卡人物的创建人物
        local hero_id_list = chapter.hero_id_list;
        if hero_id_list ~= nil and next( hero_id_list ) then
            SceneManager:getCurSceneModel():createStoryPlayers(self.m_model.m_mode, hero_id_list, function()
                self:updateMsg("close_battle_loading", nil, "parent")
                self:plotShow( function()
                    self:runStory( function()
                        --剧情都跑完，打开布阵界面
                        SceneManager.curScene.plyMgr:destroy();
                        if self.m_model.is_battle then
                            self:openView("Formation", self.m_model.m_params)
                        else
                            self:requestStory()
                        end
                        self:setOnceTimer(0.7, function()
                            self:closeView()
                        end)
                    end)
                end);
            end);
        else
            self:updateMsg("close_battle_loading", nil, "parent")
            self:plotShow( function()
                self:runStory( function()
                    --剧情都跑完，打开布阵界面
                    SceneManager.curScene.plyMgr:destroy();
                    if is_battle then
                        self:openView("Formation", self.m_model.m_params)
                    else
                        self:requestStory()
                    end
                    self:setOnceTimer(0.7, function()
                        self:closeView()
                    end)
                end)
            end);
        end
    else
        --剧情都跑完，打开布阵界面
      --  self:openView("Loading.BattleLoading", {callfunc = function(open_flag)
       --     if open_flag == "open_view" then
                self:openView("Formation", self.m_model.m_params)
                self:closeView()
       --     end
      --  end })
    end
end

function M:requestStory()
    local function netCallback(response)
        if response and response.new_unlock_hero and next(response.new_unlock_hero) then
            self:updateMsg("unlock_new_chapter", response.new_unlock_hero, "Raccon.RacconXkzDetail")
        end
        self:updateMsg("update_data", response, "Raccon.RacconXkz")
        self:updateMsg("update_data", response, "Raccon.RacconXkzDetail")
    end
    self.m_model:getNetData("raccon_event_end", {hero_id = self.m_model.hero_index, stage_id = self.m_model.stage_id}, netCallback, nil, true)
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "show_black_line" then
        --显示黑条
        self.m_view:runAnim("black_line_1")
        audio:SendEvtUI("UI_StoryStart")
        audio:PauseMusicBusVol()
    elseif msg == "hide_black_line" then
        --黑条消失
        self.m_view:runAnim("black_line_2")
        audio:ResumeMusicBusVol()
    end
end

--开始跑剧情
function M:plotShow( over_callback )
    --local function callback()
    if over_callback ~= nil then
        over_callback();
    end
end

function M:runStory( callback )
    --战斗前的逻辑
    --场景剧情不是空
    local scene_view = SceneManager:getCurSceneView();
    if scene_view:get_story() ~= nil then
        --0 先播放别的剧情
        --1 先播放我
        if scene_view:get_story().playIndex == 0 then
            --播放剧情
            self:formation_play_drama( function()
                --播放站立对话
                scene_view:runStory(function()
                    if callback ~= nil then
                        callback();
                    end
                end)
            end)
        else
            --先播放站立对话
            scene_view:runStory(function()
                --再播放 drama
                self:formation_play_drama( function()
                    if callback ~= nil then
                        callback();
                    end
                end)
            end)
        end
    end
end

--播放布阵前的剧情
function M:formation_play_drama( callback_drama )
    local stage_cfg = GameUtil:getBattleStageCfg()
    local open_event = stage_cfg.open_event
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RACCON then
        open_event = self.m_model.m_open_event
    end
    
    if open_event and open_event ~= 0 then
        Logger.log(" callback_drama ~~~~~~~~~~~~~~~~~~  2 ~~~~~~~~~~~~~~~~~~"..open_event)
        local function callback()
            Logger.log(" callback_drama ~~~~~~~~~~~~~~~~~~  0 ~~~~~~~~~~~~~~~~~~")
            if callback_drama ~= nil then
                callback_drama()
            end
        end
        self:openView("Guide.GuideDrama", {dialog_id = open_event, callback = callback, is_delay_close = true})
    else
        Logger.log(" callback_drama ~~~~~~~~~~~~~~~~~~  1 ~~~~~~~~~~~~~~~~~~")
        if callback_drama ~= nil then
            callback_drama()
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M;
