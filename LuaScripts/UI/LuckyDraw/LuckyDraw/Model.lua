local M = class("LuckyDrawModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
    self:getData("gacha_active_index")
end

function M:onEnter()
    --Logger.logError(self.m_data,"数据~~~~~~~~~~~~~~~~~~~~~~~~~")
    self.open_id = 314
    self.is_token = self.m_params.is_token
    self.m_msg_data = self.m_params.msg_data or {}
    self.spring_festival_gacha = ConfigManager:getCfgByName("tongyong_gacha");
    self.rewards = self:getCanUseReward();
    self.m_actives = self:getActiveCfgByOpenId(self.open_id)
    self.m_big_reward = self:getBigReward()
    self.times = self.m_params.times;
    self.big_reward_index = 1 --大奖轮播
    self:getActiveData()
end

--更新数据
function M:netData(data, tag)
    table.merge(self.m_data, data)
end

--获取活动数据
function M:getActiveData()
    local main_gacha = ConfigManager:getCfgByName("main_gacha")
    self.active_datas = main_gacha[self.m_data.version]
end

function M:getOneCost()
    if self.active_datas then
        return self.active_datas.gacha[1]
    end
end

function M:getTenCost()
    if self.active_datas then
        return self.active_datas.gacha1[1]
    end
end

function M:getGachaItem()
    if self.active_datas then
        return self.active_datas.gacha_item
    end
end

function M:getGacheActiveID()
    if self.active_datas then
        return self.active_datas.active_id
    end
    return 0
end

--获取spine信息
function M:getSkinData(skin_id)
    local hero_skin = ConfigManager:getCfgByName("hero_skin")
    return hero_skin[skin_id] or {}
end

-- 砸罐子
function M:drawFromServer( time, call_back )
    self:getNetData("gacha_active_draw",{ version = self.m_data.version, times = time }, function( data )
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
    local gacha_data = self.spring_festival_gacha[self.m_data.version];
    local rewards = {}
    for i, v in ipairs(gacha_data) do
        if v.is_show then
            if #rewards < 3 then
                table.insert(rewards, v);
            end
        end
    end
    return rewards;
end

function M:getBigReward()
    local gacha_data = self.spring_festival_gacha[self.m_data.version];
    local rewards = {}
    for k,v in ipairs(gacha_data) do
        if v.type == 1 then
            table.insert(rewards, v);
        end
    end
    return rewards
end

function M:getBigRewardStr()
    local show_str = ""
    for i = #self.m_data.big_win_msg,1,-1 do
        local cur_str = ""
        local cur_msg_data = self.m_data.big_win_msg[i]
        local server_name = cur_msg_data.server_name
        --local server_name = UserDataManager.server_data:getServerNameById(cur_msg_data.server)
        local name = cur_msg_data.name
        local vsn_data = self.spring_festival_gacha[cur_msg_data.version];
        local gacha_data = vsn_data[cur_msg_data.gift_id]
        if gacha_data then
            local reward_data = RewardUtil:getProcessRewardData(gacha_data.reward[1])
            local item_name = reward_data.name.."*"..reward_data.data_num
            cur_str = Language:getTextByKey("new_year_str_003", server_name, name, item_name)
            if #self.m_data.big_win_msg == 1 then
                show_str = cur_str
            else
                show_str = show_str.."\n"..cur_str
            end
        end
    end
    return show_str
end

function M:getEndTs()
	if self.m_actives and self.m_actives.end_time then
        local end_ts = GameUtil:stringToTimesTamp(self.m_actives.end_time)
		return end_ts
	end
	return 0
end

function M:getActiveCfgByOpenId(open_id)
	local active_tab = ConfigManager:getCfgByName("active")
	for i,v in pairs(active_tab) do
		if v.open_id == open_id and v.version == self.m_data.version then
			return v
		end
	end	
	local active_recharge_tab = ConfigManager:getCfgByName("active_recharge")
	for i,v in pairs(active_recharge_tab) do
		if v.open_id == open_id and v.version == self.m_data.version then
			return v
		end
	end	
	return nil
end


return M