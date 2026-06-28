------------ EquipData
local M = {
	m_mystices = {},
    m_ids = {},
    m_type_name = "default",
    m_new_ids = {}, --本次新获得的秘籍（红点用）
    m_inlay_mystics = {}, -- 镶嵌秘籍
}

--[[--
    更新秘籍数据
]]
function M:updateMoreMysticData(data, update)
    if data == nil then return end
    for k,v in pairs(data) do
        self:updateOneMysticData(v, update)
    end
    self:mysticesSortByTypeName()
end

--[[--
    更新单个秘籍数据
]]
function M:updateOneMysticData(data, update)
    if data == nil then return end
    local id = tostring(data.id)
    if self.m_mystices[id] == nil then
        self.m_ids[#self.m_ids + 1] = id
    end
    self.m_mystices[id] = data
    if update then
        -- if self.m_new_ids[oid] == nil then
        --     self.m_new_ids[oid] = 1
        -- end
    end
end

--[[--
    通过id表格移出秘籍数据
]]
function M:removeMoremysticDataById(ids)
    if ids == nil then return end
    for k,v in pairs(ids) do
        self:removeOnemysticDataById(v)
    end
end

--[[--
    通过id移除秘籍数据
]]
function M:removeOnemysticDataById(oid)
    oid = tostring(oid)
    local removeIndex = nil
    for k,v in pairs(self.m_ids) do
        if v == oid then
            removeIndex = k
            break
        end
    end
    if removeIndex ~= nil then
        table.remove(self.m_ids,removeIndex)
        self.m_mystices[oid] = nil
    end
end

--[[
    秘籍排序
]]
function M:mysticesSortByTypeName(type_name)
    self.m_type_name = type_name or self.m_type_name
    self:mysticIdsSort(self.m_ids, self.m_type_name)
end

--[[
    秘籍排序
]]
function M:mysticIdsSort(ids, type_name)
    ids = ids or {}
    type_name = type_name or "default";
    local function sortFunc(id_one, id_two)
        local data1, cfg1 = self:getMysticDataById(id_one)
        local data2, cfg2 = self:getMysticDataById(id_two)
        local cid1, cid2 = data1.id, data2.id
        local quality1, quality2 = cfg1.quality, cfg2.quality
        if type_name == "default" then                           -- 默认排序
            if quality1 == quality2 then
                return cid1 > cid2
            else
                return quality1 > quality2
            end
        else
            return cid1 > cid2
        end
    end
    table.sort(ids, sortFunc)
end

--[[
    获取秘籍列表
]]
function M:getMysticesId()
    return self.m_ids
end

--[[--
    获得秘籍的数量
]]
function M:getMysticesCount()
    return #self.m_ids
end

--秘籍是否在激活列中（后台传来的都是激活的）
function M:containMysticId(id)
    for i, v in pairs(self.m_ids) do
        if v==id then
            return true
        end
    end
    return false
end

--[[--
    获取mystices数据
]]
function M:getMysticesData()
    return self.m_mystices
end

--[[--
    通过id获得mystices数据
    TODO ：之后添加配置的读取
]]
function M:getMysticDataById(oid)
    oid = tostring(oid)

    local data = self.m_mystices[oid]
    local cfg = nil
    if data then
        cfg = self:getMysticConfigByCid(data.id)
        data.star=data.star or 0
    end

    --if cfg == nil and tonumber(oid) ~= 0 then
    --    Logger.logError(oid, "mystic cfg is nil : ")
    --    --GameUtil:sendLuaError("mystic cfg is nil :  " .. oid .. debug.traceback())
    --end
    return data, cfg
end

--[[
    通过配置id获得配置
]]
function M:getMysticConfigByCid(cid)
    if cid == nil then return end
    local mystic_cfg = ConfigManager:getCfgByName("mystic")
    return mystic_cfg[cid]
end


function M:getMysticLvCfg(mystic_id,lv)
    local mystic_cfg = ConfigManager:getCfgByName("mystic_level")
    return mystic_cfg[mystic_id][lv]
end

function M:getMysticStarConfigId(mystic_id,starLv)
    if mystic_id==nil then
        return
    end
    local mystic_star=ConfigManager:getCfgByName("mystic_star")
    if starLv then
        return mystic_star[mystic_id][starLv]
    else
        return mystic_star[mystic_id]
    end
end

-- 秘籍
-- mystics 英雄装备的秘籍
-- 一本秘籍可能有多个buff
function M:getMysticGroup(mystic_Ids,mysticsData)
    local activation_group = {}
    local use_ids = {}
    mystic_Ids = mystic_Ids or {}
    for k,id in pairs(mystic_Ids) do
        use_ids[k] = id
    end
    local mystic_buff_cfg = ConfigManager:getCfgByName("mystic_buff")
    for k, id in pairs(use_ids) do
        if use_ids[k] ~= nil then
            local mystic_data=nil
            if mysticsData~=nil then
                mystic_data=mysticsData[tostring(id)]
            end
            local buff = self:getMysticEfficientSkill(id,mystic_data)
            if buff then
                for m, n in pairs(buff) do -- 单本秘籍的buff列表
                    activation_group[id] = mystic_buff_cfg[n] -- buff表 (目前只考虑单秘籍单buff，buff的id不会增加效果会增加)
                end
            end
        end
    end
    
    return table.values(activation_group), activation_group
end

function M:getMysticBaseAttrsById(id)
    local data = {}
    local mystic_data, mystic_cfg = self:getMysticDataById(id)
    if mystic_data then
        data = mystic_cfg.attrs[mystic_data.star] or {}
    end
    return data
end

function M:clearNewIds()
    self.m_new_ids = {}
end

function M:removeOneNewIds(oid)
    if self.m_new_ids[tostring(oid)] and self.m_new_ids[tostring(oid)] == 1 then
        self.m_new_ids[tostring(oid)] = nil
    end
end

----------------------- 秘籍镶嵌 ---------------------------------------

function M:getAllInlayMysticData()
    return self.m_inlay_mystics
end

function M:updateInlayMysticData(data)
    if data == nil then return end
    for k,v in pairs(data) do
        self.m_inlay_mystics[k] = v
    end
end

function M:removeInlayMysticData(data)
    if data == nil then return end
    for i,v in pairs(data) do
        self.m_inlay_mystics[tostring(v)] = nil
    end
end

function M:getInlayMysticData(id)
    return self.m_inlay_mystics[tostring(id)]
end

function M:getAllInlayMysticData()
    return self.m_inlay_mystics
end

-- 检查秘籍是否可以镶嵌
function M:checkMysticInsetByOid(oid)
    local data = self.m_mystices[oid]
    if data then 
        return self:checkMysticInset(data.id)
    end
    return false
end

function M:checkMysticInset(id)
    --local open_flag = BtnOpenUtil:isBtnOpen(337)
    --if open_flag then
    --    local cfg = self:getMysticConfigByCid(id)
    --    return cfg.set == 1
    --else
    --    return false
    --end
    return false
end

-- 获得秘籍镶嵌所有属性
function M:getMysticInsetAllAttrs(id)
    local show_data = {}
    local mystic_cfg = self:getMysticConfigByCid(id)
    Logger.log(mystic_cfg,"mystic_cfg =====")
    if mystic_cfg then
        local inlay_mystic = self:getInlayMysticData(id)
        for i, v in ipairs(mystic_cfg.inlay_attr) do
            local num = 0
            for ii,vv in pairs(inlay_mystic or {}) do
                if vv.id then
                    if v.condition[1] == 1 then -- 任意品质秘籍
                        local cfg = self:getMysticConfigByCid(vv.id)
                        if cfg.quality >= v.condition[3] then
                            num = num + 1
                        end
                    elseif v.condition[1] == 2 then -- 同类品质秘籍
                        local cfg = self:getMysticConfigByCid(vv.id)
                        if cfg.type == mystic_cfg.type and cfg.quality >= v.condition[3] then
                            num = num + 1
                        end
                    elseif v.condition[1] == 3 then -- 同名秘籍
                        if vv.id == id then
                            num = num + 1
                        end
                    end
                end
            end
            for ii,vv in ipairs(v.attr) do
                table.insert(show_data, {attr = vv, num = num, condition = v.condition, mystic_type = mystic_cfg.type, mystic_name = mystic_cfg.name, type = mystic_cfg.type})
            end
        end
    end
    return show_data
end

-- 获得秘籍镶嵌生效的属性
function M:getMysticInsetEfficientAttrs(id,inlay_mystic_data)
    local attrs = {}
    local mystic_cfg = self:getMysticConfigByCid(id)
    if mystic_cfg then
        local inlay_mystic
        if inlay_mystic_data then
            inlay_mystic = inlay_mystic_data[tostring(id)]
        else
            inlay_mystic = self:getInlayMysticData(id)
        end
        for i, v in ipairs(mystic_cfg.inlay_attr) do
            local num = 0
            for ii,vv in pairs(inlay_mystic or {}) do
                if vv.id then
                    if v.condition[1] == 1 then -- 任意品质秘籍
                        local cfg = self:getMysticConfigByCid(vv.id)
                        if cfg.quality >= v.condition[3] then
                            num = num + 1
                        end
                    elseif v.condition[1] == 2 then -- 同类品质秘籍
                        local cfg = self:getMysticConfigByCid(vv.id)
                        if cfg.type == mystic_cfg.type and cfg.quality >= v.condition[3] then
                            num = num + 1
                        end
                    elseif v.condition[1] == 3 then -- 同名秘籍
                        if vv.id == id then
                            num = num + 1
                        end
                    end
                end
            end
            if num >= v.condition[2] then
                local count = math.floor(num/v.condition[2])
                for ii,vv in ipairs(v.attr) do
                    local attr = table.copy(vv)
                    attr[2] = attr[2] * count
                    table.insert(attrs, attr)
                end
            end
        end
    end
    return attrs
end

-- 获得奥义解放效果
function M:getMysticInsetSkillEffect(id)
    local show_data = {}
    local mystic_cfg = self:getMysticConfigByCid(id)
    if mystic_cfg then
        local inlay_mystic = self:getInlayMysticData(id)
        for i, v in ipairs(mystic_cfg.inlay_view_buff) do
            local num = 0
            for ii,vv in pairs(inlay_mystic or {}) do
                if vv.id then
                    if v.condition[1] == 1 then -- 任意品质秘籍
                        local cfg = self:getMysticConfigByCid(vv.id)
                        if cfg.quality >= v.condition[3] then
                            num = num + 1
                        end
                    elseif v.condition[1] == 2 then -- 同类品质秘籍
                        local cfg = self:getMysticConfigByCid(vv.id)
                        if cfg.type == mystic_cfg.type and cfg.quality >= v.condition[3] then
                            num = num + 1
                        end
                    elseif v.condition[1] == 3 then -- 同名秘籍
                        if vv.id == id then
                            num = num + 1
                        end
                    end
                end
            end
            table.insert(show_data, {des = v.des, num = num, condition = v.condition, mystic_type = mystic_cfg.type, mystic_name = mystic_cfg.name})
        end
    end
    return show_data
end

-- 获得秘籍技能-用于展示
function M:getMysticEfficientSkill(id,mysticData)
    local mystic_data=mysticData
    if mysticData==nil then
        mystic_data=UserDataManager.mystic_data:getMysticDataById(id)
    end

    local starLv= 0
    if mystic_data.star then
        starLv=mystic_data.star
    end
    local mystic_star_cfg = UserDataManager.mystic_data:getMysticStarConfigId(id,starLv)
    --local inset_open = self:checkMysticInset(id)
    if mystic_star_cfg then
        --if inset_open then
        --    local inlay_mystic = self:getInlayMysticData(id)
        --    for i = #mystic_star_cfg.buff, 1 , -1 do
        --        local flag = true
        --        local inlay_buff = mystic_star_cfg.buff[i]
        --        for k, condition in pairs(inlay_buff.condition) do
        --            local num = 0
        --            for ii,v in pairs(inlay_mystic or {}) do
        --                if v.id then
        --                    if condition[1] == 1 then -- 任意品质秘籍
        --                        local cfg = self:getMysticConfigByCid(v.id)
        --                        if cfg.quality >= condition[3] then
        --                            num = num + 1
        --                        end
        --                    elseif condition[1] == 2 then -- 同类品质秘籍
        --                        local cfg = self:getMysticConfigByCid(v.id)
        --                        if cfg.type == mystic_star_cfg.type and cfg.quality >= condition[3] then
        --                            num = num + 1
        --                        end
        --                    elseif condition[1] == 3 then -- 同名秘籍
        --                        if v.id == id then
        --                            num = num + 1
        --                        end
        --                    end
        --                end
        --            end
        --            if num < condition[2] then
        --                flag = false
        --                break
        --            end
        --        end
        --        if flag then
        --            return inlay_buff.buff
        --        end
        --    end
        --end
        return mystic_star_cfg.buff
    end
end

-- 记录等待镶嵌的秘籍，用来做属性变化展示
function M:waitUpMystic(id)
    self.m_wait_inset_attrs = {has_show = {}}
    local inset_attrs = self:getMysticInsetAllAttrs(id)
    if #inset_attrs > 0 then
        self.m_wait_inset_attrs[id] = inset_attrs
    end
    self.m_wait_inset_buff = {}
    self.m_wait_inset_buff[id] = self:getMysticEfficientSkill(id)
end

function M:getWaitUpAttr(id, attr)
    if self.m_wait_inset_attrs and self.m_wait_inset_attrs.has_show[attr.attr[1]] ~= true then
        if self.m_wait_inset_attrs[id] then
            local old = self.m_wait_inset_attrs[id]
            for i,v in pairs(old) do
                if v.attr[1] == attr.attr[1] then
                    local old_count = math.floor(v.num/v.condition[2])
                    local new_count = math.floor(attr.num/attr.condition[2])
                    self.m_wait_inset_attrs.has_show[attr.attr[1]] = true
                    return old_count < new_count
                end
            end
        else
            local new_count = math.floor(attr.num/attr.condition[2])
            self.m_wait_inset_attrs.has_show[attr.attr[1]] = true
            return new_count > 0
        end
    end
end

function M:getWaitUpBuff(id)
    local buff = self:getMysticEfficientSkill(id)
    if self.m_wait_inset_buff[id] then
        return self.m_wait_inset_buff[id][1] ~= buff[1]
    elseif buff then
        if buff[1] then
            return true
        end
    end
end

return M