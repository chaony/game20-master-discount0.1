local M = class("GuildHighWarSettlementPopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "left_btn" then 
        self.m_model.m_current_index =1
        self.m_view:refreshUI()
    elseif msg == "right_btn" then
        self.m_model.m_current_index =2
        self.m_view:refreshUI()
    elseif msg == "paihang_btn" then
        --local function netCallback(response)
        --    self.m_model.m_guild_info = response.guild_info
        --    self.m_model.m_city_data = response.citys
        --    self:openView("GuildHighWar.GuildHighWarRankList",{rank_sort = 1,total_city_data = self.m_model.m_city_data,
        --                                                       total_guild_data = self.m_model.m_guild_info ,
        --                                                       big_stage = self.m_model.big_stage,playoff_type = self.m_model.playoff_type})
        --end
        --self.m_model:getNetData("guild_high_war_battlefield", nil, netCallback)
        self:openView("GuildHighWar.GuildHighWarRankList",{rank_sort = 1,total_city_data = self.m_model.m_city_data,
                                                           total_guild_data = self.m_model.m_guild_info ,
                                                           big_stage = self.m_model.big_stage,playoff_type = self.m_model.playoff_type})
    elseif msg == "Image_rank1" then
        self:openPlayer(1)
    elseif msg == "Image_rank2" then 
        self:openPlayer(2)
    elseif msg == "Image_rank3" then
        self:openPlayer(3)
    elseif msg == "own_btn1" then
        self:openOwnPlayer(1)
    elseif msg == "own_btn2" then
        self:openOwnPlayer(2)
    elseif msg == "own_btn3" then
        self:openOwnPlayer(3)
    end
end

function M:openPlayer(index)
    local data = self.m_model:GetEndGuildRank()
    if data[index] then
        self:openView("Pops.PlayerInfo", {uid = data[index].user.uid})
    end
end

function M:openOwnPlayer(index)
    local data = self.m_model:GetEndSelfRank()
    if data[index] then
        self:openView("Pops.PlayerInfo", {uid = data[index].user.uid})
    end
end
return M
