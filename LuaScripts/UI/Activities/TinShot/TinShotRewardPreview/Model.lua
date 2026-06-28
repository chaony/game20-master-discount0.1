local M = class("TinShotRewardPreviewModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
    self.m_transfer = "scale"
    self:getData()
end

function M:onEnter()
    self.m_floor = self.m_params.floor or 1
    self.m_version = self.m_params.version or 1
    self.m_select_big_id = self.m_params.big_gift_id or 0
    self.m_big_rcvd = self.m_params.big_rcvd or {}
    self.m_is_tongyong = self.m_params.tongyong or false
end

function M:refreshData(data)

end

function M:getBigReward()
    local scroll_tab = ConfigManager:getCfgByName("spring_festival_gacha")
    local scroll_list = scroll_tab[self.m_version]
    local new_tab = {}
    for i, v in pairs(scroll_list) do
        local cur_scroll = scroll_list[i]
        table.insert(new_tab, {cfg = cur_scroll, sort = i})
    end
     table.sort(new_tab,function(data1,data2)
         return data1.sort < data2.sort
     end)
    return new_tab
end

function M:getTongYongBigReward()
    local scroll_tab = ConfigManager:getCfgByName("tongyong_gacha")
    local scroll_list = scroll_tab[self.m_version]
    local new_tab = {}
    for i, v in pairs(scroll_list) do
        local cur_scroll = scroll_list[i]
        table.insert(new_tab, {cfg = cur_scroll, sort = i})
    end
     table.sort(new_tab,function(data1,data2)
         return data1.sort < data2.sort
     end)
    return new_tab
end

return M
