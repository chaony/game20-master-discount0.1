local M = class("ChemicalStarView",LikeOO.OOUIbase)

M.m_uiName = "DestinyStar/ChemicalStar"

function M:onEnter()
    self.m_hui_img = self:findImage("hui_img")
    self.fate_build_btn = self:findButton("fate_build_btn")
    self.fate_build_btn_img = self:findImage("fate_build_btn")
    self:setTextByLanKey("fate_build_text", "fate_building_text_0002")
    self:setTextByLanKey("cur_build_floor_text", "fate_building_text_0007")
    self:refreshUI()
end

function M:refreshUI()
    self:refreshStar()
    self:refreshFateBuild()
end

--刷新星辰详情
function M:refreshStar()
    local start_data = self.m_model:getStarInfo()
    for i, v in ipairs(start_data) do
        local text_name = "star_name_"..v.star_id
        self:setTextByLanKey(text_name, v.cfg.star_name)--设置星辰名称obj, name
        
        local text_number_name = "star_number_"..v.star_id
        local number = self.m_model:getStarLightNumber(v.star_id) --点亮数量
        local max_number = #v.cfg.hero_group --最大点亮数量
        local number_text =  Language:getTextByKey("new_str_0410",number,max_number)
        self:setTextByLanKey(text_number_name, number_text)--设置点亮星辰比例
        
        local Img_name = "star_"..v.star_id
        --local img_icon_start = "a_tmhx_ziweixingyuandian" --紫微星icon  初始icon
        --local img_icon = "a_tmhx_ziweixingyuandian" --紫微星icon        点亮后icon 
        local img_icon_start = "a_tmhx_huaxingyuandoam_0007" --紫微星icon  初始icon
        local img_icon = "a_tmhx_yuandoam_0004" --紫微星icon        点亮后icon
        local light_name = "UI_DestinyStar_GlowB_001" --特效名称
        if v.cfg.color == 1 then --紫色
            img_icon_start = "a_tmhx_huaxingyuandoam_0005" 
            img_icon = "a_tmhx_yuandoam_0001"
            light_name = "UI_DestinyStar_GlowG_001"
        elseif v.cfg.color == 2 then --绿色
            img_icon_start = "a_tmhx_huaxingyuandoam_0004"
            img_icon = "a_tmhx_yuandoam_0002"
            light_name = "UI_DestinyStar_GlowB_001"
        elseif v.cfg.color == 3 then --黄色
            img_icon_start = "a_tmhx_huaxingyuandoam_0006"
            img_icon = "a_tmhx_yuandoam_0003"
            light_name = "UI_DestinyStar_GlowY_001"
        elseif v.cfg.color == 4 then --蓝色
            img_icon_start = "a_tmhx_huaxingyuandoam_0007"
            img_icon = "a_tmhx_yuandoam_0004"
            light_name = "UI_DestinyStar_GlowB_001"
        end
        --特效内容获取
        local light_object = self:findGameObject("light_"..v.star_id)
        local transform = light_object.transform
        UIUtil.setObjectVisible(transform, true, light_name)
        if number == 0 then
            self:setImg(img_icon_start, "active_ui", Img_name) --设置初始图标
        else
            self:setImg(img_icon, "active_ui", Img_name) --设置点亮后图标
            UIUtil.setObjectVisible(transform, true, "UI_DestinyStar_JiHuo_003")
        end
        local btnName = "star_btn_" .. v.star_id
        local btn = self:findButton(btnName)
        UIUtil.setButtonClick(
                btn,
                function()
                    audio:SendEvtUI("UI_TMStar")
                    self:updateMsg("star",v)
                end
        )
    end
end

function M:refreshFateBuild()
    local building_data =  UserDataManager.m_fate_building
    local cur_floor = building_data.lv or 0
    local cur_build_cfg = self.m_model:getCurFateBuildingCfgByFloor(cur_floor)
    local next_floor = cur_floor + 1
    local next_build_cfg = self.m_model:getCurFateBuildingCfgByFloor(next_floor)
    local fate_nums = self.m_model:getFateNums()
    local show_floor = next(building_data)
    local show_flag = BtnOpenUtil:isBtnOpen(316)
    local can_building = self.m_model:canFateBuilding()
    local can_break = next_build_cfg and next_build_cfg["break"] == 1 or false
    local is_max = cur_floor >= table.nums(self.m_model.m_fate_building_cfg)
    self:setTextByLanKey("fate_unlock_text", "fate_building_text_0001", self.m_model:getFateUnlockNums())
    self:setTextByLanKey("cur_build_floor_nums_text", cur_floor)
    self:setTextByLanKey("fate_unlock_nums_text", fate_nums .. "/" .. self.m_model:getFateUnlockNums())
    self:setObjectVisible("fate_building_node", show_flag)
    self:setObjectVisible("fate_building_attr_node", show_flag and show_floor)
    self:setObjectVisible("fate_build_btn", not is_max)
    if show_flag then
        self:setObjectVisible("unlock_img", not can_building)
        self:setObjectVisible("floor_img", can_building)
        self:setObjectVisible("break_img", can_break)
        self:setObjectVisible("cost_node", not can_break and can_building and not is_max)
        if can_building then
            self.fate_build_btn.interactable = true
            self.fate_build_btn_img.material = nil
        else
            self.fate_build_btn.interactable = false
            self.fate_build_btn_img.material = self.m_hui_img.material
        end
        self:refreshBuildCostNode(next_build_cfg, can_break)
    end

    if can_building then
        self:refreshFloorImgPos(can_break)
    end
    if show_floor then
        self:refreshFateBuildAttrNode(cur_floor)
    end
end

function M:refreshBuildCostNode(next_build_cfg, can_break)
    local cost_reward = next_build_cfg and next_build_cfg.build_cost or {}
    if next(cost_reward) then
        if can_break then
            local cost_data = cost_reward[1]
            local reward_data = RewardUtil:getProcessRewardData(cost_data)
            local break_item = self:findGameObject("build_break_item")
            GameUtil:updateItemElementByData(break_item, reward_data, true, true)
            local break_item_luaBehaviour = UIUtil.findLuaBehaviour(break_item.transform)
            local count_text = break_item_luaBehaviour:FindText("count_text")
            count_text.color = reward_data.user_num >= reward_data.data_num and Color.New(1,1,1) or Color.New(1,0,0)
        else
            for i = 1, 2 do
                local cost_data = cost_reward[i] or nil
                self:setObjectVisible("cost_img" .. i, cost_data and true or false)
                self:setObjectVisible("cost_num_text" .. i, cost_data and true or false)
                if cost_data then
                    local reward_data = RewardUtil:getProcessRewardData(cost_data)
                    self:setImg(reward_data.icon_name, reward_data.atlas_name, "cost_img" .. i)
                    local cost_text = self:setTextByLanKey("cost_num_text" .. i , reward_data.user_num.."/"..reward_data.data_num)
                    if reward_data.user_num >= reward_data.data_num then
                        cost_text.color = GlobalConfig.COMMON_COLLOR.COMMON_1
                    else
                        cost_text.color = GlobalConfig.COMMON_COLLOR.COMMON_11
                    end
                end
              
            end
        end
    end
end

function M:refreshFloorImgPos(can_break)
    local floor_img = self:findGameObject("floor_img")
    if can_break then
        UIUtil.setLocalPosition(floor_img.transform, nil, 47)
    else
        UIUtil.setLocalPosition(floor_img.transform, nil, 8.7)
    end
end

function M:refreshFateBuildAttrNode(cur_floor)
    local total_attr = self.m_model:getFateBuildAttrByCurFloor(cur_floor)
    for i = 1, #total_attr do
        local add_value = total_attr[i][2] or 0
        add_value = math.floor(add_value * 100)
        local add_des = Language:getTextByKey("fate_building_text_000" .. 3 + i, add_value .. "%") 
        self:setText("fate_attr_text_" .. i, add_des)
    end
end

return M