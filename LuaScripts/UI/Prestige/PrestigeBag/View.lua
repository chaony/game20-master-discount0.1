---@class PrestigeBagView : OOPopBase
local M = class("PrestigeBagView", LikeOO.OOPopBase)

local __MINI_SLOT_SIDE_LENGTH = 25
local __ROTATE_TIME_THRESHOLD = 0.15

M.m_uiName = "Prestige/PrestigeBag"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
    --self.grid_item_list = {}
    self:initView()
    self:refreshView()
end

function M:initView()
    if self.isInit == true then
        return
    end
    self.isInit = true
    
    --本地化绑定
    self:setTextByLanKey("title_text", "prestige_bag_text_003")
    self:setTextByLanKey("sort_text1", "prestige_bag_text_001")
    
    --排序绑定
    self.selected_img_tab = {}
    for i = 1, 6 do
        table.insert(self.selected_img_tab, self:findGameObject("img_select_".. i))
        self:setTextByLanKey("txt_sort_" .. i, "prestige_sort_text_00" .. i)
        local btn_item = self:findGameObject("btn_sort_" .. i)
        UIUtil.setButtonClick(btn_item, function()
            self.m_control:onSortGridList(i)
        end)
    end
end

function M:refreshView()
    local block_data = self.m_model:getViewList()
    self.m_model.self_time_data = {}
    self:setTextByLanKey("gridcount_txt", "prestige_bag_text_002", #block_data)
    if self.m_block_scroll == nil then
        local list_scroll = self:findGameObject("block_scroll")
        local params = {
            one_line_count = 6,
            show_data = block_data,
            loop_scroll_object = list_scroll,
            --init_cell = function(index, cell_object)
            --    table.insert(self.grid_item_list, cell_object)
            --end,
            update_cell = function(index, cell_object, cell_data)
                self:updateBlockInfo(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:OnClickGridItem(index, cell_object, cell_data)
            end
        }
        self.m_block_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_block_scroll:reloadData(block_data, true)
    end
end

function M:updateBlockInfo(cell_index, cell_object, cell_data)
    local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
    self.m_model.self_time_data[cell_object] = {luaBehaviour = luaBehaviour,cell_index= cell_index,cell_data = cell_data.data,cell_object = cell_object}
    -- 冲突状态
    --local is_conflict = self.m_model:isBlockInConflict(cell_data.id)
    --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "conflict_block_effect", is_conflict)
    -- 装备状态
    
    local state = cell_data.state
    local cell_data = cell_data.data
    
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "equipped_mask", cell_data.status ~= 0)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "selected_mask", state == 1)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "equipment_text", "prestige_bag_text_004")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "selected_text", "prestige_bag_text_005")
    
    -- 星级
    local star = self.m_model:getStarByShape(cell_data.shape)
    local posX = -32
    for i = 1,5 do
        local starObj = luaBehaviour:FindGameObject("star" .. i)
        if starObj ~= nil then
            starObj:SetActive(i <= star)
            starObj.transform.localPosition = Vector3(posX, 0,0)
            if star < 5 then
                posX = posX + 32
            elseif star == 5 then
                posX = posX + 25
            end
        end
    end
    -- 英雄头像
    local bg_name = "a_ui_currency_ws_jin_small" or cell_data.bg_name
    local avatar_name = "TX_" .. cell_data.hero
    LuaBehaviourUtil.setImg(luaBehaviour, "hero_bg", bg_name, "hero_head_ui")
    LuaBehaviourUtil.setImg(luaBehaviour, "hero_avatar", avatar_name, "hero_head_ui")
    -- 过期时间
    local times = cell_data.times
    if times > 0 then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "time_text", true)
        local time_text = luaBehaviour:FindText("time_text")
        local remain_day, remain_hour, remain_min = GameUtil:getTimeLayoutBySecond(times)
        if remain_day >= 1 then
            LuaBehaviourUtil.setText(luaBehaviour,"time_text",string.format("%d天", remain_day))
        elseif remain_hour >= 1 then
            LuaBehaviourUtil.setText(luaBehaviour,"time_text",string.format("%d小时", remain_hour))
        else
            LuaBehaviourUtil.setText(luaBehaviour,"time_text",string.format("%d分钟", remain_min))
        end
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "time_text", false)
    end
    -- 棋子词缀
    local affixes = {}
    for _,v in pairs(cell_data.affix) do
        for _,j in pairs(v) do
            local attr = self.m_model:getAttrByAffixID(j)
            local name = UserDataManager:getNewAttrsNameByAttrId(attr[1])
            local value = attr[2]
            table.insert(affixes, {name, value})
        end
    end
    for i = 1,3 do
        local affix = affixes[i]
        if affix then
            local name_text = affix[1]
            local value_text = affix[2] < 1 and (affix[2] * 100) .. "%" or tostring(affix[2])
            local affix_text = name_text .. "+" .. value_text
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "effect_text" .. i, true)
            LuaBehaviourUtil.setText(luaBehaviour,"effect_text" .. i, affix_text)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "effect_text" .. i, false)
        end
    end
    
    -- todo：棋子形状 —— 使用对象池优化
    local mini_grid = luaBehaviour:FindGameObject("mini_grid")
    UIUtil.destroyAllChild(mini_grid.transform)
    local mini_block = self.m_control.block_manager:generateMiniBlock(cell_data, mini_grid)
    local block_transform = mini_block:getTransform()
    local anchor_point = self.m_model:getAnchorPointOfBlockShape(cell_data.shape)
    local pos = self:getPosOnMiniGrid(anchor_point)
    block_transform.localPosition = pos
    -- 拖动回调
    --local scrollRectClick = luaBehaviour.gameObject:GetComponent("ScrollRectClick")
    --if scrollRectClick then
    --    local btn = luaBehaviour.gameObject:GetComponent("Button")
    --    btn.enabled = false
    --    scrollRectClick.index = cell_index
    --    scrollRectClick:RegistClickCallBack(
    --            function(click_type, index)
    --                if click_type == 3 and cell_data.status == 0 then
    --                    local params = {
    --                        block_data = cell_data,
    --                        grid_obj = self.m_grid_obj
    --                    }
    --                    self:updateMsg("create_block", params)
    --                end
    --            end
    --    )
    --end
end

function M:getPosOnMiniGrid(anchor_point)
    return self:getMiniBoardLocalPosBySlotIndex(anchor_point[1], anchor_point[2])
end

-- 根据格子索引值，获取棋盘相对位置坐标
function M:getMiniBoardLocalPosBySlotIndex(index_row, index_column)
    local local_pos_x = (index_column - 2.5) * __MINI_SLOT_SIDE_LENGTH
    local local_pos_y = (2.5 - index_row) * __MINI_SLOT_SIDE_LENGTH
    local local_pos = Vector3(local_pos_x, local_pos_y, 0)
    return local_pos
end

--function M:RefreshSelectedState(state)
--    for _, v in pairs(self.grid_item_list) do
--        local luaBehaviour = v:GetComponent("LuaBehaviour")
--        local equipObj = LuaBehaviourUtil.findGameObject(luaBehaviour, "equipped_mask")
--        if equipObj.activeSelf == false then
--            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "selected_mask", state)    
--        end
--    end
--end

function M:OnClickGridItem(cell_index, cell_object, cell_data)
    if cell_data.data.status ~= 0 then
        Logger.log("===============已装备")
        return
    end

    if cell_data.data.expire > 0 then
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("prestige_bag_text_007"), delay_close = 2})
        return
    end

    cell_data.state = cell_data.state == 0 and 1 or 0
    
    local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
    local obj = LuaBehaviourUtil.findGameObject(luaBehaviour, "selected_mask")
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "selected_mask", cell_data.state == 1)

    local flagObj = self:findGameObject("selected_img")
    if cell_data.state ~= 1 and flagObj.activeSelf then
        self:setObjectVisible("selected_img", false)
        self.m_control.is_all_selected = false
    end

    self.m_control:onSelectedSingleGrid(cell_data.data.id)
end

function M:onRefreshSortNode()
    self:setObjectVisible("sort_list1", false)
    local type = self.m_model.view_sort_type
    self:setTextByLanKey("sort_text1", "prestige_sort_text_00" .. type)
    for k, v in ipairs(self.selected_img_tab) do
        v:SetActive(k == tonumber(type))
    end
    self:refreshView()
    self:sliderTopFirstIndex()
end

function M:sliderTopFirstIndex()
    if self.m_block_scroll ~= nil then
        local data = self.m_model:getViewList()
        if #data > 0 then
            self.m_block_scroll:moveToCellIndex(1)
        end
    end
end

function M:UpdateDataTimeView()
    for k,v in pairs(self.m_model.self_time_data) do
        local times = v.cell_data.times
        Logger.logAlways("-------------------------------- current_time_S:"..tostring(times))
        if times > 0 then
            LuaBehaviourUtil.setObjectVisible( v.luaBehaviour, "time_text", true)
            local remain_day, remain_hour, remain_min ,sec= GameUtil:getTimeLayoutBySecond(times)
            Logger.logAlways("-------------------------------- current_time:"..tostring(sec))
            if remain_day >= 1 then
                LuaBehaviourUtil.setText(v.luaBehaviour,"time_text",string.format("%d天", remain_day))
            elseif remain_hour >= 1 then
                LuaBehaviourUtil.setText(v.luaBehaviour,"time_text",string.format("%d小时", remain_hour))
            else
                LuaBehaviourUtil.setText(v.luaBehaviour,"time_text",string.format("%d分钟", remain_min))
            end
        else
            LuaBehaviourUtil.setObjectVisible(v.luaBehaviour, "time_text", false)
        end
    end
end
return M