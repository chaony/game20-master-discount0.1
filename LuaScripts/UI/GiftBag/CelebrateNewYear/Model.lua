local M = class("CelebrateNewYearModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	--self.m_transfer = "scale"
	self.is_token = self.m_params.is_token
	self:getData("spring_festival_index")
end

function M:onEnter()
	self.m_refresh_times = 0 -- 刷新首页次数
	self.m_max_refresh_times = 2 -- 刷新首页最大次数
	self:updateData()
end


function M:updateData(data)
	if data then
		table.merge(self.m_data, data)
	end
	--Logger.logError( self.m_data, " spring_festival_index 数据 ")
	--当前开启的付费活动
	self.charge_actives = self.m_data.charge_actives;
	--当前开启的活动
	self.actives = self.m_data.actives;
	--活动版本号
	self.version = self.m_data.version;
	--当前第几天
	self.cur_day = self.m_data.cur_day;
	--签到奖励 已领取的签到奖励id
	self.sign_done = self.m_data.sign_done;
	--春节礼包 [服务器直接给数据]
	self.spring_gifts = self.m_data.spring_gifts;
	--团圆饭礼包 [服务器直接给数据]
	self.dinner_gifts = self.m_data.dinner_gifts;
	--皮肤礼包 已购买的皮肤礼包id [读取本地表]
	self.clothes_done = self.m_data.clothes_done;
	--砸罐子次数
	self.draw_times = self.m_data.draw_times;
	--碎碎平安礼包 这个礼包需要从配置里读数据 [读取本地表]
	self.draw_gifts = self.m_data.draw_gifts;
	--大奖轮播数据
	self.m_draw_msgs = self.m_data.draw_msgs;
	--小游戏合集
	self.little_games = self:getAllLittleGames()
	--帮会积分
	self.m_guild_score = self.m_data.guild_score
	--帮会积分奖励领取记录
	self.m_dinner_done = self.m_data.dinner_done
	self.all_actives = nil
	self:getAllOpenActives()
	local dinner_type_tab = ConfigManager:getCfgByName("dinner_type");
	local vsn_tab = dinner_type_tab[self.version]
	for i = 1, #vsn_tab do
		local cur_cfg = vsn_tab[i]
		if self.cur_day >= cur_cfg.start_day and self.cur_day <= cur_cfg.end_day then
			self.m_key = i
		end
	end
	if self.m_key == 0 then
		local last_cfg = vsn_tab[#vsn_tab]
		if last_cfg then
			self.m_key = #vsn_tab
		end
	end
end


-- 当前所有的开启活动
-- mode == 1 返回所有的付费活动
-- mode == 2 返回所有的非付费活动
-- mode == N or nil 返回所有活动 
-- ["open_id"] = 262,
-- ["version"] = 1,
-- ["show_start_ts"] = 1673366400.0,
-- ["open_status"] = 1,
-- ["end_ts"] = 1673366399.0,
-- ["start_ts"] = 1640966400.0,
-- ["remain_ts"] = 30412091,
-- ["id"] = 218,
function M:getAllOpenActives( mode )
	if mode == 1 then
		return self.charge_actives
	elseif mode == 2 then
		return self.actives
	else
		if self.all_actives == nil then
			self.all_actives = {}
			for i, v in ipairs(self.charge_actives) do
				table.insert(self.all_actives,v);
			end
			for i, v in ipairs(self.actives) do
				table.insert(self.all_actives,v);
			end
		end
		return self.all_actives;
	end
end

function M:getActivesByOpenId( open_id )
	if self.all_actives == nil then
		self:getAllOpenActives()
	end
	for i, v in pairs(self.all_actives) do
		if v.open_id == open_id then
			return v
		end
	end
	return {}
end

function M:isActOpenByOpenId(open_id)
	local active = self:getActivesByOpenId(open_id)
	local open_flag = false
	local time_text = Language:getTextByKey("world_boss_str_0030")
	if next(active) then
		local start_ts = active.start_ts or 0
		local diff_time = start_ts - UserDataManager:getServerTime() + 2
		if diff_time > 0 then
			time_text = Language:getTextByKey("new_str_1086", GameUtil:formatTimeBySecond(diff_time))
		else
			if active.open_status == 3 then
				time_text = "refresh_index"
			else
				open_flag = true
			end
		end
	end
	return open_flag, time_text
end


--获取所有小游戏
function M:getAllLittleGames()
	local little_games = {}
	for k,v in pairs(self.actives) do
		if v.open_id == 267 then
			table.insert(little_games, v)
		end
	end
	return little_games
end

function M:refreshData(data)
	if data then
		table.merge(self.m_data, data)
	end
end

--查看红点
function M:checkRedPointByOpenId(open_id)
	local is_open, open_tips = self:isActOpenByOpenId(open_id)
	if is_open == false then
		return false
	end
	if open_id == 262 then
		if self.clothes_done == nil then
			return false
		end
		if next(self.clothes_done) == nil then
			return RedPointUtil:localRedPointJudge("new_year_skipday")
		end
		if table.nums(self.clothes_done) >= 2 then
			return false
		end
		return RedPointUtil:localRedPointJudge("new_year_skipday")
		-- RedPointUtil:saveLocalRedPointFreshTime("new_year_skip_shop_262")
	elseif open_id == 263 then
		return self:checkRedGiftRedPoint()
	elseif open_id == 264 then
		return self:getFreeDinner() == true or self:getDiamondDinner() == true or self:getMilestoneDinner() == true
	elseif open_id == 265 then
		local reward_data = RewardUtil:getProcessRewardData({103,5365,1})
		if reward_data.user_num >= 10 then
			return true
		end
		return RedPointUtil:localRedPointJudge("spring_festival_shop_gift") --礼包一次性红点
	elseif open_id == 266 then
		return self:haveSignRed()
	elseif open_id == 267 then
		return RedPointUtil:hasRedPointById(267)
	end
	return false
end


function M:isSignByDay(day)
	for i = 1, #self.sign_done do
		if tonumber(self.sign_done[i]) == tonumber(day) then
			return true
		end
	end
	return false
end

function M:getSignCurDay()
	local actives = self:getActivesByOpenId(266)
	local day = 0--GameUtil:NumberOfDaysIntervalDay(start_ts, UserDataManager:getServerTime())
	if actives then
		local start_ts = actives.start_ts or 0
		day = GameUtil:NumberOfDaysIntervalDay(start_ts, UserDataManager:getServerTime())
	end
	return day
end

function M:haveSignRed()
	local sign_day = self:getSignCurDay()
	for day = 1, 7 do
		if not(self:isSignByDay(day)) and day <= sign_day then
			return true
		end
	end
	return false
end

--- 吉派利是 红点 START
function M:getGiftCfgByPlaceIdAndGiftId(place_id, gift_id)
	local spring_festival_gift_tab = ConfigManager:getCfgByName("spring_festival_gift")[self.version] or {}
	local cur_spring_festival_gift = spring_festival_gift_tab[self.cur_day] or {}
	if cur_spring_festival_gift[tonumber(place_id)] and cur_spring_festival_gift[tonumber(place_id)][tonumber(gift_id)] then
		return cur_spring_festival_gift[tonumber(place_id)][tonumber(gift_id)]
	end
	return nil
end
--- 吉派利是 红点
function M:checkRedGiftRedPoint()
	local redFlag = false
	for net_place_id, net_index_item in pairs(self.spring_gifts) do
		local cfg_data = self:getGiftCfgByPlaceIdAndGiftId(net_place_id, net_index_item.gift_id)
		if cfg_data and cfg_data.price == 0 then
			if net_index_item.times < cfg_data.time_limit then
				redFlag = true
			end
		end
	end
	return redFlag
end
--- 吉派利是 红点 END


--团圆饭礼包免费可领取
function M:getFreeDinner()
	local dinner_cfg, dinner_data = self:getDinnerGiftCfg(1)
	if not dinner_cfg or not dinner_data then
		return false
	end
	return (dinner_cfg.time_limit - dinner_data.times) > 0
end

--团圆饭礼包有元宝可购买的礼包
function M:getDiamondDinner()
	local dinner_cfg, dinner_data = self:getDinnerGiftCfg(2)
	if not dinner_cfg or not dinner_data then
		return false
	end
	return (dinner_cfg.time_limit - dinner_data.times) > 0
end

--团圆饭里程碑奖励可领取
function M:getMilestoneDinner()
	local dinner_rank_tab = ConfigManager:getCfgByName("dinner_reward");
	if next(dinner_rank_tab) == nil then
		return {}
	end
	local vsn_reward_tab = dinner_rank_tab[self.version]
	local key_tab = vsn_reward_tab[self.m_key]
	if not key_tab then
		return false
	end
	for k,v in pairs(key_tab) do
		if self.m_guild_score >= v.score then
			if self:checkDinnerDone(k) == false then
				return true
			end
		end
	end
	return false
end

function M:checkDinnerDone(id)
	local key_dinner_done = self.m_dinner_done[tostring(self.m_key)]
	if key_dinner_done then
		for k,v in pairs(key_dinner_done) do
			if v == id then
				return true
			end
		end
	end
	return false
end

function M:getDinnerGiftCfg(index)
	local dinner_gift = ConfigManager:getCfgByName("dinner_gift")
	local version_gift = dinner_gift[self.version];
	if version_gift == nil then
		return nil
	end
	if not version_gift[self.cur_day] then
		return nil
	end
    local day_gift = version_gift[self.cur_day];
	if day_gift then
		local index_gift = day_gift[index];
		local gift_data = self.dinner_gifts[tostring(index)]
		if index_gift ~= nil and gift_data then
			return index_gift[gift_data.gift_id] ,gift_data
		end
	end
	return nil
end

function M:getActiveCfgByOpenId(open_id)
	local active_tab = ConfigManager:getCfgByName("active")
	for i,v in pairs(active_tab) do
		if v.open_id == open_id then
			return v
		end
	end	
	local active_recharge_tab = ConfigManager:getCfgByName("active_recharge")
	for i,v in pairs(active_recharge_tab) do
		if v.open_id == open_id then
			return v
		end
	end	
	return nil
end

function M:checkActivesEnd(open_id)
	local active = self:getActivesByOpenId(open_id)
	if next(active) then
		local end_ts = active.end_ts or 0
		if UserDataManager:getServerTime() >= end_ts then
			return false
		else
			return true	
		end
	end
	return false
end

return M