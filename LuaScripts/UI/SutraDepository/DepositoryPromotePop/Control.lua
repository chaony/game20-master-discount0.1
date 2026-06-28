local M = class("DepositoryPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.SutraDepository.DepositoryPop.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then
        if self.m_tuiyan_save then
            return
        end
        self:closeView()
    elseif msg == "promote_btn" then -- 参悟按钮
        if self.m_model.m_sel_func_tab_index == 1 then -- 参悟
            local needNum = self.m_model:screenSynthesisMysticNumByQuality(self.m_model.selMysticQuality)
            if table.nums(self.m_model.selMysticList) >0 and table.nums(self.m_model.selMysticList)<needNum then
                local cfg = GlobalConfig.QUALITY_COMMON_SETTING[self.m_model.selMysticQuality]
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("mystic_str_0061",needNum,Language:getTextByKey(cfg.name)), delay_close = 2})
                return
            elseif table.nums(self.m_model.selMysticList) == 0 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("mystic_str_0062"), delay_close = 2})
                return
            end
            self:syntheticMystic()
        elseif self.m_model.m_sel_func_tab_index == 2 then -- 推演
            if table.nums(self.m_model.selMysticList) == 0 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("mystic_str_0062"), delay_close = 2})
            else
                local cost_data = self.m_model:getTuiyanCost(self.m_model.selMysticQuality, self.m_model.selMysticList[1])
                if cost_data.user_num < cost_data.data_num then
                    local name = Language:getTextByKey(cost_data.name)
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("mystic_str_0076", name), delay_close = 2})
                else
                    self:tuiyanMystic()
                end
            end
        end
    elseif msg == "quick_add_btn" then -- 一键添加
        self.m_model.m_reward_mystic = nil
        self.m_model:quickAddMystic()
        if table.nums(self.m_model.selMysticList) == 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("mystic_str_0064")})
            return
        end
        self.m_view:refreshUI()
    elseif msg == "put_on_btn" or msg == "put_out_btn" then -- 点击添加秘籍
        if self.m_tuiyan_save then
            return
        end
        local flag, index = self.m_model:checkMysticSelected(data.oid)
        local cfg = self.m_model:getMysticData(data.data_id)
        if self.m_model.m_sel_func_tab_index == 1 then
            local needNum = 0
            if cfg.type == 3 then
                needNum = self.m_model:screenSynthesisMysticNumByType3(cfg.quality)  
            else
                needNum = self.m_model:screenSynthesisMysticNumByQuality(cfg.quality)    
            end
            if table.nums(self.m_model.selMysticList) == needNum and not flag then -- 当选中秘籍=needNum本时判断，不能再继续添加秘籍
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("mystic_str_0055", needNum), delay_close = 2})
                return
            end
            self.m_model.m_reward_mystic = nil
            self.m_model:addSelMysticList(data) -- 点击添加/删除秘籍
        elseif self.m_model.m_sel_func_tab_index == 2 then
            Logger.log(table.nums(self.m_model.selMysticList), "table.nums(self.m_model.selMysticList) ==")
            if table.nums(self.m_model.selMysticList) > 0 and msg == "put_on_btn" then
                self.m_model:replaceSelMystic(data, 1)
            else
                self.m_model:addSelMysticList(data)
            end
        end
        self.m_view:refreshUI()
    elseif msg == "MysicItem_1" then
        self.m_model:removeSelMysticByIndex(1)
        self.m_view:refreshUI()
    elseif msg == "MysicItem_2" then
        self.m_model:removeSelMysticByIndex(2)
        self.m_view:refreshUI()
    elseif msg == "MysicItem_3" then
        self.m_model:removeSelMysticByIndex(3)
        self.m_view:refreshUI()
    elseif msg == "MysicItem_4" then
        self.m_model:removeSelMysticByIndex(4)
        self.m_view:refreshUI()
    elseif msg == "MysicItem_5" then
        self.m_model:removeSelMysticByIndex(5)
        self.m_view:refreshUI()
        -- 1全部、2先天、3绝学
    elseif type(msg) == "number" and msg >= 1 and msg <= 4 then
        self:switchTabBtn(msg)
    elseif msg == "func_toggle" then
        self.m_model:setFuncTabIndex(data)
        self.m_view:refreshUI()
    elseif msg == "check_detail" then
        self:openView("SutraDepository.DepositoryPop", {oid = data.data_id, mode = 2})
    elseif msg == "group_detail_btn" then
        local mystic_group = self.m_model:getMysticBuffGroupById(data.data_id)
        if mystic_group then
            self:openView("SutraDepository.DepositoryGropSkillTips", {id = data.data_id})
        end
    elseif msg == "help_btn" or msg == "MysicItem_6" then
        if self.m_model.m_reward_mystic then
            self:updateMsg("check_detail", self.m_model.m_reward_mystic)
            return
        end
        if self.m_model.selMysticQuality == 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("mystic_str_0073"), delay_close = 2})
            return
        end
        if self.m_model.m_sel_func_tab_index == 1 then
            local needNum = self.m_model:screenSynthesisMysticNumByQuality(self.m_model.selMysticQuality)
            if table.nums(self.m_model.selMysticList) < needNum then -- 当选中秘籍=needNum本时判断，不能再继续添加秘籍
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("mystic_str_0074"), delay_close = 2})
                return
            end
            self:lookMysicCompositeProbability()
            -- local function call_func()
            --     self.mysicComposite_pop = nil
            -- end
            -- local mystic_rate_list, max_rate_mystic_list = self.m_model:getMysticDepositoryPromote()
            -- self:lookMysicCompositeProbabilityPop({mystic_rate_list= mystic_rate_list, max_rate_mystic_list = max_rate_mystic_list,
            --                                        call_func = call_func, next_quality = self.m_model.m_next_quality})
        elseif self.m_model.m_sel_func_tab_index == 2 then
            if msg == "help_btn" then
                if self.mysicTuiyan_pop then
                    self.mysicTuiyan_pop:destroy()
                    self.mysicTuiyan_pop = nil
                end
                local function call_func()
                    self.mysicTuiyan_pop = nil
                end
                local params = self.m_model:getTuiyanProbability()
                params.call_func = call_func
                params.parent = self.m_view.m_rootView
                local LookInfoTips = CustomRequire("UI.SutraDepository.DepositoryPromotePop.MysicTuiyanProbabilityPop")
                self.mysicTuiyan_pop = LookInfoTips.new(self, params)
            else
                local oid = self.m_model.selMysticList[1]
                local data, cfg = self.m_model:getMysticDataByOid(oid)
                self:openView("SutraDepository.DepositoryPop", {oid = data.id, mode = 2})
            end
        end
    elseif msg == "ok_btn" then
        self.m_model:resetData()
        self.m_view:refreshUI()
        self.m_tuiyan_save = false
        self.m_view:tuiyanSaveInteractableBtns(true)
    elseif msg == "cancle_btn" then
        self:cancelTuiyanMystic()
    end
end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_view:switchTabNode(index)
    end
end

--合成秘籍  mystic_id: 1   秘籍id (秘籍配置id)
function M:syntheticMystic()
    local function putCallback(response)
        audio:SendEvtUI("UI_MJHeCheng")
        self.m_view:showEffect(true)
        self.m_view:lockTouch()
        self:setOnceTimer(1, function()
            self.m_view:unlockTouch()
            self.m_view:showEffect(false)
            local mystic = response.reward.mystic
            self.m_model.selMysticList = {} -- 后成后重置
            self.m_model.selMysticQuality = 0
            self.m_model.selMysticType = 0
            self.m_view:refreshUI(mystic)
            if response.reward then
                --RewardUtil:rewardTipsByData(response.reward)
            end
            self:updateMsg("update_data", nil, "SutraDepository")
            audio:SendEvtUI("UI_MiJi_Synthesis")
        end)
    end
    self.m_model:getNetData("mystic_synthetic", {mystics = self.m_model.selMysticList}, putCallback)
end

-- 打开概率说明界面
function M:lookMysicCompositeProbabilityPop(params)
    if self.mysicComposite_pop then
        self.mysicComposite_pop:destroy()
        self.mysicComposite_pop = nil
    end
    local LookInfoTips = CustomRequire("UI.SutraDepository.DepositoryPromotePop.MysicCompositeProbabilityPop")
    self.mysicComposite_pop = LookInfoTips.new(self, params)
end

-- 合成秘籍概率请求
function M:lookMysicCompositeProbability()
    local function putCallback(response)
        local function call_func()
            self.mysicComposite_pop = nil
        end
        local mystic_rate_list, max_rate_mystic_list = self:getMaxCompositeProbability(response)
        -- self:lookMysicCompositeProbabilityPop({mystic_rate_list= mystic_rate_list, max_rate_mystic_list = max_rate_mystic_list,
        --                                        call_func = call_func, next_quality = self.m_model.m_next_quality})
        local params = {}
        params.next_quality = self.m_model.m_next_quality
        params.call_func = call_func
        params.max_rate_mystic_list = response.mystics_rate
        self:lookMysicCompositeProbabilityPop(params)
    end
    self.m_model:getNetData("mystic_show_rate", {mystics = self.m_model.selMysticList}, putCallback)
end

function M:getMaxCompositeProbability(response)
    local mystic_rate_list = {}
    for i, v in pairs(response.mystics_rate) do
        mystic_rate_list[tonumber(i)] = v
    end
    local max_rate = 0
    local max_rate_mystic_list = {} -- 合成概率最大的秘籍
    for id, rate in pairs(mystic_rate_list) do
        if rate >= max_rate then
            max_rate = rate -- 找到最大的概率
        end
    end
    for id, rate in pairs(mystic_rate_list) do
        if rate == max_rate then
            max_rate_mystic_list[id] = rate -- 找到最大概率的秘籍
        end
    end
    return mystic_rate_list, max_rate_mystic_list
end

function M:tuiyanMystic()
    local function putCallback(response)
        audio:SendEvtUI("UI_MJHeCheng")
        self.m_view:showEffect(true)
        self.m_view:lockTouch()
        self.m_tuiyan_save = true
        self.m_view:tuiyanSaveInteractableBtns(false)
        self:setOnceTimer(1, function()
            self.m_view:unlockTouch()
            self.m_view:showEffect(false)
            local mystic = response.reward.mystic
            --self.m_model:resetData() -- 后成后重置
            self.m_view:refreshUI(mystic)
            if response.reward then
                --RewardUtil:rewardTipsByData(response.reward)
            end
            self:updateMsg("update_data", nil, "SutraDepository")
            audio:SendEvtUI("UI_MiJi_Synthesis")
        end)
    end
    self.m_model:getNetData("mystic_deduce", {mystic_oid = self.m_model.selMysticList[1]}, putCallback)
end

function M:cancelTuiyanMystic()
    local function putCallback(response)
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("mystic_str_0082"), delay_close = 2})
        self.m_model:resetData()
        self.m_view:refreshUI()
        self.m_tuiyan_save = false
        self.m_view:tuiyanSaveInteractableBtns(true)
    end
    self.m_model:getNetData("mystic_cancel_deduce", {mystic_oid = self.m_model.selMysticList[1]}, putCallback)
end

return M
