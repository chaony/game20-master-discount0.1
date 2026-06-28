---@class AdditionSupportSystemModel:OODataBase
local M = class("AdditionSupportSystemModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData("hero_help_index")
end

function M:onEnter()
    self.supported_hero_oids=self.m_data.pos_heros

    self:switchTag(1)

    --已经使用的数目
    self.usageNum=self:getUsageNum()
    --已经解锁的上限
    self.unlockNum=self.m_data.open_pos_num
    self.selectType_index=1
    self.unlcokMaxNum=30
end

function M:getUsageNum()
    self.pos_heros=self.m_data.pos_heros
    local usageNum=0
    for race, heros in pairs(self.pos_heros) do
        local num=table.nums(heros)
        if num>0 then
            usageNum=usageNum+num
        end
    end
    return usageNum
end

function M:updateData(data)
    self.m_data=data

    local pos_heros=self.m_data.pos_heros
    local help_heros={}
    for race, hero_oids in pairs(pos_heros) do
        for i, oid in pairs(hero_oids) do
            table.insert(help_heros,oid)
        end
    end
    UserDataManager.help_heros=help_heros
    self:update_usage_num()
end

function M:update_usage_num()
    self.usageNum=self:getUsageNum()
end

function M:switchTag(tag)
    self.m_race_oids =self.m_data.pos_heros[tostring(tag)] or {}
    self.m_race_id=tag
end

function M:getCurTagOids()
    local race_oids=self.m_data.pos_heros[tostring(self.m_race_id)] or {}
    local oids=table.copy(race_oids)
    return oids
end

function M:changeTagOids()

end

function M:setCurOpPos(pos)
    self.m_curOpPos=pos
end

function M:setCurOpRace(race)
    self.m_cur_Op_Race=race
end

--有空位置
function M:isVacant()
  return self.usageNum<self.unlockNum
end

return M

 
