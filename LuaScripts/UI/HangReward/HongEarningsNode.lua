---@class HongEarningsNode:OOUIbase
---@field m_model HangRewardModel
--- 挂机收益
local M = class("HongEarningsNode", LikeOO.OOUIbase)

M.m_uiName = "HangReward/HongEarningsNode"
M.m_iphoneXAdapter = true

function M:onEnter()
    self:setTextByLanKey("time_desc_text", "hang_str_0001")
    self:setTextByLanKey("common_title_text", "hang_str_0002")
    self:setTextByLanKey("quick_get_reward_btn_text", "qh_str_0001")
    self:refreshUI()
end

function M:refreshUI()
    local count = #self.m_model.reward
    if count > 0 then
        self:setObjectVisible("count", true)
        self:setObjectVisible("no_reward", false)
        self:setObjectVisible("get_reward_btn", true)
    else
        self:setObjectVisible("count", false)
        self:setObjectVisible("no_reward", true)
        self:setObjectVisible("get_reward_btn", false)
    end
    self:setTime()
    self:updateRewardLoopScroll()
    self:refreshRedPoint()
    local hero_exp_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HERO_EXP})
    local exp_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.EXP})
    local coin_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.COIN})
    local equip_exp_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.EQUIP_EXP})
    local xs_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.ITEM, 5025,0})
    self:setImg(hero_exp_data.icon_name, hero_exp_data.atlas_name, "hero_exp")
    self:setImg(exp_data.icon_name, exp_data.atlas_name, "exp")
    self:setImg(coin_data.icon_name, coin_data.atlas_name, "gold_exp")
    self:setImg(xs_data.icon_name, xs_data.atlas_name, "xs_img")
    self:setTextByLanKey ("exp_num", "new_str_0704", self.m_model:getIdlePlayerExp())
    self:setTextByLanKey("hero_exp_num", "new_str_0704",self.m_model:getIdleHeroExp())
    self:setTextByLanKey("gold_num","new_str_0704", self.m_model:getIdleMoney())
    if self.m_model:getIdleXSL() == 0 then
        self:setObjectVisible("reward_4", false)
    else
        self:setObjectVisible("reward_4", true)  
    end
    local equip_exp = self.m_model:getIdleEquipExp()
    local reward_node = self:findGameObject("reward_node")
    local reward_5 = self:findGameObject("reward_5")
    if equip_exp_data and equip_exp > 0 then
        self:setImg(equip_exp_data.icon_name, equip_exp_data.atlas_name, "equip_exp_img")
        self:setTextByLanKey("equip_exp_num","new_str_0704", equip_exp)
        self:setObjectVisible("reward_5", true) 
        UIUtil.setLocalPosition(reward_node.transform,nil, 114,nil)
        UIUtil.setLocalPosition(reward_5.transform,nil, 80,nil)
    else
        self:setObjectVisible("reward_5", false)   
        UIUtil.setLocalPosition(reward_node.transform,nil, 101,nil)  
    end
    self:setTextByLanKey("xs_num","new_str_0704", self.m_model:getIdleXSL())
	self:setTextByLanKey("get_reward_btn_text", "reward_recive_btn")
	self:setTextByLanKey("title_text", "idlereward_reward")
    
end

--[[
    掉落列表
]]
function M:updateRewardLoopScroll()
    self.m_reward_cell_tab = {}
    if self.m_reward_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = self.m_model.reward,
            one_line_count = 6,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                if self.m_model.m_double_bl == true then 
                    if cell_data[1] == RewardUtil.REWARD_TYPE_KEYS.COIN or cell_data[1] == RewardUtil.REWARD_TYPE_KEYS.HERO_EXP then
                        cell_data[3] = GameUtil:formatNum(cell_data[3]/2) 
                    end
                end
                local item = GameUtil:updateItemElement(cell_obj, cell_data, true, true)
                local LuaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
                if LuaBehaviour then
                    if self.m_model.m_double_bl == true then
                        if cell_data[1] == RewardUtil.REWARD_TYPE_KEYS.COIN or cell_data[1] == RewardUtil.REWARD_TYPE_KEYS.HERO_EXP then
                            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "double_earn", true)
                        else
                            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "double_earn", false)  
                        end
                    else
                        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "double_earn", false)   
                    end
                end
                if cell_data[1] == RewardUtil.REWARD_TYPE_KEYS.ITEM or cell_data[1] == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
                    self.m_reward_cell_tab[cell_obj] = true
                else
                    self.m_reward_cell_tab[cell_obj] = false
                end
            end
        }
        self.m_reward_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_reward_scroll_view:reloadData(self.m_model.reward)
    end
end

function M:refreshRedPoint()
    for k, v in pairs({{"quick_reward_point", 8}}) do
        local red_flag = RedPointUtil:isFuncRedPointById(v[2])
        self:setObjectVisible(v[1], red_flag == true)
    end
end

function M:setTime()
    self:setText("time_text", self.m_model:getTime())
end

function M:itemFlyAction()
    audio:SendEvtUI("PLAY_UI_GOLD")
    local delay = 0
    for k, v in pairs(self.m_reward_cell_tab) do
        k.transform:SetParent(static_rootControl.m_view.m_ui_obj.transform, true)
        local tweener = k.transform:DOScale(0.4, 1)
        CS.wt.framework.TweenTool.Bezier(
            k,
            self.m_model.m_target.transform,
            0.6,
            CS.wt.framework.BezierType.Bezier_Level2,
            delay,
            false,
            function()
                tweener:Kill()
                UIUtil.destroyObject(k)
                static_rootControl:updateMsg("bag_action", nil, "parent")
            end
        )
        delay = delay + 0.03
    end
end

return M
