--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-06-02 21:03:08
]]

---@class TablePoolUtil @
local M = class("TablePoolUtil")

--0 默认 {}
--1 FixVector3
function M:init()
    --实际的表池
    if self.table_pool == nil then
        self.table_pool = {}
    else
        for i, v in pairs(self.table_pool) do
            self.table_pool[i] = nil
        end
    end

    if self.table_pool_temp == nil then
        self.table_pool_temp = {}
    else
        for i, v in pairs(self.table_pool_temp) do
            self.table_pool_temp[i] = nil
        end
    end

    if self.table_len_max == nil then
        self.table_len_max = {}
    else
        for i, v in pairs(self.table_len_max) do
            self.table_len_max[i] = nil
        end
    end
   
    --临时的表池
    self:register(1,0);
    self:register(2,0);
    self.registerFinish = 1;
end


--一开始注册对象
function M:register( key, count )
    if self.table_pool[key] == nil then
        self.table_pool[key] = {}
    end
    if count > 0 then
        for i=1,count do
            self:addItem( key )
        end
    end
    self.table_len_max[key] = count;
end


--向表中加入一个对象
function M:addItem( key )
    local item = self:getItem(key)
    table.insert(self.table_pool[key], item)
end


--根据key 获取一个对象
function M:getItem( key )
    local item = nil
    if key == 1 then
        item = FixVector3.New(0,0,0);
    elseif key == 2 then
        item = FixQuaternion.New(0,0,0,0);
    else
        item = {}
    end
    return item
end


--从池中弹出一个物体
function M:pop( key )
    local table_key = self.table_pool[key]
    if table_key ~= nil then
        local len = #table_key
	    if len > 0 then
		    local item = table_key[len]
            table.remove(table_key, len)
            if self.table_len_max[key] < #table_key then
                self.table_len_max[key] = #table_key
            end
            TablePoolUtil:push_temp(key,item);
            return item
        else
            local item = self:getItem(key)
            --放入到临时表中
            TablePoolUtil:push_temp(key,item);
            return item;
        end
    else
        local item = self:getItem(key)
        --放入到临时表中
        TablePoolUtil:push_temp(key,item);
        return item;
    end
end

--将item推入临时表中
function M:push_temp( key, item )
    if self.table_pool_temp[key] == nil then
        self.table_pool_temp[key] = {}
    end
    if item ~= nil then
        table.insert(self.table_pool_temp[key], item)
    end
    if self.table_len_max[key] < #self.table_pool_temp[key] then
        self.table_len_max[key] = #self.table_pool_temp[key]
    end
end

--将所有的item 推入到池中
function M:push_all()
    for k1,v1 in pairs(self.table_pool_temp) do
        for k2,v2 in ipairs(v1) do
            table.insert(self.table_pool[k1], v2)
        end
        if self.table_pool_temp[k1] ~= nil then
            self.table_pool_temp[k1] = nil
        end
    end
end


--将一个对象 返回到池中
function M:push( key, item )
    if self.table_pool[key] == nil then
        self.table_pool[key] = {}
    end
    if item ~= nil then
        table.insert(self.table_pool[key], item)
    end
    if self.table_len_max[key] < #self.table_pool[key] then
        self.table_len_max[key] = #self.table_pool[key]
    end
end


function M:pushCount()
    for k,v in pairs(self.table_pool) do
        Logger.log(k.." : "..#v)
    end
end

return M;