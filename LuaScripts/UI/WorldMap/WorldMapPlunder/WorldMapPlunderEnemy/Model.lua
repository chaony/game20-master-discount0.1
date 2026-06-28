local M = class("WorldMapPlunderEnemyModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
    self:getData("big_map_plunder_station")
end

M.battle_end_data = {}
M.cur_buildingTeam_data = {}

M.m_curGarrison_team = {}

--当前点击的驻地ID
M.cur_building_id = 0

--当前驻地数据
M.cur_Garrison = {}

function M:onEnter()

	self.m_curGarrison_team = {}
    self.battle_end_data = {}
     self.enemyDataList = {}
     self.cur_buildingTeam_data = {}
     self.cur_building_id =  self.m_params.cell_data.obj_id 
     self.cur_Garrison ={}
    self.all_one_key_Herodata = {}
end

function M:refreshPlunderListData( ... )
	
    local show_data = {}
	local map_info_cfg = ConfigManager:getCfgByName("fort_info")
    --local stage_battle_tab = ConfigManager:getCfgByName("stage_battle")
	for k,v in pairs(map_info_cfg) do

		if tonumber(k) == self.m_params.cell_data.obj_id  then
			
            local battle_data = ConfigManager:getCfgStageBattle(v.init_enemy)--stage_battle_tab[v.init_enemy]
            local monsters = battle_data["monster"]
            for k1,v1 in pairs(monsters) do
                local cfg = UserDataManager.hero_data:getHeroConfigByCid(v1.id)
                table.insert(show_data, cfg)
            end
		end
		
	end
    return show_data
end

--筛选出已上阵的英雄
function M:getAllHero(heroIds)
   
    local i, m = 1, #heroIds
    while i <= m do
        local c_d = heroIds[i]
        if self:checkIsSelfHero(c_d) or self:checkIsEqualHero(c_d,heroIds,i) then

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
