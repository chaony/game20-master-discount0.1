--- 重铸
local M = class("EqpRecoinNode",LikeOO.OOUIbase)

M.m_uiName = "HeroInfo/EqpRecoinNode"
local pro_tab = {}
function M:onEnter()
    self.m_icon_node = self:findGameObject("icon_node")
    self.m_equip_obj = self:findGameObject("equip_obj")
    self:setTextByLanKey("recoin_text", "new_str_0514")
    self:setTextByLanKey("ok_text", "new_str_0006")
    self:setTextByLanKey("cancle_text", "new_str_0007")
    self:setTextByLanKey("desc_text", "equip_str_011")
    self:setTextByLanKey("desc_text2", "equip_str_012")
    self.light_tab = {}
    self:refreshUI()    
    self:setRaceUI()
    self:setRecoinBtn(true)
    self:setOkBtn(false)
end

function M:refreshUI()
    self:setCurEqp()
    self:updataCons()
    self:setLightImg()
    local consItem = self.m_model:getCons()
    if self.m_model.m_resultRace == 0 or consItem.user_num < consItem.data_num then
        local recoin_btn = self:findImage("recoin_btn")
        local levelup_text = self:findText("recoin_text")
        recoin_btn.color = Color.New(0.5,0.5,0.5)
        levelup_text.color = Color( 143/255, 147/255, 156/255)
    else
        local recoin_btn = self:findImage("recoin_btn")
        local recoin_text = self:findText("recoin_text")
        recoin_btn.color = GlobalConfig.COMMON_COLLOR.COMMON_1
        recoin_text.color = GlobalConfig.COMMON_COLLOR.COMMON_1
    end
end

--更新当前被强化的装备信息
function M:setCurEqp()
    local cur_eqp_data, cur_eqp_cfg = self.m_model:getEqpData()
    if cur_eqp_cfg then
        if not IsNull(self.curEqp) then
            ResourceUtil:ReturnItem(self.curEqp)
            self.curEqp = nil
        end
        if not IsNull(self.cenEqp) then
            ResourceUtil:ReturnItem(self.cenEqp)
            self.cenEqp = nil
        end
		if cur_eqp_data then
			self.curEqp = GameUtil:createItemElement({RewardUtil.REWARD_TYPE_KEYS.EQUIPS, cur_eqp_data.id, cur_eqp_data.race}, false, false)
            self.cenEqp = GameUtil:createItemElement({RewardUtil.REWARD_TYPE_KEYS.EQUIPS, cur_eqp_data.id, cur_eqp_data.race}, false, false)
			self.curEqp.transform:SetParent(self.m_icon_node.transform, false)
            self.cenEqp.transform:SetParent(self.m_equip_obj.transform, false)
			GameUtil:updateItemEquipInfo(self.curEqp, cur_eqp_data, nil, self.m_model.m_heroid)
            GameUtil:updateItemEquipInfo(self.cenEqp, cur_eqp_data)
		else
			self.curEqp = GameUtil:createItemElement({ RewardUtil.REWARD_TYPE_KEYS.EQUIPS, self.m_model.m_equip_cfg_id, 0}, false, false)
			self.curEqp.transform:SetParent(self.m_icon_node.transform, false)
            self.cenEqp = GameUtil:createItemElement({ RewardUtil.REWARD_TYPE_KEYS.EQUIPS, self.m_model.m_equip_cfg_id, 0}, false, false)
			self.cenEqp.transform:SetParent(self.m_equip_obj.transform, false)
		end
	end
    self:setTextByLanKey(cur_eqp_cfg.name, "equip_text")
    self:setTextByLanKey("equip_text", cur_eqp_cfg.name)
    local color = GlobalConfig.QUALITY_COMMON_SETTING[cur_eqp_cfg.quality]
    self:setTextColor("equip_text",color.RGBA)
    local kk = GlobalConfig.QUALITY_COMMON_SETTING[cur_eqp_cfg.quality] or GlobalConfig.QUALITY_COMMON_SETTING[1]
    local pro_parent = self:findGameObject("pro_parent")
    local attrs = UserDataManager:appendAttrs(UserDataManager:getEquipAttrsByData(cur_eqp_data, cur_eqp_cfg))
    local atrs_tab = {}
    for k,v in pairs(attrs) do
        table.insert(atrs_tab, {name = k, num = v})
    end
    for k,v in pairs(pro_tab) do
        ResourceUtil:ReturnItem(v)
    end
    pro_tab = {}
    for i = 1, #atrs_tab do
        local atr_data = atrs_tab[i]
        local pp = GameUtil:createEqpLevelUp_Cell(atr_data.name, atr_data.num)
        pp.transform:SetParent(pro_parent.transform,false)
        table.insert(pro_tab, pp)
    end
    for k,v in pairs(pro_tab) do
        local pro_luaBehaviour = UIUtil.findLuaBehaviour(v)
        if pro_luaBehaviour then
            LuaBehaviourUtil.setObjectVisible(pro_luaBehaviour, "bg", k%2 ~= 0)
        end
    end
end

function M:updataEqp()
    local cur_eqp_data, cur_eqp_cfg = self.m_model:getEqpData()
    GameUtil:updateItemEquipInfo(self.curEqp, cur_eqp_data, nil, self.m_model.m_heroid)
    GameUtil:updateItemEquipInfo(self.cenEqp, cur_eqp_data)
end

function M:setRaceUI()
    for i = 1,6 do
        local race_name = "race_"..i
        local race_data = GlobalConfig.TYPE_HERO_RACE[i]
        self:setImg(race_data.big_race_icon,  ResourceUtil:getLanAtlas(), race_name)
    end
end

function M:setLightImg()
    for i = 1,6 do
        local race_light = "light_"..i
        self:setObjectVisible(race_light, self.m_model.m_random_index == i)
        local race_light = "race_"..i
        local select_img = self:findImage(race_light)
        if self.m_model.m_resultRace > 0 then
            if self.m_model.m_resultRace == i then
                select_img.color = Color.New(0.5,0.5,0.5)
            else
                select_img.color = GlobalConfig.COMMON_COLLOR.COMMON_1
            end
        else
            select_img.color = Color.New(0.5,0.5,0.5)
        end
    end
end

function M:updataCons()
    local consItem = self.m_model:getCons()
    self:setImg(consItem.icon_name, consItem.atlas_name, "cons_img")
    if consItem.user_num < consItem.data_num then
        self:setTextByLanKey("cons_num", "equip_str_033" ,tostring(consItem.user_num) ,tostring(consItem.data_num))
    else
        self:setTextByLanKey("cons_num", tostring(consItem.user_num).."/"..tostring(consItem.data_num))
    end
end

function M:setRecoinBtn(bl)
    self:setObjectVisible("recoin_btn", bl)
    self:setObjectVisible("cons_bg", bl)
end

function M:setOkBtn(bl)
    self:setObjectVisible("ok_btn", bl)
    self:setObjectVisible("cancle_btn", bl)
    self:setObjectVisible("desc_text2", bl)
end

function M:getGrowth(eqp_id, type, level)
    local cur_num, rate = GameUtil:getEqpBaseTypeNum(eqp_id,type)
    local newNum = 0
    newNum = cur_num * (rate/100) * level
    if GameUtil:canPerAttrTransition(type) == true then
        return GameUtil:formatNum((newNum + cur_num )*100) 
    end
    return newNum + cur_num 
end

function M:destroy()
    M.super.destroy(self)
end

return M