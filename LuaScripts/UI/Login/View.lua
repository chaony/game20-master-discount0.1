---@class LoginView : OOSceneBase
local M = class("LoginView", LikeOO.OOSceneBase)

M.m_uiName = "Login/Login"
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("select_server_text", "select_server_tex")
	self:setTextByLanKey("Loading_Sence_Text", "loading_sence_tex")
	self:setText("res_version_text",Language:getTextByKey("new_str_0001") .. GameVersionConfig.GAME_RESOURCES_VERION)
	self:findText("start_text").text = Language:getTextByKey("new_str_0003")
	self:findText("login_text").text = Language:getTextByKey("new_str_0365")
	local str = string.gsub(Language:getTextByKey("tid#mustdo1"), "\\n", "\n")
	self:setText("mustdo_text", str)
	self:setTextByLanKey("notice_btn_text", "notice_str_0001")
	self:setTextByLanKey("vedio_btn_text", "new_str_0469")
	self:setTextByLanKey("account_text", "new_str_1102")
	self:setTextByLanKey("repair_text", "new_str_1021") --修复
	if SDKUtil.is_tencent then
		self:setTextByLanKey("agreement_text", "new_str_0517")
	elseif SDKUtil.is_gmsdk then
		if self.m_control.application_Id and self.m_control.application_Id == "com.hermes.wl.jh" then
			self:setTextByLanKey("agreement_text", "new_str_1096")
		else
			self:setTextByLanKey("agreement_text", "new_str_0963")
		end
	end
	self:setTextByLanKey("customer_btn_text", "options_str_0033") --客服
	self.m_sequence = Tweening.DOTween.Sequence()
	--self.m_sequence:Append(DOTweenModuleUI.DOFade(self:findText("start_text"), 0.2, 2))
	self.m_sequence:Append(DOTweenModuleUI.DOFade(self:findImage("start_img"), 0.2, 2))
	--self.m_sequence:Append(DOTweenModuleUI.DOFade(self:findText("start_text"), 1, 2))
	self.m_sequence:Append(DOTweenModuleUI.DOFade(self:findImage("start_img"), 1, 2))
	self.m_sequence:SetLoops(-1)
	self:refreshUI()
	--self:retainVisibleView()
	self:startBtnVisible(false)
	self:setParticleRenderOrder(self.content_node)
	self:setObjectVisible("url_list_btn",  GameVersionConfig.OPEN_SELECT_SERVER == true)
	self:setObjectVisible("penguin_login_node", false)
	self:setObjectVisible("logined_node", false)
	self:setObjectVisible("vedio_btn", false)
	self:setObjectVisible("agreement_text", SDKUtil.is_tencent)
	self:setObjectVisible("agreement_btn", SDKUtil.is_tencent)
	self:setObjectVisible("select_server_btn", true)
	self:setObjectVisible("account_btn", false)
	self:setObjectVisible("logOut_btn", false)
	self:setObjectVisible("Loading_Sence_Text", false)
	self.vedio = self:findGameObject("vedio")
	local video_control = self.vedio:GetComponent("VideoControl")
	local full_path,file_type = io.fileFullPath(self.m_model.m_vedio_path)
	if full_path then
		video_control:VideoPlay(file_type,self.m_model.m_vedio_path,true,0);
	end

	--local zhulin = self:findRectTransform("Zhulin")
	--local bg_scale_w = self.m_view_width/GlobalConfig.BG_UI_DESIGN_WIDTH
	--local bg_scale_h = self.m_view_height/GlobalConfig.BG_UI_DESIGN_HEIGHT
	--local new_rate = math.max(bg_scale_w , bg_scale_h)
	--UIUtil.setLocalScale(zhulin, new_rate, new_rate)
	if SDKUtil.is_gmsdk then -- 字节的sdk
		self:findText("client_version_text").text = Language:getTextByKey("new_str_0002") .. GameVersionConfig.BYTE_DANCE_SERVER_VERSION
		self:setObjectVisible("customer_btn", false)
		local application_Id = SDKUtil.sdk_params.applicationId
		if application_Id == "com.hermes.wl" or SDKUtil.sdk_params.app == 2 then
			self:setObjectVisible("customer_btn", true)
			self:setObjectVisible("account_btn", true)
		elseif application_Id ~= "com.hermes.wl" then
			self:setObjectVisible("agreement_text", true)
			self:setObjectVisible("agreement_btn", true)
		end
	else
		self:refreshClientService()
		self:findText("client_version_text").text = Language:getTextByKey("new_str_0002") .. GameVersionConfig.CLIENT_VERSION
	end

	if SDKUtil.is_oneSDK == true and SDKUtil.sdkChannel ~= "yyh" then
		self:setObjectVisible("account_btn", false)
	else
		self:setObjectVisible("account_btn", true)
	end
	--CS.LoginCamera.Inst:SetLayer("scene");

	self:updateMsg("initUrl",nil,"parent")
end

function M:refreshChannelInfo()
	if SDKUtil.sdk_params.fchannel == "yyh" then
		self:setTextByLanKey("Text (3)", "new_str_1146")
		self:setTextByLanKey("Text (4)", "new_str_1148")
	else
		self:setTextByLanKey("Text (3)", "new_str_1145")
		if SDKUtil.sdk_params.fchannel == "4399" or SDKUtil.sdk_params.fchannel == "xiaomi" then
			self:setTextByLanKey("Text (4)", "new_str_1152")
		else
			self:setTextByLanKey("Text (4)", "new_str_1147")
		end
	end

end

function M:refreshClientService()

	--Logger.log("is onsdk " .. (SDKUtil.is_oneSDK and "1" or "0") .. "  " .. SDKUtil.sdk_params.isCS)
	if SDKUtil.is_oneSDK == true then
		if SDKUtil.sdk_params.isCS == "1"
				or SDKUtil.sdk_params.isCS == "2"
				or SDKUtil.sdk_params.isCS == "3"
				or SDKUtil.sdk_params.isCS == "4" then
			self:setObjectVisible("customer_btn", true)
		else
			self:setObjectVisible("customer_btn", false)
		end
	end
end

function M:refreshUI(need_player_back_check)
	local server_data = UserDataManager.server_data:getServerData()
	if server_data then
		self:setText("select_server_text",server_data.server_name)
	end
	self:setObjectVisible("Loading_Sence_Text", false)
	self:freshAgreement()
	if need_player_back_check == true then
		self.m_control:checkPlayerBackChoseServer()
	end
	local active_spine_id =ConfigManager:getCommonValueById(646,0)
	--local new_bg_img = self:findImage("new_year_bg_img")
	--local new_year_sk = self:findGameObject("new_year_sk")
	--local xiaohuanxiong_img = self:findImage("xiaohuanxiong_img")
	--local sanguo_img = self:findGameObject("sanguo_img")
	--local zhanzhao_img = self:findGameObject("zhanzhao_img")
	--local libai_img = self:findGameObject("libai_img")
	--local diwu_img = self:findGameObject("diwu_img")
	--local rabbit_year_img = self:findGameObject("rabbit_year_img")
	local zhouyu_xiaoqiao_img = self:findGameObject("zhouyu_xiaoqiao_img")
	--local qunying_img = self:findGameObject("qunying_img")
	--if active_spine_id == 1 and not IsNull(new_bg_img) and not IsNull(new_year_sk) then --新年
	--	GameUtil:updateResourcesImg(new_bg_img, "Texture/a_denglu_bg02")
	--	GameUtil:updateSpineLoadSet(new_year_sk, "RoleSpine/xinnianzhujiemian_SkeletonData", "idle", 0, true)
	--	self:setSpineVisible(active_spine_id)
	--	local zhulin = self:findRectTransform("new_year_spin_obj")
	--	local bg_scale_w = self.m_view_width/GlobalConfig.BG_UI_DESIGN_WIDTH
	--	local bg_scale_h = self.m_view_height/GlobalConfig.BG_UI_DESIGN_HEIGHT
	--	local new_rate = math.max(bg_scale_w , bg_scale_h)
	--	UIUtil.setLocalScale(zhulin, new_rate, new_rate)
	--elseif active_spine_id == 2 and not IsNull(xiaohuanxiong_img) then -- 小浣熊
	--	self:setSpineVisible(active_spine_id)
	--elseif active_spine_id == 3 and not IsNull(sanguo_img) then -- 三国
	--	self:setSpineVisible(active_spine_id)
	--elseif active_spine_id == 4 and not IsNull(zhanzhao_img) then -- 展昭
	--	self:setSpineVisible(active_spine_id)
	--elseif active_spine_id == 5 and not IsNull(libai_img) then -- 李白
	--	self:setSpineVisible(active_spine_id)
	--elseif active_spine_id == 6 and not IsNull(diwu_img) then -- 狄仁杰 武则天
	--	self:setSpineVisible(active_spine_id)
	--elseif active_spine_id == 7 and not IsNull(rabbit_year_img) then -- 关羽
	--if active_spine_id == 7 and not IsNull(rabbit_year_img) then -- 关羽
	--	self:setSpineVisible(active_spine_id)
	--else
	if active_spine_id == 8 and not IsNull(zhouyu_xiaoqiao_img) then -- 狄仁杰 武则天
		self:setSpineVisible(active_spine_id)
	--elseif active_spine_id == 9 and not IsNull(qunying_img) then -- 狄仁杰 武则天
	--	self:setSpineVisible(active_spine_id)
	else
		--self:setObjectVisible("sanguo_img", false)
		--self:setObjectVisible("new_year_bg_img", false)
		--self:setObjectVisible("xiaohuanxiong_img", false)
		--self:setObjectVisible("zhanzhao_img", false)
		--self:setObjectVisible("libai_img",false)
		--self:setObjectVisible("diwu_img",false)
		--self:setObjectVisible("rabbit_year_img",false)
		self:setObjectVisible("zhouyu_xiaoqiao_img",true)
	end
end

function M:setSpineVisible(spine_id)
	self:setObjectVisible("zhouyu_xiaoqiao_img", spine_id == 8)
	--self:setObjectVisible("qunying_img", spine_id == 9)
end

function M:sdkVisible(flag)
	flag = flag or false
	--self:setObjectVisible("account_btn", flag)
	--self:setObjectVisible("select_server_btn", flag)
	if flag then
		self:setObjectVisible("url_list_btn",  GameVersionConfig.OPEN_SELECT_SERVER == true)
	else
		self:setObjectVisible("url_list_btn", false)
	end
end

function M:startBtnVisible(flag)
	self:setObjectVisible("start_btn", flag)
	self:setObjectVisible("sdk_login_btn", not flag)
end

function M:enableStartBtn(show)
	-- local obj = self:findGameObject("start_btn")
	-- obj.enabled = show
	
	-- local obj2 = self:findGameObject("sdk_login_btn")
	-- obj2.enabled = show
	-- self:getObject
	self:setObjectVisible("start_btn", show)
	-- self:setObjectVisible("sdk_login_btn", show)
	
end

function M:tencentLoginBtnVisible(flag)
	self:setObjectVisible("penguin_login_node", flag)
end

function M:LoginedBtnsVisible(flag)
	self:setObjectVisible("logined_node", flag)
end

-- 腾讯协议勾选
function M:freshAgreement()
	self:setObjectVisible("agreement_type_img", self.m_model.tencent_agreement ~= 0)
end

function M:playStartBtnEffect()
	self:setObjectVisible("UI_Login_AnNiu_001", false)
	self:setObjectVisible("UI_Login_AnNiu_001", true)
end

function M:destroy()
	self.m_sequence:Kill()
    M.super.destroy(self)
end

return M