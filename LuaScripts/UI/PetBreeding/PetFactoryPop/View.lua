---@class PetFactoryPopView: OOPopBase
---@field m_model PetFactoryPopModel
local M = class("PetFactoryPopView", LikeOO.OOPopBase)

M.m_uiName = "PetBreeding/PetFactoryPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

--- 倒计时文本组件
M.m_leftTimeUpdateText = nil

M.m_normal_reward_scroll_view = nil
M.m_random_reward_scroll_view = nil

M.m_gray_img = nil

function M:onEnter()
    self:bindUI()
end

function M:bindUI()
    self:setTextByLanKey("common_title_text", "pet_factory_text_0001")
    self:setTextByLanKey("sub_title_send_text", "pet_factory_text_0002")
    self:setTextByLanKey("sub_title_send_title_text", "pet_factory_text_0003")
    self:setTextByLanKey("sub_title_normal_reward_text", "pet_factory_text_0005")
    self:setTextByLanKey("sub_title_random_reward_text", "pet_factory_text_0006")
    self:setTextByLanKey("get_reward_btn_text", "pet_factory_text_0009")
    self:setTextByLanKey("add_food_btn_text", "pet_factory_text_0010")
    self:setTextByLanKey("quick_change_btn_text", "pet_factory_text_0011")

    local commonCfg = ConfigManager:getCfgByName("common")
    local productionRateStr = commonCfg[742].value * 100
    self:setTextByLanKey("production_rate_desc_text", "pet_factory_text_0008", productionRateStr)
    
    self.m_leftTimeUpdateText = self:findText("sub_title_send_time_text")
    self.m_gray_img = self:findImage("gray_img")
    
    self:refreshUI()
end

---设置普通掉落奖励
function M:setNormalRewardList()
    local allData = {}
    local dropTime = 3600
    if self.m_model.m_dropCfg then 
        allData = table.copy(self.m_model.m_dropCfg.reward_drop)
        dropTime = self.m_model.m_dropCfg.drop_time
    end
    
    local curDispatchCount = self.m_model:getDispatchPetCount()
    curDispatchCount = curDispatchCount <= 0 and 1 or curDispatchCount

     -- 计算公式 3600 / drop_time * reward_drop 的 第三个数 * 宠物派遣个数
    for i, v in pairs(allData) do
        if v then
            local origin = v[3]
            v[3] = math.floor(curDispatchCount * origin * 3600 / dropTime)
        end
    end
    
    if self.m_normal_reward_scroll_view == nil then
        local loopScroll = self:findGameObject("dropnormal_loopscroll")
        loopScroll:SetActive(true)
        local params = {
            show_data = allData,
            loop_scroll_object = loopScroll,
            update_cell = function(index, cell_obj, cell_data)
                GameUtil:updateItemElement(cell_obj, cell_data, true, true)
            end
        }
        self.m_normal_reward_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_normal_reward_scroll_view:reloadData(allData)
    end
end

---设置随机掉落奖励
function M:setRandomRewardList()
    local allData = {}
    local dropTime = 3600
    if self.m_model.m_dropCfg then
        allData = table.copy(self.m_model.m_dropCfg.drop_random_show)
        dropTime = self.m_model.m_dropCfg.drop_time
    end
    
    local curDispatchCount = self.m_model:getDispatchPetCount()
    curDispatchCount = curDispatchCount <= 0 and 1 or curDispatchCount

    for i, v in pairs(allData) do
        if v then
            v[3] = curDispatchCount
        end
    end
    
    if self.m_random_reward_scroll_view == nil then
        local loopScroll = self:findGameObject("droprandom_loopscroll")
        loopScroll:SetActive(true)
        local params = {
            show_data = allData,
            loop_scroll_object = loopScroll,
            update_cell = function(index, cell_obj, cell_data)
                GameUtil:updateItemElement(cell_obj, cell_data, true, true)
            end
        }
        self.m_random_reward_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_random_reward_scroll_view:reloadData(allData)
    end
end

---刷新界面
function M:refreshUI()
    print("[PetFactoryPop][refreshUI]**************************************************")
    self:setNormalRewardList()
    self:setRandomRewardList()
    self:setBazaarAdditionInfo()
    self:refreshTimeStr()
    self:setCurDispatchPet()

    local getRewardBtnImg = self:findImage("get_reward_btn")
    getRewardBtnImg.material = nil
    -- 没有奖励可领取时，按钮置灰
    if self.m_model.m_gifts ~= nil and #self.m_model.m_gifts == 0 then
        getRewardBtnImg.material = self.m_gray_img.material	
    end
    
    -- 处理红点显示
    local pet_factory = UserDataManager:getRedDotByKey("pet_factory")
    self:setObjectVisible("get_reward_red_point_img", pet_factory == 1)

    local pet_factory_best_team = UserDataManager:getRedDotByKey("pet_factory_best_team")
    self:setObjectVisible("quick_change_red_point_img", pet_factory_best_team == 1)
end

---设置动态文本
function M:setDynamicText()
    local curTime = UserDataManager:getServerTime()
    local isDouble = self.m_model.m_foodEndTime ~= 0 and self.m_model.m_foodEndTime >= curTime and self.m_model.m_idleStartTime ~= 0
    self:setObjectVisible("addition_effect_text", isDouble)
    self:setObjectVisible("production_rate_desc_text", isDouble)
    if isDouble then
        local time = self.m_model.m_foodEndTime - UserDataManager:getServerTime() 
        local doubleEffectStr = GameUtil:formatTimeBySecond(math.min(self.m_model.m_maxIdleSecond, time), 999)
        self:setTextByLanKey("addition_effect_text", "pet_factory_text_0012", doubleEffectStr) 
    end
end

---设置当前派遣宠物的显示
function M:setCurDispatchPet()
    for i = 1, 3 do
        local petNodeObj = self:findGameObject("pet_cell_" .. i)
        self:setSinglePetNode(petNodeObj, i)
    end
end

---设置当个宠物cell显示
function M:setSinglePetNode(petNodeObj, pos)
    local luaBehaviour = UIUtil.findLuaBehaviour(petNodeObj)
    local data = self.m_model:getDispatchPetDataByPos(pos)
    local petID = data and data.oid or ""
    local bazaarAdditionDesc = ""
    local showAddition = false
    
    if petID ~= "" then
        GameUtil:updatePetElement(petNodeObj, {oid = petID}, true, true)
        local allEvoCfg = ConfigManager:getCfgByName("pet_evolution")
        local curEvoCfg = allEvoCfg[data.evo]
        local rate = math.modf(curEvoCfg.factory_evo_coef * 100 - 100)
        bazaarAdditionDesc = string.format("+%s%%", rate)
        showAddition = petID ~= "" and rate ~= 0
    end

    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "empty_bg_img", petID == "")
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "pet_cell", petID ~= "")
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "pet_addition_img", showAddition)
    LuaBehaviourUtil.setText(luaBehaviour, "pet_addition_text", bazaarAdditionDesc)

    local function clickCallback()
        local tempData = {
            oid = petID,
            pos = pos,
        }
        self:updateMsg("pet_node_cell_click", tempData)
    end
    
    UIUtil.setButtonClick(petNodeObj, clickCallback)
end

---刷新倒计时显示
function M:refreshTimeStr()
    self:setDynamicText()
    
    if self.m_leftTimeUpdateText then
        self.m_leftTimeUpdateText.text = self.m_model:getIdleTimeStr()
    end
end

---设置蓬莱集市的加成描述
function M:setBazaarAdditionInfo()
    local curDispatchCount = self.m_model:getDispatchPetCount()
    local descStr = "pet_factory_text_0004"
    if curDispatchCount ~= 0 then 
        descStr = self.m_model.m_dropCfg.extra_des
    end
    self:setTextByLanKey("sub_title_reward_desc_text", descStr)
end

function M:destroy()
    M.super.destroy(self)
end

return M