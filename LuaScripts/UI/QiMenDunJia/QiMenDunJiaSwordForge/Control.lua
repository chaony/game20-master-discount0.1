local M = class("QiMenDunJiaSwordForgeControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "box_click" then
        audio:SendEvtUI("UI_Treasure_Click")
        self.m_view:updateRelicsInfo(data)
    elseif msg == "left_left_arrow_btn" then
        self.m_view:moveRelicsProgressLoopScrollPage(-1)
    elseif msg == "left_right_arrow_btn" then
        self.m_view:moveRelicsProgressLoopScrollPage(1)
    elseif msg == "use_btn" then
        --self:requestForUse()
        if self.m_model:getShareLv() == true then
            static_rootControl:closeAllViewPop()
            --QuickOpenFuncUtil:openFunc(81)
            QuickOpenFuncUtil:openFunc(89)
            self:updateMsg(99999)
        else
            local weapon_lock_lv = ConfigManager:getCommonValueById(577,160)
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("weapon_str_0006", weapon_lock_lv), delay_close = 2 })
        end
    elseif msg == "level_up_btn" then
        audio:SendEvtUI("UI_Treasure_Up")
        self:requestForLevelUp()
    elseif msg == "sword_reset_des_btn" then
        local common = ConfigManager:getCfgByName("common")
        local params_tab = {0, 0}
        if common[644] and common[645] then
            params_tab = {(common[644].value * 100) .. "%", common[645].value}
        end
        local content_str = GameUtil:formatTextString(Language:getTextByKey("tid#QMDJ_dec_04"), params_tab)
        self:openView("QiMenDunJia.QiMenDunJiaContentPopTwo", {content_str = content_str})
    end
end

function M:requestForUse()
    --法宝功能未开启
    if self.m_model:isRelicsFunctionOpen() == false then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("weapon_str_0006", ConfigManager:getCommonValueById(577,160) ), delay_close = 2 })
        return
    end
    
    if self.m_model:isCurrentRelicsAvailableToUse() == false then
        local relics_data = self.m_model:getCurrentRelicsData()
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_men_dun_jia_str_023", Language:getTextByKey(relics_data.cfg.name_tips)), delay_close = 2})
        return
    end
    
    local function readCallback(response)
        if response then
            table.merge(UserDataManager.m_slots, response.slots)
            self.m_view:updateRelicsInfo(self.m_model:getSelectedCellData())
        end
    end
    local params = {}
    params.slot_id = self.m_model:getRelicsPosition()
    params.relic_id = self.m_model:getRelicsID()
    self.m_model:getNetData("relic_select_relic", params, readCallback)
end

function M:requestForLevelUp()
    --最大等级
    if self.m_model:isRelectMaxLevel() then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_men_dun_jia_str_024"), delay_close = 2})
        return
    end
    --帮会币不足
    if self.m_model:getRelicsExpCount() < self.m_model:getCurrentLevelRelicsCost() then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_men_dun_jia_str_022"), delay_close = 2})
        return 
    end
    
    self.m_model:setRelicsProgressLoopScrollPosition(self.m_view:getRelicsProgressLoopScrollPosition())
    
    local function netCallback(response)
        self:openView("MagicWeapon.MagicWeaponLvUpPop")
        self.m_model:updateRelicsData(response)
        self.m_view:updateRelicsProgressLoopScroll()
        self.m_view:updateRelicsProgressBar()
        self.m_view:updateRelicsProgressLoopScrollStatus(false)
    end
    local params = {
        ver = self.m_model:getVersion(),
        relic_id = self.m_model:getRelicsID()
    }
    self.m_model:getNetData("gve_guild_relic_lvlup", params, netCallback)
end

return M
