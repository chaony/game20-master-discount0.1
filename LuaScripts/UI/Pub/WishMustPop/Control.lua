---@class WishMustPopControl:OOControlBase
local M = class("WishMustPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Pub.WishMustPop.Guide"
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
        if self.m_model:hasHeroInSlot() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("Pub_str_0042"), delay_close = 2})
            self:closeView()
            return
        end
        self:closeView()
    elseif msg == "select_hero" then
        self:clickHero(data)
    elseif msg == "check_send_btn" then
        self:clickSlot(data)
    elseif msg == "help_btn" then
        self:openHelpPop()
    elseif msg == "tab_btn" then
        if data.index > 4 then
            local open_flag,tips_str  = self.m_model:getOpenYinYang()
            if not open_flag then
                GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
                self.m_view:setToggleIsOn(self.m_model.selectType_index)
                return
            end
        end
        if self.m_model.selectType_index ~= data.index then
            self.m_view.race_hero = self.m_model:switchHeroList(data.value.race)
            self.m_view:refreshUI()
            self.m_model.selectType_index = data.index
        end
    elseif msg == "set_btn" then
        self:setBlessHero()
    end
end

function M:openHelpPop()
    local params = {
        title = Language:getTextByKey("tid#luky1"),
        content = Language:getTextByKey("tid#luky2"),
    }
    self:openView("Pops.CommonFiveLineHelpPop", params)
end

--点击某个槽位
function M:clickSlot(data)
    local hero_id = data.hero_id
    if self.m_model:isInSlot(hero_id) then
        --下阵
        self.m_model:removeHeroInSendSlot(hero_id)
        self.m_view:updateSendList()
    end
end

--点击某个英雄
function M:clickHero(hero_id)
    if hero_id ~= self.m_model.m_hero_id then
        local curCfg = ConfigManager:getCfgByName("hero_detail")[self.m_model.m_hero_id]
        local nextCfg = ConfigManager:getCfgByName("hero_detail")[hero_id]
        if curCfg ~= nil and nextCfg ~= nil then
            if curCfg.race <= 4 and nextCfg.race > 4 then
                local params = {
                    on_ok_call = function(msg)
                        self:setHero(hero_id)
                    end,
                    text = Language:getTextByKey("Pub_str_0040")
                }
                self:openView("Pops.CommonPop", params)
            else
                self:setHero(hero_id)
            end
        else
            self:setHero(hero_id)
        end
    end
end

function M:setHero(hero_id)
    self.m_model:addHeroInSendSlot(hero_id)
    self.m_model:updateMaxValue()
    self.m_view:updateSendList()
    self.m_view:refreshUI()
    self.m_model.m_hero_id = hero_id
    self.m_view:refreshZhuFu()
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

return M