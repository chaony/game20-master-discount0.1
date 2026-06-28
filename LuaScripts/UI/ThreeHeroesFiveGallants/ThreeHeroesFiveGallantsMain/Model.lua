local M = class("ThreeHeroesFiveGallantsMainModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self.m_is_token = self.m_params.is_token or false
    self:getData("chivalrous_index")
end

local ACTIVE_TAB = {
    {id = 1, btn_name = "three_heroes_five_gallants_text_0007",open_id = 387}, 	--猫鼠游戏
    {id = 2, btn_name = "three_heroes_five_gallants_text_0008",open_id = 386}, 	--前尘往事
    {id = 3, btn_name = "three_heroes_five_gallants_text_0009",open_id = 388}, 	--江湖行侠
    {id = 4, btn_name = "three_heroes_five_gallants_text_0010",open_id = 389}, 	--侠义献礼
    {id = 5, btn_name = "three_heroes_five_gallants_text_0010",open_id = 346}, 	--花落谁家
}

function M:onEnter()
    self.open_id = 385
end

function M:netData(data, tag)
    table.merge(self.m_data, data or {})
end


--获取活动数据
function M:getActiveData(open_id)
    local id = self.open_id
    if open_id then
        id = open_id
    end
    local active_tab = ConfigManager:getCfgByName("active")
    for i, v in pairs(active_tab) do
        if v.open_id == id then
            return v
        end
    end
    return nil
end

--获取活动信息
function M:getActiveTab()
    local active_tab = {}
    local open_condition = ConfigManager:getCfgByName("open_condition")
    for i, v in ipairs(ACTIVE_TAB) do
        local params = {id = v.id,open_id = v.open_id,btn_name = open_condition[v.open_id].name}
        table.insert(active_tab,params)
    end
    return active_tab
end

--获取活动version
function M:getActVsn(open_id, is_recharge)
    open_id = open_id or 339
    local active = nil
    if is_recharge then
        active = UserDataManager:getActivesRechargeDataByOpenId(open_id)
    else
        active = UserDataManager:getActivesDataByOpenId(open_id)
    end
    if active and active.version then
        return active.version
    end
    return 1
end

--获取活动table
function M:getAllActiveTab()
    return ACTIVE_TAB
end

--获取前尘往事是否有奖励未领取
function M:getStoreReward()
    local chivalrous_reward = ConfigManager:getCfgByName("chivalrous_reward")
    local chivalrous_camp = ConfigManager:getCfgByName("chivalrous_camp")
    if self.m_data.cur_camp == 0 then
        return false
    end
    local method_id = chivalrous_camp[1][self.m_data.period][self.m_data.cur_camp].method or 1001
    local rewards = chivalrous_reward[method_id][3]
    for i, v in pairs(rewards) do
        if not self:getRewardIsReceive(i) and v.parameter <= self.m_data.self_score then
            return true
        end
    end
    return false
end

--获取是否领取过奖励
function M:getRewardIsReceive(id)
    for i, v in pairs(self.m_data.recv_chivalrous) do
        if v == id then
            return true
        end
    end
    return false
end

return M
