local M = class("EquipmentPolishedsPopView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "HeroInfo/EquipmentPolishedsPop"

function M:onEnter()
    self.m_loop_obj = {} --缓存列表
    self.m_combat = {} --战力缓存
    self:refreshUI()
    self:setObjectVisible("order_tips_text", false)
    self:setTextByLanKey("tips_text", "dj_zh_text")
    self:setTextByLanKey("polished_text", "jx_xl_text")
    self:setTextByLanKey("ok_text", "th_sx_text")
end

function M:refreshUI()
    for i = 1,6 do
        local polish_node = self:findGameObject("polish_node_"..i)
        local data = self.m_model:getPolishByIndex(i)
        self:updatePolishNode(polish_node, data, i)
    end
    local consItem = self.m_model:polishCons() 
        self:setImg(consItem.icon_name, consItem.atlas_name, "money_iocn")
        if consItem.user_num < consItem.data_num then
            self:setTextByLanKey("cons_num_text", "equip_str_033" ,tostring(consItem.user_num), tostring(consItem.data_num))
        else
            self:setTextByLanKey("cons_num_text", tostring(consItem.user_num).."/"..tostring(consItem.data_num))
        end
        local polished_btn = self:findImage("polished_btn")
        local polished_text = self:findText("polished_text")
   
        if consItem.data_num > consItem.user_num then
            polished_btn.color = Color.New(0.5,0.5,0.5)
            polished_text.color = Color( 143/255, 147/255, 156/255)
        else
            polished_btn.color = GlobalConfig.COMMON_COLLOR.COMMON_1
            polished_text.color = GlobalConfig.COMMON_COLLOR.COMMON_1
        end
end

function M:updatePolishNode(obj, data, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local polish_btn = luaBehaviour:FindButton("polish_btn")
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light_img", self.m_model.m_select_index == index)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "Rare_img", self.m_model.m_select_index == index)
        local list_scroll = luaBehaviour:FindGameObject("order_list_scroll")
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_img", false)
        if index == 1 then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "head_text", "equip_str_045")  
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_img", true)
            LuaBehaviourUtil.setImg(luaBehaviour, "head_img", "a_zb_xl_bql_bg", "main_ui2")  
        end
        local check_rare = self.m_model:checkRareAttrs(data)
        if check_rare == true then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_img", true)
            if index ~= 1 then
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "head_text", "equip_str_046")  
                LuaBehaviourUtil.setImg(luaBehaviour, "head_img", "a_zb_xl_bqh_bg", "main_ui2") 
            end
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_img", true)
        end
        local score_num = self.m_model:getOrderCombat(data)
        self.m_combat[index] = score_num
        local affix_score = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "order_affix_combat", "equip_str_044", score_num)  
        if check_rare == true then --稀有
            affix_score.color = Color.New(96/255,50/255,28/255)
        else
            affix_score.color = Color.New(44/255,58/255,80/255)
        end
        self:updateoldLoopScroll(list_scroll, data, index)
        local function clickCallback()
            self:updateMsg("select_id", index)
        end
        UIUtil.setButtonClick(polish_btn, clickCallback)
    end
end

--[[	
	属性列表
]]
function M:updateoldLoopScroll(obj, data, index)
    local new_data = {}
    local equip_affix_tab = ConfigManager:getCfgByName("equip_affix")
    for i,v in ipairs(data) do
        local affix_id = v[1]
        local affix_cfg = equip_affix_tab[affix_id]
        if affix_cfg and affix_cfg.unique == 0 then
            table.insert(new_data, v)
        end
    end
    local m_loop_scroll_view = self.m_loop_obj[index]
    if m_loop_scroll_view == nil then
        local loopscroll = obj
        local params = {
            show_data = new_data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local check_rare = self.m_model:checkRareAttrs(data)
                self:updateCell(cell_object, cell_data, check_rare, index)
            end
        }
        m_loop_scroll_view = LoopScrollViewUtil.new(params)
        self.m_loop_obj[index] = m_loop_scroll_view
    else
        m_loop_scroll_view:reloadData(new_data)
    end
end


function M:updateCell(obj, cell_data, check_rare, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local attr_id, attr_scope = self.m_model:switchAttrs(cell_data)
        local affix_id = cell_data[1]
        local attr_data = cell_data[2][1]
        local atk_num = attr_data[3]
        local affix_data = self.m_model:getAffixData(affix_id)
        local atk_key = GameUtil:getAttrsKey(attr_id)
        local atk_name = GameUtil:getAttrsName(atk_key)
        local scope_attr = ""
        if GameUtil:attrTransition(atk_key) == true then
            if GameUtil:canPerAttrTransition(atk_key) == true then
                scope_attr = GameUtil:formatNum(attr_scope[1]*100).."%~"..GameUtil:formatNum(attr_scope[2]*100).."%"
            else
                scope_attr = attr_scope[1].."%~"..attr_scope[2].."%"
            end
        else
            if GameUtil:canPerAttrTransition(atk_key) == true then
                scope_attr = GameUtil:formatNum(attr_scope[1]*100).."~".. GameUtil:formatNum(attr_scope[2]*100)
            else
                scope_attr = attr_scope[1].."~"..attr_scope[2]
            end
        end
        local cell_title = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title_text", atk_name.." [".. scope_attr.."]" )
        if GameUtil:attrTransition(atk_key) == true then
            if GameUtil:canPerAttrTransition(atk_key) == true then
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"attr_num", (atk_num*100).."%")
            else
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"attr_num", atk_num.."%")
            end
        else
            if GameUtil:canPerAttrTransition(atk_key) == true then
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"attr_num", atk_num*100)
            else
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"attr_num", atk_num)
            end
        end
        local lock_bl = self.m_model:checkLockStatus(index)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_btn", lock_bl == true)  
        local atr_quality = GameUtil:checkAttrsQuality(affix_id)
        cell_title.color = atr_quality
    end
end

return M