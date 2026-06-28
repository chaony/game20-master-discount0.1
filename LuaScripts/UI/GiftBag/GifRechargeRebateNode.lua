local M = class("GifRechargeRebateNode", LikeOO.OOUIbase)
--充值返利
M.m_uiName = "GiftBag/GifRechargeRebateNode"

function M:onEnter()
    self.end_ts = 0
    self.actives_info = {}
end
function M:switchUI(id)
    local nums = table.nums(self.actives_info)
    if nums > 0 then
        self:setSpine()
        self:createLoopScroll()
        self:updateTime()
    end
end
function M:refreshUI()
    self.actives_info = self.m_model.m_rechargeRebata_Data.actives[1]
    local nums = table.nums(self.actives_info)
    if nums > 0 then
        self:createLoopScroll()    
    end
end
--[[
    创建返利列表
]]
function M:createLoopScroll()
    local lianliankan_quest_data = ConfigManager:getCfgByName("lianliankan_quest")
    local rechargeRebate_data= lianliankan_quest_data[self.actives_info.open_id][self.actives_info.version]
    local data = {}
    
    local recharge_rebateData_status = self.m_model.m_rechargeRebata_Data
    local recharge_rebate_quests = recharge_rebateData_status.quests
    self.end_ts = recharge_rebateData_status.actives[1].end_ts
    local undone_quests = {}
    local receive_quests = {}
    local alreadyreceive_quests = {}
    local nums = 0;
    for k,v in pairs(rechargeRebate_data) do
        local recharge_Rebate = recharge_rebate_quests[tostring(k)]
        local status = recharge_Rebate.status
        v.status = status
        v.quest_id = k
        if status == 0 then
            table.insert(undone_quests,v)
        elseif status == 1 then
            table.insert(receive_quests,v)
        elseif status == 2 then
            table.insert(alreadyreceive_quests,v)
        end
    end
    table.insertto(data,receive_quests)
    table.insertto(data,undone_quests)
    table.insertto(data,alreadyreceive_quests)
    
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("rebate_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateCell(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                local params = {open_id = self.actives_info.open_id, vsn = self.actives_info.version, quest_id = cell_data.quest_id}
                self:updateMsg(click_name, params)
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data, true)
    end
end

function M:updateCell(index, obj, cfg)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local level_text = luaBehaviour:FindText("text_rechargeLevelText")
        local numbers_text = luaBehaviour:FindText("text_receiveNumbersText")
        local state_text = luaBehaviour:FindText("text_stateText")
        local parent = luaBehaviour:FindGameObject("itemParent")
        self:creatRewards(parent.transform,cfg.reward)
        level_text.text = Language:getTextByKey(cfg.name)
        local status = cfg.status
        if status == 0 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "btn_receiveBtn", false)
            state_text.text = Language:getTextByKey("recharge_rebate_text5")
            numbers_text.text = Language:getTextByKey("recharge_rebate_text1",0)
        elseif status == 1 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "btn_receiveBtn", true)
            state_text.text = Language:getTextByKey("recharge_rebate_text4")
            numbers_text.text = Language:getTextByKey("recharge_rebate_text1",0)
        elseif status == 2 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "btn_receiveBtn", false)
            state_text.text = Language:getTextByKey("recharge_rebate_text6")
            numbers_text.text = Language:getTextByKey("recharge_rebate_text1",1)
        end
    end
end

function M:creatRewards(parent, rewards)
    UIUtil.destroyAllChild(parent)
    local items = {}
    for k, v in pairs(rewards) do
        local item = GameUtil:createItemElement(v, true, true)
        local data = RewardUtil:getProcessRewardData(v)
        item.transform:SetParent(parent, false)
        items[k] = item
        if data.data_type == 130 then
            GameUtil:creatCommonActiveEffect(item)
        end
    end
    Logger.log(nums)
    return items
end

function M:setSpine()
    local recharge_rebateData = ConfigManager:getCfgByName("recharge_rebate")
    local c_id = recharge_rebateData[self.actives_info.open_id][self.actives_info.version].spine
    local hero_cfg = ConfigManager:getPlayerPictureCfg(tonumber(c_id))
    local spine_name = hero_cfg.hero_spine or "hero_0001_SkeletonData"
    local hk_obj = self:findGameObject("hero_spine")
    GameUtil:updateSpineLoadSet(hk_obj, "RoleSpine/" .. spine_name, "idle", 0, true)
end

function M:onButtonClick(obj, name)
    if name == "btn_infoBtn" then
        local recharge_rebateData = ConfigManager:getCfgByName("recharge_rebate")
        local content = Language:getTextByKey(recharge_rebateData[self.actives_info.open_id][self.actives_info.version].des)
        self:openView("Pops.CommonHelpPop", { title = "recharge_rebate_text3", content = content })
    end
end

function M:updateTime()
    if self.end_ts and self.end_ts > 0 then
        local time_show = GameUtil:formatTimeBySecond(self.end_ts - UserDataManager:getServerTime())
        self:setTextByLanKey( "text_timer","recharge_rebate_text2",time_show) --todo
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
