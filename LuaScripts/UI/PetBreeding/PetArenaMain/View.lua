---@class PetArenaMainView: OOPopBase
---@field m_model PetArenaMainModel
local M = class("PetArenaMainView", LikeOO.OOPopBase)

M.m_uiName = "PetBreeding/PetArenaMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

local reached_times_img = "a_cw_djg_jifendian02"
local not_reached_times_img = "a_cw_djg_jifendian03"

function M:onEnter()
    self:adaptScreen()
    self.m_pet_objs = {}
    self.m_effect_go_list = {}
    self.m_effect_spine_list = {}
    self.m_pet_ab_name = {}
    for i = 1, 3 do
        self.m_pet_objs[i] = nil
    end
    self:bindUI()
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, { mode = 41 })
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, { self, self.everyDayRefreshEvent })
    self:refreshUI()
end

function M:bindUI()
    self:setTextByLanKey("close_title_text", "pet_arena_text_0001")
    self:setTextByLanKey("time_title_text", "new_str_1058")
    self:setTextByLanKey("challenge_btn_text", "pet_arena_text_0004")
    self:setTextByLanKey("team_btn_text", "pet_arena_text_0005")
    self:setTextByLanKey("feed_btn_text", "pet_arena_text_0008")
    self:setTextByLanKey("buff_title", "pet_arena_text_0011")

    self.m_time_text = self:findText("time_text")
    self.m_week_times_text = self:findText("week_times_text")
    self.m_gameObject3D = self:findGameObject("3d_go")
    self.m_gameObject3D.transform:SetParent(self.m_rootView.transform, false)
    UIUtil.setScale(self.m_gameObject3D.transform, 1, 1, 1)
    self.m_times_slider = self:findSlider("progress_slider")
    self.m_close_panel = self:findGameObject("panel_close_btn")
    self.m_close_panel:SetActive(false)
    local camera_tran = self:findRectTransform("Camera")
    self.m_model_camera = UIUtil.findCamera(camera_tran)
    self.m_raw_img_tran = self:findRectTransform("PetRawImage")

    local go
    local spine
    for i = 1, 3 do
        go = self:findGameObject("UI_PetBagPetNode_HaoGan_00" .. i)
        go:SetActive(false)
        self.m_effect_go_list[i] = go
        spine = self:findSkeletonGraphic("HaoGan" .. i)
        self.m_effect_spine_list[i] = spine
    end
end

function M:refreshUI()
    self:setTimeText()
    self:refreshScore()
    self:updatePetModel()
    self:refreshAddNode()
    self:hideAddPanel()
    self:refreshAwardNode()
    self:refreshSlider()
    self:refreshJumpState()
    self:refreshPetAdd()
end

function M:refreshPetAdd()
    local cfg = self.m_model:getAddPetCfg()
    if cfg then
        local detail_cfg = ConfigManager:getCfgByName("pet_detail")
        if detail_cfg and detail_cfg[cfg.pet1[1]] then
            local cur_cfg = detail_cfg[cfg.pet1[1]]
            self:setImg(cur_cfg.icon, "item_icon", "add_icon")
            self:setTextByLanKey("add_text", "pet_arena_text_0007", Language:getTextByKey(cur_cfg.name))
        end
    end
end

function M:showAddPanel()
    if not self.isInitAddPanel then
        self:initAddPanel()
    end
    self:setObjectVisible("pet_add_panel", true)
    self.m_close_panel:SetActive(true)
end

function M:hideAddPanel()
    self:setObjectVisible("pet_add_panel", false)
    for i = 1, 3 do
        self:setObjectVisible("mood_des_panel" .. i, false)
    end
    self.m_close_panel:SetActive(false)
end

function M:showMoodPanel(index)
    local mood_cfg = self.m_model:getMoonCfgByIndex(index)
    self:setObjectVisible("mood_des_panel" .. index, true)
    self:setTextByLanKey("mood_des_text" .. index, mood_cfg.name)
    self:setTextByLanKey("mood_add_text" .. index, mood_cfg.description)
    self.m_close_panel:SetActive(true)
end

function M:initAddPanel()
    local cfg = self.m_model:getAddPetCfg()
    local add_pet_list = cfg.pet1
    local detail_cfg = ConfigManager:getCfgByName("pet_detail")
    local game_obj
    local luaBehaviour
    local cur_cfg
    for i = 1, 3 do
        cur_cfg = detail_cfg[add_pet_list[i]]
        if i <= #add_pet_list and cur_cfg then
            game_obj = self:setObjectVisible("pet_head_" .. i, true)
            luaBehaviour = UIUtil.findLuaBehaviour(game_obj)
            LuaBehaviourUtil.setImg(luaBehaviour, "pet_icon", cur_cfg.icon, "item_icon")
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pet_name", cur_cfg.name)
        else
            game_obj = self:setObjectVisible("pet_head_" .. i, false)
        end
    end
    self:setTextByLanKey("buff_add_text", cfg.add_des)
end

function M:refreshSlider()
    local awardData = self.m_model:getAwardList()
    local weekTimes = self.m_model:getWeekTimes()
    local max_index = 0
    local cur_stage_num = 0
    local stage = 0.2   --一共5个
    local left_num = weekTimes
    local slider_value = 0.0
    for index, awardItemData in ipairs(awardData) do
        cur_stage_num = awardItemData.num
        if weekTimes >= cur_stage_num then
            max_index = index
        else
            break
        end
    end
    if max_index == 0 then
        slider_value = (weekTimes / awardData[1].num) * stage
    elseif max_index >= 5 then
        slider_value = 1.0
    else
        local stage_num = awardData[max_index + 1].num - awardData[max_index].num
        left_num = left_num - awardData[max_index].num
        slider_value = stage * max_index + (left_num / stage_num) * stage
    end
    audio:SendEvtUI("UI_FeelBetter") --播放进度条音效
    self.m_times_slider.value = slider_value
    
end

function M:setTimeText()
    local time = self.m_model:getRemainingTime()
    if time < 0 and not self.m_model:getSeasonState() then
        self.m_time_text.text = Language:getTextByKey("activities_str_0007")
        self:updateMsg("getNewData", { isSeasonRefresh = true })
    else
        self.m_time_text.text = GameUtil:formatTimeBySecond(time)
    end

end

function M:refreshAwardNode()
    local awardData = self.m_model:getAwardList()
    local weekTimes = self.m_model:getWeekTimes()
    if #awardData ~= 5 then
        Logger.logError("please check config pet_arena_reward the length is 5")
        return
    end
    for i = 1, 5 do
        local num = awardData[i].num or 0
        local isReceived = self.m_model:checkReceivedList(i)
        local isReached = weekTimes >= num
        local isCanRecv = isReached and (not isReceived)
        local item_parent = self:findRectTransform("awardNode" .. i)
        GameUtil:updateItemElement(item_parent, awardData[i].rewards[1], true, true, nil)
        self:setObjectVisible("canReceived" .. i, isCanRecv)
        self:setObjectVisible("Received" .. i, isReceived)
        self:setText("num_text" .. i, GameUtil:formatValueToString(num))
        local img_name = isReached and reached_times_img or not_reached_times_img
        self:setImg(img_name, "main_ui2", "node_img" .. i)
    end
    self.m_week_times_text.text = Language:getTextByKey("pet_arena_text_0015", weekTimes, awardData[5].num)
end

function M:refreshScore()
    if self.m_model.m_is_can_match then
        local score = self.m_model:getScore()
        self:setTextByLanKey("score_text", "pet_arena_text_0003", score)
    else
        self:setTextByLanKey("score_text", "pet_arena_text_0021")
    end

end

function M:updatePetModel()
    local cfgs = self.m_model:getShowCfgList()
    local quality_bg
    for i = 1, 3 do
        if not IsNull(self.m_pet_objs[i]) then
            U3DUtil:Destroy(self.m_pet_objs[i])
            self.m_pet_objs[i] = nil
        end
        if next(cfgs[i]) then
            local obj, ab_name = ResourceUtil:LoadRole3d(cfgs[i].prefab)
            ResourceUtil:AddCancelUnloadBundle(ab_name)
            self.m_pet_ab_name[ab_name] = ab_name
            self.m_pet_objs[i] = obj
            if not IsNull(obj) then
                local luaViewHelper = obj:GetComponent("LuaViewHelper")
                if luaViewHelper then
                    luaViewHelper.enabled = false
                end
                local transform = self:findRectTransform("pet_model" .. i)
                obj.transform:SetParent(transform, false)
                obj.transform.localPosition = Vector3(0, 0, 0)
                obj.transform.localRotation = Quaternion.Euler(0, cfgs[i].package_y, 0)
                obj.transform.localScale = Vector3(cfgs[i].interact_scale, cfgs[i].interact_scale, cfgs[i].interact_scale)
                GlobalTools:CloseShadow(obj.transform)

                --切换场景暂停导致speed为0
                local body_tran = obj.transform:Find("body")
                local anim = body_tran:GetComponent("Animator")
                anim.speed = 1

                local head_tran = obj.transform:Find("head")
                local head_pos = head_tran.position
                local screen_pos = self.m_model_camera:WorldToScreenPoint(head_pos)
                local offset_y = 0
                if cfgs[i].pet_type == 2 or cfgs[i].pet_type == 4 then
                    --龙和羊驼偏移
                    offset_y = 40
                end
                local mood_x = screen_pos.x + self.m_raw_img_tran.rect.x + self.m_raw_img_tran.anchoredPosition.x
                local mood_y = screen_pos.y + self.m_raw_img_tran.rect.y + self.m_raw_img_tran.anchoredPosition.y - offset_y
                local img_tran = self:findRectTransform("mood_bg" .. i)
                UIUtil.setLocalPosition(img_tran, mood_x, mood_y)

                local effect_x = screen_pos.x + self.m_raw_img_tran.rect.x + self.m_raw_img_tran.anchoredPosition.x
                local effect_y = screen_pos.y + self.m_raw_img_tran.rect.y + self.m_raw_img_tran.anchoredPosition.y - 100 - offset_y
                img_tran = self:findRectTransform("UI_PetBagPetNode_HaoGan_00" .. i)
                UIUtil.setLocalPosition(img_tran, effect_x, effect_y)

            else
                Logger.logError(cfgs[i].prefab, "LoadRole3d failed : ")
            end
        end
        quality_bg = self.m_model:getQualityImgByIndex(i)
        self:setImg(quality_bg, "main_ui2", "pet_quality_img" .. i)
    end
    self:refreshPetMood()
end

function M:refreshPetMood()
    local moodList = self.m_model:getMoonList()
    for i = 1, 3 do
        if next(moodList[i]) then
            self:setObjectVisible("mood_bg" .. i, true)
            self:setImg(moodList[i].icon, "main_ui2", "mood_img" .. i)
        else
            self:setObjectVisible("mood_bg" .. i, false)
        end
    end
end

function M:refreshAddNode()
    self.isInitAddPanel = false
end

function M:everyDayRefreshEvent()
    local time = self.m_model:getRemainingTime()
    --跨赛季零点也刷新，2s容错
    if time > 2 and not self.m_model:getSeasonState() then
        self:updateMsg("getNewData", { isSeasonRefresh = false })
    end

end

function M:refreshJumpState()
    local isJump = self.m_model:getJumpState()
    self:setObjectVisible("skip_battle_close_img", not isJump)
    self:setObjectVisible("skip_battle_open_img", isJump)
end

function M:adaptScreen()
    local bg_rt = self:findRectTransform("bg_obj")
    local rect = bg_rt.rect
    self.m_bg_scale_w = rect.width / GlobalConfig.UI_DESIGN_WIDTH
    self.m_bg_scale_h = rect.height / GlobalConfig.UI_DESIGN_HEIGHT
    self.m_bg_scale = math.max(self.m_bg_scale_w, self.m_bg_scale_h)
    local bg_rect_tran = self:findRectTransform("bg_img")
    UIUtil.setScale(bg_rect_tran, self.m_bg_scale)
end

function M:playEffect()
    local list = self.m_model.m_feed_pet_ids
    if self.effect_time then
        self.m_control:removeTimer(self.effect_time)
        self.effect_time = nil
        for i = 1, 3 do
            self.m_effect_go_list[i]:SetActive(false)
            if self.m_effect_spine_list[i].AnimationState then
                self.m_effect_spine_list[i].AnimationState:ClearTracks()
            end
        end
    end
    for i = 1, #list do
        self.m_effect_go_list[list[i]]:SetActive(true)
        self.m_effect_spine_list[list[i]].AnimationState:SetAnimation(0, "PetBagPetNode_HaoGan_001", false)
    end
    if self.m_control then
        self.effect_time = self.m_control:setTimer(
                1,
                function()
                    if self.effect_time then
                        self.m_control:removeTimer(self.effect_time)
                        self.effect_time = nil
                        for i = 1, 3 do
                            self.m_effect_go_list[i]:SetActive(false)
                            if self.m_effect_spine_list[i].AnimationState then
                                self.m_effect_spine_list[i].AnimationState:ClearTracks()
                            end
                        end
                    end
                end
        )
    end
    self.m_model.m_feed_pet_ids = {}
end

function M:unLoadPetModel()
    local sceneId = SceneManager.curScene.sceneId
    if sceneId ~= Battle.BattleGlobalConfig.SCENE_ID.PetHallScene then
        for k, v in pairs(self.m_pet_ab_name) do
            ResourceUtil:UnLoadBundle(v, false)
        end
    else
        if SceneManager.curScene.plyMgr.all_list.list then
            local list = SceneManager.curScene.plyMgr.all_list.list
            local ab_name
            local isFind
            for k1, v1 in pairs(self.m_pet_ab_name) do
                isFind = false
                for k2, v2 in ipairs(list) do
                    ab_name = "role3d_" .. string.lower(v2.prefabRoot)
                    if v1 == ab_name then
                        isFind = true
                        break
                    end
                end
                if not isFind then
                    ResourceUtil:UnLoadBundle(v1, false)
                end
            end
        end
    end
end

function M:destroy()
   
    self:unLoadPetModel()
    if self.effect_time then
        self.m_control:removeTimer(self.effect_time)
        self.effect_time = nil
        for i = 1, 3 do
            self.m_effect_go_list[i]:SetActive(false)
            if self.m_effect_spine_list[i].AnimationState then
                self.m_effect_spine_list[i].AnimationState:ClearTracks()
            end
        end
    end
    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, { self, self.everyDayRefreshEvent })
    M.super.destroy(self)
end

return M