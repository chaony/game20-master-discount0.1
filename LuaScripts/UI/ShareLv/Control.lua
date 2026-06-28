local M = class("ShareLvPopControl",LikeOO.OOControlBase)

function M:onEnter()
    --local heros = self.m_model.m_data.level_top
    --SceneManager:changeScene(SceneManager.SceneID.PantheonScene, heros)
    --SceneManager:scenestart()
    self.m_guide_file_name = "UI.ShareLv.Guide"
    audio:SendEvtUI("Amb_2D_indoor_fire")
end

function M:startGuide()
    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(39, 2)
    if have_guide then
        if self.m_guide then
            self.m_guide:start()
        end
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("common_refresh", nil, "parent")  
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 21})
    elseif msg == "share_btn" or msg == "tree_btn" then
        -- self:openView("ShareLv.ShareLvHeroPop", self.m_model.m_data)
    elseif msg == "refresh_ui" then
        self.m_view:refreshUI()
    elseif msg == "help_btn" then
    	local params = {}
        params.title = "tid#crystal1"
        params.content = "tid#crystal2"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "open_lv_btn" then
        self:requestUnlock()
    elseif msg == "exp_send" then
        self:requestUpgrade()
    elseif msg == "lv_up" then
        local can_lv, type = self.m_model:checkCelCanLvUp()
        if can_lv == true then
            self.m_model:lvUp()
            self.m_view:showLvEffect(true)
        else
            if type and type == 1 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("hero_role_upgrade_text3"), delay_close = 2})
                self:requestUpgrade(false)
                if self.m_view.changAn_btn then
                    self.m_view.changAn_btn:StopClick(false)
                end
            elseif type and type == 1 then
                self:requestUpgrade(false)
                if self.m_view.changAn_btn then
                    self.m_view.changAn_btn:StopClick(false)
                end
            end
        end
    elseif msg == "lv_btn" then
        self:requestUpgrade()
    elseif msg == "add_hero" then
        local function callback(params)
            self:requestAddHero(params)
        end
        local slot = self.m_model:getSoltDataByIndex(data)
        self:openView("ShareLv.ShareLvSelectPop", {slot_id = slot.id, level_top = self.m_model.m_data.level_top,callback = callback})
    elseif msg == "remove_hero" then
        local function callback(params)
            self:requestRemoveHero(data)
        end
        self:openView("ShareLv.ShareLvRemoveHeroPop", {data = data, callback = callback})
    elseif msg == "remove_time" then
        local user_data = UserDataManager.user_data
        local diamond = user_data:getUserStatusDataByKey("diamond")
        local reset_cost = self.m_model:getClearTimeCost(data)
        local params =
        {
            on_ok_call = function(msg)
                self:requestRemoveTime(data)
            end,
            cost = {RewardUtil.REWARD_TYPE_KEYS.DIAMOND,0,reset_cost},
            text = string.format(Language:getTextByKey("shareLv_str_0007"), reset_cost)
        }
        static_rootControl:openView("Pops.CommonPop", params)
    elseif msg == "open_slot" then
        self:OpenSlot()
    elseif msg == "open_btn" then
        self:OpenSlot()
    elseif msg == "fresh_data" then
        self:refreshData()
    elseif msg == "sort_toggle_btn" then
        self.m_view:setToggleActive(not self.m_view.m_sort_toggle_flag)
    elseif msg == "sort_toggle_bg" then
        self.m_view:setToggleActive(false)
    elseif msg == "sort_btn" then
        self.m_model:sortCrystalSlot(data)
        self.m_view:updateListScroll()
    elseif msg == "guide_check" then
        self.m_guide:checkGuide()
    elseif msg == "rank_btn" then
        self:openView("ShareLv.ShareRankPop")
    end
end

function M:onUpdate()
    self.m_view:refreshUI()
end

function M:requestUnlock()
    local function unlockCallback(response)
        self.m_model:setData(response)
        self.m_view:refreshUI()
        audio:SendEvtUI("Play_UI_Unlock")
    end

    self.m_model:getNetData("hero_crystal_unlock", nil, unlockCallback)
end

function M:requestUpgrade(next)
    local function upgradeCallback(response)
        self.m_model:setData(response)
        self.m_view:showLvEffect()
        local crystal_upgrade = ConfigManager:getCfgByName("crystal_upgrade")
	    local crystal = crystal_upgrade[self.m_model.m_data.clv]
	    if crystal.pull_energy == 1 then
            self:openView("MagicWeapon.MagicWeaponLvUpPop")
        end
    end
    local parms = {}
    if self.m_model.m_client_lv_up == true then
        if next == nil or next == true then
            parms.level = self.m_model.m_data.clv + 1
        else
            parms.level = self.m_model.m_data.clv        
        end
    end
    self.m_model:getNetData("hero_crystal_levelup", parms, upgradeCallback)
end

----------------------------------------------------

function M:requestAddHero(params)
    local flag, name = self.m_model:isHaveSameHero(params.hero_oid)
    local function addCallback(response)
        -- self:openView("ShareLv", {oid = params.hero_oid})
        self.m_model:setSoltData(response)
        self.m_view:refreshUI()
        self.m_view:creatEffect(response)
    end
    if flag then
        local params =
        {
            on_ok_call = function(msg)
                self.m_model:getNetData("hero_crystal_add", params, addCallback)
            end,
            text = string.format(Language:getTextByKey("shareLv_str_0012"), Language:getTextByKey(name))
        }
        static_rootControl:openView("Pops.CommonPop", params)
    else
        self.m_model:getNetData("hero_crystal_add", params, addCallback)
    end
end

function M:requestRemoveHero(data)
    local slot = self.m_model:getSoltDataByIndex(data[1])
    local function removeCallback(response)
        self.m_model:setSoltData(response)
        self.m_view:refreshUI()
    end
    local params = {}
    params.pos = slot.id
    GameUtil:heroInLocalArenaDefenseTips({slot.hid}, function()
        self.m_model:getNetData("hero_crystal_remove", params, removeCallback)
    end, "new_str_0650")
end

function M:requestRemoveTime(data)
    local slot = self.m_model:getSoltDataByIndex(data)
    local function removeCallback(response)
        self.m_model:setSoltData(response)
        self.m_view:refreshUI()
    end
    local params = {}
    params.pos = slot.id
    self.m_model:getNetData("hero_crystal_clear", params, removeCallback)
end

function M:OpenSlot()
    local count = #self.m_model.m_data.crystal_slot
    local reset_cost = GameUtil:getRefreshCost(count, 8)
    local cost_data = RewardUtil:getProcessRewardData(reset_cost)
    local need_num = cost_data.data_num
    if cost_data.user_num < need_num then
        reset_cost = GameUtil:getRefreshCost(count, 7)
        cost_data = RewardUtil:getProcessRewardData(reset_cost)
        --if cost_data.user_num < cost_data.data_num then
        --    QuickOpenFuncUtil:costsTips(cost_data)
        --else
            local params =
            {
                on_ok_call = function(msg)
                    self:requestOpenSlot(1)
                end,
                cost = reset_cost,
                text = string.format(Language:getTextByKey("shareLv_str_0009"),need_num, reset_cost[3])
            }
            static_rootControl:openView("Pops.CommonPop", params)
        --end
    else
        local params =
        {
            on_ok_call = function(msg)
                self:requestOpenSlot(2)
            end,
            cost = reset_cost,
            text = string.format(Language:getTextByKey("shareLv_str_0008"), reset_cost[3])
        }
        static_rootControl:openView("Pops.CommonPop", params)
    end
end

function M:requestOpenSlot(unlock_type)
    local function openCallback(response)
        self.m_model:setSoltData(response)
        self.m_view:refreshUI()
    end
    local params = {}
    params.unlock_type = unlock_type
    self.m_model:getNetData("hero_crystal_open_slot", params, openCallback)
end

function M:refreshData()
    local function netCallback(response)
        self.m_model:setData(response)
        self.m_view:refreshUI()
    end

    self.m_model:getNetData("hero_crystal_index", nil, netCallback)
end

function M:destroy()
    local red_flag = RedPointUtil:hasRedPointById(6001)
    if red_flag then
        RedPointUtil:saveLocalRedPointFreshTime("red_crystal")
    end
    audio:SendEvtUI("Reset_Lpf_Amb_2D_wind_bird_water_frog")
    M.super.destroy(self)
end

return M;
