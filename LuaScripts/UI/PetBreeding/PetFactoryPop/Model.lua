---@class PetFactoryPopModel: OODataBase
local M = class("PetFactoryPopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData("pet_factory_index")
end

function M:onEnter()
    self.m_all_pet_list = self:getAllPetIds()
    
    -- 缓存一次进入界面时是否达到最大派遣时间状态
    self.m_get_reward_enter_state = UserDataManager:getRedDotByKey("pet_factory") == 1

    self:setFactoryData(self.m_data)
end

---设置工坊数据
function M:setFactoryData(msgData)
    local vipCfg = ConfigManager:getCfgByName("vip")
    -- VIP 加成计算
    local curVipLevel = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0

    local maxHour = 0
    if vipCfg[curVipLevel].factory_time_limit ~= nil then
        maxHour = vipCfg[curVipLevel].factory_time_limit
    end

    self.m_bazaarLevel = msgData.bazaar_lv

    local allDropCfg = ConfigManager:getCfgByName("pet_factory_drop")
    self.m_dropCfg = allDropCfg[self.m_bazaarLevel]
    
    -- 最长挂机时间
    self.m_maxIdleSecond = maxHour * 3600
    
    -- 挂机开始时间，秒级时间戳
    self.m_idleStartTime = msgData.idle_start_time
    self.m_idleEndTime = self.m_idleStartTime ~= 0 and self.m_idleStartTime + self.m_maxIdleSecond or 0
    -- 饲料结束时间，秒级时间戳
    self.m_foodEndTime = msgData.food_end_time
    
    -- 清空奖励赋值
    self.m_gifts = {}
    if msgData.gifts then
        for i, v in ipairs(msgData.gifts) do
            table.insert(self.m_gifts, v)
        end
    end
    
    -- 清空已派遣宠物赋值
    self.m_pets = {}
    if msgData.pets then
        for i, v in ipairs(msgData.pets) do
            table.insert(self.m_pets, v)
        end
    end
end

--- 网络数据回调，需要复写
function M:netData(data, tag)
    print("网络数据回调 ============>" .. tag)
    if tag == "pet_factory_index" or 
       tag == "pet_factory_dispatch" or 
       tag == "pet_factory_quick_dispatch" or 
       tag == "pet_factory_recall" or
       tag == "pet_factory_add_food" then
        self:setFactoryData(data)
    elseif tag == "pet_factory_collect" then
        if data then
            -- 显示通用奖励界面
            if data.reward then
                RewardUtil:rewardTipsByData(data.reward)
            end

            -- 更新数据
            if data.pet_factory then
                self:setFactoryData(data.pet_factory)
            end
        end
    end
end

---================================================================

--宠物列表
function M:getAllPetIds()
    local ids = table.copy(UserDataManager.pet_data:getPetsId())
    
    --[[排序规则:
        1. 宠物类型
        2. 代数
        3. 等级
        4. 战力
        5. id
    --]]
    local function sortFunc(id_one, id_two)
        local data1, cfg1 = self:getPetDataById(id_one)
        local data2, cfg2 = self:getPetDataById(id_two)
        if cfg1.pet_type ~= cfg2.pet_type then
            return cfg1.pet_type < cfg2.pet_type
        elseif data1.evo ~= data2.evo then
            return data1.evo > data2.evo
        elseif data1.lv ~= data2.lv then
            return data1.lv > data2.lv
        elseif data1.combat ~= data2.combat then
            return data1.combat > data2.combat
        else
            return data1.oid > data2.oid
        end
    end
    table.sort(ids, sortFunc)
    return ids
end

function M:getPetDataById(oid)
    local data, cfg = UserDataManager.pet_data:getPetDataById(oid)
    return data, cfg
end

function M:getPetDataByIndex(index)
    return self.m_all_pet_list[index]
end

---根据上阵位置获取已派遣宠物数据
function M:getDispatchPetDataByPos(pos)
    return self.m_pets[pos]
end

---获取当前已派遣宠物数量
function M:getDispatchPetCount()
    local res = 0
    for i, v in pairs(self.m_pets) do
        if v.oid and v.oid ~= "" then 
            res = res + 1
        end
    end
    return res
end

---================================================================

---判断是否使用食物道具
function M:checkUsingFoodItem() 
    return self.m_foodEndTime ~= 0
end

---获取当前挂机时长
function M:getIdleTimeStr()
    -- 开始时间为0，表示未开始派遣宠物
    if self.m_idleStartTime <= 0 then
        return Language:getTextByKey("pet_factory_text_0026")
    else
        local time = UserDataManager:getServerTime() - self.m_idleStartTime
        return GameUtil:formatTimeBySecond(math.min(self.m_maxIdleSecond, time), 999)    
    end
end

return M