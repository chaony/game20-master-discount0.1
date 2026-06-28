local M = class("HeroTeamRecommendPopView",LikeOO.OOPopBase)

M.m_uiName = "HeroBag/HeroTeamRecommend"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("common_title_text", "new_str_0645")
    self:setTextByLanKey("common_title_text", "new_str_0645")
    self.gray_img = self:findImage("gray_img")
    self:refreshUI()
end

function M:refreshUI()
    self:updateListScroll()
end

function M:updateListScroll()
    local data = self.m_model.m_list_data
    local all_cell_size = {}
    for i,v in ipairs(data or {}) do
        if v.visible == true then
            all_cell_size[i] = Vector2(710.8, 324)
        else
            all_cell_size[i] = Vector2(710.8, 223)
        end
    end
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            all_cell_size = all_cell_size,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                self:listHandle(cell_object, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, index)
            end,
            ui_name = self.m_uiName
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data,true, all_cell_size)
    end
end

function M:listHandle(obj, id, data)
    local luaBehaviour = obj:GetComponent("LuaBehaviour")
    local des_panel = luaBehaviour:FindGameObject("des_panel")
    local hero_panel = luaBehaviour:FindGameObject("hero_panel")

    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", data.cfg.name or "")
    UIUtil.destroyAllChild(hero_panel.transform)
    for i,v in ipairs(data.cfg.hero or {}) do
        local hero_data = {RewardUtil.REWARD_TYPE_KEYS.HEROS, v, 1}
        local hero_icon = GameUtil:creatBaseHeroCell(hero_data,handler(self,self.heroClickShow))
        hero_icon.transform:SetParent(hero_panel.transform,false)
        hero_icon.transform.localScale = Vector3(0.8,0.8,0.8)
        local scrollRectClick=hero_icon.transform:GetComponent("ScrollRectClick")
        scrollRectClick.enabled=false
        if self.m_model:getHeroActivationFlag(v) == 0 then
            local hero_luaBehaviour = hero_icon:GetComponent("LuaBehaviour")
            local count_node = hero_luaBehaviour:FindGameObject("count_node")
            local canvas_group = count_node:GetComponent("CanvasGroup")
            LuaBehaviourUtil.setObjectVisible(hero_luaBehaviour, "weihuode_img", true)
            canvas_group.alpha = 0.5
        end
    end
    local rect = obj:GetComponent("RectTransform")
    local cell_bg = luaBehaviour:FindGameObject("cell_bg")
    local bg_rect = cell_bg:GetComponent("RectTransform")
    local open_img = luaBehaviour:FindGameObject("open_img")
   
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "reward_red_point_img", data.receive_state == 1)
    if data.visible then
        des_panel:SetActive(true)
        local des = Language:getTextByKey("new_str_0646")..":   " .. data.cfg.text or ""
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "des_text", des)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "collect_text", "new_str_0647",data.collect_num,#data.cfg.hero)
        local ItemNode = luaBehaviour:FindGameObject("ItemNode")
        local function getreward()
            if data.receive_state == 1 then
                self:updateMsg("reward_click", id)
            elseif data.receive_state == 0 then
                GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_0692"), delay_close = 2})    
            end
        end
        local ui_element = GameUtil:updateItemElement(ItemNode,data.cfg.reward[1], true, false,getreward)
        if data.receive_state == 2 then
            ui_element.item_img.material = self.gray_img.material
            ui_element.quality_img.material = self.gray_img.material
        else
            ui_element.item_img.material = nil
            ui_element.quality_img.material = nil
        end
        open_img.transform.localRotation = Quaternion.Euler(0,0,180);
        rect.sizeDelta = Vector2(rect.rect.width, 324)
        bg_rect.sizeDelta = Vector2(rect.rect.width, 288)
    else
        des_panel:SetActive(false)
        open_img.transform.localRotation = Quaternion.Euler(0,0,0);
        rect.sizeDelta = Vector2(rect.rect.width, 223)
        bg_rect.sizeDelta = Vector2(rect.rect.width, 186)
    end
end

function M:heroClickShow(click_object, click_name, idx, data, hero_cfg)
    self.m_control:openView("Pops.HeroLookInfo", {hero_id = data and data.data_id or hero_cfg.id, is_new = false})
end

return M