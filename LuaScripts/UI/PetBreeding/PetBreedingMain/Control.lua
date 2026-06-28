---@class PetBreedingMainControl: OOControlBase
---@field m_model PetBreedingMainModel
---@field m_view PetBreedingMainView
local M = class("PetBreedingMainControl", LikeOO.OOControlBase)

function M:onEnter()
    --SceneManager:changeScene(SceneManager.SceneID.PetScene, self.m_model)
    local sceneId = SceneManager.curScene.sceneId
    if sceneId ~= Battle.BattleGlobalConfig.SCENE_ID.PetHallScene then
        SceneManager:changeScene(Battle.BattleGlobalConfig.SCENE_ID.PetHallScene, self.m_model.m_data)
        local function callback()

        end
        self:openView("Loading.BigLoading", {callfunc = callback, show_time = 1})
    else
        if SceneManager:getCurSceneModel().updatePet then
            SceneManager:getCurSceneModel():updatePet(self.m_model.m_data)
        end
    end
    self.m_timer = self:setTimer(10, handler(self, self.updateTime))
end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:updateMsg("refresh_entrances", nil, "PengLaiBazzar.PengLaiBazzarIsland")
        self:closeView()
    elseif msg == "refresh_sence" then
        local sceneId = SceneManager.curScene.sceneId
        if sceneId ~= Battle.BattleGlobalConfig.SCENE_ID.PetHallScene then
            SceneManager:changeScene(Battle.BattleGlobalConfig.SCENE_ID.PetHallScene, self.m_model.m_data)
        end
    elseif msg == "show_btn" then
        audio:SendEvtUI("UI_Popup_N1")
        --宠物展示
        self:openView("PetBreeding.PetShowSet", self.m_model.m_data)
    elseif msg == "pet_btn" then
        --宠物背包
        self:openView("PetBreeding.PetBag",{ mode = 1 })
    elseif msg == "shop_btn" then
        --神兽商店
        self:openView("Shop", {shop_type = 33})
    elseif msg == "pk_btn" then
        --神兽斗技
        if self:checkPvp() then
            self:openView("PetBreeding.PetArenaMain")
        end
    elseif msg == "penglai_btn" then
        --蓬莱工坊
        self:openView("PetBreeding.PetFactoryPop", {})
    elseif msg == "evolve_btn" then
        -- 进化
        self:openView("PetBreeding.PetSpawn")
    elseif msg == "update_data" then
        self.m_model:updateData(data)
        if SceneManager:getCurSceneModel().updatePet then
            SceneManager:getCurSceneModel():updatePet()
        end
        self.m_view:refreshShowList()
    elseif msg == "update_pet_index" then
        self:updatePetIndex()
    elseif msg == "open_interact" then
        audio:SendEvtUI("Play_UI_Tab")
        self:openView("PetBreeding.PetBreedingInteraction", self.m_model.m_data)
    elseif msg == "explain_btn" then
        -- 说明
        self:openView("Pops.CommonHelpPop", { title = Language:getTextByKey("pet_bag_text_0104"), content = Language:getTextByKey("tid#PetRuleDes_1") })
    elseif msg == "show_list_btn" then
        audio:SendEvtUI("Play_UI_Tab")
        self.m_model:setListShowType(true)
        self.m_view:refreshShowList()
    elseif msg == "hide_list_btn" then
        audio:SendEvtUI("Play_UI_Tab")
        self.m_model:setListShowType(false)
        self.m_view:refreshShowList()
    elseif msg == "redPoint_refresh" then
        self.m_view:refreshRedPointAndBtnStates()
    end
end

function M:updatePetIndex()
    local function netCallback(response)
        self.m_model:updateData(response)
        if SceneManager:getCurSceneModel().updatePet then
            SceneManager:getCurSceneModel():updatePet()
        end
        self.m_view:refreshShowList()
        self:updateMsg("refresh_entrances", nil, "PengLaiBazzar.PengLaiBazzarIsland")
        self:updateMsg("refresh_red_point", nil, "Main")
    end
    self.m_model:getNetData("pet_index", nil, netCallback)
end

function M:updateTime()
    self.m_view:refreshRedPointAndBtnStates()
end

function M:destroy()
    self:removeTimer(self.m_timer)
    M.super.destroy(self)
end

function M:checkPvp()
    local open_flag, tips_str = BtnOpenUtil:isBtnOpen(365)
    if not open_flag then
        GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
        return false
    end
    local ids = UserDataManager.pet_data:getPetsId()
    if #ids <= 0 then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pet_bag_text_0114"), delay_close = 2 })
        return false
    end
    local data = UserDataManager:getPetPvpSeasonData()
    if not data or not data.season then
        Logger.logError("pet_pvp_season_data error")
        return false
    elseif data.season <= 0 then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pet_bag_text_0115"), delay_close = 2 })
        return false
    end
    return true
end

return M
