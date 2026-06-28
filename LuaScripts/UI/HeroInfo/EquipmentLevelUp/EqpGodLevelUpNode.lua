--- 神兵进化
local M = class("EqpRecoinNode",LikeOO.OOUIbase)

M.m_uiName = "HeroInfo/EqpGodLevelUpNode"
local pro_tab = {}
function M:onEnter()
    self.m_gray_img = self:findImage("gray_img")
    self.m_icon_node = self:findGameObject("icon_node")
    self:setTextByLanKey("god_lv_up_btn_text", "equip_str_016")
    self:setObjectVisible("max_tips_text", false)
    self:refreshUI()    
end

function M:refreshUI()
    self:setObjectVisible("equip_cons", false)
    self.equip_legend_cfg, self.next_equip_legend_cfg = self.m_model:getEquipLegendCfg()
    self:updateAskLvUp()
    self:setCurEqp()
    self:updataCons()
    self:updateAttrsLoopScroll()
    self:updateEqpsLoopScroll()
    if self.next_equip_legend_cfg and next(self.next_equip_legend_cfg.equip_cost) == nil then
        self:setObjectVisible("equip_cons", true)
    end
    if self.next_equip_legend_cfg == nil then
        self:setObjectVisible("max_tips_text", true)
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
			GameUtil:updateItemEquipInfo(self.curEqp, cur_eqp_data, nil, self.m_model.m_heroid)
            GameUtil:updateItemEquipInfo(self.cenEqp, cur_eqp_data)
		else
			self.curEqp = GameUtil:createItemElement({ RewardUtil.REWARD_TYPE_KEYS.EQUIPS, self.m_model.m_equip_cfg_id, 0}, false, false)
			self.curEqp.transform:SetParent(self.m_icon_node.transform, false)
            self.cenEqp = GameUtil:createItemElement({ RewardUtil.REWARD_TYPE_KEYS.EQUIPS, self.m_model.m_equip_cfg_id, 0}, false, false)
		end
	end
    self:setTextByLanKey(cur_eqp_cfg.name, "equip_text")
    self:setTextByLanKey("equip_text", cur_eqp_cfg.name)
    local color = GlobalConfig.QUALITY_COMMON_SETTING[cur_eqp_cfg.quality]
    self:setTextColor("equip_text",color.RGBA)
end

function M:updataEqp()
    local cur_eqp_data, cur_eqp_cfg = self.m_model:getEqpData()
    GameUtil:updateItemEquipInfo(self.curEqp, cur_eqp_data, nil, self.m_model.m_heroid)
    GameUtil:updateItemEquipInfo(self.cenEqp, cur_eqp_data)
end

--强化要求
function M:updateAskLvUp()
    for i = 1,2 do
        local cell_obj = self:setObjectVisible("cond_cell_"..i, false)
        if i == 1 then
            if self.next_equip_legend_cfg and self.next_equip_legend_cfg.des1 then
                UIUtil.setTextByLanKey(cell_obj.transform, "cell_text", self.next_equip_legend_cfg.des1)
                self:setObjectVisible("cond_cell_"..i, true)
            end
        else
            if self.next_equip_legend_cfg and #self.next_equip_legend_cfg.des2 > 0 then  
                UIUtil.setTextByLanKey(cell_obj.transform, "cell_text", self.next_equip_legend_cfg.des2)
                self:setObjectVisible("cond_cell_"..i, true)
            end
        end
    end
end


--属性
function M:updateAttrsLoopScroll()
    local data = self.m_model:getEquipAttrsTab(self.equip_legend_cfg,self.next_equip_legend_cfg)
    if self.m_attr_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("attr_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateEqpLevelUpCell(index,cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
			
			end
        }
        self.m_attr_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_attr_loop_scroll_view:reloadData(data)
    end
end

function M:updateEqpLevelUpCell(index,obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_last", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_new", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num2", false)
    local cur_attr = data.c_num
    local next_attr = data.n_num
    local attr_id = data.atr_id
    if attr_id == 0 then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title", "new_str_0066")
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num", false)
        local cur_stars = luaBehaviour:FindGameObject("star_last")
        local next_stars = luaBehaviour:FindGameObject("star_new")
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_last", cur_attr > 0)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_new", next_attr > 0)
        for i = 1,5 do
            local star_img = UIUtil.setObjectVisible(cur_stars.transform, cur_attr >= i, "star_"..i)
            UIUtil.setImg(star_img.transform, "a_ui_currency_ws_xingji", "equip_icon")
        end
        for i = 1,5 do
            local star_img = UIUtil.setObjectVisible(next_stars.transform, next_attr >= i, "star_"..i)
            UIUtil.setImg(star_img.transform, "a_ui_currency_ws_xingji", "equip_icon")
        end
    else
        local atr_key = GameUtil:getAttrsKey(attr_id)
        local atr_name = GameUtil:getAttrsName(atr_key)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title", atr_name)
        local flag = GameUtil:countAttrType(attr_id)
        if flag then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num", (cur_attr * 100).."%")
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num2", (next_attr * 100).."%")
        else
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num", cur_attr)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num2",next_attr)
        end
    
        if next_attr > 0 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num2", true)
        end
    end
    if index%2 == 0 then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg", false)
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg", true)    
    end
end

--消耗装备
function M:updateEqpsLoopScroll()
    local data = {} 
    self:setObjectVisible("equip_no_cons_text", false)    
    if self.next_equip_legend_cfg then
        data = self.m_model:getEquipCostList(self.next_equip_legend_cfg.equip_cost)
        if next(self.next_equip_legend_cfg.equip_cost) ~= nil and next(data) == nil then
            self:setObjectVisible("equip_no_cons_text", true)    
        end
    end
    if self.m_eqp_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            one_line_count = 5, -- 行或列的数量
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateConsEquip(cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                self:updateMsg("click_equip_cons", cell_data)
			end
        }
        self.m_eqp_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_eqp_loop_scroll_view:reloadData(data)
    end
end

function M:updateConsEquip(cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local equip_data, equip_cfg = UserDataManager.equip_data:getEquipDataById(cell_data)
    local equ_data = {RewardUtil.REWARD_TYPE_KEYS.EQUIPS, equip_data.id,equip_data.race, cell_data}
    GameUtil:updateItemElement(cell_object,equ_data,false,false)
    local bl = self.m_model:checkIsGetByGodCons(cell_data)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", bl == true)
end


function M:updataCons()
    self:setObjectVisible("cons_need_1", false)
    self:setObjectVisible("cons_need_2", false)
    if self.next_equip_legend_cfg then
        local cons_one = self.next_equip_legend_cfg.cost[1]
        local cons_two = self.next_equip_legend_cfg.cost[2]
        if cons_one then
            local consItem = RewardUtil:getProcessRewardData(cons_one)
            local cons_obj = self:setObjectVisible("cons_need_1", true)
            UIUtil.setImg(cons_obj.transform, consItem.icon_name, consItem.atlas_name, "cons_img")
            if consItem.user_num < consItem.data_num then
                UIUtil.setText(cons_obj.transform, Language:getTextByKey("equip_str_033" ,tostring(consItem.user_num) ,tostring(consItem.data_num)), "cons_num")
            else
                UIUtil.setText(cons_obj.transform, consItem.user_num.."/"..consItem.data_num, "cons_num")
            end
        end
        if cons_two then
            local consItem = RewardUtil:getProcessRewardData(cons_two)
            local cons_obj = self:setObjectVisible("cons_need_2", true)
            UIUtil.setImg(cons_obj.transform, consItem.icon_name, consItem.atlas_name, "cons_img")
            if consItem.user_num < consItem.data_num then
                UIUtil.setText(cons_obj.transform, Language:getTextByKey("equip_str_033" ,tostring(consItem.user_num) ,tostring(consItem.data_num)), "cons_num")
            else
                UIUtil.setText(cons_obj.transform, consItem.user_num.."/"..consItem.data_num, "cons_num")
            end
        end
    end
    local god_lv_up_btn = self:findImage("god_lv_up_btn")
    local god_lv_up_btn_text = self:findText("god_lv_up_btn_text")
    if self.m_model:checkArtifactLock() == true and self.m_model:checkConsEquip() == true  and self.m_model:checkConsItem() == true then
        god_lv_up_btn.color = GlobalConfig.COMMON_COLLOR.COMMON_1
        god_lv_up_btn_text.color = GlobalConfig.COMMON_COLLOR.COMMON_1
    else
        god_lv_up_btn.color = Color.New(0.5,0.5,0.5)
        god_lv_up_btn_text.color = Color( 143/255, 147/255, 156/255)
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

function M:destroy()
    M.super.destroy(self)
end

return M