local M = class("MagicWeaponSelectMainControl",LikeOO.OOControlBase)

function M:onEnter()
	-- local season_data = UserDataManager.m_season_data or {}
	-- if season_data and next(season_data) and season_data.season then
	-- 	if season_data.season < 2 then
	-- 		self:openView("MagicWeapon")
	-- 		self:setOnceTimer(0.1, function ()
	-- 			self:updateMsg(99999)
	-- 		end)
	-- 	end
	-- end
end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		self:updateMsg("refresh_red_point", nil, "parent")
		self:closeView()
	elseif msg == "guide_btn" then --快速导航
		self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 81})
	elseif msg == "magic_weapon_btn" then
		if self.m_model:getShareLv() == true then
			self:openView("MagicWeapon")
		else
			GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("weapon_str_0006",self.m_model.weapon_lock_lv), delay_close = 2 })
		end
	elseif msg == "equip_awaken_btn" then
		--GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("new_str_0512"), delay_close = 2 })
		self:openView("EquipAwaken")
	elseif msg == "artifact_btn" then
		self:openView("EquipAwaken.ArtifactBookPop")
	elseif msg == "mystic_btn" then
		QuickOpenFuncUtil:openFunc(28)
		local mystic_inset = BtnOpenUtil:isBtnOpen(337)
		if mystic_inset then
		    local show_finger = UserDataManager.local_data:getUserDataByKey("mystic_magic_finger", 1)
		    if show_finger == 1 then
		        UserDataManager.local_data:setUserDataByKey("mystic_magic_finger", 0)
		    end
		end
	elseif msg == "refreshUI" then
		self.m_view:refreshUI()
	elseif msg == "destinyStar_btn" then
		self:openView("DestinyStar")
		--self:openView("DestinyStar.StarDetails")
	elseif msg == "heavenEarth_btn" then
		self:openView("HeavenEarth") --天地阁
	elseif msg == "red_point_update" then
		self.m_view:refreshUI()
	elseif msg == "echo_btn" then
		local is_echo_sp = UserDataManager.hero_data:checkEchoSP()
		if is_echo_sp == false then
			GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("echo_text_013"), delay_close = 2 })
			return
		end
		self:openView("HeroBag.HeroEcho",nil)
	end
end

return M