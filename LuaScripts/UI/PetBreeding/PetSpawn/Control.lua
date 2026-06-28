---@class PetSpawnControl: OOControlBase
---@field m_model PetSpawnModel
---@field m_view PetSpawnView
local M = class("PetSpawnControl", LikeOO.OOControlBase)

function M:onEnter()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        self:updateMsg("common_refresh", self.m_model.m_pet_change, "PetBreeding.PetBag")
        self:updateMsg("redPoint_refresh", nil, "PetBreeding.PetBreedingMain")
        self:closeView()
    elseif msg == "select_index" then
        self.m_model.index_oid = data
        self.m_view:refreshUI()
    elseif msg == "help_btn" then
        -- 说明
        self:openView("Pops.CommonHelpPop", { title = Language:getTextByKey("new_str_0023"), content = Language:getTextByKey("new_str_0023") })
    elseif msg == "pet_lock_btn" then
        if self.m_model.index_oid == 0 or self.m_model.index_oid == "" or  
        self.m_model.m_select_oid == 0 or self.m_model.m_select_oid == "" then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("请继续添加奇兽！ --- "), delay_close = 2})
            return
        end
        self:openView("PetBreeding.PetEvolvePreview", {m_id = self.m_model.index_oid , sec_id =  self.m_model.m_select_oid, lock_skill = self.m_model.lock_skill})
    elseif msg == "spwan_btn" then
        self:netEvoLv()
    elseif msg == "refresh_lock_skill" then
        self.m_model.lock_skill = data or {}
    elseif msg == "click_pet" or msg == "add_go2" or msg == "add_go1" then
        if self.m_model:checkIsEgg() == false then
            self:openView("PetBreeding.PetEvolvePop", {type = 1, pet_oid = self.m_model.index_oid, material_oid = self.m_model.m_select_oid})  
        else
            self:openView("PetBreeding.PetEvolvePop", {type = 1})
        end
    elseif msg == "common_refresh" then
        self.m_model.index_oid = data[1] or 0
        self.m_model.m_select_oid = data[2] or 0
        self.m_view:refreshUI()
    elseif msg == "add_one_btn" then -- +1
        self.m_model:addLv()
        self.m_view:refreshRateUI()
    elseif msg == "minus_one_btn" then -- -1
        self.m_model:subLv()
        self.m_view:refreshRateUI()
    elseif msg == "max_btn" then -- max
        self.m_model:MaxLv()
        self.m_view:refreshRateUI()
    elseif msg == "min_btn" then -- min
        self.m_model:MinLv()
        self.m_view:refreshRateUI()
    elseif msg == "lingwu_btn" then
        local params = {}
        params.title = "pet_evo_lv_0012"
        params.content = "tid#PetRuleDes_3"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "hint_btn" then
        local params = {}
        params.title = "pet_bag_text_0110"
        params.content = "tid#PetRuleDes_2"
        self:openView("Pops.CommonHelpPop", params) 
    elseif msg == "quick_btn" then
           --加速
        self:openView("PetBreeding.PetEvolveQuicklyPop", { pet_oid = self.m_model.index_oid, source = 2 })
    elseif msg == "pet_egg_success" then
        --成功孵化
        local evolve_succeed_data = self.m_model:getEvolvePopData()
        self:openView("PetBreeding.PetEvolveSucceedPop",
                { new_oid = evolve_succeed_data.oid, old_skills = evolve_succeed_data.old_skills, old_variation = evolve_succeed_data.old_variation,
                  variation_skills = evolve_succeed_data.variation_skills, callback = function()
                end })
        self:updateMsg(99999)
    end
end

--发送进化请求
function M:netEvoLv()
    if self.m_model.index_oid == nil or self.m_model.index_oid == "" or self.m_model.index_oid == 0 or 
    self.m_model.m_select_oid == nil or self.m_model.m_select_oid == "" or self.m_model.m_select_oid == 0  then
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("pet_evo_lv_0025"), delay_close = 2})
        return
    end
    local cons_coin, cons_exp= self.m_model:getCompreheadCons()
    if cons_coin.user_num < cons_coin.data_num  then
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("new_str_0098", Language:getTextByKey(cons_coin.name)), delay_close = 2})
        return
    end
    if cons_exp.user_num < cons_exp.data_num then
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("new_str_0098", Language:getTextByKey(cons_exp.name)), delay_close = 2})
        return
    end
    
    --发送请求
    local function sendEvoLvNet()
        local pet_hero, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_model.index_oid)
        local old_skills = table.copy(pet_hero.skills)
        local old_variation = table.copy(pet_hero.variation)
        local function callFunc(data)
            if data then
                self.m_model.m_pet_change = true
                self.m_model.index_oid = data.new_pet_oids[1]
                local pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_model.index_oid)
                if pet_data and pet_data.egg_ets then
                    self.m_model.egg_oid = self.m_model.index_oid
                    self.m_model.egg_data = pet_data
                end
                self.m_view:refreshUI()
                self:updateTime()
                self:updateMsg("update_pet_index", nil, "PetBreeding.PetBreedingMain")
            end
        end
        local pet_data = {}
        pet_data[self.m_model.index_oid]= {self.m_model.m_select_oid}
        local lock_data = {}
        lock_data[self.m_model.index_oid]= self.m_model.lock_skill
        local level_data = {}
        level_data[self.m_model.index_oid]= (pet_hero.lv + self.m_model.m_buy_lv)
        local params = {}
        params.pet_data = pet_data
        params.lock_data = lock_data
        if self.m_model.m_buy_lv > 0 then
            params.level_data = level_data
        end
        self.m_view:playSpineAnim(function ()
            self.m_model:getNetData("pet_evolution", params, callFunc, nil, true)
        end)
    end 
    local lock_max_num =self.m_model:getlockSkillNums()
    --检查技能锁
    if lock_max_num > table.nums(self.m_model.lock_skill) then
        local params = {
            on_ok_call = function(msg)
                sendEvoLvNet()
            end,
            no_close_btn = false,
            tow_close_btn = true,
            text = Language:getTextByKey("pet_evo_lv_0021")
        }
        self:openView("Pops.CommonPop", params, nil, true)
    else
        sendEvoLvNet()
    end
end

function M:updateTime()
    self.m_view:updateTime()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
