---@class PengLaiBazaarMainView: OOPopBase
---@field m_model PengLaiBazaarMainModel
local M = class("PengLaiBazaarMainView", LikeOO.OOPopBase)

local NPC_SPINE_RES_LIST = {
    [1] = { res = "RoleSpine/A_SkeletonData", startNode = "npc_start_1", endNode = "npc_end_1", moveTime = 56, initScaleX = -1 },
    [2] = { res = "RoleSpine/B_SkeletonData", startNode = "npc_start_2", endNode = "npc_end_2", moveTime = 60, initScaleX = -1 },
    [3] = { res = "RoleSpine/C_SkeletonData", startNode = "npc_start_3", endNode = "npc_end_3", moveTime = 64, initScaleX = 1 },
}

M.m_uiName = "PengLaiBazzar/PengLaiBazzarMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

M.m_itemEffect = nil

function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, { self, self.dayRefresh })
    self.m_timer_obj_list = {}
    self:bindUI()
    self:setNPCRole()
    self:setPopularItem(true)
    self:setBazaarMap()
end

function M:bindUI()
    self:setTextByLanKey("close_title_text", "pengLai_text_003")
    self:setTextByLanKey("bag_btn_text", "pengLai_text_007")
    self:setTextByLanKey("bazzar_btn_text", "pengLai_text_006")
    self:setTextByLanKey("bazzar_build_num_title_text", "pengLai_text_005")
    self:setTextByLanKey("guess_btn_text", "pengLai_text_008")
    self:setTextByLanKey("bazzar_build_num_title_text", "pengLai_text_005")
    
    local text_money = self:findText("bazzar_build_num_text")
    local totalNum = self.m_model.m_maxVipBuildingNum + self.m_model.m_maxBuildingNum
    local curNum = self.m_model.m_unlockBuildingNum
    text_money.text = Language:getTextByKey("summer_text_drawDisPlay1", curNum, totalNum)
    
    local cur, max = self.m_model:getBazaarExpProgress()
    local expStr = self.m_model:getBazaarExpProgressStr()
    local sliderValue = max == 0 and 1 or cur / max
    
    self:setText("bazzar_exp_text", expStr)
    local expSlider = self:findSlider("bazzar_exp_slider")
    expSlider.value = sliderValue
end

---设置今日热卖道具
function M:setPopularItem(change) 
    self:setObjectVisible("popular_btn", self.m_model.m_popularItem ~= 0)
    
    if change and self.m_model.m_popularItem ~= 0 then
        local dataTable = {103, self.m_model.m_popularItem, 0}
        local cell_obj = self:findGameObject("item_node_cmp")
        local rewardData = RewardUtil:getProcessRewardData(dataTable)
        GameUtil:updateItemElement(cell_obj, dataTable, false, true)
        if self.m_itemEffect then
            U3DUtil:Destroy(self.m_itemEffect)
            self.m_itemEffect = nil
        end
        self.m_itemEffect = GameUtil:creatCommonItemEffect(cell_obj, rewardData.quality, 1)
    end
end

---设置摊位地图
function M:setBazaarMap()
    -- 生成地图
    for i, v in ipairs(self.m_model.m_buildings) do
        local boothObj = self:findGameObject("BoothNode_" .. i)
        if boothObj ~= nil then
            local luaBehaviour = UIUtil.findLuaBehaviour(boothObj)
            self.m_timer_obj_list[boothObj] = {
                isVipPos = false,
                pos = i,
                text = luaBehaviour:FindText("left_time_text"),
                slider = luaBehaviour:FindText("left_time_slider"),
                getBtn = self:findGameObject("get_reward_btn_" .. i)
            }

            self:setSingleBoothNode(luaBehaviour, i, v, false)
        else
            print("======================>" .. i)
        end
    end

    for i, v in ipairs(self.m_model.m_vipBuildings) do
        local boothObj = self:findGameObject("BoothNode_Vip_" .. i)
        if boothObj ~= nil then
            local luaBehaviour = UIUtil.findLuaBehaviour(boothObj)
            self.m_timer_obj_list[boothObj] = {
                isVipPos = true,
                pos = i,
                text = luaBehaviour:FindText("left_time_text"),
                slider = luaBehaviour:FindText("left_time_slider"),
                getBtn = self:findGameObject("get_reward_vip_btn_" .. i)
            }

            self:setSingleBoothNode(luaBehaviour, i, v, true)
        else
            print("===========VIP===========>" .. i)
        end
    end
    
    self:refreshMapCellTimer()
end

function M:setSingleBoothNode(luaBehaviour, pos, data, isVipPos) 
    local lockCmp = luaBehaviour:FindGameObject("lock_cmp")
    local unlockCmp = luaBehaviour:FindGameObject("unlock_cmp")
    local emptyCmp = luaBehaviour:FindGameObject("empty_cmp")
    
    local isLock = self.m_model:checkBazaarIsLock(pos, isVipPos)
    local isEmpty = self.m_model:checkBazaarIsEmpty(pos, isVipPos)
    
    lockCmp:SetActive(false)
    emptyCmp:SetActive(isEmpty)
    unlockCmp:SetActive(not isLock and not isEmpty)

    local btnStr = isVipPos and "get_reward_vip_btn_" or "get_reward_btn_"
    local canGetReward = self.m_model:checkRewardState(pos, isVipPos)
    local getRewardBtn = self:findGameObject(btnStr .. pos)
    getRewardBtn:SetActive(canGetReward)
    
    -- 处理特效播放
    local effectObjOnNew = luaBehaviour:FindGameObject("UI_PengLaiBazzar_onBuild")
    local effectObjOnDestroy = luaBehaviour:FindGameObject("UI_PengLaiBazzar_onDestory")
    local effectObjOnGetReward = luaBehaviour:FindGameObject("UI_PengLaiBazzar_onFull")
    effectObjOnNew:SetActive(false)
    effectObjOnDestroy:SetActive(false)
    effectObjOnGetReward:SetActive(false)
    
    local changeState = self.m_model:getBazaarChangeStateDataByPos(pos, isVipPos)
    if changeState then
        effectObjOnNew:SetActive(changeState.showNew)
        effectObjOnDestroy:SetActive(changeState.showDestroy)
        effectObjOnGetReward:SetActive(changeState.showGetReward)    
    end
    
    if data then    
        local leftTimeSlider = luaBehaviour:FindSlider("left_time_slider")
        local leftTimeText = luaBehaviour:FindText("left_time_text")
        local emptyDescText = luaBehaviour:FindText("empty_desc_text")
        local unlockDescText = luaBehaviour:FindText("unlock_desc_text")
        local spineObj = luaBehaviour:FindGameObject("spine_cmp")
        
        -- 加载 spine 动画
        local spineResName = self.m_model:getBuildSpineName(data.build_id)
        if spineResName ~= "" then
            GameUtil:updateSpineLoadSet(spineObj, spineResName, "idle", 0, true)    
        end

        emptyDescText.text = Language:getTextByKey("pengLai_text_009")
        unlockDescText.text = Language:getTextByKey("pengLai_text_010")
        leftTimeSlider.value = self.m_model:getCurPosLeftTimeProgress(pos, isVipPos)
        leftTimeText.text = self.m_model:getCurPosLeftTimeStr(pos, isVipPos)
    end
end

---设置NPC角色
function M:setNPCRole()
    for i = 1, 3 do
        local npcObj = self:findGameObject("NPCNode_" .. i)
        if npcObj ~= nil then
            local luaBehaviour = UIUtil.findLuaBehaviour(npcObj)
            self:setSingleNPCNode(luaBehaviour, i, NPC_SPINE_RES_LIST[i], npcObj)
        else
            print("======================>" .. i)
        end

    end
end

function M:setSingleNPCNode(luaBehaviour, i, resData, npcObj)
    local spineObj = luaBehaviour:FindGameObject("spine_obj")

    -- 加载 spine 动画
    local spineResName = resData.res
    if spineResName ~= "" then
        GameUtil:updateSpineLoadSet(spineObj, spineResName, "walk", 0, true)
    end
    
    -- 执行移动操作
    local startNode = self:findGameObject(resData.startNode)
    local endNode = self:findGameObject(resData.endNode)
    
    local startNodePos = startNode.transform.position
    local endNodePos = endNode.transform.position

    local sequence = Tweening.DOTween.Sequence()
    -- 设置角色到初始位置
    sequence:Append(npcObj.transform:DOMove(startNodePos, 0))
    sequence:Append(npcObj.transform:DOMove(endNodePos, resData.moveTime):SetEase(Tweening.Ease.Linear))
    sequence:AppendCallback(function()
        UIUtil.setLocalScale(npcObj.transform, -resData.initScaleX, 1, 1)
    end)
    sequence:Append(npcObj.transform:DOMove(startNodePos, resData.moveTime):SetEase(Tweening.Ease.Linear))
    sequence:AppendCallback(function()
        UIUtil.setLocalScale(npcObj.transform, resData.initScaleX, 1, 1)
    end)
    
    sequence:SetLoops(-1)
end

function M:refreshUI()
    print("[PengLaiBazzarMain][refreshUI]**************************************************")
    self:bindUI()
    self:setBazaarMap()
    self:setPopularItem(true)
end

function M:dayRefresh()
    -- 每日刷新热卖道具
    self.m_control:setOnceTimer(2, self:setPopularItem(true))
end

---刷新倒计时显示
function M:refreshMapCellTimer()
    for k, v in pairs(self.m_timer_obj_list) do
        if v.text then 
            local leftTimeStr = self.m_model:getCurPosLeftTimeStr(v.pos, v.isVipPos)
            v.text.text = leftTimeStr
        end
        
        if v.slider then
            local leftTimeProgress = self.m_model:getCurPosLeftTimeProgress(v.pos, v.isVipPos)
            v.slider.value = leftTimeProgress
        end
        
        if v.getBtn then
            local canGetReward = self.m_model:checkRewardState(v.pos, v.isVipPos)
            v.getBtn:SetActive(canGetReward)
        end 
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, { self, self.dayRefresh })
    M.super.destroy(self)
end

return M