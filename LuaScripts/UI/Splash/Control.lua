local M = class("SplashControl",LikeOO.OOControlBase)

--- 页面不可返回
M.m_needBack = false

function M:onEnter()

	if SDKUtil.sdk_params and SDKUtil.sdk_params.is_open_user_agreement then

		SDKUtil:agreeUserAgreement()
		self:splashStart()

		-- local user_agreement_flag = UserDataManager.local_data:getLocalDataByKey("user_agreement_flag", 0)
		-- if user_agreement_flag == 0 then
		-- 	self:updateMsg("user_agreement")
		-- else
		-- 	SDKUtil:agreeUserAgreement()
		-- 	self:splashStart()
		-- end
	else
		self:splashStart()
	end
end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		self:updateMsg("initUrl",nil,"parent")
		self:closeView()
		--LikeOO.OOControlBase:openView("Login")
	elseif msg == "vedio" then
		self:openView("Pops.VedioPlayerPop", {callback = function()
			EventDispatcher:registerTimeEvent("splash_open_login", function()
				self.m_view:healthNotice()
			end, 0.2, 0.2)
		end, vedio_name = data.vedio_name or "tencent_logo.mp4", no_close_btn = true})
	elseif msg == "byte_image" then
		EventDispatcher:registerTimeEvent("splash_open_login", function()
			self.m_view:healthNotice()
		end, 1, 1)
	elseif msg == "user_agreement" then
		local params =
		{
			on_ok_call = function(msg)
				SDKUtil:agreeUserAgreement()
				self:splashStart()
			end,
			on_cancel_call = function(msg)
				GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0628"), delay_close = 2})
				self:updateMsg("user_agreement")
			end,
		}
		self:openView("Pops.UserAgreementPop", params, nil, true)
	end
end

function M:splashStart()
	if GameMain.enter_main_flag ~= true and GameMain.restart_flag == true then
		self:updateMsg(99999)
	else
		if SDKUtil.is_tencent then
			EventDispatcher:registerTimeEvent("splash_open_login", function()
				self:updateMsg("vedio", {vedio_name = "tencent_logo.mp4"})
			end, 1, 1)
		--elseif SDKUtil.is_gmsdk then
		--	self:openView("Pops.VedioPlayerPop", {callback = function()
		--		EventDispatcher:registerTimeEvent("splash_open_login1", function()
		--			--self:updateMsg("vedio", {vedio_name = "byte_dance_logo.mp4"})
		--			self.m_view:byteNotice()
		--			self:updateMsg("byte_image")
		--		end, 0.2, 0.2)
		--	end, vedio_name = "kingsoft_logo.mp4", no_close_btn = true})
		else
			EventDispatcher:registerTimeEvent("splash_open_login", function()
				self.m_view:healthNotice()
			end, 1, 1)
		end
	end
end

function M:destroy()
    M.super.destroy(self)
end

return M
	