local M = class("HuntTreasuresGuildView",LikeOO.OOPopBase)

M.m_uiName = "HuntTreasuresGuild/HuntTreasuresGuild"
M.m_iphoneXAdapter = true
local __title_img_tab = {"tid#mining_regin2_01", "tid#mining_regin2_02", "tid#mining_regin2_03", "tid#mining_regin2_04"}
function M:onEnter()
    self.m_sliding = false
    self.m_gray_image = self:findImage("gray_image")
    local scroll_view = self:findGameObject("map_scroll")
    self.m_scroll_rect = scroll_view:GetComponent("ScrollRect")
    local main_rect = self.m_control.m_view.m_rt.rect
    --self.m_luaBehaviour:UseFingersSliding(handler(self,self.fingerSliding))
    if main_rect.height > 1280 then
        local bg_node = self:findGameObject("bg_node")
        UIUtil.setScale(bg_node.transform, main_rect.height/1280)
    end
    --local new_rate = self.m_control.m_view.m_bg_scale
    --local m_1 = self:findGameObject("bg_img")
    --UIUtil.setLocalScale(m_1.transform, new_rate, new_rate)
    self.m_bg_img = self:findImage("big_bg_img")
    self:setTextByLanKey("close_title_text", UserDataManager.m_activity_name)
    --self:setTextByLanKey("close_title_text", "hunt_treasure_guild_str_005")
    self:setTextByLanKey("battle_log_btn_text", "hunt_treasure_str_024")
    self:setTextByLanKey("my_area_btn_text", "hunt_treasure_str_010")
    self:setTextByLanKey("shop_btn_text", "hunt_treasure_guild_str_008")
    self:setTextByLanKey("area_btn_text", "hunt_treasure_str_035")
    self:setTextByLanKey("big_map_btn_text", "hunt_treasure_str_029")
    self:setTextByLanKey("drop_text", "hunt_treasure_str_040")
    self.m_content_panel = self:findGameObject("content_panel")
    local tab_cls = CustomRequire("UI.HuntTreasuresGuild.HuntTreasuresGuildTotalAreaNode")
    self.m_area_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
    self.m_area_node:updateData(self.m_model.m_data)
    self:refreshUI()
    local log_flag = UserDataManager:getRedDotByKey("active_mining_blog") --有新战报
    if log_flag == 1 then
        self:updateMsg("battle_log_btn")
    end
end

function M:refreshJiantouStatus()
    self:setObjectVisible("left_btn", self.m_model.m_cur_page ~= 1)
    self:setObjectVisible("right_btn", self.m_model.m_cur_page ~= self.m_model.m_total_page)
end

function M:updateTime()
    self.m_area_node:updateTime()
end

function M:refreshAreaNode(direction)
    self.m_area_node:updateData(self.m_model.m_data)
    --self.m_area_node:playEnterAnim(direction)
end

function M:refreshUI()
    local bg_img_name = self.m_model:getRegionImg()
    if bg_img_name ~= "" and bg_img_name ~= self.m_model.m_bg_name then
        self.m_model.m_bg_name =bg_img_name
        GameUtil:updateResourcesImg( self.m_bg_img, "Texture/hunt_treasures/" .. bg_img_name)
        self.m_bg_img:SetNativeSize()
    end
    local area_name = self.m_model.m_mining_location_config[self.m_model.m_region_id][self.m_model.m_location_id].name
    self:setTextByLanKey("region_name_text", self.m_model:getLocationName())
    local race_tab = self.m_model.m_mining_region_config[self.m_model.m_version][self.m_model.m_region_id].race
    local title_name = __title_img_tab[self.m_model.m_region_id]
    self:setImg(title_name,  ResourceUtil:getLanAtlas(), "region_name_img")
    self:setTextByLanKey("area_name_text", title_name)
    self:setTextByLanKey("region_nmy_area_btn_imgame_text", self.m_model:getLocationName())
    local ackAdd , rewardAdd = self.m_model:getGuildAdd()
    self:setTextByLanKey("union_add_text", "hunt_treasure_str_015", ackAdd)
    self:setTextByLanKey("union_reward_add_text", "hunt_treasure_guild_str_006", rewardAdd)
    self:setTextByLanKey("force_add_text", "hunt_treasure_str_014")
   
    --local my_area_btn_img = self:findImage("my_area_btn_img")
    --local area_img_name = self.m_model:getMineImg()
    --if area_img_name ~= "" then
    --    GameUtil:updateResourcesImg(my_area_btn_img, "Texture/hunt_treasures/" .. area_img_name)
    --    --my_area_btn_img:SetNativeSize()
    --end
    local race_cft = GlobalConfig.TYPE_HERO_RACE[race_tab[1]]
    self:setImg(race_cft.race_icon, ResourceUtil:getLanAtlas(), "icon_img_1")
    self:findImage("icon_img_1"):SetNativeSize()
    self:refreshRedPoint()
    self:refreshJiantouStatus()
    --self:updateDropLoopScroll()
    self:refreshRobTimes()

    --快速导航
    self:setObjectVisible("guide_btn", false)
end

function M:refreshRobTimes()
    self:setTextByLanKey("plunder_times_text", "hunt_treasure_str_042", self.m_model:canRobTimes())
end

function M:updateDropLoopScroll()
    self.m_cell_tab = {}
    local data = self.m_model:getCurRegionDrop(true) or {}
    self:setObjectVisible("drop_img", #data > 0)
    --self:setObjectVisible("CommonTipsNode", #data == 0)
    local new_index = nil
    if self.m_drop_scroll_view == nil then
        local loopscroll = self:findGameObject("drop_loopscroll")
        local params = {
            show_data = data,
            pos_center = true,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local data = cell_data
                local reward_data = RewardUtil:getProcessRewardData(data)
                --local final_num, float_num = math.modf(reward_data.data_num * 60 * self.m_model.m_produce_add  );
                local ui_element = GameUtil:updateItemElementByData(cell_object, reward_data, true, true)
                ui_element.red_point_img:SetActive(false)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
            end,
            ui_name = self.m_uiName
        }
        self.m_drop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_drop_scroll_view:reloadData(data, false, nil, nil, true)
    end
end

function M:refreshRedPoint()
    local team_flag = UserDataManager:getRedDotByKey("active_mining_team") --有编队可用
    local log_flag = UserDataManager:getRedDotByKey("active_mining_blog") --有新战报
    self:setObjectVisible("team_red_point_img", team_flag == 1)
    self:setObjectVisible("log_red_point_img", log_flag == 1)
end

function M:fingerSliding(locat)
    if not self.m_sliding then
        return
    end
    if self.m_control:checkHasChild() then
        return
    end
    if locat == true then
        --self:updateMsg("fingerSliding",2)
    elseif locat == false then
        local chivalry_lock = BtnOpenUtil:isBtnOpen(40)
        if chivalry_lock == true then
            self:updateMsg("fingerSliding",3)
        end
    end
end

function M:destroy()
    self.m_area_node:destroy()
    M.super.destroy(self)
end

return M