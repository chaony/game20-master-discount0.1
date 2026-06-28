local M = class("NewYearLotteryView", LikeOO.OOPopBase)

M.m_uiName = "GiftBag/CelebrateNewYear/NewYearLottery"
M.m_iphoneXAdapter = true

function M:onEnter()
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 29})
    local open_data = self.m_model:getActiveCfgByOpenId(265)
	if open_data and open_data.name then
		self:setTextByLanKey("close_title_text", (Language:getTextByKey(open_data.name)))
    else
        self:setTextByLanKey("close_title_text", "碎碎平安")    
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
    self:refreshBoySpineUI()
    self:refreshSpineUI()
    self:refreshUI();
    self:refreshBigUI()
    self:updateTime()
    self:setTextByLanKey("pool_num_text", "new_year_str_005")
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
    self:refreshLeftCountUI()
    self:refreshReward( reward_items );
    self:refreshRedPoint()
end

function M:refreshRedPoint()
    local red_bl = RedPointUtil:localRedPointJudge("spring_festival_shop_gift")
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
    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
    M.super.destroy(self)
end


return M