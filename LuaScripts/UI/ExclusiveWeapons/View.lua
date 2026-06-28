local M = class("ExclusiveWeaponsView",LikeOO.OOPopBase)

M.m_uiName = "ExclusiveWeapons/ExclusiveWeapons"

function M:onEnter()
    self.m_icon_node = self:findGameObject("icon_node")

	self:refreshUI()
end


function M:refreshUI()
    if self.m_model.exclusive_lv >= 0 then
        self:setObjectVisible("con_1",true)
        self:setObjectVisible("con_2",false)
    else
        self:setObjectVisible("con_1",false)
        self:setObjectVisible("con_2",true)   
        self:updateLoopScroll(self.m_model:activateAttrs())
    end
    self:setTextByLanKey("title_text", self.m_model.m_eqp_cfg.name) 
    self:setImg(self.m_model.m_eqp_cfg.icon, "equip_icon", "icon_e_w")
    self:setCost()
end

--
function M:setCost()
    local cost = self.m_model:checkCost()
    self.m_icon_node = self:findGameObject("icon_node")
    local item = GameUtil:createItemElement(cost, false, true)
    item.transform:SetParent(self.m_icon_node.transform, false)
end


function M:setAttrs()
    local data = {}
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            one_line_count = 2,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
               
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data)
    end
end

--[[	
	属性列表
]]
function M:updateLoopScroll(attrs)
    local data = UserDataManager:appendAttrs(attrs)
	local tab = {}
	for i, v in pairs(data) do
		table.insert(tab, {i, v})
	end

    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = tab,
            one_line_count = 2,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
				local cp = GameUtil:getAttrsName(cell_data[1])
				local attr_name_text = UIUtil.setText(transform, cp, "attr_name_text")
				-- 四舍五入保留小数点后一位
				local attr_value = cell_data[2] or 0
				attr_value = math.floor(attr_value * 10 + 0.5)/10
				local attr_value_text = UIUtil.setText(transform, tostring(attr_value), "attr_value_text")
				local attr_value_text_trans = UIUtil.findRectTransform(attr_value_text)
				UIUtil.setLocalPosition(attr_value_text_trans, attr_name_text.preferredWidth + 20)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data)
    end
end

return M