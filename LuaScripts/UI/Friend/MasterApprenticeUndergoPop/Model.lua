local M = class("MasterApprenticeUndergoPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData("mentorship_msg_info")
end

function M:onEnter()
	self:initData()
end

function M:initData(data)
	if data then
		self.m_data = data
	end
	self.m_msgs = self.m_data.msgs
end

function M:getDesc(index)
	local data = self.m_msgs[index]
	if data then
		local desc =  os.date("%m月%d日 %H:%M", data.ctime) --  
		local tab = ConfigManager:getCfgByName("prompt")
		local cfg = Language:getTextByKey(tab[data.prompt].text) 
		local str_desc = string.gsub(cfg, "%b{}", function(a,b) 
			local num = string.match(a, "%d") 
			local type = string.match(a, "%a%a%a%a%a") 
			if type == "Stage" then
				local stage_data = self:getStageName(data.params[tonumber(num)])
				return Language:getTextByKey(stage_data.map_point_name) 
			else
				return data.params[tonumber(num)] 
			end
		end)
		return desc.."    "..str_desc
	end
end

function M:getStageName(id)
	local stage_tab = ConfigManager:getCfgByName("stage")
	local stage_data = stage_tab[id]
	return stage_data
end

return M
