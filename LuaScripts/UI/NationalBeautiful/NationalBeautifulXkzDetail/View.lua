local M = class("NationalBeautifulXkzDetail",LikeOO.OOPopBase)

M.m_uiName = "NationalBeautiful/NationalBeautifulXkzDetail"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self.m_gray_image = self:findImage("hui")
    self.m_week_box_reward_slider = self:findSlider("week_box_reward_slider")
    self.m_box_node = self:findGameObject("box_node")
    self.m_box_node_rt = UIUtil.findRectTransform(self.m_box_node)
    if self.m_model.m_active then
        self:setTextByLanKey("close_title_text", self.m_model.m_active.name)
    else
        self:setTextByLanKey("close_title_text", "raccon_text_0003")
    end
    self:refreshUI()

end

function M:refreshUI(is_refresh)
    self:initDes()
    self:refreshHeroInfo()
    self:updateLoopScroll(is_refresh)
    self:updateRewardBox()
end

function M:initDes()
    local des = self.m_model.m_cur_cfg.des or ""
    self:setTextByLanKey("item_des_text", des)
    self:setTextByLanKey("tili_text","raccon_text_0014", self.m_model.m_health )
end

function M:updateLoopScroll(is_refresh)
    local data, id_tab = self.m_model:getStageData(is_refresh)
    local last_data = data[#data]
    
    if self.m_loop_scroll_zhuanji_detail == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateLoopScrollCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "btn_1" then
                    self:updateMsg("go_battle", {index = index, pos_index = 1})
                elseif click_name == "btn_2" then
                    self:updateMsg("go_battle", {index = index, pos_index = 2})
                elseif click_name == "btn_3" then
                    self:updateMsg("go_battle", {index = index, pos_index = 3})
                elseif click_name == "start_btn" then
                    self:updateMsg("go_battle", {index = 1, pos_index = 2})
                elseif click_name == "jifen_obj" then
                    GameUtil:lookInfoTips(self.m_control, {click_transform = click_object.transform, msg = Language:getTextByKey("tid#EventPointDes_1")})
                end
            end
        }
        self.m_loop_scroll_zhuanji_detail = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_zhuanji_detail:reloadData(data)
    end
    local move_index = self.m_model.m_cur_cell_group or self.m_model.m_min_unlock_group
    if move_index and move_index ~= 999 then
        self.m_loop_scroll_zhuanji_detail:moveToCellIndex(move_index)
    end
end

function M:updateLoopScrollCell(index, cell_object, cell_data)
    local show_data,stage_id_tab,_, total_data_tab = self.m_model:getStageData()
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    local node = luaBehaviour:FindGameObject("node")
    --LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "progress_text", "new_str_0471", math.min(cell_data.value, cell_data.target_value), cell_data.target_value)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "start_btn", index == 1)
   
    for i = 1, 3 do
        local is_have = cell_data[i] and true or false--self.m_model:getBtnShow(cell_data, i)
        local cur_data = cell_data[i] or {}
        local stage_front = cur_data.stage_front or -1
        local is_show = self.m_model:isCanVisible(stage_front)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "btn_" .. i, index > 1 and is_have and is_show )
        if cell_data[i] then
            local is_lock = cell_data.lock == 0
            local is_finish = self.m_model:isCanVisible(stage_id_tab[index][i])
            local is_cost = self.m_model:isCost(stage_id_tab[index][i])
            local btn_img = nil
            if index == 1 then
                btn_img = luaBehaviour:FindImage("start_btn")
            else
                btn_img = luaBehaviour:FindImage("btn_" .. i)
            end
            btn_img.material = is_finish and self.m_gray_image.material or nil
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "start_back_line_img", index == 1 and #show_data > 1)

            local btn = luaBehaviour:FindGameObject("btn_" .. i)
            local btn_luaBehaviour = UIUtil.findLuaBehaviour(btn.transform)
            LuaBehaviourUtil.setObjectVisible(btn_luaBehaviour, "UI_Raccon_XiaKeZhi_002", not is_finish)
            
            --每个节点后面的线
            local next_cell_data = show_data[index + 1]
            if next_cell_data and (next_cell_data[2] or next_cell_data[i] or table.nums(next_cell_data) > 1) then
                LuaBehaviourUtil.setObjectVisible(btn_luaBehaviour, "back_line_img", true)
            elseif next_cell_data and table.nums(cell_data) == 1 and table.nums(next_cell_data) == 1 then
                LuaBehaviourUtil.setObjectVisible(btn_luaBehaviour, "back_line_img", true)
            else
                LuaBehaviourUtil.setObjectVisible(btn_luaBehaviour, "back_line_img", false)
            end
            
            LuaBehaviourUtil.setObjectVisible(btn_luaBehaviour, "lock_img", is_lock)
            LuaBehaviourUtil.setTextByLanKey(btn_luaBehaviour, "btn_text", cell_data[i].name)
            LuaBehaviourUtil.setTextByLanKey(btn_luaBehaviour, "cost_text", is_cost and 0 or cell_data[i].cost)
            LuaBehaviourUtil.setObjectVisible(btn_luaBehaviour, "v_line_img2", true)
            LuaBehaviourUtil.setObjectVisible(btn_luaBehaviour, "v_line_img3", true)
            LuaBehaviourUtil.setObjectVisible(btn_luaBehaviour, "v_line_img", true)
            if i ~= 2 and table.nums(cell_data) == 1 then
                local last_cell_data = show_data[index - 1]
                if last_cell_data and table.nums(last_cell_data) == 1 then
                    LuaBehaviourUtil.setObjectVisible(btn_luaBehaviour, "v_line_img", last_cell_data[2] and true or false)
                    LuaBehaviourUtil.setObjectVisible(btn_luaBehaviour, "v_line_mid_img", last_cell_data[2] and true or false)
                else
                    LuaBehaviourUtil.setObjectVisible(btn_luaBehaviour, "v_line_img", false)
                    LuaBehaviourUtil.setObjectVisible(btn_luaBehaviour, "v_line_mid_img", false)

                end
              elseif i == 2 and is_have then
                local last_cell_data = show_data[index - 1] or {}
                LuaBehaviourUtil.setObjectVisible(btn_luaBehaviour, "v_line_img2", last_cell_data[1] and true or false)
                LuaBehaviourUtil.setObjectVisible(btn_luaBehaviour, "v_line_img3", last_cell_data[3] and true or false)
                if last_cell_data and table.nums(last_cell_data) == 1 and last_cell_data[2] then
                    LuaBehaviourUtil.setObjectVisible(btn_luaBehaviour, "v_line_img", false)
                    LuaBehaviourUtil.setObjectVisible(btn_luaBehaviour, "v_line_img2", false)
                    LuaBehaviourUtil.setObjectVisible(btn_luaBehaviour, "v_line_img3", false)
                end
            elseif i ~= 2 then
                local last_data = total_data_tab[index - 1]
                LuaBehaviourUtil.setObjectVisible(btn_luaBehaviour, "v_line_img", last_data and last_data[2])
                LuaBehaviourUtil.setObjectVisible(btn_luaBehaviour, "v_line_mid_img", last_data and last_data[2])
            end
        end
    end
end

function M:refreshHeroInfo()
    local coordinate = self.m_model.m_cur_cfg.coordinate or {}
    local hero_id = self.m_model.m_cur_cfg.spine or "502"
    local hk_obj = self:findGameObject("hero_spine")
    local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(tonumber(hero_id))
    local spine_name = hero_cfg.hero_spine or "hero_0001_SkeletonData"
    GameUtil:updateSpineLoadSet(hk_obj, "RoleSpine/" .. spine_name, "idle", 0, true)
    if coordinate[1] then
        UIUtil.setLocalPosition(hk_obj, coordinate[1], coordinate[2])
    end
end

--左下，宝箱
function M:updateRewardBox()
    local box_trans = self.m_box_node.transform
    UIUtil.destroyAllChild(box_trans)
    local show_data = self.m_model:getBoxShowData()
    local cur_num = self.m_model:getChapterNumsByHeroIndex(self.m_model.m_hero_index)
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

function M:destroy()
    M.super.destroy(self)
end

function M:refreshRedPoint()
end

return M