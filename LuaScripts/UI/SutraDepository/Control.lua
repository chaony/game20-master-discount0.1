---@class SutraDepositoryControl:OOControlBase
---@field m_model SutraDepositoryModel
---@field m_view SutraDepositoryView
local M = class("SutraDepositoryControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.SutraDepository.Guide"
    audio:SendEvtUI("Amb_2D_indoor_fire")
    RedPointUtil:saveLocalRedPointFreshTime("sutra_depository")
end

function M:startGuide()
    M.super.startGuide(self)
    self:triggerGuide()
end

function M:onHandle(msg , data)
    if msg == 99999 then
        if UserDataManager.mystic_data and next(UserDataManager.mystic_data.m_new_ids) ~= nil then
            UserDataManager.mystic_data:clearNewIds()
        end
        self:updateMsg("refreshUI", nil, "MagicWeaponSelectMain")
        self:updateMsg("refresh_red_point", nil, "parent")
        self:closeView()
    elseif msg == "tab_btn" then
        if data ~= self.m_model.m_tab_index then
            self.m_model:setTabIndex(data)
            self.m_view:refreshUI()
        end
    elseif msg == "jiantou_btn" then
        self.m_view:showDesc()
    elseif msg == "other_atk_btn_mask" then --外功
        local red_flag, tips_str = BtnOpenUtil:isBtnOpen(96)
        GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
    elseif msg == "inside_atk_btn_mask" then --内功
        local red_flag, tips_str = BtnOpenUtil:isBtnOpen(98)
        GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
    elseif msg == "shenfa_atk_btn_mask" then --身法
        local red_flag, tips_str = BtnOpenUtil:isBtnOpen(97)
        GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
    elseif msg == "jueji_atk_btn_mask" then --绝技
        local red_flag, tips_str = BtnOpenUtil:isBtnOpen(99)
        GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})

    elseif msg == "help_btn" then
        local params = {}
        --if self.m_model.m_tab_index == 1 then
        --    params.title = "mystic_str_0003"
        --    params.content = "tid#Scripture_Tips_1"
        --else
        --    params.title = "mystic_str_0002"
        --    params.content = "tid#Scripture_Tips_1"
        --end
        params.title = "mystic_str_00120"
        params.content = "tid#Scripture_Tips_1"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "grid_click" then

        self:openView("SutraDepository.Depositoryintensify", {slot_id = data})


        -- local mystic_data = self.m_model:getUsedMysticDataByIndex(data-1)
        -- if mystic_data == nil then -- 空的 打开添加
        --     self:openView("Mystic.MysticSelectPop", {slot_id = data})
        -- else -- 展示秘籍
        --     --Logger.log(mystic_data,"mystic_data ====")
        --     self:openView("Mystic.MysticDetailsPop", {oid = tostring(mystic_data), solt = data, look = 1})
        -- end
    elseif msg == "put_mystic" then
        self:putMysticRequest(data)
    elseif msg == "remove_solt" then -- 删除已配置的秘籍
        self:removeMysticRequest(data)
    elseif msg == "replace_solt" then -- 替换当前槽位的秘籍
        self:putMysticRequest(data)
    elseif msg == "upgrade_btn" then
        if self.m_model.m_need_count <= 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("mystic_str_0022"), delay_close = 2})
        elseif self.m_model.m_need_count > #self.m_model.m_select then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("mystic_str_0023"), delay_close = 2})
        else
            --self:openView("Mystic.MysticUpgradePop", self.m_model.m_select)
            local  param = {}
            param[self.m_model.m_select[1]] = {self.m_model.m_select[2], self.m_model.m_select[3]}

            local function timeCall()
                self:evolutionMysticRequest(param)
                if self.m_view.m_cur_tab_node then
                    self.m_view.m_cur_tab_node:resetUpgradeAnimation()
                end

                self.m_view:unlockTouch()
            end
            self.m_view:lockTouch()
            self:setOnceTimer(2.5,timeCall)
            if self.m_view.m_cur_tab_node then
                self.m_view.m_cur_tab_node:upgradeAnimation()
            end
        end
    elseif msg == "onekey_upgrade_btn" then
        local evolution_type, list = self.m_model:getOneKeyData()
        if evolution_type then
            self:openView("Mystic.MysticSmartPop", {evolution_list = list, evolution_type = evolution_type})
        end
    elseif msg == "select_mystic" then
        -- local status, slot = self.m_model:AddMystic(data.oid)

        -- if status == 0 then
        --     self.m_model.upgrade_anim_slot = slot
        --     self.m_view:refreshUI()
        -- elseif status == 1 then
        --     GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("advanced_str_0004"), delay_close = 2})
        -- elseif status == 2 then
        --     GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("advanced_str_0007"), delay_close = 2})
        -- end 
        self.m_model:setSelectIndex(data.index)
        self.m_view:refreshUI(true)
        --data.mystic_slots = self.m_model.m_data.mystic_slots
        --self:openView("SutraDepository.DepositoryPop", data)
    elseif msg == "upgrade_mystic" then -- 参悟按钮回调
        self.m_view:upgradeMystic(data)

    elseif msg == "remove_mystic" then -- 进阶选中删除
        local slot = self.m_model:removeMystic(data.oid)
        self.m_view:refreshUI()

    elseif msg == "select_practice" then -- 修炼选中
        self.m_model.m_cur_oid = data.oid
        self.m_view:refreshUI()
    elseif msg == "practice_btn" then -- 修炼按钮
        -- self:openView("Mystic.MysticIntensifyPop", {oid = self.m_model.m_cur_oid,list_data = self.m_model.m_list_data})
    elseif msg == "evolution" then
        self:evolutionMysticRequest(data.params)
    elseif msg == "other_atk_btn" or msg == "inside_atk_btn" or msg == "shenfa_atk_btn" or msg == "jueji_atk_btn"  then --功法按钮
        local mystic_type = 0
        if  msg == "other_atk_btn" then
            mystic_type = 1
        elseif msg == "inside_atk_btn" then
            mystic_type = 3
        elseif msg == "shenfa_atk_btn" then
            mystic_type = 2
        elseif msg == "jueji_atk_btn" then
            mystic_type = 4
        end

        self:openView("SutraDepository.Depositoryintensify", {mystic_type = mystic_type,mystic_lv = self.m_model.m_data.mystic_slots[tostring(mystic_type)].lv})
    elseif msg == "synthetic_btn" then -- 合成
        -- local data = self.m_model:getMysticListDataByIndex(self.m_model.m_index)
        -- if data.synthesis_flag then
        --     self:syntheticMystic(data)
        -- else
        --     GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("mystic_str_0048"), delay_close = 2})
        -- end
        self:openView("SutraDepository.DepositoryPromotePop") -- 秘籍参悟
    elseif msg == "promote_btn" then -- 提升按钮
        local data = self.m_model:getMysticListDataByIndex(self.m_model.m_index)
        if data.sort_value == 6 then
            self.m_model.m_oid = data.id
            local params = {mystic_id = self.m_model.m_oid}
            self:promoteMysticRequest(params)
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("mystic_str_0048"), delay_close = 2})
        end
    elseif msg == "update_data" then
        self.m_model:updateData(data)
        self.m_view:refreshUI(true)
    elseif msg == "group_detail_btn" then
        -- local data = self.m_model:getMysticListDataByIndex(self.m_model.m_index)
        -- self:openView("SutraDepository.DepositoryGropSkillTips", {id = data.id})
    elseif msg == "check_guide" then
        self.m_guide:checkGuide()
    elseif msg == "click_inset_slot" then -- 点击镶嵌槽
        local mystic_data = self.m_model:getMysticListDataByIndex(self.m_model.m_index)
        local params = {}
        params.id = mystic_data.id
        params.pos = data.slot
        if data.data.id ~= nil then
            params.mystic_data = data.data
            params.mode = 3
            self:openView("SutraDepository.DepositoryPop", params)
        else
            self:openView("SutraDepository.DepositoryInsetPop", params)
        end
    elseif msg=="intensify_btn" then
        local mystic_data = self.m_model:getMysticListDataByIndex(self.m_model.m_index)
        self:Mystic_request("mystic_levelup",mystic_data.id)
    elseif msg=="unlock_btn" then
        local mystic_data = self.m_model:getMysticListDataByIndex(self.m_model.m_index)
        self:Mystic_request("mystic_activate",mystic_data.id)
        --local meetCondition,lackNum=self.m_model:judgeCurSelectedMysticChipNum()
        --if meetCondition then
        --    self:Mystic_request("mystic_activate",mystic_data.id)
        --else
        --    self:openView("SutraDepository/MysticChipConvert",{lackNum=lackNum,mystic_cfg=mystic_data.cfg,chipId=mystic_data.cfg.chip_id,callback=function()
        --        self.m_view:refreshUI()
        --    end})
        --end
    elseif msg=="break_btn" then
        local mystic_data = self.m_model:getMysticListDataByIndex(self.m_model.m_index)
        local meetCondition,lackNum=self.m_model:judgeCurSelectedMysticChipNum()
        if meetCondition  then
            self:Mystic_request("mystic_starup",mystic_data.id)
        else
            self:openView("SutraDepository/MysticChipConvert",{lackNum=lackNum,mystic_cfg=mystic_data.cfg,chipId=mystic_data.cfg.chip_id,callback=function()
                self.m_view:refreshUI()
            end})
        end
    elseif msg=="skill_detail_btn" then
        local click_obj = self.m_view:findGameObject(msg)
        local title,skill_text=self.m_model:getNextStarBuffDetail()
        self:openView("Pops.SkillPop", {ordinary_skill = 4,title_text =Language:getTextByKey(title), skill_text =skill_text,click_transform = click_obj.transform,pivot = Vector2(1,1)})
    end
end

--秘籍激活，强化，升星请求
function M:Mystic_request(url,mysticId)
    local function putCallback(response)
        self.m_model:updateList()
        self.m_view:refreshUI()
    end
    self.m_model:getNetData(url, {mystic_id = mysticId}, putCallback)
end

function M:removeMysticRequest(data)
    local function putCallback(response)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("mystic_take_out_mystic", {slot_id = data - 1}, putCallback)
end

function M:putMysticRequest(params)
    if params then
        local function putCallback(response)
            self.m_model.use_anim_slot = params.slot_id
             self.m_model:updateData(response)
            -- self.m_view:refreshUI()
            self.m_view:upgradeMystic(params)
            self:updateMsg("mystic_callback", response, "SutraDepository.DepositoryPop")
            audio:SendEvtUI("UI_MiJi_Up")
        end
        self.m_model:getNetData("mystic_put_mystic_in_slot", params, putCallback)
    end
end

function M:evolutionMysticRequest(params)
    -- Logger.log(params,"params ====")
    if params then
        local function evolutionCallback(response)
            if response.reward then
                RewardUtil:rewardTipsByData(response.reward)
            end
            self.m_model:updateData({select_mystic = response.select_mystic, mystic_slots = response.mystic_slots})
            self.m_view:refreshUI()
        end
        self.m_model:getNetData("mystic_evolution", {mystic_data = params}, evolutionCallback, false, false, GlobalConfig.POST)
    end
end

--合成秘籍  mystic_id: 1   秘籍id (秘籍配置id)
function M:syntheticMystic(data)
    local function putCallback(response)
        self.m_model:updateData(response)
        self.m_view:playSyntheticMysticAnim()
        audio:SendEvtUI("UI_MiJi_Synthesis")
    end
    self.m_model:getNetData("mystic_synthetic", {mystic_id = data.id}, putCallback)
end

function M:promoteMysticRequest(params)
    if params then
        local function promoteCallback(response)
            self.m_model:updateData(response)
            self.m_view:refreshUI()
            self:openView("SutraDepository.DepositoryPopNode", {cur_m_oid=self.m_model.m_oid})
            audio:SendEvtUI("UI_MiJi_LevelUp")
        end
        self.m_model:getNetData("mystic_up_sta", params, promoteCallback)
    end
end

-- 合成和升星引导触发条件
function M:triggerGuide()
    local guide_info = UserDataManager.guide_data:getCurGuideInfo()
    if guide_info == nil or guide_info.key ~= "SutraDepository" then
        if self.m_model.m_has_synthesis then -- 合成
            local id = ConfigManager:getCommonValueById(377)
            UserDataManager.guide_data:setAnyTeamGuide(id)
            self.m_guide:checkGuide()
        end
    end

    guide_info = UserDataManager.guide_data:getCurGuideInfo()
    if guide_info == nil or guide_info.key ~= "SutraDepository" then
        if self.m_model.m_has_up_star then -- 升星
            local id = ConfigManager:getCommonValueById(378)
            UserDataManager.guide_data:setAnyTeamGuide(id)
            self.m_guide:checkGuide()
        end
    end
end

function M:destroy()
    audio:SendEvtUI("Reset_Lpf_Amb_2D_wind_bird_water_frog")
    M.super.destroy(self)
end

return M
