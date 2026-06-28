------------ ArtifactData
local M = {
	m_artifacts = {},
    m_ids = {},--神器id对应表
    m_type_name = "default",-- 排序类型
}

--[[--
    更新神器数据
]]
function M:updateArtifactData(data)
    if data == nil then return end
    for k,v in pairs(data) do
        self:updateOneArtifactData(v)
    end
    self:artifactSortByTypeName()
end

--[[--
    更新单个神器数据
]]
function M:updateOneArtifactData(data)
    if data == nil then return end
    local oid = tostring(data.oid)
    if self.m_artifacts[oid] == nil then
        self.m_ids[#self.m_ids + 1] = oid
    end
    self.m_artifacts[oid] = data
end

--[[--
    通过id表格移出神器数据
]]
function M:removeMoreArtifactDataById(ids)
    if ids == nil then return end
    for k,v in pairs(ids) do
        self:removeOneArtifactDataById(v)
    end
end

--[[--
    通过id移除神器数据
]]
function M:removeOneArtifactDataById(oid)
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
        self.m_artifacts[oid] = nil
    end
end

--[[
    神器排序
]]
function M:artifactSortByTypeName(type_name)
    self.m_type_name = type_name or self.m_type_name
    self:equipIdsSort(self.m_ids, self.m_type_name)
end

--[[
    神器排序
]]
function M:equipIdsSort(ids, type_name)
    ids = ids or {}
    type_name = type_name or "default";
    local function sortFunc(id_one, id_two)
        local data1, cfg1 = self:getArtifactDataById(id_one)
        local data2, cfg2 = self:getArtifactDataById(id_two)
        local cid1, cid2 = data1.id, data2.id
        local lv1, lv2 = data1.lv, data2.lv
        if type_name == "default" then                           -- 默认排序
            if lv1 == lv2 then
                return cid1 > cid2
            else
                return lv1 > lv2
            end
        else
            return cid1 > cid2
        end
    end
    table.sort(ids, sortFunc)
end

--[[
    获取神器id列表
]]
function M:getEquipsId()
    return self.m_ids
end

--[[--
    获得神器的数量
]]
function M:getEquipsCount()
    return #self.m_ids
end

--[[--
    获取神器数据
]]
function M:getEquipsData()
    return self.m_artifacts
end

--[[--
    通过id获得equip数据
    TODO ：之后添加配置的读取
]]
function M:getArtifactDataById(oid)
    oid = tostring(oid)
    local data = self.m_artifacts[oid]
    local cfg = nil
    if data then
        cfg = self:getArtifactConfigByCid(data.id)
    end
    return data, cfg
end

--[[
    通过配置id获得神器配置
]]
function M:getArtifactConfigByCid(cid)
    cid = tonumber(cid)
    local artifact_detail = ConfigManager:getCfgByName("artifact")
    return artifact_detail[cid]
end

return M