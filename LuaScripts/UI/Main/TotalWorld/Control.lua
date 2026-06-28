local M = class("TotalWorldControl",LikeOO.OOControlBase)

--local __scene_id = 102

function M:onEnter()
    --SceneManager:changeScene(SceneManager.SceneID.JiaoWai)
    self.m_guide_file_name = "UI.Main.TotalWorld.Guide"
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    audio:SendEvtBGM("Set_State_TianXia")
    SceneManager:getCurSceneModel():setCameraShow(false)
    self:UpdateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.UpdateTime))
end

function M:startGuide()
    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(1, 1)
    if have_guide then
        if self.m_guide then
            self.m_guide:start()
        end
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent") 
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = -1})
    elseif msg == "hunt_treasure_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(180)
        if open_flag then
            self:openView("HuntTreasures")
        else
            GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
        end
    elseif msg == "union_war_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(168)
        if open_flag == false then
            GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2 })
            return
        end
        local function callback(response)
            local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
            if guild_id and guild_id > 0 then
                --工会战
                self:openView("UnionWar", { union_data = response })
                --轮播动画跳转
                if data.is_carousel == true then -- 轮播
                    self:setOnceTimer(0.3,function()
                        self:updateMsg("new_btn",data,"UnionWar")
                    end)
                end
            else
                --没有工会
                self:openView("Union.UnionIndex", response)
            end
        end
        self.m_model:getNetData("guild_index", nil, callback)
    elseif msg == "high_arena_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(34)
        if open_flag == false then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey(tips_str), delay_close = 2})
            return
        end
        self:openView("LingCloud", {high_arena =  self.m_model:getAreaData("high_arena"),top_arena =  self.m_model:getAreaData("top_arena")})
    elseif msg == "servers_group_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(193)
        if open_flag == false then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey(tips_str), delay_close = 2})
            return
        end
        self:openView("TianXiaBattle")
    elseif msg == "season_preview_btn" then
        local open_flag, tips_str = self.m_model:checkSeasonPreviewOpen()
        local open_flag1, tips_str1 = BtnOpenUtil:isBtnOpen(240)
        if open_flag then -- 有赛季预告先打开预告，没有再打开赛季旅程
            self:openView("SeasonPreview")
        elseif open_flag1 then
            self:openView("Achievement") -- 赛季旅程
        else
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey(tips_str1), delay_close = 2})
        end
    elseif msg == "five_race_arena_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(234)
        if open_flag == true then
            if self.m_model:isOpenFiveRace() then
                self:openView("Arena.ArenaFiveRace")
            else
                GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("tid#LianSai_des_4"), delay_close = 2})
            end
        else
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey(tips_str), delay_close = 2})
        end
    elseif msg == "qi_men_dun_jia_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(246)
        if open_flag == false then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey(tips_str), delay_close = 2})
            return
        end
        self:openView("QiMenDunJia.QiMenDunJiaMain")
    elseif msg == "union_btn" then --工会
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(22)
        if open_flag == false then
            GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2 })
            return
        end
        --GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0055"), delay_close = 2})
        QuickOpenFuncUtil:openFunc(23)
    elseif msg == "change_TotalWorld_scene" then
        self.m_view:refreshUI()
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint() 
    elseif msg == "guide_check" then
        self.m_guide:checkGuide()
    elseif msg == "change_scene" then
        GameUtil:playSceneConfigBGM(__scene_id)
    end
end

--计时器
function M:UpdateTime(_, dt)
    dt = dt or 0
    self.m_view:updateTime()
end

function M:changeTotalWorldScene(event, data)
    GameUtil:playSceneConfigBGM(__scene_id)
    self.m_view:refreshUI()                                                                                                                                                                                                                                                      
end

function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if data.event == "remove_red_dot" or data.event == "red_dot_update" then
        self.m_view:refreshRedPoint()
    end
end


function M:destroy()
    self:removeTimer(self.m_timer_id)
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    SceneManager:getCurSceneView():setBGMusic()
    SceneManager:getCurSceneModel():setCameraShow(true)
    M.super.destroy(self)
end

return M;
