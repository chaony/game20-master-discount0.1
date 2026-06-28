local M = class("ItemListModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
    --self.m_transfer = "scale"
    self:getData()
end

function M:onEnter()
	self.m_open_tab_index = self.m_params.open_tab_index or 4
    self.m_isShowRunescapeItem = self.m_params.isShowRunescapeItem or false
    self.m_sel_tab_index = nil
    self.m_data_cache = {}
end

--[[
    仓库数据
]]
function M:refreshListData(index, force_refresh)
    if force_refresh then
        self.m_data_cache = {}
    end
    index = index or self.m_open_tab_index
    if self.m_data_cache[index] == nil then
        local show_data = {} 
        if index == 1 then-- 道具
            local function filterFunc(item_data, item_cfg)
                if self.m_isShowRunescapeItem then
                    return (item_cfg.sort == 1 or item_cfg.sort == 3 or item_cfg.sort == 5) and (item_cfg.is_show == 1)
                else
                    return (item_cfg.sort == 1 or item_cfg.sort == 3 or item_cfg.sort == 5) and (item_cfg.is_show == 1) and (item_cfg.sort ~= 3)
                end
            end
            GameUtil:insertProcessItemData(show_data, filterFunc)
        elseif index == 2 then-- 装备
            GameUtil:insertEquipsData(show_data)
        elseif index == 3 then-- 灵魂石
            local function filterFunc(item_data, item_cfg)
                return item_cfg.sort == 2 and item_cfg.is_show == 1
            end
            GameUtil:insertProcessItemData(show_data, filterFunc)
        elseif index == 4 then-- 全部
            --江湖任务道具
            local function filterFunc(item_data, item_cfg)
                if self.m_isShowRunescapeItem then
                    return item_cfg.is_show == 1 and item_cfg.sort == 3
                else
                    return item_cfg.is_show == 1 and item_cfg.sort == 3 and (item_cfg.sort ~= 3)
                end
            end
            GameUtil:insertProcessItemData(show_data, filterFunc)
            GameUtil:insertRedPacketData(show_data)
            --其他道具
            local other_items_data = {}
            local function filterFunc(item_data, item_cfg)
                if self.m_isShowRunescapeItem then
                    return item_cfg.is_show == 1 and item_cfg.sort ~= 3
                else
                    return item_cfg.is_show == 1 and item_cfg.sort ~= 3 and (item_cfg.sort ~= 3)
                end
            end
            GameUtil:insertProcessItemData(other_items_data, filterFunc)
            table.insertto(show_data, other_items_data)
            GameUtil:insertEquipsData(show_data)
            --GameUtil:insertMysticesData(show_data)
        --elseif index == 5 then-- 江湖道具
        --    local function filterFunc(item_data, item_cfg)
        --        return item_cfg.sort == 3 and item_cfg.is_show == 1
        --    end
        --    GameUtil:insertProcessItemData(show_data, filterFunc)
        elseif index == 5 then-- 秘籍碎片
            local function filterFunc(item_data, item_cfg)
                return item_cfg.sort == 4 and item_cfg.is_show == 1
            end
            GameUtil:insertProcessItemData(show_data, filterFunc)
            --GameUtil:insertMysticesData(show_data)
        end
        --类型为20的自选卡，奖励内容和赛季相关
        for i, v in ipairs(show_data) do
            GameUtil:updateItemEffect(v)
        end
        self.m_data_cache[index] = show_data
    end
    self.m_show_data = self.m_data_cache[index] or {}
    return self.m_show_data
end

function M:getShowData()
	return self.m_show_data
end

function M:isHeroReward(item_cfg)
    local effect = item_cfg.effect or {}
    local flag = true
    for k,v in pairs(effect) do
        if v[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS then
            flag = false
            break
        end
    end
    return flag
end

return M
