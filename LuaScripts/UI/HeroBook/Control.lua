local M = class("HeroBookControl",LikeOO.OOControlBase)

function M:onEnter()
	
end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		self:closeView()
		self:updateMsg("refresh_tj_redPoint", nil, "HeroBag")
	elseif msg == "select_hero" then
		self:openView("HeroBookShow", {h_id = data,type = 1})
	elseif msg == "refresh_ui" then
		self.m_view:refreshUI()	
	elseif msg == "check_tag" then
		if self.m_model.m_sel_tab_index ~= data then
			self.m_model.m_sel_tab_index = data
			self.m_view:switchRacePanel(self.m_model.m_sel_tab_index)
		end
	elseif msg == "get_reward" then
		self:getKillReward()
	elseif self.m_model:clickHero(msg) then
		local str_btn = string.sub(msg, 5,7)
		local id = tonumber(str_btn)
		self:openView("Pops.HeroLookInfo", {hero_id = id, is_new = false}) -- 1 武林谱 
	elseif msg == "fly" then
		self.m_view:itemFlyAction(data)
	elseif msg == "race_mask_1" or 
			msg == "race_mask_2" or 
			msg == "race_mask_3" or 
			msg == "race_mask_4" or 
			msg == "race_mask_5" or 
			msg == "race_mask_6"   then	
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0576"), delay_close = 2})
	elseif msg == "refreshRedPint" then
		self.m_view:refreshRedPoint()
		self.m_view:refreshBottomRedPoint()
	elseif msg == "role_help_btn" then
		local params = {}
		params.title = "hero_role_upgrade_text15"
		params.content = "tid#AttTips_1"
		self:openView("Pops.CommonHelpPop", params)
	end
end


--领取奖励
function M:getKillReward()
    local function callfunc(response)
        RewardUtil:rewardTipsByData(response.reward)
		self.m_model:setAllHeroStatus()
        UserDataManager.hero_data:updateOneHeroCollect(self.m_model.m_select_book_id)
        self.m_view:refreshUI()
		self:updateMsg("common_refresh",nil, "HeroBag")
    end
    local data = {
        hero_id = self.m_model.m_select_book_id
    }
    self.m_model:getNetData("hero_collect_receive", data, callfunc)
end

return M