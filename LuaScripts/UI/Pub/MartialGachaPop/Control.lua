local M = class("MartialGachaPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "card_btn_1" then
    	self:openCard(1)
    elseif msg == "card_btn_2" then
    	self:openCard(2)
    elseif msg == "card_btn_3" then
    	self:openCard(3)
    elseif msg == "card_btn_4" then
    	self:openCard(4)
    elseif msg == "show_new" then
        if self.m_model.m_new_card[1] then
            local card_hero_cfg = ConfigManager:getCfgByName("card_hero")
            local cfg = card_hero_cfg[self.m_model.m_new_card[1]]
            self:openView("HeroInfo.HeroNewPop", {hero_id = cfg.hero_id, is_new = true})
        end
    end
end

function M:openCard(index)
	if self.m_model.m_card then
		local card_hero_cfg = ConfigManager:getCfgByName("card_hero")
		local cfg = card_hero_cfg[self.m_model.m_card[2]]
		if cfg.hero_evo > 2 then
			self:openView("Pops.HeroLookInfo", {hero_id = cfg.hero_id, is_new = false})
		end
	else
		self.m_model:setGachaIndex(index)
		self:requestGacha(index)
	end
end

function M:requestGacha(data)
	local params = {}
	params.item_index = data - 1
	params.item_id = self.m_model.m_item_id
	params.item_num = 1
	local function gachaCallback(response)
		self.m_model:setGachaData(response)
		self.m_view:refreshUI()
		self:updateMsg("update_data",nil,"Pub")
	end
	self.m_model:getNetData("item_use_item", params, gachaCallback)
end

return M;
