---@class UpdateModel:OODataBase
local M = class("UpdateModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.down_num = 0
	self.url_index = 1
	self.res_response = {}
	self.config_response = {}
	self.m_configOldTable = {}
	self.m_downloadCfgTab = {}
    self.m_downloadCfgMD5 = {}
end

-- 设置热更资源和配置信息
function M:setResponse(data)
	self.res_response.count = 0
	self.res_response = data.resource or {files = {}, count = 0}
	if data.resource.files then
		self.res_response.count = #data.resource.files
	end
	self.config_response = data.config
	self.config_response.count = #data.config.game_config_version
	local res_url = UserDataManager.server_data:getResourceUrl()
	if #res_url > 0 then
		self.res_response.url = res_url
	end
	local cfg_url = UserDataManager.server_data:getConfigUrl()
	if #cfg_url > 0 then
		self.config_response.url = cfg_url
	end
end

-- 设置热更资源信息
function M:setResourceResponse(data)
	table.merge(self.res_response, data)
	self.res_response.count = #data.files
end

function M:downloadNumber()
	self.down_num = self.down_num + 1
end

-- 下载失败更换地址
function M:downResUrlChanged()
	self.url_index = self.url_index + 1
	if self.url_index > #self.res_response.url then
		self.url_index = 1
	end
end

-- 获取最新资源的版本号
function M:getResversion()
	return self.res_response.version
end

function M:getRealResUrl(url)
	if url == nil then
		Logger.logErrorAlways("resources url is null")
		return ""
	end
	local start_idx = string.find(url, "/android/")
	if start_idx then 
		url = string.sub(url, 1, start_idx)
	end
	if SDKUtil.sdk_params.app == 2 then -- ios
		url = url .. "ios/"
	else-- android
		url = url .. "android/"
	end
	return url
end

-- 获取下载资源地址
function M:getResUrl()
	local url = self.res_response.url[self.url_index] 
	local file = self.res_response.files[self.down_num + 1][1]
	if file == nil then
		file = self.res_response.files[self.down_num + 1].file
	end
	url = self:getRealResUrl(url)
	return file, url .. file
end

-- 获取资源Json地址
function M:getResJsonUrl(resource_version)
	if resource_version then
		local url = self.res_response.url[self.url_index]
		url = self:getRealResUrl(url)
		return url .. resource_version .. ".json"
	end
end

-- 获取资源的MD5
function M:getResMd5()
	local md5 = self.res_response.files[self.down_num + 1][2]
	if md5 == nil then
		md5 = self.res_response.files[self.down_num + 1].md5
	end
	return md5
end

-- 获取资源文件长度
function M:getResFileLength()
	local file_length = self.res_response.files[self.down_num + 1][3]
	if file_length == nil then
		file_length = self.res_response.files[self.down_num + 1].size
	end
	return file_length
end

-----------------------------------------------------------------------------
------------------ 下面是配置 -------------------------------------------------
-----------------------------------------------------------------------------

-- 获取最新配置总文件MD5
function M:getAllConfgMd5()
	return self.config_response.all_config_version
end

-- 获取单个配置文件md5列表
function M:getConfigMd5Table()
	return self.config_response.game_config_version
end

-- 获取下载配置地址
function M:getConfigUrl()
	local url = self.config_response.url[self.url_index]
	local file = self.m_downloadCfgTab[self.down_num + 1]
	local md5 = self.m_downloadCfgMD5[self.down_num + 1]
	if url then
		return file, md5, url .. file .. "." .. md5 .. ".lua"
	else
		return file, md5, ""
	end
	
end

-- 下载失败更换地址
function M:downConfigUrlChanged()
	self.url_index = self.url_index + 1
	if self.url_index > #self.config_response.url then
		self.url_index = 1
	end
end

return M
