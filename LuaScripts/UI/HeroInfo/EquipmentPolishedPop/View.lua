local M = class("EquipmentPolishedPopView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "HeroInfo/EquipmentPolishedPop"

function M:onEnter()
    self:refreshUI()
    self:setTextByLanKey("order_text", "equip_str_029")
    self:setTextByLanKey("new_text", "equip_str_028")
    self:setTextByLanKey("save_tips_text", "equip_str_032")
    self:setTextByLanKey("order_tips_text", "yuanshuxing_text")
    self:setObjectVisible("order_tips_text", false)
end

function M:refreshUI()
    self:updateoldLoopScroll()
    self:updatenewLoopScroll()
    if self.m_model.m_affix_ts and next(self.m_model.m_affix_ts) then
        self:setObjectVisible("order_core_attr_text", true)
        local str = Language:getTextByKey(self.m_model.m_affix_ts[1].cfg.affix_des)
        self:setTextByLanKey("order_core_attr_text", str) 
        self:setObjectVisible("new_core_attr_text", true)
        local str = Language:getTextByKey(self.m_model.m_affix_ts[2].cfg.affix_des)
        self:setTextByLanKey("new_core_attr_text", str)
    else
        self:setObjectVisible("order_core_attr_text", false)
        self:setObjectVisible("new_core_attr_text", false)
    end
    if self.m_model.order_affix_combat > 0 then
        self:setObjectVisible("order_affix_combat", true)
        self:setTextByLanKey("order_affix_combat", "equip_str_026", self.m_model.order_affix_combat)
    else
        self:setObjectVisible("order_affix_combat", false) 
    end
    if self.m_model.new_affix_combat > 0 then
        self:setObjectVisible("new_affix_combat", true)
        self:setTextByLanKey("new_affix_combat", "equip_str_026", self.m_model.new_affix_combat)
    else
        self:setObjectVisible("new_affix_combat", false) 
    end
end

--[[	
	原属性列表
]]
function M:updateoldLoopScroll()
    local data = self.m_model.m_attrs
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("order_list_scroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateCell(cell_object, cell_data, true)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
				if click_name == "lock_btn" then
                    self:updateMsg("lock_attr", cell_data)
                end
			end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data)
    end
end

--[[	
	新属性列表
]]
function M:updatenewLoopScroll()
    local data = self.m_model.m_attrs
    if self.m_loop_scroll_view2 == nil then
        local loopscroll = self:findGameObject("new_list_scroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateCell(cell_object, cell_data, false)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
				if click_name == "lock_btn" then
                    self:updateMsg("lock_attr", cell_data)
                end
			end
        }
        self.m_loop_scroll_view2 = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view2:reloadData(data)
    end
end

function M:updateCell(obj, cell_data, is_ord)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local affix_data = cell_data.data
        local affix_cfg = nil
        if ( affix_data and affix_data.lock and affix_data.lock == 1 ) or self.m_model.m_is_all_lock then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_btn", true)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_btn", false)    
        end
        local attr_value = nil
        local attr_id = 0
        if is_ord and is_ord == true then
            if affix_data.lock == 1  or self.m_model.m_is_all_lock then
                attr_value = affix_data.value[1]
                attr_id = affix_data.id
                affix_cfg = cell_data.cfg
            else
                attr_value = affix_data.pvalue[1]    
                attr_id = affix_data.pid
                affix_cfg = cell_data.p_cfg
            end
        else
            attr_value = affix_data.value[1]
            attr_id = affix_data.id
            affix_cfg = cell_data.cfg
        end
        local atk_key = GameUtil:getAttrsKey(attr_value[2])
        local atk_num = attr_value[3]
        local atk_name = GameUtil:getAttrsName(atk_key)
        local scope_attr = ""
        if GameUtil:attrTransition(atk_key) == true then
            if GameUtil:canPerAttrTransition(atk_key) == true then
                scope_attr = GameUtil:formatNum(affix_cfg[1]*100).."%~"..GameUtil:formatNum(affix_cfg[2]*100).."%"
            else
                scope_attr = affix_cfg[1].."%~"..affix_cfg[2].."%"
            end
        else
            if GameUtil:canPerAttrTransition(atk_key) == true then
                scope_attr = GameUtil:formatNum(affix_cfg[1]*100).."~".. GameUtil:formatNum(affix_cfg[2]*100)
            else
                scope_attr = affix_cfg[1].."~"..affix_cfg[2]
            end
        end
        local cell_title = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title_text", atk_name.." [".. scope_attr.."]" )
        local atr_quality = GameUtil:checkAttrsQuality(attr_id)
        cell_title.color = atr_quality
        if GameUtil:canPerAttrTransition(atk_key) == true then
            atk_num = GameUtil:formatNum(atk_num*100) 
        end
        if GameUtil:attrTransition(atk_key) == true then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"attr_num", atk_num.."%")
        else
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"attr_num", atk_num)
        end
    end
end

return M