local M = class("CustomMadeNode", LikeOO.OOUIbase)
--定制礼包
M.m_uiName = "OperateActivity/CustomMadeNode"

function M:onEnter()
    self.m_end_ts = 0
    self.time_down = self:findText("time_down")
    self:setTextByLanKey("time_down_text", "castingSword_str_0028")
end

function M:switchInit(url, data, id, callback, is_update)
    local function callFunc(data)
        if callback then
            callback(data)
        end
        if data and data["end"] then
            return
        end
        self.m_cont_data = self.m_model.m_custom_data or {}
        self:refreshUI()
    end
    self.is_update = is_update
    self.node_data = data
    self.m_model:initData(url, callFunc)
end

function M:switchUI()
    self.m_cont_data = self.m_model.m_custom_data or {}
    self:refreshUI()
end

function M:refreshUI()
    if self.m_cont_data == nil then
        return
    end
    self.m_cont_data = self.m_model.m_custom_data or {}
    self.m_version = 0
    for k,v in pairs(self.m_model.m_custom_actives) do
        if v.open_status > 0 then
            local active_tab = ConfigManager:getCfgByName("active_recharge")
            local act_data = active_tab[v.id]
            self.m_version = act_data.version
        end
    end
    self.m_end_ts = self.m_model:getActiveEndTime(self.m_model.m_custom_actives)
    self.m_control:updateTime()
    self:createLoopScroll()
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    local data = self.m_model:get_custom_made_cfg(self.m_version)
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
            show_data = data,
            loop_scroll_object = loopscroll,
			update_cell =function(index, cell_obj, cell_data)
                self:update_Gift(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                if self.m_model:checkActiveIsEnd(self.m_end_ts) == false then
                    self:updateMsg("buy_sdk_update")
                    return
                end
                local custim_data = self.m_model:getCustomGiftData(self.m_version, cell_data.id)
                if custim_data and #custim_data.pos_lst > 0 then
                    if cell_data.charge_id == 0 or cell_data.price == 0 then
                        self:updateMsg("receive_custom_gift", {gift_id = cell_data.id, version = self.m_version})
                    else
                        self:updateMsg("buy", cell_data.charge_id)
                    end
                else
                    self:updateMsg("open_custom_pop",  {cont_data = self.m_cont_data, version = self.m_version , id = cell_data.id, index = 1})
                end
			end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
    	self.m_scroll_view:reloadData(data, true)
    end 
end

function M:update_Gift(index, cell_obj, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaviour then
        local bl = false
        local custim_data = self.m_model:getCustomGiftData(self.m_version, cell_data.id)
        local reward_node_1 = luaBehaviour:FindGameObject("reward_node1")
        local reward_node_2 = luaBehaviour:FindGameObject("reward_node2")
        UIUtil.destroyAllChild(reward_node_1.transform)
        UIUtil.destroyAllChild(reward_node_2.transform)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "gift_name", cell_data.gift_name)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "yuan_text", self:getShowMoneyType())
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title_text", GameUtil:switchMoneyType(cell_data.price))
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_text", "gf_str_0048")
        local times = cell_data.times_limit
        if custim_data and #custim_data.pos_lst > 0 then
            bl = true
            times = cell_data.times_limit - custim_data.times
        end
        if bl then
            LuaBehaviourUtil.setImg(luaBehaviour, "buy_btn", "a_ui_currency_btn_middle_2", "common_ui")
            if cell_data.price == 0 then
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_btn_text", "new_str_0278")
            else
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_btn_text", GameUtil:getMoneyTypeNum(cell_data.price))
            end
        else
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_btn_text", "gf_str_0072")
            LuaBehaviourUtil.setImg(luaBehaviour, "buy_btn", "a_ui_currency_btn_middle_3", "common_ui")
        end
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "xiangou_text", "gf_str_0050", times)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "mask_img", times == 0)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", times ~= 0)
        local base_obj = self:creatItem(reward_node_1)
        self:updateItem(base_obj, cell_data.reward[1])
        for i = 2, #cell_data.reward do
            local add_obj = self:creatItem(reward_node_2)
            self:updateGiftItem(add_obj, cell_data, custim_data, i)
        end
    end
end


function M:creatItem(parent)
    local item = ResourceUtil:LoadUIGameObject("OperateActivity/CustomMade_Item", Vector3.zero, nil)
    item.transform:SetParent(parent.transform, false)
    return item
end

function M:updateItem(obj, data)
    GameUtil:updateItemElement(obj, data[1], true, true)
    UIUtil.setObjectVisible(obj.transform, false, "select_btn")
end

function M:updateGiftItem(obj, cfg, data, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local ItemNode = luaBehaviour:FindGameObject("ItemNode")
    if data then
        local pos = data.pos_lst[index-1]
        local items = cfg.reward[index]
        local reward_item = items[pos]
        GameUtil:updateItemElement(ItemNode, reward_item, true, true)
        UIUtil.setObjectVisible(obj.transform, true, "select_btn")
        luaBehaviour:RegistButtonClick(handler(self, function(obj, obj2, name)
            if name == "select_btn" then
                if self.m_model:checkActiveIsEnd(self.m_end_ts) == false then
                    self:updateMsg("buy_sdk_update")
                    return
                end
                self:updateMsg("open_custom_pop",  {cont_data = self.m_cont_data, version = self.m_version, id = cfg.id, index = index-1})
            end           
        end))
        local times = data.times - cfg.times_limit
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", times == 0)
    else
        UIUtil.setObjectVisible(obj.transform, false, "select_btn")
        GameUtil:updateItemElementNoData(ItemNode, nil,nil, function ()
            if self.m_model:checkActiveIsEnd(self.m_end_ts) == false then
                self:updateMsg("buy_sdk_update")
                return
            end
            self:updateMsg("open_custom_pop",  {cont_data = self.m_cont_data, version = self.m_version, id = cfg.id, index = index-1})
        end)
    end
end



function M:onButtonClick(obj, name)
    if name == "reward_1" then
       
    else
        M.super.onButtonClick(self, obj, name)
    end
end

function M:getShowMoneyType()
    local money_type = ConfigManager:getCommonValueById(331)
    for k,v in pairs(GlobalConfig.TYPE_MONEY) do
        if money_type == v.name then
            return v.sign_name
        end
    end
    return "¥"
end

function M:setSpine()
    local reward_data = RewardUtil:getProcessRewardData({101, 282, 1})
    if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
        local cfg = UserDataManager.hero_data:getHeroConfigByCid(reward_data.data_id)
        if cfg then
            local icon = cfg.hero_spine
            if self.cacheSpineName == icon then
                return
            else
                self.cacheSpineName = icon
            end
            local play_img = self:findGameObject("hero_spine")
            GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. self.cacheSpineName, "idle", 0, true)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end


return M
