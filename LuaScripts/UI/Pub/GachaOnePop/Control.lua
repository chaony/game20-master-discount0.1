local M = class("GachaOnePopControl",LikeOO.OOControlBase)

function M:onEnter()
  	self.m_guide_file_name = "UI.Pub.GachaOnePop.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then 
    	self:updateMsg("check_guide", nil, "Pub")
        self:updateMsg("show_reward", nil, "Pub")
        self:closeView()
    elseif msg == "card_btn" then
        if self.m_model.m_open then
            local card_hero_cfg = ConfigManager:getCfgByName("card_hero")
            local cfg = card_hero_cfg[self.m_model.m_card[2]]
            if cfg.hero_evo > 2 then
                self:openView("Pops.HeroLookInfo", {hero_id = cfg.hero_id, is_new = false})
            end
        else
            self.m_view:openCard()
            self.m_model.m_open = true
        end
    elseif msg == "oneKey_btn" then
    	self.m_view:openCard()
        self.m_model.m_open = true
    elseif msg == "gacha_btn" then
    	-- self:closeView()
        if self.m_model.m_pool_id == GlobalConfig.GACHA_SCORE_ID and self.m_view.gacha_times == 0 then --积分招募
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("Pub_str_0048"), delay_close = 2})
            return
        end
    	self:updateMsg("one_gacha_again", self.m_view.gacha_times, "Pub")
    elseif msg == "show_new" then
        if self.m_model.m_new_card[1] then
            local card_hero_cfg = ConfigManager:getCfgByName("card_hero")
            local cfg = card_hero_cfg[self.m_model.m_new_card[1]]
            self:openView("HeroInfo.HeroNewPop", {hero_id = cfg.hero_id, is_new = true})
        end
    elseif msg == "guide_check" then
        self.m_guide:checkGuide()
    end
end

return M;
