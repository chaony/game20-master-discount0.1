local M = class("WorldMapGuideView",LikeOO.OOPopBase)

M.m_uiName = "WorldMap/WorldMapGuide"
M.m_size_type = 2

function M:create()
    M.super.create(self)
end

function M:onEnter()
    self:setTextByLanKey("jianghu_text", Language:getTextByKey("world_str_007"))
    self:setTextByLanKey("shouye_text", Language:getTextByKey("world_str_019"))
    self:refreshUI()
    self:lockTouch()
    self.m_control:setOnceTimer(1.2, function ()
        if self.bk_list_scroll then
            self.bk_list_scroll:moveToCellIndex(1)
        end
        self:unlockTouch()
    end)
end

function M:refreshUI()
    --江湖未开放时，置灰
    local open_flag = BtnOpenUtil:isBtnOpen(89)
    if open_flag == false then
        self:setImgGray(self.m_luaBehaviour, "jianghu_btn")
        local jiang_hu_text = self:findText("jianghu_text")
        local star_color = jiang_hu_text.color
        star_color.r = 197.0 / 255
        star_color.g = 183.0 / 255
        star_color.b = 183.0 / 255
        jiang_hu_text.color = star_color
    end
    
    self:creatBookScroll()
end

function M:creatBookScroll()
    local data_handled = {}
    local data = self.m_model:getNpcGuideTab()
    data.length = table.nums(data)
    data.shi_wu_first_flag = false
    data.xia_yi_first_flag = false
    data.index_shi_wu = 0
    data.index_xia_yi = 0
    data.index = 1
    for i = 1, data.length do
        local count = i % 2
        local t = {}
        local got_one = false
        if self:getItemData(t, data) then
            got_one = true
        end
        if count == 1 then
            if self:getItemData(t, data) then
                got_one = true
            end
        end
        if got_one then
            table.insert(data_handled, #data_handled + 1, t)
        else
            break
        end
    end

    local all_cell_size = {}
    for k,v in pairs(data_handled) do
        all_cell_size[k]= Vector2(96.5, 556)
    end
    if self.bk_list_scroll == nil then
		local list_scroll = self:findGameObject("loopscroll")
		local params = {
			ui_name = self.m_uiName,
            show_data = data_handled,
            all_cell_size = all_cell_size,
			loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                self:handleCell(index, cell_object, cell_data)
			end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                local guide_cfg = {}
                if click_name == "item_node_1" then
                    guide_cfg = cell_data[1]
                elseif click_name == "item_node_2" then
                    guide_cfg = cell_data[2]
                end
                self:updateMsg("go_to", guide_cfg.go_type)
            end
		}
		self.bk_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.bk_list_scroll:reloadData(data_handled, true)
	end
    
end

function M:getItemData(t_in, t_out)
    local item_data = t_out[t_out.index]
    if t_out.index > t_out.length or item_data == nil then
        return false
    end
    t_out.index = t_out.index + 1
    if item_data.sort == 1 then
        t_out.index_shi_wu = t_out.index_shi_wu + 1
    elseif item_data.sort == 2 then
        t_out.index_xia_yi = t_out.index_xia_yi + 1
    end
    if t_out.shi_wu_first_flag == false and item_data.sort == 1 and t_out.index_shi_wu == 1 then
        item_data.shi_wu_first_flag = true
        t_out.shi_wu_first_flag = true
    elseif t_out.xia_yi_first_flag == false and item_data.sort == 2 then
        item_data.xia_yi_first_flag = true
        t_out.xia_yi_first_flag = true
    end
    t_in[#t_in + 1] = item_data
    return true
end

function M:handleCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object.transform)
    local item_data = cell_data[1]
    if item_data then
        if item_data.sort == 1 and item_data.shi_wu_first_flag == true then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "shiwu_img", true)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "shiwu_img", false)
        end
        if item_data.sort == 2 and item_data.xia_yi_first_flag == true then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "xiayi_img", true)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "xiayi_img", false)
        end
    end
    for i = 1, 2 do
        local item_object = luaBehaviour:FindGameObject( "item_node_" .. i)
        item_object:SetActive(false)
    end
    for i = 1, #cell_data do
        local item_object = luaBehaviour:FindGameObject( "item_node_" .. i)
        self:handleCellItem(item_object, cell_data[i])
    end
end

function M:handleCellItem(item_object, item_data)
    if item_object then
        item_object:SetActive(true)
        if next(item_data) then
            local luaBehaviour = UIUtil.findLuaBehaviour(item_object)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg_img", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"icon_img", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"title_text", true)
            LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", item_data.icon, "active_ui")
            LuaBehaviourUtil.setText(luaBehaviour, "title_text", item_data.name)
            if item_data.open_flag == false then
                self:setImgGray(luaBehaviour, "bg_img")
                self:setImgGray(luaBehaviour, "icon_img")
            end
        end
    end
end

function M:setImgGray(luaBehaviour, key)
    local img = luaBehaviour:FindImage(key)
    if img then
        local star_color = img.color
        star_color.r = 133.0 / 255
        star_color.g = 127.0 / 255
        star_color.b = 127.0 / 255
        img.color = star_color
    end
end

return M