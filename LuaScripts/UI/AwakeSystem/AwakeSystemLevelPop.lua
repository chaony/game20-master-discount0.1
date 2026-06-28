local M = class("AwakeSystemLevelPop", LikeOO.OOUIbase)

--登仙楼  羽化
M.m_uiName = "AwakeSystem/AwakeSystemLevelPop"

function M:onEnter()
    self.m_fTime = 0
    self.m_Time = 0
    self.exp = 0
    self:setTextByLanKey("Slider_text", "awake_system_text_0011")
    self:setTextByLanKey("change_text", "awake_system_text_0014")
    self:setTextByLanKey("task_name_text", "awake_system_text_0015")
    self.m_fill_img = self:findImage("exp_fill_image")
    self.hui = self:findImage("hui")
    self.m_awaken_fly_quest = ConfigManager:getCfgByName("awaken_fly_quest")
    local right_obj = self:findGameObject("right_bg")
    local left_obj = self:findGameObject("left_bg")
    self.pos1 = right_obj.transform.position
    self.pos2 = left_obj.transform.position
    self.fx_ui = self:findGameObject("UI_AwakeSystem_Tr002")
    self.legth = self.pos1.x - self.pos2.x
    self.pos =  self.fx_ui.transform.position
    self.m_update_key = "update_awaken"
    GameMain.addUpdate(self.m_update_key, handler(self, self.update))
end

function M:update()
    if self.m_fTime >= self.m_Time then
        self.m_Time = self.m_Time + CS.UnityEngine.Time.deltaTime
        if not IsNull(self.fx_ui) then
            local x = self.legth * self.m_Time
            local pos = self.pos
            local ori_x = pos.x
            ori_x = ori_x + x
            self.fx_ui.transform.position = Vector3(ori_x,pos.y,pos.z)
        end
    end
end

--刷新UI
function M:refreshUI(fx_flag)
    self:refreshTask()
    local cur_fly_cfg = self.m_model.m_awaken_fly_cfg[self.m_model.m_cur_hero_id]
    local cur_fly_level = self.m_model.m_fly_heros[tostring(self.m_model.m_cur_hero_id)]
    local cur_name = cur_fly_cfg[cur_fly_level.lv].name or {}
    local cfg_exp = cur_fly_cfg[cur_fly_level.lv].exp or 100
    self.exp =  self.m_model.m_cur_hero_id ~= 0 and self.m_model.m_fly.exp/cfg_exp or 0
    self:setTextByLanKey("Slider_nums_text", cur_name)
    if not fx_flag then
        self.m_fill_img.fillAmount = self.exp
        return
    end
    self.m_fTime = self.exp
    self.m_Time = 0
    --如果是进入界面，那么就直接赋值
   
    
    if self.exp ~= 0 then
        self.fx_ui:SetActive(true)
    else
        self.m_fill_img.fillAmount = 0
        self.fx_ui.transform.position = self.pos
        return
    end
    local sequence = Tweening.DOTween.Sequence()
    sequence:Append(Tweening.DOTween.To(function(index)
        local temp = math.floor(index)
        self.m_fill_img.fillAmount = index
     
    end, 0.0, self.exp, self.exp))
    sequence:AppendInterval(0.2)
    sequence:OnComplete(function ()
        self.fx_ui:SetActive(false)
    end)
    sequence:SetAutoKill(true)
    
end

function M:refreshText(cur_name,next_name)
    self:setTextByLanKey("Slider_text", cur_name)
    self:setTextByLanKey("Slider_nums_text", next_name)
end

--
function M:refreshTask()
    local data = self.m_model.m_fly_quests
    if self.m_rightloop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                local cfg = self.m_awaken_fly_quest[cell_data.quest_id]
                if cfg and next(cfg) then
                    local reward_node = LuaBehaviourUtil.findGameObject(luaBehaviour,"itemParent")
                    local item = GameUtil:createRewards(reward_node.transform, cfg.cost, true, true, nil, 1)
                    local exp = cfg.exp or 0
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"get_btn_text","awake_system_text_0012")
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"cell_title_text","awake_system_text_0013")
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"get_btn_text",cell_data.status == 0)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"get_btn",cell_data.status == 0)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"cell_title_img",cell_data.status == 1)
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"add_text","awake_system_text_0062",tostring(exp) .. "%")
                    local get_img = luaBehaviour:FindImage("get_btn")
                    local gray_flag = false
                    for k,v in ipairs(item) do
                        local item_obj = v
                        local cost = cfg.cost[k]
                        local item_luaBehaviour = UIUtil.findLuaBehaviour(item_obj)
                        local consItem = RewardUtil:getProcessRewardData(cost)
                        if consItem.user_num < consItem.data_num then
                            gray_flag = true
                            LuaBehaviourUtil.setTextByLanKey(item_luaBehaviour,"count_text","equip_str_033", tostring(consItem.user_num), tostring(consItem.data_num))
                        else
                            LuaBehaviourUtil.setTextByLanKey(item_luaBehaviour,"count_text", tostring(consItem.user_num) .. "/" .. tostring(consItem.data_num))
                        end
                    end
                    get_img.material = gray_flag and self.hui.material or nil
                else
                    Logger.log("缺少相应的任务配置" .. tostring(cell_data.quest_id))
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                local click_obj = luaBehaviour:FindGameObject("fenggexian")
                self:updateMsg("submit_rank", {index = index,data = cell_data,click_obj = click_obj},"AwakeSystem.AwakeSystemMain")
            end
        }
        self.m_rightloop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_rightloop_scroll_view:reloadData(data,true)
    end
end

function M:destroy()
    GameMain.removeUpdate(self.m_update_key)
    self.m_fTime = 0
    M.super.destroy(self)
end

return M

