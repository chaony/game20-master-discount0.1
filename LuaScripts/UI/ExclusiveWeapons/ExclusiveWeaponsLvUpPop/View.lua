local M = class("ExclusiveWeaponsLvUpPopView",LikeOO.OOPopBase)

M.m_uiName = "ExclusiveWeapons/ExclusiveWeaponsLvUpPop"
M.m_size_type = 2
function M:onEnter()
	self:refreshUI()
end

function M:refreshUI()
    local cfg = self.m_model:getArtData()
    if cfg then
        self:setImg(cfg.icon, "item_icon", "exclusive_icon")
    end
    self:updateLoopScroll()
end

--[[
	创建属性列表
]]
function M:updateLoopScroll()
	local data = self.m_model.m_attrs
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:setCellHander(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

function M:setCellHander(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local main_title_text = luaBehaviour:FindText("main_title_text")
    local aff_title_text = luaBehaviour:FindText("aff_title_text")
    local count_text = luaBehaviour:FindText("count_text")
    local count2_text = luaBehaviour:FindText("count2_text")
    local fx_flash_num = luaBehaviour:FindGameObject("fx_flash_num")
    main_title_text.gameObject:SetActive(false)
    aff_title_text.gameObject:SetActive(false)
    count_text.gameObject:SetActive(true)
    count2_text.gameObject:SetActive(true)
    self.m_control:setOnceTimer(0.35, function ()
        fx_flash_num:SetActive(true)
    end)
    if data["last_lv"] then
        main_title_text.gameObject:SetActive(true)
        main_title_text.text = Language:getTextByKey("new_str_0066")
        count_text.text = "+".. data.last_lv
        count2_text.text = "+".. data.cur_lv
        count2_text.color = GlobalConfig.COMMON_COLLOR.COMMON_3
    else
        aff_title_text.gameObject:SetActive(true)
        local key_name = GameUtil:getAttrsKey(data.cur_attr[1])
        aff_title_text.text = GameUtil:getAttrsName(key_name)
        count2_text.color = GlobalConfig.COMMON_COLLOR.COMMON_18
        if GameUtil:attrTransition(key_name) == true then
            count_text.text = "+".. GameUtil:formatNum(data.last_attr[2] * 100).."%"
            count2_text.text = "+"..GameUtil:formatNum(data.cur_attr[2] * 100).."%"
        else
            count_text.text = "+"..data.last_attr[2]
            count2_text.text = "+".. data.cur_attr[2]
        end
    end
end

return M