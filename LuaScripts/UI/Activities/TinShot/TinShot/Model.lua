local M = class("TinShotModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
    self:getData("spring_festival_index")
end

function M:onEnter()
    self.is_token = self.m_params.is_token
    --活动版本号
    self.m_actives = UserDataManager:getActivesDataByOpenId(265)
    self.version = self.m_actives.version;
    self.m_msg_data = self.m_data.draw_msgs or {}
    self.m_cfg_id_tab = {}
    self.spring_festival_gacha = ConfigManager:getCfgByName("spring_festival_gacha");
    self:initGachCfg()
    self.rewards = self:getCanUseReward();
    self.m_big_reward = self:getBigReward()
    self.m_draw_gifts = self.m_data.draw_gifts
    self.times = self.m_data.draw_times;
    self.big_reward_index = 1 --大奖轮播
end

function M:initGachCfg()
    for i, v in pairs(self.spring_festival_gacha[self.version]) do
        self.m_cfg_id_tab[#self.m_cfg_id_tab + 1] = tonumber(i)
    end
    table.sort(self.m_cfg_id_tab)
end

function M:getGachaByCfgId(cfg_id)
    if self.spring_festival_gacha[self.version] and self.spring_festival_gacha[self.version][cfg_id] then
        return self.spring_festival_gacha[self.version][cfg_id]
    end
    return nil
end

-- 砸罐子
function M:drawFromServer( time, call_back )
    self:getNetData("spring_festival_draw",{ version = self.version, times = time }, function( data )
        if call_back ~= nil then
            call_back(data)
        end
    end)
end

function M:newxBigRewardIndex()
    if self.big_reward_index + 1 > #self.m_big_reward then
        self.big_reward_index = 1
    else
        self.big_reward_index = self.big_reward_index + 1    
    end
end

-- 获取可以用的奖励
function M:getCanUseReward()
    --local gacha_data = self.spring_festival_gacha[self.version];
    local rewards = {}
    for i, cfg_id in ipairs(self.m_cfg_id_tab) do
        local v = self:getGachaByCfgId(cfg_id)
        if v and v.is_show then
            if #rewards < 3 then
                table.insert(rewards, v);
            end
        end
    end
    return rewards;
end

function M:getBigReward()
    local rewards = {}
    for i, cfg_id in ipairs(self.m_cfg_id_tab) do
        local v = self:getGachaByCfgId(cfg_id)
        if v.type == 1 then
            table.insert(rewards, v);
        end
    end
    return rewards
end

function M:getBigRewardStr()
    local show_str = ""
    for i = #self.m_msg_data,1,-1 do
        local cur_str = ""
        local cur_msg_data = self.m_msg_data[i]
        local server_name = cur_msg_data.server_name
        --local server_name = UserDataManager.server_data:getServerNameById(cur_msg_data.server)
        local name = cur_msg_data.name
        local vsn_data = self.spring_festival_gacha[cur_msg_data.version];
        local gacha_data = vsn_data[cur_msg_data.gift_id]
        local reward_data = RewardUtil:getProcessRewardData(gacha_data.reward[1])
        local item_name = reward_data.name.."*"..reward_data.data_num
        cur_str = Language:getTextByKey("new_year_str_003", server_name, name, item_name)
        if #self.m_msg_data == 1 then
            show_str = cur_str
        else
            show_str = show_str.."\n"..cur_str
        end
    end
    return show_str
end

function M:getEndTs()
	if self.m_actives and self.m_actives.end_ts then
		return self.m_actives.end_ts
	end
	return 0
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


return M