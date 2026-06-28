local M = class("LuckyDrawView", LikeOO.OOPopBase)

M.m_uiName = "LuckyDraw/LuckyDraw"
M.m_iphoneXAdapter = true

function M:onEnter()
    --local one_cost = self.m_model:getOneCost()
    --local one_item = table.copy(self.m_model:getGachaItem())
    --table.insert(one_item, one_cost)
    --self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {ext_data = one_item})
    local open_data = self.m_model:getActiveCfgByOpenId(self.m_model.open_id)
	if open_data and open_data.name then
		self:setTextByLanKey("close_title_text", (Language:getTextByKey(open_data.name)))
    else
        --self:setTextByLanKey("close_title_text", UserDataManager.m_activity_name)
        self:setTextByLanKey("close_title_text", "luckyDraw_str_0001")
	end
    --设置背景和spine
    if self.m_model.active_datas then
        local Img_bg = self:findGameObject("bg_img")
        GameUtil:updateResourcesImg(Img_bg,"Texture/"..self.m_model.active_datas.background)
        if self.m_model.active_datas.hero_spine then
            self.m_model.hero_skin_data = self.m_model:getSkinData(self.m_model.active_datas.hero_spine)  --英雄皮肤信息
            local spine_name = self.m_model.hero_skin_data.hero_spine or "hero_0001_SkeletonData"
            local play_img = self:findGameObject("people_hero_bg")
            GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "", 0, true)
        end
        self:setTextByLanKey("once_btn_text", self.m_model.active_datas.gacha_des)
        self:setTextByLanKey("ten_btn_text", self.m_model.active_datas.gacha_des1)
    end
    
    self.m_big_reward_node = self:findGameObject("big_reward_node")
    self.itemNodes = {}
    for i = 1, 3 do
        local node = self:findGameObject("ItemNode"..i);
        table.insert(self.itemNodes, node);
    end
    local pz_obj = self:findGameObject("SkeletonGraphic")
    self.pingzi_spine = pz_obj.gameObject:GetComponent("SkeletonGraphic")
    local boy_obj = self:findGameObject("boy_spine")
    self.boy_spine = boy_obj.gameObject:GetComponent("SkeletonGraphic")
    --self:refreshBoySpineUI()
    --self:refreshSpineUI()

    local gacha_active_id = self.m_model:getGacheActiveID()
    self:setObjectVisible("change_btn", gacha_active_id ~= 0)
    
    self:refreshUI();
    self:refreshBigUI()
    self:updateTime()
    self:setTextByLanKey("pool_num_text", "tid#TianXiangReport_1")
    self:setTextByLanKey("change_btn_text", "new_str_0907")
end

-- 刷新奖励
function M:refreshReward( reward )
    for i, v in ipairs(reward) do
        GameUtil:updateItemElement(self.itemNodes[i], v,true, true);
    end
end

-- 刷新UI
function M:refreshUI()
    local reward_items = {}
    for i, v in ipairs(self.m_model.rewards) do
        table.insert(reward_items, v.reward[1])
    end

    local one_cost = self.m_model:getOneCost()
    local one_cost_data = RewardUtil:getProcessRewardData(one_cost)
    self:setImg(one_cost_data.icon_name, one_cost_data.atlas_name, "one_icon")
    self:setText("one_cont_text", "x" .. one_cost_data.user_num .. "/" .. one_cost_data.data_num)
    if one_cost_data.user_num < one_cost_data.data_num then
        self:setTextColor("one_cont_text", Color(1, 0.4431373, 0.2941177))
        self:setObjectVisible("once_btn_red_point", false)
    else
        self:setTextColor("one_cont_text", Color(1, 1, 1))
        self:setObjectVisible("once_btn_red_point", true)
    end
    local ten_cost = self.m_model:getTenCost()
    local ten_cost_data = RewardUtil:getProcessRewardData(ten_cost)
    self:setImg(ten_cost_data.icon_name, ten_cost_data.atlas_name, "ten_icon")
    self:setText("ten_cont_text", "x" .. ten_cost_data.user_num .. "/" .. ten_cost_data.data_num)
    if ten_cost_data.user_num < ten_cost_data.data_num then
        self:setTextColor("ten_cont_text", Color(1, 0.4431373, 0.2941177))
        self:setObjectVisible("ten_btn_red_point", false)
    else
        self:setTextColor("ten_cont_text", Color(1, 1, 1))
        self:setObjectVisible("ten_btn_red_point", true)
    end
    
    local gacha_active_id = self.m_model:getGacheActiveID()
    self:setObjectVisible("change_btn", gacha_active_id ~= 0)
    
    self:refreshLeftCountUI()
    self:refreshReward( reward_items );
    self:refreshRedPoint()
end

function M:refreshRedPoint()
    local red_bl = RedPointUtil:localRedPointJudge("TongYongGachaGift")
    self:setObjectVisible("gift_btn_red_point", red_bl == true)
end

function M:refreshLeftCountUI()
    self:setTextByLanKey("left_count", self.m_model:getBigRewardStr())
end

-- 刷新大奖UI
function M:refreshBigUI()
    local reward_data = self.m_model.m_big_reward[self.m_model.big_reward_index]
    if reward_data and reward_data.reward and next(reward_data.reward) ~= nil then
        UIUtil.destroyAllChild(self.m_big_reward_node.transform)
        local itemObj = GameUtil:createItemElement(reward_data.reward[1], true, true)
        itemObj.transform:SetParent(self.m_big_reward_node.transform, false)
    end
end

function M:palySpineAnim(callback)
    if not IsNull(self.pingzi_spine) then
        audio:SendEvtUI("UI_HSZDan")
        self:setObjectVisible("UI_NewYearLottery_001", true)
        self:setObjectVisible("show_ping_img", false)
        self.pingzi_spine.AnimationState:ClearTracks()
        self.pingzi_spine.AnimationState:SetAnimation(0, "NewYearLottery", false)
        self:lockTouch()
        self.m_control:setOnceTimer(0.8, function ()
            self:unlockTouch()
            if callback then
                callback()
            end
        end)
    end
end

function M:refreshSpineUI()
    if not IsNull(self.pingzi_spine) then
        self.pingzi_spine.AnimationState:ClearTracks()
        self.pingzi_spine.AnimationState:SetAnimation(0, "pose", false)
        self:setObjectVisible("UI_NewYearLottery_001", false)
        self:setObjectVisible("show_ping_img", true)
    end
end

function M:refreshBoySpineUI()
    if not IsNull(self.boy_spine) then
        self.boy_spine.AnimationState:ClearTracks()
        self.boy_spine.AnimationState:SetAnimation(0, "idle", true)
    end
end

function M:updateTime()
    local end_ts = self.m_model:getEndTs()
	local down_time = end_ts - UserDataManager:getServerTime()
	if down_time >= 0 then
		local text = GameUtil:formatTimeBySecond(down_time)
		self:setTextByLanKey("time_text", Language:getTextByKey("new_str_0919")..text)
	else
		self:updateMsg(99999)
	end
end

function M:destroy()
    --if self.m_attr_node then
    --    self.m_attr_node:destroy()
    --    self.m_attr_node = nil
    --end
    M.super.destroy(self)
end


return M