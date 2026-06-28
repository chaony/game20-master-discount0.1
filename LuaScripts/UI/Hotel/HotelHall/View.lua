--==================================
-- file:  View.lua
-- brief:  酒楼大厅
--==================================
local M = class("HotelHallView", LikeOO.OOPopBase)

M.m_uiName = "Hotel/HotelHall"
M.m_size_type = 1

function M:onEnter()
    self:setTextByLanKey("close_title_text", "hotel_text_009")
    self:setTextByLanKey("quest_goal_text", "hotel_text_011")
    self:setTextByLanKey("quest_reward_text", "hotel_text_012")
    self:setTextByLanKey("run_btn_text", "hotel_text_013")
    self:setTextByLanKey("gain_text", "hotel_text_021")
    self:setTextByLanKey("open_upgrade_btn_text", "hotel_text_019")
    self:setTextByLanKey("open_hero_btn_text", "hotel_text_025")
    self:setTextByLanKey("hero_hint_text", "hotel_text_027")
    self:setTextByLanKey("hero_hint_text2", "hotel_text_039")
    self.m_content_panel = self:findGameObject("content_panel")
    self.m_gray_img = self:findImage("gray_image")
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 56})
    self.m_token_icon = self.m_attr_node:findGameObject("attr_icon_1")
    self.m_token_action = false
    self.m_cur_node_type = 0
    self.m_last_grade = -1
    self:refreshUI()
end

function M:refreshUI()
    self:refreshQuest()
    self:refreshRooms()
    self:refreshRoomDetail(self.m_model.m_select_room)
    self:refreshRun()
    --back spine
    local spine_res = self.m_model.m_spine_res
    local back_spine_res_name = "jiuxiu_jiulou_zhujiemian" .. spine_res
    local back_spine = self:findGameObject("back_spine")
    GameUtil:updateSpineLoadSet(back_spine,"RoleSpine/" .. back_spine_res_name .. "hou_SkeletonData",back_spine_res_name .. "hou", 0,true)
end

function M:refreshQuest()
    local quest = self.m_model.m_quest
    if quest == nil or quest.status == 2 then
        self:setObjectVisible("quest", false)
        return
    end
    self:setObjectVisible("quest", true)
    self:setTextByLanKey("quest_desc_text", quest.cfg.name)
    local slider = self:findSlider("quest_slider")
    slider.value = quest.value / quest.cfg.target_value
    self.m_quest_reward = self:findGameObject("quest_reward")
    self:setObjectVisible("quest_red_point", quest.value >= quest.cfg.target_value)
    UIUtil.destroyAllChild(self.m_quest_reward.transform)
    local length = #quest.cfg.awards
    for i = 1, length do
        local data = quest.cfg.awards[i]
        local item = GameUtil:createItemElement(data, true, true)
        item.transform:SetParent(self.m_quest_reward.transform, false)
    end
end

function M:refreshRooms()
    local rooms = self.m_model.m_rooms
    for k,v in ipairs(rooms) do
        local obj = self:findGameObject("room_btn_" .. k)
        local luaBehaviour = UIUtil.findLuaBehaviour(obj)
        LuaBehaviourUtil.setText(luaBehaviour,"name_text", v.name)
        local icon_img = luaBehaviour:FindImage("icon")
        if v.unlock_run_num > self.m_model.m_his_run_times then
            icon_img.material = self.m_gray_img.material
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unlock", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock", true)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lock_text", "hotel_text_018", v.unlock_run_num - self.m_model.m_his_run_times)
        else
            icon_img.material = nil
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unlock", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock", false)
            LuaBehaviourUtil.setText(luaBehaviour,"level_text", Language:getTextByKey("hotel_text_038", v.level))
            local grade_img = luaBehaviour:FindImage("grade_img")
            GameUtil:updateResourcesImg( grade_img, "Texture/hotel/grade_" .. v.grade)
            local hero_num = 0
            local length = #v.heroes
            for i = 1, length do
                if v.heroes[i] ~= "" then
                    hero_num = hero_num + 1
                end
            end
            LuaBehaviourUtil.setText(luaBehaviour,"hero_text", hero_num .. "/" .. length)
        end
    end
end

function M:refreshRoomDetail(room_id, play_grade)
    local room = self.m_model.m_rooms[room_id]
    self:setTextByLanKey("name", "hotel_text_024", room.name, room.level)
    --grade tween
    if play_grade then
        self.m_last_grade = -1
    end
    self:playGrade(room.grade)
    --attrs tween
    local level_cfg = ConfigManager:getCfgByName("hotel_room_level")
    local room_cfg = level_cfg[room_id]
    local cfg = room_cfg[room.level]
    local attrs_aim = cfg.attr_aims
    local attrs_max = cfg.attr_shows
    local attrs_room = self.m_model:getRoomAttrs(room)
    local length = #attrs_aim
    for i = 1, length do
        local aim = attrs_aim[i]
        local max = attrs_max[i]
        local cur = attrs_room[i]
        self:setTextByLanKey("attr_text_" .. i, self.m_model:getRoomAttrName(i) .. "  " .. cur)
        local attr_aim_slider = self:findSlider("attr_aim_" .. i)
        local attr_slider = self:findSlider("attr_" .. i)
        local fill_img = self:findImage("Fill_" .. i)
        local sequence = Tweening.DOTween.Sequence()
        sequence:AppendInterval(0.5)
        sequence:Append(DOTweenModuleUI.DOValue(attr_aim_slider, aim / max, 0.4):SetEase(CS.DG.Tweening.Ease.OutQuad))
        if cur >= aim then
            sequence:Append(DOTweenModuleUI.DOValue(attr_slider, cur / max, 0.4):SetEase(CS.DG.Tweening.Ease.OutQuad))
            sequence:Append(DOTweenModuleUI.DOColor(fill_img, Color(255/255, 217/255, 90/255, 1), 0.2):SetEase(CS.DG.Tweening.Ease.OutQuad))
            sequence:OnComplete(function()
                local parent = self:findGameObject("attr_effect_" .. i)
                local ex = self:creatEffect("HeroInfo/UI_HeroInfo_ShuXing_002", parent)
                self:setParticleRenderOrder(ex)
                self.m_control:setOnceTimer(0.5, function()
                    U3DUtil:Destroy(ex)
                end)
            end)
        else
            sequence:Append(DOTweenModuleUI.DOValue(attr_slider, cur / max, 0.4):SetEase(CS.DG.Tweening.Ease.OutQuad))
            sequence:Append(DOTweenModuleUI.DOColor(fill_img, Color(255/255, 255/255, 255/255, 1), 0.2):SetEase(CS.DG.Tweening.Ease.OutQuad))
        end
        sequence:SetAutoKill(true)
    end
    --heroes
    self:updateHeroScroll(room.heroes)
end

function M:refreshRun()
    --run times
    self:setTextByLanKey("times_text", "hotel_text_007", self.m_model.m_times)
    --run gain
    self:setImg("hotel_coin", "item_icon", "token_icon_img")
    local gain = self.m_model:getRunGain()
    self:setTextByLanKey("gain_value", gain)
end

function M:updateHeroScroll(heroes)
    local data = heroes
    if self.m_hero_scroll == nil then
        local list_scroll = self:findGameObject("hero_scroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            --one_line_count = 1,
            pos_center = true,
            loop_scroll_object = list_scroll,
            init_cell = function(index, cell_object)
                local function callback()
                    local itemNode = ResourceUtil:LoadUIGameObject("Main/MainHeroNodeCell", Vector3.zero, nil)
                    local canvas_group = itemNode:GetComponent("CanvasGroup")
                    canvas_group.blocksRaycasts = false
                    itemNode.name = "cell_content"
                    itemNode.transform:SetParent(cell_object.transform, false)
                    itemNode:SetActive(true)
                    local cell_data = data[index]
                    self:listHandle(itemNode, index, cell_data)
                end
                self.m_control:setOnceTimer(index <= 6 and  (0.033 * index) or 0, callback)
            end,
            update_cell = function(index, cell_object, cell_data)
                local content_tran = UIUtil.findTrans(cell_object.transform, "cell_content")
                if content_tran then
                    content_tran.gameObject:SetActive(true)
                    self:listHandle(content_tran.gameObject, index, cell_data)
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if self.m_cur_node_type == 2 and cell_data ~= "" then
                    --local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                    --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img",true)
                    self:updateMsg("down_hero", {index = index, oid = cell_data})
                elseif self.m_cur_node_type == 0 then
                    self:updateMsg("open_hero_btn")
                end
            end,
        }
        self.m_hero_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_hero_scroll:reloadData(data, true)
    end
end

function M:listHandle(obj, index, cell_data)
    local oid = cell_data
    if oid == nil or oid == "" then
        obj:SetActive(false)
    else
        obj:SetActive(true)
        --local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
        GameUtil:updateHeroContent(obj, oid)
    end
end

--房间升级效果
function M:playRoomUpgrade(room_id)
    local room = self.m_model.m_rooms[room_id]
    local obj = self:findGameObject("room_btn_" .. room_id)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    --level & grade
    LuaBehaviourUtil.setText(luaBehaviour,"level_text", Language:getTextByKey("hotel_text_038", room.level))
    local grade_img = luaBehaviour:FindImage("grade_img")
    GameUtil:updateResourcesImg( grade_img, "Texture/hotel/grade_" .. room.grade)
    --effect
    local parent = luaBehaviour:FindGameObject("effect")
    local ex = self:creatEffect("Formation/UI_Formation_GuaJi_001", parent)
    self:setParticleRenderOrder(ex)
    local ex2 = self:creatEffect("HeroInfo/UI_HeroInfo_ShengJi_002", obj)
    self:setParticleRenderOrder(ex2)
    self.m_control:setOnceTimer(1, function()
                U3DUtil:Destroy(ex)
                U3DUtil:Destroy(ex2)
                self:refreshRoomDetail(room_id) --左侧效果播放完毕，再刷新任务和右侧详情
                self:refreshQuest()
                self:refreshRun()
            end
    )
    --ShareLvPop/UI_ShareLvPop_Chongneng01
end

function M:creatEffect(tx_name, prent)
    local item = ResourceUtil:GetUIEffectItem(tx_name, prent)
    --item.transform:SetParent(prent.transform, false)
    return item
end

--评级提升效果
function M:playGrade(grade)
    local grade_img = self:findImage("grade")
    local sequence_grade = Tweening.DOTween.Sequence()
    sequence_grade:AppendInterval(0.5)
    sequence_grade:Append(grade_img.transform:DOScale(Vector3(0, 1, 1), 0.3))
    sequence_grade:OnComplete(function()
        GameUtil:updateResourcesImg( grade_img, "Texture/hotel/grade_" .. grade)
        if self.m_last_grade < grade then
            self:setObjectVisible("grade_effect", true)
            self.m_control:setOnceTimer(0.5, function()
                self:setObjectVisible("grade_effect", false)
            end)
            --[[
            local parent = self:findGameObject("grade_effect")
            local ex = self:creatEffect("ShareLv/UI_ShareLv_Xiaobaodian_001", parent)
            self:setParticleRenderOrder(ex)
            self.m_control:setOnceTimer(0.5, function()
                U3DUtil:Destroy(ex)
            end)
            ]]--
        end
        self.m_last_grade = grade
    end)
    sequence_grade:SetAutoKill(true)
    local sequence_grade2 = Tweening.DOTween.Sequence()
    sequence_grade2:AppendInterval(1)
    sequence_grade2:Append(grade_img.transform:DOScale(Vector3(1, 1, 1), 0.3))
    sequence_grade2:SetAutoKill(true)
end

--放入侠客效果
function M:playRoomHeroDispatch(index)
    if index <= 0 then
        return
    end
    local obj_name = "hero_card_effect_" .. index
    self:setObjectVisible(obj_name, false)
    self:setObjectVisible(obj_name, true)
end

--经营获得效果
function M:playGain(outputs)
    local target_loc = self:findGameObject("token_target").transform.position
    for i,v in pairs(outputs) do
        local k = tonumber(i)
        local obj = self:findGameObject("room_btn_" .. k)
        local gain_icon_fly = self:findGameObject("gain_icon_fly_" .. k)
        gain_icon_fly.transform.localScale = Vector3(0.1, 0.1, 0.1)
        gain_icon_fly.transform.position = obj.transform.position
        self:setObjectVisible("gain_icon_fly_" .. k, true)
        local sequence = Tweening.DOTween.Sequence()
        sequence:Append(gain_icon_fly.transform:DOScale(2, 0.5))
        sequence:AppendInterval(0.3)
        sequence:Append(gain_icon_fly.transform:DOLocalMove(Vector3(target_loc.x, target_loc.y, 0), 1.0))
        sequence:OnComplete(function()
            self:setObjectVisible("gain_icon_fly_" .. k, false)
            self:tokenScale()
        end)
        sequence:SetAutoKill(true)
    end
end

--右上代币效果
function M:tokenScale()
    if self.m_token_action ~= true then
        self.m_token_action = true
        local obj = self.m_token_icon
        local sequence = Tweening.DOTween.Sequence()
        sequence:Append(obj.transform:DOScale(1.2, 0.05))
        sequence:Append(obj.transform:DOScale(1.0, 0.05))
        sequence:Append(obj.transform:DOScale(1.2, 0.05))
        sequence:Append(obj.transform:DOScale(1.0, 0.05))
        sequence:Append(obj.transform:DOScale(1.2, 0.05))
        sequence:Append(obj.transform:DOScale(1.0, 0.05))
        sequence:OnComplete(function ()
            self.m_token_action = false
        end)
        sequence:SetAutoKill(true)
    end
end

--打开node——升级和更换侠客
function M:openNode(type)
    local lua_name = nil
    if type == 1 then
        lua_name = "UI.Hotel.HotelHall.RoomUpgradeNode"
    elseif type == 2 then
        lua_name = "UI.Hotel.HotelHall.RoomHeroNode"
    end
    if lua_name == nil then
        return
    end
    self.m_cur_node_type = type
    local tab_cls = CustomRequire(lua_name)
    self.m_cur_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
    self:setObjectVisible("L", false)
    self:setObjectVisible("open_upgrade_btn", false)
    self:setObjectVisible("open_hero_btn", false)
    self:setObjectVisible("hero_hint_text", type == 2)
    self:setObjectVisible("hero_hint_text2", type == 2)
end

--关闭node
function M:closeNode()
    if self.m_cur_node then
        self.m_cur_node:destroy()
        self.m_cur_node = nil
        self.m_cur_node_type = 0
    end
    self:setObjectVisible("L", true)
    self:setObjectVisible("open_upgrade_btn", true)
    self:setObjectVisible("open_hero_btn", true)
    self:setObjectVisible("hero_hint_text", false)
    self:setObjectVisible("hero_hint_text2", false)
end

--刷新node
function M:refreshNode()
    if self.m_cur_node then
        self.m_cur_node:refreshHeroList()
    end
end

function M:destroy()
    M.super.destroy(self)
    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
end

return M