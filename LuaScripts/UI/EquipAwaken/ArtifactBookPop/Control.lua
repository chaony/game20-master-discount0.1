local M = class("ArtifactBookPopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("red_point_update", nil, "EquipAwaken")
        self:closeView()
    elseif msg == "tag_btn" then
        if self.m_model.tag_index ~= data then
			self.m_model.tag_index = data
            self.m_view:clearWeaponObj()
			self.m_view:refreshUI()
		end	
    elseif msg == "equip_icon_1" then
        self:checkEquip(1)
    elseif msg == "equip_icon_2" then
        self:checkEquip(2)
    elseif msg == "equip_icon_3" then
        self:checkEquip(3)
    elseif msg == "equip_icon_4" then
        self:checkEquip(4)
    elseif msg == "quick_lv_up_btn" then
        self.m_model.quick_lv_up  = not self.m_model.quick_lv_up
        if self.m_model.quick_lv_up == true then
            UserDataManager.local_data:setUserDataByKey("artifact_book_quick_lv", 1)
        else
            UserDataManager.local_data:setUserDataByKey("artifact_book_quick_lv", 0)    
        end
        self.m_view:updateLvUpUI()
    elseif msg == "lv_btn" then
        if self.m_model:checkSeason() == false then
            local season = self.m_model:getLockSeason()
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("equip_awake_016",season), delay_close = 2})
            return 
        end

        local max_lv = self.m_model:getThronsMaxlvByIndex()
        local lv = self.m_model:getThronslvByIndex(self.m_model.tag_index)
        if lv >= max_lv then
            self:lvUp2ToNet()
        else
            self:lvUpToNet()
        end
    elseif msg == "hint_btn" then
        self.m_view:showRightTips(true)
    elseif msg == "tips_mask" then
        self.m_view:showRightTips(false)
    elseif msg == "lv_lock_btn" then
        local cost = {}
        if self.m_model.quick_lv_up == true then
            cost = self.m_model:getQuickLvThronsConsByIndex(self.m_model.tag_index)
        else
            cost = self.m_model:getThronsConsByIndex(self.m_model.tag_index)
        end
        QuickOpenFuncUtil:hasCostsTips(cost)
    elseif msg == "lvup_over" then
        self.m_view:showHuaBan2()
        self.m_view:refreshUI()
    elseif msg == "cons_1_img" then  
        local cons = self.m_model:getThronsConsByIndex(self.m_model.tag_index)
        local click_obj = self.m_view:findGameObject(msg)
        GameUtil:lookInfoTips(self.m_control, {click_transform = click_obj.transform, data = cons[1]})
    elseif msg == "cons_2_img" then  
        local cons = self.m_model:getThronsConsByIndex(self.m_model.tag_index)
        local click_obj = self.m_view:findGameObject(msg)
        GameUtil:lookInfoTips(self.m_control, {click_transform = click_obj.transform, data = cons[2]})
    elseif msg == "break_btn" then
        if self.m_model:checkCryLv() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("equip_awake_028", self.m_model:getLvUpLock()), delay_close = 2})
            return
        end
        if self.m_model:checkCanAdvanced() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("equip_awake_027", self.m_model:getThronsMaxlvByIndex()), delay_close = 2})
            return
        end
        self:lvUp2ToNet()
	end
end

function M:checkEquip(Index) 
    local cur_equip_data = self.m_model:getEquipDataByIndex(Index)
    if cur_equip_data then
        self:openView("EquipAwaken.EquipAwakenPop", {equip_cfg = cur_equip_data})	    
    end
end

function M:onUpdate()
    self.m_view:refreshUI()
end

--升级
function M:lvUpToNet() 
    if self.m_model:checkCanLvUp() == false then
        local cons = self.m_model:getThronsConsByIndex(self.m_model.tag_index)
        if next(cons) ~= nil then
            local cons_data1 = RewardUtil:getProcessRewardData(cons[1])
            local cons_data2 = RewardUtil:getProcessRewardData(cons[2])
            if cons_data1.user_num >= cons_data1.data_num then
                QuickOpenFuncUtil:costsTips(cons_data1)
            elseif cons_data2.user_num >= cons_data2.data_num then
                QuickOpenFuncUtil:costsTips(cons_data2)
            end
        end	
        return 
    end
    local last_lv = self.m_model:getThronslvByIndex(self.m_model.tag_index)
    local function callfunc()
        local new_lv = self.m_model:getThronslvByIndex(self.m_model.tag_index)
        self.m_view:showHuaBan(last_lv, new_lv)
        self.m_view:playAttrNumEffect(last_lv, new_lv)
        self.m_view:lockTouch()
        local sub_num = 0.3
        if (new_lv - last_lv) > 1 then
            sub_num = ((new_lv-last_lv)*0.3)
            if sub_num < 1.5 then
                sub_num = 1.5
            end
            self:setOnceTimer(sub_num, function ()
                self.m_view:refreshUI()
            end)
        else
            self:setOnceTimer(0.3, function ()
                self.m_view:refreshUI()
            end)
        end
        self:setOnceTimer(sub_num, function ()
             self.m_view:unlockTouch()
        end)
    end
    local is_auto = 0
    if self.m_model.quick_lv_up == true then
        is_auto = 1
    end
    self.m_model:getNetData("thrones_up_lv",{ throne_id = self.m_model.tag_index, is_auto = is_auto}, callfunc)	
end

--进阶
function M:lvUp2ToNet() 	
    self:openView("EquipAwaken.ArtifactBookLvUpPop", {type_index = self.m_model.tag_index, quality_level = self.m_model:getThronsQualityLevelByIndex() })
end

return M
