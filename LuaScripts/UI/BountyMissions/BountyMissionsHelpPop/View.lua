local M = class("BountyMissionsHelpPopView",LikeOO.OOPopBase)

M.m_uiName = "BountyMissions/BountyMissionsHelpPop"
M.m_size_type = 2

local pro_type = {
    {key = 1, icon = "a_ui_all", text = "全", isOn = true ,race = 0},
    {key = 2, icon = "a_ui_qinglong", text = "", isOn = false ,race = 1 },
    {key = 3, icon = "a_ui_zhuque", text = "", isOn = false ,race = 3 },
    {key = 4, icon = "a_ui_xuanwu", text = "", isOn = false ,race = 2 },
    {key = 5, icon = "a_ui_baihu", text = "", isOn = false ,race = 4 },
    -- {key = 6, icon = "a_ui_guangming", text = "", isOn = false ,race = 5 },
    -- {key = 7, icon = "a_ui_heian", text = "", isOn = false ,race = 6 },
}


function M:onEnter()	
	self:updateProLoopScroll()
end

--[[
    职业类型页签列表
]]
function M:updateProLoopScroll()
    self.m_pro_cell_tab = {}
    local tog = self:findGameObject("pro_toggle")   
    self.pro_toggle = UIUtil.findComponent(tog.transform, typeof(U3DUtil:Get_ToggleGroup()))
    if self.m_pro_scroll_view == nil then
        local loopscroll = self:findGameObject("pro_loopscroll")
        local params ={
            show_data = pro_type,
            loop_scroll_object = loopscroll,
            update_cell =function(index, cell_obj, cell_data)
                self.m_pro_cell_tab[index] = { obj = cell_obj, data = cell_data}
                local cell_tog = UIUtil.findComponent(cell_obj.transform,typeof(U3DUtil:Get_Toggle()))
                cell_tog.group = self.pro_toggle
                GameUtil:updateProCell(cell_obj, cell_data, function(is_on) self:switchTabByProCell(is_on, cell_data.race) end, self.m_uiName)
            end,
        }
        self.m_pro_scroll_view = LoopScrollViewUtil.new(params)
    else
    	self.m_pro_scroll_view:reloadData(pro_type)
    end 

    for k,v in pairs(self.m_pro_cell_tab) do
        if v.data.isOn == true then
            local cell_tog = UIUtil.findComponent(v.obj.transform,typeof(U3DUtil:Get_Toggle()))
            cell_tog.isOn = true
        end
    end
end

function M:switchTabByProCell(is_on, update_key)
    if is_on then
        self.m_race = update_key
        self:updateLoopScroll()
	end
end

--[[
	创建英雄列表
]]
function M:updateLoopScroll()
	self.m_model:getHeroByRace(self.m_race)
	local data = self.m_model.Filtrate_list
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 7,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateHeroContent(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("select_hero", cell_data)
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--刷新英雄数据
function M:updateHeroContent(obj, heroOid)
	if obj == nil then 
		Logger.log("GameUtil fun updateHeroContent obj error！！！")
		return 
	end
	local hero_data,hero_cfg = self.m_model:getHero(heroOid)
	local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 1, hero_data.oid})
	CommonUIUtil:updateHeroElementByData(obj, itemData)
	CommonUIUtil:updateHeroLvByData(obj, hero_data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	if luaBehaviour then
		local duigoudi_img = luaBehaviour:FindGameObject("duigou_img")
		local in_team_flag = self.m_model:isInSlot(heroOid)
		duigoudi_img:SetActive(in_team_flag)
	end
	luaBehaviour:InjectionFunc()
end

return M