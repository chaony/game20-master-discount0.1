local M = class("MagicWeaponHeroPopView",LikeOO.OOPopBase)

M.m_uiName = "MagicWeapon/MagicWeaponHeroPop"
M.m_size_type = 2
--英雄信息
function M:onEnter()
    self.m_gray_img = self:findImage("gray_img")
    self:updateHerosScroll()
    self:setTextByLanKey("title_text", "weapon_str_0012")
end

function M:refreshUI()

end

function M:updateHerosScroll()
    local data = self.m_model.m_heros
    -- if #data < 8 then
    --     for i = #data, 8 do
    --         data[i] = -1
    --     end
    -- end
    self.select_cell_obj = nil
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("loopscroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			one_line_count = 6,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                if luaBehaviour then
                    local hero_node = luaBehaviour:FindGameObject("HeroNode")
                    if cell_data > 0 then
                        CommonUIUtil:updateHeroElement(hero_node, {101,cell_data,1},false, function ()
                            self.m_control:openView("Pops.HeroLookInfo", {hero_id = cell_data, is_new = false})
                        end)
                    else
                        CommonUIUtil:updateHeroElementAdd(hero_node, nil, false)
                    end
                    local item_img = luaBehaviour:FindImage("item_img")
                    local quality_img = luaBehaviour:FindImage("quality_img")
                    if item_img then
                        if UserDataManager.hero_data:checkHeroCollect(cell_data) == false then
                            item_img.material = self.m_gray_img.material
                            quality_img.material = self.m_gray_img.material
                        else
                            item_img.material = nil
                            quality_img.material = nil
                        end
                    end
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "camp_bg", false)
                end
			end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
    
			end,
            ui_name = self.m_uiName,
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data, true)
	end
end


function M:destroy()
    M.super.destroy(self)
end

return M