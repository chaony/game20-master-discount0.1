local M = class("NewYearSkipShopModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
    self:getData()
end

function M:onEnter()
    self.is_tokens = self.m_params.is_token
    -- 已购买的皮肤礼包id
    self.hasBuySkinIds = self.m_params.data;
    -- openid
    self.open_id = self.m_params.open_id;
    -- 活动版本号
    self.version = self.m_params.version;
    -- 获取到皮肤配置
    self.spring_festival_clothes = ConfigManager:getCfgByName("spring_festival_clothes");
    self.m_actives = self.m_params.actives
end

--获取名字 
function M:getTitleName()
    local open_data = self:getActiveCfgByOpenId(self.open_id)
    if open_data ~= nil then
        return Language:getTextByKey(open_data.name);
    end
    return nil;
end

--["reward"]=
--{
--  {
--      130,
--      20802,
--      1,
--  },
--},
--["price_old"]=328,
--["price_new"]=98,
--["charge_id"]=1058,
--["return_per"]="3.9折",
--获取皮肤
function M:getSkins()
    --通过版本号来获取到皮肤配置
    local skins = self.spring_festival_clothes[self.version];
    if skins ~= nil then
        local m_skin_datas = {}
        for i, v in ipairs(skins) do
            local skin_item = table.copy(v);
            --是否已经购买过这个皮肤
            skin_item.hasBuy = self:hasSkin(i)
            table.insert(m_skin_datas, skin_item);
        end
        return m_skin_datas;
    end
    return nil;
end

function M:getEndTs()
    if self.m_actives and self.m_actives.end_ts then
        return self.m_actives.end_ts
    end
    return 0
end

function M:hasSkin( id )
    for i, v in ipairs(self.hasBuySkinIds) do
        if id == v then
            return true;
        end
    end
    return false;
end

function M:getActiveCfgByOpenId(open_id)
	local active_tab = ConfigManager:getCfgByName("active")
	for i,v in pairs(active_tab) do
		if v.open_id == open_id then
			return v
		end
	end	
	local active_recharge_tab = ConfigManager:getCfgByName("active_recharge")
	for i,v in pairs(active_recharge_tab) do
		if v.open_id == open_id then
			return v
		end
	end	
	return nil
end


return M