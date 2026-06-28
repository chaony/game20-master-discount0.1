local M = class("AwakeSystemGodPop", LikeOO.OOUIbase)

--登仙楼  登仙
M.m_uiName = "AwakeSystem/AwakeSystemGodPop"

local slider_obj_name = "slider"
local slider_name = "awake_system_text_004"

function M:onEnter()
    self:setTextByLanKey("change_text","awake_system_text_0014")
    self:setTextByLanKey("invite_text","awake_system_text_0035")
    self:setTextByLanKey("upgrade_text","awake_system_text_0034")
    self:setTextByLanKey("task_name_text","awake_system_text_0031")
    self.gray_img = self:findImage("gray_img")
    self.upgrade_btn_img = self:findImage("upgrade_btn")
    self.ori_pos = -114
    self.ori_length = 228
    local obj = self:findGameObject(slider_obj_name .. 1)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local fx_ui_obj = LuaBehaviourUtil.findGameObject(luaBehaviour,"UI_AwakeSystem_Tr001")
        local fill_ui_obj = LuaBehaviourUtil.findGameObject(luaBehaviour,"exp_fill_image")
        self.ori_pos = fx_ui_obj.transform.localPosition.x
        self.ori_length = fill_ui_obj.transform.sizeDelta.x
    end
    self:setObjectVisible("blue_block_text",true)
    self:refreshUI()

end

--刷新UI
function M:refreshUI(fx_flag)
    self:setTextByLanKey("day_nums_text","awake_system_text_0032",self.m_model.m_god_daily_remain_times)
    self:refrehCost() 
    self:refreshTask()
    self:refreshSlider(fx_flag)
    self:refrehSuccessRate()
end

--刷新消耗
function M:refrehCost()
    if self.m_model:getCanGodFlag() then
        local cur_fly_cfg,cur_fly_level = self.m_model:getCurGodCfg()
        local cur_cfg = cur_fly_cfg[cur_fly_level.lv]
        if self.m_model.m_currentHeroIndex ~= 0 and cur_cfg then
            local reward_node = self:findGameObject("cost_itemParent")
            local cost = {}  --精彩中的精彩 1 + 1 = 1
            local cost_extra = table.copy(cur_cfg.cost_extra) or {}
            cost = table.copy(cur_cfg.cost) or {}
            for k,v in ipairs(cost) do
                cost[k][3] = v[3] * self.m_model.m_god_cost_add
            end
            for k,v in ipairs(cost_extra) do
                table.insert(cost,v)
            end
            self.m_model.m_cur_god_cost_cfg = table.copy(cost)
            local item_list = GameUtil:createRewards(reward_node.transform, self.m_model.m_cur_god_cost_cfg, true, true, nil, 1)
            for k,v in ipairs(item_list) do
                local cost_item = self.m_model.m_cur_god_cost_cfg[k]
                local flag = self:refreshCostState(cost_item)
                local item_luaBehaviour = UIUtil.findLuaBehaviour(v)
                local q_img = item_luaBehaviour:FindImage("quality_img")
                local i_img = item_luaBehaviour:FindImage("item_img")
                q_img.material = flag and self.gray_img.material or nil
                i_img.material = flag and self.gray_img.material or nil
            end
        end
        self.upgrade_btn_img.material = nil
        self:setObjectVisible("slider_node",false)
        self:setObjectVisible("cost_itemParent",true)
    else
        self.m_model.m_cur_god_cost_cfg ={}
        self.upgrade_btn_img.material = self.gray_img.material
        self:setObjectVisible("slider_node",true)
        self:setObjectVisible("cost_itemParent",false)
    end
end

--刷新成功率
function M:refrehSuccessRate()
    --god_fail_rate  渡劫成功率加成
    --外加一个配置的
    if self.m_model:getCanGodFlag() then
        local value1,value2,value3 = self.m_model:getGodRate()
        local base = value1 + value2 +value3
        base = math.min(base,100)
        local rate = tostring((base)) .. "%"
        local name = Language:getTextByKey("awake_system_text_0033",tostring(rate))
        self:setTextByLanKey("success_rate_text",name)
        self:setObjectVisible("success_rate_node",true)
    else
        self:setObjectVisible("success_rate_node",false)
    end
end

function M:refreshText(cur_name,next_name)
    
end

function M:refreshCostState(v)
    local can_flag = true
    if v[1] == RewardUtil.REWARD_TYPE_KEYS.ITEM then
        local consItem = RewardUtil:getProcessRewardData(v)
        can_flag = consItem.user_num >= consItem.data_num
    elseif v[1] == RewardUtil.REWARD_TYPE_KEYS.MYSTIC then
        --elseif v[1] == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
        --  final_data[v[1]][(v[2])] = v[3]
    elseif v[1] == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
        local material_list = self.m_model:getEvoSixHeroList(v[2])
        can_flag = next(material_list) ~= nil
    end
    return not can_flag
end


--刷新进度条
function M:refreshSlider(fx_flag)
    local name = {"exp_body","exp_heart","exp_soul"}
    local cur_fly_cfg,cur_fly_level = self.m_model:getCurGodCfg()
    local last_god = table.copy(self.m_model.m_last_god)
    if cur_fly_cfg and cur_fly_level then
        local cur_cfg = cur_fly_cfg[cur_fly_level.lv]
        for i = 1,3 do
            local obj = self:findGameObject(slider_obj_name .. i)
            if not IsNull(obj) then
                local luaBehaviour = UIUtil.findLuaBehaviour(obj)
                if luaBehaviour then
                    local value = self.m_model.m_god[name[i]] or 0
                    local last_value = last_god[name[i]] or 0
                    local cfg_value = cur_cfg[name[i]] or 100
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "Slider_nums_text",value .. "%")
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "Slider_text", slider_name .. i)
                    local img = luaBehaviour:FindImage("exp_fill_image")
                    local exp = value/cfg_value
                    if value ~= last_value and fx_flag then
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_AwakeSystem_Tr001",true)
                        local fx_ui_obj = LuaBehaviourUtil.findGameObject(luaBehaviour,"UI_AwakeSystem_Tr001")
                        local sequence = Tweening.DOTween.Sequence()
                        sequence:Append(Tweening.DOTween.To(function(index)
                            img.fillAmount = index
                            local x = self.ori_pos + self.ori_length*index
                            local pos =  fx_ui_obj.transform.localPosition
                            fx_ui_obj.transform.localPosition = Vector3(x,pos.y,pos.z)
                        end, 0.0, exp, exp))
                        sequence:AppendInterval(0.2)
                        sequence:OnComplete(function ()
                            fx_ui_obj:SetActive(false)
                        end)
                        sequence:SetAutoKill(true)
                    else
                        img.fillAmount = exp
                    end
                end
            end
        end
    end
    self.m_model.m_last_god = table.copy(self.m_model.m_god)
end

function M:refreshTask()
    local data = ConfigManager:getCommonValueById(791,{})
    if self.m_rightloop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                local cfg = self.m_model.m_item_cfg[cell_data]
                if cfg and next(cfg) then
                    local reward_node = LuaBehaviourUtil.findGameObject(luaBehaviour,"itemParent")
                    local cost = {{103,cell_data,1}}
                    local item_obj = GameUtil:createRewards(reward_node.transform, cost, true, true, nil, 1)
                    local gray_flag = false
                    for k,v in ipairs(item_obj) do
                        local consItem = RewardUtil:getProcessRewardData(cost[k])
                        local item_luaBehaviour = UIUtil.findLuaBehaviour(v)
                        if consItem.user_num < consItem.data_num then
                            gray_flag = true
                            LuaBehaviourUtil.setTextByLanKey(item_luaBehaviour,"count_text","equip_str_033", tostring(consItem.user_num), tostring(consItem.data_num))
                        else
                            LuaBehaviourUtil.setTextByLanKey(item_luaBehaviour,"count_text", tostring(consItem.user_num) .. "/" .. tostring(consItem.data_num))
                        end
                    end
                    local get_img = luaBehaviour:FindImage("get_btn")
                    get_img.material = gray_flag and self.gray_img.material or nil
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"get_btn_text","awake_system_text_0012")
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"cell_title_text","awake_system_text_0013")
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"desc_text",cfg.name)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"cell_title_img",false)
                else
                    Logger.log("缺少相应的item配置" .. tostring(cell_data))
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("submit_item", {id = cell_data,obj = click_object},"AwakeSystem.AwakeSystemMain")
            end
        }
        self.m_rightloop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_rightloop_scroll_view:reloadData(data,true)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M

