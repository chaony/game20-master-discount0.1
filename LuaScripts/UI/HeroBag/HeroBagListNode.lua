---@class HeroBagListNode:OOUIbase
---@field m_model HeroBagModel
local M = class("HeroBagListNode",LikeOO.OOUIbase)

M.m_uiName = "HeroBag/HeroBagListNode"

local __TAB_BTN_NODE = GlobalConfig.RACE_TAB_BTN_NODE

local __TAB_HERO_BTNS = {
    {btn_name = "ws_img"},
    {btn_name = "tj_img"}
}

function M:onEnter()
    self.select_HeroItem = nil
    self.hero_tab = {}
    self.book_tab = {}
    self:setTextByLanKey("book_title_text_1", "hero_ui_str_0011")
    self:setTextByLanKey("recommend_btn_text", "recommend_btn_tex")
    self:setTextByLanKey("book_title_text_2", "hero_ui_str_0012")
    self:setTextByLanKey("common_no_have_text", "friend_str_0032")
    self:setTextByLanKey("tj_btn_text", "hero_ui_str_0016")
    self:setTextByLanKey("ws_text", "new_str_0433")
    self:setTextByLanKey("tj_text", "new_str_0150")
    self:setTextByLanKey("txt_sort_1", "new_str_0490")
    self:setTextByLanKey("txt_sort_2", "new_str_0436")
    self:setTextByLanKey("txt_sort_3", "hero_ui_str_0009")

    local open_flag = BtnOpenUtil:isBtnOpen(372)
    if open_flag then
        local cfg = ConfigManager:getCfgByName("open_condition")
        local fenghua_record_cfg = cfg[372]
        self:setTextByLanKey("fenghua_record_btn_text", fenghua_record_cfg.name)
    else
        local fenghua_record_go = self:findGameObject("fenghua_record_btn")
        fenghua_record_go:SetActive(false)
    end

    open_flag=BtnOpenUtil:isBtnOpen(476)
    self:setObjectVisible("supportSys",open_flag)
    if open_flag then
        self:setTextByLanKey("supportSys_btn_text", "supportSys_str_0004")
    end
    

	for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v.btn)
		--local lan_text = "new_str_0065"
		--if i > 1 then
		--	lan_text = GlobalConfig.TYPE_HERO_RACE[i-1].name
		--end
		--self:setTextByLanKey(v.name, lan_text)
        UIUtil.setObjectVisible(tog_btn.transform, i==1,"UI_ShareLv_Xuanze_01") --默认第一个
		UIUtil.addToggleListener(tog_btn, function(is_on, data) 
			if is_on then
                if data == 9 then
                    self:updateMsg("tab_btn", 100) --SP处理
                else
                    self:updateMsg("tab_btn", data - 1)
                end
				--local lan_text = data > 1 and GlobalConfig.TYPE_HERO_RACE[i-1].name or "new_str_0065"
				--self:setTextByLanKey("race_toggle_btn_text", lan_text)
                UIUtil.setObjectVisible(tog_btn.transform, true,"UI_ShareLv_Xuanze_01")
            else
                UIUtil.setObjectVisible(tog_btn.transform, false,"UI_ShareLv_Xuanze_01")
			end 
		end, i, self.m_uiName)
    end
    self:setObjectVisible("img_sort_select", false)
    self.sort_list = {}
    for i=1, 3 do
        self.sort_list[i] = {}
        local btn_item = self:findGameObject("btn_sort_" .. i)
        local img_select = self:findGameObject("img_select_" .. i)
        local txt_sort_type = self:findText("txt_sort_" .. i)
        UIUtil.setButtonClick(btn_item, function()
            self.m_control:SortDataList(i)
        end)
        self.sort_list[i] = {img_select = img_select, txt_sort_type = txt_sort_type,}
    end
    self:updateHerosScroll()
    self:refreshHero_Grid() 
    self:refreshUI()
    self:refreshMaskStatus()
    self:refreshSupportSysRedPoint()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
end

function M:dataUpdateEvent(event, data)
    if data.event == "red_dot_update" then
        self:refreshSupportSysRedPoint()
    end
end

function M:refreshMaskStatus()
    local race_hero_num = self.m_model:checkRaceMask()
    for k,v in pairs(GlobalConfig.TYPE_HERO_RACE) do
        if race_hero_num[k] ~= nil and race_hero_num[k] > 0 then
            self:setObjectVisible("race_"..k.."_mask", false)
        else
            self:setObjectVisible("race_"..k.."_mask", true)
        end
    end
    --sp侠客
    local is_have_sp = UserDataManager.hero_data:checkHaveSP()
    self:setObjectVisible("sp_mask", is_have_sp == false)
end

function M:InitType(c_type, first)
    if c_type == 1 then
        self.m_rt.gameObject:SetActive(true)
        local move_x = self.m_model:getCurMoveX(-370.5, self.m_control.m_view.m_view_width)
        if first == false then
			GameUtil:dotweenMoveX(self.m_rt.gameObject, move_x)
        else
            self.m_rt.localPosition = Vector3.New(move_x,0,0)
		end
        if self.m_model.refresh_hero_list == true then
            self:updateHerosScroll()
            self:refreshUI() 
        end
    elseif c_type == 2 then
        local move_x = self.m_model:getCurMoveX(-877, self.m_control.m_view.m_view_width)
        if first == false then
            local callback = function ()
                self.m_rt.gameObject:SetActive(false) 
			end
			GameUtil:dotweenMoveX(self.m_rt.gameObject, move_x, callback)
        else
            self.m_rt.localPosition = Vector3.New(move_x,0,0)   
            self.m_rt.gameObject:SetActive(false) 
		end
    else
        local move_x = self.m_model:getCurMoveX(-370.5, self.m_control.m_view.m_view_width)
        self.m_rt.localPosition = Vector3.New(move_x,0,0)
        self:updateHerosScroll()
        self:refreshUI() 
    end
end

--左右滑动英雄刷新选中框
function M:updateSelectHero()
    if self.select_HeroItem then
        local LuaBehaviour = UIUtil.findLuaBehaviour(self.select_HeroItem)
        if LuaBehaviour then
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img", false)
        end
        local temp_obj = nil
        if self.m_model.m_hero_list_type == 1 then
            for k,v in pairs(self.hero_tab) do
                if self.m_model.m_selected_id == k then
                    temp_obj = v
                end
            end
        end
        if temp_obj then
            local temp_LuaBehaviour = UIUtil.findLuaBehaviour(temp_obj)
            if temp_LuaBehaviour then
                LuaBehaviourUtil.setObjectVisible(temp_LuaBehaviour, "select_img", true)
            end
            self.select_HeroItem = temp_obj
        end
    end
end

function M:refreshUI()
    if self.m_model.m_mode == 3 then
        return
    end
    self:setObjectVisible("hero_list_obj", self.m_model.m_hero_list_type == 1)
    self:setObjectVisible("tj_red_point_img", RedPointUtil:hasRedPointById(27)== true)
    local red_point = RedPointUtil:checkPushFormationRedPoint()
    self:setObjectVisible("recommend_red_point_img", red_point == true)
end

function M:refreshSupportSysRedPoint()
    local red_point = RedPointUtil:checkSupportSysRedPoint()
    self:setObjectVisible("supportSys_red_point_img", red_point == true)
end

function M:refreshTJRedPoint()
    self:setObjectVisible("tj_red_point_img", RedPointUtil:hasRedPointById(27)== true)
end

function M:sliderTop()
    if self.m_model.m_hero_list_type == 1 then
        if self.m_list_scroll ~= nil then
            local data = self.m_model.hero_list
            if #data > 0 then
                local index = self.m_model:getHeroIndexByOid(self.m_model.m_selected_id) or 1
                self.m_list_scroll:moveToCellIndex(index) 
            end
        end
    end
end

--英雄格子数量
function M:refreshHero_Grid()
    local c_num, max_num = self.m_model:getHeroGrideNum()
    local num_text = Language:getTextByKey("new_str_0430", c_num.."/"..max_num)
    self:setText("hero_num",num_text)
end

function M:switchRaceScroll()
    self.hero_tab = {}
    self:updateHerosScroll()
end

function M:updateHerosScroll()
    if self.m_model.m_mode == 3 then
        return
    end
    local data = self.m_model.hero_list
    self.select_cell_obj = nil
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("heros_scroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			one_line_count = 3,
			loop_scroll_object = list_scroll,
            init_cell = function(index, cell_object)
                local function callback()
                    local cell_data = self.m_list_scroll.m_show_data[index]
                    local itemNode = ResourceUtil:LoadUIGameObject("Main/MainHeroNodeCell", Vector3.zero, nil)
                    local canvas_group = itemNode:GetComponent("CanvasGroup")
                    canvas_group.blocksRaycasts = false
                    itemNode.name = "cell_content"
                    itemNode.transform:SetParent(cell_object.transform, false)
                    if cell_data then
                        self.hero_tab[cell_data] = itemNode
                        self:listHandle(itemNode, index)
                        itemNode:SetActive(true)
                    else
                        itemNode:SetActive(false)
                    end
                end
                if index <= 9 then
                    self.m_control:setOnceTimer(index <= 9 and  (0.033*index) or 0, callback)
                else
                    callback()
                end
			end,
			update_cell = function(index, cell_object, cell_data)
                local content_tran = UIUtil.findTrans(cell_object.transform, "cell_content")
                if not IsNull(content_tran) then
                    content_tran.gameObject:SetActive(true)
                    local data = cell_data
                    self.hero_tab[cell_data] = content_tran
                    self:listHandle(content_tran.gameObject, index)
                end
			end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                local content_tran = UIUtil.findTrans(cell_object.transform, "cell_content")
                if content_tran then
                    if index ~= self.m_model.m_select_index then
                        if not IsNull(self.select_cell_obj) then
                            local LuaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
                            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img",false) 
                        end
                        self.select_cell_obj = content_tran
                        local LuaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
                        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img",true) 
                        local oid = self.m_model:getHeroDataByIndex(index)
                        self:updateMsg("select_hero", {id = oid,index = index})
                    else
                        local cur_guide = UserDataManager.guide_data:getCurGuideInfo()
                        local bl = cur_guide ~= nil and cur_guide.key == "HeroBag"
                        if bl == true then
                            local oid = self.m_model:getHeroDataByIndex(index)
                            self:updateMsg("select_hero", {id = oid,index = index})
                        end 
                    end
                end
			end,
            ui_name = self.m_uiName,
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data, true)
	end
end

function M:listHandle(obj, id)
	local oid = self.m_model:getHeroDataByIndex(id)
    if oid == nil then
        return
    end
    local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    GameUtil:updateHeroContent(obj, oid)
    local bl = RedPointUtil:checkHeroRedPointById(oid)
    if LuaBehaviour then
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "red_point_img", false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "red_point_img2", false)
        if data.evo >= 10 and data.evo <= 13 then
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "red_point_img2", bl == true)
        else
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "red_point_img", bl == true) 
        end
        if oid == self.m_model.m_selected_id then
            self.select_HeroItem = obj
            self.select_cell_obj = obj
            self.m_model.m_select_index = id
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img",true)
        else
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img",false)  
        end
    end
end

function M:refreshRedPoint()
    if self.m_model.m_hero_list_type == 1 then
        if self.m_model.m_type == 1 then
            self:updateHerosScroll()
            self:refreshHero_Grid()
        end
    end
end

function M:switchHeroBtnType()
    for k,v in pairs(__TAB_HERO_BTNS) do
        local cur_obj = self:findGameObject(v.btn_name) 
        local cur_img = self:findImage(v.btn_name) 
        if k == self.m_model.m_hero_list_type then
            if cur_obj then
                cur_obj.transform:SetAsLastSibling()
                cur_obj.transform.localPosition = Vector3(-13, 0, 0)
                cur_obj.transform.localScale = Vector3(1, 1, 1)
                cur_img.color = Color.New(1, 1, 1)
            end
        else
            if cur_obj then
                cur_obj.transform.localPosition = Vector3(33, 0, 0)
                cur_obj.transform.localScale = Vector3(0.8, 0.8, 0.8)
                cur_img.color = Color.New(0.6, 0.6, 0.6)
            end
        end
    end
    local jt_obj = self:findGameObject("jt_img") 
    if jt_obj then
        jt_obj.transform:SetAsLastSibling()
    end
    if self.m_model.m_hero_list_type == 1 then
        self:updateHerosScroll()
        self:refreshHero_Grid()
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end

return M