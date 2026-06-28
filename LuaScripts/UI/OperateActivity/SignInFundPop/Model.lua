local M = class("SignInFundPopModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
    self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_sign_data = self.m_params.data
    self.m_high = self.m_params.high
end

function M:getCfgTab(version, max_day)
    if self.m_high == 1 then
        return self:get_high_fund_cfg(version, max_day)
    else
        return self:get_noormal_fund_cfg(version, max_day)    
    end
end


--超值基金
function M:get_noormal_fund_cfg(version, max_day)
    local normal_fund_tab = ConfigManager:getCfgByName("normal_fund_reward")
    local c_version = version or 1
    local version_tab = normal_fund_tab[c_version]
    local new_tab = {}
    for i = 1, max_day do
        new_tab[i] = version_tab[i]
    end
    return new_tab
end

--豪华基金
function M:get_high_fund_cfg(version, max_day)
    local high_fund_tab = ConfigManager:getCfgByName("high_fund_reward")
    local c_version = version or 1
    local version_tab = high_fund_tab[c_version]
    local new_tab = {}
    for i = 1, max_day do
        new_tab[i] = version_tab[i]
    end
    return new_tab
end

--签到基金
function M:get_sign_cfg()
    local index = self.m_high +1
    local sign_fund_tab = ConfigManager:getCfgByName("sign_fund")
    return sign_fund_tab[index]
end

function M:getDayDiff(tim_ts)
    local server_ts = UserDataManager:getServerTime()
    local day = GameUtil:NumberOfDaysInterval(tim_ts, server_ts, 0)
    return day + 1
end

return M