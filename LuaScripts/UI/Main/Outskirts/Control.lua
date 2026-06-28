---@class OutskirtsControl:OOControlBase
---@field m_view OutskirtsView
local M = class("OutskirtsControl",LikeOO.OOControlBase)

local __scene_id = 102

function M:onEnter()
    --SceneManager:changeScene(SceneManager.SceneID.JiaoWai)
    self.m_guide_file_name = "UI.Main.Outskirts.Guide"
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE, {self, self.changeOutskirtsScene})
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    GameUtil:playSceneConfigBGM(__scene_id)
    SceneManager:getCurSceneModel():setCameraShow(false)
end

--function M:startGuide()
--
--end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = -1})
    --elseif msg == "sect_build_btn" then
        --QuickOpenFuncUtil:openFunc(73)
    --    self:updateMsg("sect_btn", nil, "parent")
    --    self:closeView()
    elseif msg == "arena_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(24)
        if open_flag == false then
            GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2 })
            return
        end
        QuickOpenFuncUtil:openFunc(37)
        --local race_open_flag, race_tips_str = BtnOpenUtil:isBtnOpen(141)
        --if race_open_flag then
        --    QuickOpenFuncUtil:openFunc(37)
        --else
        --    QuickOpenFuncUtil:openFunc(24)
        --end
        --[[
    elseif msg == "treasure_btn" then
        local function netDataCallBack(response)
            if response.finish == 0 and response.cells ~= nil and _G.next(response.cells) ~= nil then
                QuickOpenFuncUtil:openFunc({18, response})
            else
                QuickOpenFuncUtil:openFunc({38, response})
            end
        end
        self.m_model:getNetData("maze_index", nil, netDataCallBack)
        ]]--
    elseif msg == "trial_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(169)
        if open_flag == true then
            self:openView("Activities.WorldBoss.WorldBossSelectMain")
        else
            GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2})
        end
        --QuickOpenFuncUtil:openFunc(29)
    elseif msg == "matrix_btn" then --四象阵
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(194)
        if open_flag == false then
            GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2 })
            return
        end
        QuickOpenFuncUtil:openFunc(83)
    elseif msg == "xuanshang_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(27)
        if open_flag == false then
            GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2 })
            return
        end
        QuickOpenFuncUtil:openFunc(16)
    elseif msg == "biography_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(171)
        if open_flag == false then
            GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2 })
            return
        end
        QuickOpenFuncUtil:openFunc(41)
    elseif msg == "change_outskirts_scene" then
        --SceneManager:changeScene(SceneManager.SceneID.JiaoWai)
        self.m_view:refreshUI()
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint()
    elseif msg == "guide_check" then
        self.m_guide:checkGuide()
    elseif msg == "tianji_btn" then
        local race_open_flag, race_tips_str = BtnOpenUtil:isBtnOpen(73)
        if race_open_flag == true then
            self:openView("Budo.BudoSelectPop")
        else
            local open_flag, tips_str = BtnOpenUtil:isBtnOpen(104)
            if open_flag == true then
                self:openView("Budo", {tower_type = 0})
            else
                GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2})
            end
        end
    elseif msg == "change_scene" then
        --SceneManager:changeScene(SceneManager.SceneID.JiaoWai)
        GameUtil:playSceneConfigBGM(__scene_id)
    elseif msg == "taoist_btn" then --武道场
        local race_open_flag, race_tips_str = BtnOpenUtil:isBtnOpen(157)
        if race_open_flag then --开启
            self:openView("Taoist")
        else --未开启
            GameUtil:lookInfoTips(self, { msg = race_tips_str, delay_close = 2})
        end
    elseif msg == "compass_btn" then --原事务里的探宝营地
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(142)
        if open_flag == false then
            GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2 })
            return
        end
        StatisticsUtil:doPointActive(142,0)
        QuickOpenFuncUtil:openFunc(72)
    --elseif msg == "bazzar_btn" then
    --    self:openView("PengLaiBazzar.PengLaiBazzarMain", { openId = 349 })
    elseif msg=="xiakedao_btn" then
        local race_open_flag, race_tips_str = BtnOpenUtil:isBtnOpen(450)
        if race_open_flag then --开启
            self:openView("Xiakedao")
        else --未开启
            GameUtil:lookInfoTips(self, { msg = race_tips_str, delay_close = 2})
        end
    elseif msg == "hero_boss_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(475)
        if open_flag == false then
            GameUtil:lookInfoTips(self, { msg = tips_str, delay_close = 2 })
            return
        end
        --StatisticsUtil:doPointActive(142,0)
        QuickOpenFuncUtil:openFunc(102)
    end
end

function M:changeOutskirtsScene(event, data)
    --SceneManager:changeScene(SceneManager.SceneID.JiaoWai)
    GameUtil:playSceneConfigBGM(__scene_id)
    self.m_view:refreshUI()                                                                                                                                                                                                                                                      
end

function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "red_dot_update" then
        self.m_view:refreshRedPoint()
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CHANGE_OUTSKIRTS_SCENE, {self, self.changeOutskirtsScene})
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    SceneManager:getCurSceneView():setBGMusic()
    SceneManager:getCurSceneModel():setCameraShow(true)
    M.super.destroy(self)
end

return M;
