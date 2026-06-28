---@class PetBagControl: OOControlBase
---@field m_model PetBagModel
---@field m_view PetBagView
local M = class("PetBagControl", LikeOO.OOControlBase)

function M:onEnter()
    self.m_timer = self:setTimer(1, handler(self, self.updateTime))
    self.m_egg_ok_list = table.copy(self.m_model.m_egg_ok_list)
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, { self, self.closeViewEvent })
    self.m_egg_cache_list = {}
    if #self.m_egg_ok_list > 0 then
        self:checkPopEvolveSucceedPop(1)
    end

end

function M:onHandle(msg, data)
    if self.m_model.m_is_quick_lv and msg ~= "level_up_btn" and msg ~= "quick_level_up_btn" then
        --当弹出快速升级按钮时点击任意其他按钮、 关闭快速升级按钮
        self:closeQuickLevelUp()
    end
    if msg == 99999 then
        -- 返回
        if self.m_model.m_panel_type == 2 then
            self.m_view:switchType(1)
            if table.nums(self.m_model.m_pet_list) > 0 then
                self.m_view:setDetailBtn(true)
            end
            self:switchTabBtn(1)
            return
        end
        self:updateMsg("redPoint_refresh", nil, "PetBreeding.PetBreedingMain")
        self:closeView()
    elseif msg == "level_up_btn" then
        --升级
        if self.m_model.m_is_quick_lv then
            self:sendLvUpReq(self.m_model.m_sel_pet_sever_lv + 1)
        else
            local lv, is_can_quick = self.m_model:checkMaxCanLv()
            if is_can_quick then
                lv = self.m_model:revertToShowLevel(lv)
                self:showQuickLevelUp(lv)
            else
                if self:checkCostCanLv() then
                    self:sendLvUpReq(self.m_model.m_sel_pet_sever_lv + 1)
                end
            end
        end
    elseif msg == "detail_btn" then
        audio:SendEvtUI("UI_XK_HeroInfo")
        --详情信息面板
        if self.m_model.m_panel_type == 1 then
            self.m_view:switchType(2)
            self.m_view:setDetailBtn(false)
        end
    elseif msg == "quick_level_up_btn" then
        --快速升级
        local lv, is_can_quick = self.m_model:checkMaxCanLv()
        if is_can_quick then
            self:sendLvUpReq(lv)
        end
    elseif type(msg) == "number" and msg >= 1 and msg <= 2 then
        -- 1属性、2技能
        self:switchTabBtn(msg)
    elseif msg == "select_pet" then
        --切换宠物
        if self.m_model.m_sel_pet_oid == data.id then
            return
        end
        if self.m_model:checkIsEgg(data.id) and self.m_model.m_sel_tab_index == 2 then
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pet_bag_text_0033"), delay_close = 2 })
            return
        end
        if self.m_model.m_sel_pet_index > data.index then
            data.dir = 2
        else
            data.dir = 1
        end
        self.m_model.m_sel_pet_oid = data.id
        self.m_model.m_sel_pet_index = data.index
        self.m_model:updateCurPetInfo(false)
        self.m_view:updateSelectPet(data.isClick)
        audio:SendEvtUI('Ui_NormalClick')
    elseif msg == "pet_variation_img" then
        --变异弹窗
        self:openView("PetBreeding.PetVariationPop", { pet_oid = self.m_model.m_sel_pet_oid })
    elseif msg == "help_btn" then
        --帮助按钮
        self:openView("Pops.CommonHelpPop", { title = Language:getTextByKey("pet_bag_text_0001"), content = Language:getTextByKey("tid#pubicgift_01") })
    elseif msg == "Sliding_left" then
        local oid, isCanSliding = self.m_model:getRightPet()
        if isCanSliding then
            self:updateMsg("select_pet", { id = oid, dir = 1, index = self.m_model.m_sel_pet_index + 1, isClick = false })
        end
    elseif msg == "Sliding_right" then
        local oid, isCanSliding = self.m_model:getLeftPet()
        if isCanSliding then
            self:updateMsg("select_pet", { id = oid, dir = 2, index = self.m_model.m_sel_pet_index - 1, isClick = false })
        end
    elseif msg == "attr_detail_btn" then
        --属性详情
        self:openView("Pops.Pro_Pop", { pet_attr_list = self.m_model:getAttrPopData() })
    elseif msg == "skill_detail_btn" then
        --技能详情
        self:openView("PetBreeding.PetSkillDetailPop", { own_skill_list = self.m_model:getAllSkillList(), pet_name = self.m_model:getCurPetName(), pet_id = self.m_model:getCurPetCid() })
    elseif msg == "skill_click" then
        --技能图标点击
        local pop_data = self.m_model:getSkillPopDataByType(data.type)
        self:openView("Pops.SkillPop", { ordinary_skill = 2, title_text = pop_data.title_text, skill_text = pop_data.skill_text, click_transform = data.click_transform })
    elseif msg == "reset_btn" then
        --重置
        self:openView("PetBreeding.PetFree", { pet_oid = self.m_model.m_sel_pet_oid })
    elseif msg == "common_refresh" and data then
        --从其他界面返回后刷新数据
        self.m_model:refreshData(true)
        if self.m_model.m_panel_type == 2 and table.nums(self.m_model.m_pet_list) <= 0 then
            self:updateMsg(99999)
        end
        self.m_view:refreshUI()
    elseif msg == "evolve_btn" then
        --进化
        self:openView("PetBreeding.PetSpawn", { pet_oid = self.m_model.m_sel_pet_oid })
    elseif msg == "quick_egg_btn" then
        --加速
        self:openView("PetBreeding.PetEvolveQuicklyPop", { pet_oid = self.m_model.m_sel_pet_oid, source = 1 })
    elseif msg == "pet_egg_success" then
        --成功孵化
        local evolve_succeed_data = self.m_model:getEvolvePopData(data.oid)
        if not evolve_succeed_data or not next(evolve_succeed_data) then
            return
        end
        self.m_model:insertRedList(data.oid)
        --上层没有全屏UI
        if not self:checkHasTopFullUi("PetBreeding.PetBag") then
            self:openView("PetBreeding.PetEvolveSucceedPop",
                    { new_oid = evolve_succeed_data.oid, old_skills = evolve_succeed_data.old_skills, old_variation = evolve_succeed_data.old_variation,
                      variation_skills = evolve_succeed_data.variation_skills, callback = function()
                        self:closeView("PetBag.PetEvolveSucceedPop")
                        self.m_model:refreshData(true)
                        self.m_view:refreshUI()
                    end })
        else
            table.insert(self.m_egg_cache_list, evolve_succeed_data)
        end
    elseif msg == "quickly_pet_egg_success" then
        --成功孵化
        self.m_model:insertRedList(data.oid)
        --上层没有全屏UI
        if not self:checkHasTopFullUi("PetBreeding.PetBag") then
            self:openView("PetBreeding.PetEvolveSucceedPop",
                    { new_oid = data.oid, old_skills = data.old_skills, old_variation = data.old_variation,
                      variation_skills = data.variation_skills, callback = function()
                        self:closeView("PetBag.PetEvolveSucceedPop")
                        self.m_model:refreshData(true)
                        self.m_view:refreshUI()
                    end })
        else
            table.insert(self.m_egg_cache_list, data)
        end
    elseif msg == "no_skill2" then
        local pop_data = self.m_model:getAllHelpSkillPopData()
        self:openView("Pops.SkillPop", { ordinary_skill = 2, title_text = pop_data.title_text, skill_text = pop_data.skill_text, click_transform = data.click_transform })
    elseif msg == "tog2_lock" then
        if self.m_model:checkIsEgg(self.m_model.m_sel_pet_oid) then
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pet_bag_text_0033"), delay_close = 2 })
        end
    elseif msg == "lock_btn" then
        local pet_info = self.m_model:getCurPetInfo()
        if pet_info.data then
            if pet_info.data.lock then
                self:unlockPet()
            else
                self:lockPet()
            end
        end
    elseif msg == "feed_btn" then
        self:feedPet()
    elseif msg == "day_refresh" then
        self.m_model:refreshData(false)
        self.m_view:refreshUI({ ["center"] = true })
    elseif msg == "feed_item_icon" then
        local mood_cfg = self.m_model:getCurMoodCfg()
        local show_data = RewardUtil:getProcessRewardData(mood_cfg.cost)
        static_rootControl:openView("Item.ItemDetail", {show_data = show_data, display = true})
    elseif msg == "btn_sort" then
        self.m_view.m_cur_tab_node["left"]:setObjectVisible("sort_penel_go", true)
    elseif msg == "btn_sort_close" then
        self.m_view.m_cur_tab_node["left"]:setObjectVisible("sort_penel_go", false)
    elseif msg == "btn_turn" then
        self:turnDataList()
    end
end


-- 详情界面tab按钮切换
function M:switchTabBtn(index)
    if index == self.m_model.m_sel_tab_index then
        return
    end
    if index == 2 and self.m_model:checkIsEgg(self.m_model.m_sel_pet_oid) then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pet_bag_text_0033"), delay_close = 2 })
        return
    end
    self.m_model.m_sel_tab_index = index
    self.m_view:changeDescTab(index)
end

--检测道具充足
function M:checkCostCanLv()
    local can_lv_up, index = self.m_model:checkLvResource(self.m_model.m_sel_pet_sever_lv + 1)
    if not can_lv_up then
        if index == 1 then
            local flag = QuickOpenFuncUtil:serverCostsTips(RewardUtil.ERROR_GIFT.ERROR_GIFT_COIN_NUM)
            if not flag then
                local params = {
                    text = string.format(Language:getTextByKey("new_str_0204"))
                }
                self:openView("Pops.CommonPop", params)
            end
        elseif index == 2 then
            local flag = QuickOpenFuncUtil:serverCostsTips(RewardUtil.ERROR_GIFT.ERROR_GIFT_PET_EXP_NUM)
            if not flag then
                local params = {
                    text = string.format(Language:getTextByKey("pet_bag_text_0027"))
                }
                self:openView("Pops.CommonPop", params)
            end
        end
    end
    return can_lv_up
end

--发送升级请求
function M:sendLvUpReq(lv)
    local function callFunc(data)
        if data then
            self:closeQuickLevelUp()
            self.m_model:refreshData(false)
            self.m_view:refreshLevelUpUI()
        end
    end
    if self.m_model:checkLvResource(lv) then
        self.m_model:saveLastLvData()
        self.m_model:getNetData("pet_level_up", { pet_oid = self.m_model.m_sel_pet_oid, level = lv }, callFunc, nil, true)
    else
        self.m_view:updateBtnState()
    end
end

function M:showQuickLevelUp(lv)
    self.m_model.m_is_quick_lv = true
    self.m_model.m_show_quick_lv_time = 3
    self.m_view:setShowQuickLevelUp(lv)
    self.m_show_quick_timer = self:setOnceTimer(3, handler(self, self.closeQuickLevelUp))
end

function M:closeQuickLevelUp()
    if not self.m_model.m_is_quick_lv then
        return
    end
    self.m_model.m_is_quick_lv = false
    self.m_view:setShowQuickLevelUp(0)
end

function M:updateTime()
    if #self.m_model.m_egg_list <= 0 then
        return
    end
    self.m_view:updateTime()
end

function M:checkPopEvolveSucceedPop(type)
    if type == 1 then
        local num = #self.m_egg_ok_list
        if num > 0 then
            self:popEvolveSucceedPop(num, self.m_egg_ok_list[num], type)
        end
    elseif type == 2 then
        local num = #self.m_egg_cache_list
        if num > 0 then
            self:popEvolveSucceedPop(num, self.m_egg_cache_list[num], type)
        end
    end
end

function M:popEvolveSucceedPop(index, data, type)
    if data then
        Logger.log("popEvolveSucceedPop:" .. "index," .. index .. "type:" .. type)
        self:openView("PetBreeding.PetEvolveSucceedPop",
                { new_oid = data.oid, old_skills = data.old_skills, old_variation = data.old_variation,
                  variation_skills = data.variation_skills, callback = function()
                    self:closeView("PetBag.PetEvolveSucceedPop")
                    if type == 1 then
                        table.remove(self.m_egg_ok_list, index)
                    elseif type == 2 then
                        table.remove(self.m_egg_cache_list, index)
                    end
                    self:setOnceTimer(0.017, function()
                        self:checkPopEvolveSucceedPop(type)
                    end)
                end })
    else
        if type == 1 then
            table.remove(self.m_egg_ok_list, index)
        elseif type == 2 then
            table.remove(self.m_egg_cache_list, index)
        end
        self:checkPopEvolveSucceedPop(type)
    end
end

function M:checkHasTopFullUi(view_name)
    local isHave = false
    local cur_sort_order = 999999999

    for i = #self.m_controls, 1, -1 do
        self.m_controls[i] = nil
    end

    for k, v in pairs(static_rootControl.m_chilrenList) do
        if (not isClassOrObject(v)) then
            for kc, vc in pairs(v) do
                if vc.m_model:getName() ~= view_name then
                    table.insert(self.m_controls, vc)
                else
                    cur_sort_order = vc.m_view.m_sortOrder
                end
            end
        else
            if v.m_model:getName() ~= view_name then
                table.insert(self.m_controls, v)
            else
                cur_sort_order = v.m_view.m_sortOrder
            end
        end
    end
    for i, v in pairs(self.m_controls) do
        if v.m_view.m_sortOrder > cur_sort_order then
            if v.m_view.m_size_type == 1 then
                isHave = true
                break
            end
        end
    end
    return isHave
end

function M:closeViewEvent(event, data)
    local view_name = data.name or ""
    if view_name == "PetBreeding.PetEvolveSucceedPop" then
        return
    end
    if not self:checkHasTopFullUi("PetBreeding.PetBag") then
        self:checkPopEvolveSucceedPop(2)
    end

end

function M:lockPet()
    local function callFunc(data)
        if data then
            self.m_model:refreshData(false)
            self.m_view:refreshUI({ ["center"] = true })
        end
    end
    self.m_model:getNetData("pet_lock", { pet_oid = self.m_model.m_sel_pet_oid }, callFunc)
end

function M:unlockPet()
    local function callFunc(data)
        if data then
            self.m_model:refreshData(false)
            self.m_view:refreshUI({ ["center"] = true })
        end
    end
    self.m_model:getNetData("pet_unlock", { pet_oid = self.m_model.m_sel_pet_oid }, callFunc)
end

function M:feedPet()
    local mood_cfg, mood = self.m_model:getCurMoodCfg()
    if mood >= 3 then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pet_bag_text_0041"), delay_close = 2 })
        return
    end
    local cost_data = mood_cfg.cost
    local feed_item_data = RewardUtil:getProcessRewardData(cost_data)
    if feed_item_data.user_num >= mood_cfg.cost[3] then
        local function callFunc(data)
            if data then
                self.m_model:refreshData(false)
                self.m_view:refreshUI({ ["center"] = true })
                self.m_view:playMoodEffect()
            end
        end
        local feed_data = {}
        feed_data[self.m_model.m_sel_pet_oid] = mood + 1
        self.m_model:getNetData("pet_arena_feed", { pet_data = feed_data}, callFunc)
    else
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pet_bag_text_0040"), delay_close = 2 })
    end
end

function M:turnDataList()
    if #self.m_model.m_pet_list <= 0 then
        return
    end
    
    self.m_model:turnPetList()
    self.m_view.m_cur_tab_node["left"]:updatePetsScroll()
    self:updateMsg("select_pet", { id = self.m_model.m_pet_list[1], dir = 1, index = 1, isClick = false })
    self.m_view.m_cur_tab_node["left"]:sliderTopFirstIndex()
end

function M:SortDataList(type)
    if #self.m_model.m_pet_list <= 0 then
        return
    end
    if type ~= nil then
        self.m_model.m_list_sort_type = type        
    end
    self.m_model:sortPetListByType()
    self.m_view.m_cur_tab_node["left"]:updatePetsScroll()
    self:updateMsg("select_pet", { id = self.m_model.m_pet_list[1], dir = 1, index = 1, isClick = false })
    self.m_view.m_cur_tab_node["left"]:setObjectVisible("sort_penel_go", false)
    self.m_view.m_cur_tab_node["left"]:sliderTopFirstIndex()
end

function M:destroy()
    --清除此次弹窗进化数据
    self:removeTimer(self.m_timer)
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, { self, self.closeViewEvent })
    self.m_egg_ok_list = nil
    self.m_egg_cache_list = nil
    M.super.destroy(self)
end

return M
