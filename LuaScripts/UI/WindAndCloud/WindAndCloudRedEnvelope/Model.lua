---@class WindAndCloudRedEnvelopeModel: OODataBase
local M = class("WindAndCloudRedEnvelopeModel", LikeOO.OODataBase)


function M:onCreate()
    self.open_id = self.m_params.open_id or 407
    self.m_active_data = UserDataManager:getActivesDataByOpenId( self.open_id)
    self.m_version = self.m_active_data.version or 1
    --self.show_tab_max_num = self.m_version --最大可展示的页签
    --self.current_show_tab_num = self.m_version --当前展示的页签
    --self.m_activityData = UserDataManager:getActivesDataByOpenId(self.m_openId)
    --self:getData("active_diamond_rebate_ranks", {open_id = self.open_id,version = self.m_version,start = 1, stop = 10})
    self:getData("redbag_index",{open_id =self.open_id,vsn = self.m_version,start = 1,stop = 10})
end


function M:onEnter()
    self.vsn_data = self.m_data.vsn_data
    self.m_current_open_times = self.vsn_data and self.vsn_data.draw_times or 0
    --self.m_all_open_times = self.vsn_data.draw_grt or 0
    local cfg = ConfigManager:getCfgByName("redbag_draw")
    self.m_count = self.m_data.rank_info.count or 0
    --self.m_count = 20
    self.m_total_rank_data = {}
    self.own_data = {}
    self.m_all_open_times = cfg and cfg[self.open_id][self.m_version].basic or 1000
    self:insertRankData(self.m_data.rank_info.ranks,self.m_data.rank_info)
    --自己排行数据
    
    
end

function M:getGachaShipRewards(reward_type)
    reward_type = reward_type or 0
    local show_data = {}
    local gacha_ship_cfg = ConfigManager:getCfgByName("redbag_reward")
    local real_cfg = gacha_ship_cfg[ self.open_id][self.m_version] or {}
    for k, v in pairs(real_cfg) do
        table.insert(show_data, {sort = v.sort,show = v.show,reward = v.reward, id = k, weight = v.show_weight, cfg = v })
    end
    table.sort(show_data, function(data1,data2)
        return data1.id < data2.id
    end)
    if reward_type ~= 0 then 
        local data = {}
        for k,v in pairs(show_data) do 
            if v.show == reward_type then 
                table.insert(data,v)
            end
        end
        table.sort(data, function(data1,data2)
            return data1.id < data2.id
        end)
        return data
    end
    return show_data
end

function M:showFourListData()
    table.sort(self.m_total_rank_data,function(a,b)
        return a.rank < b.rank
    end)
    return self.m_total_rank_data
end

function M:getOwnItem()
    return self.own_data
end

function M:getLoadIndex()
    local max_rank_count = self.m_count
    local cur_rank_nums = table.nums(self:showFourListData())
    local start_pos, end_pos = 0, 0
    if cur_rank_nums + 10 <= max_rank_count then
        start_pos = cur_rank_nums + 1
        end_pos = cur_rank_nums + 10
    elseif max_rank_count - cur_rank_nums > 0 then
        start_pos = cur_rank_nums + 1
        end_pos = max_rank_count
    end
    return start_pos, end_pos
end


function M:insertRankData(new_rank_data,rank_info)
    for i = 1, #new_rank_data do
        table.insert(self.m_total_rank_data, new_rank_data[i])
    end
    self.own_data = {rank = rank_info.rank or 0,score = rank_info.score,user=rank_info.user_info}
end

function M:getOpenTimes()
    --local data = {}
    --local cfg = ConfigManager:getCfgByName()
    --local data = {[1]=100,[2]=300,[3]=500,[4]=1000}
    --for i =1,#data do 
    --    if self.m_current_open_times <data[i] then
    --        self.m_all_open_times = data[i]
    --        break
    --    end
    --end
    --if self.m_current_open_times>= data[#data] then
    --    self.m_all_open_times = data[#data]
    --end
    return self.m_current_open_times,self.m_all_open_times
end

function M:updateTimes(response)
    self.m_current_open_times = response and response.draw_times or self.m_current_open_times
end

return M
