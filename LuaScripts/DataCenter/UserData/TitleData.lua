------------ TitleData
local M = {
	m_titles = {},
    m_titles_package = {},
    m_ids = {},
    m_type_name = "default",
    m_new_ids = {}, --本次新获得的称号（红点用）
}

--[[--
    更新秘籍数据
]]
function M:updateMoreTitleData(data, update)
    if data == nil then return end
    for k,v in pairs(data) do
        v.id = k
        self:updateOneTitleData(v, update)
    end
    self:titlesSort(self.m_ids)
end

--[[--
    更新一种多个称号的数据
]]
function M:updateMoreTitlePackageData(data)
    if data == nil then return end
    for k,v in pairs(data) do
        self.m_titles_package[tonumber(k)] = v
    end
end

--[[--
    更新单个秘籍数据
]]
function M:updateOneTitleData(data, update)
    if data == nil then return end
    local id = tostring(data.id)
    if self.m_titles[id] == nil then
        self.m_ids[#self.m_ids + 1] = id
    end
    self.m_titles[id] = data
    if update then
        -- if self.m_new_ids[id] == nil then
        --     self.m_new_ids[id] = 1
        -- end
    end
end

--[[--
    通过id表格移出秘籍数据
]]
function M:removeMoreTitleDataById(ids)
    if ids == nil then return end
    for k,v in pairs(ids) do
        self:removeOneTitleDataById(v)
    end
end

--[[--
    删除一种多个称号的数据
]]
function M:removeMoreTitlePackageDataById(ids)
    if ids == nil then return end
    for k,v in pairs(ids) do
        self.m_titles_package[v] = nil
    end
end

--[[--
    通过id移除秘籍数据
]]
function M:removeOneTitleDataById(id)
    id = tostring(id)
    local removeIndex = nil
    for k,v in pairs(self.m_ids) do
        if v == id then
            removeIndex = k
            break
        end
    end
    if removeIndex ~= nil then
        table.remove(self.m_ids,removeIndex)
        self.m_titles[id] = nil
    end
end

--[[
    称号排序
]]
function M:titlesSort(ids)
    ids = ids or {}
    local function sortFunc(id_one, id_two)
        local data1, cfg1 = self:getTitleDataById(id_one)
        local data2, cfg2 = self:getTitleDataById(id_two)
        local cid1, cid2 = data1.id, data2.id
        local order1, order2 = cfg1.order, cfg2.order
        if order1 == order2 then
            return cid1 > cid2
        else
            return order1 < order2
        end
    end
    table.sort(ids, sortFunc)
end

--[[
    获取称号列表
]]
function M:getTitlesId()
    return self.m_ids
end

--[[--
    获得称号的数量
]]
function M:getTitlesCount()
    return #self.m_ids
end

--[[--
    获取称号数据
]]
function M:getTitlesData()
    return self.m_titles
end

--[[--
    获取一种多个称号的数据
]]
function M:getTitlePackagesData()
    return self.m_titles_package
end

--[[--
    通过id获得称号数据
    TODO ：之后添加配置的读取
]]
function M:getTitleDataById(id)
    id = tostring(id)
    local data = self.m_titles[id]
    local cfg = nil
    if data then
        cfg = self:getTitleConfigById(data.id)
    end
    if cfg == nil and tonumber(id) ~= 0 then
        Logger.logError(id, "title cfg is nil : ")
    end
    return data, cfg
end

--[[--
    通过id获得称号数据
    TODO ：之后添加配置的读取
]]
function M:getTitlePackageDataById(id)
    id = tonumber(id)
    local count = self.m_titles_package[id]
    local data
    local cfg = nil
    if count then
        cfg = self:getTitleConfigById(id)
        data = {id = id}
    end
    if cfg == nil and tonumber(id) ~= 0 then
        Logger.logError(id, "title cfg is nil : ")
    end
    return data, cfg
end

--[[--
    通过id获得一种多个称号的数据
]]
function M:getTitlePackageCountById(id)
    return self.m_titles_package[id] or 0
end

-- 获取称号收集属性
function M:getTitlesCollectAttrs()
    local attrs = {}
    for i, v in pairs(self.m_ids) do
        local data, cfg = self:getTitleDataById(v)
        table.insertto(attrs, cfg.attr1)
    end
    return attrs
end

-- 获取称号穿戴属性
function M:getTitleWearAttrs()
    local attrs = {}
    local title_id = UserDataManager.user_data:getUserStatusDataByKey("title")
    if title_id and title_id ~= 0 then
        local data, cfg = self:getTitleDataById(title_id)
        attrs = cfg.attr2
    end
    return attrs
end

--[[
    通过配置id获得配置
]]
function M:getTitleConfigById(id)
    local title_cfg = ConfigManager:getCfgByName("title")
    return title_cfg[tonumber(id)]
end

function M:clearNewIds()
    self.m_new_ids = {}
end

function M:removeOneNewIds(oid)
    if self.m_new_ids[tostring(oid)] and self.m_new_ids[tostring(oid)] == 1 then
        self.m_new_ids[tostring(oid)] = nil
    end
end

return M