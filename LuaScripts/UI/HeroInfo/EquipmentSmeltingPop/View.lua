local M = class("EquipmentSmeltingPopView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_iphoneXAdapter = true
M.m_uiName = "HeroInfo/EquipmentSmeltingPop"

function M:onEnter()
    self.m_icon_node = self:findGameObject("item_parent")
    self.m_const_node = self:findGameObject("cons_parent")
    self:setTextByLanKey("common_title_text", "new_str_1016")
    self:setTextByLanKey("left_title_text", "new_str_1015")
    self:setTextByLanKey("right_title_text", "new_str_1014")
    self:setTextByLanKey("smelt_btn_text", "new_str_1017")
    
    --local data, cfg = self.m_model:getEqpData()
    --if cfg then
    --    if data then
    --        local go = GameUtil:createItemElement({RewardUtil.REWARD_TYPE_KEYS.EQUIPS, data.id, data.race}, false, false)
    --        go.transform:SetParent(self.m_icon_node.transform, false)
    --        GameUtil:updateItemEquipInfo(go, data)
    --        local luaBehaviour = UIUtil.findLuaBehaviour(go)
    --    else
    --        local go = GameUtil:createItemElement({ RewardUtil.REWARD_TYPE_KEYS.EQUIPS, cfg.id, 0}, false, false)
    --        go.transform:SetParent(self.m_icon_node.transform, false)
    --    end
    --    local combat_1, combat_2 = self.m_model:getCombat()
    --    self:setTextByLanKey("combat_1_text", GameUtil:formatNum(combat_1))
    --    self:setTextByLanKey("combat_2_text", GameUtil:formatNum(combat_2))
    --end
    --local cons = self.m_model:getConsume()
    --local data = RewardUtil:getProcessRewardData(cons[1])
    --self:setTextByLanKey("cons_num_text", data.data_num.."/"..data.user_num)
    --if cons then
    --    local go = GameUtil:createItemElement(cons[1], false, true)
    --    go.transform:SetParent(self.m_const_node.transform, false)
    --end
    self:refreshUi()
end

function M:refreshUi()
    self:updateLoopScroll()
    self:updateRightLoopScroll()
end

--[[	
	属性列表
]] 
function M:updateLoopScroll()
    local data = self.m_model:getEqpData()
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            one_line_count = 5,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local data = cell_data
                local ui_element = GameUtil:updateItemElementByData(cell_object, data, false, false)
                ui_element.red_point_img:SetActive(false)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_image", self.m_model:isSelect(data.oid))
                --if self.m_select_cell_index == index then
                --    self.m_select_cell_object = cell_object
                --    self.m_select_cell_data = cell_data
                --end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                local content_tran = UIUtil.findTrans(cell_object.transform, "cell_content")
                local oid = cell_data.oid
                local cid = cell_data.data_id
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_image", not(self.m_model:isSelect(oid)))
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", not(self.m_model:isSelect(oid)))

                self:updateMsg("click_cell", {oid = oid, cid = cid })
            end,
            ui_name = self.m_uiName
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data)
    end
end

function M:updateRightLoopScroll()
    local data = self.m_model:getRighShowData()
    self:setObjectVisible("right_loopscroll",#data > 0)
    self:setObjectVisible("smelt_btn", #data > 0)
    if self.m_loop_right_scroll_view == nil then
        local loopscroll = self:findGameObject("right_loopscroll")
        local params = {
            show_data = data,
            one_line_count = 3,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local data = cell_data
                local reward_data = RewardUtil:getProcessRewardData(cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                local item_node = luaBehaviour:FindGameObject("item_node")
                local is_show_num = true
                if cell_data[4] then
                    is_show_num = false
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"extra_img", true)
                    LuaBehaviourUtil.setImg(luaBehaviour,"extra_img", cell_data[4] == 1 and "a_rl_digailv" or "a_rl_gaogailv", ResourceUtil:getLanAtlas())
                else
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"extra_img", false)
                end
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_image", self.m_model:isSelect(data.oid))
                local ui_element = GameUtil:updateItemElementByData(item_node, reward_data, is_show_num, true)
                ui_element.red_point_img:SetActive(false)
                --if self.m_select_cell_index == index then
                --    self.m_select_cell_object = cell_object
                --    self.m_select_cell_data = cell_data
                --end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
            end,
            ui_name = self.m_uiName
        }
        self.m_loop_right_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_right_scroll_view:reloadData(self.m_model:getRighShowData())
    end
end

return M