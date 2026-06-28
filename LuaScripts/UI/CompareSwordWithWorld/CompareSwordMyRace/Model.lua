local M = class("CompareSwordMyRaceModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.round = self.m_params.round or 1
	self.phase_day = self.m_params.phase_day
	self.racePhase = self.m_params.racePhase or 2	--积分赛2 晋级赛3
	self.data_racePhase = self.m_params.data_racePhase --服务器返回的全阶段
	self.role_id = UserDataManager.user_data:getUid()
	if self.racePhase == 2 then
		self:getData("full_service_point_race_schedule",{target_uid = self.role_id})
	elseif self.racePhase == 3 then
		self:getData("full_service_top_my_battle",{round_stage = self.phase_day})
	end
end

function M:onEnter()
	--local cfg = ConfigManager:getCfgByName("") --获取配置表数据
	local netData = self.m_data  --获取服务器数据

	self.self_boss_damage_rank = self.m_params.self_boss_damage_rank or 0
	self.boss_damage_rank = self.m_data.boss_damage_rank or 0 --boss 排名
	self.point_race_score = self.m_data.point_race_score or 0 --比赛积分
	self.full_service_point_race_rank = self.m_data.full_service_point_race_rank or 0 --积分胜场
	self.rise_rank = self.m_data.top_best_rank
	self.rank_data = {}
	self:initData()
end

function M:initData()
	--init net data
    local data = self.m_data.schedule or {}
	for k,v in pairs(data) do 
		local data_ = v
		data_.index = tonumber(k) +1
		table.insert(self.rank_data,data_)
	end
	table.sort(self.rank_data,function(a, b) 
		return a.index<b.index
	end)
	-- self.m_something = self.data.netData
end

function M:updateData( response )
	-- use mothed in control , for update from net 
	table.merge(self.m_data , response)
	self:initData()
end

function M:getShowHeroData(hero_data)
	if hero_data then
		local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
		data.quality = hero_data.evo
		data.card_id = hero_id
		data.hero_data = hero_data
		return data
	end
end


function M:destroy()

	M.super.destroy(self)
end

return M