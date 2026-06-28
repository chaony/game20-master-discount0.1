local M = class("ShareLvSelectPopView",LikeOO.OOPopBase)

M.m_uiName = "ShareLv/ShareLvSelectPop"
M.m_size_type = 2

local __TAB_BTN_NODE = {
    {btn = "martial_all_toggle", name = "martial_all_text",},
    {btn = "martial_1_toggle", name = "martial_1_text",},
    {btn = "martial_4_toggle", name = "martial_4_text",},
    {btn = "martial_2_toggle", name = "martial_2_text",},
    {btn = "martial_3_toggle", name = "martial_3_text",},
    {btn = "martial_6_toggle", name = "martial_6_text",},
    {btn = "martial_5_toggle", name = "martial_5_text",},
    {btn = "martial_7_toggle", name = "martial_7_text",},
}
function M:onEnter()
    -- self.RaceToggle = self:findGameObject("race_toggle_bg")
    -- self.RaceToggle:SetActive(true)
    for i,v in ipairs(__TAB_BTN_NODE) do
        local tog_btn = self:findToggle(v.btn)
        local lan_text = "new_str_0065"
        if i > 1 then
            lan_text = GlobalConfig.TYPE_HERO_RACE[i-1].name
        end
        self:setTextByLanKey(v.name, lan_text)
        UIUtil.setObjectVisible(tog_btn.transform, self.m_model.m_race == i,"UI_ShareLv_Xuanze_01")
        UIUtil.addToggleListener(tog_btn, function(is_on, data)
            if is_on then
                self:updateMsg("tab_btn",data)
                local lan_text = data > 1 and GlobalConfig.TYPE_HERO_RACE[i-1].name or "new_str_0065"
                self:setTextByLanKey("race_toggle_btn_text", lan_text)
                UIUtil.setObjectVisible(tog_btn.transform, true,"UI_ShareLv_Xuanze_01")
            else
                UIUtil.setObjectVisible(tog_btn.transform, false,"UI_ShareLv_Xuanze_01")
            end
        end, i, self.m_uiName)
    end
    --self.RaceToggle:SetActive(false)
    self.m_race_toggle_flag = false
    
	self:setText("ok_text", Language:getTextByKey("new_str_0006"))
	self:setText("common_title_text", Language:getTextByKey("shareLv_str_0002"))
    self:setTextByLanKey("no_text", "shareLv_str_0020")
    self.no_panel = self:findGameObject("no_panel")

	self:refreshUI()
end

function M:refreshUI()
    self.no_panel:SetActive(#self.m_model.m_show_heros <= 0)
	self:updateListScroll()
end

function M:updateListScroll()
    local data = self.m_model.m_show_heros
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 6,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                self:updateHeroData(cell_object, index)
                if index == 1 then
                    self.m_guide_cell = cell_object
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                local oid = self.m_model:getHeroDataByIndex(index)
                self:updateMsg("select_hero", oid)
            end,
            ui_name = self.m_uiName,
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data, self.m_control.keep_offset)
        self.m_control.keep_offset = nil
    end
end

function M:listHandle(obj, id)
	local oid = self.m_model:getHeroDataByIndex(id)
	if oid then
		-- local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
        -- -- UIUtil.setScale(obj.transform,0.9)
		-- CommonUIUtil:updateHeroElement(obj, {RewardUtil.REWARD_TYPE_KEYS.HEROS,cfg.id,1,oid})
		-- local luaBehaviour = obj:GetComponent("LuaBehaviour")
		-- local duigou_img = luaBehaviour:FindGameObject("duigou_img")
		-- local is_select = self.m_model.m_select == oid
		-- duigou_img:SetActive(is_select)
	end
end


function M:updateHeroData(obj, id)
    local o_id = self.m_model:getHeroDataByIndex(id)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    GameUtil:updateHeroContent(obj, o_id)
    local duigou_img = luaBehaviour:FindGameObject("duigou_img")
    local is_select = self.m_model.m_select == o_id
	duigou_img:SetActive(is_select)
end


function M:setToggleActive(flag)
    self.m_race_toggle_flag = flag
    --self.RaceToggle:SetActive(flag)
end

return M