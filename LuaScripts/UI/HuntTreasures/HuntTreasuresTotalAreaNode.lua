local M = class("HuntTreasuresTotalAreaNode",LikeOO.OOUIbase)

M.m_uiName = "HuntTreasures/HuntTreasuresTotalAreaNode"
local __max_mines_num = 9 --一页里的最大矿点数量

function M:onEnter()  
    self.node_panel = self:findGameObject("node_panel")
    local area_bg_img = self:findImage("area_bg_img")
    self.m_mine_tab = {}
    self.m_cur_show_time = 0
    self.m_cur_cd_time = 0
    self.m_show_flag = false
    self.m_show_index = 0
    self.m_bubble_text = {}
    --GameUtil:updateResourcesImg(area_bg_img, "Texture/a_fl_BG")
    --area_bg_img:SetNativeSize()
    self.m_dis = self:initPosYDis()
    self:initMineNode()
    self:refreshUI()

end

function M:getRandomNum()
    math.randomseed(os.time())
    local num = math.random( 1, #self.m_bubble_text )
    return num
end

function M:updateTime()
    local show_time = 3
    local cd_time = 5
    local prefab, luaBehaviour = nil, nil
    local desc = ""
    if self.m_show_index ~= 0 then
        prefab = self.m_mine_tab[self.m_show_index]
        desc = self.m_bubble_text[self.m_show_index]
        luaBehaviour = UIUtil.findLuaBehaviour(prefab)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bubble_img", self.m_show_flag and desc ~= "")
    end
    if self.m_show_flag then
        self.m_cur_show_time = self.m_cur_show_time + 1
        if luaBehaviour then
            LuaBehaviourUtil.setText(luaBehaviour, "bubble_text", self.m_bubble_text[self.m_show_index])
        end
    else
        self.m_cur_cd_time = self.m_cur_cd_time + 1
    end
    
    if self.m_cur_show_time >= show_time then
        self.m_cur_show_time = 0
        self.m_show_flag = false
        
    end
    if self.m_cur_cd_time >= cd_time or desc == "" then
        self.m_cur_cd_time = 0
        self.m_show_index = self:getRandomNum()
        self.m_show_flag = true
    end
end

function M:playEnterAnim(direction)
    if direction then
        self.m_transfer = direction
        self:runOpenAnim(self.node_panel)
    end
    local area_bg_img = self:findImage("area_bg_img")
    GameUtil:updateResourcesImg(area_bg_img, "Texture/a_hdtq_bg")
    area_bg_img:SetNativeSize()
end

function M:updateData()
    self:refreshUI()
end

function M:initPosYDis()
    local mine_node = self:findGameObject("mine_node_" .. 1)
    local pos1 = mine_node.transform.localPosition
    local mine_node = self:findGameObject("mine_node_" .. 12)
    local pos2 = mine_node.transform.localPosition
    return  math.abs(pos2.y - pos1.y)
end

function M:getNodeScaleByPosY(minde_index)
    local mine_node = self:findGameObject("mine_node_" .. minde_index)
    local pos1 = mine_node.transform.localPosition
    local mine_node = self:findGameObject("mine_node_" .. 12)
    local pos2 = mine_node.transform.localPosition
    local dis = math.abs(pos2.y - pos1.y)
    local normal_scale_num = dis / self.m_dis
    local scale_num = 1 - (1- normal_scale_num) * 0.3
    return scale_num
end

function M:initMineNode()
    for i = 1, __max_mines_num do
        local mine_node = self:findGameObject("mine_node_" .. i)
        local prefab = GameUtil:createPrefab("HuntTreasures/HuntTreasuresMineNode",mine_node.transform)
        self.m_mine_tab[i] = prefab
        --local scale_num = self:getNodeScaleByPosY(i)
        --prefab.transform.localScale = Vector3(scale_num,scale_num,scale_num)
    end
end

function M:refreshUI()
    self.m_bubble_text = {}
    for i = 1, __max_mines_num do
        local mine_node = self:findGameObject("mine_node_" .. i)
        local mines_data = self.m_model.m_mines[tostring(i)]
        if mine_node and mines_data then
            local mines_user = mines_data.user
            local desc = mines_data.desc
            self.m_bubble_text[i] = desc
            local prefab = self.m_mine_tab[i]
            local luaBehaviour = UIUtil.findLuaBehaviour(prefab)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bubble_img", false)
            LuaBehaviourUtil.setText(luaBehaviour, "area_combat_text", Language:getTextByKey("hunt_treasure_str_019", mines_data.combat))
            local mine_img_name = self.m_model:getMineImg(i)
            local area_img = luaBehaviour:FindImage("area_img")
            if mine_img_name and mine_img_name ~= "" then
                GameUtil:updateResourcesImg(area_img, "Texture/hunt_treasures/" .. mine_img_name)
                area_img:SetNativeSize()
            end
            local scale_num = self:getNodeScaleByPosY(i)
            prefab.transform.localScale = Vector3(scale_num,scale_num,scale_num)
            local self_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
            local user_name = ""
            if self_uid == mines_data.uid then
                user_name = Language:getTextByKey("hunt_treasure_str_017",mines_user.name )
            else
                user_name = Language:getTextByKey("hunt_treasure_str_018",mines_user.name )
            end
            if mines_user.is_robot then
            else
                local HeadNode = luaBehaviour:FindGameObject("HeadNode")
                GameUtil:setUserAvatar(HeadNode,mines_user,false,nil,{show_flag = true, scale = 1})
            end
            LuaBehaviourUtil.setText(luaBehaviour, "area_owner_text", user_name)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "HeadNode", mines_user.is_robot ~= true)
            if mines_data.is_enemy == 1 then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "relation_icon_img", true)
                LuaBehaviourUtil.setImg(luaBehaviour, "relation_icon_img",  "a_mjxb_choujia", ResourceUtil:getLanAtlas())
            elseif mines_data.is_guild == 1 then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "relation_icon_img", true)
                LuaBehaviourUtil.setImg(luaBehaviour, "relation_icon_img",  "a_mjxb_youfang", ResourceUtil:getLanAtlas())
            else
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "relation_icon_img", false)
            end
            local fxui_node = luaBehaviour:FindGameObject("fxui_node")
            UIUtil.destroyAllChild(fxui_node.transform)
            local effect_name = ""
            effect_name = self.m_model:getMineEffectName(i)
            if effect_name ~= "" then
                local mine_fx = ResourceUtil:GetUIEffectItem("HuntTreasures/" .. effect_name, fxui_node, nil)
            end
            local mine_quality = self.m_model:getAreaDropQualityByAreaIndex(i)
            for i = 1, 7 do
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_img" .. i,  i <= mine_quality)
            end
            UIUtil.setButtonClick(prefab, function()
                local oid = mines_data.oid
                self:updateMsg("click_mine", i)
            end)
        end
    end
end

function M:getOpenMineParams(i)
    local params = {}
    params.mines_data = self.m_model.m_mines[tostring(i)]
    --params.oid = params.mines_data.oid
    --params.desc = params.mines_data.desc
    --params.mines_user = params.mines_data.user
    params.plunder_times = self.m_model.m_data.plunder_times
    params.buy_plunder = self.m_model.m_data.buy_plunder
    params.area_index = i
    params.mine_img_name = self.m_model:getMineImg(i)
    return params
end

function M:onButtonClick(obj, name)
    M.super.onButtonClick(self, obj, name)
end

function M:destroy()
    M.super.destroy(self)
end

return M