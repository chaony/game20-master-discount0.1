local M = class("HeavenBlessRewardNode", LikeOO.OOUIbase)
--天赐祈福
M.m_uiName = "GiftBag/HeavenBlessRewardNode"

local _heaven_stone = { RewardUtil.REWARD_TYPE_KEYS.ITEM, 5582, 0 }
function M:onEnter()
    self.total_itemsId_list = {} --固定奖励ID
    self.get_items_List = {}  --已经获得的奖励
    self.itemNodeList = {}
    
    self.round_Num = 4 --当前的轮次
    self.stone_num = 0  --灵石数量
    self.need_stone_num = 1 --当前抽奖需要的灵石数量
    self.round_reward_List = {} --轮次奖励列表
    self.get_stage = {} --已经获取的轮次奖励
    
    self.posList = {} --用于给动画使用的节点的位置
    
    self.select_node = self:findGameObject("select_node")
    self.cur_select_index = 0 --选择框的起始下标
    self.guide_effect = self:findGameObject("select_reward_effect")

    self.btn_one = self:findButton("btn_one")
    self.redPoint = self:findGameObject("one_red_point")    --抽奖红点
    self.get_redPoint = self:findGameObject("get_red_point") --任务列表红点

    self.select_node:SetActive(false)
    self.selectReward = false  --玩家是否已经选择过奖励
    local activeData = UserDataManager:getActivesDataByOpenId(400)
    self.m_version = activeData.version or 1
    
    EventDispatcher:registerEvent("HeavenBless_RefreshNetData", {self, self.refreshNetData})
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.heavenBlessEveryDayRefreshEvent})
    self.lottery_count_reward_cfg = ConfigManager:getCfgByName("lottery_count_reward") --轮次奖励配置表
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
    end
    self.m_model:initData2(url, callFunc)
end

function M:switchUI()
    self:refreshUI()
end

function M:refreshUI()
    local item_data = RewardUtil:getProcessRewardData(_heaven_stone) --获取拥有的灵石数量
    self.stone_num = item_data.user_num or 0
    
    if self.m_model.m_heavenBless_data == nil or next(self.m_model.m_heavenBless_data) == nil then 
        return
    end
    local data = self.m_model.m_heavenBless_data
    local cfg = self.m_model:get_heaven_bless_reward_cfg(self.m_version) --读表的数据
    if data ~= nil then
        local level_ids = data.weekendsevent.level_ids
        if level_ids then
            self.total_itemsId_list[1] = level_ids["1"][1]
            self.total_itemsId_list[2] = level_ids["2"][1]
            self.total_itemsId_list[3] = level_ids["2"][2]
            self.selectReward = true
        else
            --玩家还没有选择奖励
        end
        self.round_Num = data.weekendsevent.times or 0    --抽奖次数
        self.get_items_List = data.weekendsevent.has_draw_id or {}    --已经抽取的奖励id
        self.get_stage = data.weekendsevent.stage or {}   --已经抽取的轮次id
    end

    if cfg then
        if cfg.reward_cfg then
            self.reward_cfg = cfg.reward_cfg
            local index = 4
            for i, v in ipairs(cfg.reward_cfg) do --添加固定的奖励列表
                if v.level == 3 then
                    self.total_itemsId_list[index] = i
                    index = index + 1
                end
            end
        end
        if cfg.round_reward_cfg then
            --轮次奖励
            self.round_reward_List = cfg.round_reward_cfg
        end
        if cfg.needStoneNum_cfg then
            --轮次使用灵石的数量
            self.need_stone_num = cfg.needStoneNum_cfg[(self.round_Num >= 12 and 12 or self.round_Num) + 1] or 0
        end
    end

    self:refreshItemList() --刷新奖励列表
    self:refreshRoundRewardSlider() --刷新轮次奖励
    self:refreshRedPoint()
    self:refreshActivityTimer()
    self:showGuide(not self.selectReward) --显示引导
    self:updateMsg("refresh_TabLoopScroll", nil, "GiftBag")
end

function M:heavenBlessEveryDayRefreshEvent()
    local m_heavenBless_Data = self.m_model.m_heavenBless_data.actives[1]
    local endTimer = m_heavenBless_Data.end_ts
    local serverTimer = UserDataManager:getServerTime()
    if serverTimer > endTimer then
        local control = self.m_control
        if self.m_control.m_view then
            local params = {
                on_ok_call = function()
                    control:closeView()
                end,
                text = string.format(Language:getTextByKey("gf_str_0085")),
                no_close_btn = true
            }
            self:openView("Pops.CommonPop", params)
        end
    end
end

function M:refreshRedPoint()
    local redPoint_flag = self.stone_num >= self.need_stone_num and self.selectReward and #self.get_items_List < 12 
    self.redPoint:SetActive(redPoint_flag)
    self.get_redPoint:SetActive(RedPointUtil:getCommonQuestRedPointByOpenId(400) or RedPointUtil:localRedPointJudge("heaven_bless_reward_once"))
    
    --XXX:天赐祈福红点特殊处理：在model中存储红点状态
    self.m_model.m_heavenBless_data.LOCAL_RED_POINT_DATA = redPoint_flag or RedPointUtil:getCommonQuestRedPointByOpenId(400) or RedPointUtil:localRedPointJudge("heaven_bless_reward_once")
end

--刷新轮次奖励
function M:refreshRoundRewardSlider()
    self:setTextByLanKey("text_roundTxt", "gf_str_0142")  
    self:setTextByLanKey("text_roundNum", self.round_Num .. "/12")
    local lang_gf_str_0135 = Language:getTextByKey("gf_str_0135") --次
    for i = 1, 3 do
        local txt = self.round_reward_List[i].gacha_count
        self:setTextByLanKey("text_roundNum" .. i, txt .. lang_gf_str_0135)
    end
    local slider = self:findSlider("round_reward_slider")
    slider.value = self.round_Num

    for i = 1, 3 do
        local obj = self:findGameObject("one_box_node" .. i)
        local luaBehaviour = obj:GetComponent("LuaBehaviour")
        local boxBefore = luaBehaviour:FindGameObject("img_getBefore")
        local boxAfter = luaBehaviour:FindGameObject("img_getAfter")
        local boxNum = i  --当前是第几个箱子的奖励

        local box_state = self:checkRoundBoxState(i)
        local boxClick = function()
            if box_state ~= 0 then
                self.m_control:openView("Pops.LookRewardTips",
                        { rewards = self.round_reward_List[i].reward,
                          click_transform = obj.transform,
                          show_check_mark = box_state == 1 })
            else --箱子可领取状态
                local params = {
                    open_id = 400,
                    vsn = self.m_version,
                    stage_id = boxNum,
                }
                self.m_model:getNetData("weekend_sevent_receive_stage", params, function(response)
                    if response ~= nil and response.reward ~= nil then
                        --领取轮次励 弹出获得奖励弹窗
                        RewardUtil:rewardTipsByRewards(self.lottery_count_reward_cfg[400][self.m_version][boxNum].reward)
                        self:refreshNetData()
                    end
                end)
            end
        end
        boxBefore:SetActive(box_state == 0)
        boxAfter:SetActive(box_state == 1)

        UIUtil.setButtonClick(obj.transform, boxClick)
    end
end

function M:checkRoundBoxState(num)
    --  -1 未到达 0 可领取 1 已领取
    if self.round_Num / 4 >= num then
        local stage = self.get_stage
        for i, v in ipairs(self.get_stage) do
            if num == v then
                return 1
            end
        end
        return 0
    else
        return -1
    end
end

--抽奖的动画效果
function M:moveTo(rewardId)
    local _index = -1

    for i, v in pairs(self.total_itemsId_list) do
        --计算奖励item的下标
        if rewardId == v then
            _index = i
            break
        end
    end
    if _index == -1 then --没有找到对应奖励下标
        RewardUtil:rewardTipsByRewards(self.reward_cfg[rewardId].reward)  --直接显示获得奖励刷新数据
        self:refreshNetData()
        self:refreshItemList()
        return 
    end
    self.select_node:SetActive(true)
    self.m_control.m_view:lockTouch()  --停止一切点击事件
    self.posList = {}  --items的位置集合
    local num = _index + #self.itemNodeList * 2 - self.cur_select_index - 1--道具下标 + 循环两圈 - 当前选择框所在的下标位置
    for i = 0, #self.itemNodeList - 1 do
        self.posList[i] = self.itemNodeList[i + 1].transform.localPosition
    end
    local sequence = Tweening.DOTween.Sequence()
    local interval = 0.03  -- 每次移动的时间间隔
    local posIdx = self.cur_select_index     --开始的下标
    for i = 0, num do --动画效果 选择框移动越来越慢
        if i > num - 1 then
            interval = interval + 0.05
        elseif i > num - 3 then
            interval = interval + 0.03
        elseif i > num - 12 then
            interval = interval + 0.02
        end
        sequence:Append(self.select_node.transform:DOLocalMove(self.posList[posIdx % 12], interval):SetEase(Tweening.Ease.OutSine))
        posIdx = posIdx + 1
    end
    sequence:OnComplete(function()
        self.cur_select_index = _index
        
        self.m_control.m_view:unlockTouch()
        RewardUtil:rewardTipsByRewards(self.reward_cfg[rewardId].reward)  --获得奖励弹窗
        self:refreshItemList()
        self:refreshNetData()
    end)
    sequence:SetAutoKill(true)
end

--刷新轮盘奖励
function M:refreshItemList()
    local btnEmptyClickCallback = function()
        --打开选择奖励的界面
        self:openView("GiftBag.HeavenBlessSelectRewardPop", { reward_cfg = self.reward_cfg , version = self.m_version})
    end

    self.itemNodeList = {}
    for i = 1, 12 do
        --对前三个奖励特殊处理
        local obj = self:findGameObject("cell_item_" .. i)
        local luaBehaviour = obj:GetComponent("LuaBehaviour")
        local reward_item = luaBehaviour:FindGameObject("ItemNode")
        local btn_empty = luaBehaviour:FindButton("btn_empty")
        local select_node = luaBehaviour:FindGameObject("selectNode")
        
        table.insert(self.itemNodeList, obj)
        if i <= 3 then
            --判断自选奖励小于3个 显示选择道具按钮
            if self.total_itemsId_list[i] == nil then
                reward_item:SetActive(false)
                btn_empty.gameObject:SetActive(true)
                UIUtil.setButtonClick(btn_empty.transform, btnEmptyClickCallback)
            else
                reward_item:SetActive(true)
                btn_empty.gameObject:SetActive(false)
                local reward = self.reward_cfg[self.total_itemsId_list[i]].reward[1]
                GameUtil:updateItemElement(reward_item, reward, true, true)
            end
        else
            reward_item:SetActive(true)
            local reward = self.reward_cfg[self.total_itemsId_list[i]].reward[1]
            GameUtil:updateItemElement(reward_item, reward, true, true)
        end
        select_node:SetActive(self:checkGetRewardById(self.total_itemsId_list[i]))
    end
    
    local stone_txt = Language:getTextByKey("gf_str_0147")
    local stone_value = "   "..self.need_stone_num .."/"..self.stone_num
    self:setTextByLanKey("stone_value_text",stone_txt .. stone_value)
end

--判断当前奖励是否已经获取到
function M:checkGetRewardById(itemId)
    if self.get_items_List == nil then
        return false
    end
    for i, v in pairs(self.get_items_List) do
        if v == itemId then
            return true
        end
    end
    return false
end

function M:onButtonClick(obj, name)
    if name == "btn_one" then
        if self.total_itemsId_list[3] == nil then --没有选择够奖励 
            GameUtil:lookInfoTips(self.m_control , {
                msg = Language:getTextByKey("gf_str_0144"), --选择奖励填入转盘
                delay_close = 2
            })
            return 
        end
        if self.stone_num < self.need_stone_num then
            local stonetxt = Language:getTextByKey("gf_str_0147")
            local msg = Language:getTextByKey("gf_str_0148",stonetxt)
            GameUtil:lookInfoTips(self.m_control , {
                msg = msg, --灵石数量不足
                delay_close = 2
            })
            return 
        end
        
        local params = {
            open_id = 400, 
            vsn = self.m_version,
        }
        local drawRewardNetCallback = function(response)
            --抽奖回调
            if response == nil or response.gift_id == nil then
                return
            end
            local reward = response.gift_id
            
            table.insert(self.get_items_List, reward)  --将抽到的奖励添加进已获取列表
            
            self:moveTo(reward)
        end
        self.m_model:getNetData("weekend_sevent_receive", params, drawRewardNetCallback)
    elseif name == "get_ace_pag_btn" then
        --打开任务列表 获取灵石
        self:updateMsg("get_text")  --获取更多 任务列表
    else
        M.super.onButtonClick(self, obj, name)
    end
end

function M:showGuide(isShow)
    self.guide_effect:SetActive(isShow)
    self.btn_one.interactable = not isShow;
end

function M:refreshActivityTimer()
    local m_heavenBless_actives_data = self.m_model.m_heavenBless_data.actives[1]
    local stTimer = m_heavenBless_actives_data.start_ts
    local edTimer = m_heavenBless_actives_data.end_ts
    local starT = TimeUtil.gmTime(stTimer)
    local endT = TimeUtil.gmTime(edTimer)
    local timerformat = Language:getTextByKey("lantern_text_0007",starT.year, starT.month, starT.day,
            endT.year, endT.month, endT.day)
    self:setTextByLanKey("time_text", "lantern_text_0008",timerformat)
end

--
function M:refreshNetData()
    local callback = function(data)
        if data ~= nil then
            local level_ids = data.weekendsevent.level_ids
            if level_ids then
                self.total_itemsId_list[1] = level_ids["1"][1]
                self.total_itemsId_list[2] = level_ids["2"][2]
                self.total_itemsId_list[3] = level_ids["2"][2]
                self.selectReward = true
            else
                --玩家还没有选择奖励
            end
            self.round_Num = data.times or 0    --抽奖次数
            self.get_items_List = data.has_draw_id or {}    --已经抽取的奖励id
            self.get_stage = data.stage or {}   --已经领取的轮次id
            self:refreshUI()
        end
    end
    local params ={
        open_id = 400,
        vsn =  self.m_version
    }
    self.m_model:getNetData("weekend_sevent_index", params, callback)
end

function M:heavenBlessSetReward(response)
    for i = 1, 3 do
        self.select_items_node[i] = response[i]
        self.total_itemsId_list[i] = response[i]
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("HeavenBless_RefreshNetData", {self, self.refreshNetData})
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.heavenBlessEveryDayRefreshEvent})

    M.super.destroy(self)
end

return M