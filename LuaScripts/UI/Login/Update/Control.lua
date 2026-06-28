---@class UpdateControl : OOControlBase
---@field m_model UpdateModel
---@field m_view UpdateView
local M = class("UpdateControl",LikeOO.OOControlBase)

--- 页面不可返回
M.m_needBack = false
M.m_isRestart = false
M.m_network_tips = true
M.m_link_count = 0
M.m_url_change_count = 0

function M:onEnter()
	self.m_view:setObjectVisible("progress_slider", false)
	self.m_view:setTextByLanKey("progress_text", "new_str_0949")
  	self:getHotUpateData()

	SDKUtil:sendBitrack(SDKUtil.BI_UpdateBegin)
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
		SDKUtil:sendBitrack(SDKUtil.BI_UpdateEnd)
    end
end

function M:responseCode(msg, data)
	if msg == "isDone" then -- 资源下载完成
		Logger.log(data, "isDone  ==== ")
		self.m_link_count = 0
		if data == 0 then -- 下载完成 去解压
			self.m_url_change_count = 0
			self.m_view:decompressFile()
		elseif data == 1 then -- MD5校验失败 从新下载
			if self:downResUrlChanged() then
				self:downloadRes()
			end
		end
	elseif msg == "code" then
		Logger.log(data, "Update http code ==== ")
		if data ~= 200 and data ~= 302 then
			if self.m_link_count > 3 then
				self.m_link_count = 0
				if self:downResUrlChanged() == false then
					return
				end
			else
				self.m_link_count = self.m_link_count + 1
			end
			self:downloadRes()
		end
	elseif msg == "UncompressCode" then
		if data == 0 then -- 解压完成
			self.m_model:downloadNumber()
			self:downloadRes()
		else
			local LuaFileHelper = CS.wt.framework.LuaFileHelper.Inst
			LuaFileHelper:DeleteDir("Bundles", true)
			LuaFileHelper:DeleteDir("LuaScripts", true)
			LuaFileHelper:DeleteDir("mp4", true)
			LuaFileHelper:DeleteDir("Audio", true)
			LuaFileHelper:DeleteDir("tempZip", true)
			GameVersionConfig = LuaReload("Start.GameVersionConfig")
			U3DUtil:PlayerPrefs_SetString("game_resources_verion",tostring(GameVersionConfig.GAME_RESOURCES_VERION))
			U3DUtil:PlayerPrefs_SetString("client_verion",tostring(GameVersionConfig.CLIENT_VERSION))
			U3DUtil:PlayerPrefs_Save()
			local params =
			{
				on_ok_call = function(msg)
					GameMain.download_game_resources = true
					GameMain.reStart()
				end,
				no_close_btn = true,
				text = Language:getTextByKey("update_str_0009")
			}
			static_rootControl:openView("Pops.CommonPop", params,"UncompressCodeErrorPop")
		end
	end
end

-- 变更资源备用地址
function M:downResUrlChanged()
	self.m_url_change_count = self.m_url_change_count + 1
	if self.m_url_change_count >= #self.m_model.res_response.url then
		 Logger.logAlways(self.m_url_change_count,"url all changed === ")
		self.m_url_change_count = 0
	end
	self.m_model:downResUrlChanged()
	return true
end

-- 请求热更信息
function M:getHotUpateData()
	-- app 默认是 Android = 1，ios = 2
	local params = {app = SDKUtil.sdk_params.app or 1} 
	local function netCallback(response)
		if response then
			self.m_model:setResponse(response)
			if SDKUtil.is_gmsdk then -- 通过字节服务器列表中的版本号取获取json配置，找到对用的资源下载包
				local server_data = UserDataManager.server_data:getServerData()
				local extra_info = server_data and server_data.extra_info
				if extra_info and extra_info ~= "" then -- {"android_rv":"t1.0.158","ios_rv":"t1.0.158"}
					self:getResourceJsonData(extra_info)
				else
					self:downloadRes()
				end 
			else
				self:downloadRes()
			end
			if response.config then
				UserDataManager.local_data:setLocalDataByKey("version_count", response.config.version_count or 0)
			end
		else
			self:getHotUpateData()
		end
	end
	self.m_model:getNetData("check_version", params, netCallback, nil, true)
end

-- 对比版本号
function M:compareResourceVersion(ver1, ver2)
	local ver1_tab = string.split(ver1, ".")
	local first_version1 = tonumber(string.sub(ver1_tab[1], 2)) or 0
	local second_version1 = tonumber(ver1_tab[2]) or 0
	local third_version1 = tonumber(ver1_tab[3]) or 0
	local ver2_tab = string.split(ver2, ".")
	local first_version2 = tonumber(string.sub(ver2_tab[1], 2)) or 0
	local second_version2 = tonumber(ver2_tab[2]) or 0
	local third_version2 = tonumber(ver2_tab[3]) or 0
	if first_version1 == first_version2 then
		if second_version1 == second_version2 then
			return third_version1 >= third_version2
		else
			return second_version1 > second_version2
		end
	else
		return first_version1 > first_version2
	end
end

function M:getResourceVersionData(res_data)
	if res_data == nil then
		return nil
	end
	local cur_version = GameVersionConfig.GAME_RESOURCES_VERION
	local res_version_data = res_data[cur_version]
	if res_version_data == nil then -- 未找到对应的版本号资源的处理
		local ver_tab = {}
		for version,data in pairs(res_data) do
			local tab = string.split(version, ".")
			local first_version = tonumber(string.sub(tab[1], 2)) or 0
			local second_version = tonumber(tab[2]) or 0
			local third_version = tonumber(tab[3]) or 0
			table.insert(ver_tab, {version = version, first_version = first_version,second_version = second_version, third_version = third_version})
		end
		-- 版本号降序排列
		table.sort(ver_tab, function(data1, data2)
			if data1.first_version == data2.first_version then
				if data1.second_version == data2.second_version then
					return data1.third_version > data2.third_version
				else
					return data1.second_version > data2.second_version
				end
			else
				return data1.first_version > data2.first_version
			end
		end)
		if #ver_tab > 0  then
			local max_version = ver_tab[1].version
			local min_version = ver_tab[#ver_tab].version
			if self:compareResourceVersion(cur_version, max_version) then -- 当前版本大于等于最大版本不热更
				Logger.logAlways(cur_version, "not hot resources")
			elseif self:compareResourceVersion(min_version, cur_version) then -- 最小版本大于等于当前版本认为当前版本不正确，不热更
				Logger.logAlways(cur_version, "resources version is error ")
			else
				-- 找第一个小于当前版本的热更资源
				for i,v in ipairs(ver_tab) do
					if self:compareResourceVersion(cur_version, v.version) then
						Logger.logAlways(cur_version, "hot resources")
						res_version_data = res_data[v.version]
						break
					end
				end
			end
		end
	end
	return res_version_data
end

-- 获取资源的json数据
function M:getResourceJsonData(extra_info)
	local extra_info_tab = Json.decode(extra_info)
	if extra_info_tab then
		local resource_version
		if SDKUtil.sdk_params.app == 2 then
			resource_version = extra_info_tab.ios_rv
		else
			resource_version = extra_info_tab.android_rv
		end
		local res_json_url = self.m_model:getResJsonUrl(resource_version)
		if res_json_url then
			local function responseMethod(response, tag, status_code)
				if response then
					local data = Json.decode(response)
					local res_version_data = self:getResourceVersionData(data)
					if res_version_data then
						Logger.logAlways(res_version_data, "res_version_data-->")
						self.m_model:setResourceResponse(res_version_data)
						self:downloadRes()
					else
						Logger.logWarningAlways(GameVersionConfig.GAME_RESOURCES_VERION, "cur_version not found : ")
						self:downloadRes()
					end
				else
					if tostring(status_code) == "404" then
						Logger.logErrorAlways(res_json_url, " res_json_url not found : ")
						local change_count = self.m_url_change_count + 1
						if change_count >= #self.m_model.res_response.url then
							self:downloadRes()
						else
							self:downResUrlChanged()
							self:getResourceJsonData(extra_info)
						end
					else
						self:downResUrlChanged()
						self:getResourceJsonData(extra_info)
					end
				end
			end
			NetWork:httpRequest(responseMethod, res_json_url, GlobalConfig.GET, {}, "res_json_url", 0, true, 2, true)
		else
			Logger.logErrorAlways(extra_info, " server extra_info is error : ")
			self:downloadRes()
		end
	else
		self:downloadRes()
	end
end

-- 检测网络环境，是否是WiFi
function M:networkStatusReachable(callback)
	if self.m_network_tips == false then
		callback()
		return
	end

	self.m_network_tips = false
	local newNetType = GameUtil:getNetworkReachability()
	local netType = ""
	SDKUtil:getNetworkState(function(params)
		netType = params.data
		if netType == "wifi" or newNetType == "wifi" then
			-- self:downloadRes()
			callback()
		elseif netType == "4G" or netType == "5G" or netType == "2G" or netType == "3G" or newNetType == "4G" then
			local params =
			{
				on_ok_call = function(msg)
					-- self:downloadRes()
					callback()
				end,
				on_cancel_call = function (msg)
					GameMain.reStart()
				end,
				no_close_btn = true,
				text = Language:getTextByKey("update_str_0002")
			}
			static_rootControl:openView("Pops.CommonPop", params, "updateNetTypePop")
		else
			local params =
			{
				on_ok_call = function(msg)
					GameMain.reStart()
				end,
				--on_cancel_call = function (msg)
				--	GameMain.reStart()
				--end,
				no_close_btn = true,
				text = Language:getTextByKey("update_str_0005")
			}
			static_rootControl:openView("Pops.CommonPop", params,"updateNetTypeError")
		end
	end)
end

-- 下载热更资源
function M:downloadRes()
	if GameUtil:getpPlatform() == "Editor" then -- 开发环境跳过下载资源
		Logger.log("---------------- jump download res go config --------------")
		self:checkDownloadConfig()
	else
		if self.m_model.down_num < self.m_model.res_response.count then
			self.m_view:setObjectVisible("progress_slider", true)
			local function checkWifiBack()
				self.m_isRestart = true
				local fileName, url = self.m_model:getResUrl()
				local md5 = self.m_model:getResMd5()
				local file_size = self.m_model:getResFileLength()
				self.m_view:downloadRes(fileName, url, md5, file_size)
				StatisticsUtil:doPoint("startDownloadHotUpdate")
			end
			self:networkStatusReachable(checkWifiBack)
		else
			self:downLoadResEnd()
		end
	end
end

function M:downLoadResEnd()
	-- body
	local res_version = self.m_model:getResversion()
	if GameMain.setGameVersion then
		Logger.logAlways(res_version, "----------- downLoadResEnd save new-------------")
		GameMain.setGameVersion("game_resources_verion", tostring(res_version))
	else
		Logger.logAlways(res_version, "----------- downLoadResEnd save old-------------")
		U3DUtil:PlayerPrefs_SetString("game_resources_verion", tostring(res_version))
	end
	self:checkDownloadConfig()
end

----------------------------------------------------------------------------------------
---------------------------- 美丽的风景线 ------------------------------------------------
----------------------------------------------------------------------------------------
-- 检查是否下载热更配置
function M:checkDownloadConfig()
	local localAllCfgMd5 = U3DUtil:PlayerPrefs_GetString("all_config_version")
	local netCfgMd5 = self.m_model:getAllConfgMd5()
	-- if localAllCfgMd5 ~= netCfgMd5 then
	self:analysisNeedDownConfig()
	self:downloadConfig()
	-- else
	-- 	self:downloadConfigEnd()
	-- end
	StatisticsUtil:doPoint("startDownloadConfig")
end

--- 分析需要下载哪些配置
function M:analysisNeedDownConfig()
    local cfgVersionData = self.m_model:getConfigMd5Table()

    local config_path = ConfigManager.CONFIG_PATH

    local readData = io.readfile(config_path .. "game_config_version.txt")
    if readData then		
		self.m_model.m_configOldTable = Json.decode(readData) or {};
		for k, v in pairs(self.m_model.m_configOldTable) do
			if cfgVersionData[k] == nil then
				self.m_model.m_configOldTable[k] = nil
			end
		end
    else
        self.m_model.m_configOldTable = {}
    end

    --当前配置文件
    self.m_model.m_downloadCfgTab = {}
    self.m_model.m_downloadCfgMD5 = {}

    -- 过滤不需要多语言配置
    local index = 1
    local addOneDownConfig = function (configName, configVer)
        self.m_model.m_downloadCfgTab[index] = configName
        self.m_model.m_downloadCfgMD5[index] = configVer
        index = index + 1
    end

    local verValue = nil;  -- 记录原版本号
    for configName, configVer in pairs(cfgVersionData) do
    	if configVer and configVer ~= "" then
	        verValue = self.m_model.m_configOldTable[configName]
	        if verValue == nil then
	            addOneDownConfig(configName, configVer)   -- 如果没有记录，则不使用忽略规则
				Logger.logAlways(configName, "need download cfg ,pre config file not found key : ")
	        else
				if configVer ~= verValue then	--本地版本号与远程版本不匹配
					addOneDownConfig(configName, configVer)
				else
					-- 区分了普通配置和战斗配置
					local fileFullPath = "";
					if Battle.BattleGlobalConfig.BattleConfigName[configName] ~= nil then
						fileFullPath = ConfigManager.BATTLE_CONFIG_PATH  .. configName .. "__" .. configVer .. ".lua"
					else
						fileFullPath = config_path .. configName .. "__" .. configVer .. ".lua"
					end
					if (not io.exists(fileFullPath)) then           -- 本地文件未找到
						addOneDownConfig(configName, configVer)	
						Logger.logAlways(configName, "need download cfg , old md5 = " .. tostring(verValue) .. " ; new md5 = " .. tostring(configVer) .. " is different or file not found")
					end
				end
	        end
	    end
    end
end

-- 下载热更配置
function M:downloadConfig()
	self.m_link_count = 0
	self.m_url_change_count = 0
	self.m_model.down_num = 0
	--判断是不是新的服务器数据格式，新格式下资源和配置的url是同一个list，索引不需要重置，老的数据则需要重置
	if not(UserDataManager.server_data:getIsNewServerData()) then
		self.m_model.url_index = 1
	end
	self.m_config_total = #self.m_model.m_downloadCfgTab
	if self.m_config_total > 0 then
		self.m_view:setObjectVisible("progress_slider", true)
	end
	self:downloadNextConfig()
end

-- 变更资源备用地址
function M:downConfigUrlChanged()
	self.m_url_change_count = self.m_url_change_count + 1
	if self.m_url_change_count >= #self.m_model.config_response.url then
		-- Logger.log(self.m_url_change_count,"config url all changed === ")
		return false
	end
	self.m_model:downConfigUrlChanged()
	return true
end

-- 下载配置
function M:downloadNextConfig()
    if self.m_model.down_num >= #self.m_model.m_downloadCfgTab then
    	local netCfgMd5 = self.m_model:getAllConfgMd5()
    	U3DUtil:PlayerPrefs_SetString("all_config_version", netCfgMd5)

    	local function delayCall()
    		self:downloadConfigEnd()
    	end
        self:setOnceTimer(0.1, delayCall)
    else
		self.m_view:downloadConfig(self.m_model.down_num, self.m_config_total)
    	local function checkWifiBack()
			-- self.m_isRestart = true
        	self:downloadConfigCDNData()
		end
		self:networkStatusReachable(checkWifiBack)
    end
end

--- 尝试从CDN下载配置下载
function M:downloadConfigCDNData()
	local configName, md5, url = self.m_model:getConfigUrl()
    if url == nil or url == "" then  -- 没有cdn地址
        return 
    end
    local function responseMethod(gameData, event)
        if gameData == nil then
    		if self:downConfigUrlChanged() == false then
				self:downConfigError()
			else
				self:downloadNextConfig()
			end
        else
			local data_md5 = CS.wt.framework.LuaFileHelper.Inst:MD5EncryptString(gameData)
			if data_md5 ~= md5 then
				Logger.log(data_md5,"data_md5 =====")
				Logger.log(md5,"md5 =====")
				self:downConfigError("update_str_0008",configName, data_md5, md5)
			else
				self:downOneConfigSuccess(configName, gameData, md5)
				self.m_url_change_count = 0
				--self.m_model.url_index = 1
				self:downloadNextConfig()
			end
        end
    end
    Logger.log(url, "donw load config -------  ")
    NetWork:httpRequest( responseMethod , url, GlobalConfig.GET , "", "config_cdn" , 0, true, true, true)
end

function M:downConfigError(error_text, extraTip, dataMd5, oriMd5)
	self.m_url_change_count = 0
	self.m_model.url_index = 1
	if error_text == nil then
		error_text = "update_str_0007"
	end
	if extraTip == nil then
		extraTip = ""
	end
	if dataMd5 == nil then
		dataMd5 = ""
	end
	if oriMd5 == nil then
		oriMd5 = ""
	end
	local params =
	{
		on_ok_call = function(msg)
			self:setOnceTimer(0.5,function ()
				self:downloadNextConfig()
			end)
		end,
		no_close_btn = true,
		text = Language:getTextByKey(error_text or "update_str_0007").."\r\n"..extraTip.."\r\n"..dataMd5.."\r\n"..oriMd5
	}
	static_rootControl:openView("Pops.CommonPop", params)
end

local __LuaZipHelper = CS.wt.framework.LuaZipHelper
local __LuaFileHelper = CS.wt.framework.LuaFileHelper

--- 下载一个配置成功
function M:downOneConfigSuccess(configName, configData, md5)
	local config_path = ConfigManager.CONFIG_PATH

	if Battle.BattleGlobalConfig.BattleConfigName[configName] ~= nil then
		config_path = ConfigManager.BATTLE_CONFIG_PATH
	end
    if not io.exists(config_path) then  -- 如果写入配置目录不存在，创建目录
        io.mkdir(config_path)
    end
	local fullpath = config_path .. tostring(configName) .. "__" .. tostring(md5) .. ".lua"
    -- Logger.log(fullpath,"fullpath ========")
	-- 解密并解压
	local newConfigData = __LuaZipHelper.Inst:GzipDecompressAndDecrypt(configData, __LuaFileHelper.xxteaKey)
	if newConfigData == nil then
		newConfigData = configData
	end
    io.writefile(fullpath, newConfigData)  -- 写入文件

	local old_md5 = self.m_model.m_configOldTable[configName]
    if md5 then
        self.m_model.m_configOldTable[configName] = md5
        local fullpath = ConfigManager.CONFIG_PATH .. "game_config_version.txt"
        io.writefile(fullpath, Json.encode(self.m_model.m_configOldTable))  -- 把版本号写入game_config_version.txt文件，用来和下次做对比
	else
		Logger.logErrorAlways(configName, "cfg not found md5 : ")
    end

    self.m_model:downloadNumber()
	if old_md5 ~= nil and md5 ~= old_md5 then -- 删除旧的带md5的配置
		CS.wt.framework.LuaFileHelper.Inst:DeleteFile(config_path .. tostring(configName) .. "__" .. tostring(old_md5) .. ".lua")
	end
end

-- 配置下载完成
function M:downloadConfigEnd()
	Logger.log("----------- downLoadRConfigEnd -------------")
	if self.m_isRestart then
		GameMain.download_game_resources = true
		GameMain.reStart()
	else
		ConfigManager:resetCfg()
		Language:init()
		--local preload_cfg = ConfigManager:analysisPreloadCfg()
		--local index = 1
		--local function tick()
		--	if preload_cfg[index] then
		--		ConfigManager:loadCfg(preload_cfg[index][1], preload_cfg[index][2])
		--		index = index + 1
		--		self.m_view:loadConfig(index, #preload_cfg)
		--	else
		--		-- if CS.wt.framework.ResourcesHelper.useAssetBundle then
		--		-- 	CS.wt.framework.ResourcesHelper.LoadFromAssetBundleAll("commoneffect")
		--		-- 	CS.wt.framework.ResourcesHelper.LoadFromAssetBundleAll("role3d_cangyun2")
		--		-- 	CS.wt.framework.ResourcesHelper.LoadFromAssetBundleAll("role3d_liushan9")
		--		-- 	CS.wt.framework.ResourcesHelper.LoadFromAssetBundleAll("role3d_robberleader20")
		--		-- 	CS.wt.framework.ResourcesHelper.LoadFromAssetBundleAll("role3d_gaibang12")
		--		-- 	CS.wt.framework.ResourcesHelper.LoadFromAssetBundleAll("role3d_mingjiao1")
		--		-- end
		--		self:removeTimer(self.preload_cfg_timer)
		--		self:updateMsg(99999)
		--	end
		--end
		--self.preload_cfg_timer = self:setTimer(0.02, tick)
  		--self.m_view:loadConfig(0, #preload_cfg)
		self:updateMsg(99999)
	end
end

return M
