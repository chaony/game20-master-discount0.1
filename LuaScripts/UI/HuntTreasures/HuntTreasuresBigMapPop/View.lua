local M = class("HuntTreasuresBigMapPopView",LikeOO.OOPopBase)

M.m_uiName = "HuntTreasures/HuntTreasuresBigMapPop"
M.m_size_type = 2
local __flag_img = {is_guild = "a_mjxb_youfang", is_enemy = "a_mjxb_choujia"}

function M:onEnter()
    self.m_gray_image = self:findImage("gray_img")
    --UIUtil:registerDragEvent(self.m_ui_obj, handler(self,self.fingerSliding))
    self:setTextByLanKey("common_title_text", "hunt_treasure_str_029")
    self:setTextByLanKey("big_map_btn_text", "hunt_treasure_str_029")
    self:setTextByLanKey("arena_btn_text", "hunt_treasure_str_011")
    --self.m_active_point_slider = self:findSlider("active_point_slider")
    self.m_box_node = self:findGameObject("box_node")
    self.m_box_node_rt = UIUtil.findRectTransform(self.m_box_node)


    
    self:refreshUI()
end

function M:switchTabUpdate(is_on, update_key)
    if is_on then
        self:updateMsg(update_key)
    end
end

function M:destroy()
    M.super.destroy(self)
end
function M:refreshUI()
    for i = 1, 4 do
        local region_data = self.m_model.m_regions[tostring(i)]
        local race_id_tab = self.m_model:getRegionCfgValueById(i, "race")
        self:setImg(GlobalConfig.MINING_RACE_ICON[race_id_tab[1]].name, ResourceUtil:getLanAtlas(), "rare_img_" .. i .. "_1")
        local area_name_text = self:findText("area_name_text_" .. i)
        local area_num_text = self:findText("area_num_text_" .. i)
        local area_name = self.m_model:getRegionCfgValueById(i, "name")
        self:setTextByLanKey("area_name_text_" .. i, area_name)
        --local num = region_data and region_data.num or 0
        local icon_tab = {}
        local is_guild = region_data and  region_data.is_guild or 0
        local is_enemy = region_data and  region_data.is_enemy or 0
        local has_self = region_data and  region_data.has_self or 0
        self:setObjectVisible("self_flag_img" .. i, has_self == 1)
        --if is_guild ~= 0 then
        --    table.insert(icon_tab, { i, "is_guild" })
        --end
        --if is_enemy ~= 0 then
        --    table.insert(icon_tab, { i, "is_enemy" })
        --end
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(self.m_model.open_id[i])
        local area_node = self:findImage("area_node_" .. i)
        local rare_img = self:findImage("rare_img_" .. i .. "_1")
        if open_flag then
            area_node.material = nil
            rare_img.material = nil
        else
            area_node.material = self.m_gray_image.material
            rare_img.material = self.m_gray_image.material
        end
        self:updateFlagIcon(icon_tab)
    end
    --self:refreshProgressBar()
end

function M:updateTime()
    for i = 1, 4 do
        local occ_time = self.m_model.m_remainder_time_tab[i]
        local tips_str = self.m_model.m_remainder_des_tab[i]
        local remainder_type = self.m_model.m_remainder_type_tab[i]
        local region_data = self.m_model.m_regions[tostring(i)]
        local has_self = region_data and  region_data.has_self or 0
        if occ_time > 0 and has_self > 0 and remainder_type > 0.5 then
            local tim = GameUtil:formatTimeBySecond(occ_time, 2)
            --local hour = math.modf(occ_time / 3600)
            --local tim = Language:getTextByKey("new_str_0416",hour) 
            self:setTextByLanKey("area_num_text_" .. i, tips_str, tim)
            self.m_model.m_remainder_time_tab[i] = self.m_model.m_remainder_time_tab[i] - 1
        elseif occ_time <=0 and has_self > 0 and remainder_type > 0.5 then
            self:updateMsg("refresh_index")
        elseif occ_time > 0 and remainder_type > 0.5 then
            --local hour = math.modf(occ_time / 3600)
            --local tim = Language:getTextByKey("new_str_0416",hour)
            local tim = GameUtil:formatTimeBySecond(occ_time, 2)
            self:setTextByLanKey("area_num_text_" .. i, tips_str, tim)
        else
            self:setTextByLanKey("area_num_text_" .. i, tips_str)
        end
    end
end

function M:updateFlagIcon(icon_tab)
    for i = 1, #icon_tab do
        local buff_img = self:findImage("buff_img_" .. icon_tab[i][1] .. "_" .. i)
        self:findGameObject("buff_img_" .. icon_tab[i][1] .. "_" .. i):SetActive(true)
        buff_img:SetNativeSize()
        self:setImg(__flag_img[icon_tab[i][2]], ResourceUtil:getLanAtlas(), "buff_img_" .. icon_tab[i][1] .. "_" .. i)
    end
end

function M:refreshProgressBar()
    self.m_active_point_slider.value = self.m_model:getBarProgress()
    local show_data, show_reward = self.m_model:getBoxShowData()
    local max_score = show_data[#show_data]
    local box_trans = self.m_box_node.transform
    UIUtil.destroyAllChild(box_trans)
    local width = self.m_box_node_rt.rect.width
    for i=1,#show_data do
        local data = {}--show_reward[i]
        data.status = self.m_model:getBoxStatusByIndex(i)
        local cfg_score = show_data[i]
        local task_box = GameUtil:createPrefab("Task/TaskBox", box_trans)
        local transform = task_box.transform
        local luaBehaviour = UIUtil.findLuaBehaviour(transform)
        UIUtil.setLocalPosition(task_box, width*cfg_score/max_score - width*0.5, 0)
        local function btns(trans,params)
            if data.status == 2 then -- 可领取
                self:updateMsg("box_reward", {click_transform = trans, data = cfg_score})
            else
                self:updateMsg("box_click", {click_transform = trans, data = show_reward[i]})
            end
        end
        UIUtil.setButtonClick(transform, btns, i)
        local score_text = UIUtil.setText(transform, Language:getTextByKey("new_str_0416", cfg_score), "score_text")
        local finish_text = UIUtil.setTextByLanKey(transform,"finish_text", "new_str_0080")
        score_text.color = data.status == 0 and GlobalConfig.COMMON_COLLOR.COMMON_1 or Color( 255/255, 235/255, 68/255)
        local box_effect = UIUtil.findRectTransform(transform, "UI_Task_BaoXiang_001")
        local box_img = nil
        if data.status == 0 then
            box_img = UIUtil.setImg(transform, "a_rw_xiangzi_weikai", "main_ui", "box_img")
        elseif data.status == 2 then
            box_img = UIUtil.setImg(transform, "a_rw_xiangzi_weikai", "main_ui", "box_img")
        elseif data.status == -1 then
            box_img = UIUtil.setImg(transform, "a_rw_xiangzi_kai", "main_ui", "box_img")
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_img", i ~= box_num)
        box_effect.gameObject:SetActive(false)
        if data.status == 2 then
            self.m_control:setOnceTimer(0.1, function()
                if not IsNull(task_box) then
                    luaBehaviour:RunAnim("UI_TaskBox_BaoXiang_001", nil , 1)
                end
            end)
            box_effect.gameObject:SetActive(true)
        end
    end
end
return M