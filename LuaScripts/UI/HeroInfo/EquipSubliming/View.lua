local M = class("EquipSublimingView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_iphoneXAdapter = true
M.m_uiName = "HeroInfo/EquipSubliming"

function M:onEnter()
    self.m_icon_node = self:findGameObject("item_parent")
    self.m_const_node = self:findGameObject("cons_parent")
    self:setTextByLanKey("common_title_text", "装备升阶")
    self:setTextByLanKey("combat_text", "战力")
    local data, cfg = self.m_model:getEqpData()
    if cfg then
        if data then
            local go = GameUtil:createItemElement({RewardUtil.REWARD_TYPE_KEYS.EQUIPS, data.id, data.race}, false, false)
            go.transform:SetParent(self.m_icon_node.transform, false)
            GameUtil:updateItemEquipInfo(go, data)
            local luaBehaviour = UIUtil.findLuaBehaviour(go)
        else
            local go = GameUtil:createItemElement({ RewardUtil.REWARD_TYPE_KEYS.EQUIPS, cfg.id, 0}, false, false)
            go.transform:SetParent(self.m_icon_node.transform, false)
        end
        local combat_1, combat_2 = self.m_model:getCombat()
        self:setTextByLanKey("combat_1_text", GameUtil:formatNum(combat_1))
        self:setTextByLanKey("combat_2_text", GameUtil:formatNum(combat_2))
    end
    local cons = self.m_model:getConsume()
    local data = RewardUtil:getProcessRewardData(cons[1])
    self:setTextByLanKey("cons_num_text", data.data_num.."/"..data.user_num)
    if cons then
        local go = GameUtil:createItemElement(cons[1], false, true)
        go.transform:SetParent(self.m_const_node.transform, false)
    end
    self:updateLoopScroll()
end

--[[	
	属性列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getAttr()
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local next_atr = self.m_model:getNextAttr(cell_data[1])
                local LuaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                if LuaBehaviour then
                    local atr = GameUtil:getAttrsKey(cell_data[1])
                    LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "title_text", GameUtil:getAttrsName(atr))
                    LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "count_text", GameUtil:formatNum(cell_data[2]) )
                    LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "count2_text", GameUtil:formatNum(next_atr[2]))
                end
            end,
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data)
    end
end

return M