local M = class("HuntTreasuresGuildAreaInfoPopView",LikeOO.OOPopBase)

M.m_uiName = "HuntTreasuresGuild/HuntTreasuresGuildAreaInfoPop"
M.m_size_type = 2

function M:onEnter()
    self.m_show_flag = false
    self.m_cur_time = 0
   
    self:setText("get_reward_text", Language:getTextByKey("hunt_treasure_str_003"))
    local mine_name = self.m_model:getMineName()
    self:setTextByLanKey("common_title_text", mine_name)
    self:setTextByLanKey("no_reward_text", "hunt_treasure_str_045")
    self:refreshUI()
    self:setObjectVisible("challenge_img", self.m_model.m_status ~= self.m_model.m_status_code.IS_SELF)
    self:setObjectVisible("challenge_btn", self.m_model.m_status ~= self.m_model.m_status_code.IS_SELF)
    self:setObjectVisible("reward_bg_img", self.m_model.m_status == self.m_model.m_status_code.IS_SELF)
end

function M:destroy()
    M.super.destroy(self)
end

function M:refreshUI()
    local area_img = self:findImage("area_img")
    if self.m_model.m_mine_img_name ~= "" then
        GameUtil:updateResourcesImg(area_img, "Texture/hunt_treasures/" .. self.m_model.m_mine_img_name)
        area_img:SetNativeSize()
    end
    self:refreshRedPoint()
    self:createTeamHeros()
    self:setText("occ_time_text", "")
    self:setText("occ_time_value_text", "")

    self:setObjectVisible("rob_times_text", self.m_model.m_status ~= self.m_model.m_status_code.IS_SELF)
    self:setTextByLanKey("rob_times_text", "hunt_treasure_str_030", self.m_model:canRobTimes())
    if self.m_model.m_robot_id > 0 then
        self:setTextByLanKey("rob_times_text", "hunt_treasure_str_051")
    end
    self:refreshOwnerInfoNode()
    self:refreshProduce()
    self:setTextByLanKey("info_des_text", self.m_model:getAreaDropQualityDes())
    if self.m_model.m_status == self.m_model.m_status_code.IS_SELF then
        self:setText("rob_reward_text", Language:getTextByKey("hunt_treasure_str_036"))
        self:setText("challenge_btn_text", Language:getTextByKey("hunt_treasure_str_006"))
    elseif self.m_model.m_status == self.m_model.m_status_code.CAN_OWNER then
        self:setText("challenge_btn_text", Language:getTextByKey("hunt_treasure_str_005"))
        self:setText("rob_reward_text", Language:getTextByKey("hunt_treasure_str_038"))
    else
        self:setText("challenge_btn_text", Language:getTextByKey("hunt_treasure_str_005"))
        self:setText("rob_reward_text", Language:getTextByKey("hunt_treasure_str_038"))
    end

    local fxui_node = self:findGameObject("fxui_node")
    UIUtil.destroyAllChild(fxui_node.transform)
    --local effect_name = ""
    --effect_name = self.m_model:getMineEffectName()
    --if effect_name ~= "" then
    --    local mine_fx = ResourceUtil:GetUIEffectItem("HuntTreasures/" .. effect_name, fxui_node, nil)
    --end
end

function M:updateTime()
    if self.m_model:getRewardReceiveTime() > 0 then
        self:setText("occ_time_text", Language:getTextByKey("hunt_treasure_str_008"))
        local tim = GameUtil:formatTimeBySecond(self.m_model:getRewardReceiveTime(), 999)
        self:setText("occ_time_value_text", tim)
    end
    local show_time = 3
    local cd_time = 5
    self.m_cur_time = self.m_cur_time + 1

    if self.m_show_flag then
        if self.m_cur_time > show_time then
            self.m_show_flag = not(self.m_show_flag)
            self.m_cur_time = 0
        end
    else
        if self.m_cur_time > cd_time then
            self.m_show_flag = not(self.m_show_flag)
            self.m_cur_time = 0
        end
    end
    self:setObjectVisible("bubble_img", self.m_show_flag and self.m_model.m_desc ~= "")
    self:setText("bubble_text", self.m_model.m_desc)
end

function M:refreshProduce()
    self:updateLoopScroll()
    --self:setObjectVisible("rob_reward_list_node", self.m_model:getRewardReceiveTime() > 0 or self.m_model.m_robot_id > 0 or self.m_model.m_status ~= self.m_model.m_status_code.IS_SELF )
    self:updateRobLoopScroll()
end

function M:refreshOwnerInfoNode()
    self:updateHeroHead()
    local owner_combat, owner_name, guild_name = 0, "", ""
    owner_combat = self.m_model:getDataByKey("combat") and self.m_model:getDataByKey("combat") or 0
    owner_name = self.m_model.m_user and self.m_model.m_user.name or ""
    guild_name= self.m_model.m_user and self.m_model.m_user.guild_name or ""
    local server_id = self.m_model.m_user and self.m_model.m_user.server or 0
    local server_name = ""
    if server_id == 0 then
        server_name = UserDataManager.server_data:getServerName()
    else
        server_name = UserDataManager.server_data:getServerNameById(server_id)
    end
    self:setText("combat_num_title_text", Language:getTextByKey("new_str_0309") .. ":")
    self:setTextByLanKey("combat_num_text", owner_combat)
    self:setTextByLanKey("owner_text", Language:getTextByKey("hunt_treasure_str_001"))
    self:setTextByLanKey("union_text", Language:getTextByKey("hunt_treasure_str_002"))
    self:setTextByLanKey("server_text", Language:getTextByKey("hunt_treasure_str_057"))
    self:setTextByLanKey("owner_name_text", owner_name)
    self:setTextByLanKey("union_name_text", guild_name)
    self:setTextByLanKey("server_name_text", server_name)
end

function M:updateHeroHead()
    local hero_node = self:findGameObject("HeadNode")
    local user = self.m_model.m_user
    if user then
        GameUtil:setUserAvatar(hero_node, user, true,nil,nil,{show_flag = true, scale = 1})
    else
        GameUtil:setUserAvatar(hero_node, { avatar =  UserDataManager.user_data:getUserStatusDataByKey("avatar") },nil,nil,{show_flag = true, scale = 1})
    end
end

function M:createTeamHeros( rewards, is_show_num, is_show_detail, callback)
    local rewards = self.m_model:getHeroShowData()
    local team_id_tab = self.m_model:getDataByKey("team")
    if team_id_tab then
        for i = 1, 5 do
            local hero_node = self:findGameObject("hero_node_" .. i)
            local hero_id = team_id_tab[i]
            local item_data = rewards[i]
            if item_data and _G.next(item_data) then
                GameUtil:updateItemElementByData(hero_node,item_data,false,false,function ()
                    self:updateMsg("click_hero", { heroid = item_data.hero_data.oid})
                end)
                GameUtil:updateHeroLvByData(hero_node, item_data.hero_data)
                local hero_luaBehaviour = UIUtil.findLuaBehaviour(hero_node)
                if hero_luaBehaviour then
                    LuaBehaviourUtil.setObjectVisible(hero_luaBehaviour, "lock_image", false)
                end
            else
                local hero_luaBehaviour = UIUtil.findLuaBehaviour(hero_node)
                GameUtil:updateItemElementNoData(hero_node, nil, nil, function ()
                    self:updateMsg("team_edit_btn")
                end)
                if hero_luaBehaviour and self.m_model.m_status ~= self.m_model.m_status_code.IS_SELF then
                    LuaBehaviourUtil.setObjectVisible(hero_luaBehaviour, "add_img", false)
                end
            end
        end
    end
end

function M:updateLoopScroll()
    self.m_cell_tab = {}
    local data = self.m_model:getCurRegionDrop() or {}
    self:setObjectVisible("line_image", #data > 0)
    self:setObjectVisible("CommonTipsNode", #data == 0)
  
    local new_index = nil
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local data = cell_data
                local reward_data = RewardUtil:getProcessRewardData(data)
                local final_num, float_num = math.modf(reward_data.data_num * 60 * self.m_model.m_produce_add  );
                reward_data.data_num = final_num
                final_num = math.max(final_num, 1)
                local ui_element = GameUtil:updateItemElementByData(cell_object, reward_data, true, true)
                ui_element.red_point_img:SetActive(false)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                local item_type = 0
                if reward_data and reward_data.item_cfg and reward_data.item_cfg.type then
                    item_type = reward_data.item_cfg.type
                end
                if GameUtil:checkDoubleActiveByType(4) == true and item_type == 18 then --好感度道具双倍
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"double_earn", true)
                else
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"double_earn", false)
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
            end,
            ui_name = self.m_uiName
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data)
    end
end

function M:dealRewardData( ower_time)
    local data = self.m_model:getCurRegionDrop( self.m_model.m_status ~= self.m_model.m_status_code.IS_SELF ) or {}
    if self.m_model.m_status == self.m_model.m_status_code.IS_SELF then
        data = self.m_model:getDropReward()
    end
    local final_rewards_tab = {}
    for i = 1, #data do
        local reward_data = RewardUtil:getProcessRewardData(data[i])
        --if self.m_model.m_status == self.m_model.m_status_code.IS_SELF then
        --    local final_num = math.round(reward_data.data_num *  ower_time *  self.m_model.m_produce_add )
        --    if final_num >= 1 then
        --        reward_data.data_num = final_num
        --        final_rewards_tab[#final_rewards_tab + 1] = reward_data
        --    end
        --else
        final_rewards_tab[#final_rewards_tab + 1] = reward_data
        --end
    end
    return final_rewards_tab
end

function M:updateRobLoopScroll()
    self.m_cell_tab = {}
    local new_index = nil
    local ower_time = math.floor(self.m_model:getRewardReceiveTime() / 60 )
    local final_rewards_tab = self:dealRewardData(ower_time)
    
    if self.m_model.m_status == self.m_model.m_status_code.IS_SELF and not(next(final_rewards_tab)) then
        self:setObjectVisible("no_reward_text", true)
        self:setObjectVisible("rob_loopscroll", false)
    else
        self:setObjectVisible("no_reward_text", false)
        self:setObjectVisible("rob_loopscroll", true)
        if self.m_rob_loop_scroll_view == nil then
            local rob_loopscroll = self:findGameObject("rob_loopscroll")
            local params = {
                show_data = final_rewards_tab,
                loop_scroll_object = rob_loopscroll,
                update_cell = function(index, cell_object, cell_data)
                    local reward_data = cell_data
                    --local reward_data = RewardUtil:getProcessRewardData(data)
                    --if self.m_model.m_status == self.m_model.m_status_code.IS_SELF then
                    --    local final_num, _ = math.modf(reward_data.data_num *  ower_time *  self.m_model.m_produce_add );
                    --    final_num = math.max(final_num, 1)
                    --    reward_data.data_num = final_num
                    --end
                    local ui_element = GameUtil:updateItemElementByData(cell_object, reward_data, true, true)
                    ui_element.red_point_img:SetActive(false)
                    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                    local item_type = 0
                    if reward_data and reward_data.item_cfg and reward_data.item_cfg.type then
                        item_type = reward_data.item_cfg.type
                    end
                    if GameUtil:checkDoubleActiveByType(4) == true and item_type == 18 then --好感度道具双倍
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"double_earn", true)
                    else
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"double_earn", false)
                    end
                end,
                click_func = function(index, cell_object, cell_data, click_object, click_name)

                end,
                ui_name = self.m_uiName
            }
            self.m_rob_loop_scroll_view = LoopScrollViewUtil.new(params)
        else
            self.m_rob_loop_scroll_view:reloadData(final_rewards_tab)
        end
    end
end

function M:refreshRedPoint()
end

return M