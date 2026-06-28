---@class PetEvolvePopControl: OOControlBase
---@field m_model PetEvolvePopModel
---@field m_view PetEvolvePopView
local M = class("PetEvolvePopControl",LikeOO.OOControlBase)

function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, { self, self.closeViewEvent })
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:updateMsg("common_refresh", nil, "PetBreeding.PetBag")
        self:closeView()
    elseif type(msg) == "number" then
        if data == self.m_model.m_open_tab_index then
            return
        end
        self:switchTabBtn(msg)
    elseif msg == "click_cell" then
        local shortage_index = self.m_model:getShortageIndex(data)
        if shortage_index == 1 or shortage_index == 2 then
            self:popGetResource(shortage_index)
            return
        end
        if self.m_model:checkIsInLvList(data) then
            --local need_exp, need_coin = self.m_model:getNeedResourceNum(data)
            --self:openView("PetBreeding.PetEvolveLvUpPop",
            --            {on_ok_call = function() self:sendNetLvUp(data) end,
            --            need_exp = need_exp, need_coin = need_coin
            --            })
            local curTime = UserDataManager:getServerTime()
            local cur_day = TimeUtil.gmTime(curTime).yday
            local last_day = UserDataManager.local_data:getUserDataByKey("PetEvolveLvUpTips")
            if cur_day ~= last_day then
                local need_exp, need_coin = self.m_model:getNeedResourceNum(data)
                self:openView("PetBreeding.PetEvolveLvUpPop",
                        {on_ok_call = function() self:sendNetLvUp(data) end,
                         need_exp = need_exp, need_coin = need_coin
                        })
            else 
                self:sendNetLvUp(data)
            end
            return
        end
        if self.m_model:checkInSlot(data) then
            self.m_model:removeSlot(data)
        else
            self.m_model:addSlot(data)
        end
        self.m_view:refreshUI()
    elseif msg == "click_cell2" then
        if self.m_model:checkInCompSlot(data) then
            self.m_model:removeCompSlot(data)
        else
            self.m_model:addCompSlot(data)
        end
        self.m_view:refreshUI()
    elseif msg == "evolve_btn" then --进化
        self:netEvoLv()
    elseif msg == "preview_btn" then --预览
        if self.m_model.m_slot[1] == nil or self.m_model.m_slot[1] == "" or  
        self.m_model.m_slot[2] == nil or self.m_model.m_slot[2] == "" then
            -- GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("请继续添加奇兽！ --- "), delay_close = 2})
            return
        end
        self:openView("PetBreeding.PetEvolvePreview", {m_id = self.m_model.m_slot[1] , sec_id =  self.m_model.m_slot[2], lock_skill = self.m_model.lock_skill})
    elseif msg == "compre_btn" then --领悟
        local comprehead_num = self.m_model:getCompreheadNums()
        if comprehead_num <= 0 then
            -- GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("领悟次数已达上限 --- "), delay_close = 2})
            return
        end
        self:netLvUp()
    elseif msg == "quick_compre_btn" then --一键领悟
        local comprehead_num = self.m_model:getCompreheadNums()
        if comprehead_num <= 0 then
            -- GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("领悟次数已达上限 --- "), delay_close = 2})
            return
        end
        self:netLvUp(true)
    elseif msg == "select_evolv_index" then
        audio:SendEvtUI("UI_Popup_3")
        self.m_model.m_select_evo1 = data
        self.m_model:refreshFilterEvolvList()
        self.m_view:refreshUI()
    elseif msg == "select_comprehead_index" then
        self.m_model.m_select_evo2 = data
        self.m_model:refreshFilterCompreheadList()
        self.m_view:refreshUI()
    elseif msg == "refresh_lock_skill" then
        self.m_model.lock_skill = data or {}
    elseif msg == "ok_btn" then
        self:updateMsg("common_refresh", self.m_model.m_slot, "PetBreeding.PetSpawn")
        self:updateMsg(99999)    
    end
end

--发送进化请求
function M:netEvoLv()
    if self.m_model.m_slot[1] == nil or self.m_model.m_slot[1] == "" or  
    self.m_model.m_slot[2] == nil or self.m_model.m_slot[2] == "" then
        -- GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("请继续添加奇兽！ --- "), delay_close = 2})
        return
    end
    --发送请求
    local function sendEvoLvNet()
        local pet_hero, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_model.m_slot[1])
        local old_skills = table.copy(pet_hero.skills)
        local old_variation = table.copy(pet_hero.variation)
        local function callFunc(data)
            if data then
                self.m_model.m_slot[2] = ""
                local variation_skills = data.variation_skills[self.m_model.m_slot[1]] or {}
                local new_oid = data.new_pet_oids[1]
                self:openView("PetBreeding.PetEvolveSucceedPop",{new_oid = new_oid, old_variation = old_variation ,old_skills = old_skills,variation_skills = variation_skills, callback = function ()
                    RewardUtil:rewardTipsByData(data.reward)
                end})
                self.m_model:refreshData()
                self.m_view:refreshUI()
            end
        end
        local pet_data = {}
        pet_data[self.m_model.m_slot[1]]= {self.m_model.m_slot[2]}
        local lock_data = {}
        lock_data[self.m_model.m_slot[1]]= self.m_model.lock_skill
        self.m_model:getNetData("pet_evolution", { pet_data = pet_data,lock_data = lock_data}, callFunc, nil, true)
    end 
    local lock_max_num =self.m_model:getlockSkillNums()
    --检查技能锁
    if lock_max_num > table.nums(self.m_model.lock_skill) then
        local params = {
            on_ok_call = function(msg)
                sendEvoLvNet()
            end,
            on_cancel_call = function(msg)
                
            end,
            no_close_btn = false,
            tow_close_btn = true,
            text = Language:getTextByKey("当前主题奇兽仍有可锁技能，是否放弃剩余锁定数量直接进化？")
        }
        self:openView("Pops.CommonPop", params, nil, true)
    else
        sendEvoLvNet()
    end
end




--发送升级请求
function M:netLvUp(quick)
    local function callFunc(data)
        if data then
            self.m_view:refreshUI()
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("领悟成功 --- "), delay_close = 2})
        end
    end
    local level = self.m_model:getNetCompreheadLv(quick)
    self.m_model:getNetData("pet_level_up", { pet_oid = self.m_model.m_comprehead_id, level = level}, callFunc, nil, true)
end

--发送升级请求
function M:sendNetLvUp(oid)
    local function callFunc(data)
        if data then
            self.m_view:refreshUI()
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("pet_evo_lv_0035"), delay_close = 2})
        end
    end
    local level = self.m_model:getEvoMinLv()
    self.m_model:getNetData("pet_level_up", { pet_oid = oid, level = level}, callFunc, nil, true)
end

-- tab按钮切换
function M:switchTabBtn(index)
	if self.m_model.m_sel_tab_index ~= index then
		self.m_view:switchTabNode(index)
		self.m_model.m_open_tab_index = index
    end
end

--检测道具充足
function M:popGetResource(index)
    if index == 1 then
        local flag = QuickOpenFuncUtil:serverCostsTips(RewardUtil.ERROR_GIFT.ERROR_GIFT_COIN_NUM)
        if not flag then
            local params = {
                text = string.format(Language:getTextByKey("new_str_0204"))
            }
            self:openView("Pops.CommonPop", params)
        end
    elseif index == 2 then
        local flag = QuickOpenFuncUtil:serverCostsTips(RewardUtil.ERROR_GIFT.ERROR_GIFT_PET_EXP_NUM)
        if not flag then
            local params = {
                text = string.format(Language:getTextByKey("pet_bag_text_0027"))
            }
            self:openView("Pops.CommonPop", params)
        end
    end
end

function M:closeViewEvent(event, data)
    local view_name = data.name or ""
    if view_name == "Pops.CommonUseItemPop" or view_name == "Pops.CommonPop" then
        self.m_view:refreshUI()
    end

end

function M:destroy()
    --清除此次弹窗进化数据
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, { self, self.closeViewEvent })
    M.super.destroy(self)
end

return M;
