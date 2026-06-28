--- 突破
local M = class("EqpBreakNode",LikeOO.OOUIbase)

M.m_uiName = "HeroInfo/EqpBreakNode"

local pro_tab = {}

function M:onEnter()
    self.m_const_node = self:findGameObject("cons_parent")
    self.m_icon_node = self:findGameObject("item_parent") 
    self:setTextByLanKey("common_no_have_text", "equip_str_010")
    self:setTextByLanKey("levelup_text", "equip_str_015")
    self:setObjectVisible("break_node", false)
    self:refreshUI()
end

function M:refreshUI()
    local e_data,e_cfg = self.m_model:getEqpData()
    if e_cfg.evolution_id and e_cfg.evolution_id > 0 then
        local cons = self.m_model:getConsume()
        local data = RewardUtil:getProcessRewardData(cons[1])
        if data.user_num < data.data_num then
            self:setTextByLanKey("cons_num_text", "equip_str_033" ,tostring(data.user_num), tostring(data.data_num))
        else
            self:setTextByLanKey("cons_num_text", tostring(data.user_num).."/"..tostring(data.data_num))
        end
        if cons then
            local rewaedData = RewardUtil:getProcessRewardData(cons[1])
            self:setImg(rewaedData.icon_name, rewaedData.atlas_name, "money_iocn")
        end
        local combat_1, combat_2 = self.m_model:getCombat()
        self:setTextByLanKey("combat_1_text", GameUtil:formatNum(combat_1))
        self:setTextByLanKey("combat_2_text", GameUtil:formatNum(combat_2))
        self:updateLoopScroll()
        self:setObjectVisible("can_break", true)
        self:setObjectVisible("not_break", false)
    else
        self:setObjectVisible("can_break", false)
        self:setObjectVisible("not_break", true)
    end
    self:setCurEqp()  
    self:creatShowEquip()
    if self.m_model:checkCanBreak() == false then
        local break_btn = self:findImage("break_btn")
        local levelup_text = self:findText("levelup_text")
        break_btn.color = Color.New(0.5,0.5,0.5)
        levelup_text.color = Color( 143/255, 147/255, 156/255)
    else
        local break_btn = self:findImage("break_btn")
        local levelup_text = self:findText("levelup_text")
        break_btn.color = GlobalConfig.COMMON_COLLOR.COMMON_1
        levelup_text.color = GlobalConfig.COMMON_COLLOR.COMMON_1
    end
    local open_go_to = BtnOpenUtil:isBtnOpen(212)
    local open_go_to2 = BtnOpenUtil:isBtnOpen(220)
    if e_cfg and e_cfg.quality >= 11 and open_go_to == true and open_go_to2 == true then
        self:setTextByLanKey("common_no_have_text", "equip_str_019")
        self:setObjectVisible("go_to_btn", true)
    else
        self:setObjectVisible("go_to_btn", false)    
    end
    local break_num = (11 - e_cfg.quality) or 0
    if break_num and break_num > 0 then
        self:setTextByLanKey("break_num", "equip_str_023", break_num)
        self:setObjectVisible("break_num", true)
    else
        self:setObjectVisible("break_num", false)    
    end
    if self.m_model:checkNewAttrs() > 0 then
        self:setTextByLanKey("attr_add_text" ,"equip_str_024", self.m_model:checkNewAttrs())
        self:setObjectVisible("attr_add_text", true)
    else
        self:setObjectVisible("attr_add_text", false)    
    end
    if e_cfg.evolution_head and e_cfg.evolution_head > 0 then
        self:setObjectVisible("check_break_btn", true)
    else
        self:setObjectVisible("check_break_btn", false)
    end
end

function M:creatShowEquip()
    local item_1 = self:findGameObject("item_1")
    local item_2 = self:findGameObject("item_2")
    local item_3 = self:findGameObject("item_3")
    local e_data,e_cfg = self.m_model:getEqpData()
    if e_cfg.evolution_id and e_cfg.evolution_id > 0 then
        local obj_1 = GameUtil:createItemElement({102, e_data.id, 0}, false, false)
        local obj_2 = GameUtil:createItemElement({102, e_cfg.evolution_id, 0}, false, false)
        local cur_eqp_data, cur_eqp_cfg = self.m_model:getEqpData()
        GameUtil:updateItemEquipInfo(obj_1, {id = cur_eqp_data.id, lv = e_data.lv, race = e_data.race})
        GameUtil:updateItemEquipInfo(obj_2, {id = e_cfg.evolution_id, lv = e_data.lv, race = e_data.race})
        UIUtil.destroyAllChild(item_1.transform)
        UIUtil.destroyAllChild(item_2.transform)
        obj_1.transform:SetParent(item_1.transform, false)
        obj_2.transform:SetParent(item_2.transform, false)
    else
        UIUtil.destroyAllChild(item_3.transform) 
        local obj_3 = GameUtil:createItemElement({102, e_data.id, 0}, false, false) 
        GameUtil:updateItemEquipInfo(obj_3, {id = e_data.id, lv = e_data.lv, race = e_data.race})
        obj_3.transform:SetParent(item_3.transform, false)
    end
end

--更新装备信息
function M:setCurEqp()
    local cur_eqp_data, cur_eqp_cfg = self.m_model:getEqpData()
	self.m_icon_node = self:findGameObject("icon_node")
    if cur_eqp_cfg then
        if not IsNull(self.curEqp) then
            ResourceUtil:ReturnItem(self.curEqp)
            self.curEqp = nil
        end
		if cur_eqp_data then
			self.curEqp = GameUtil:createItemElement({RewardUtil.REWARD_TYPE_KEYS.EQUIPS, cur_eqp_data.id, cur_eqp_data.race}, false, false)
			self.curEqp.transform:SetParent(self.m_icon_node.transform, false)
			GameUtil:updateItemEquipInfo(self.curEqp, cur_eqp_data, nil, self.m_model.m_heroid)
		else
			self.curEqp = GameUtil:createItemElement({ RewardUtil.REWARD_TYPE_KEYS.EQUIPS, self.m_model.m_equip_cfg_id, 0}, false, false)
			self.curEqp.transform:SetParent(self.m_icon_node.transform, false)
		end
	end
    self:setTextByLanKey(cur_eqp_cfg.name, "equip_text")
    self:setTextByLanKey("equip_text", cur_eqp_cfg.name)
    local color = GlobalConfig.QUALITY_COMMON_SETTING[cur_eqp_cfg.quality]
    self:setTextColor("equip_text",color.RGBA)
    local pro_parent = self:findGameObject("pro_parent")
    for k,v in pairs(pro_tab) do
        ResourceUtil:ReturnItem(v)
    end
    pro_tab = {}
    local new_eqp_data = table.copy(cur_eqp_data)
    local attrs = UserDataManager:appendAttrs(UserDataManager:getEquipAttrsByData(new_eqp_data, cur_eqp_cfg))
    local atrs_tab = {}
    for k,v in pairs(attrs) do
        table.insert(atrs_tab, {name = k, num = v})
    end
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

function M:getGrowth(eqp_id, type, level)
    local cur_num, rate = GameUtil:getEqpBaseTypeNum(eqp_id,type)
    local newNum = 0
    newNum = cur_num * (rate/100) * level
    if GameUtil:canPerAttrTransition(type) == true then
        return GameUtil:formatNum((newNum + cur_num )*100) 
    end
    return newNum + cur_num 
end

--[[	
	属性列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getAttr()
    local atrs_tab = {}
    for k,v in pairs(data) do
        local next_atr = self.m_model:getNextAttr(k)
        if next_atr and next_atr > v then
            table.insert(atrs_tab, {name = k, num = v})
        end
    end
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = atrs_tab,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local atk_id = GameUtil:getAttrsId(cell_data.name)
                local next_atr = self.m_model:getNextAttr(cell_data.name)
                local LuaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                if LuaBehaviour then
                    LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "title_text", GameUtil:getAttrsName(cell_data.name))
                    if GameUtil:attrTransition(cell_data.name) == true then
                        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "count_text", GameUtil:formatNum(cell_data.num).. "%" )
                        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "count2_text", "+"..GameUtil:formatNum(next_atr - cell_data.num).. "%" )
                    else
                        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "count_text", GameUtil:formatNum(cell_data.num))
                        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "count2_text", "+"..GameUtil:formatNum(next_atr - cell_data.num))
                    end
                end
            end,
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(atrs_tab)
    end
end


function M:onButtonClick(obj, name)
    if name == "check_break_btn" then
        self:setObjectVisible("break_node", true)
        self:initBreakList()
    elseif name == "breaks_close_btn"  then
        self:setObjectVisible("break_node", false)
    elseif name == "go_to_btn" then
        self:updateMsg("go_to_e_a")    
    else
        M.super.onButtonClick(self, obj, name)
    end
end

function M:initBreakList()
    local list = self.m_model:getBreakList()
    local e_data,e_cfg = self.m_model:getEqpData()
    for i = 1,4 do
        local obj = self:findGameObject("break_item_"..i)
        local data = nil
        self:updateItem(obj, list[i], e_data.race)
    end
end

function M:updateItem(obj, data, race)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        if data then
            local eqp_data = {RewardUtil.REWARD_TYPE_KEYS.EQUIPS, data, race}
            local item_parent = luaBehaviour:FindGameObject("itemNode")
            UIUtil.destroyAllChild(item_parent.transform)
            local item_data = RewardUtil:getProcessRewardData(eqp_data)
            local item_obj = GameUtil:createItemElementByData(item_data, false, false)
            local name_text = nil
            if item_data.quality >= 12 then
                name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "item_name_text", "equip_str_025")
                if not IsNull(name_text) then
                    name_text.color = Color( 207/255, 105/255, 49/255)
                end
            else
                name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "item_name_text", item_data.name)
                if not IsNull(name_text) then
                    name_text.color = Color( 19/255, 27/255, 39/255)
                end
            end
            item_obj.transform:SetParent(item_parent.transform, false)
        end
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M