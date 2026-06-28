local M = class("UnionIndexModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_data = self.m_params
	self.creat_limit = self:checkVipGuildMake()
	self.creat_day = ConfigManager:getCommonValueById(530,4)
end

--检测是否可以创建公会
function M:checkCanCreatTeam()
	local vip_tab = ConfigManager:getCfgByName("vip")	
	local vip = UserDataManager.user_data:getUserStatusDataByKey("vip")
	if vip_tab[vip] then
		local cur_cfg = vip_tab[vip]
		if cur_cfg.guild_make == 1 then
			return true
		end
	end
	return false
end

--
function M:checkVipGuildMake()
	local vip_tab = ConfigManager:getCfgByName("vip")	
	for i = 0, #vip_tab do
		local c_cfg = vip_tab[i]
		if c_cfg then
			if c_cfg.guild_make == 1 then
				return i
			end
		end
	end
end

--检测注册时间是否足够
function M:checkDayLock()
	local registerDay = GameUtil:playerRegisterDays()
	return registerDay >= self.creat_day
end

return M
