---@class SetHeroAndBackView:OOPopBase
local M = class("SetHeroAndBackView",LikeOO.OOPopBase)

M.m_uiName = "Main/SetHeroAndBack"
M.m_iphoneXAdapter = true
M.m_size_type = 2

local __TAB_BTN_NODE = {
    {btn = "martial_all_toggle", name = "martial_all_text", mask = "martial_all_mask", race = 0},
    {btn = "martial_1_toggle", name = "martial_1_text", mask = "martial_1_mask", race = 1},
    {btn = "martial_2_toggle", name = "martial_2_text", mask = "martial_2_mask", race = 2},
    {btn = "martial_3_toggle", name = "martial_3_text", mask = "martial_3_mask", race = 3},
    {btn = "martial_4_toggle", name = "martial_4_text", mask = "martial_4_mask", race = 4},
    {btn = "martial_5_toggle", name = "martial_5_text", mask = "martial_5_mask", race = 5},
    {btn = "martial_6_toggle", name = "martial_6_text", mask = "martial_6_mask", race = 6},
    {btn = "martial_7_toggle", name = "martial_7_text", mask = "martial_7_mask", race = 7}
}

function M:onEnter()
    self.m_flag = 1
    self:switch()
    self:initRacesTabBtn()
    self:updateHeroScroll(0)
    self:updateBackScroll()
    self:setTextByLanKey("close_title_text", "new_str_0478")
    self:setTextByLanKey("back_set_btn_text", "new_str_0006")
    self:setTextByLanKey("hero_set_btn_text", "new_str_0006")
end

function M:switch()
    local hero_list = self:findGameObject("bottom_hero")
    local back_list = self:findGameObject("bottom_back")
    if self.m_flag == 1 then
        back_list:SetActive(false)
        hero_list:SetActive(true)
        self:setTextByLanKey("switch_btn_text", "main_set_text_002")
        UIUtil.setLocalPosition(hero_list.transform, nil,-400)
        local sequence = Tweening.DOTween.Sequence()
        sequence:Append(hero_list.transform:DOLocalMoveY(-287.5, 0.3):SetEase(Tweening.Ease.OutSine))
        sequence:SetLoops(1)
    else
        hero_list:SetActive(false)
        back_list:SetActive(true)
        self:setTextByLanKey("switch_btn_text", "main_set_text_001")
        UIUtil.setLocalPosition(back_list.transform, nil,-400)
        local sequence = Tweening.DOTween.Sequence()
        sequence:Append(back_list.transform:DOLocalMoveY(-287.5, 0.3):SetEase(Tweening.Ease.OutSine))
        sequence:SetLoops(1)
    end
    self.m_flag = self.m_flag == 1 and 0 or 1
end

function M:initRacesTabBtn()
    for i,v in ipairs(__TAB_BTN_NODE) do
        local tog_btn = self:findToggle(v.btn)
        if i > 1 then
            local have_hero = self.m_model:checkRaceTypeCount(v.race)
            local trans = UIUtil.findImage(tog_btn.gameObject.transform, "Image")
            if have_hero then
                trans.material = nil
                self:setObjectVisible(v.mask, false)
            else
                self:setObjectVisible(v.mask, true)
            end
        else
            self:setTextByLanKey(v.name, "new_str_0065")
            self:setObjectVisible(v.mask, false)
        end
        UIUtil.addToggleListener(
                tog_btn,
                function(is_on, data)
                    if is_on then
                        self:updateHeroScroll(data)
                        local hero_id = self.m_model:getHeroIDByIndex(1)
                        self:updateMsg("select_hero", {id = hero_id, index = 1})
                    end
                end,
                v.race,
                self.m_uiName
        )
    end
end

function M:updateHeroScroll(race)
    local data = self.m_model:getHeroIDs(race)
    self.m_select_index = 1
    self.select_cell_obj = nil
    if self.m_hero_scroll == nil then
        local list_scroll = self:findGameObject("hero_scroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            init_cell = function(index, cell_object)
                local function callback()
                    local itemNode = ResourceUtil:LoadUIGameObject("Main/MainHeroNodeCell", Vector3.zero, nil)
                    local canvas_group = itemNode:GetComponent("CanvasGroup")
                    canvas_group.blocksRaycasts = false
                    itemNode.name = "cell_content"
                    itemNode.transform:SetParent(cell_object.transform, false)
                    self:listHandle(itemNode, index)
                    itemNode:SetActive(true)
                end
                if index <= 9 then
                    self.m_control:setOnceTimer(index <= 9 and  (0.033 * index) or 0, callback)
                else
                    callback()
                end
            end,
            update_cell = function(index, cell_object, cell_data)
                local content_tran = UIUtil.findTrans(cell_object.transform, "cell_content")
                if content_tran then
                    content_tran.gameObject:SetActive(true)
                    self:listHandle(content_tran.gameObject, index)
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                local content_tran = UIUtil.findTrans(cell_object.transform, "cell_content")
                if content_tran then
                    if index ~= self.m_select_index then
                        if not IsNull(self.select_cell_obj) then
                            local LuaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
                            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img",false)
                        end
                        self.m_select_index = index
                        self.select_cell_obj = content_tran
                        local LuaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
                        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img",true)
                        local hero_id = self.m_model:getHeroIDByIndex(index)
                        self:updateMsg("select_hero", {id = hero_id, index = index})
                    end
                end
            end,
        }
        self.m_hero_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_hero_scroll:reloadData(data, true)
    end
end

function M:listHandle(obj, index)
    local hero_id = self.m_model:getHeroIDByIndex(index)
    --Logger.logWarning(hero_id, "hero_id :")
    local cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_id)
    --Logger.logWarning(cfg.icon_name, "icon_name :")
    GameUtil:updateHeroContentByData(obj, nil, cfg)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    if LuaBehaviour then
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lv_text", false) --隐藏等级
        if index == self.m_select_index then
            self.select_cell_obj = obj
            self.check_cell_obj = obj
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img",true)
        else
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img",false)
        end
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "duigou_img",hero_id == self.m_model.m_hero_id)
    end
end

function M:refreshHeroCheck()
    local LuaBehaviour = UIUtil.findLuaBehaviour(self.check_cell_obj)
    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "duigou_img",false)
    LuaBehaviour = UIUtil.findLuaBehaviour(self.select_cell_obj)
    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "duigou_img",true)
    self.check_cell_obj = self.select_cell_obj
end

function M:updateBackScroll()
    local data = self.m_model:getBGList()
    self.m_select_back_index = 1
    self.select_back_obj = nil
    if self.m_back_scroll == nil then
        local list_scroll = self:findGameObject("back_scroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                self:refreshBGItem(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if index ~= self.m_select_back_index then
                    if self.select_back_obj then
                        local LuaBehaviour = UIUtil.findLuaBehaviour(self.select_back_obj)
                        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img",false)
                    end
                    self.m_select_back_index = index
                    self.select_back_obj = cell_object
                    self.m_model.m_back_state = self.m_model:checkBGOpen(cell_data)
                    local LuaBehaviour = UIUtil.findLuaBehaviour(self.select_back_obj)
                    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img",true)
                    self:updateMsg("select_back", {img = cell_data.big_img})
                end
            end
        }
        self.m_back_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_back_scroll:reloadData(data, true)
    end
end

function M:refreshBGItem(index, obj, cell_data)
    local cfg = cell_data
    local state = self.m_model:checkBGOpen(cfg)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local img = luaBehaviour:FindImage("icon_img")
    GameUtil:updateResourcesImg( img, "Texture/".. cfg.small_img)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text",cfg.name)
    if state == 1 then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "method_text", " ")
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock",false)
    else
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "method_text",cfg.ways)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock",true)
    end
    if index == self.m_select_back_index then
        self.select_back_obj = obj
        self.focus_back_obj = obj
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img",true)
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img",false)
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_img",self.m_model.m_back_img == cfg.big_img)
end

function M:refreshBGCheck()
    local LuaBehaviour = UIUtil.findLuaBehaviour(self.focus_back_obj)
    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "check_img",false)
    LuaBehaviour = UIUtil.findLuaBehaviour(self.select_back_obj)
    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "check_img",true)
    self.focus_back_obj = self.select_back_obj
end

function M:destroy()
    M.super.destroy(self)
end

return M