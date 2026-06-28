local M = class("TalisManmentListModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
    --self.m_transfer = "scale"
    self:getData()
end

function M:onEnter()
	self.m_selected_id = self.m_params.heroid
    self.m_select_cell_object = nil
    self.m_select_cell_index = 1
    self.m_select_cell_data = nil
    self.pos = self.m_params.pos
    self.m_open_id = 773
    self.is_refresh_effet = false
    self.lock_num = 0
  
end


--当前选中英雄信息
function M:getSelectHeroData()
    --if self.m_mode == 3 then --其他玩家的英雄
    --    local heros = self.m_look_heros or {}
    --    local data = heros[self.m_selected_id]
    --    local cfg = UserDataManager.hero_data:getHeroConfigByCid(data.id)
    --    --data.clv = data.lv
    --    return data, cfg
    --else
    --    if self.m_hero_list_type == 1 then
            return self:getHero(self.m_selected_id)
        --else
            --return self:getHeroCfg(self.m_select_book_id)
        --end
    --end
end

--获取英雄符篆列表 
function M:getHeroTalinsManList()
    local h_data, h_cfg = self:getSelectHeroData()
    return h_data.seal_character or {}
end

function M:getHero(id)
    local  data, cfg = UserDataManager.hero_data:getHeroDataById(id)
    return data, cfg
end

function M:getHeroCfg(id)
    local cfg = UserDataManager.hero_data:getHeroConfigByCid(id)
    return cfg
end

function M:getCurrentTalinsDataByPos(index)
    local h_data, h_cfg = self:getSelectHeroData()
    local equips = h_data.seal_character or {}
    return equips[tostring(index)]
end

function M:getTalisSuitConfigByCid(cid)
    local talis_detail = ConfigManager:getCfgByName("seal_character_suit")
    return talis_detail[cid]
end

function M:getTalisConfigByCid(cid)
    local talis_detail = ConfigManager:getCfgByName("seal_character_team")
    return talis_detail[cid]
end

--获取共鸣效果 
function M:getHeroTalinsEfeectNum()
    local curNum = 0
    local allNum = 4
    local cfg = ConfigManager:getCfgByName("seal_character_suit")
    local data = self:getCurrentTalinsDataByPos(self.pos)
    local team_id = cfg[data.id].team
    local quaily_id = cfg[data.id].quality
    local talinsData = self:getHeroTalinsManList()
    local aar= {}
    for k,v in pairs(talinsData) do
        local t_id = cfg[v.id].team
        local q_id =cfg[v.id].quality
        if t_id == team_id and quaily_id == q_id then
            curNum = curNum + 1
        end
    end
    for k,v in pairs(talinsData) do
        local t_id = cfg[v.id].team
        local q_id =cfg[v.id].quality
        if aar[v.id] == nil then
            --aar[v.id].team_id = team_id
            --aar[v.id].quaily_id = quaily_id
            aar[v.id] = {team_id = t_id,quaily_id = q_id,num = 1}
        else
            aar[v.id].num = aar[v.id].num + 1
        end
    end
    return curNum,allNum
end

--获取共鸣效果 
function M:getHeroTalinsEfeectNumFail(id)
    local curNum = 1
    local allNum = 4
    local cfg = ConfigManager:getCfgByName("seal_character_suit")
    local team_id = cfg[id].team
    local quaily_id = cfg[id].quality
    local talinsData = self:getHeroTalinsManList()
    for k,v in pairs(talinsData) do
        local t_id = cfg[v.id].team
        local q_id =cfg[v.id].quality
        if t_id == team_id and quaily_id == q_id  then
            curNum = curNum + 1
        end
    end
    --local 
    --local own_id =  talinsData[tostring(self.pos)].id
    --if id == team_id2 and quaily_id2 == cfg[own_id].quality then
    --    curNum = curNum - 1 >=0 and curNum - 1 or 0
    --end
    --p抛出自己
    local data = self:getCurrentTalinsDataByPos(self.pos)
    if data then
        local team_id2 = cfg[data.id].team
        local quaily_id2 = cfg[data.id].quality
        if team_id2 == cfg[id].team and quaily_id2 == cfg[id].quality then
            curNum = curNum - 1 >=0 and curNum - 1 or 0
        end
    end
    return curNum,allNum
end

-- 品质 位置 team_id  当前属性值
function M:getCurrentLimitbyId(quaily_id,pos,team_id,value)
    value = value or 0
    local currentValue = 0
    local AllValue = 1
    local curValue = 0
    local maxValue = 1
    local cfg = ConfigManager:getCfgByName("seal_character")
    if cfg then
        local qusliyData = cfg[quaily_id]
        if qusliyData then
            local posData = qusliyData[pos]
            for i,v in pairs(posData) do 
                if team_id == v.team_id then
                    local limit = v.limit
                    currentValue =limit[1]
                    AllValue =limit[2]
                end
            end
        end
    end
    curValue = value - currentValue
    maxValue = AllValue - currentValue
    if curValue <= 0 then
        curValue= 1
        maxValue = 100
    end
    return curValue,maxValue
end

--value 当前属性值  type 部位 id 属性id  
function M:getCurrentPropertyTextColor(value,pos,id)
    local cfg = ConfigManager:getCfgByName("seal_grade")
    local common = ConfigManager:getCfgByName("common")
    local arr = common[self.m_open_id].value
    local currentValue = 0
    local allValue = 1
    local quaily_index = 1 --品阶
    if cfg then
        for k,v in ipairs(cfg) do
            if v.type == pos and v.hero_enumaration ==id then
                currentValue = v.limit[1] or 0
                allValue = v.limit[2] or 1
            end
        end
        local probability = value/allValue 
        for m,n in ipairs(arr) do
            if probability < n[1] and probability >= arr[(m-1)>1 and m-1 or 1][1] then
                quaily_index =arr[(m-1)>1 and m-1 or 1][2]
            end
        end
    end
    return GlobalConfig.FUZHUAN_GRADE_COLOR[quaily_index]
end

-- 获取当前属性
function M:getCurrentAttrs(attrs)
    local show_attrs = {}
    for k,v in pairs(attrs) do
        if #v > 1 then
            local key = GameUtil:getAttrsKey(v[1])
            local atr_data = GameUtil:getAttrCfg(v[1])
            if atr_data.is_percent and  atr_data.is_percent == 1 then
                show_attrs[key] = v[2] * 100
            elseif key == "rageregenper" then --特殊处理内力回复
                show_attrs[key] = v[2] * 100
            else
                show_attrs[key] = v[2]
            end
        end
    end
    local data = {}
    for i, v in pairs(show_attrs) do
        table.insert(data, {i, {cur_num = v}})
    end
    table.sort(data,function(data1,data2)
        local id = GameUtil:getAttrsId(data1[1])
        local id2 = GameUtil:getAttrsId(data2[1])
        return tonumber(id)<tonumber(id2);
    end)
    return data[1]
end
--获取进度上下限制
function M:getSliderLimit(quaily_id,pos,team_id,id)
    local currentValue = 0
    local AllValue = 1
    local cfg = ConfigManager:getCfgByName("seal_character")
    local cfg2 = ConfigManager:getCfgByName("seal_grade")
    if cfg then
        local qusliyData = cfg[quaily_id]
        if qusliyData then
            local posData = qusliyData[pos]
            for i,v in pairs(posData) do
                if team_id == v.team_id then
                    local limit = v.limit
                    currentValue =limit[1]
                    AllValue =limit[2]
                    for m,n in ipairs(cfg2) do
                        if n.type == pos and n.hero_enumaration ==id then
                            if n.decimal == 1 then
                                currentValue= currentValue * 100
                                AllValue = AllValue * 100
                            end
                        end
                    end
                end
            end
        end
    end
    return currentValue,AllValue
end

--获取符篆数据
function M:getTalisData()
    return UserDataManager.talis_data:getTalisData() or {}
end

--获取符篆数据
function M:getTalisDataNumber()
    return #UserDataManager.talis_data:getTalisData() or {}
end

function M:getTalisDataById(id)
    return UserDataManager.talis_data:getTalisDataById(id) 
end

return M
