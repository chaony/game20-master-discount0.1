local M = class("GrowUpFundPopModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
    self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_war_fund_receiced_data = self.m_params
end

function M:get_linshi_fund(id)
    local all_tab = ConfigManager:getCfgByName("growth_fund_reward")
    local fund_reward_tab = all_tab[id]
    local new_tab = {}
    for k,v in pairs(fund_reward_tab) do
        v.id = k
        table.insert(new_tab, v)
    end
    local function sortFunc(id_one, id_two)
        local data_one = self:getFundData(id_one.id)
        local data_two = self:getFundData(id_two.id)
        local get_1 = data_one.status == 2 and 1 or 0
        local get_2 = data_two.status == 2 and 1 or 0
        if get_1 == get_2 then
            return id_one.id < id_two.id
        else
            return get_1 < get_2
        end
    end
    table.sort(new_tab, sortFunc)
    return new_tab
end

function M:getFundData(id)
    if self.m_war_fund_receiced_data == nil then
        return nil
    end
    return self.m_war_fund_receiced_data.fund_quests[tostring(id)]
end

return M