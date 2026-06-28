---@class PetBagPetNode: OOUIbase
---@field m_model PetBagModel
local M = class("PetBagPetNode", LikeOO.OOUIbase)

M.m_uiName = "PetBreeding/PetBagPetNode"

function M:onEnter()
    self:bindUI()
    self:refreshUI()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})
end

function M:bindUI()
    local com_parent = self:findGameObject("hero_effect_parent")
    self.lv_lizi = ResourceUtil:GetUIEffectItem("HeroInfo/UI_HeroInfo_ShengJi_002", com_parent)
    self:setParticleRenderOrder(self.lv_lizi)
    self.lv_lizi:SetActive(false)
    self:setTextByLanKey("hatch_text", "pet_bag_text_0029")
    self:setTextByLanKey("egg_tips", "pet_bag_text_0028")
    self:setTextByLanKey("reset_btn_text", "pet_bag_text_0009")
    self.m_info_node = self:findRectTransform("pet_name_node")
    self.m_go_3d = self:findGameObject("gameObject_3d")
    self.m_go_3d.transform:SetParent(self.m_rootView.transform, false)
    UIUtil.setScale(self.m_go_3d.transform, 1, 1, 1)
    self.m_pet_parent = self:findGameObject("role_3d")
    self.m_egg_spine_node = self:findSkeletonGraphic("egg_img")
    self.m_pet_obj = nil
    self.m_pet_ab_name = nil
    local effect_parent = self:findGameObject("lv_effect_parent")
    self.lv_lizi = ResourceUtil:GetUIEffectItem("HeroInfo/UI_HeroInfo_ShengJi_002", effect_parent)
    self:setParticleRenderOrder(self.lv_lizi)
    self.lv_lizi:SetActive(false)
    self.m_mood_slider = self:findSlider("mood_slider")
    self.m_feed_icon = self:findImage("feed_item_icon")
    self.m_feed_btn = self:findImage("feed_btn")
    local gray_img = self:findImage("gray_img")
    self.m_gray_material = gray_img.material
    self.m_open_mood = self.m_model:checkMoodOpen()
    self.m_mood_effect = self:findGameObject("UI_PetBagPetNode_HaoGan_001")
    self.m_mood_effect:SetActive(false)
    self.m_mood_spine = self:findSkeletonGraphic("HaoGan")
end

function M:InitType(c_type, first)
    if c_type == 1 then
        local move_x = self.m_model:getCurMoveX(266.25, self.m_control.m_view.m_view_width)
        if first == false then
            GameUtil:dotweenMoveX(self.m_rt.gameObject, move_x)
        else
            self.m_rt.localPosition = Vector3.New(move_x, 0, 0)
        end
    elseif c_type == 2 then
        local move_x = self.m_model:getCurMoveX(-236, self.m_control.m_view.m_view_width)
        if first == false then
            GameUtil:dotweenMoveX(self.m_rt.gameObject, move_x)
        else
            self.m_rt.localPosition = Vector3.New(move_x, 0, 0)
        end

    end
    self:setObjectVisible("next_btn", c_type ~= 1 and self.m_model.m_sel_tab_index == 1)
    self:setObjectVisible("last_btn", c_type ~= 1 and self.m_model.m_sel_tab_index == 1)
end

function M:refreshUI()
    self:stopEffect()
    self:setShowVisible(true)
    local data = self.m_model.m_pet_list
    if #data <= 0 or not self.m_model.m_sel_pet_oid then
        self:setShowVisible(false)
        self:setDetailBtn(false)
        return
    end
    self:updatePetInfo()
    local pet_data = self.m_model:getCurPetInfo()
    local isEgg = self.m_model:checkIsEgg(self.m_model.m_sel_pet_oid)

    if isEgg then
        self:setObjectVisible("role_3d", false)
        self:setObjectVisible("reset_btn", false)
        self:setObjectVisible("lock_btn", false)
        self:setObjectVisible("mood_node", false)
        local egg_spine = self.m_model.m_evolutionCfg[pet_data.data.evo].egg_spine
        if egg_spine then
            GameUtil:updateSpineLoadSet(self.m_egg_spine_node, "RoleSpine/" .. tostring(egg_spine), "idle", 0, true)
        end
    else
        self:setObjectVisible("lock_btn", true)
        local lock_img_name = pet_data.data.lock and "a_zbxl_jinsuo" or "a_zbxl_suo_open"
        local lock_img_atlas = pet_data.data.lock and "mystic_ui" or "active_ui"
        self:setImg(lock_img_name, lock_img_atlas, "lock_btn_img")
        self:setObjectVisible("reset_btn", pet_data.data.lock ~= true)
        self:setObjectVisible("pet_egg", false)
        self:updatePetModel(pet_data.cfg)
        if self.m_open_mood then
            self:updatePetMood()
        end
        
    end
end

function M:showLvEffect()
    if self.lv_lizi_time then
        self.m_control:removeTimer(self.lv_lizi_time)
        self.lv_lizi:SetActive(false)
        self.lv_lizi_time = nil
    end
    self.lv_lizi:SetActive(true)
    if self.m_control then
        self.lv_lizi_time = self.m_control:setTimer(
                1,
                function()
                    if self.lv_lizi_time then
                        self.m_control:removeTimer(self.lv_lizi_time)
                        self.lv_lizi:SetActive(false)
                        self.lv_lizi_time = nil
                    end
                end
        )
    end
end

function M:updatePetInfo()
    local oid = self.m_model.m_sel_pet_oid
    GameUtil:createPetGeneration(oid, self.m_info_node)
end

function M:updatePetMood()
    local mood_cfg, mood = self.m_model:getCurMoodCfg()
    if mood_cfg then
        self:setTextByLanKey("mood_des_text", mood_cfg.name)
        self:setTextByLanKey("mood_add_text", mood_cfg.description)
        local slider_value = 0
        if mood == 1 then
            slider_value = 0
        elseif mood == 2 then
            slider_value = 0.5
        elseif mood == 3 then
            slider_value = 1
        end
        self.m_mood_slider.value = slider_value
        self:setObjectVisible("feed_item_bg", mood ~= 3)
        if mood == 3 then
            self.m_feed_btn.material = nil
            return
        end
        local feed_item_data = RewardUtil:getProcessRewardData(mood_cfg.cost)
        if feed_item_data.user_num >= mood_cfg.cost[3] then
            self:setText("feed_item_text", tostring(mood_cfg.cost[3]))
            self.m_feed_icon.material = nil
            self.m_feed_btn.material = nil
        else
            self:setTextByLanKey("feed_item_text", "pet_bag_text_0039")
            self.m_feed_icon.material = self.m_gray_material
            self.m_feed_btn.material = self.m_gray_material
        end
        self:setImg(feed_item_data.icon_name, "item_icon", "feed_item_icon")
    end
   
end

function M:updatePetModel(cfg)
    if not cfg then
        return
    end
    if not IsNull(self.m_pet_obj) then
        U3DUtil:Destroy(self.m_pet_obj)
        self.m_pet_obj = nil
    end
    local obj = ResourceUtil:LoadRole3d(cfg.prefab)
    self.m_pet_obj = obj
    if not IsNull(obj) then
        local luaViewHelper = obj:GetComponent("LuaViewHelper")
        if luaViewHelper then
            luaViewHelper.enabled = false
        end
        self.m_pet_ab_name = cfg.prefab
        obj.transform:SetParent(self.m_pet_parent.transform, false)
        obj.transform.localPosition = Vector3(0, 0, 0)
        obj.transform.localRotation = Quaternion.Euler(0, cfg.package_y, 0)
        obj.transform.localScale = Vector3(cfg.interact_scale, cfg.interact_scale, cfg.interact_scale)
        GlobalTools:CloseShadow(obj.transform)
    else
        Logger.logError(cfg.prefab, "LoadRole3d failed : ")
    end
end

function M:setShowVisible(isShow)
    self:setObjectVisible("pet_egg", isShow)
    self:setObjectVisible("reset_btn", isShow)
    self:setObjectVisible("pet_egg", isShow)
    self:setObjectVisible("role_3d", isShow)
    self:setObjectVisible("pet_name_node", isShow)
    self:setObjectVisible("mood_node", isShow and self.m_open_mood)
    self:setObjectVisible("lock_btn", isShow)
end

function M:setDetailBtn(isShow)
    self:setObjectVisible("detail_btn", isShow)
end

function M:onButtonClick(obj, name)
    if name == "last_btn" then
        self:updateMsg("Sliding_right")
    elseif name == "next_btn" then
        self:updateMsg("Sliding_left")
    else
        M.super.onButtonClick(self, obj, name)
    end
end

function M:refreshLevelUpUI()
    local last_lv = self.m_model.last_lv
    local cur_lv = self.m_model:getCurShowLevel()
    if cur_lv > last_lv then
        self:stopEffect()
        self.lv_lizi:SetActive(true)
        self.lv_lizi_time = self.m_control:setTimer(1, handler(self, self.stopEffect))
    end

end

function M:stopEffect()
    if self.lv_lizi_time then
        self.m_control:removeTimer(self.lv_lizi_time)
        self.lv_lizi:SetActive(false)
        self.lv_lizi_time = nil
    end
    if self.effect_time then
        self.m_control:removeTimer(self.effect_time)
        self.m_mood_effect:SetActive(false)
        self.effect_time = nil
        self.m_mood_spine.AnimationState:ClearTracks()
    end
end

function M:everyDayRefreshEvent()
    self:updateMsg("day_refresh")
end

function M:playMoodEffect()
    if self.effect_time then
        self.m_control:removeTimer(self.effect_time)
        self.m_mood_effect:SetActive(false)
        self.effect_time = nil
        self.m_mood_spine.AnimationState:ClearTracks()
    end
    self.m_mood_effect:SetActive(true)
    self.m_mood_spine.AnimationState:SetAnimation(0, "PetBagPetNode_HaoGan_001", false)
    if self.m_control then
        self.effect_time = self.m_control:setTimer(
                1,
                function()
                    if self.effect_time then
                        self.m_control:removeTimer(self.effect_time)
                        self.m_mood_effect:SetActive(false)
                        self.effect_time = nil
                        self.m_mood_spine.AnimationState:ClearTracks()
                    end
                end
        )
    end
end

function M:destroy()
    self:stopEffect()
    if self.m_pet_ab_name then
        ResourceUtil:UnLoadBundle(self.m_pet_ab_name, false)
    end
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})
    M.super.destroy(self)
end

return M
