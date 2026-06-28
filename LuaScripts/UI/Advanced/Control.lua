local M = class("AdvancedPopControl",LikeOO.OOControlBase)

function M:onEnter()
    --SceneManager:changeScene(SceneManager.SceneID.AdvancedScene, nil)
    --SceneManager:scenestart()
    self.m_guide_file_name = "UI.Advanced.Guide"
    audio:SendEvtUI("Amb_2D_indoor_fire")
    --self:clearRedPoint()
    if self.m_model.m_default_select_oid then --默认选中
        self:updateMsg("select_hero", {oid = self.m_model.m_default_select_oid})
    end
end

--[[function M:startGuide()
    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(29, 3)
    if have_guide then
        if self.m_guide then
            self.m_guide:start()
        end
    end
end]]--

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 7})
    elseif msg == "tab_btn" then
        self.m_model:setMartial(data)
        self.m_view:updateHerosScroll()
    elseif msg == "select_hero" then
        -- Logger.log(data,"select_hero ====")
        local status, slot = self.m_model:AddHero(data.oid)
        if status == 0 then
            self.m_model.m_is_show_detail = false
            self.m_view:showDetailNode()
            self.m_model.anim_slot = slot
            self.m_view:refreshUI()

            local show_type = self.m_model.m_need_count == 3 and 1 or 2
            if #self.m_model.m_select == 1 and self.m_model.is_link == false then
                self.m_view:setSpine()
            elseif self.m_model.is_link == true then
                self.m_view:setSpine()
            end
        elseif status == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("advanced_str_0004"), delay_close = 2})
        elseif status == 2 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("advanced_str_0007"), delay_close = 2})
        elseif status == 4 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("advanced_str_0010"), delay_close = 2})
        elseif status == 5 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("advanced_str_0019"), delay_close = 2})
        end
    elseif msg == "remove_hero" then
        self.m_model.m_is_show_detail = false
        self.m_view:showDetailNode()
        local slot = self.m_model:removeHero(data.oid)
        self.m_view:refreshUI()
        if #self.m_model.m_select == 0 then
            self.m_view:setSpine()
            --SceneManager.curScene:removeAllHero()
        else
            if self.m_model.is_link == true then
                self.m_view:setSpine()
            end
            if slot then
                --SceneManager.curScene:removeHero(slot)
            end
        end
    elseif msg == "advanced_btn" then
        local universal_tab = self.m_model:checkCanUseUniversal()
        if next(universal_tab) ~= nil then
            if self.m_model:checkHaveUniversal() == true then
                self:openView("Advanced.AdvancedDetailsPop",{data = self.m_model.m_select, slot_consume = self.m_model.m_slot_consume})
            end
        else
            if #self.m_model.m_select > 0 and #self.m_model.m_select == self.m_model.m_need_count then
                self:openView("Advanced.AdvancedDetailsPop",{data = self.m_model.m_select, slot_consume = self.m_model.m_slot_consume})
            else
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("advanced_str_0003"), delay_close = 2})
            end
        end
    elseif msg == "advanced" then
        if not self.m_model.m_select[1] then
            return
        end
        local params = {}
        local oneData = {}
        local cons_data = {}
        local universal_tab = self.m_model:checkCanUseUniversal()
        if next(universal_tab) ~= nil and self.m_model:checkHaveUniversal() == true and self.m_model:checkUseUniversalNum() > 0 then
            --本次使用了万能材料 
            cons_data = self.m_model:getLutionConsData(universal_tab)
        else
            for hero_index, hero_id in pairs(self.m_model.m_select) do
                if hero_index > 1 then
                    table.insert( cons_data, hero_id)
                end
            end
        end
        oneData[self.m_model.m_select[1]] = cons_data
        params.hero_data = oneData
        local function callBackFunc()
            self:sendHeroEvoLutionNet(params, function(response)
                self.m_view:lockTouch()
                local function timeCall()
                    local heros = {}
                    local length = 0
                    for k,v in pairs(params.hero_data) do
                        heros[#heros + 1] = k
                        length = length + 1
                    end
                    self:openView("Advanced.AdvancedSuccessPop",{hero = self.m_model.m_select[1]})
                    if response.reward then
                        RewardUtil:rewardTipsByData(response.reward)
                    end
                    self.m_model:reset()
                    self.m_model:updateOneKeyData(response.select_evo)
                    self.m_view:resetPosition()
                    self.m_view:refreshUI()
                end
                self:setOnceTimer(1.5,timeCall)
                self.m_view:advancedAnimation()
            end)
        end
        GameUtil:heroInLocalArenaDefenseTips(oneData[self.m_model.m_select[1]], callBackFunc, "new_str_0649")
    elseif msg == "one_key_btn" then
        self.m_model.m_is_show_detail = false
        self.m_view:showDetailNode()
        local dataTab = {}
        if self.m_model.m_evo_num > 0 then
            dataTab = self.m_model.m_oneKey_data.onekey
        elseif self.m_model.m_adv_num > 0 then
            dataTab = self.m_model.m_oneKey_data.intellect
        end
        self:openView("Advanced.AdvancedSmartPop", {data = dataTab})
    elseif msg == "advanced_smart" then
        self.m_model.m_is_show_detail = false
        self.m_view:showDetailNode()
        local params = {}
        params.hero_data = data.param
        params.from_smart = true
        local all_cost_hero = {}
        for k,v in pairs(data.param) do
            table.insertto(all_cost_hero, v)
        end
        GameUtil:heroInLocalArenaDefenseTips(all_cost_hero, function()
            self:heroEvolution(params,true)
        end, "new_str_0649")
    elseif msg == "help_btn" then
        local params = {}
        params.title = "new_str_0021"
        params.content = "tid#cathedral102002"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "race_toggle_btn" then
        self.m_view:setToggleActive(not self.m_view.m_race_toggle_flag)
    elseif msg == "race_toggle_bg" then
        self.m_view:setToggleActive(false)
    elseif msg == "wuxing_btn" then
        if self.m_model.m_detail_index ~= 1 then
            self.m_model.m_detail_index = 1
            self.m_view:showDetailNode()
        end
    elseif msg == "yin_btn" then
        if self.m_model.m_detail_index ~= 2 then
            self.m_model.m_detail_index = 2
            self.m_view:showDetailNode()
        end
    elseif msg == "yang_btn" then
        if self.m_model.m_detail_index ~= 3 then
            self.m_model.m_detail_index = 3
            self.m_view:showDetailNode()
        end
    elseif msg == "yuan_btn" then
        if self.m_model.m_detail_index ~= 4 then
            self.m_model.m_detail_index = 4
            self.m_view:showDetailNode()
        end 
    elseif msg == "detail_btn" then
        self.m_model.m_is_show_detail = not(self.m_model.m_is_show_detail)
        self.m_view:showDetailNode()
    elseif msg == "detail_close_btn" then
        self.m_model.m_is_show_detail = false
        self.m_view:showDetailNode()
    elseif msg == "link_btn" then --结义
        self:openView("Advanced.AdvancedDetailsPop",{data = self.m_model.m_select, slot_consume = self.m_model.m_slot_consume, islink = self.m_model.is_link, link_type = 1})
    elseif msg == "link_remove_btn" then--结义解除
        self:openView("Advanced.AdvancedDetailsPop",{data = self.m_model.m_select, slot_consume = self.m_model.m_slot_consume, islink = self.m_model.is_link, link_type = 3})
    elseif msg == "link_levelup_btn" then--结义加深
        self:openView("Advanced.AdvancedDetailsPop",{data = self.m_model.m_select, slot_consume = self.m_model.m_slot_consume, islink = self.m_model.is_link, link_type = 2})
    elseif msg == "link_level_up_net" then -- 结义加深请求
        self:netHeroLinkLevelUp(data)
    elseif msg == "link_remove_net" then -- 结义解除请求
        self:netHeroUnLink(data)
    elseif msg == "link_net" then --结义请求
        self:netHeroLink()
    end
end

--发送请求
function M:sendHeroEvoLutionNet(params, callback)
	self.m_model:getNetData("hero_evolution", params, callback, false, false, GlobalConfig.POST)
end

function M:heroEvolution(params, isOnekey)
	local function advancedCallback(response)
        local heros = {}
        local length = 0
        for k,v in pairs(params.hero_data) do
            heros[#heros + 1] = k
            length = length + 1
        end
        if isOnekey == true then
            if length == 1 then
                self:openView("Advanced.AdvancedSuccessPop",{hero = heros[1]})
            end
            if next(response.reward) then
                RewardUtil:rewardTipsByData(response.reward)
            end
        else
            self:openView("Advanced.AdvancedSuccessPop",{hero = self.m_model.m_select[1]})
            if response.reward then
                RewardUtil:rewardTipsByData(response.reward)
            end
        end
		self.m_model:reset()
        self.m_model:updateOneKeyData(response.select_evo)
        self.m_view:resetPosition()
		self.m_view:refreshUI()
	end
	self.m_model:getNetData("hero_evolution", params, advancedCallback, false, false, GlobalConfig.POST)
end

function M:clearRedPoint()
    local function clearRedCall()
        UserDataManager:removeRedDotByKey("hero_evolution")
    end
    self.m_model:getNetData("red_dot_clear", {red_dot_type = {"hero_evolution"}}, clearRedCall)
end

--结义
function M:netHeroLink()
    local function clearRedCall(response)
        self:openView("Advanced.AdvancedSuccessPop",{hero = self.m_model.m_select[1]})
        self.m_model:reset()
        self.m_view:refreshUI()
        self.m_view:setSpine()
    end
    if #self.m_model.m_select < 2 then
        return
    end
    local cur_hero = self.m_model.m_select[1]
    local link_hero = self.m_model.m_select[2]
    self.m_model:getNetData("hero_link", {hero_oid = cur_hero, obj_hero_oid = link_hero}, clearRedCall)
end

--结义解除
function M:netHeroUnLink(data)
    local function clearRedCall(response)
        self:openView("Advanced.AdvancedSuccessPop",{hero = self.m_model.m_select[1],link_id = self.m_model.m_select[2], martial = data})
        self.m_model:reset()
        self.m_view:refreshUI()
        self.m_view:setSpine()
    end
    if #self.m_model.m_select < 2 then
        return
    end
    local cur_hero = self.m_model.m_select[1]
    self.m_model:getNetData("hero_unlink", {hero_oid = cur_hero}, clearRedCall)
end

--结义加深
function M:netHeroLinkLevelUp(data)
    local function clearRedCall(response)
        self:openView("Advanced.AdvancedSuccessPop",{hero = self.m_model.m_select[1]})
        self.m_model:reset()
        self.m_view:refreshUI()
        self.m_view:setSpine()
    end
    local cur_hero = self.m_model.m_select[1]
    self.m_model:getNetData("hero_link_lvlup", {hero_oid = cur_hero, material = data }, clearRedCall)
end

function M:destroy()
    audio:SendEvtUI("Reset_Lpf_Amb_2D_wind_bird_water_frog")
    M.super.destroy(self)
end

return M
