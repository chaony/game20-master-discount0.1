local M = class("CompareSwordMyRaceControl",LikeOO.OOControlBase)

function M:onEnter()

end

local __TAB_FORMATION_DATA = {{teamKey = "full_service_point_race", mode = GlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_POINT_RACE},
							  {teamKey = "full_service_promotion", mode = GlobalConfig.BATTLE_MODE.TEAM_SORT_FULL_SERVICE_PROMOTION} ,
}

function M:onHandle(msg , data)
	if msg == 99999 then
		self:closeView()
	elseif msg == "btn_Name" then

	elseif msg == "btn_formation" then --个人侠客
		--self:openView("CompareSwordWithWorld.CompareSwordMyRacePlayerInfo",{heros =data.players[1].heros ,teams=data.players[1].teams })
		local own_uid = UserDataManager.user_data:getUid()
		local other_uid = own_uid == data.players[2].uid and data.players[1].uid or data.players[2].uid
		self:openView("CompareSwordWithWorld.CompareSwordMyRacePlayerInfo",{uid = other_uid })
	elseif msg == "btn_editor" then --个人战报 天
		if self.m_model.racePhase == 2 then
			self:openView("CompareSwordWithWorld.CompareSwordFightReportPop",{open_type = 2,uid = data.players[2].uid})
		elseif self.m_model.racePhase == 3 then
			local own_uid = UserDataManager.user_data:getUid()
			local other_uid = own_uid == data.players[2].uid and data.players[1].uid or data.players[2].uid
			self:openView("CompareSwordWithWorld.CompareSwordFightReportPop",{open_type = 4,uid = other_uid,typ = self.m_model.raceType,round_stage = self.m_model.phase_day})
		end
	elseif msg == "btn_myReport" then --我的战报 天
		if self.m_model.racePhase == 2 then
			self:openView("CompareSwordWithWorld.CompareSwordFightReportPop",{open_type = 2,uid = self.m_model.role_id})
		elseif self.m_model.racePhase == 3 then
			self:openView("CompareSwordWithWorld.CompareSwordFightReportPop",{open_type = 4,uid = self.m_model.role_id,typ = self.m_model.raceType,round_stage = self.m_model.phase_day})
		end
	elseif msg =="editor_btn" then
		local race_typ = self.m_model.racePhase - 1
		self:openView("CompareSwordWithWorld.CompareSwordDefendTeam" , {teamKey = __TAB_FORMATION_DATA[race_typ].teamKey,
																		mode =  __TAB_FORMATION_DATA[race_typ].mode,
																		back_refresh = true,
																		race_typ = race_typ,
		})
	elseif msg == "help_btn" then
		self:openView("Pops.CommonHelpPop", { title = "compare_sword_race_text_020", content = self.m_model.racePhase == 2 and "tid#Full_service_tips2" or "tid#Full_service_tips3"})
	elseif msg == "refresh_red" then
		self.m_view:refreshRed()
	end
end

function M:destroy()

	M.super.destroy(self)
end


return M