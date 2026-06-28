local M = class("ServiceNpcGuideView",LikeOO.OOPopBase)

M.m_uiName = "Xian/ServiceNpcGuide"
M.m_size_type = 2

function M:create()
    M.super.create(self)
end

function M:onEnter()
    self.select_tab = {}
    self:setObjectVisible("open_mask", false)
    self:setTextByLanKey("common_title_text", "gf_str_0090")
    self.select_item = nil
    self.itemNode = self:findGameObject("itemList")
    self.base_obj_fitter = self.itemNode:GetComponent("ContentImmediate")
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
    --self:creatList()
    self:creatBookScroll()
    self.base_obj_fitter:ForceRefreshSize()
end

function M:creatBookScroll()
    self.itemNode = {}
    local data = self.m_model:getNpcGuideTab()
    local all_cell_size = {}
    for k,v in pairs(data) do
        if self.select_tab[k] then
            all_cell_size[k]= Vector2(self.select_tab[k], 556)
        else
            all_cell_size[k]= Vector2(104, 556)
        end
    end
    if self.bk_list_scroll == nil then
		local list_scroll = self:findGameObject("loopscroll")
		local params = {
			ui_name = self.m_uiName,
            show_data = data,
            all_cell_size = all_cell_size,
			loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                self.itemNode[index] = cell_object
                self:listHandle(index, cell_object, cell_data)
			end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                local get_bl, guide_cfg = self.m_model:getNpcGuideData(cell_data)
                if click_name == "little_bg" then
                    local bl_1,bl_2 = self.m_model:checkLockSort(cell_data)
                    if bl_2 == false then
                        local get_bl, guide_cfg = self.m_model:getNpcGuideData(cell_data)
                        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0121", guide_cfg.unlock_days)..Language:getTextByKey(guide_cfg.name), delay_close = 2})
                        return
                    end
                    local jump = ConfigManager:getCfgByName("jump")
                    local jump_item = jump[guide_cfg.go_type[1]]
                    local open_flag, tips_str = BtnOpenUtil:isBtnOpen(jump_item.open_condition_id)
                    if open_flag == false then
                        GameUtil:lookInfoTips(self.m_control, {msg = tips_str, delay_close = 2})
                        return
                    end
                    self:clickLitter(index)
                elseif click_name == "big_bg" then
                    self:clickBig(index)
                elseif click_name == "big_icon" then
                    local go_type = guide_cfg.go_type or {}
                    if _G.next(go_type) then
                        self:updateMsg("go_to", go_type)
                    end
                end
			end
		}
		self.bk_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.bk_list_scroll:reloadData(data, true, all_cell_size)
	end
end

function M:listHandle(index, obj, id)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj.transform)
    local get_bl, guide_cfg = self.m_model:getNpcGuideData(id)
    if luaBehaviour and guide_cfg then
        if self.select_tab[index] and self.select_tab[index] == 295 then
            local little_bg = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "little_bg", false)
            local big_bg = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "big_bg", true) 
        else
            local little_bg = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "little_bg", true)
            local big_bg = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "big_bg", false) 
        end

        if self.select_tab[index+1] and self.select_tab[index+1] == 295 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "right_shadow", true)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "right_shadow", false)
        end
        local cur_stage = UserDataManager:getCurStage()
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title", guide_cfg.name)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "big_title_text", guide_cfg.name)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "big_count_text", guide_cfg.des)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_open_text", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_open_day_text", false)
        LuaBehaviourUtil.setImg(luaBehaviour, "big_icon", guide_cfg.icon, "active_ui")
        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"reward_get", false)
        local itemNode = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "itemNode", false)
        if get_bl == true then
            -- 已领
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"reward_obj", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"lock_obj", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"reward_get", true)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_get_text", "new_str_0080")
        else
            if self.m_model:checkOpenById(id) == true then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour,"reward_obj", true)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour,"lock_obj", false)
                --可领
                local item = GameUtil:createItemElement(guide_cfg.reward[1], true, nil, function ()
                    self:updateMsg("get_reward", id)
                end)
                GameUtil:creatCommonItemEffect(itemNode, 6, 0.8)
                UIUtil.setLocalScale(item.transform, 0.8, 0.8)
                item.transform:SetParent(itemNode.transform, false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "itemNode", true)
            else
                LuaBehaviourUtil.setObjectVisible(luaBehaviour,"reward_obj", false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour,"lock_obj", true)
                local bl_1,bl_2 = self.m_model:checkLockSort(id)
                --待开启    
                local str = Language:getTextByKey(guide_cfg.dialogue1)
                str = string.gsub(str, "-", "︱")
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_open_text", str)
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_open_day_text", "gf_str_0121", guide_cfg.unlock_days)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_open_text", bl_1 == false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_open_day_text", bl_2 == false)
                if bl_2 == false then
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_open_text", false)
                end
            end
        end
    end
end

function M:clickLitter(index)
    local sele_item = self.itemNode[index]
    for k,v in pairs(self.select_tab) do
        self.select_tab[k] = 104
    end
    self.select_tab[index] = 295
    self.select_index = index
    local luaBehaviour = UIUtil.findLuaBehaviour(sele_item.transform)
    self:creatBookScroll()
    local data = self.m_model:getNpcGuideTab()
    --if index >= table.nums(data)-2 then
    --self.bk_list_scroll:moveToCellIndex(index)
    --end
end

function M:clickBig(index)
    local sele_item = self.itemNode[index]
    self.select_tab[index] = 104
    local luaBehaviour = UIUtil.findLuaBehaviour(sele_item.transform)
    self:creatBookScroll()
end

function M:openCheckDes(bl)
    if bl == false then
        if self.select_item then
            self:setWidth(self.select_item, 102.5)
            self.base_obj_fitter:ForceRefreshSize()
            local luaBehaviour = UIUtil.findLuaBehaviour(self.select_item.transform)
            if luaBehaviour then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "little_bg", true)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "big_bg", false)  
            end
        end
        self.select_item = nil
    end
    self:setObjectVisible("open_mask", bl)
end

function M:setWidth(obj, num)
    local m_rt = obj:GetComponent("RectTransform")
    local rect_width, rect_height = m_rt.rect.width, m_rt.rect.height
    rect_width = num
    m_rt.sizeDelta = Vector2(rect_width, rect_height) 
end

function M:setOrder(obj)
    local canvas = obj:GetComponent("Canvas")
    if not IsNull(canvas) then
        canvas.sortingOrder = self.m_sortOrder +1
    end
end


return M