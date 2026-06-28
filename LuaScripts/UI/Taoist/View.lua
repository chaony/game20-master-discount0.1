local M = class("TaoistMainView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "Taoist/TaoistMain"
M.m_iphoneXAdapter = true

local ACTIVE_TAOIST_TAB = {
    {open_id = 158,name_key = "tid#OpenConditionName_158",type_key = 1,open = true}, --梅花桩
    {open_id = 159,name_key = "tid#OpenConditionName_159",type_key = 2,open = true}, --铜人阵
    {open_id = 160,name_key = "tid#OpenConditionName_160",type_key = 3,open = true}, --达摩洞
    {open_id = 210,name_key = "tid#OpenConditionName_210",type_key = 5,open = true}, --千佛崖
    {open_id = 214,name_key = "tid#OpenConditionName_214",type_key = 6,open = true}, --金刚台
    {open_id = 161,name_key = "tid#OpenConditionName_161",type_key = 4,open = true}, --藏经阁
    {open_id = 435,name_key = "tid#OpenConditionName_435",type_key = 7,open = true}, --藏经阁
}

function M:onEnter()
    self.level_Img = self:findGameObject("level_Img") --关卡图
    self.level_name_Img = self:findGameObject("level_name_Img") --关卡名
    self.goto_btn = self:findGameObject("goto_btn_all") --挑战按钮
    self.receive_btn = self:findGameObject("receive_btn_all") --碾压按钮 
    self.Moppingup_btn = self:findGameObject("mopping_vertical_all") --扫荡按钮
    self.Moppingup_btn_hui = self:findGameObject("Moppingup_btn_hui_all") --扫荡灰按钮
    self.cost_node = self:findGameObject("cost_node_all") --付费消耗
    self.auto_sweep_vertical = self:findGameObject("auto_sweep_vertical") --一键扫荡父物体
    self.cost_node_auto_sweep = self:findGameObject("cost_node_auto_sweep") --一键扫荡付费消耗
    self.Auto_sweep_btn = self:findGameObject("Auto_sweep_btn") --一键扫荡按钮
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 16})
    self:setTextByLanKey("goto_btn_text","new_str_0386") --挑战
    self:setTextByLanKey("receive_btn_text","new_str_0811") --碾压
    self:setTextByLanKey("Moppingup_btn_text","new_str_0573") --扫荡
    self:setTextByLanKey("Moppingup_btn_hui_text","new_str_0573") --扫荡灰
    self:setTextByLanKey("Auto_sweep_btn_text","new_str_0965") --全部扫荡
    self.auto_sweep_vertical.gameObject:SetActive(false) --一键扫荡隐藏
    self.Tab_Node = ACTIVE_TAOIST_TAB
    self:benginDisplayLevelName()
    self:CurrentComplet()
    self:refreshUI()
    self:setTextByLanKey("close_title_text","world_str_012")
    local user_status_text = Language:getTextByKey("new_str_0930",tostring(UserDataManager.user_data:getUserStatusDataByKey("full_combat")))
    self:setTextByLanKey("my_user_statue",user_status_text)
    --self.surplusNum = self.m_model:getCommonData() --剩余扫荡次数
    self:retreshScroll()
    self.cur_select_index = 0
    self.old_select_index = 0
end

--刷新当前挑战数据
function M:refreshCurrentlevel()
    self.m_model.current_level_sweep = self.m_model:currentBattle() --最大可扫荡层数
    if self.m_model.current_level_sweep then
        self.m_model.current_level_battle = self.m_model:getNextBattleOrder(self.m_model.current_level_sweep) --当前可挑战层
        if self.m_model.current_level_battle == 0 then
            self.m_model.current_level_battle = self.m_model.current_level_sweep
        end
    else
        self.m_model.current_level_battle = self.m_model:currentBattleID(self.current_complet,self.m_model.current_playing) --当前可挑战层
    end
    
    self.m_model.current_level_battle_data = self.m_model:getCurrentLevelData(self.m_model.current_level_battle) --当前可挑战层数据
    self.m_model.current_level_battle_index = self.m_model:currentBattleIndex(self.m_model.current_level_battle,self.m_model.current_playing)
end

--当前高亮关卡
function M:CurrentComplet()
    self.current_complet = self.m_model:currentBattleLevel() or 1 --当前可挑战
    local data = self.m_model:getLevelData(self.m_model.current_playing)
    if self.current_complet == 1 and self.m_model:currentBattle() == false then
        self.current_complet = 1
    elseif data[self.current_complet + 1] ~= nil then
        self.current_complet = self.current_complet + 1
    else
        if data[self.current_complet] == nil then
            self.current_complet = 1
        end
    end
    self.m_model.current_choice_level = {index = self.current_complet,cell_data = data[self.current_complet]}
end

--刷新
function M:refreshUI()
    self:refreshCurrentlevel()
    --更新扫荡次数
    self:moppingNum()
    --更新关卡名称列表
    self:updatePlayingNameLoopScroll()
    --更新关卡列表
    self:updateLevelLoopScroll()
    --刷新按钮
    self:refreshBtn()
    --刷新列表
    self:loopsScrollUp()
    --一键扫荡按钮
    self:autoSweep()

    --快速导航
    self:setObjectVisible("guide_btn", true)
end

--刷新滑动条位置
function M:retreshScroll()
    self.current_complet = self.m_model:currentBattleLevel() or 1 --当前可挑战
    if self.m_level_loop_scroll_view ~= nil then
        self.m_level_loop_scroll_view:moveToCellIndex(self.current_complet)
    end
end

--开始状态显示位置
function M:benginDisplayLevelName()
    local playingName = self.m_model:getPlayingNameData(self.Tab_Node)
    for i, v in ipairs(playingName) do
        local open_id = self:getOpenId(v.type)
        local race_open_flag = BtnOpenUtil:isBtnOpen(open_id)
        local red_point = self.m_model:isHasRed(v.type)
        if red_point and race_open_flag then
            self.m_model.current_playing = v.type
            return 
        end
    end
end

--更新扫荡次数
function M:moppingNum()
    self.free_number = self.m_model:getCommonData() --设定免费扫荡次数
    self.pay_number = self.m_model:getVipPayNum(self.m_model.current_playing) --付费挑战次数
    self.total_number = self.free_number + self.pay_number --总次数
    self.usedNum = self.m_model:getUsedMoppingNum(self.m_model.current_playing) --已使用扫荡次数
    self.surplusNum = self.total_number -  self.usedNum --可使用次数
    local battle_num_text = 0
    if self.surplusNum > self.pay_number then
        battle_num_text = Language:getTextByKey("new_str_0870",self.free_number - self.usedNum)
    else
        battle_num_text = Language:getTextByKey("new_str_0871",self.surplusNum)
        --battle_num_text = "今日付费扫荡次数"..self.surplusNum.."次"
    end
    self:setTextByLanKey("battle_num_text",battle_num_text)
end

--创建玩法名称列表
function M:updatePlayingNameLoopScroll()
    self.m_PlayingName_click_cell_object = nil
    local data = self.m_model:getPlayingNameData(self.Tab_Node)
    if self.m_PlayingName_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("levelname_loopscroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index,cell_object,cell_data)
                self:updatePlayingNameScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index,cell_object,cell_data,click_object,click_name)
                self:updateMsg("playing", {id = index, cell_data = cell_data,open_id = self:getOpenId(cell_data.type)})
                self.cur_select_index = index
            end
        }
        self.m_PlayingName_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_PlayingName_loop_scroll_view:reloadData(data,true)
        if self.cur_select_index and self.old_select_index and self.old_select_index ~= self.cur_select_index then
            self.m_PlayingName_loop_scroll_view:moveToCellIndex(self.cur_select_index)
            self.old_select_index = self.cur_select_index
        end
    end
end

--玩法名称列表更新
function M:updatePlayingNameScrollViewCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local transform = cell_object.transform
    --设置基本信息
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"choice_levelname_btn_text",cell_data.name) --设置名称
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"levelname_btn_text",cell_data.name) --设置名称
    local Img_bg = luaBehaviour:FindGameObject("Background") --背景图1
    local check_Img = luaBehaviour:FindGameObject("check_Img") --背景图2
    GameUtil:updateResourcesImg(Img_bg,"Texture/worldProgress/"..cell_data.picture) --设置图片
    GameUtil:updateResourcesImg(check_Img,"Texture/worldProgress/"..cell_data.picture) --设置图片
    
    
    --设置当前状态
    local choice_Img_show = false
    local current_open_id = self:getOpenId(cell_data.type)
    local race_open_flag = BtnOpenUtil:isBtnOpen(current_open_id)

    if cell_data.type == self.m_model.current_playing then
        choice_Img_show = true
    end

    --红点显示
    local red_point_show = false

    if race_open_flag then --当前开启
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_Img", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_Img", false)
        if self.m_model:isHasRed(cell_data.type) then --有免费扫荡次数
            red_point_show = true
        end
    else
        local level = self.m_model:getLockLevel(current_open_id)
        --local lock_level_text = "通关"..level.."解锁"
        local lock_level_text = Language:getTextByKey("new_str_0872",level)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"lock_text",lock_level_text) --通关解锁关卡
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_Img", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_Img", true)
    end
    
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "levelname_red_point_img", red_point_show)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "choice_Img", choice_Img_show)

end

--创建关卡列表
function M:updateLevelLoopScroll()
    self.m_level_click_cell_object = nil
    local data = self.m_model:getLevelData(self.m_model.current_playing)
    if self.m_level_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("level_loopscroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index,cell_object,cell_data)
                self:updateLevelScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index,cell_object,cell_data,click_object,click_name)
                --self:updateMsg("level", {index = index, cell_data = cell_data})
            end
        }
        self.m_level_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_level_loop_scroll_view:reloadData(data,true)
    end
end

--关卡列表更新
function M:updateLevelScrollViewCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local transform = cell_object.transform
    
    local cfg = cell_data.cfg
    
    --固定文本
    local level_text = Language:getTextByKey("new_str_0869",cfg.order)
    UIUtil.setTextByLanKey(transform,"level_num_text", level_text) --设置层数
    UIUtil.setTextByLanKey(transform,"Recommendedpower_text", "new_str_0873") --推荐战力
    UIUtil.setTextByLanKey(transform,"combat_text", cfg.bs1) --推荐战力数值
    UIUtil.setTextByLanKey(transform,"goto_btn_text", "new_str_0386") --挑战
    UIUtil.setTextByLanKey(transform,"receive_btn_text", "new_str_0811") --碾压
    UIUtil.setTextByLanKey(transform,"Moppingup_btn_text", "new_str_0573") --扫荡
    
    --关卡背景设置
    local bg_name = "a_wdc_lingqukuang"
    if tonumber(cfg.tier) == 2 then
        bg_name = "a_wdc_lingqukuang2"
    end
    local Img_bg = luaBehaviour:FindGameObject("level_Item_bg")
    GameUtil:updateResourcesImg(Img_bg,"Texture/"..bg_name)
    
    --设置付费扫荡消耗
    local old_price = self.m_model:getPayBattleCost()
    local price = old_price
    if cell_data.cfg ~= nil and cell_data.cfg.cost ~= nil then
        price = cell_data.cfg.cost[1] or old_price
    end
    local itemData = RewardUtil:getProcessRewardData(price)
    self:setImg(itemData.icon_name, "item_icon", "cost_img_all")--设置元宝图标
    self:setTextByLanKey("cost_num_text_all",GameUtil:formatValueToString(itemData.data_num))--设置元宝数量
    

    --奖励
    local reward = cfg.reward or {}
    local reward_node = luaBehaviour:FindGameObject("reward_node")
    local reward_element = GameUtil:createRewards(reward_node.transform,reward,true,true,nil,1)
    for i = 1, #reward_element do
        local reward_item = reward_element[i]
        local itemLuabehaviour = UIUtil.findLuaBehaviour(reward_item)
        local show_flag = false
        if GameUtil:checkDoubleActiveByType(5) == true then
            show_flag = true
        end
        LuaBehaviourUtil.setObjectVisible(itemLuabehaviour, "double_earn", show_flag)
    end
    
    local lock_text_show = false
   
    
    --设置按钮状态
    
    --[[
    战力1.0版本
    
    local atk_team = UserDataManager.hero_data:getTeamByKey("raid", "stage") --队伍
    local combat = 0 --战力
    for k, v in pairs(atk_team) do
        local data, cfg = self:getHero(v)
        if data ~= nil then
            combat = data.combat + combat
        end
    end
    --]]
    
    
    --高亮显示，并显示下方按钮
    if self.m_model.current_choice_level.index == index then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "choice_Img", true)
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "choice_Img", false)
    end

    local params = {
        index = index,
        cell_data = cell_data
    }
    if cell_data.id > self.m_model.current_level_battle then
        lock_text_show = true
    end
    if lock_text_show then --未解锁
        local last_level = index - 1
        --local lock_text =  "通关第"..last_level.."层解锁"
        local lock_text =  Language:getTextByKey("new_str_0609",last_level)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"task_lock_text",lock_text) --解锁提示
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "task_lock_Img", lock_text_show)

end

--刷新按钮
function M:refreshBtn()
    --按钮
    local goto_btn_show = false
    local receive_btn_show = false
    local Moppingup_btn_show = false
    local lock_text_show = false
    local cost_node_show = false
    local Moppingup_btn_hui_show = false

    --战力2.0版本
    local user = UserDataManager.user_data.user_status
    local combat = user.full_combat or 0

    local isBattle = self.m_model:ishasBattle(self.m_model.current_level_battle)

    local usedNum = self.m_model:getUsedMoppingNum(self.m_model.current_playing) --已使用扫荡次数
    
    
    --扫荡按钮
    if self.surplusNum == 0 then --没有扫荡次数
        Moppingup_btn_hui_show = true
    else
        if not self.m_model.current_level_sweep then --没有可扫荡关卡
            Moppingup_btn_hui_show = true
        else
            Moppingup_btn_show = true
            local num = self.free_number - self.usedNum --免费扫荡剩余次数
            if num <= 0 then
                cost_node_show = true
            end
        end
    end
    
    local material_hui = self:findImage("Moppingup_btn_hui_all")
    local goto_btn = self:findImage("goto_btn_all")
    --挑战按钮
    if isBattle then --挑战过,挑战按钮置灰
        goto_btn_show = true
        goto_btn.material = material_hui.material
    else --没挑战过
        if combat > self.m_model.current_level_battle_data.cfg.bs2 then --碾压
            receive_btn_show = true
        else --挑战
            goto_btn_show = true
            goto_btn.material = nil
        end
    end

    --高亮显示，并显示下方按钮
   
    self.goto_btn.gameObject:SetActive(goto_btn_show) --挑战按钮
    self.receive_btn.gameObject:SetActive(receive_btn_show) --碾压按钮 
    self.Moppingup_btn.gameObject:SetActive(Moppingup_btn_show) --扫荡按钮
    self.Moppingup_btn_hui.gameObject:SetActive(Moppingup_btn_hui_show) --扫荡灰按钮
    self.cost_node.gameObject:SetActive(cost_node_show) --付费消耗
    --设置付费扫荡消耗
    local old_price = self.m_model:getPayBattleCost()
    local price = old_price
    if self.m_model.current_level_battle_data.cfg ~= nil and self.m_model.current_level_battle_data.cfg.cost ~= nil then
        price = self.m_model.current_level_battle_data.cfg.cost[1] or old_price
    end
    local itemData = RewardUtil:getProcessRewardData(price)
    self:setImg(itemData.icon_name, "item_icon", "cost_node/cost_img") --设置元宝图标
    self:setTextByLanKey("cost_num_text", GameUtil:formatValueToString(itemData.data_num)) --设置元宝数量

    -- 全部扫荡按钮置灰
    local isHasAutoSweepNum,cost = self.m_model:isHasAutoSweepNum(self.Tab_Node)
    local auto_sweep_btn_img = self:findImage("Auto_sweep_btn")
    if isHasAutoSweepNum then
        auto_sweep_btn_img.material = nil
    else
        auto_sweep_btn_img.material = material_hui.material
    end

    return lock_text_show
end

--获取open_id
function M:getOpenId(type)
    for i, v in pairs(self.Tab_Node) do
        if v.type_key == type then
            return v.open_id
        end
    end
end

--根据id获得英雄数据
function M:getHero(id)
    local hero_data, hero_cfg = nil
    hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(id)
    return hero_data, hero_cfg
end

function M:destroy()
    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
    M.super.destroy(self)
end

--设置关卡图片
function M:setPicture(pictureName)
    self.picture = "Texture/worldProgress/"..pictureName
    self.name_picture = "Texture/worldProgress/"..pictureName.."_zi"
    --设置图片，更新关卡名称
    GameUtil:updateResourcesImg(self.level_Img,self.picture) --设置关卡图片
    GameUtil:updateResourcesImg(self.level_name_Img,self.name_picture) --设置关卡名称
end

--列表上移
function M:loopsScrollUp()
    if self.cell_size_y == nil then
        local level_loopscroll = self:findGameObject("level_loopscroll")
        local loop_scroll_view = level_loopscroll:GetComponent("LoopScrollView")
        self.cell_size_y = loop_scroll_view.cellSize.y --item高度
        local rect_transform = self:findRectTransform("level_loopscroll")
        self.level_loopscroll_height = rect_transform.transform.sizeDelta.y --可显示高度
    end
    if self.m_level_loop_scroll_view ~= nil then
        local position = self.m_level_loop_scroll_view:getContentOffset()
        local maxScrol = #self.m_model:getLevelData(self.m_model.current_playing)
        local max_height = maxScrol * self.cell_size_y
        local min_height = max_height - self.level_loopscroll_height
        local offer = position.y
        local max_level = (max_height + offer)/self.cell_size_y
        local min_level = ((min_height + offer)/self.cell_size_y) + 1
        if self.m_model.current_level_battle_index < min_level or self.m_model.current_level_battle_index > max_level then
            self.m_level_loop_scroll_view:moveToCellIndex(self.m_model.current_level_battle_index)
        end
    end
end

--自动扫荡
function M:autoSweep()
    local isComleteAllState = self:isComleteAllState()
    if isComleteAllState then
        self.auto_sweep_vertical.gameObject:SetActive(true)
        local isHasAutoSweepNum,cost,cost_name = self.m_model:isHasAutoSweepNum(self.Tab_Node)
        if isHasAutoSweepNum and cost > 0  then
            self.is_buy = 1
            --self.cost_node_auto_sweep.gameObject:SetActive(true)
            --self:setImg(cost_name, "item_icon", "cost_node/cost_img") --设置元宝图标
            --self:setTextByLanKey("cost_num_text_auto_sweep", cost) --设置元宝数量
        else
            self.is_buy = 0
            --self.cost_node_auto_sweep.gameObject:SetActive(false)
        end
    end
end

--是否挑战过所有关卡
function M:isComleteAllState()
    for i, v in ipairs(self.Tab_Node) do
        local max_level = self.m_model:maxStateLevel(v.type_key)
        local battle_level = self.m_model:currentBattleIndex(self.m_model.m_data.raids[tostring(v.type_key)],v.type_key)
        if battle_level >= max_level then
            return true
        end
    end
    return false
end

return M