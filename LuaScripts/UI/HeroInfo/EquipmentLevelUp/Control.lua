local M = class("EquipmentLevelUpControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.HeroInfo.EquipmentLevelUp.Guide"
    self.can_close = false
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if self.m_model.m_open_tab_index == 2 and self.can_close == true then
            self:selectRecoinResult()
            return
        end
        if self.m_model.m_callback then
            self.m_model.m_callback()
        end
        self:closeView()
    elseif type(msg) == "number" and msg >= 1 and msg <= 5 then
        if data == self.m_model.m_open_tab_index then
            return
        end
        if self.m_model.m_open_tab_index == 2 and self.can_close == true then
            self.m_view:setTagStatus(self.m_model.m_open_tab_index)
            self:selectRecoinResult()
            return
        end
        self:switchTabBtn(msg)
    elseif msg == "check_eqp" then
        self:checkEqp(data)
    elseif msg == "sub_eqp" then
        self:subEqp(data)
    elseif msg == "yijianf_btn" then
        self:rapidFilling()
    elseif msg == "replace_btn" then
        self:eqpLevelUp()
    elseif msg == "recoin_btn" then
        if self.m_model.m_resultRace == 0 then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("equip_str_008"), delay_close = 2})
            return
        end
        local consItem = self.m_model:getCons()
        if  consItem.user_num < consItem.data_num then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("compass_str_002"), delay_close = 2})
            return
        end
        self:netRecoin()
    elseif msg == "ok_btn" then
        if self.m_model.m_open_tab_index == 2 and self.m_view.m_cur_tab_node then
            self.m_view.m_cur_tab_node:setOkBtn(false)
            self.m_view.m_cur_tab_node:setRecoinBtn(true)
            self.m_model.m_random_index = 0
            self.m_model:checkRecoin()
            self.m_model:refreshData()
            self.m_view:refreshUI()
            self.m_view.m_cur_tab_node:updataEqp()
            self.can_close = false
        end
    elseif msg == "cancle_btn" then
        self:netCancelRecoin()
    elseif msg == "break_btn" then
        self:netEvolution()
    elseif msg == "money_iocn" then
        local cons = self.m_model:getConsume()
        local data_reward = RewardUtil:getProcessRewardData(cons[1])
        self:openView("Item.ItemDetail", {show_data = data_reward, display = true}, nil, true)
    elseif msg == "cons_img" then
        local data_reward = self.m_model:getCons()
        self:openView("Item.ItemDetail", {show_data = data_reward, display = true}, nil, true)
    elseif msg == "polished_btn" then
        if self.m_model.m_batch_polished == true then
            self:netPolishsRandom()
        else
            self:netPolishRandom()
        end
    elseif msg == "polished_btn2" then
        self:netPolishRandom(true)
    elseif msg == "lock_attr" then
        self:netPolishLock(data)
    elseif msg == "updateUI" then
        self.m_view:refreshUI()  
    elseif msg == "go_to_e_a" then
        self:openView("EquipAwaken",{hero_oid = self.m_model.m_heroid, pos = self.m_model.m_pos})
    elseif msg == "all_polished_btn" then
        if self.m_model.m_batch_polished == false then
            self.m_model.m_batch_polished = true
        else
            self.m_model.m_batch_polished = false
        end
        self.m_view:refreshUI()
    elseif msg == "polished_hint_btn" then
        local params = {}
        params.title = Language:getTextByKey("equip_str_049")
        params.content = Language:getTextByKey("tid#Equipcommon_1")
        self:openView("Pops.CommonHelpPop", params)  
    elseif msg == "god_lv_up_btn" then
        self:netGodLvUp()
    elseif msg == "click_equip_cons" then
        if next(self.m_model.god_cons) ~= nil then
            for k,v in pairs(self.m_model.god_cons) do
                if data == v then
                    self.m_model.god_cons = {}    
                    self.m_view:refreshUI()
                    return
                end
            end
            self.m_model.god_cons = {}    
        end
        table.insert(self.m_model.god_cons, data)
        self.m_view:refreshUI()
    end
end

-- tab按钮切换
function M:switchTabBtn(index)
	if self.m_model.m_sel_tab_index ~= index then
		self.m_view:switchTabNode(index)
		self.m_model.m_open_tab_index = index
    end
end

function M:checkEqp(data)
    if self.m_model.m_canlevelup == false then 
        local params =
        {  
            no_close_btn = true,
            text = Language:getTextByKey("new_str_0067"),
        }
        self:openView("Pops.CommonPop",params)
        return
    end
    if self.m_model:expIsFull() then
        local params =
        {  
            no_close_btn = true,
            text = Language:getTextByKey("new_str_0100"),
        }
        self:openView("Pops.CommonPop",params)
        return
    end
    if not self.m_model:checkIsInEqpList(data) then
        self.m_model:addCheckEqp(data) --添加
        self.m_view:setEqpCell()
    end
    
end

function M:subEqp(data)
    self.m_model:removeCheckEqp(data) --移除
    self.m_view:setEqpCell()
end


--快速填充
function M:rapidFilling()
    if self.m_model:expIsFull() then
        local params =
        {  
            no_close_btn = true,
            text = Language:getTextByKey("new_str_0100"),
        }
        self:openView("Pops.CommonPop",params)
        return
    end
    self.m_model:rapidFilling()
    self.m_view:setEqpCell()
end

--强化 hero_oid: 英雄唯一id pos: 装备的位置，1-4 items: 消耗道具, {item_id: num}  equips: 消耗装备 {equip_oid: num}
function M:eqpLevelUp()
    --最大等级
    if self.m_model.m_canlevelup == false then 
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0067"), delay_close = 2})
        return
    end
    --没有选择道具
    local items = {}
    local equips = {}
    local num = 0
    for k,v in pairs(self.m_model.m_check_list) do
        local data = k
        if data.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
            items[data.data_id] = v
        else
            equips[data.oid] = v
        end
        num = num+1
    end
    if num == 0 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("equip_str_007"), delay_close = 2})
        return
    end
    local function levelUp()
        local last_lv, last_num = self.m_model.cur_eqpdata.lv, self.m_model.cur_eqpdata.exp
        local function callfunc()
            self.m_model.m_check_list = {}
            self.m_model:refreshData()
            self.m_view:updateLvUpUI(last_lv, last_num)
            self:updateMsg("update_equip",false,"HeroInfo")
		    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("equip_str_006"), delay_close = 2})
            audio:SendEvtUI("Play_UI_Intensify")
        end
        self.m_model:getNetData("equip_level_up",{hero_oid = self.m_model.m_heroid, pos = self.m_model.m_pos, items = items , equips = equips}, callfunc,false,nil, GlobalConfig.POST)
    end
    if self.m_model:checkEatEqpOver() == true then
        local params = {
			on_ok_call = function(msg)
				levelUp()
			end,
			no_close_btn = false,
			tow_close_btn = true,
			text = Language:getTextByKey("equip_str_014")
		}
		self:openView("Pops.CommonPop", params)
    else
        levelUp()        
    end
end

function M:onUpdate()
    self.m_view:setCurEqp()
end

---重铸----------------------------------------------------------------------------------------------------
function M:recoinEqp()
    self.can_close = true
    self.cur_Tim = self:setTimer(0.1, handler(self,self.showTurn))
end

function M:showTurn()
    self.m_model:turnNum()
    self.m_view.m_cur_tab_node:setLightImg()
    if self.m_model:canStop() == true then
        audio:SendEvtUI("UI_ChongZhu_fx_end")
        self:removeTimer(self.cur_Tim)
        self.m_model:checkRecoin()
        self.m_view.m_cur_tab_node:setOkBtn(true)
        self.m_view:unlockTouch()
        self:updateMsg("update_equip", nil, "HeroInfo") 
        self:updateMsg("update_equip", nil, "HeroInfo.EquipmentPop")
    end
end

function M:netRecoin()
    local function callfunc()
        audio:SendEvtUI("UI_ChongZhu_fx")
        self.m_view:lockTouch()
        self:recoinEqp()
        self:updateMsg("update_equip", nil, "HeroInfo") 
        self:updateMsg("update_equip", nil, "HeroInfo.EquipmentPop")
        self.m_view.m_cur_tab_node:setRecoinBtn(false)
    end
    self.m_model:getNetData("eqp_recast",{ hero_oid = self.m_model.m_heroid, pos = self.m_model.m_pos }, callfunc)	
end

function M:netCancelRecoin()
    local function callfunc()
        self:updateMsg("update_equip", nil, "HeroInfo")
        self:updateMsg("update_equip", nil, "HeroInfo.EquipmentPop")
        self.m_model.m_random_index = 0
        self.m_view.m_cur_tab_node:updataEqp()
        self.m_view.m_cur_tab_node:setOkBtn(false)
        self.m_view.m_cur_tab_node:setRecoinBtn(true)
        self.m_model:checkRecoin()
        self.m_view:refreshUI()
        self.can_close = false
    end
    self.m_model:getNetData("cancel_recast_recast",{ hero_oid = self.m_model.m_heroid, pos = self.m_model.m_pos }, callfunc)	
end

function M:selectRecoinResult()
    local params = {
        on_ok_call = function(msg)
            self:updateMsg("ok_btn")
        end,
        new_cancel_call = function(msg)
            self:netCancelRecoin()
        end,
        no_close_btn = false,
        tow_close_btn = true,
        text = Language:getTextByKey("equip_str_017")
    }
    self:openView("Pops.CommonPop", params)
end


function M:netEvolution()
    if self.m_model:checkCanPoloshed() == false then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("equip_str_031"), delay_close = 2})
        return
    end
    local function callfunc()
        -- 升阶成功
        self:updateMsg("update_equip", nil, "HeroInfo")
        --GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("equip_str_009"), delay_close = 2})
        self.m_model:refreshData()
        self.m_view:refreshUI()
        self:openView("HeroInfo.EquipmentLevelUp.EqpBreakPop", {eqp_cfg = self.m_model.cur_eqpcfg})
    end
    if self.m_model:checkCanBreak() == false then
        local e_data,e_cfg = self.m_model:getEqpData()
        local lv = ConfigManager:getCommonValueById(434,5)
        if e_data.lv < lv then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("equip_str_013",lv), delay_close = 2})
            return
        end
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("compass_str_002"), delay_close = 2})
        return
    end
    if self.m_model.m_heroid and self.m_model.m_pos then
        self.m_model:getNetData("eqp_evolution",{ hero_oid = self.m_model.m_heroid, pos = self.m_model.m_pos }, callfunc)	
    else
        self.m_model:getNetData("eqp_evolution",{ equip_oid = self.m_model.m_heroid, pos = self.m_model.m_pos }, callfunc)	
    end

end

---洗练----------------------------------------------------------------------------------------------------
--[[
    词缀洗练保护
    hero_oid: 侠客唯一id
    pos: 装备位置
    index: 词缀中的key
    lock: 是否锁 0不锁 1锁
]]
function M:netPolishLock(data)
    local function callfunc()
        self.m_view:refreshUI()
    end
    local params = {}
    params.hero_oid = self.m_model.m_heroid
    params.pos = self.m_model.m_pos
    params.index = data.index
    if data.data.lock == 0 then
        audio:SendEvtUI("UI_FangYu_Lock")
        params.lock = 1
    else
        audio:SendEvtUI("UI_FangYu_UnLock")
        params.lock = 0
    end
    self.m_model:getNetData("affix_protect", params, callfunc)	
end

--[[
    词缀洗练
    hero_oid: 侠客唯一id
    pos: 装备位置
]]
function M:netPolishRandom(is_high)
    if self.m_model:checkCanPoloshed() == false then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("equip_str_031"), delay_close = 2})
        return
    end
    local consItem = self.m_model:polishCons(is_high)
    if consItem.data_num > consItem.user_num then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("compass_str_002"), delay_close = 2})
        return
    end
    local function callfunc()
        -- if self.m_model:checkCanJueXing() == false then
        --     self:setOnceTimer(0.05, function ()
        --         self:netPolishRandom()
        --     end)   
        -- else
        self:openView("HeroInfo.EquipmentPolishedPop",{heroid = self.m_model.m_heroid, pos = self.m_model.m_pos, is_all_lock = false})
        -- end
    end
    local params = {}
    params.hero_oid = self.m_model.m_heroid
    params.pos = self.m_model.m_pos
    params.is_recast = is_high and 1 or 0
    if is_high then
        params.is_lock = 0
    end
    self.m_model:getNetData("affix_random", params, callfunc)	
end

--词缀批量洗练
function M:netPolishsRandom(is_high)
    if self.m_model:checkCanPoloshed() == false then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("equip_str_031"), delay_close = 2})
        return
    end
    local consItem = self.m_model:polishCons(is_high)
    if consItem.data_num > consItem.user_num then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("compass_str_002"), delay_close = 2})
        return
    end
    local function callfunc(data)
        local params = {}
        params.hero_oid = self.m_model.m_heroid
        params.pos = self.m_model.m_pos
        self:openView("HeroInfo.EquipmentPolishedsPop", params)
    end
    local params = {}
    params.hero_oid = self.m_model.m_heroid
    params.pos = self.m_model.m_pos
    self.m_model:getNetData("batch_affix_random", params, callfunc)	
end


---神级装备强化----------------------------------------------------------------------------------------------------
--[[
   "hero_oid": "",     // 侠客唯一id
    "pos": 0,           // 装备的位置，1-4
    "equips": {}     // 消耗装备 {equip_oid: num}
]]
function M:netGodLvUp()
    local function callfunc(data)
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("equip_str_006"), delay_close = 2})
        if data.reward and next(data.reward) ~= nil then
            RewardUtil:rewardTipsByData(data.reward)
        end
        self.m_model:refreshData()
        self.m_view:refreshUI()
    end
    if self.m_model:checkArtifactLock() == false then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0594"), delay_close = 2})
        return
    end
    if self.m_model:checkConsEquip() == false then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("equip_str_053"), delay_close = 2})
        return
    end
    if self.m_model:checkConsItem() == false then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("compass_str_002"), delay_close = 2})
        return
    end
    local equips = {}
    for k,v in pairs(self.m_model.god_cons) do
        equips[v] = 1
    end
    local params = {}
    params.hero_oid = self.m_model.m_heroid
    params.pos = self.m_model.m_pos
    params.equips = equips
    self.m_model:getNetData("strengthen_divine_equip", params, callfunc)	
end


function M:onDestroy()
	if self.cur_Tim then
        self:removeTimer(self.cur_Tim)
    end
end


return M
