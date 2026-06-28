---@class BudoView:OOPopBase
local M = class("BudoView", LikeOO.OOPopBase)

M.m_uiName = "Budo/Budo"
M.m_size_type = 1
M.enemy_hero_list = {}
M.m_iphoneXAdapter = true

function M:create()
    M.super.create(self)
    local new_rate = self.m_control.m_view.m_bg_scale
    if self.m_model.m_tower_type == 0 then
        UserDataManager:removeRedDotByKey("task_red_point_1013")
    else
        UserDataManager:removeRedDotByKey("tower_race_once_"..self.m_model.m_tower_type)
    end
end

function M:onEnter()
    self.scroll_obj = {}
    self.role_parent = self:findGameObject("role_3d")
    self.player_img = self:findGameObject("player_img")
    if self.player_img then
        local canvas = self.player_img:GetComponent("Canvas")
        if not IsNull(canvas) then
            canvas.sortingOrder = self.m_sortOrder +1
        end
    end
    if self.m_model.m_tower_type == 0 then
        self:setTextByLanKey("close_title_text", "world_str_009")
    else
        local tab_tower = ConfigManager:getCfgByName("tower_race")
        local tower_name = Language:getTextByKey(tab_tower[self.m_model.m_tower_type].name)
        self:setTextByLanKey("close_title_text", tower_name)
    end

    self:setTextByLanKey("shili_name", "budo_czsl_tex")
    self:setTextByLanKey("enemy_count", "biography_str_006")
    self:setTextByLanKey("reward_count", "biography_str_007")
    self:setTextByLanKey("challenge_btn_text", "new_str_0386")
    self.enemy_hero_list = {}
    -- for i = 1,8 do
    --     local enemy_img = self:findGameObject("enemy_img_"..i)
    --     local parent_target = self:findGameObject("enemy_3d_"..i)
    --     table.insert(self.enemy_hero_list, {use = false, img = enemy_img, parent = parent_target, role_obj = nil })
    -- end
  
    self:setTextByLanKey("cur_floor_count", "tid#towertip_01")
    -- local yun_tx = self:setObjectVisible("UI_WorldMapMain_YanWu_003", true)
    -- if yun_tx then
    --     local canvas = yun_tx:GetComponent("Canvas")
    --     if not IsNull(canvas) then
    --         canvas.sortingOrder = self.m_sortOrder +2
    --     end
    -- end
    self.scroll_content = self:findGameObject("scroll_content")
    self:refreshUI()
    self:moveToFloor(self.m_model.cur_floor)
    --self:updateSelectEnemy(self.m_model.cur_floor+1)
    self:upeadtScrollRectActive(true)
    self:updateQuestSpecial()
end

function M:upeadtScrollRectActive(bl)
    local list_scroll = self:findGameObject("list_scroll")
    local scroll_rect = UIUtil.findScrollRect(list_scroll.transform)
    local mask_img = self:findGameObject("mask")
    if bl == true then
        if scroll_rect then
            scroll_rect.enabled = false
        end
        if mask_img then
            mask_img:SetActive(false)
        end
    else
        if scroll_rect then
            scroll_rect.enabled = true
        end
        if mask_img then
            mask_img:SetActive(true)
        end
    end
end


function M:refreshUI()
    --self:creatRole3D()
    self:creatNewLoopScroll()
    self:updateRightCount()
    --self:updateMainItem()
    if self.m_model:checkCanQuick() == true then
        self:setTextByLanKey("challenge_btn_text", "budo_quick_tex")
    else
        self:setTextByLanKey("challenge_btn_text", "new_str_0386")
    end
    if self.m_model.cur_floor >= self.m_model.max_floor then
        self:setObjectVisible("righe_bg", false)
        self:setObjectVisible("dianfeng_text", true)
    else
        self:setObjectVisible("righe_bg", true)
        self:setObjectVisible("dianfeng_text", false)
    end
    if self.m_model.m_tower_type == 0 then
        self:setObjectVisible("race_attack_num", false)
    else
        self:setObjectVisible("race_attack_num", true)    
        self:setTextByLanKey("race_attack_num", "budo_str_004", self.m_model:getAttackNum())
    end
    self:updateGetRewardUI()
    self:updateBattleRace()

    --快速导航
    self:setObjectVisible("guide_btn", true)
end

function M:updateGetRewardUI()
    local rewards = self.m_model:getNextShowReward()
    if next(rewards) ~= nil then
        local reward_node = RewardUtil:getProcessRewardData(rewards[1])
        self:setImg(reward_node.icon_name, reward_node.atlas_name, "reward_icon_img")
    end
end

function M:updatePlayerIngPos()
    local lur_item = self.scroll_item[self.m_model.cur_floor]
    if lur_item then
        local show_obj = self:getPyObj(lur_item, self.m_model.cur_floor)
        local LuaBehaviour = UIUtil.findLuaBehaviour(show_obj)
        if LuaBehaviour then
            self.player_img.transform:SetParent(show_obj.transform, false)
            self.player_img.transform.localPosition = Vector3(0,45,0)
            self.role_parent.transform.localRotation = Quaternion.Euler(0, 120, 0)
        end
    end
end

function M:updateMainItem()
    local lur_item = self.scroll_item[self.m_model.cur_floor]
    if lur_item then
        local show_obj = self:getPyObj(lur_item, self.m_model.cur_floor)
        local LuaBehaviour = UIUtil.findLuaBehaviour(show_obj)
        if LuaBehaviour then
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "cell_floor_bg", false)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "play_effect", false)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "cell_name_bg", true)
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "cell_name", self.m_model:getMainName())
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "play_sk", false)
        end
    end
end

function M:moveToFloor(floor)
    if self.m_scroll_view then
        if floor == 0 then
            self.m_scroll_view:moveToCellIndex(1)
        end
        for k, v in pairs(self.m_model.enemy_list) do
            if v == floor then
                self.m_scroll_view:moveToCellIndex(k - 3 > 0 and k-3 or 1)
            end
        end
    end
    --self:updatePlayerIngPos()
end

function M:updateSelectEnemy(select_floor)
    for k, v in pairs(self.scroll_item) do
        local show_obj = self:getPyObj(v, k)
        local LuaBehaviour = UIUtil.findLuaBehaviour(show_obj)
        if LuaBehaviour then
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "play_effect", false)
        end
    end
    if select_floor > self.m_model.max_floor then
        return
    end
    local lur_item = self.scroll_item[select_floor]
    local show_obj = self:getPyObj(lur_item, select_floor)
    local LuaBehaviour = UIUtil.findLuaBehaviour(show_obj)
    if LuaBehaviour then
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "play_effect", true)
    end
end

function M:updateRightCount(select_floor)
    local next_floor, next_data = nil, nil
    if select_floor then
        next_floor = select_floor
        next_data = self.m_model:getEnemyDataByFloor(select_floor)
    else
        next_floor, next_data = self.m_model:getNextFloor()
    end
    self:setTextByLanKey("cur_floor_text", "new_str_0083", next_floor)
    local enemy_node = self:findGameObject("enemy_node")
    local reward_node = self:findGameObject("reward_node")
    UIUtil.destroyAllChild(enemy_node.transform)
    UIUtil.destroyAllChild(reward_node.transform)
    for i = 1, table.nums(next_data.rewards) do
        local data = next_data.rewards[i]
        local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS
        local item = GameUtil:createItemElement(data, showNum, true)
        UIUtil.setScale(item.transform, 0.9)
        item.transform:SetParent(reward_node.transform, false)
    end
    local battle_data = self.m_model:getTeamByBattleId(next_data.battle_id)
    for i = 1, table.nums(battle_data.monster) do
        local data = battle_data.monster[i]
        if next(data) ~= nil and data.id ~= 0 then
            local hero_tab = {101, data.id, 0}
            --local item = GameUtil:createItemElement(hero_tab, false, false, handler(self, self.clickHeros))
            local item = CommonUIUtil:createHeroElement(hero_tab,false,nil)
            CommonUIUtil:updateHeroLvByData(item, data)
            --UIUtil.setScale(item.transform, 0.6)
            item.transform:SetParent(enemy_node.transform, false)
        end
    end
end

function M:clickHeros(object, click_name, index, item_data)
    local next_floor, next_data = self.m_model:getNextFloor()
    local battle_data = self.m_model:getTeamByBattleId(next_data.battle_id)
    local all_heros = {}
    local cur_hero = nil
    for i = 1, table.nums(battle_data.monster) do
        local data = battle_data.monster[i]
        local temp_data = table.copy(data)
        local equip = table.copy(temp_data.equips)
        temp_data.equips = {}
        for i = 1, 4 do
            if equip[i] then
                temp_data.equips[tostring(i)] = {
                    race = 0,
                    lrace = 0,
                    amount = 0,
                    exp = 0,
                    oid = 10,
                    lv = equip[(i * 2)],
                    id = equip[(i * 2) - 1]
                }
            end
        end
        all_heros[temp_data.id] = temp_data
        if item_data.data_id == data.id then
            cur_hero = temp_data
        end
    end
    self.m_control:openView("HeroBag", {player_data = {heros = all_heros}, mode = 3, oid = cur_hero.id, team = false})
end

function M:creatNewLoopScroll()
    local data = self.m_model.enemy_list
    self.scroll_item  = {}
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                local LuaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
                self.scroll_item[cell_data] = cell_obj
                if LuaBehaviour then
                    --LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "play_sg_effect", false)
                    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "ta_bg_1", cell_data ~= self.m_model.max_floor)
                    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "ta_bg_2", cell_data == self.m_model.max_floor)
                    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "blue_light", false)
                    local tower_drop = LuaBehaviour:FindGameObject("tower_cell_reward")
                    UIUtil.destroyAllChild(tower_drop.transform)
                    local drop = self.m_model:checkSpecialDrop(cell_data)
                    if drop then
                        for i,v in pairs(drop) do
                            local drop_item = GameUtil:createItemElement(v,true,true)
                            UIUtil.setScale(drop_item.transform, 0.5)
                            drop_item.transform:SetParent(tower_drop.transform, false)
                        end
                    end
                    if cell_data > self.m_model.cur_floor then
                        local cell_name = LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "tower_cell_name", "new_str_0083", cell_data)
                        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "tower_cell_name", true)
                        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "tower_cell_get", false)
                        if cell_data == self.m_model.cur_floor + 1 then
                            cell_name.color = GlobalConfig.COMMON_COLLOR.COMMON_1
                            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "blue_light", true)
                        else
                            cell_name.color = GlobalConfig.COMMON_COLLOR.COMMON_4
                        end
                    else
                        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "tower_cell_name", false)
                        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "tower_cell_get", true)
                        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "tower_cell_get", "budo_str_003")
                    end
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                if click_name == "py_1" or click_name == "py_2" then
                    if cell_data ~= self.m_model.cur_floor then
                        self:updateMsg("clickEnemy", cell_data)
                    end
                end
            end,
            ui_name = self.m_uiName
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data, true)
    end

end

--暂时弃用
function M:createLoopScroll()
    self.scroll_item = {}
    local data = self.m_model.enemy_list
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                local LuaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
                self.scroll_item[cell_data] = cell_obj
                if LuaBehaviour then
                    local yu = cell_data % 2
                    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "right_st", false)
                    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "left_st", false)
                    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "py_2", false)
                    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "py_1", false)
                    local st_obj = nil
                    local show_obj = nil
                    if yu == 0 then
                        show_obj = LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "py_1", true)
                        st_obj = LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "right_st", true)
                    elseif yu == 1 then
                        show_obj = LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "py_2", true)
                        st_obj = LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "left_st", true)
                    end            
                    local parent = LuaBehaviour:FindGameObject("role_3d")
                    local floor_cfg = self.m_model:getEnemyDataByFloor(cell_data)
                    self:updateEnemyItem(show_obj, cell_data)
                    if cell_data == self.m_model.max_floor then
                        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "stones2", false)
                        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "stones1", false)
                    else
                        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "stones2", true)
                        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "stones1", true)
                    end
                    local enemy_img =  nil
                    if self.scroll_obj[cell_obj] == nil then
                        enemy_img = self:getEnemyImg()
                        self.scroll_obj[cell_obj] = {data = cell_data, img = enemy_img}
                    else
                        local scr_data = self.scroll_obj[cell_obj]
                        if scr_data.img == nil then
                            enemy_img = self:getEnemyImg()
                            scr_data.img = enemy_img
                        else
                            enemy_img = scr_data.img
                        end
                    end
                    if enemy_img then
                        if floor_cfg then
                            local role_parent = UIUtil.findTrans(show_obj.transform, "role_parent")
                            enemy_img.transform:SetParent(role_parent.transform, false)
                            if self.temp_floor ~= 0 then
                                self:creatCellHero(floor_cfg.enemy_show,enemy_img, cell_data)
                            else
                                if cell_data > self.m_model.cur_floor and cell_data <= self.m_model.cur_floor+7 then
                                    self:creatCellHero(floor_cfg.enemy_show,enemy_img, cell_data)
                                end
                            end
                            enemy_img:SetActive(true)
                            enemy_img.transform.localPosition = Vector3(0,45,0)
                        end
                        if cell_data == self.m_model.cur_floor and self.temp_floor == 0 then
                            enemy_img:SetActive(false)
                        else
                            enemy_img:SetActive(true)
                        end
                        if self.temp_floor == 0 and cell_data < self.m_model.cur_floor then
                            st_obj:SetActive(false)
                            show_obj:SetActive(false)
                        end
                        self:getEnemyData(enemy_img, cell_data)
                    end
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                if click_name == "py_1" or click_name == "py_2" then
                    if cell_data ~= self.m_model.cur_floor then
                        self:updateMsg("clickEnemy", cell_data)
                    end
                end
            end,
            ui_name = self.m_uiName
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data, true)
    end
end

function M:refreshEnemyStatus()
    for i,v in ipairs(self.enemy_hero_list) do
        if v.role_obj and v.floor then
            local view_helper = v.role_obj:GetComponent("PlayerLuaViewHelper");
            view_helper.enabled = false;
            self:loadFinishObj2(v.floor, v.role_obj)
        end
    end
    if self.m_role_obj then
        self:loadFinishObj(self.m_role_obj);
    end
end

function M:returnAllRole()
    for i,v in ipairs(self.enemy_hero_list) do
        if v.role_obj then
            local helper = v.role_obj:GetComponent("LuaTransformHelper")
            if helper then
                local body = helper:FindObj(v.role_obj.transform, "body")
                body.transform.localScale = Vector3(1, 1, 1) 
            end
            U3DUtil:Destroy(v.role_obj)
            v.role_obj = nil
        end
    end
    if self.m_role_obj then
        local helper = self.m_role_obj:GetComponent("LuaTransformHelper")
        if helper then
            local body = helper:FindObj(self.m_role_obj.transform, "body")
            body.transform.localScale = Vector3(1, 1, 1) 
        end
        U3DUtil:Destroy(self.m_role_obj)
        self.m_role_obj = nil
    end
end


function M:getEnemyImg()
    for i,v in ipairs(self.enemy_hero_list) do
        if v.use == false then
            v.use = true
            return v.img
        end
    end
    return nil
end

function M:getEnemyData(img, floor)
    for i,v in ipairs(self.enemy_hero_list) do
        if v.img == img then
            v.floor = floor
        end
    end
end

function M:creatCellHero(id, img, floor)
    local cell_enemy_data = nil
    for i,v in ipairs(self.enemy_hero_list) do
        if v.img == img then
            cell_enemy_data = v
            cell_enemy_data.floor = floor
            break
        end
    end
    if cell_enemy_data.parent and not IsNull(cell_enemy_data.parent) then
        local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(id)
        local prefab_name = hero_cfg["prefab"]
        local name_path = string.split(prefab_name, "/")
        ResourceUtil:LoadRole3dAsync(prefab_name, nil,
        function(obj)
            if cell_enemy_data.role_obj then
                local helper = cell_enemy_data.role_obj:GetComponent("LuaTransformHelper")
                if helper then
                    local body = helper:FindObj(cell_enemy_data.role_obj.transform, "body")
                    body.transform.localScale = Vector3(1, 1, 1) 
                end
                --ResourceUtil:ReturnItem(cell_enemy_data.role_obj)
                U3DUtil:Destroy(cell_enemy_data.role_obj)
                cell_enemy_data.role_obj = nil
            end
            obj.transform:SetParent(cell_enemy_data.parent.transform, false)
            obj.transform.localScale = Vector3(1,1,1);
            cell_enemy_data.role_obj = obj
            local view_helper = obj:GetComponent("PlayerLuaViewHelper");
            view_helper.enabled = false;
            self:loadFinishObj2(floor, obj);
        end)
    end
end

function M:loadFinishObj2(floor, obj)
        local helper = obj:GetComponent("LuaTransformHelper")
        --helper:SetAnimator(true)
        obj.transform.localPosition = Vector3(0, 0, 0)
        obj.transform.localRotation = Quaternion.Euler(0, 0, 0)
        obj.transform.localScale = Vector3(1.1, 1.1, 1.1)
        if helper then
            local body = helper:FindObj(obj.transform, "body")
            if floor%2 == 0 then
                body.transform.localScale = Vector3(1, 1, -1)
            else
                body.transform.localScale = Vector3(1, 1, 1) 
            end
        end
end

function M:updateEnemyItem(obj, floor)
    if obj then
        local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
        local floor_cfg = self.m_model:getEnemyDataByFloor(floor)
        if LuaBehaviour then
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "cell_name_bg", false)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "cell_floor_bg", false)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "play_effect", false)
            if self.temp_floor == 0 and floor == self.m_model.cur_floor then
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "cell_name_bg", true)
                LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "cell_name", self.m_model:getMainName())
            else
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "cell_floor_bg", true)
                LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "cell_floor_name", "new_str_0083", floor)
            end
        end
    end
end

function M:creatRole3D()
    local user = UserDataManager.user_data.user_status
    local avatar = user.avatar or 104
    local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(tonumber(avatar))
    local prefab_name = hero_cfg["prefab"]
    local name_path = string.split(prefab_name, "/")
    ResourceUtil:LoadRole3dAsync(prefab_name, nil,
    function(obj)
        if self.m_role_obj then
            U3DUtil:Destroy(self.m_role_obj)
        end
        obj.transform.localScale = Vector3(1,1,1);
        self.m_role_obj = obj
        self:loadFinishObj(obj);
    end)
end

function M:loadFinishObj(obj)
    local helper = obj:GetComponent("LuaTransformHelper")
    self.anim = obj:GetComponent("Animator")
    if helper then
        local body = helper:FindObj(obj.transform, "body")
        body.transform.localScale = Vector3(1, 1, 1) 
    end
    self.effectpoint0 = nil
    self.jy_eff = nil
    local view_helper = obj:GetComponent("PlayerLuaViewHelper");
    if view_helper then
        view_helper.enabled = false;
    end
    if helper then
        self.effectpoint0 = helper:FindObj(obj.transform, "effectpoint0")
        self.effectpoint2 = helper:FindObj(obj.transform, "effectpoint2")
        -- if self.effectpoint0 then
        --     self.jy_eff =  ResourceUtil:LoadRole3dEffect("W_JinY_104","W_JinY_Attack_SF_001", self.effectpoint0)
        --     self.jy_eff:SetActive(false)
        -- end
        -- if self.effectpoint2 then
        --     self.jy_ying =  ResourceUtil:LoadRole3dEffect("W_JinY_104","W_JinY_Skill3_Hit_001_01", self.effectpoint2)
        --     if self.jy_ying then
        --         self.jy_ying.transform.localPosition = Vector3(-0.5, -1, 3)
        --         self.jy_ying.transform.localRotation = Quaternion.Euler(0, 0, -75)
        --         self.jy_ying:SetActive(false)
        --     end
        -- end
    end
    --helper:SetAnimator(true)
    obj.transform:SetParent(self.role_parent.transform, false)
    obj.transform.localPosition = Vector3(0, 0, 0)
    obj.transform.localRotation = Quaternion.Euler(0, 0, 0)
    obj.transform.localScale = Vector3(1.1, 1.1, 1.1)
    self:setAnim("idle")
end

--
function M:moveToNext(next_floor, callback)
    local cur_item = self.scroll_item[next_floor - 1]
    if cur_item then
        local show_obj = self:getPyObj(cur_item, next_floor - 1)
        local m_play_sk = self:getPySk(show_obj)
        local c_pos = self.content_node.transform.parent:InverseTransformPoint(m_play_sk.transform.position)
        self.player_img.transform:SetParent(show_obj.transform, false)
        self.player_img.transform.localPosition = m_play_sk.transform.localPosition
    end
    local move_late_pos = self.scroll_content.transform.localPosition.y
    local next_item = self.scroll_item[next_floor]
    if next_item then
        local show_obj = self:getPyObj(next_item, next_floor)
        local m_target = self:getPySk(show_obj)
        local next_pos = self.player_img.transform.parent:InverseTransformPoint(m_target.transform.position)
        self:setAnim("run")
        if next_floor % 2 == 0 then
            self.role_parent.transform.localRotation = Quaternion.Euler(0, 120, 0)
        else
            self.role_parent.transform.localRotation = Quaternion.Euler(0, -120, 0)
        end
        local sequence = Tweening.DOTween.Sequence()
        sequence:Append(self.player_img.transform:DOLocalMove(next_pos, 0.9):SetEase(Tweening.Ease.Linear))
        sequence:OnComplete(
            function()
                self.role_parent.transform.localRotation = Quaternion.Euler(0, 120, 0)
                -- if next_floor >= self.lock_floor and next_floor ~= self.m_model.cur_floor then
                --     self.scroll_content.transform:DOLocalMoveY(move_late_pos-118, 0.9, false):SetEase(Tweening.Ease.Linear)
                -- end
                callback()
            end
        )
        sequence:SetAutoKill(true)
    end
end

function M:TestStar(callback)
    self:upeadtScrollRectActive(false)
    local move_late_pos = self.scroll_content.transform.localPosition.y
    local inter = (self.m_model.cur_floor-self.temp_floor)
    local diff_num = (inter-2) * 122
    local sub_num = diff_num - 4
    local tim = (inter-1)*0.9
    self.s_pos = self.scroll_content.transform.localPosition.y
    self:TestQuickJump(function()
        self.temp_floor = 0
        self.m_control:setOnceTimer(0.3,function()
            self:updatePlayerIngPos()
        end)
        if self.m_model.cur_floor == self.m_model.max_floor then
            self:upeadtScrollRectActive(true)
            callback() 
        else
            self.s_pos =  self.s_pos - 240
            local sequence = Tweening.DOTween.Sequence()
            sequence:Append( self.scroll_content.transform:DOLocalMoveY(self.s_pos, 1.8, false):SetEase(Tweening.Ease.Linear))
            sequence:OnComplete(function ()
                self:upeadtScrollRectActive(true)
                callback() 
            end)
            sequence:SetAutoKill(true)
        end
    end)
end

function M:moveAnim(callback)
    self:creatNewLoopScroll()
    local deff_num = 0
    if self.temp_floor < 5 then
        deff_num = 4 - self.temp_floor
    end
    local move_late_pos = self.scroll_content.transform.localPosition.y
    local inter = (self.m_model.cur_floor-self.temp_floor) - deff_num
    self.s_pos = self.scroll_content.transform.localPosition.y
    self.s_pos = self.s_pos - (92 * inter) 
    self:upeadtScrollRectActive(false)
    self:setObjectVisible("budo_effect", true)
    local sequence = Tweening.DOTween.Sequence()
    sequence:Append( self.scroll_content.transform:DOLocalMoveY(self.s_pos, 2, false):SetEase(Tweening.Ease.Linear))
    sequence:OnComplete(function ()
        self:upeadtScrollRectActive(true)
        self:setObjectVisible("budo_effect", false)
        if self.scroll_item[self.m_model.cur_floor+1] then
            local luaBehaviour = UIUtil.findLuaBehaviour(self.scroll_item[self.m_model.cur_floor+1])
            if luaBehaviour then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "play_sg_effect", true)
                self.m_control:setOnceTimer(1, function ()
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "play_sg_effect", false)
                end)
            end
        end
        callback() 
    end)
    sequence:SetAutoKill(true)
end

function M:TestQuickJump(callback)
    if self.temp_floor + 1 < self.m_model.cur_floor then
        self:Testmove(
            self.temp_floor + 1,
            function()
                self.temp_floor = self.temp_floor + 1
                self:TestQuickJump(callback)
            end
        )
    elseif self.temp_floor + 1 == self.m_model.cur_floor then
        self:Testmove(
            self.temp_floor + 1,
            function()
                self.temp_floor = self.temp_floor + 1
                self:setAnim("idle")
                self:updateMainItem()
                if callback then
                    callback()
                end
            end
        )
    else
        if callback then
            callback()
        end
    end
end

function M:Testmove(next_floor, callback)
    local cur_item = self.scroll_item[next_floor - 1]
    if cur_item then
        local show_obj = self:getPyObj(cur_item, next_floor - 1)
        local m_play_sk = self:getPySk(show_obj)
        local c_pos = self.content_node.transform.parent:InverseTransformPoint(m_play_sk.transform.position)
        self.player_img.transform:SetParent(show_obj.transform, false)
        self.player_img.transform.localPosition = m_play_sk.transform.localPosition
    end
    local next_item = self.scroll_item[next_floor]
    if next_item then
        local show_obj = self:getPyObj(next_item, next_floor)
        local m_target = self:getPySk(show_obj)
        local m_effect_2 = self:getByName(show_obj, "play_effect2")
        if m_effect_2 then
            m_effect_2:SetActive(false)
        end
        local next_pos = self.player_img.transform.parent:InverseTransformPoint(m_target.transform.position)
        self:setAnim("run")
        local tx_parent = UIUtil.findTrans(show_obj.transform, "role_parent")
        if next_floor % 2 == 0 then
            self.role_parent.transform.localRotation = Quaternion.Euler(0, 120, 0)
        else
            self.role_parent.transform.localRotation = Quaternion.Euler(0, -120, 0)
        end
        local sequence = Tweening.DOTween.Sequence()
        sequence:Append(self.player_img.transform:DOLocalMove(next_pos, 0.9):SetEase(Tweening.Ease.Linear))
        sequence:OnComplete(
            function()
                local function killover()
                    self.role_parent.transform.localRotation = Quaternion.Euler(0, 120, 0)
                    if self.lock_floor <= next_floor and next_floor ~= self.m_model.cur_floor then
                        self.s_pos = self.s_pos - 120
                        self.scroll_content.transform:DOLocalMoveY(self.s_pos, 0.9, false):SetEase(Tweening.Ease.Linear)
                    end
                    callback()
                end
                if next_floor %5 == 0 then
                    self.m_control:setOnceTimer(0.7, function ()
                        killover()
                    end)
                    self:setAnim("attack1")
                    for k,v in pairs(self.enemy_hero_list) do
                        if v.floor == next_floor then
                            self:playAnim("die", v.role_obj, false,0.3)
                            if m_effect_2 then
                                m_effect_2:SetActive(true)
                            end
                        end
                    end
                else
                    for k,v in pairs(self.enemy_hero_list) do
                        if v.floor == next_floor then
                            self:playAnim("die", v.role_obj, true)
                            if m_effect_2 then
                                m_effect_2:SetActive(true)
                            end
                        end
                    end
                    killover()
                end
            end
        )
        sequence:SetAutoKill(true)
    end
end

function M:setDefaultPos(obj, index)
    local yu = index % 2
    if yu == 0 then
        UIUtil.setLocalPosition(obj.transform, 0, 50.6, 0)
    elseif yu == 1 then
        UIUtil.setLocalPosition(obj.transform, 0, 35.3, 0)
    end
end

function M:getPyObj(obj, index)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    local show_obj = nil
    if LuaBehaviour then
        local yu = index % 2
        if yu == 0 then
            show_obj = LuaBehaviour:FindGameObject("py_1")
        elseif yu == 1 then
            show_obj = LuaBehaviour:FindGameObject("py_2")
        end
    end
    return show_obj
end

function M:getPySk(obj)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    if LuaBehaviour then
        return LuaBehaviour:FindGameObject("run_target"), LuaBehaviour:FindGameObject("play_sk")
    end
end

function M:getByName(obj, name)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    if LuaBehaviour then
        return LuaBehaviour:FindGameObject(name)
    end
end

M.temp_floor = 0
M.lock_floor = 0

function M:setAnim(name)
    if not IsNull(self.anim) and not IsNull(self.m_role_obj) then
        self.anim:CrossFade(name, 0,0,0)
    end
    if name == "attack1" then
        audio:SendEvtUI('UI_Sword_Whoosh')
    elseif name == "run" then
        audio:SendEvtUI('UI_Move')
    end
end

function M:playAnim(name, obj, play_effect, delay)
    local function play_fun()
        if not IsNull(obj) then
            local anim = obj:GetComponent("Animator")
            if not IsNull(anim) then
                anim:CrossFade(name, 0,0,0)
            end
        end
    end 
    if delay then
        self.m_control:setOnceTimer(delay, play_fun)
    else
        play_fun()
    end
end

function M:creatEffectItem(parent)
    local item = ResourceUtil:GetUIEffectItem("Budo/UI_BuDo_01", parent)
    return item
end


function M:destroy()
    self:returnAllRole()
    M.super.destroy(self)
end

-- 5 天机楼  54 金   55 木   56 水   57 火
function M:updateQuestSpecial()
    local quest_type = self.m_model:getQuestType()
    GameUtil:updateQuestSpecialNode(self, quest_type)
end

--可参战的势力类型
function M:updateBattleRace()
    if self.m_model.m_tower_type == 0 then
        self:setObjectVisible("race_tab", false)
    else
        self:setObjectVisible("race_tab", true) 
        local race_data = GlobalConfig.TYPE_HERO_RACE[self.m_model.m_tower_type]
        local race_data2 = nil
        self:setImg(race_data.race_icon, ResourceUtil:getLanAtlas(), "race_1_img")
        if self.m_model.m_tower_type == 1 or self.m_model.m_tower_type == 2 then
            race_data2 = GlobalConfig.TYPE_HERO_RACE[5]
        else
            race_data2 = GlobalConfig.TYPE_HERO_RACE[6]
        end
        self:setImg(race_data2.race_icon, ResourceUtil:getLanAtlas(), "race_2_img")
    end
end




return M
