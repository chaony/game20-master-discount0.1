local M = class("ActiveCurrentDailyRewardView",LikeOO.OOPopBase)

M.m_uiName = "ActiveCurrent/ActiveCurrentDailyReward"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("common_title_text", "UnionWar_str_061")
	self:setTextByLanKey("des_text", "new_str_1094")
	self:setTextByLanKey("get_reward_btn_text", "new_str_0056")
    self.hui = self:findImage("hui")
    self.m_get_reward_btn_img = self:findImage("get_reward_btn")
    self.m_get_reward_btn = self:findButton("get_reward_btn")
    self:refreshUI()
    local cur_id = self.m_model:getCurRewardId()
    if self.m_scroll_view and cur_id and cur_id <= table.nums(self.m_model.m_cur_cfg) then
        self.m_scroll_view:moveToCellIndex(cur_id)
    end
end

--刷新UI
function M:refreshUI()
    local cur_id = self.m_model:getCurRewardId()
    if self.m_model.m_daily_recv_rewards > 0 or self.m_model.m_max_evo <= 0 or cur_id == nil then
        self.m_get_reward_btn_img.material = self.hui.material;
        self.m_get_reward_btn.interactable = false;
    end
	self:createRewardLoopScroll()
end

----创建奖励列表------------------------------------------------------------------------------------------
function M:createRewardLoopScroll()
    local data = self.m_model.m_cur_cfg
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateItem(cell_obj, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
        
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end
end

function M:updateItem(obj, index, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_img", index <= 3) 
        local hero_id = data.hero_id 
        local quality = data.quality
        local reward = data.reward
        local farm_data = GlobalConfig.HERO_QUALITY_COMMON_SETTING[quality]
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_text", "new_str_1092", Language:getTextByKey(farm_data.name))
        local HeroNode = luaBehaviour:FindGameObject("HeroNode")
        local hero_data = RewardUtil:getProcessRewardData({101, hero_id, 1})
        --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "quality_up_img_mask", farm_data.hero_star > 0) -- 遮罩的角
        hero_data.quality = quality
        CommonUIUtil:updateHeroElementByData(HeroNode, hero_data)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"ok_text", "new_str_1091")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"no_text", "new_str_1093")
        local reward_node = luaBehaviour:FindGameObject("reward_content")
        GameUtil:createRewards(reward_node.transform, reward, true, true)

        if self.m_model.m_max_evo < quality then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_node", true )
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_text", true )
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "ok_text", false )
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_node", false )
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_text", false )
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "ok_text", true )
        end
    end    
end

return M