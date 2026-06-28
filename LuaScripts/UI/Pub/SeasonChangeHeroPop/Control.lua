local M = class("SeasonChangeHeroPopControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "select_hero" then
        self:clickHero(data)
    elseif msg == "check_btn" then
        self.m_model:setCheckStatus()
        self.m_view.race_hero = self.m_model:switchHeroList(self.m_model.m_cur_race)
        self.m_view:refreshUI()
    elseif msg == "use_btn" then
        if table.nums(self.m_model.m_cur_select_hero_tab) < (self.m_model.m_normal_cfg_num + self.m_model.m_core_cfg_num) then
            GameUtil:lookInfoTips(self.m_control, {msg = "season_change_hero_text_007", delay_close = 2})
        else
            self:requestChangeHero()
        end
    elseif msg == "help_btn" then
        self:openHelpPop()
    elseif msg == "tab_btn" then
        if self.m_model.selectType_index ~= data.index then
            self.m_view.race_hero = self.m_model:switchHeroList(data.value.race)
            self.m_view:refreshUI()
            self.m_model.selectType_index = data.index
        end
    end
end


function M:openHelpPop()
    local params = {
        title = Language:getTextByKey("tid#luky1"),
        content = Language:getTextByKey("tid#luky2"),
    }
    self:openView("Pops.CommonFiveLineHelpPop", params)
end

function M:requestChangeHero()
    local function netCallback(response)
        if response.reward and response.reward.emoji and table.nums(response.reward.emoji) > 0 then
            GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_1042"), delay_close = 2})
        else
            local extra_params = {}
            extra_params.season_change_hero = true
            RewardUtil:rewardTipsByData(response.reward, nil, nil, extra_params)
        end
        self:closeView()
    end
    local params = {item_id = self.m_model.m_show_data.data_id, item_num = item_num or 1}
    params.material = table.keys(self.m_model.m_cur_select_hero_tab)
    self.m_model:getNetData("item_use_item", params, netCallback)
end

--点击某个英雄
function M:clickHero(hero_id)
    local tips = self.m_model:updateSelectHeroTab(hero_id)
    if tips ~= "" then
        GameUtil:lookInfoTips(self.m_control, {msg = tips, delay_close = 2})
    else
        self.m_view:refreshUI(true)
    end
end

function M:setHero(hero_id)
    self.m_model:addHeroInSendSlot(hero_id);
    self.m_model:updateMaxValue();
    self.m_view:updateSendList()
    self.m_view:refreshUI();
    self.m_view:refreshChangeHero();
    self.m_model.m_hero_id = hero_id;
end


function M:setBlessHero()
    local params = 
    {
        hero_id = self.m_model.m_hero_id,
    }
    local function callBack(response)
        self:updateMsg("update_bless_hero", response, "Pub")
        self:closeView()
    end
    self.m_model:getNetData("gacha_set_bless_hero", params, callBack, nil, nil, GlobalConfig.POST)
end



function M:destroy()
    M.super.destroy(self)
end

return M;
