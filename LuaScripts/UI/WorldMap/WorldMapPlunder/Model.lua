local M = class("WorldMapPlunderModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
    self:getData("big_map_plunder_station")
end
--驻地列表
M.map_station_data = {}

M.m_open_tab_index = 1



function M:onEnter()
    self.m_sel_tab_index =  nil
    self.m_data_cache = {}
    self.map_station_data = {}
    self.m_open_tab_index = 1
    self.m_curGarrison_team = {}
    self.cur_building_id = 0
    self.cur_Garrison ={}
    self.all_one_key_Herodata = {}
end



function M:refreshPlunderListData(index, force_refresh)
    if force_refresh then
        self.map_station_data = {}
    end
    if self.map_station_data[index] == nil then
        local show_data = {}
        if index == 1 then-- 驻地列表

            local map_event_cfg = ConfigManager:getCfgByName("fort_event")
            
            for k, v in pairs(self.m_data.station_event_list) do
                
                local map_event_cfg_item = map_event_cfg[v.type]
                if map_event_cfg_item then
                    table.insert(show_data, {cfg = map_event_cfg_item, cell_data = v})
                end
            end
        elseif index == 2 then-- 驻地详情
            --驻地详情需要表
            local map_event_cfg = ConfigManager:getCfgByName("fort_info")
            for k, v in pairs(self.m_data.station_list) do
                 local map_event_cfg_item = map_event_cfg[v.building_id]
                table.insert(show_data, {building_id = v.building_id,data = v,cfg = map_event_cfg_item })
            end
            
        end
        self.map_station_data[index] = show_data
    end
    self.m_show_data = self.map_station_data[index] or {}
    return self.m_show_data
end

--筛选出已上阵的英雄
function M:getAllHero(heroIds)
   
    local i, m = 1, #heroIds
    while i <= m do
        local c_d = heroIds[i]
         if self:checkIsSelfHero(c_d)  or self:checkIsEqualHero(c_d,heroIds,i) then

            table.remove(heroIds, i)
            i = i -1
            m = m -1
        end
        i = i +1
    end 
    return heroIds
end


--筛选出d当前驻地已上阵的英雄
function M:getcur_AllHero(heroIds,building_id)
   
    local i, m = 1, #heroIds
    while i <= m do
        local c_d = heroIds[i]
         if self:checkIscur_SelfHero(c_d,building_id)  then

            table.remove(heroIds, i)
            i = i -1
            m = m -1
        end
        i = i +1
    end 
    return heroIds
end

--筛选出相同英雄的战力最高的英雄
function M:getAllEqualsHero(heroIds)
   
    local i, m = 1, #heroIds
    while i <= m do
        local c_d = heroIds[i]
         if self:checkIsEqualHero(c_d,heroIds,i) then

            table.remove(heroIds, i)
            i = i -1
            m = m -1
        end
        i = i +1
    end 
    return heroIds
end


function M:checkIsEqualHero(c_d,heroIds,i)
    local hero_select_Data = UserDataManager.hero_data:getHeroDataById(c_d)
    local local_heros = heroIds
    for k,v in pairs(local_heros) do
        local cur_hero_Data = UserDataManager.hero_data:getHeroDataById(v)
        
        if  hero_select_Data~= nil and hero_select_Data.id  == cur_hero_Data.id then
            if cur_hero_Data.evo  > hero_select_Data.evo then
                return true
            elseif cur_hero_Data.evo  == hero_select_Data.evo then
                if cur_hero_Data.lv > hero_select_Data.lv then
                    return true
                elseif cur_hero_Data.lv  == hero_select_Data.lv then
                    if k > i then
                        return true
                    end
                end
               
                 
            end
           
        end
    end
    return false
end

function M:checkIscur_SelfHero(id,building_id)
    local hero_select_Data = UserDataManager.hero_data:getHeroDataById(id)
    for k,v in pairs(self.cur_Garrison) do

        for k1,v1 in pairs(v) do
            if k1 ~= building_id then
                local cur_hero_Data = UserDataManager.hero_data:getHeroDataById(v1)
                if hero_select_Data ~= nil and hero_select_Data.id  == cur_hero_Data.id then
                    return true
                end
            end
            
        end
       
    end
    return false
end

function M:checkIsSelfHero(id)
    local hero_select_Data = UserDataManager.hero_data:getHeroDataById(id)
    for k,v in pairs(self.cur_Garrison) do

        for k1,v1 in pairs(v) do
            local cur_hero_Data = UserDataManager.hero_data:getHeroDataById(v1)
            if hero_select_Data ~= nil and hero_select_Data.id  == cur_hero_Data.id then
                return true
            end
        end
       
    end
    return false
end

--筛选出战力最高的英雄
function M:getAllHero_atk(heroIds)

    local len = #heroIds
    for i = 1,len-1 do
        for j = 1,len-i do

            local cur_hero_Data = UserDataManager.hero_data:getHeroDataById(heroIds[j])

            local next_hero_Data = UserDataManager.hero_data:getHeroDataById(heroIds[j+1])

            if cur_hero_Data.attrs.atk < next_hero_Data.attrs.atk then
                local temp= heroIds[j+1]

                heroIds[j+1]= heroIds[j]

                heroIds[j]= temp
            end
        end

    end

    return heroIds

end


return M
