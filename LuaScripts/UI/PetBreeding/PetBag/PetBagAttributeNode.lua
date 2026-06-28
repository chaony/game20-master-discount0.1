---@class PetBagAttributeNode: OOUIbase
---@field m_model PetBagModel
local M = class("PetBagAttributeNode", LikeOO.OOUIbase)

M.m_uiName = "PetBreeding/PetBagAttributeNode"

local tab_exp = { RewardUtil.REWARD_TYPE_KEYS.PET_EXP, 0, 0 } --经验
local tab_money = { RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0 } --金币

M.E_Color = Color(255 / 255, 253 / 255, 247 / 255)
M.U_Color = Color(241 / 255, 67 / 255, 31 / 255)

local Property = {
    { EnumerationId = 902, text_name = "hp_text", text_num = "hp_num", user_key = "hp" }, --生命
    { EnumerationId = 901, text_name = "attack_text", text_num = "attack_num", user_key = "atk" }, -- 攻击
    { EnumerationId = 903, text_name = "def_text", text_num = "def_num", user_key = "def" }, -- 防御
    { EnumerationId = 9950, text_name = "anger_text", text_num = "anger_num", user_key = "power" }, -- 气势
}

function M:onEnter()
    self.lv_effect = {} --升级特效预制
    local com_parent = self:findGameObject("com_eff")
	local property = self:findGameObject("property")
	local effect = ResourceUtil:GetUIEffectItem("HeroBag/UI_HeroBag_ZhanLi_001", com_parent)
	-- local effect2 = ResourceUtil:GetUIEffectItem("HeroBag/UI_HeroBag_ZhanLi_002", property)
    self:setParticleRenderOrder(effect)
	-- self:setParticleRenderOrder(effect2)
	table.insert(self.lv_effect, effect)
	-- table.insert(self.lv_effect, effect2)
    for k,v in pairs(self.lv_effect) do
		if not IsNull(v) then
			v:SetActive(false)
		end
	end
    self:bindUI()
    self:initLvEffect()
    self:refreshUI()
end

function M:refreshUI()
    local data = self.m_model.m_pet_list
    if #data <= 0 or not self.m_model.m_sel_pet_oid then
        return
    end
    local isEgg = self.m_model:checkIsEgg(self.m_model.m_sel_pet_oid)
    self:refreshPropData(isEgg)
    self:updateBtnState(isEgg)
end

function M:bindUI()
    self.m_hero_enumeration_cfg = ConfigManager:getCfgByName("hero_enumeration")
    for k, v in ipairs(Property) do
        local lan_key = self.m_hero_enumeration_cfg[v.EnumerationId].name
        self:setTextByLanKey(v.text_name, lan_key)
    end

    self:setTextByLanKey("talent_hp_text", "pet_bag_text_0008")
    self:setTextByLanKey("talent_attack_text", "pet_bag_text_0008")
    self:setTextByLanKey("talent_def_text", "pet_bag_text_0008")
    self:setTextByLanKey("talent_anger_text", "pet_bag_text_0008")
    self:setTextByLanKey("lv_title_text", "pet_bag_text_0010")
    self:setTextByLanKey("evolve_text", "pet_bag_text_0011")
    self:setTextByLanKey("level_up_text", "pet_bag_text_0012")
    self:setTextByLanKey("quick_level_up_text ", "pet_bag_text_0013")
    self:setTextByLanKey("can_evolve_tips", "pet_bag_text_0014")
    self:setTextByLanKey("no_lv_tips", "pet_bag_text_0015")
    self:setTextByLanKey("variation_text", "pet_bag_text_0007")
    self:setTextByLanKey("quick_egg_text", "pet_bag_text_0030")

    self.m_lv_btn_img = self:findImage("level_up_btn")
    self.m_evo_btn_img = self:findImage("evolve_btn")
    local gray_img = self:findImage("gray_img")
    self.m_gray_material = gray_img.material
    --进化按钮不会置灰
    local normal_img = self:findImage("evolve_btn")
    self.m_normal_material = normal_img.material
end

function M:refreshPropData(isEgg)
    self:hideEffect()
    self:clearAnim()
    local level = self.m_model:getCurShowLevel()
    local talent_data = self.m_model:getTalentData()
    self:setText("pet_lv_text", GameUtil:formatValueToString(level))

    if not isEgg then
        local attrs = self.m_model:getAttrs()
        local combat = self.m_model:getCurCombat()
        local variation_rate = self.m_model:getVariationRate()
        self:setText("hp_num", GameUtil:formatValueToString(math.round(attrs["hp"])))
        self:setText("attack_num", GameUtil:formatValueToString(math.round(attrs["atk"])))
        self:setText("def_num", GameUtil:formatValueToString(math.round(attrs["def"])))
        self:setText("anger_num", GameUtil:formatValueToString(math.round(attrs["power"])))
        self:setText("combat_text", GameUtil:formatValueToString(combat))
        self:setText("variation_num", variation_rate)
        for i = 1, 4 do
            self:setText("talent_num" .. i, GameUtil:formatValueToString(math.round(talent_data[i].num)))
            local text = Language:getTextByKey("pet_bag_text_0008")
            self:setText("talent_text" .. i, talent_data[i].attr_text .. text)
        end
    else
        self:setTextByLanKey("hp_num", "pet_bag_text_0031")
        self:setTextByLanKey("attack_num", "pet_bag_text_0031")
        self:setTextByLanKey("def_num", "pet_bag_text_0031")
        self:setTextByLanKey("anger_num", "pet_bag_text_0031")
        self:setTextByLanKey("combat_text", "pet_bag_text_0031")
        self:setTextByLanKey("variation_num", "pet_bag_text_0031")
        for i = 1, 4 do
            self:setTextByLanKey("talent_num" .. i, "pet_bag_text_0031")
            local text = Language:getTextByKey("pet_bag_text_0008")
            self:setText("talent_text" .. i, talent_data[i].attr_text .. text)
        end
    end

end

function M:updateBtnState(isEgg)
    local level_btn = self:setObjectVisible("level_up_btn", false) --升级
    local no_lv_tips = self:setObjectVisible("no_lv_tips", false) --满级满进化提示
    local can_evolve_tips = self:setObjectVisible("can_evolve_tips", false) --可进阶提示
    local resour_bg = self:setObjectVisible("resour_bg", false) --资源底
    local resour_obj = self:setObjectVisible("resour_obj", false) --资源条
    local evolve_btn = self:setObjectVisible("evolve_btn", false) --进化按钮
    local quick_egg_btn = self:setObjectVisible("quick_egg_btn", false) --孵化加速按钮
    local detail_btn = self:setObjectVisible("attr_detail_btn", true)
    local egg_timer_bg_obj = self:setObjectVisible("egg_timer_bg", false) --孵化时间bg
    local varition_obj = self:setObjectVisible("varition", false)  --变异显示
    if isEgg then
        quick_egg_btn:SetActive(true)
        egg_timer_bg_obj:SetActive(true)
        detail_btn:SetActive(false)
        self:updateTime()
        return
    end
    if self.m_model:checkMaxLv() then
        --满级满进化
        no_lv_tips:SetActive(true)
    elseif self.m_model:checkCanLv() then
        --可升级
        level_btn:SetActive(true)
        resour_bg:SetActive(true)
        resour_obj:SetActive(true)
        self:setLevelUpRes()
    else
        --可前往进化界面
        can_evolve_tips:SetActive(true)
        evolve_btn:SetActive(true)
        varition_obj:SetActive(true)
    end
end

function M:updateTime()
    if self.m_model:checkIsEgg(self.m_model.m_sel_pet_oid) then
        local curTime = UserDataManager:getServerTime()
        local endTime = self.m_model:getEggEndTime(self.m_model.m_sel_pet_oid)
        local diffTime = endTime - curTime
        if diffTime >= 0 then
            local time_str = GameUtil:formatTimeBySecond(diffTime, 999)
            self:setTextByLanKey("egg_timer_text", "pet_bag_text_0032", time_str)
        end
    end
end


-- 英雄升级需要消耗
function M:setLevelUpRes()
    self.m_model:updateResourceData()
    local need_coin, need_exp = self.m_model:getNextLevelNeedMoney()
    local cur_exp = self.m_model.data_exp.user_num
    local cur_coin = self.m_model.data_coin.user_num
    local my_text = self:setText("money_text", GameUtil:formatValueToString(need_coin))
    local jy_text = self:setText("jingyan_text", GameUtil:formatValueToString(need_exp))
    local isEnough = true
    if need_coin > cur_coin then
        isEnough = false
        my_text.color = self.U_Color
    else
        my_text.color = self.E_Color
    end
    if need_exp > cur_exp then
        isEnough = false
        jy_text.color = self.U_Color
    else
        jy_text.color = self.E_Color
    end
    --self.m_lv_btn_img.material = isEnough and self.m_normal_material or self.m_gray_material
    self:setImg(self.m_model.data_coin.icon_name, self.m_model.data_coin.atlas_name, "money_img")    --金币
    self:setImg(self.m_model.data_exp.icon_name, self.m_model.data_exp.atlas_name, "jingyan_img")    --经验
end

function M:setShowQuickLevelUp(lv)
    self:setObjectVisible("quick_level_up_btn", lv > 0)
    self:setTextByLanKey("quick_level_up_text", "pet_bag_text_0013", lv)
end

function M:onButtonClick(obj, name)
    if name == "money_img" or name == "jingyan_img" then
        self:clickTips(name)
    else
        M.super.onButtonClick(self, obj, name)
    end
end

function M:clickTips(str)
    local m_data = { top = true }
    if str == "money_img" then
        local cur_obj = self:findGameObject("money_img")
        m_data.click_transform = cur_obj.transform
        m_data.data = tab_money

    elseif str == "jingyan_img" then
        local cur_obj = self:findGameObject("jingyan_img")
        m_data.click_transform = cur_obj.transform
        m_data.data = tab_exp
    end
    GameUtil:lookInfoTips(self.m_control, m_data)
end


function M:initLvEffect()
    self.m_sequence2 = {}
    self.m_attr_time = {}
    self.attr_sq = {}
    self.lv_effect = {} --升级特效预制
    self.add_combat = nil --战力改变飞入预制
    self.add_attr = {} --属性改变飞入预制
    local combat_text = self:findGameObject("combat_text")
    local hp_num = self:findGameObject("hp_num")
    local attack_num = self:findGameObject("attack_num")
    local def_num = self:findGameObject("def_num")
    local anger_num = self:findGameObject("anger_num")
    local add_hp = self:creatEffect("add_combat", hp_num)
    local add_attack = self:creatEffect("add_combat", attack_num)
    local add_def = self:creatEffect("add_combat", def_num)
    local add_anger = self:creatEffect("add_combat", anger_num)
    self.add_attr["hp_num"] = add_hp
    self.add_attr["attack_num"] = add_attack
    self.add_attr["def_num"] = add_def
    self.add_attr["anger_num"] = add_anger
    self.add_combat = self:creatEffect("add_combat2", combat_text)
    local com_parent = self:findGameObject("com_eff")
    local property = self:findGameObject("property")
    local level_up_btn = self:findGameObject("level_up_btn")
    local effect = ResourceUtil:GetUIEffectItem("HeroBag/UI_HeroBag_ZhanLi_001", com_parent)
    local effect2 = ResourceUtil:GetUIEffectItem("HeroBag/UI_HeroBag_ZhanLi_002", property)
    local effect3 = ResourceUtil:GetUIEffectItem("Common/UI_Common_AnNiu_YellowBig_02", level_up_btn)
    effect3.transform.localScale = Vector3.New(0.8, 1, 1)
    self:setParticleRenderOrder(effect)
    self:setParticleRenderOrder(effect2)
    self:setParticleRenderOrder(effect3)
    table.insert(self.lv_effect, effect)
    table.insert(self.lv_effect, effect2)
    table.insert(self.lv_effect, effect3)
    self:hideEffect()
end

function M:hideEffect()
    self.add_combat:SetActive(false)
    for k, v in pairs(self.lv_effect) do
        if not IsNull(v) then
            v:SetActive(false)
        end
    end
    for k, v in pairs(self.add_attr) do
        if not IsNull(v) then
            v:SetActive(false)
        end
    end
end

function M:playLvUpEffect()
    local cur_lv = self.m_model:getCurShowLevel()
    local last_lv = self.m_model.last_lv
    local cur_attrs = self.m_model:getAttrs()
    local last_attrs = self.m_model.last_attrs
    local cur_comb = self.m_model:getCurCombat()
    local last_comb = self.m_model.last_combat
    self:addCombatNumber(last_comb, cur_comb)
    self:lvZoom(last_lv, cur_lv)
    self:updateAttrs(cur_attrs, last_attrs)
    local isEgg = self.m_model:checkIsEgg(self.m_model.m_sel_pet_oid)
    self:updateBtnState(isEgg)
end

function M:updateAttrs(cur_attrs, last_attrs)
    if last_attrs ~= nil and next(last_attrs) ~= nil then
        for k, v in pairs(self.attr_sq) do
            if v then
                v:Kill()
                v = nil
            end
        end
        for k, v in pairs(last_attrs) do
            local last_h, cur_h = math.round(v) , math.round(cur_attrs[k])
            if cur_h > last_h then
                if k == "hp" then
                    self:setTextByLanKey("hp_num", GameUtil:formatValueToString(last_h))
                    self:addAttrNumber("hp_num", last_h, cur_h)
                elseif k == "atk" then
                    self:setTextByLanKey("attack_num", GameUtil:formatValueToString(last_h))
                    self:addAttrNumber("attack_num", last_h, cur_h)
                elseif k == "def" then
                    self:setTextByLanKey("def_num", GameUtil:formatValueToString(last_h))
                    self:addAttrNumber("def_num", last_h, cur_h)
                elseif k == "power" then
                    self:setTextByLanKey("anger_num", GameUtil:formatValueToString(last_h))
                    self:addAttrNumber("anger_num", last_h, cur_h)
                end
            else
                if k == "hp" then
                    self:setTextByLanKey("hp_num", GameUtil:formatValueToString(cur_h))
                elseif k == "atk" then
                    self:setTextByLanKey("attack_num", GameUtil:formatValueToString(cur_h))
                elseif k == "def" then
                    self:setTextByLanKey("def_num", GameUtil:formatValueToString(cur_h))
                elseif k == "power" then
                    self:setTextByLanKey("anger_num", GameUtil:formatValueToString(cur_h))
                end
            end
        end

    end
end

function M:addAttrNumber(text_name, num1, num2)
    if self.m_sequence2 and self.m_sequence2[text_name] then
        self.m_sequence2[text_name]:Kill()
        self.m_sequence2[text_name] = nil
    end
    if self.m_attr_time[text_name] then
        self.m_control:removeTimer(self.m_attr_time[text_name])
        self.m_attr_time[text_name] = nil
    end
    local show_text = self:findText(text_name)
    local text_rt = show_text.gameObject:GetComponent("RectTransform")
    local rect = text_rt.rect
    local num = rect.width
    local add_comb = self.add_attr[text_name]
    local combat_text = UIUtil.findText(add_comb.transform)
    combat_text.text = "+" .. (num2 - num1)
    local pos_x = (num + 10)
    add_comb.transform.localPosition = Vector3.New(pos_x, 0, 0)
    UIUtil.setTextColor(add_comb.transform, Color(74 / 255, 237 / 255, 109 / 255, 1))
    add_comb:SetActive(true)
    if self.m_control then
        local function awaitPlay()
            if not IsNull(add_comb) then
                local sequence = Tweening.DOTween.Sequence()
                sequence:Append(add_comb.transform:DOLocalMoveX(-20, 0.5))
                sequence:Insert(0, DOTweenModuleUI.DOFade(combat_text, 0, 0.5))
                sequence:OnComplete(function()
                    add_comb:SetActive(false)
                    if not IsNull(add_comb) then
                        self.attr_sq[text_name] = self:attrNumberChange(text_name, num1, num2)
                    end
                    audio:SendEvtUI("Play_UI_Power_Increase")
                end
                )
                sequence:SetAutoKill(false)
                self.m_sequence2[text_name] = sequence
            end
            if self.m_attr_time[text_name] then
                self.m_control:removeTimer(self.m_attr_time[text_name])
                self.m_attr_time[text_name] = nil
            end
        end
        self.m_attr_time[text_name] = self.m_control:setTimer(0.5, awaitPlay)
    end
end

function M:attrNumberChange(text_name, num1, num2)
    local sequence = Tweening.DOTween.Sequence()
    sequence:SetAutoKill(false)
    sequence:Append(Tweening.DOTween.To(function(index)
        local temp = math.floor(index)
        self:setText(text_name, GameUtil:formatValueToString(temp))
    end, num1, num2, 0.5))
    return sequence
end

function M:NumberChange(num1, num2)
    local sequence = Tweening.DOTween.Sequence()
    sequence:SetAutoKill(false)
    sequence:Append(Tweening.DOTween.To(function(index)
        local temp = math.floor(index)
        self:setText("combat_text", GameUtil:formatValueToString(temp))
    end, num1, num2, 0.5))
    return sequence
end

function M:addCombatNumber(num1, num2)
    if self.add_combat_sequence then
        self.add_combat_sequence:Kill()
        self.add_combat_sequence = nil
    end
    if self.combat_time then
        self.m_control:removeTimer(self.combat_time)
        self.combat_time = nil
    end
    local show_text = self:setText("combat_text", GameUtil:formatValueToString(num1))
    local text_rt = show_text.gameObject:GetComponent("RectTransform")
    local rect = text_rt.rect
    local num = rect.height
    local combat_text = UIUtil.findText(self.add_combat.transform)
    combat_text.text = "+" .. (num2 - num1)
    self.add_combat.transform.localPosition = Vector3.New(-125, (num - 92), 0)
    UIUtil.setTextColor(self.add_combat.transform, Color(74 / 255, 237 / 255, 109 / 255, 1))
    self.add_combat:SetActive(true)
    local function awaitPlay()
        if not IsNull(self.add_combat) then
            local sequence = Tweening.DOTween.Sequence()
            sequence:Append(self.add_combat.transform:DOLocalMoveY(0, 0.5))
            sequence:Insert(0, DOTweenModuleUI.DOFade(combat_text, 0, 0.5))
            sequence:OnComplete(function()
                if not IsNull(self.add_combat) then
                    self.m_sequence = self:NumberChange(num1, num2)
                    --self:setText("combat_text", GameUtil:formatValueToString(num2))
                    self.add_combat:SetActive(false)
                end
                audio:SendEvtUI("Play_UI_Power_Increase")
            end
            )
            sequence:SetAutoKill(false)
            self.add_combat_sequence = sequence
        end
        if self.combat_time then
            self.m_control:removeTimer(self.combat_time)
            self.combat_time = nil
        end
    end
    self:combatZoom()
    self.combat_time = self.m_control:setTimer(0.5, awaitPlay)
end

function M:combatZoom()
    if self.lv_lizi_time then
        self.m_control:removeTimer(self.lv_lizi_time)
        for k, v in pairs(self.lv_effect) do
            if not IsNull(v) then
                v:SetActive(false)
            end
        end
        self.lv_lizi_time = nil
    end
    for k, v in pairs(self.lv_effect) do
        if not IsNull(v) then
            v:SetActive(true)
        end
    end
    if self.m_control then
        self.lv_lizi_time = self.m_control:setTimer(
                1,
                function()
                    if self.lv_lizi_time then
                        self.m_control:removeTimer(self.lv_lizi_time)
                        for k, v in pairs(self.lv_effect) do
                            if not IsNull(v) then
                                v:SetActive(false)
                            end
                        end
                        self.lv_lizi_time = nil
                    end
                end
        )
    end
end

function M:lvZoom(last_lv, cur_lv)
    if last_lv and cur_lv and cur_lv > last_lv then
        local lv_text = self:findGameObject("pet_lv_text")
        GameUtil:ZoomObj(lv_text)
    end
    self:setText("pet_lv_text", GameUtil:formatValueToString(cur_lv))
end

function M:creatEffect(tx_name, prent)
    local item = ResourceUtil:GetUIEffectItem("HeroInfo/" .. tx_name, prent)
    return item
end

function M:clearAnim()
    if self.lv_lizi_time then
        self.m_control:removeTimer(self.lv_lizi_time)
        self.lv_lizi_time = nil
    end
    if self.combat_time then
        self.m_control:removeTimer(self.combat_time)
        self.combat_time = nil
    end
    if self.add_combat_sequence then
        self.add_combat_sequence:Kill()
        self.add_combat_sequence = nil
    end
    if self.m_sequence2 then
        for i, v in pairs(self.m_sequence2) do
            v:Kill()
        end
    end
    self.m_sequence2 = {}
    if self.m_sequence then
        self.m_sequence:Kill()
        self.m_sequence = nil
    end
    for k, v in pairs(self.attr_sq) do
        if v then
            v:Kill()
        end
    end
    self.attr_sq = {}
    for i, v in pairs(self.m_attr_time) do
        self.m_control:removeTimer(v)
    end
    self.m_attr_time = {}
end

function M:destroy()
    self:clearAnim()
    M.super.destroy(self)
end

return M