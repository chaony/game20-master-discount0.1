------------ ClientData

local M = {
	user_token = nil,
	app_id = nil,
	pt = nil,
	lan = nil,
	user_account = nil,
	device_mark = nil,
	is_iphonex = false,
	is_new_user = false,
	sk = nil,
	crypto_switch = false,
	crypto_key = "z+m-h/x*",
	login_crypto_key = "z4+lm7oh2g/xi*0n",
	all_crypto_key = nil,
	sdk_token = nil,
	--tps_key = "V+lzmaY3p3pDw9o2iRGEUoN2Eg4JtSORD9IlzRB4P08FQBlCzjkgLxqbzDeAFDZ2rUQtrvHf3OhT0RE5mODdFiJX756UGGtrqoN23uZXF0Zc2etW8QBl+u0QLuHZ9nKmHRsRCVJEXfXbPI/ddaoJAYTvX7ktghRs9vfQHQMw4Zbm/JYCG/R5/067mdzHCpsyATq21pDiLMQgye0Nb/u9U4U3n9+5DGCsKYtvkbIfroFS8N+TSZbf8SRJWvx6/8eqvtVzZdbgRnZMx/Q2eYacRbjP6hhEHocae89DrIxY/0xoh5rxvHvHZOCnXMAzhwzRY501/hxPtypah0vJjNDa5A==",
	tps_key = "EO3wL8K8945IuuBcwnDRrh3wvbhHIQ7NiUc9DRCkJ3tNalwEhNS806JgsS5MNSrYRZ4RdvAQ1iwXgeYp+NhI/i1q5JecT++b58eFvyD+GmGRqfTwuZ0AIx/i722JCMJiv9WE6sM/6RSsD0tBiMoiwkLlnsehDvg2ASH9rPxaPDMQq0jbK127wBcHel90JtvXnlfun868TDJdJIvCDp9It/69rl3ORyKnUXrvYs+QU6RrE2czyC4sc6SmDh+CPClsvzfZOSlBvyxiHN6gbhDotCrq6fKNfW+Kx3pj1mIHQUbKkseeGmQJhlvhnCguGHcxflhpYmRNTSvq3wYOc5+uAQ==",
}

local screen_width = U3DUtil:Screen_Width()
local screen_height = U3DUtil:Screen_Height()
if screen_width == 2436 and screen_height == 1125 then
	M.is_iphonex = true
else
	-- TODO  通过不同的机型返回是否需要处理刘海
end

function M:getDeviceMark()
	return self.device_mark or ""
end

function M:setSk(value)
	self.sk = value
	self.all_crypto_key = tostring(self.crypto_key) .. tostring(self.sk)
end

function M:getAllCryptoKey()
	return tostring(self.all_crypto_key)
end

function M:setCryptoSwitch(value)
	self.crypto_switch = value
end

function M:setSdkToken(value)
	self.sdk_token = value
end

function M:getSdkToken()
	return self.sdk_token
end

function M:getCryptoSwitch()
	return self.crypto_switch
end

local __LuaZipHelper = CS.wt.framework.LuaZipHelper
local __gzip_flag = GameVersionConfig.vcd == 1
local __XXTEA = CS.Xxtea.XXTEA

if GameVersionConfig.vcd == 2 then
	__LuaZipHelper.Inst:TpsClientSdkInit(M.tps_key)
end

function M:encryptToBase64String(data_str)
	if GameVersionConfig.vcd == 2 then
		return data_str
	end
	local key = self:getAllCryptoKey()
	local temp_data = nil
	if __gzip_flag then
		temp_data = __LuaZipHelper.Inst:GzipCompressAndEncrypt(data_str, key)
	else
		temp_data = __XXTEA.EncryptToBase64String(data_str, key)
	end
	return temp_data
end

function M:decryptBase64StringToString(data_str)
	if GameVersionConfig.vcd == 2 then
		return data_str
	end
	local key = self:getAllCryptoKey()
	local temp_data = nil
	if __gzip_flag then
		temp_data = __LuaZipHelper.Inst:GzipDecompressAndDecrypt(data_str, key)
	else
		temp_data = __XXTEA.DecryptBase64StringToString(data_str, key)
	end
	return temp_data
end

function M:loginEncryptToBase64String(data_str)
	if GameVersionConfig.vcd == 2 then
		return data_str
	end
	local key = self.login_crypto_key
	local temp_data = nil
	if __gzip_flag then
		temp_data = __LuaZipHelper.Inst:GzipCompressAndEncrypt(data_str, key)
	else
		temp_data = __XXTEA.EncryptToBase64String(data_str, key)
	end
	return temp_data
end

function M:loginDecryptBase64StringToString(data_str)
	if GameVersionConfig.vcd == 2 then
		return data_str
	end
	local key = self.login_crypto_key
	local temp_data = nil
	if __gzip_flag then
		temp_data = __LuaZipHelper.Inst:GzipDecompressAndDecrypt(data_str, key)
	else
		temp_data = __XXTEA.DecryptBase64StringToString(data_str, key)
	end
	return temp_data
end


return M