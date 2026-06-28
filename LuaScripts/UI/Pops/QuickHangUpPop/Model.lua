local M = class("QuickHangUpPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self:getNum()
end


function M:getNum()
	local now_tim = UserDataManager:getServerTime()
	local user_data = UserDataManager.user_data
	local vip = user_data:getUserStatusDataByKey("vip")
	local vip_cfg = ConfigManager:getCfgByName("vip")[vip]
	--快速挂机次数
	self.use_num = UserDataManager.idle_info.quick_idle_times --已使用的次数
	self.m_quick_idle_times = vip_cfg.quick_idle_times - UserDataManager.idle_info.quick_idle_times
	if self.m_quick_idle_times < 0 then
		self.m_quick_idle_times = 0
	end
	self.m_tim  = UserDataManager.end_ts - now_tim
end

function M:getCost()
	local renovate_tab = ConfigManager:getCfgByName("renovate")
	local cfg = renovate_tab[5]
	return cfg.cost[self.use_num + 1]
end

--挂机收益表
function M:getStagepIdle()
    local stage_id = UserDataManager:getCurStage()
    local stage_tab = ConfigManager:getCfgByName("stage")
    local stage_idle_tab = ConfigManager:getCfgByName("stage_idle")
    local idle_id =  stage_tab[stage_id].idle_id
    local idle_cfg = stage_idle_tab[idle_id]
    return idle_cfg
end

--挂机突破丹收益表
function M:getStagepIdle2()
    local stage_id = UserDataManager:getCurStage()
    local stage_tab = ConfigManager:getCfgByName("stage")
    local stage_idle_tab = ConfigManager:getCfgByName("stage_idle")
    local idle_id =  stage_tab[stage_id].idle_id
	local idle_cfg = stage_idle_tab[idle_id]
	local dust = idle_cfg.idle_drop.dust
	local idle_drop = ConfigManager:getCfgByName("idle_drop")
	local item = idle_drop[dust[1]]
    return item.random_reward.rewards[1][3], dust[2]
end

--掉落金币
function M:getIdleMoney()
	local cfg = self:getStagepIdle()
	local num = cfg.coin * 7200
    return math.floor(num / 20)
end
--掉落英雄经验
function M:getIdleHeroExp()
	local cfg = self:getStagepIdle()
	local num = cfg.hero_exp * 7200
    return math.floor(num / 20) 
end
--掉落突破丹
function M:getIdlePlayerExp()
	local item_num, inter  = self:getStagepIdle2()
	local num = item_num * 7200
    return math.floor(num/inter)
end

function M:getNumByType(t)
	if t == RewardUtil.REWARD_TYPE_KEYS.DUST then
		return self:getIdlePlayerExp()
	elseif	t == RewardUtil.REWARD_TYPE_KEYS.COIN then
		return self:getIdleMoney()
	elseif	t == RewardUtil.REWARD_TYPE_KEYS.HERO_EXP then
		return self:getIdleHeroExp()
	end
	return 0
end

--- 网络数据回调，需要复写
function M:netData(data, tag)
	if tag == "get_quick_idle_reward" then
		Logger.log(data,"GG")
	end
end

return M
