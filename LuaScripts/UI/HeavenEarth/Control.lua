local M = class("HeavenEarthControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		--self:updateMsg("refresh_red_point", nil, "Main")
		self:closeView()
	--elseif msg == "guide_btn" then --快速导航
	--	self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 81})
	elseif  msg == "help_btn" then
		local btn_data = BtnOpenUtil:getBtnCfg(338)
		self:openView("Pops.CommonHelpPop", {title = Language:getTextByKey(btn_data.name) , content = "tid#normal_array_tips"})
	elseif msg == "click_cell" then
		self.m_team = data
		self.m_view:refreshRight(self.m_team, true)
	elseif msg == "set_cell" then
		self.m_team = data
	elseif msg == "upgrade_btn" then
		self:requestUpgrade()
	elseif msg == "hero_cell_1" then
		self:clickHero(1)
	elseif msg == "hero_cell_2" then
		self:clickHero(2)
	elseif msg == "hero_cell_3" then
		self:clickHero(3)
	elseif msg == "hero_cell_4" then
		self:clickHero(4)
	elseif msg == "hero_cell_5" then
		self:clickHero(5)
	elseif msg == "hero_cell_6" then
		self:clickHero(6)
	end
end

function M:clickHero(index)
	local cond = self.m_team.cond_array[index]
	if cond == nil then
		return
	end
	if cond[1] == 1 then
		if cond[3] == 1 then
			GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("heavenEarth_text_006"), delay_close = 2})
		else
			GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("heavenEarth_text_007"), delay_close = 2})
		end
	elseif cond[1] == 2 then
		local str = Language:getTextByKey("heavenEarth_zy_text_00" .. cond[3])
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("heavenEarth_text_008",str), delay_close = 2})
	elseif cond[1] == 3 then
		self:openView("Pops.HeroLookInfo", {hero_id = cond[2], is_new = false})
	elseif cond[1] == 4 then
		local sp_type = cond[2]
		local sp_cfg = GlobalConfig.SP_TYPE_SETTING[sp_type]
		local str = Language:getTextByKey(sp_cfg.name)
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("heavenEarth_text_009",str), delay_close = 2})
	end
end

--升级
function M:requestUpgrade()
	local function netCallback(response)
		if response then
			self:openView("MagicWeapon.MagicWeaponLvUpPop")
			self.m_model:updateUpgrade(response.normal_team_id, response.lv)
			self.m_view:refreshRight(self.m_team)
			self.m_view:refreshSelectTeamLv(response.normal_team_id)
			--self:updateMsg("refresh_gacha_red_point", nil, "Hotel") --刷新抽卡入口红点
		end
	end
	local params = {normal_team_id = self.m_team.id}
	self.m_model:getNetData("hero_normal_array_levelup", params, netCallback)
end

return M