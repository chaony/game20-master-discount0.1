local M = class("UnionWarDetailsModel", LikeOO.OODataBase)

function M:onCreate()
    self.m_transfer = "scale"
    M.super.onCreate(self)
    self:getData()    
end

function M:onEnter()
    self.m_data = self.m_params.data   
    self.m_index = self.m_params.index
    self.m_owner = self.m_params.owner
end

function M:getShowData()
    local show_data = {}
    show_data.team_num = self.m_data.team_num
    show_data.combat = self.m_data.combat
    local team_info =  self.m_data.team_info or {}
    local self_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
    for i, team_data in ipairs(team_info) do
        local team = team_data.team or {}
        local heros = team_data.heros or {}
        local team_heros_data = {}
        local total_combat = 0
        local showRecall = false
        for index = 1,5 do
            local hero_id = team[index] or ""
            local hero_data = heros[hero_id]
            local data = nil            
            if hero_data then
                data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
                data.quality = hero_data.evo
                data.card_id = hero_id
                data.hero_data = hero_data
                total_combat = total_combat + (hero_data.combat or 0)
            end
            team_heros_data[index] = data or {}            
        end
        if self_uid == team_info[i].user.uid and team_info[i].team_id then
            showRecall = true
        end        
        show_data[i] = {team_heros_data = team_heros_data, total_combat = total_combat, user = team_info[i].user, showRecall = showRecall, team_id = team_info[i].team_id}
    end
    
    --sort
    local index = 1
    for k = 1, #show_data do 
        local temp_data = {}
        if show_data[k].user.uid == self_uid then
            temp_data = show_data[index]
            show_data[index] = show_data[k]
            show_data[k] = temp_data
            index = index + 1
        end
    end 
    
    return show_data
end

return M