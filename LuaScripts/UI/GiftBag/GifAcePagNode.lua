local M = class("GifAcePagNode", LikeOO.OOUIbase)
--锦囊玉轴
M.m_uiName = "GiftBag/GifAcePagNode"

function M:onEnter()
    
end

function M:switchInit(url, callback)
    local function callFunc(data)
        if callback then
            callback(data)
        end
        if data and data["end"] == 1 then
			return
		end
        self:refreshUI()
        if self:checkAutoOpen() == true then
            self:updateMsg("get_ace_pag_btn")
        end
    end
    self.m_model:initData2(url, callFunc)
end

function M:switchUI()
    self:refreshUI()
    if self:checkAutoOpen() == true then
        self:updateMsg("get_ace_pag_btn")
    end
end


function M:refreshUI()
    self:setObjectVisible("get_red_point", self:checkTaskRedPoint() == true)
    if self.m_model.m_scroll_data then
        self:updateScrollItems()
        self:updateCurDes()
        self:setObjectVisible("spine_xinshou", self.m_model.m_scroll_data.times == 0 and self.m_model:get_check_scroll_first() == true)
    end
end

function M:checkTaskRedPoint()
    if self.m_model.m_scroll_data == nil then
        return false
    end
    for k,v in pairs(self.m_model.m_scroll_data.quests) do
        if v.status == 1 then
            return true
        end
    end
    return RedPointUtil:getScrollActiveShopStatus()
end

function M:checkAutoOpen()
    for k,v in pairs(self.m_model.m_scroll_data.quests) do
        if v.status == 1 then
            return true
        end
    end
    return false
end


function M:updateCurDes()
    local m_scroll_data = self.m_model.m_scroll_data
    local scroll_cfg = self.m_model:getScrollCfg()
    local remain_ts = 0
    self.end_ts = self.m_model:getActiveEndTime(m_scroll_data.actives)
    self:updateTime()
    local comsume_data = self.m_model:getScrollConsume()
    if comsume_data == nil then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
        return
    end
    self:setImg(comsume_data.icon_name, comsume_data.atlas_name, "consume_img")
    local big_reward_parent = self:findGameObject("big_reward_node")
    UIUtil.destroyAllChild(big_reward_parent.transform)
    local big_reward = nil
    local scoreData = self.m_model:getCostNum()
    local consume_data = RewardUtil:getProcessRewardData(scoreData)
    self:setTextByLanKey("desc", "gf_str_0049")
    if  m_scroll_data.times >= scroll_cfg.free_time then
        self:setTextByLanKey("consume_num", "x"..consume_data.data_num)
    else
        self:setTextByLanKey("consume_num", "x0")
    end
    if self.m_model.m_scroll_data.layer == -1 then
        self:setTextByLanKey("stage_num", self.m_model:getMaxFloor())
        self:setObjectVisible("maxk_reward", true)
    else
        self:setObjectVisible("maxk_reward", false)
        self:setTextByLanKey("stage_num", self.m_model.m_scroll_data.layer)
    end
    
    if self.m_model.m_scroll_data.big_gift_id == 0 then
        local data_tab = {101, 1001, 1}
        big_reward = GameUtil:createItemElement(data_tab)
        GameUtil:updateItemElementNoData(
            big_reward,
            RewardUtil.REWARD_TYPE_KEYS.ITEM,
            nil,
            function()
                self:updateMsg("open_scroll_pop")
            end
        )
    else
        local big_reward_cfg = self.m_model:checkBigRcvd()
        local rewardTable = big_reward_cfg.reward[1] 
        big_reward = GameUtil:createItemElement(rewardTable, true, true)
        local data = RewardUtil:getProcessRewardData(rewardTable)
        GameUtil:creatCommonActiveEffect(big_reward, data.quality, 1)
    end
    big_reward.transform:SetParent(big_reward_parent.transform, false)
end

function M:updateScrollItems()
    local get_num = 0
    local data = {}
    for i = 1, 16 do
        local rcvd_gift = self.m_model:getScrollRcvdGift(i)
        if rcvd_gift and next(rcvd_gift) ~= nil then
            get_num = get_num + 1
        end
        data[i] = rcvd_gift or {}
        local cell_obj = self:findGameObject("cell_"..i)
        self:updateItemNode(i, cell_obj, data[i])
    end
    if get_num == 16 then
        self:setObjectVisible("kong_panel",true)
    end
end

function M:updateItemNode(index, obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour == nil then
        return
    end
    local reward_node = luaBehaviour:FindGameObject("reward_node")
    UIUtil.destroyAllChild(reward_node.transform)
    if next(data) ~= nil then
        local itemNode = GameUtil:createItemElement(data.gift[1], true, true)
        itemNode.transform:SetParent(reward_node.transform, false)
        local item_LuaBehaviour = UIUtil.findLuaBehaviour(itemNode)
        LuaBehaviourUtil.setObjectVisible(item_LuaBehaviour, "duigoudi_img", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "open_btn", false)
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "open_btn", true)
        local random_id = math.random(1,3)
        if random_id == 1 then
            local open_img = LuaBehaviourUtil.setImg(luaBehaviour,"open_img","a_jnyz_icon_xiangzi","active_ui")
            UIUtil:setLocalDelta(open_img.gameObject.transform, 78,62)
        elseif random_id == 2 then
            local open_img = LuaBehaviourUtil.setImg(luaBehaviour,"open_img","a_jnyz_icon_jinnang","active_ui")   
            UIUtil:setLocalDelta(open_img.gameObject.transform, 70,74)
        elseif random_id == 3 then
            local open_img = LuaBehaviourUtil.setImg(luaBehaviour,"open_img","a_jnyz_icon_jingshu","active_ui")  
            UIUtil:setLocalDelta(open_img.gameObject.transform, 76,76) 
        end
    end
    local function clickCallback()
        if next(data) == nil then
            self:updateMsg("open_scroll", {position = index, vsn = self.m_model.m_scroll_data.version })
        end
    end
    UIUtil.setButtonClick(obj, clickCallback)
end

function M:updateTime()
	if self.end_ts and self.end_ts > 0 then
		local time_show = self.end_ts - UserDataManager:getServerTime()
		self:setTextByLanKey("down_time", "activities_str_0012", GameUtil:formatTimeBySecond(time_show))
	end
end

function M:onButtonClick(obj, name)
    if name == "change_btn" then
        self:updateMsg("open_scroll_pop")
    elseif name == "yulan_btn" then    
        self:updateMsg("open_look_scroll")
    elseif name == "reward_btn" then
        self:updateMsg("jump_operate")    
    else
        self:updateMsg(name)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
