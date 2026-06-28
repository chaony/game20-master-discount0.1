------------ JewelData
local M = {
    m_jewels = {},
    m_effects = {},
}

function M:updateData(data)
    if data == nil then
        return
    end
    for k, v in pairs(data) do
        self.m_jewels[tonumber(k)] = v --转key为数值
    end
end

--激活新增
function M:updateActive(id)
    if self.m_jewels[id] ~= nil then
        return
    end
    self.m_jewels[id] = {evo = 1, awaken = 0} --激活后默认1星
end

--升星
function M:updateEvo(id, evo)
    if self.m_jewels[id] then
        self.m_jewels[id].evo = evo
    end
end

--觉醒
function M:updateAwaken(id)
    if self.m_jewels[id] then
        self.m_jewels[id].awaken = 1
    end
end

--获取宝物实例
function M:getJewel(id)
    return self.m_jewels[id]
end

--宝物是否激活
function M:isActiveJewel(id)
    if self.m_jewels[id] == nil then
        return false
    end
    return true
end

function M:getJewels()
    return self.m_jewels
end

--是否显示激活效果
function M:checkActiveUI(id)
    if id == nil then
        return false
    end
    local is_active = self:isActiveJewel(id)
    --未激活，展示获得界面
    if is_active == false then
        return true
    end
    --抽到天级及以上品质宝物时，无论是否拥有该宝物，都展示一次该宝物的获得界面效果
    local cfg = self:getDetailCfg(id)
    if cfg.quality >= 6 then
        return true
    end
    return false
end

--根据id获取宝物基本配置
--id=nil，取全表
function M:getDetailCfg(id)
    local detail_tab = ConfigManager:getCfgByName("jewel_detail")
    if id == nil then
        return detail_tab
    end
    return detail_tab[id]
end

--根据品质获取碎片配置
function M:getChipCfg(quality)
    local chip_tab = ConfigManager:getCfgByName("jewel_chip_quality")
    return chip_tab[quality]
end

--获得宝物养成状态
function M:getJewelTrainState(id)
    local jewel = self.m_jewels[id]
    if jewel == nil then
        return 0 --未激活状态
    end
    if jewel.evo < 5 then
        return 1 --升星中
    end
    if jewel.awaken == 0 then
        return 2 --准备觉醒
    end
    return 9 --觉醒了
end

--遍历宝物是否有红点
function M:checkAllRedPoint()
    local books = self:getDetailCfg()
    for k, v in pairs(books) do
        local is_red_point = self:isRedPoint(k)
        if is_red_point == true then
            return true
        end
    end
    return false
end

--单个宝物红点
function M:isRedPoint(id)
    local jewel = self.m_jewels[id]
    if jewel == nil then
        local is_active = self:isRedPointForActive(id)
        return is_active
    end
    if jewel.awaken == 1 then
        return false
    end
    local evo = jewel.evo
    if evo >= 5 then
        local is_awaken = self:isRedPointForAwaken(id)
        return is_awaken
    end
    local is_evo = self:isRedPointForEvo(id, jewel.evo)
    return is_evo
end

--是否可以激活红点
function M:isRedPointForActive(id)
    local cfg = self:getDetailCfg(id)
    local data, item_cfg = UserDataManager.item_data:getItemDataById(cfg.chip_id)
    if data.num <= 0 then
        return false
    end
    local chip_cfg = self:getChipCfg(cfg.quality)
    if data.num < chip_cfg.active_num then
        return false
    end
    return true
end

--是否可以升星红点
function M:isRedPointForEvo(id, evo)
    if evo >= 5 then
        return false
    end
    local evo_tab = ConfigManager:getCfgByName("jewel_evo_up")
    local cfg = evo_tab[id][evo + 1]
    local costs = cfg.costs
    if not next(costs) then
        return false
    end
    for i,v in ipairs(costs) do
        local cost_item = RewardUtil:getProcessRewardData(v)
        if cost_item.user_num < cost_item.data_num then
            return false
        end
    end
    return true
end

--是否可以觉醒红点
function M:isRedPointForAwaken(id)
    local awaken_tab = ConfigManager:getCfgByName("jewel_awake")
    local cfg = awaken_tab[id]
    local costs = cfg.costs
    for i,v in ipairs(costs) do
        local cost_item = RewardUtil:getProcessRewardData(v)
        if cost_item.user_num < cost_item.data_num then
            return false
        end
    end
    return true
end

--根据侠客id和激活的宝物，统计加成属性
--返回属性组
--[1] = {[901, 99999],[902, 9999]}
--[2] = {[901, 99999],[902, 9999]}
function M:getAttrs(hero_id)
    local all_attrs_list = {}
    for k, v in pairs(self.m_jewels) do
        local cfg = self:getDetailCfg(k)
        --非专属宝物，全体都加成
        --专属宝物，只加本侠客
        if cfg.hero_id == nil or cfg.hero_id == 0 or cfg.hero_id == hero_id then
            local attr_cfg = self:getAttrCfg(k, v.evo, v.awaken)
            local attrs = attr_cfg.attrs
            all_attrs_list[#all_attrs_list + 1] = attrs
        end
    end
    return all_attrs_list
end

--返回当前属性，下级属性，状态(0可升星，1可觉醒，2已觉醒)
function M:getAttrCfg(id, evo, awaken)
    if awaken == 1 then
        local awaken_cfg = self:getAwakenCfg(id)
        return awaken_cfg, nil, 2
    end
    local evo_cfg = self:getEvoCfg(id, evo)
    local next_evo_cfg = self:getEvoCfg(id, evo + 1)
    if next_evo_cfg == nil then
        local awaken_cfg = self:getAwakenCfg(id)
        return evo_cfg, awaken_cfg, 1
    end
    return evo_cfg, next_evo_cfg, 0
end

function M:getEvoCfg(id, evo)
    local evo_tab = ConfigManager:getCfgByName("jewel_evo_up")
    local evo_cfg = evo_tab[id][evo]
    return evo_cfg
end

function M:getAwakenCfg(id)
    local awaken_tab = ConfigManager:getCfgByName("jewel_awake")
    local awaken_cfg = awaken_tab[id]
    return awaken_cfg
end

function M:initEffect(effects)
    self.m_effects = effects or {}
end

function M:updateEffects(effects)
    if effects and next(effects) then
        table.merge(self.m_effects, effects)
    end
end

function M:checkFightSpeed4()
    for k, v in pairs(self.m_effects) do
        if tonumber(k) == 3 then
            return true
        end
    end
    return false
end

--秘宝增加挂机次数
function M:getHandTimes()
    for k, v in pairs(self.m_effects) do
        if tonumber(k) == 6 then
            return v
        end
    end
    return 0
end

return M