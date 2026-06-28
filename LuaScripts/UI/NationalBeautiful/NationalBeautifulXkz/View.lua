local M = class("NationalBeautifulXkzView",LikeOO.OOPopBase)

M.m_uiName = "NationalBeautiful/NationalBeautifulXkz"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    for i = 1, 3 do
        self:setObjectVisible("spine_show_" .. i, false)
    end
    self.m_gray_image = self:findImage("hui")
    self.m_week_box_reward_slider = self:findSlider("week_box_reward_slider")
    self.m_box_node = self:findGameObject("box_node")
    self.m_box_node_rt = UIUtil.findRectTransform(self.m_box_node)
    local active = self.m_model:getActiveData(self.open_id)
    if active then
        self:setTextByLanKey("close_title_text", active.name)
    end
    self:refreshUI()
end

function M:showClickSpine(hero_index, is_show)
    self:setObjectVisible("spine_show_" .. hero_index, is_show and self.m_model.m_health > 0)
end

function M:refreshUI()
    self:refreshHeroInfo()
    self:updateLoopScroll()
    self:updateRewardBox()
    self:setObjectVisible("week_box_reward_slider",false)
    self:setObjectVisible("box_node",false)
    self:setObjectVisible("Image_left",false)
end

function M:refreshHeroInfo()
    local show_spine = self.m_model:getCfgValueByKey("spine") or {}
    local coordinate = self.m_model:getCfgValueByKey("coordinate") or {}
    local stage = self.m_model:getCfgValueByKey("stage") or {}
    local hero = self.m_model:getCfgValueByKey("hero") or {}
    local hero_count = #hero
    for i = 1, hero_count do
        local hero_btn_img = self:findImage("hero_btn" .. i)
        local hero_img = self:findImage("hero_img" .. i)
        local hero_btn_red_point_img1 = self:findImage("hero_btn_red_point_img" .. i)
        local hero_id = show_spine[i] or 0
        local hero_index = hero[i] or 0
        local is_lock = self.m_model:isChapterUnlock(hero_index)
        hero_btn_img.material = is_lock and self.m_gray_image.material or nil
        self:setObjectVisible("hero_btn_red_point_img" .. i, self.m_model:getDetailBoxRedPoint(hero_index))

        local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(tonumber(hero_id))
        if hero_cfg and next(hero_cfg) then
            local class_str = Language:getTextByKey(hero_cfg.class)
            self:setTextByLanKey("hero_name_text" .. i, class_str)
            local spine_name = hero_cfg.hero_spine or "hero_0502_SkeletonData"
            local play_img = self:findGameObject("hero_spine" .. i)
            --local x_hero_spine = GameUtil:updateSpineLoadSet(play_img, "RoleSpine/diaochan_jq_SkeletonData", "", 0, true)
            local x_hero_spine = GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "", 0, true)
            local sp_hero = x_hero_spine.gameObject:GetComponent("SkeletonGraphic")
            if sp_hero then
                if not is_lock then
                    sp_hero.color = Color(10, 10, 10)
                else
                    sp_hero.color = Color(255, 255, 255)
                end
            end
            if coordinate[i] then
                UIUtil.setLocalPosition(play_img, coordinate[i][1], coordinate[i][2])
            end
            local max_stage = stage[i] or -1
            local cur_num = table.nums(self.m_model:getFinishStage(hero_index)) 
            self:setTextByLanKey("hero_nums_text" .. i, cur_num .. "/" .. max_stage)
            self:showClickSpine(i, not is_lock and (cur_num < max_stage) )
        end
    end

    if hero_count < 3 then
        for i = hero_count+1, 3 do
            self:setObjectVisible("hero_btn" .. i, false)
        end 
    end
end

function M:updateLoopScroll()
    local data = self.m_model.m_rbc_cfg
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell =function(index, cell_obj, cell_data)
                self:updateCell(cell_obj, cell_data, index)
            end,
            ui_name = self.m_uiName,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                audio:SendEvtUI("UI_Tab_N3")

                if cell_data.open == 0 then
                    GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("rpg_scroll_9"), delay_close = 2})
                else 
                    self:updateMsg("change_index", index)
                end
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
        --self.m_scroll_view.m_scroll_rect.onValueChanged:AddListener(handler(self, self.onValueChanged))
    else
        self.m_scroll_view:reloadData(data, self.m_scroll_stay_flag)
        self.m_scroll_stay_flag = true
    end
    --self:updateJianTou()
end

function M:updateCell(obj, data, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"name_text", data.name)
        --置灰
        local buy_img = luaBehaviour:FindImage("cell")
        buy_img.material = (data.open == 0 or index ~= self.m_model.m_cur_index) and self.m_gray_image.material or nil
        local red_flag = self.m_model:getRewardPointDataByIndex(index)
        local red_flag2 = false
        local hero = self.m_model:getCfgValueByKey("hero", index) or {}
        for i = 1, 3 do
            local hero_index = hero[i] or 0
            red_flag2 = self.m_model:getDetailBoxRedPoint(hero_index, index) or red_flag2
        end
        --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point_img", red_flag or red_flag2)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point_img", false)
    end
end

--
--function M:getHeroInfo(hero_id)
--    local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(tonumber(hero_id))
--    if hero_cfg and next(hero_cfg) then
--        local shin_data_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData({}, hero_cfg)
--        local class_str = Language:getTextByKey(hero_cfg.class)
--        local name_str = Language:getTextByKey(shin_data_cfg.name)
--        local race = GlobalConfig.TYPE_HERO_RACE[hero_cfg.race].big_race_icon
--        local spine_name = hero_cfg.hero_spine or "hero_0001_SkeletonData"
--        return name_str, class_str, spine_name --,--hero_cfg.max_evo, race, spine_name
--        self:setTextByLanKey("hero_name", name_str)
--        self:setTextByLanKey("hero_name2", class_str)
--        self:setImg(race,  ResourceUtil:getLanAtlas(), "hero_race")
--        local frame_data = GlobalConfig.QUALITY_FRAME[hero_cfg.max_evo]
--        self:setImg(frame_data.line_frame_name, "common_ui","hero_evo")
--        local play_img = self:findGameObject("hero_spine")
--        GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "", 0, true)
--    end
--end

--左下，宝箱
function M:updateRewardBox()
    local box_trans = self.m_box_node.transform
    UIUtil.destroyAllChild(box_trans)
    local show_data = self.m_model:getBoxShowData()
    local cur_num = self.m_model:getTotalChapterNums()
    self:setTextByLanKey("cur_times_text", "raccon_text_0013", cur_num)

    local width = self.m_box_node_rt.rect.width
    local max_num = 0
    local box_num = #show_data
    if show_data[box_num] then
        max_num = show_data[box_num].score
    end
    max_num = max_num > 0 and max_num or 100
    self.m_week_box_reward_slider.value = cur_num/max_num
    for i=1,box_num do
        local data = show_data[i]
        local cfg = data
        local task_box = GameUtil:createPrefab("EvilShadow/EvilShadowRewardBox", box_trans)
        local transform = task_box.transform
        UIUtil.setLocalScale(transform, 0.7, 0.7, 1.0)
        local luaBehaviour = UIUtil.findLuaBehaviour(transform)
        UIUtil.setLocalPosition(task_box, width*cfg.score/max_num - width*0.5, 0)
        local function btns(trans,params)
            if data.status == 2 then -- 可领取
                self:updateMsg("box_reward", {click_transform = trans, data = data})
            else
                self:updateMsg("box_click", {click_transform = trans, data = data})
            end
        end
        UIUtil.setButtonClick(transform, btns, i)
        local score_text = UIUtil.setText(transform, tostring(cfg.score), "score_text")
        local finish_text = UIUtil.setTextByLanKey(transform,"finish_text", "new_str_0080")
        score_text.color = data.status == 0 and GlobalConfig.COMMON_COLLOR.COMMON_1 or Color( 255/255, 235/255, 68/255)
        local box_effect = UIUtil.findRectTransform(transform, "UI_Arena_BX_01")
        local box_effect2 = UIUtil.findRectTransform(transform, "UI_Arena_BX_02")
        local box_img = luaBehaviour:FindImage("box_img")
        if data.status == 0 then --未开启
            GameUtil:updateResourcesImg(box_img, "Texture/moon_shadow/a_yycs_weijiesuobaoxiang")
        elseif data.status == 2 then --可领取
            GameUtil:updateResourcesImg(box_img, "Texture/moon_shadow/a_yycs_kelingqubaoxiang")
        elseif data.status == -1 then --已领取
            GameUtil:updateResourcesImg(box_img, "Texture/moon_shadow/a_yycs_yilingqubaoxiang")
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"got_flag_img",true)
        end
        box_img:SetNativeSize()
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_img", i ~= box_num)
        if box_effect ~= nil then
            box_effect.gameObject:SetActive(false)
        end
        if box_effect2 ~= nil then
            box_effect2.gameObject:SetActive(false)
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Arena_BX_01", data.status == 2)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Arena_BX_02", data.status == 2)
        if data.status == 2 then
            --self.m_control:setOnceTimer(0.1, function()
            --	if not IsNull(task_box) then
            --		luaBehaviour:RunAnim("UI_TaskBox_BaoXiang_001", nil , 1)
            --	end
            --end)
            if box_effect ~= nil then
                box_effect.gameObject:SetActive(true)
            end
            if box_effect2 ~= nil then
                box_effect2.gameObject:SetActive(true)
            end
        end
    end
end

function M:updateActivityTimer()
    local end_ts = self.m_model:getEndTs()
    if end_ts >= 0 then
        local text = GameUtil:formatTimeBySecond(end_ts, 999)
        text = Language:getTextByKey("new_str_0919") .. text
        self:setTextByLanKey("time_dwon_text", text)
    else
        self:updateMsg(99999)
    end
end

function M:destroy()
    M.super.destroy(self)
end

function M:refreshRedPoint()
end

return M