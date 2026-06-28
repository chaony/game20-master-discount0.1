---@class XiakedaoModel:OODataBase
local M=class("XiakedaoModel",LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData("hero_isle_index")
end

function M:onEnter()

    local data=self.m_data
    self.m_data.layer=self.m_data.layer+1
    --self.m_data.layer=105
    self.m_lose_num=self.m_data.lose_num

    self:refreshCurTop3RankData(self.m_data)
    self.season_id=self.m_data.season
    local hero_isle_visitor_cfg=ConfigManager:getCfgByName("hero_isle_visitor")
    self.hero_isle_visitor_cfg_item=hero_isle_visitor_cfg[self.season_id]
    if self.hero_isle_visitor_cfg_item==nil then
        self.hero_isle_visitor_cfg_item=hero_isle_visitor_cfg[-1]
    end

    local hero_isle_layer=ConfigManager:getCfgByName("hero_isle_layer")
    self.maxLayer=table.nums(hero_isle_layer)
end

function M:refreshCurTop3RankData(data)
    self.m_top3_ranks={}
    for i = 1, 3 do
        if data.ranks[1] then
            self.m_top3_ranks[i]=data.ranks[1]
            table.remove(data.ranks,1)
        end
    end
end


function M:getCurTop3RankData()
    return self.m_top3_ranks
end

return M
