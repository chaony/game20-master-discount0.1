------------------- WhaleSdkHelper

local M = {}
M.m_whale_sdk_helper = CS.WhaleSdkHelper.instance
M.open = false
function M:init()
	if self.open == true then
		self:sdkInit()
	end
end

function M:sdkInit()
	local channel = "testandroid"
	self.m_whale_sdk_helper:InitSDK("999080", GameVersionConfig.CLIENT_VERSION, channel)
end

--资源加载完毕
function M:OnGameLoadResource()
	if self.open == true then
		self.m_whale_sdk_helper:OnGameLoadResource()
	end
end

--配置加载完毕
function M:OnGameLoadConfig()
	if self.open == true then
		self.m_whale_sdk_helper:OnGameLoadConfig()
	end
end

--账号登录（必接） accountId :渠道返回给游戏的账号ID
function M:OnAccountLogin(accountId)
	if self.open == true then
		self.m_whale_sdk_helper:OnAccountLogin(accountId)
	end
end

--账号登出
function M:OnAccountLogout()
	if self.open == true then
		self.m_whale_sdk_helper:OnAccountLogout()
	end
end

--角色登录（必接） 角色id,名字，角色类型,等级,服务器id,服务器名称,性别
function M:OnRoleLogin(userData, serverData)
	if self.open == true then
		local  id, name, type, lv, serverId, serverName, gender
		id = userData.user_status.uid
		name = userData.user_status.name
		type = "玩家"
		lv = userData.user_status.level
		serverId = "S"..serverData:getServerId()
		serverName = "服务器:"..serverData:getServerId()
		gender = userData.user_status.gender or "m"
		self.m_whale_sdk_helper:OnRoleLogin(id, name, type, lv, serverId, serverName, gender)
	end
end

--角色升级
function M:OnRoleLevelUp(accountLv)
	if self.open == true then
		self.m_whale_sdk_helper:OnRoleLevelUp(accountLv)
	end
end

--角色退出
function M:OnRoleLogout()
	if self.open == true then
		self.m_whale_sdk_helper:OnRoleLogout()
	end
end

--暂停
function M:OnPause()
	if self.open == true then
		self.m_whale_sdk_helper:OnPause()
	end
end

--从新开始
function M:OnResume()
	if self.open == true then
		self.m_whale_sdk_helper:OnResume()
	end
end

--支付完成  currency:实际支付的国际标准货币代码,比如CNY(人民币)/USD(美元), money:金额， gameTradeNo:游戏订单ID
function M:OnPayFinish(currency, money, gameTradeNo)
	currency = currency or "CNY"
	if self.open == true then
		self.m_whale_sdk_helper:OnPayFinish(currency, money, gameTradeNo)
	end
end

--购买虚拟货币 数量，类型，总量，订单号
function M:OnVirtualCurrencyGainForPurchased(amount, type, total,tradeNo)
	if self.open == true then
		self.m_whale_sdk_helper:OnVirtualCurrencyGainForPurchased(amount, type, total, tradeNo)
	end
end

--私有功能码
function M:OnPrivateFunCodeUse(code, desc, type, batch)
	if self.open == true then
		self.m_whale_sdk_helper:OnPrivateFunCodeUse(code, desc, type, batch)
	end
end

--共有功能码
function M:OnPublicFunCodeUse(code, desc, type, batch)
	if self.open == true then
		self.m_whale_sdk_helper:OnPublicFunCodeUse(code, desc, type, batch)
	end
end

--进入关卡
function M:OnMissionBegin(stageId, stageName, Num, Power)
	if self.open == true then
		self.m_whale_sdk_helper:OnMissionBegin(stageId, stageName, Num, Power)
	end
end

--闯关成功
function M:OnMissionSucess(stageId, stageName, Num, Power)
	if self.open == true then
		self.m_whale_sdk_helper:OnMissionSucess(stageId, stageName, Num, Power)
	end
end

--闯关失败
function M:OnMissionFail(stageId, stageName, Num, Power)
	if self.open == true then
		self.m_whale_sdk_helper:OnMissionFail(stageId, stageName, Num, Power)
	end
end

return M
