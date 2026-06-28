local M = class("NewYearMiNiGameModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self:getData("mult_index")
end

function M:onEnter()
    self.m_change_tab = {}
    self.mini_game_data = ConfigManager:getCfgByName("mini_game");
    self.spring_festival_data = ConfigManager:getCfgByName("spring_festival");
    self.m_version = self.m_params.version --新年活动版本号
    self.ver_fest_data = self.spring_festival_data[self.m_version]
    self.m_change_tab = self.ver_fest_data.mini_game --展示小游戏版本号
    self.m_actives = self.m_params.data or {}
    self.cur_actives_data = self.m_params.actives or {}
    self.m_key = self.m_params.key 
end

function M:getMiniGameCfg(id)
    return self.mini_game_data[id]
end

function M:getMiniGameActives(version)
    for k,v in pairs(UserDataManager.m_actives) do
        if v.version == version then
            return v
        end
    end
    return nil
end

function M:getRecv(version)
    return self.m_data.recv_dict[tostring(version)] or {}
end

function M:getRecvId(version, id)
    if self.m_data.recv_dict[tostring(version)] then
        local recv_dict = self.m_data.recv_dict[tostring(version)]
        for k,v in pairs(recv_dict) do
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

--是否有奖励未领取
function M:checkCanGetReward(vsn)
    local vsn_cfg = self:getMiniGameCfg(vsn)
    local score = self.m_data.scores[tostring(vsn)] or 0
    for k,v in pairs(vsn_cfg.milepost_data) do
        if score >= k then
            if self:getRecvId(vsn, k) == false then
                return true
            end
        end
    end
    return false
end

--是否有首次进入
function M:checkFirstLogin(vsn)
    local red_data = UserDataManager.red_dot["mult_game_street"]
    if red_data and red_data.status == 1 and red_data.versions then
        local click_bl = RedPointUtil:localRedPointJudge("mult_game_street_"..vsn)
        if click_bl == true then
            return true
        end       
    end
end

function M:getEndTs()
    if self.cur_actives_data and self.cur_actives_data.end_ts then
        return self.cur_actives_data.end_ts
    end
    return 0
end

return M