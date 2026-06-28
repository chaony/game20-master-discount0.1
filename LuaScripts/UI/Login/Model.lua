local M = class("LoginModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_user_name = U3DUtil:PlayerPrefs_GetString("username")
	self.m_user_password = U3DUtil:PlayerPrefs_GetString("password")
	self.auto_register = false
	if self.m_user_name == nil or self.m_user_name == "" then
		math.randomseed(os.time())
		self.m_user_name = "acc" .. math.random(100,9999999)
		self.m_user_password = 1
		self.auto_register = true
	end
	self.m_sdk_login_state = 0
	self.m_sdk_init_success = false
	--self.tencent_agreement = U3DUtil:PlayerPrefs_GetInt("tencent_agreement",1)
	self.tencent_agreement = UserDataManager.local_data:getLocalDataByKey("gsdk_agreement",0)
	local vedio_name = self.m_params.vedio_name or  "login_background.mp4"
	self.m_vedio_path = "mp4/" .. vedio_name
end

function M:setSdkAccount(params)


	Logger.log(params,"setSdkAccount")
	--Logger.log("params.is_CS " .. params.is_CS)
    SDKUtil.sdk_params.android_id = params.android_id or ""
    SDKUtil.sdk_params.device_id = params.device_id or ""
	SDKUtil.sdk_params.oaid = params.oa_id or ""
	SDKUtil.sdk_params.gaid  = params.android_id or ""
	SDKUtil.sdk_params.isCS = params.is_CS
	SDKUtil.sdk_params.uid = params.uid
	--Logger.log("sdk_params.isCS " .. SDKUtil.sdk_params.isCS)
	SDKUtil.sdkChannel = params.sdkChannel or ""
	SDKUtil.configChannel = params.configChannel

	if params.platform then
		SDKUtil.sdk_params.platform = params.platform
	end


	

	self.m_sdk_login = true
	self.m_session = params.session
	self.m_uid = params.uid
	self.m_nickName = params.nickName
	self.m_msdk_os = params.msdkOS
	self.m_reg_channel = params.regChannelDis

	self.subSdkChannel = params.subSdkChannel
	
	self.m_platform = params.platform or SDKUtil.sdk_params.platform
	self.m_channel = params.channel
	self.m_config_channel = params.configChannel
	self.m_sdkChannel = params.sdkChannel
	-- self.m_openid = params.openid
	self.m_token = params.token
	self.m_userid = params.userid
	UserDataManager.client_data:setSdkToken(self.m_token)

	SDKUtil:sendBitrack(SDKUtil.BI_SdkLogined)

end

return M
