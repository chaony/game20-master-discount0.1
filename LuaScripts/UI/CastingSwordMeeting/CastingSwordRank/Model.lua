---@class CastingSwordRankModel: OODataBase
local M = class("CastingSwordRankModel", LikeOO.OODataBase)

function M:onCreate()
    self.m_is_token = self.m_params.is_token or false
    self:getData("item_score_index")
end

function M:onEnter()
    self.active_id = self.m_data.active_id
    self.version =  self.m_data.version
    self.current_show_tab_num = 1 --默认进入活动展示展示排行榜
    --[[
    self.m_items = {{active_id = -1, open_id = -1,btn_name = "item_1_btn",btn_txt_name = "item_1_btn_text",item_value = ""},
                    {active_id = -1, open_id = -1,btn_name = "item_2_btn",btn_txt_name = "item_2_btn_text",item_value = ""},
                    {active_id = -1,open_id = -1, btn_name = "item_3_btn",btn_txt_name = "item_3_btn_text",item_value = ""},
                    {active_id = -1, open_id = -1,btn_name = "item_4_btn",btn_txt_name = "item_4_btn_text",item_value = ""},}
    for k, v in pairs(self.m_data.active_ids) do
        local item = self:getActiveData(v)
        if item ~= nil then
            self.m_items[k].active_id = v
            self.m_items[k].open_id = item.open_id
            self.m_items[k].item_value = item.name
        end
    end
    ]]--
    self:refreshRankData(self.m_data)
    self:getRewardInfo()
end

function M:netData(data, tag)
    table.merge(self.m_data, data or {})
    --self:refreshRankData(self.m_data)
end

function M:getAllItem()
    return self.m_items
end

function M:getItem(btn_name)
    for k, v in pairs(self.m_items) do
        if btn_name == v.btn_name then
            return v
        end
    end
    return nil
end

function M:getTokenFlag()
    return self.m_is_token
end

--设置当前显示页签id
function M:setSelectIndex(index)
    self.current_show_tab_num = index
end

--刷新排行榜数据
function M:refreshRankData(m_data)
    self.roleRankData = m_data.ranks
    self.roleRankCount = m_data.count
    if self.roleRankCount > 0 and table.nums(self.roleRankData) > 0 then
        table.sort(self.roleRankData, function(itemData1, itemData2) return itemData1.rank < itemData2.rank end)
    end
    self.myInfoData = {
        rank = m_data.rank,
        score = m_data.score,
    }
end

--获取活动数据
function M:getActiveData(active_id)
    local id = self.active_id
    if active_id then
        id = active_id
    end
    local active_tab = ConfigManager:getCfgByName("active")
    if active_tab[id] ~= nil then
        return active_tab[id]
    end
    local active_recharge_tab = ConfigManager:getCfgByName("active_recharge")
    if active_recharge_tab[id] ~= nil then
        return active_recharge_tab[id]
    end
    return nil
end

--获取排名奖励
function M:getRewardInfo()
    self.rank_rewards = {}
    local favor_rank = ConfigManager:getCfgByName("item_score_rank")
    if favor_rank[self.version] then
        self.rank_rewards = favor_rank[self.version]
    end
end

--获取spine信息
function M:getSkinData()
    local hero_skin = ConfigManager:getCfgByName("hero_skin")
    return hero_skin[self.m_data.hero_skin] or {}
end

--获取活动名称
function M:getRankTittle()
    return self.m_data.title
end

return M