---@class FamilyDinnerModel:OODataBase
local M = class("FamilyDinnerModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
    -- self.m_transfer = "scale"
	self.is_token = self.m_params.is_token
	self:getData("spring_festival_index")
end

function M:onEnter()
	self.is_tokens = self.m_params.is_token
    -- 活动版本号
    
    -- 当前第几天
    self.day = self.m_data.cur_day;
    -- 服务器数据
    self.m_server_data = self.m_data.dinner_gifts;
    self.m_guild_score = self.m_data.guild_score;
	self.m_own_score = self.m_data.personal_score;
    self.m_dinner_done = self.m_data.dinner_done;
	self.m_actives = UserDataManager:getActivesDataByOpenId(264)
	self.version = self.m_actives.version;
	self.m_act_id = self.m_actives.id or 226
	local act_cfg = ConfigManager:getCfgByName("active")
	self.m_active_name = act_cfg[self.m_act_id] and act_cfg[self.m_act_id].name or ""
	self:InitData()
end

function M:InitData() 
	self.m_key = 0 -- 期数
    local dinner_type_tab = ConfigManager:getCfgByName("dinner_type");
	self.dinner_vsn_tab = dinner_type_tab[self.version]
	for i = 1, #self.dinner_vsn_tab do
		local cur_cfg = self.dinner_vsn_tab[i]
		if self.day >= cur_cfg.start_day and self.day <= cur_cfg.end_day then
			self.m_key = i
		end
	end
	if self.m_key == 0 then
		local last_cfg = self.dinner_vsn_tab[#self.dinner_vsn_tab]
		if last_cfg then
			self.m_key = #self.dinner_vsn_tab
		end
	end
	local server_time = UserDataManager:getServerTime()
	local next_fresh_time = TimeUtil.getIntTimestamp(server_time)
	self.day_end_ts = next_fresh_time + 24 * 3600 --今天结束的时间戳
	local cur_cfg = self.dinner_vsn_tab[self.m_key] --本期数据
	local days = cur_cfg.end_day - self.day --距离本轮结束间隔天数
	self.day_end_ts = self.day_end_ts + (86400*days)
	self.m_value_des = cur_cfg.des or ""
end


--获取服务器数据
function M:getServerData( call_back )
    self:getNetData("spring_festival_member_rank_info",{start = 1,stop = 5,version = self.version}, function( data )
        if call_back ~= nil then
            self.m_team_data = data
            call_back( data );
        end
    end)
end

function M:getGradeRewards()
	local dinner_rank_tab = ConfigManager:getCfgByName("dinner_reward");
	if next(dinner_rank_tab) == nil then
		return nil
	end
	local vsn_reward_tab = dinner_rank_tab[self.version]
	if vsn_reward_tab then 
		local key_tab = vsn_reward_tab[self.m_key] or {}
		local new_tab = {}
		for k,v in pairs(key_tab) do
			table.insert(new_tab,{id = tonumber(k), data = v} )
		end
		local function sortFun(data1, data2)
			return data1.id < data2.id
		end
		table.sort(new_tab, sortFun )
		for i = 1, #new_tab do 
			local cur_cfg = new_tab[i]
			if self.m_guild_score < cur_cfg.data.score then 
				return cur_cfg, (cur_cfg.data.score - self.m_guild_score)
			end
		end
		if #new_tab > 0 then
			local max_cfg = new_tab[#new_tab]
			return max_cfg, 0 
		end
	end
	return nil
end

function M:getEndTs()
	return self.day_end_ts
end

function M:getDinnerVoice(index)
	local dinner_gift = ConfigManager:getCfgByName("dinner_gift")
	local version_gift = dinner_gift[self.version];
    local day_gift = version_gift[self.day];
	local index_gift = day_gift[index];
	local gift_data = self.m_server_data[tostring(index)]
	if index_gift ~= nil then
		local gift_item = index_gift[gift_data.gift_id] 
		if gift_item then
			local action_index = math.random(1, #gift_item.voice)
			return gift_item.voice[action_index]
		end
	end
	return nil
end

function M:getDinnerGiftCfg(index)
	local dinner_gift = ConfigManager:getCfgByName("dinner_gift")
	local version_gift = dinner_gift[self.version];
	if version_gift == nil then
		return nil
	end
    local day_gift = version_gift[self.day];
	if day_gift == nil then
		return nil
	end
	local index_gift = day_gift[index];
	local gift_data = self.m_server_data[tostring(index)]
	if index_gift ~= nil and gift_data then
		return index_gift[gift_data.gift_id] ,self.m_server_data[tostring(index)]
	end
	return nil
end

--团圆饭里程碑奖励可领取
function M:getMilestoneDinner()
	local dinner_rank_tab = ConfigManager:getCfgByName("dinner_reward");
	if next(dinner_rank_tab) == nil then
		return false
	end
	local vsn_reward_tab = dinner_rank_tab[self.version]
	if vsn_reward_tab == nil then
		return false
	end
	local key_tab = vsn_reward_tab[self.m_key] or {}
	for k,v in pairs(key_tab) do
		if self.m_guild_score >= v.score and self.m_own_score >= v.personal_score then
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

function M:getActiveEndTs()
	if self.m_actives and self.m_actives.end_ts then
		return self.m_actives.end_ts
	end
	return 0
end

--团圆饭礼包免费可领取
function M:getFreeDinner()
	local dinner_cfg, dinner_data = self:getDinnerGiftCfg(1)
	if not dinner_cfg or not dinner_data  then
		return false
	end
	return (dinner_cfg.time_limit - dinner_data.times) > 0
end

--团圆饭礼包有元宝可购买的礼包
function M:getDiamondDinner()
	local dinner_cfg, dinner_data = self:getDinnerGiftCfg(2)
	if not dinner_cfg or not dinner_data  then
		return false
	end
	return (dinner_cfg.time_limit - dinner_data.times) > 0
end

--获取活动类型
function M:getCurrentActiveMode()
	local common = ConfigManager:getCfgByName("common")
	return common[639].value or 0
end

return M