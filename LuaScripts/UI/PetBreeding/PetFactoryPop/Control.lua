---@class PetFactoryPopControl: OOControlBase
---@field m_model PetFactoryPopModel
---@field m_view PetFactoryPopView
local M = class("PetFactoryPopControl", LikeOO.OOControlBase)

function M:onEnter()
    M.super.onCreate(self)
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:updateMsg("redPoint_refresh", nil, "PetBreeding.PetBreedingMain")
        -- 达到最大奖励时，强制结算一次
        local isMaxReward = UserDataManager:getRedDotByKey("pet_factory") == 1
        if self.m_model.m_get_reward_enter_state or isMaxReward then 
            local cb = function()
                self:closeView()
            end
            self:collectRequest(cb)
        else
            self:closeView()    
        end
        
        
    elseif msg == "pet_node_cell_click" then
        if data.oid ~= "" then
            -- 卸下
            self:recallRequest(data.pos - 1)
        else
            -- 打开替换界面
            local showData = {
                pos = data.pos, -- 位置索引，从 1 开始
                excludeList = self.m_model.m_pets, -- 已上阵的宠物列表
            }
            self:openView("PetBreeding.PetFactorySendPop", showData)
        end
    elseif msg == "get_reward_btn" then
        -- 没有奖励可以领取时，弹出提示
        if self.m_model.m_gifts ~= nil and #self.m_model.m_gifts == 0 then
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pet_factory_text_0025"), delay_close = 2 })
        else
            -- 请求领取奖励
            self:collectRequest()
        end
    elseif msg == "add_food_btn" then
        -- 打开投喂饲料界面
        local data = {
            idleStartTime = self.m_model.m_idleEndTime,
            idleEndTime = self.m_model.m_idleEndTime,
        }
        self:openView("PetBreeding.PetFactoryAddFoodPop", data)
    elseif msg == "quick_change_btn" then
        -- 请求一键派遣
        self:dispatchQuickRequest()
    elseif msg == "information_btn" then
        local params = {}
        params.title = "pet_factory_text_0001"
        params.content = "tid#PetRuleDes_5"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "pet_factory_update_ui" then
        if data then
            local msgTag = data.tag
            self.m_model:netData(data, msgTag)
        end
        
        if self.m_view then 
            self.m_view:refreshUI()
        end
    end
end

---========================[net function]======================================

---一键派遣
function M:dispatchQuickRequest()
    local function callback(response)
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pet_factory_text_0029"), delay_close = 2 })
        if self.m_view then
            self.m_view:refreshUI()
        end
        self:notifyGetPetIndexData()
    end

    print("[REQ_PET_FACTORY][dispatchQuick]")
    self.m_model:getNetData("pet_factory_quick_dispatch", { }, callback)
end

--- 领取奖励
function M:collectRequest(cb)
    local function callback(response)
        if response then 
            if response.rewards then
                RewardUtil:rewardTipsByData(response.rewards)
            end
            
            self.m_model:setFactoryData(response.pet_factory)
        end
        
        if self.m_view then
            self.m_view:refreshUI()
        end
        self:notifyGetPetIndexData()
        
        if cb then 
            cb()
        end
    end

    print("[REQ_PET_FACTORY][collect]")
    self.m_model:getNetData("pet_factory_collect", { }, callback)
end

--- 召回宠物
---@param pos number 位置索引，从 0 开始
function M:recallRequest(pos)
    local function callback(response)
        if response then
            self.m_model:setFactoryData(response)
        end
        if self.m_view then
            self.m_view:refreshUI()
        end
        self:notifyGetPetIndexData()
    end

    print("[REQ_PET_FACTORY][recall]" .. table.dump({pos = pos}, true, 5))
    self.m_model:getNetData("pet_factory_recall", { pos = pos }, callback)
end

-- 通知刷新数据
function M:notifyGetPetIndexData()
    self:updateMsg("update_pet_index", nil, "PetBreeding.PetBreedingMain")
end

---============================================================

---倒计时回调
function M:updateTime()
    if self.m_view then
        self.m_view:refreshTimeStr()
    end
end

---============================================================

function M:destroy()
    if self.m_timer_id then
        self:removeTimer(self.m_timer_id)
        self.m_timer_id = nil
    end
    M.super.destroy(self)
end

return M
