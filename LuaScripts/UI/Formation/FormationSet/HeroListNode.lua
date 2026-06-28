---武神
local M = class("HeroListNode",LikeOO.OOUIbase)

M.m_uiName = "Formation/HeroListNode"

local __TAB_BTN_NODE = { 
	--    show_sidebar(是否显示侧边栏)
	{btn_key = "tog_1", lua_name = "UI.Formation.FormationSet.HeroListNode", text_name = "tog_1_text", text_key = "shareLv_str_0024"}, -- 势力
	{btn_key = "tog_2", lua_name = "UI.Formation.FormationSet.DeploymentNode", text_name = "tog_2_text", text_key = "new_str_0521" }, -- 定位
}

function M:onEnter()
    for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.text_name, v.text_key)
		local tog_btn = self:findToggle(v.btn_key)
		if k == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
		end
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
    end    
    self:switchHeroTypeBtn() --默认调用
end

function M:switchTabUpdate(is_on, update_key)
	if is_on then
		self:updateMsg("switch_hero_type", update_key)
	end
end

function M:switchHeroTypeBtn(index)
    self:updateTypeLoopScroll()
end

--筛选类型
function M:updateTypeLoopScroll()
    local data = self.m_model:getTypeList()
	if self.m_type_scroll_view == nil then
        local loopscroll = self:findGameObject("type_loopscroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
			loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local LuaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                if LuaBehaviour then
                    local tog_btn = LuaBehaviour:FindToggle("Image")
                    if index == 1 then
                        tog_btn.isOn = true
                    end
                    UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTypeTog(is_on, index) end,nil,self.m_uiName)
                end
			end,
        }
        self.m_type_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_type_scroll_view:reloadData(data, true)
	end
end

function M:switchTypeTog(is_on, update_key)
    self:updateHeroLoopScroll()
end

--更新英雄列表
function M:updateHeroLoopScroll()
    self.m_model:getTypeList()
    local data = self.m_model.Filtrate_list
	if self.m_hero_scroll_view == nil then
        local loopscroll = self:findGameObject("hero_loopscroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 4, -- 行或列的数量
			loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateHero(cell_object, cell_data)
			end,
        }
        self.m_hero_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_hero_scroll_view:reloadData(data, true)
	end
end

--刷新英雄数据
function M:updateHero(obj, heroOid)
    local hero_data,hero_cfg = self.m_model:getHero(heroOid)
    CommonUIUtil:updateHeroElement(obj, {RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 1}) 
end


function M:refreshUI()

end


return M