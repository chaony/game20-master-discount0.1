local M = class("HireMasterHeroPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/HireMasterHeroPop"
M.m_size_type = 2

local pro_type = {
    {key = 1, icon = "SL_quan", text = "全", isOn = true ,race = 0},
    {key = 2, icon = "SL_qinglong", text = "", isOn = false ,race = 1 },
    {key = 3, icon = "SL_zhuque", text = "", isOn = false ,race = 2 },
    {key = 4, icon = "SL_xuanwu", text = "", isOn = false ,race = 3 },
    {key = 5, icon = "SL_baihu", text = "", isOn = false ,race = 4 },
    {key = 6, icon = "SL_baihu", text = "", isOn = false ,race = 5 },
    {key = 7, icon = "SL_baihu", text = "", isOn = false ,race = 6 },
}

function M:onEnter()
	self:refreshUI()
end

function M:refreshUI()
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
			one_line_count = 6,
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
function M:updateHeroContent(obj, id)
	if obj == nil then 
		Logger.log("GameUtil fun updateHeroContent obj error！！！")
		return 
	end
    local hero_data, hero_cfg = self.m_model:getHero(id)
    local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_cfg.id, quality = hero_data.evo})
    GameUtil:updateItemElementByData(obj, itemData, false, false)
    GameUtil:updateHeroLvByData(obj, hero_data)
    local luaBehaviour = obj:GetComponent("LuaBehaviour")
    local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
    lv_bg_img:SetActive(true)
    local camp_ = GlobalConfig.TYPE_HERO_RACE[hero_cfg.race]
    local camp_img = LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", camp_.race_icon,  ResourceUtil:getLanAtlas())
    if self.m_model:checkLockHero(id) == true then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_image", true)
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", self.m_model:checkIsSelect(id))
    end

end


return M