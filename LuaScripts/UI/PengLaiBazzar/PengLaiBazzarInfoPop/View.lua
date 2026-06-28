---@class PengLaiBazzarInfoPopView: OOPopBase
---@field m_model PengLaiBazzarInfoPopModel
local M = class("PengLaiBazzarInfoPopView", LikeOO.OOPopBase)

M.m_uiName = "PengLaiBazzar/PengLaiBuildBazzarPop"
M.m_size_type = 2

M.m_build_group_cmp = nil
M.m_speed_up_group_cmp = nil
M.m_item_list_cmp = nil
M.m_build_desc_cmp = nil

M.m_build_one_btn = nil
M.m_build_all_btn = nil

M.m_build_loop_scroll_view = nil
M.m_item_loop_scroll_view = nil

M.m_showStyle = 1
M.m_initShowStyle = 1

function M:onEnter()
    self.m_showStyle = self.m_model.m_showType
    self.m_initShowStyle = self.m_model.m_showType
    
    self:bindUI()
    self:refreshUI()
end

function M:bindUI()
    self.m_build_group_cmp = self:findGameObject("build_group")
    self.m_speed_up_group_cmp = self:findGameObject("speed_up_group")
    self.m_item_list_cmp = self:findGameObject("item_list_group")
    self.m_build_desc_cmp = self:findGameObject("bazzar_desc_group")

    self.m_build_one_btn = self:findGameObject("build_one_btn")
    self.m_build_all_btn = self:findGameObject("build_all_btn")
    
    self:setTextByLanKey("sub_title_text", "pengLai_text_011")
    self:setTextByLanKey("left_time_title_text", "pengLai_text_012")
    self:setTextByLanKey("bazzar_type_title_text", "pengLai_text_013")
    self:setTextByLanKey("build_one_btn_text", "pengLai_text_014")
    self:setTextByLanKey("build_all_btn_text_1", "pengLai_text_014")
    self:setTextByLanKey("build_all_btn_text_2", "pengLai_text_015")
    self:setTextByLanKey("speed_up_btn_text", "pengLai_text_016")
    self:setTextByLanKey("reward_empty_text", "pengLai_text_022")
end

function M:refreshUI()
    self:switchShowType(self.m_showStyle)
    self:setBuildGiftList()
    self:setBuildingList()
    
    self:setCostBtnInfo()
    self:setBuildDesc()
    
    if self.m_showStyle ~= 2 then
        local curBuildingCfg = self.m_model.m_allBuildings[self.m_model.m_buildID]
        local leftTimeStr = GameUtil:formatTimeBySecond(curBuildingCfg.sale_time * 3600, 999) 
        self:refreshLeftTime(leftTimeStr)    
    elseif self.m_initShowStyle == 2 then
        local curPos = self.m_model.m_curPos
        local leftTimeStr = self.m_model.m_leftTimeFunc(curPos, self.m_model.m_isVipPos)
        self:refreshLeftTime(leftTimeStr)
    end
    
    local leftSpeedUpCount = self.m_model:getLeftSpeedUpCount()
    self:setTextByLanKey("left_speed_up_count_text", "pengLai_text_023", leftSpeedUpCount)

    local contentNode = self:findGameObject("content_node")
    -- 设置位置偏移
    if self.m_model.m_click_transform then
        local pos = self.m_rt.transform:InverseTransformPoint(self.m_model.m_click_transform.transform.position)
        local posX = pos.x + 90
        posX = posX < -350 and -350 or posX
        posX = posX > 350 and 350 or posX
        pos.x = posX
        pos.y = 0
        pos.z = 0
        contentNode.transform.localPosition = pos
    end
end

---切换显示模式
function M:switchShowType()
    local showType = self.m_showStyle
    local initShowType = self.m_initShowStyle

    self.m_build_group_cmp:SetActive(initShowType == 1)
    self.m_speed_up_group_cmp:SetActive(initShowType == 2)
    self.m_item_list_cmp:SetActive(showType ~= 3)
    self.m_build_desc_cmp:SetActive(showType == 3)

    self.m_build_one_btn:SetActive(initShowType == 1)
    self.m_build_all_btn:SetActive(initShowType == 1)
    
    self:setObjectVisible("sub_title_text", showType ~= 3)
    self:setObjectVisible("sub_title_bg_img", showType ~= 3)

    self:setObjectVisible("reward_empty_text", #self.m_model.m_rewards <= 0 and showType ~= 3)
end

---设置消耗图标及相关文字
function M:setCostBtnInfo()
    local curBuildingCfg = self.m_model.m_allBuildings[self.m_model.m_buildID]
    local itemCost = curBuildingCfg.item_cost[1]
    local resCost = curBuildingCfg.money_cost[1]
    local speedUpCost = curBuildingCfg.finish_cost[1]
    
    local costItemID = itemCost[2]
    local itemData, cfg = UserDataManager.item_data:getItemDataById(costItemID)
    local buildAllCostValue = 0
    local buildOneCostValue = 0
    
    local quickBuildCount = self.m_model:getCanQuickBuildCount()
    -- 优先使用道具
    if itemData.num ~= nil and itemData.num > itemCost[3] then
        local itemData = RewardUtil:getProcessRewardData(itemCost)
        self:setImg(cfg.icon, itemData.atlas_name or "item_icon", "build_one_icon_img")
        self:setImg(cfg.icon, itemData.atlas_name or "item_icon", "build_all_icon_img")
        buildAllCostValue = itemCost[3] * quickBuildCount
        buildOneCostValue = itemCost[3]
        
        self.m_model:setCostType(1)
    else
        self:setImg("DJ_yuanbao", "item_icon", "build_one_icon_img")
        self:setImg("DJ_yuanbao", "item_icon", "build_all_icon_img")
        buildAllCostValue = resCost[3] * quickBuildCount
        buildOneCostValue = resCost[3]

        self.m_model:setCostType(2)
    end
    
    self:setText("build_one_cost_text",  buildOneCostValue)
    self:setText("build_all_cost_text", buildAllCostValue)
    self:setText("speed_up_btn_cost_text", speedUpCost[3])
    self:setText("build_all_total_text", quickBuildCount)

    self:setImg("DJ_yuanbao", "item_icon", "speed_up_icon_img")
end

---==================================================================================

---设置奖励产出
function M:setBuildGiftList()
    local showNum = self.m_initShowStyle == 2
    if self.m_item_loop_scroll_view == nil then
        local data = self.m_model.m_rewards
        local loopScroll = self:findGameObject("item_loopscroll")
        local params = {
            show_data = data,
            one_line_count = 5,
            loop_scroll_object = loopScroll,
            update_cell = function(index, cell_obj, cell_data)
                local item = GameUtil:updateItemElement(cell_obj, cell_data, showNum, true)
            end
        }
        self.m_item_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_item_loop_scroll_view:reloadData(self.m_model.m_rewards)
    end
end

---==================================================================================

---设置可用建筑列表
function M:setBuildingList()
    local allBuildingCfg = {}
    for k, v in pairs(self.m_model.m_curUpgradeCfg.build) do
        table.insert(allBuildingCfg, v)
    end
    
    if self.m_build_loop_scroll_view == nil then
        local loopScroll = self:findGameObject("building_loopscroll")
        loopScroll:SetActive(true)
        local params = {
            show_data = allBuildingCfg,
            pos_center = true,
            loop_scroll_object = loopScroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateBuildingListCell(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                -- 点击回调
                local tempData = {
                    index = index,
                    data = cell_data,
                    click_name = click_name,
                    cell_obj = cell_object,
                }
                self:updateMsg("building_list_item_select", tempData)
            end,
            ui_name = self.m_uiName
        }
        self.m_build_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_build_loop_scroll_view:reloadData(allBuildingCfg, true)
    end
end

function M:updateBuildingListCell(index, cell_obj, cell_data)
    
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaviour then
        local curBuildingCfg = self.m_model.m_allBuildings[cell_data]
        local isLock = false
        local isPopular = self.m_model:checkIsPopular(cell_data)

        -- 设置“热卖”、“锁定”状态
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_mask_img", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bazzar_lock_text", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "popular_item_img", isPopular)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "popular_tag_text", isPopular)

        LuaBehaviourUtil.setText(luaBehaviour, "bazzar_name_text", Language:getTextByKey(curBuildingCfg.name))
        LuaBehaviourUtil.setText(luaBehaviour, "popular_tag_text", Language:getTextByKey("pengLai_text_017"))
        LuaBehaviourUtil.setText(luaBehaviour, "bazzar_lock_text", Language:getTextByKey("pengLai_text_018"))

        -- 加载Spine
        local spineObj = luaBehaviour:FindGameObject("spine_obj")
        GameUtil:updateSpineLoadSet(spineObj , "RoleSpine/" .. curBuildingCfg.spine .. "_SkeletonData", "idle", 0, true)
        
        -- 检测资源是否充足
        local itemCost = curBuildingCfg.item_cost[1]
        local resCost = curBuildingCfg.money_cost[1]

        local costItemID = itemCost[2]
        local itemData, cfg = UserDataManager.item_data:getItemDataById(costItemID)
        -- 优先使用道具
        if not isLock then
            if itemData.num ~= nil and itemData.num > itemCost[3] then
                local itemData = RewardUtil:getProcessRewardData(itemCost)
                LuaBehaviourUtil.setText(luaBehaviour, "bazzar_price_text", itemCost[3])
                LuaBehaviourUtil.setImg(luaBehaviour, "cost_item_icon_img", cfg.icon, itemData.atlas_name or "item_icon")
            else
                LuaBehaviourUtil.setText(luaBehaviour, "bazzar_price_text", resCost[3])
                LuaBehaviourUtil.setImg(luaBehaviour, "cost_item_icon_img", "DJ_yuanbao", "item_icon")
            end    
        end

        local selectImg = luaBehaviour:FindGameObject("selected_img")
        local arrowTag = luaBehaviour:FindGameObject("arrow_img")
        local idx = index
        selectImg:SetActive(idx == self.m_model.m_selectedIndex)
        arrowTag:SetActive(idx == self.m_model.m_selectedIndex)
    end
    
    if self.m_model.m_click_transform == nil and self.m_initShowStyle ~= 2 then 
        self.m_model:setClickTransform(cell_obj)
    end
end

---==================================================================================

function M:setBuildDesc()
    local curBuildingCfg = self.m_model.m_allBuildings[self.m_model.m_buildID]
    self:setTextByLanKey("main_title_text", curBuildingCfg.name)
    
    self:setTextByLanKey("bazzar_type_text", curBuildingCfg.type_name)
    self:setTextByLanKey("bazzar_desc_text", curBuildingCfg.des)
end

function M:refreshLeftTime(leftTimeStr)
    if leftTimeStr ~= nil then
        self:setText("left_time_text", leftTimeStr)    
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M