---@class BanHeroControl:OOControlBase
---@field m_model BanHeroModel
---@field m_view BanHeroView
local M = class("BanHeroControl",LikeOO.OOControlBase)

function M:onHandle(msg , data)
    if msg == 99999 then
        local ids=self.m_model:getForbiddenHeroIds()
        if table.nums(ids)>0 then
            self:updateMsg("update_preban_hero",self.m_model:getForbiddenHeroIds(),"Arena.ArenaRTA.RTAMain")
        end
        self:closeView()
    elseif msg == "select_hero" then
        self:clickHero(data)
    elseif msg == "help_btn" then
        self:openHelpPop()
    elseif msg == "check_send_btn" then
        self:clickHero(data)
    elseif msg == "tab_btn" then
        self.m_view.m_scroll_view_update_move_flag = false
        self.m_view.race_hero = self.m_model:switchHeroList(data.value.race)
        self.m_view:refreshUI()
        self.m_view.m_scroll_view_update_move_flag = true
    elseif msg=="confirm_btn" then
        if self.m_model.is_rta then
            self:updateMsg("update_preban_hero",self.m_model:getForbiddenHeroIds(),"Arena.ArenaRTA.RTAMain")
        else
            self:updateMsg("update_lock_hero",self.m_model:getForbiddenHeroIds(),"Formation")
        end
        self:closeView()
    end
end


--点击某个槽位
function M:clickSlot(data)
    local hero_id = data.hero_id;
    if self.m_model:isInSlot(hero_id) then
        --下阵
        self.m_model:removeHeroInSendSlot(hero_id)
        self.m_view:updateSendList()
    end
end


--点击某个英雄
function M:clickHero(hero_id)
    --local slotInfo = self.m_model:getSlotInfo(hero_id)
    --if slotInfo ~= nil then
    --    if slotInfo.finish == 1 then
    --        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("Pub_str_0036"), delay_close = 2})
    --        return;
    --    end
    --end
    if self.m_model:isInSlot(hero_id) then
        --下阵
        self.m_model:removeHeroInSendSlot(hero_id)
        self.m_view:updateSendList()
        self.m_view:refreshUI();
    else
        -- 1 表示成功了 0 表示失败了
        local result,race = self.m_model:addHeroInSendSlot(hero_id)
        if result == 1 then
            --更新所有槽位
            audio:SendEvtUI("UI_Hero_Click")
            self.m_view:updateSendList()
        elseif result == 2 then
            audio:SendEvtUI("Play_UI_Popup_3")
            local data = GlobalConfig.TYPE_HERO_RACE[race];
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gua_ji_xia_ke_str_007",Language:getTextByKey(data.name)), delay_close = 2})
        elseif result == 0 then
            audio:SendEvtUI("Play_UI_Popup_3")
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gua_ji_xia_ke_str_008"), delay_close = 2})
        elseif result == 4 then
            audio:SendEvtUI("Play_UI_Popup_3")
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gua_ji_xia_ke_str_003"), delay_close = 2})
        end
        self.m_view:refreshUI();
    end
end

function M:openHelpPop()
    local params = {
        title = Language:getTextByKey("tid#wish1"),
        content = Language:getTextByKey("tid#wish2"),
    }
    self:openView("Pops.CommonFiveLineHelpPop", params)
end


function M:setWishHeros()
    --遍历槽位
    local wish_list_data = {}
    local hero_data = UserDataManager.hero_data:getHerosData()
    for i, v in ipairs(self.m_model:getSendSlot()) do
        local oid
        local skinOid
        for kk, vv in pairs(hero_data) do
            if v.hero_id == vv.id then
                oid = vv.oid
                if vv.skin ~= nil then
                    skinOid = vv.oid
                    break
                end
            end
        end
        if skinOid then
            oid = skinOid
        else
            local hero_cfg = self.m_model:getHero(v.hero_id)
            if hero_cfg then
                oid = hero_cfg.oid
            else
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gua_ji_xia_ke_str_006"), delay_close = 2})
                return
            end
            
        end
        table.insert(wish_list_data, oid)
    end

    if #wish_list_data < 5 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gua_ji_xia_ke_str_006"), delay_close = 2})
        return
    end
    
    if self.m_model:hasSlotChanged() == true then
        local params =
        {
            team = wish_list_data,
            type = "view",
            index = 0,
            deployment = 1
        }
        local function callBack(response)
            self:updateMsg("update_hero_list", nil, "Options")
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gua_ji_xia_ke_str_009"), delay_close = 2})
            --if SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene then
            --    SceneManager.curScene:reset()
            --end
            self:closeView()
        end
        self.m_model:getNetData("hero_set_team", params, callBack)
    else
        self:closeView()
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M;
