local M = class("JewelControl",LikeOO.OOControlBase)

function M:onEnter()
    --self.m_guide_file_name = "UI.Treasure.Guide"
    --if self.m_model.m_evo_hero_oid then --默认选中
    --   self:updateMsg("select_hero", {oid = self.m_model.m_evo_hero_oid})
    --end
end

--[[function M:startGuide()
    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(29, 1)
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
    elseif msg == "help_btn" then
        local params = {title = "jewel_text_001", content = "tid#Jewel_1"}
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "tab_btn" then
        local toggle = data
        if self.m_model.m_is_book == true then
            self.m_view:updateBookScroll(toggle)
        else
            self.m_view:updateListScroll(toggle)
        end
    elseif msg == "chip_num_btn" then
        local quality = data.quality
        local obj = data.obj
        local text = nil
        if quality == 4 then
            text = "jewel_text_022"
        elseif quality == 5 then
            text = "jewel_text_023"
        elseif quality == 6 then
            text = "jewel_text_024"
        elseif quality == 8 then
            text = "jewel_text_025"
        end
        GameUtil:lookInfoTips(self,{click_transform = obj.transform, msg = Language:getTextByKey("jewel_text_021", Language:getTextByKey(text))})
        --GameUtil:lookInfoTips(self,{msg = Language:getTextByKey("jewel_text_021", Language:getTextByKey(text)), delay_close = 2})
    elseif msg == "select_jewel" then
        local is_book = data.is_book or false
        local id = data.jewel.id
        if is_book == true then
            self:openView("Jewel.JewelDetailsPop", {id = id, evo = 5, awaken = 1}) --图鉴查看，按已觉醒显示
            return
        end
        local jewel = UserDataManager.jewel_data:getJewel(id) --宝物实例
        if jewel == nil then --没激活且碎片足够的
            local is_can_active = data.jewel.user_chip_num >= data.jewel.need_chip_num
            if is_can_active == true then
                self:requestActive(id)
                return
            end
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("jewel_text_019"), delay_close = 2})
            return
        end
        self:openView("Jewel.JewelDetailsPop", {id = id, evo = jewel.evo, awaken = jewel.awaken})
    elseif msg == "gacha_btn" then
        --local params = {gacha = self.m_model.m_gacha}
        --self:openView("Jewel.JewelGacha", params)
        self:openView("Jewel.JewelGacha")
        self:closeView()
    elseif msg == "update_jewel" then
        local type = data.type
        local id = data.id
        if type == 1 then
            UserDataManager.jewel_data:updateActive(id)
        elseif type == 2 then
            local evo = data.evo
            UserDataManager.jewel_data:updateEvo(id, evo)
        elseif type == 3 then
            UserDataManager.jewel_data:updateAwaken(id)
        end
        self.m_view:refreshJewelElement(type, id)
    end
end

function M:requestActive(id)
    local function callback(response)
        if response then
            local jewel_id = response.jewel_id
            --更新秘宝
            self:updateMsg("update_jewel", {type = 1, id = jewel_id}, "Jewel")
            UserDataManager.jewel_data:updateEffects(response.effects) --秘宝效果
            --获得新秘宝界面关闭后，显示详情
            local function closeCallback()
                self:openView("Jewel.JewelDetailsPop", {id = jewel_id, evo = 1, awaken = 0})
            end
            self:openView("Jewel.JewelNewPop", {id = jewel_id, callback = closeCallback})
        end
    end
    local params = {jewel_id = id}
    self.m_model:getNetData("jewel_activate", params, callback)
end

function M:destroy()
    M.super.destroy(self)
end

return M