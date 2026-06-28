local M = class("MasterNodeView",LikeOO.OOUIbase)

M.m_uiName = "DestinyStar/MasterNode"

function M:onEnter()
    --self.m_hui_img = self:findImage("hui_img")
    --self.fate_build_btn = self:findButton("fate_build_btn")
    --self.fate_build_btn_img = self:findImage("fate_build_btn")
    --self:setTextByLanKey("fate_build_text", "fate_building_text_0002")
    --self:setTextByLanKey("cur_build_floor_text", "fate_building_text_0007")
    self:refreshUI()
end

function M:refreshUI()
    self:refreshMasterNode()
end

function M:refreshMasterNode()
    local node_lock_status = self.m_model:getMasterNodeIsLock()
    local master_data = UserDataManager.m_fate_master
    --master_id 五个柱子的id
    for master_id = 1, #node_lock_status do
        local master_obj = self:findGameObject("master_node" .. master_id)
        local luaBehaviour = UIUtil.findLuaBehaviour(master_obj)
        local is_unlock = node_lock_status[master_id] == 0
        local cur_data = master_data[tostring(master_id)] or nil
        local is_alive = is_unlock and cur_data

        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unlock_master_btn", is_unlock)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img", not is_unlock)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unlock_master_btn_text", is_unlock)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unlock_master_text", not is_unlock)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "alive_img", is_alive)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "master_hero_node", is_alive)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "slaves_hero_node", is_alive)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "master_hero_node", is_alive)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unlock_img", not is_alive)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unlock_master_node", not is_alive and is_unlock)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "unlock_master_text", "fate_building_text_0008", node_lock_status[master_id])
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "unlock_master_btn_text", "fate_building_text_0009")
        UIUtil:setLocalDelta(master_obj.transform, 100, is_alive and 600 or 300)
        self:refreshHeroNode(luaBehaviour, cur_data, master_id)
        if is_unlock and not is_alive then
            self:updateUnlockItem(master_id, luaBehaviour)  
        end
        
    end
end

function M:refreshHeroNode(luaBehaviour, cur_master_data, master_id)
    local master_hero_id = "" --柱子上的英雄id
    local master_role_type = 0
    if cur_master_data then
        master_hero_id = cur_master_data.master or ""
    end
    local master_hero_node = luaBehaviour:FindGameObject("master_hero_node")
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img", false)
    if master_hero_id ~= "" and master_hero_id ~= 0 then
        local h_data, h_cfg =  UserDataManager.hero_data:getHeroDataById(master_hero_id)
        master_role_type = h_cfg.role_type
        local hero_data = self.m_model:transHeroData(h_data, h_cfg)
        local master_hero_node_luaBehaviour = UIUtil.findLuaBehaviour(master_hero_node.transform)
        
        GameUtil:updateItemElementByData(master_hero_node.transform, hero_data,false,false,function ()
            self:updateMsg("add_master", { hero_id = master_hero_id, index = master_id})
        end, false, false)
        local camp_img = master_hero_node_luaBehaviour:FindGameObject("camp_img")
        local stars = master_hero_node_luaBehaviour:FindGameObject("stars")
        camp_img:SetActive(false)
        stars:SetActive(false)
    else 
        GameUtil:updateItemElementNoData(master_hero_node.transform, nil, nil, function ()
            self:updateMsg("add_master", {hero_id = master_hero_id, index = master_id})
        end)
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_nums", false)
    local slot_nums = self.m_model:getMasterSlotNumsByIndex(master_id)
    for slaves_pos = 1, 2 do --插槽位置
        local slaves_hero_node = luaBehaviour:FindGameObject("slaves_hero_node" .. slaves_pos)
        local slaves_hero_id = cur_master_data and cur_master_data.slaves[slaves_pos] or ""
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "slaves_hero_node" .. slaves_pos, slaves_pos <= slot_nums and master_hero_id ~= "" and master_hero_id ~= 0)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "slaves_nums" .. slaves_pos , slaves_hero_id ~= "")
        if slaves_hero_id ~= "" and slaves_hero_id ~= 0 then
            local h_data, h_cfg = UserDataManager.hero_data:getHeroDataById(slaves_hero_id)
            local itemData = self.m_model:getHeroDataById(h_data, h_cfg)
            local add_nums_des = self.m_model:getMasterSlotAddNumsByIndex(master_id, h_cfg.role_type == master_role_type and master_role_type ~= 0)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "slaves_nums" .. slaves_pos, add_nums_des .. "%")
            GameUtil:updateItemElementByData(slaves_hero_node, itemData,false,false,function ()
                self:updateMsg("add_slaves", { hero_id = slaves_hero_id, index = master_id, slaves_pos = slaves_pos})
            end)
        else
            GameUtil:updateItemElementNoData(slaves_hero_node.transform, nil, nil, function ()
                self:updateMsg("add_slaves", {hero_id = slaves_hero_id, index = master_id, slaves_pos = slaves_pos})
            end)
        end
    end
end

function M:updateUnlockItem(master_id, luaBehaviour)
    local fate_master_cfg = ConfigManager:getCfgByName("fate_master") or {}
    local cur_cfg = fate_master_cfg[master_id] or {}
    local build_cost = cur_cfg.build_cost or {}
    local reward_data = RewardUtil:getProcessRewardData(build_cost[1])
    if reward_data then
        local break_item = luaBehaviour:FindGameObject("unlock_master_node")
        GameUtil:updateItemElementByData(break_item, reward_data, true, true)
        local break_item_luaBehaviour = UIUtil.findLuaBehaviour(break_item.transform)
        local count_text = break_item_luaBehaviour:FindText("count_text")
        count_text.color = reward_data.user_num >= reward_data.data_num and Color.New(1,1,1) or Color.New(1,0,0)
        local btn = luaBehaviour:FindButton("unlock_master_btn")
        UIUtil.setButtonClick(
                btn,
                function()
                    self:updateMsg("unlock_master_btn", { master_id = master_id, reward_data = reward_data})
                end
        )
    end
   
end

return M