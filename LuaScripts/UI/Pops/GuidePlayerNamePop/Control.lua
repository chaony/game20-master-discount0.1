local M = class("GuidePlayerNameControl",LikeOO.OOControlBase)

function M:onEnter()
	self.m_guide_file_name = "UI.Pops.GuidePlayerNamePop.Guide"
end

function M:onHandle(msg , data)
	if msg == "ok_btn" then
		local text = self.m_view:getText()
		local curName, isPass = string.filterInvalidChars(text)
		if not isPass then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("title_text_0006"), delay_close = 2})
			return
		end
		if curName ~= "" then
			self:requestSetName(curName)
		else
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#Rename_01"), delay_close = 2})
		end
	elseif msg == "random_btn" then
		self.m_view:setInputText()
    end
end


function M:requestSetName(msg)
	local function nameCallback(response)
		UserDataManager:setIsFirstName(response.is_first_name)
		--GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("options_str_0007"), delay_close = 2})
		self.m_guide:doNextGuide()
		if self.m_model.m_callback then
			self.m_model.m_callback()
		end

		if SDKUtil.is_gmsdk or SDKUtil.is_oneSDK then
			local getServerData = UserDataManager.server_data:getServerData()
			local user_data = UserDataManager.user_data.user_status
			local params = {
				zoneid = getServerData.ZoneID or "",
				zonename = getServerData.ZoneName or "",
				roleid = user_data.uid or "",
				rolename = user_data.name or "",
				rolelevel = user_data.level or "",
				power = user_data.full_combat or "",
				vip = user_data.vip or "",
				partyid = user_data.guild_id or "",
				partyname = user_data.guild_name or "",
				chapter = UserDataManager:getCurStage() or "",
				serverId = getServerData.server or "",
				serverName = getServerData.server_name or "",
			}
			local json_string = Json.encode(params)
			SDKUtil:CreateNewRoleUpload(json_string)
		end
		StatisticsUtil:onCreateRoleToBi()
		self:closeView()
	end
	if (string.find(msg, "%%")) then
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("options_str_0037"), delay_close = 2})
		return
	end
	local params = {}
	params.name = msg
	self.m_model:getNetData("user_set_name", params, nameCallback)
end

return M;
