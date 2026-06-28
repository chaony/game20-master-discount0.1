local M = class("RegisterPopControl",LikeOO.OOControlBase)

function M:onEnter()
 
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "sign_up_btn" then	-- 注册
    	self:register()
		self:updateMsg("refresh_serverInfo", nil, "parent")
    elseif msg == "cancle_btn" then -- 取消
    	self:closeView()
    end
end

function M:register()
	local account, password1, password2 = self.m_view:getNameAndPassword()

	if account ~= "" and password1 ~= "" and password2 ~= "" then
		if password1 == password2 then
			local params = {passwd=tostring(password1), account=tostring(account)}
			SDKUtil:appendPlatformParam(params)
			local netCallback = function(response)
				U3DUtil:PlayerPrefs_SetString("username", account)
				U3DUtil:PlayerPrefs_SetString("password", password1)

        		UserDataManager.client_data.user_account = tostring(account)
        		Logger.log(account,"account =========")
       			--注册完之后直接进游戏
				UserDataManager.client_data:setSk(response.sk)
				UserDataManager.client_data:setCryptoSwitch(response.crypto_switch)
				UserDataManager.server_data:setServerData(response.current_server)
				UserDataManager.server_data:setUserSid(response.sid)
				UserDataManager.client_data.is_new_user = true
				
				self:closeView()
				self:openView("Login.Update")
		    end
		    self.m_model:getNetData("register", params, netCallback)
			StatisticsUtil:doPoint("gameLoginSuccess")
		else
			Logger.log("请确认你的密码是否一致")
		end
	else
		Logger.log("缺少用户名或密码")
	end
end

return M
	