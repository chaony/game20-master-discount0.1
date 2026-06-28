local M = class("WishPopControl",LikeOO.OOControlBase)

function M:onEnter()
    --self.m_guide_file_name = "UI.Pub.WishPop.Guide"
end

function M:startGuide()
    M.super.startGuide(self)
    self:triggerGuide()
end

function M:triggerGuide()
    --local id = ConfigManager:getCommonValueById(303)
    --UserDataManager.guide_data:setAnyTeamGuide(id)
    --self.m_guide:checkGuide()
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:requestSaveChange()
    elseif msg == "help_btn" then
        local params = {}
        params.title = "tid#wish1"
        params.content = "tid#wish2"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "show_cards" then
    	self.m_model:setMartial(data)
    	--self.m_view:showCardsList(true)
        self.m_view:refreshList()
    	self.m_view:refreshCardsList()
    elseif msg == "close_cards_btn" then
    	--self.m_view:showCardsList(false)
    elseif msg == "click_card" then
    	if self.m_model:cardSelectChange(data) then
    		self.m_view:updateListScroll()
    		self.m_view:refreshCardsList(true)
    	end
    end
end

function M:requestSaveChange()
    local wish = self.m_model:getNewWishHero()
    local params = {}
    params.wish_list = wish
    local function wishCallback(response)
        -- Logger.log(response,"gachaCallback response=====")
        self:updateMsg("update_data", response, "Pub")
        self:closeView()
    end
    
    --local is_full = self.m_model:isFull()
    --if is_full then
        self.m_model:getNetData("gacha_set_hero_wish_list", params, wishCallback, nil, nil, GlobalConfig.POST)
    --else
    --    local params =
    --    {
    --        on_ok_call = function(msg)
    --            self.m_model:getNetData("gacha_set_hero_wish_list", params, wishCallback, nil, nil, GlobalConfig.POST)
    --        end,
    --        text = Language:getTextByKey("Pub_str_0015")
    --    }
    --    static_rootControl:openView("Pops.CommonPop", params)
    --end
   
end

return M;
