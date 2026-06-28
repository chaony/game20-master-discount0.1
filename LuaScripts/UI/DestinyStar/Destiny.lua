local M = class("Destiny", LikeOO.OOUIbase)

--天命化星 天命
M.m_uiName = "DestinyStar/Destiny"

function M:onEnter()
    self.hui_material = self:findImage("hui_img").material
    self.trans_01 = self:findGameObject("select1_panel").transform
    self.trans_02 = self:findGameObject("select2_panel").transform
    self.trans_03 = self:findGameObject("select3_panel").transform
    self.derstand_btn = self:findButton("derstand_btn")
    self.derstand_btn_img = self:findImage("derstand_btn")
    self:setTextByLanKey("derstand_text","destinyStar_text_0003")
    self.understand_isNo = self:findGameObject("understand_isNo") --不可领悟
    self.understand_isOk = self:findGameObject("understand_isOk") --可领悟
    self.understand_isComplete = self:findGameObject("understand_isComplete") --领悟成功
end

--刷新UI
function M:refreshUI()
    self:refreshHero()
end

--刷新信息
function M:refreshInfo(cell_data)
    self:setObjectVisible("people_hero_bg", true)
    self:setObjectVisible("value_text_1", true)
    self:setObjectVisible("value_text_2", true)
    self:setObjectVisible("value_text_3", true)
    self:setObjectVisible("value_text_4", true)
    self:setObjectVisible("left_Img_zi_suo", true)
    self:setObjectVisible("center_Img_zi_suo", true)
    self:setObjectVisible("right_Img_zi_suo", true)
    self:setObjectVisible("right_Img_zi_ok", true)
    self:setObjectVisible("center_Img_zi_ok", true)
    self:setObjectVisible("left_Img_zi_ok", true)
    self:setObjectVisible("derstand_btn", true)
    self:setTextByLanKey("complete_text","destinyStar_text_0002")
    local poetry_info = self.m_model:getPoetry(cell_data.data.id) or {}
    --local hero_picture = poetry_info.hero_picture or "a_tmhx_tianming_juese" --剪影
    local hero_des1 = Language:getTextByKey(poetry_info.des1) or "destinyStar_text_0004" --前两句
    local hero_des2 = Language:getTextByKey(poetry_info.des2) or "destinyStar_text_0005" --后两句
    local des = {}
    local des_1 = string.split(hero_des1,"/n")
    local des_2 = string.split(hero_des2,"/n")
    for i, v in ipairs(des_1) do
        table.insert(des,v)
    end
    for i, v in ipairs(des_2) do
        table.insert(des,v)
    end
    for i, v in ipairs(des) do --设置诗文本
        local show_text = "value_text_"..i
        self:setTextByLanKey(show_text, v)
    end
    --设置剪影 (变成spine)
    local Img_bg = self:findGameObject("people_hero_bg")
    --GameUtil:updateResourcesImg(Img_bg,"Texture/worldProgress/"..hero_picture)
    local spine_name = cell_data.cfg.hero_spine
    if cell_data.data.skin ~= nil then
        spine_name = self.m_model:getHeroSkin(cell_data.data.skin)
    end
    GameUtil:updateSpineLoadSet(Img_bg,"RoleSpine/" .. spine_name,"idle", 0,true)
    --设置天命星辰icon
    local start_icon_name = self.m_model:getStarIcon(cell_data.data.id)
    local start_icon_img = self:findGameObject("destiny_icon")
    if start_icon_name ~= 0 then
        GameUtil:updateResourcesImg(start_icon_img,"Texture/zh_cn/tmhx_start/"..start_icon_name)
    end
    --显示材料卡信息
    local same_id_heros, universal = self.m_model:getEvoSixHeroList(cell_data.data.id)
    self.m_model.material = same_id_heros
    --设置第一个位置显示（材料英雄）
    local flag_1 = #same_id_heros >= 1
    if flag_1 == false and universal then
        flag_1 =  universal.user_num >= universal.data_num
    end
    self:setHeroIcon(cell_data.data.id,self.trans_01,flag_1,1, universal,same_id_heros)
    --设置第二个位置显示（材料道具）
    local fate_cost = self.m_model:getFateCost(cell_data.data.id)
    local itemData = RewardUtil:getProcessRewardData(fate_cost[1])
    self:setHeroIcon(fate_cost[1],self.trans_02,itemData.user_num >= itemData.data_num ,2)
    --设置第三个位置显示（材料英雄）
    local flag_3 = #same_id_heros >= 2
    if flag_3 == false and universal then
        flag_3 =  universal.user_num >= (2 - #same_id_heros) * universal.data_num
    end
    self:setHeroIcon(cell_data.data.id,self.trans_03,flag_3,3, universal,same_id_heros)
end

--设置材料消耗icon
function M:setHeroIcon(id,fater_trans,is_setopacity,pos_id,universal,same_id_heros)
    local icon, ui_element = 1,1
    local scale_value = 0.5
    if pos_id == 2 then
        icon, ui_element = GameUtil:createItemElement(id,true,true,nil)
        scale_value = 0.8
        local Item_LuaBehaviour = UIUtil.findLuaBehaviour(icon)
        local count_text = Item_LuaBehaviour:FindText("count_text")
        local item_img = Item_LuaBehaviour:FindImage("item_img")
        local quality_img = Item_LuaBehaviour:FindImage("quality_img")
        if is_setopacity then
            count_text.color = Color.New(1,1,1)
            item_img.material = nil
            quality_img.material = nil
        else
            count_text.color = Color.New(1,0,0)
            item_img.material = self.hui_material
            quality_img.material = self.hui_material
        end
    else
        local num = pos_id == 1 and 1 or 2
        if is_setopacity then
            if #same_id_heros >= num then
                icon, ui_element = CommonUIUtil:createHeroElement({RewardUtil.REWARD_TYPE_KEYS.HEROS,id,1,quality = 6}, false, false)
            else
                icon, ui_element = GameUtil:createItemElementByData(universal, true,true)
                scale_value = 0.8
            end
        else
            icon, ui_element = CommonUIUtil:createHeroElement({RewardUtil.REWARD_TYPE_KEYS.HEROS,id,1,quality = 6}, false, false)
        end 
        
        local opacity_value = is_setopacity and 1 or 0.6
        UIUtil.setOpacity(icon.transform,opacity_value)
    end
    UIUtil.destroyAllChild(fater_trans)
    icon.transform:SetParent(fater_trans, false)
    UIUtil.setLocalScale(icon.transform, scale_value, scale_value, scale_value)
end

--刷新状态
function M:refreshHeroState(state)
    local understand_isNo_active = false
    local understand_isOk_active = false
    local understand_isComplete_active = false
    local start_icon_active = false --天命icon
    if state == 1 then --不可领悟
        understand_isNo_active = true
    elseif state == 0 then --可以领悟
        understand_isOk_active = true
    elseif state == 2 then --领悟完成
        understand_isComplete_active = true
        start_icon_active = true
    end
    --天命icon状态
    local start_icon_img = self:findImage("destiny_icon")
    if start_icon_active then
        start_icon_img.material = nil
    else
        start_icon_img.material = self.hui_material
    end
    --self.understand_isNo.gameObject:SetActive(understand_isNo_active)
    self.understand_isOk.gameObject:SetActive(understand_isOk_active or understand_isNo_active)
    self.understand_isComplete.gameObject:SetActive(understand_isComplete_active)
    --领悟按钮状态设置
    --self.derstand_btn.interactable = understand_isOk_active
    if understand_isOk_active then --可以领悟
        self.derstand_btn_img.material = nil
    else
        self.derstand_btn_img.material = self.hui_material
    end
end

--刷新英雄天命状态
function M:refreshFateState(cell_data,state)
    --功力至臻
    local evo_isok = self.m_model:heroEvoIsOk(cell_data.data.evo)
    self:setObjectVisible("right_Img_zi_suo",not evo_isok)
    self:setObjectVisible("right_Img_zi_ok",evo_isok)
    self:setObjectVisible("UI_Destiny_003",state == 2)
    --经脉畅通
    local sig_isok = self.m_model:heroSigIsOk(cell_data.data.sig)
    self:setObjectVisible("left_Img_zi_suo",not sig_isok)
    self:setObjectVisible("left_Img_zi_ok",sig_isok)
    self:setObjectVisible("UI_Destiny_002",state == 2)
    --情缘已了
    local friend_isok = self.m_model:heroFriendIsOk(cell_data.data.id)
    self:setObjectVisible("center_Img_zi_suo",not friend_isok)
    self:setObjectVisible("center_Img_zi_ok",friend_isok)
    self:setObjectVisible("UI_Destiny_004",state == 2)
end

--刷新英雄
function M:refreshHero()
    self.m_click_cell_object = nil
    local data = self.m_model.hero_table
    if self.m_model.select_hero_id ~= 0 then --有指定英雄
        self.m_model:showSelectHero(self.m_model.select_hero_id,data)
        --self.m_model.select_hero_id = 0
    end
    if data ~= nil and data[self.m_model.currentHeroIndex] ~= nil then
        self:setHeroState(data[self.m_model.currentHeroIndex])
    end
    if self.m_rightloop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll_node")
        local params = {
            show_data = data,
            one_line_count = 2,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                --local transform = cell_object.transform
                if luaBehaviour then
                    local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, cell_data.data.id, 1, cell_data.data.oid})
                    GameUtil:updateItemElementByData(cell_object, itemData)
                    --GameUtil:updateHeroStarsByQuality(cell_object, itemData.quality)
                    GameUtil:updateHeroInfo(cell_object, itemData)
                    if index == self.m_model.currentHeroIndex then
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", true)
                    else
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", false)
                    end
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("select_hero", {index = index,data = cell_data})
            end
        }
        self.m_rightloop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_rightloop_scroll_view:reloadData(data, true)
    end
end

--设置展示英雄状态
function M:setHeroState(show_data)
    self:refreshInfo(show_data)
    local state = self.m_model:filtrateHero(show_data) --领悟状态
    self.m_model.state = state
    self:refreshHeroState(state)
    self:refreshFateState(show_data,state)
    if state == 2 then
        self:setObjectVisible("select_panel", false)
    else
        self:setObjectVisible("select_panel", true)
    end
end

--设置点亮天命
function M:setDerstand()
    audio:SendEvtUI("UI_TM_Sfx")
    self:setObjectVisible("UI_Destiny_001",true)
    self:setObjectVisible("hero_Img",false)
    self:setObjectVisible("mask_img",true)
    self.m_control:setOnceTimer(4.1, function()
        self:setObjectVisible("hero_Img",true)
        self:setObjectVisible("UI_Destiny_001",false)
        self:setObjectVisible("mask_img",false)
        self.m_control:getHeroEnable()
    end)
end

return M