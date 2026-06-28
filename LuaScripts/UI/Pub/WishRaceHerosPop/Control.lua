local M = class("WishRaceHerosPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Pub.WishRaceHerosPop.Guide"
end

function M:startGuide()
    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(27, 2)
    if have_guide then
        if self.m_guide then
            self.m_guide:start()
        end
    end
end


function M:onHandle(msg , data)
    if msg == 99999 then
        --发送心愿单数据
        self:setWishHeros();
    elseif msg == "select_hero" then
        self:clickHero(data)
    elseif msg == "help_btn" then
        self:openHelpPop()
    elseif msg == "check_send_btn" then
        self:clickHero(data)
    elseif msg == "tab_btn" then
        self.m_view.race_hero = self.m_model:switchHeroList(data.value.race)
        self.m_view:refreshUI()
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
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0927",Language:getTextByKey(data.name)), delay_close = 2})
        elseif result == 0 then
            audio:SendEvtUI("Play_UI_Popup_3")
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0925"), delay_close = 2})
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
    for i, v in ipairs(self.m_model:getSendSlot()) do
        table.insert(wish_list_data, v.hero_id)
    end
    local params =
    {
        wish_list = wish_list_data,
    }
    local function callBack(response)
        self:updateMsg("update_hero_wish_list", response, "Pub")
        self:closeView()
    end
    self.m_model:getNetData("gacha_set_hero_wish_list", params, callBack, nil, nil, GlobalConfig.POST)
end


function M:destroy()
    M.super.destroy(self)
end

return M;
