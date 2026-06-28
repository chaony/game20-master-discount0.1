local M = class("GiftBagScrollShopPopModel", LikeOO.OODataBase)

M.point = {}

local PopShowType = {
    [1] = "activity_gift",
    [2] = "activity_gift",
}

function M:onCreate()
    self.m_transfer = "scale"
    self.popShowType = PopShowType
    self.m_showType =  (self.m_params.showType ~= nil) and self.m_params.showType or 1
    self:getData("activity_gift_index")
end

function M:onEnter()
    StatisticsUtil:doPointActive(115,self.m_data.version)
    self.bag_list = self:get_scroll_shop_cfg()
    self.m_is_token = self.m_params.is_token or false
end

function M:updateData(data)
    if data then
        self.m_data = data
        self.bag_list = self:get_scroll_shop_cfg()
    end
end

--锦囊配置数据
function M:get_scroll_shop_cfg()
    local cfgName = self.popShowType[self.m_showType]
    local scroll_shop_tab = ConfigManager:getCfgByName(cfgName)
    local version = self.m_data.version or 1
    local new_tab = table.copy(scroll_shop_tab[version])
    for k,v in pairs(new_tab) do
        local num = self:getActivityGiftData(k)
        v.id = k
    end
    local function sortFunc(id_one, id_two)
        local data_one = self:getActivityGiftData(id_one.id) >= id_one.time_limit and 1 or 0
        local data_two = self:getActivityGiftData(id_two.id) >= id_two.time_limit and 1 or 0
        if data_one == data_two then
            return id_one.id < id_two.id
        else
            return data_one < data_two
        end
    end
    table.sort(new_tab, sortFunc)
    return new_tab
end

function M:getActivityGiftData(id)
    if self.m_data ~= nil then
        return self.m_data.activity_log[tostring(id)] or 0
    end
    return 0
end

return M
