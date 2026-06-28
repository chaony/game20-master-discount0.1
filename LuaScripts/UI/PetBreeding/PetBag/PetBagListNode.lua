---@class PetBagListNode: OOUIbase
---@field m_model PetBagModel
local M = class("PetBagListNode", LikeOO.OOUIbase)

M.m_uiName = "PetBreeding/PetBagListNode"

local Page_Cell_Num = 12

function M:onEnter()
    self.m_select_pet_obj = nil
    self.m_pet_list = {}
    self.m_timer_text_list = {}
    self:bindUI()
    self:refreshUI()
    self:bindSortFunc()
end

function M:InitType(c_type, first)
    if c_type == 1 then
        self.m_rt.gameObject:SetActive(true)
        local move_x = self.m_model:getCurMoveX(-370.5, self.m_control.m_view.m_view_width)
        if first == false then
            GameUtil:dotweenMoveX(self.m_rt.gameObject, move_x)
        else
            self.m_rt.localPosition = Vector3.New(move_x, 0, 0)
        end
        self:updatePetsScroll()
    elseif c_type == 2 then
        local move_x = self.m_model:getCurMoveX(-877, self.m_control.m_view.m_view_width)
        if first == false then
            local callback = function()
                self.m_rt.gameObject:SetActive(false)
            end
            GameUtil:dotweenMoveX(self.m_rt.gameObject, move_x, callback)
        else
            self.m_rt.localPosition = Vector3.New(move_x, 0, 0)
            self.m_rt.gameObject:SetActive(false)
        end

    end
end

function M:bindSortFunc()
    self:setObjectVisible("sort_penel_go", false)
    for i=1, 3 do
        local btn_item = self:findGameObject("btn_sort_" .. i)
        UIUtil.setButtonClick(btn_item, function()
            self.m_control:SortDataList(i)
        end)
    end
end

function M:refreshUI()
    self:updatePetsScroll()
    self:refreshPetNum()
end

function M:updateTime()
    self:refreshCellTimer()
end

function M:bindUI()
    self.empty_go = self:findGameObject("empty_tips")
    self:setTextByLanKey("empty_tips", "pet_bag_text_0017")
    
    self:setTextByLanKey("txt_sort_1", "pet_qishow_text_01")
    self:setTextByLanKey("txt_sort_2", "pet_qishow_text_02")
    self:setTextByLanKey("txt_sort_3", "pet_qishow_text_03")
end

function M:sliderTop()
    if self.m_list_scroll ~= nil then
        local data = self.m_model.m_pet_list
        if #data > 0 then
            local index = self.m_model:getPetIndexByOid(self.m_model.m_sel_pet_oid) or 1
            self.m_list_scroll:moveToCellIndex(index)
        end
    end
end

function M:sliderTopFirstIndex()
    if self.m_list_scroll ~= nil then
        local data = self.m_model.m_pet_list
        if #data > 0 then
            self.m_list_scroll:moveToCellIndex(1)
        end
    end
end


function M:refreshPetNum()
    local c_num, max_num = self.m_model:getPetNum()
    local num_text = Language:getTextByKey("new_str_0430", c_num .. "/" .. max_num)
    self:setText("pet_num", num_text)
end

--左右切换选中状态
function M:updateSelectPet()
    if self.m_select_pet_obj then
        local LuaBehaviour = UIUtil.findLuaBehaviour(self.m_select_pet_obj)
        if LuaBehaviour then
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img2", false)
        end
        local temp_obj = nil
        for k, v in pairs(self.m_pet_list) do
            if self.m_model.m_sel_pet_oid == k then
                temp_obj = v
                break
            end
        end
        if not IsNull(temp_obj) then
            local temp_LuaBehaviour = UIUtil.findLuaBehaviour(temp_obj)
            if temp_LuaBehaviour then
                LuaBehaviourUtil.setObjectVisible(temp_LuaBehaviour, "select_img2", true)
            end
            self.m_select_pet_obj = temp_obj
        end
    end
    --self:sliderTop()
end

function M:updatePetsScroll()
    local data = self.m_model.m_pet_list
    if #data <= 0 or not self.m_model.m_sel_pet_oid then
        self.empty_go:SetActive(true)
        self:setObjectVisible("Viewport",false)
        return
    end
    self.empty_go:SetActive(false)
    self:setObjectVisible("Viewport",true)
    self.m_select_pet_obj = nil
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("pets_scroll")
        local list_canvas_group = list_scroll:GetComponent("CanvasGroup")
        list_canvas_group.blocksRaycasts = false
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 3,
            loop_scroll_object = list_scroll,
            init_cell = function(index, cell_object)
                local function callback()
                    local cell_data = self.m_list_scroll.m_show_data[index]
                    if cell_data then
                        local itemNode, luaBehaviour = GameUtil:createPetElement(cell_data, cell_object.transform, true, true, nil, 1.357, true, true)
                        itemNode.name = "cell_content"
                        itemNode.transform:SetAsFirstSibling()
                        self.m_pet_list[cell_data] = itemNode
                        self:listHandle(cell_data, luaBehaviour, itemNode, cell_object)
                        itemNode:SetActive(true)
                        local canvas_group = itemNode:GetComponent("CanvasGroup")
                        canvas_group.blocksRaycasts = false
                    else
                        local itemNode, luaBehaviour = GameUtil:loadPetElement(cell_object.transform, 1.357)
                        itemNode:SetActive(false)
                        itemNode.name = "cell_content"
                        itemNode.transform:SetAsFirstSibling()
                        local canvas_group = itemNode:GetComponent("CanvasGroup")
                        canvas_group.blocksRaycasts = false
                    end

                    if (index == Page_Cell_Num) or (index < Page_Cell_Num and index == #data) then
                        list_canvas_group.blocksRaycasts = true
                    end
                end
                if index <= Page_Cell_Num then
                    self.m_control:setOnceTimer(0.01 * index or 0, callback)
                else
                    callback()
                end
            end,
            update_cell = function(index, cell_object, cell_data)
                local content_tran = UIUtil.findTrans(cell_object.transform, "cell_content")
                if not IsNull(content_tran) then
                    self.m_pet_list[cell_data] = content_tran
                    content_tran.gameObject:SetActive(true)
                    local luaBehaviour = UIUtil.findLuaBehaviour(content_tran)
                    GameUtil:updatePetElementInfo(cell_data, content_tran.gameObject, true, true)
                    self:listHandle(cell_data, luaBehaviour, content_tran, cell_object)
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                local content_tran = UIUtil.findTrans(cell_object.transform, "cell_content")
                if content_tran then
                    if index ~= self.m_model.m_sel_pet_index then
                        if self.m_model:checkIsEgg(cell_data) and self.m_model.m_sel_tab_index == 2 then
                            GameUtil:lookInfoTips(self.m_control, { msg = Language:getTextByKey("pet_bag_text_0033"), delay_close = 2 })
                            return
                        end
                        if not IsNull(self.m_select_pet_obj) then
                            local LuaBehaviour = UIUtil.findLuaBehaviour(self.m_select_pet_obj)
                            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img2", false)
                        end
                        if self.m_model:checkIsHaveRed(cell_data) then
                            local luaBehaviour_cell = UIUtil.findLuaBehaviour(cell_object)
                            self.m_model:removeRedList(cell_data)
                            LuaBehaviourUtil.setObjectVisible(luaBehaviour_cell, "img_red_point", false)
                        end
                        self.m_select_pet_obj = content_tran
                        local LuaBehaviour = UIUtil.findLuaBehaviour(self.m_select_pet_obj)
                        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_img2", true)
                        self:updateMsg("select_pet", { id = cell_data, index = index, isClick = true })
                    end
                end
            end,
            ui_name = self.m_uiName,
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data, true)
        self:sliderTop()
    end
end

function M:listHandle(oid, luaBehaviour, obj, cell_object)
    if oid == self.m_model.m_sel_pet_oid then
        self.m_select_pet_obj = obj
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img2", true)
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_img2", false)
    end
    local luaBehaviour_cell = UIUtil.findLuaBehaviour(cell_object)
    local time_go = luaBehaviour_cell:FindGameObject("pet_level_text_bg")
    local time_text = luaBehaviour_cell:FindText("pet_level_text")
    local team_go = luaBehaviour_cell:FindGameObject("team_img")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour_cell, "team_text", "pet_bag_text_0043")
    local is_have_red = self.m_model:checkIsHaveRed(oid)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour_cell, "img_red_point", is_have_red)
    time_go:SetActive(false)
    if self.m_model:checkIsEgg(oid) then
        local icon = self.m_model:getEggIcon(oid)
        time_go:SetActive(true)
        local curTime = UserDataManager:getServerTime()
        local endTime = self.m_model:getEggEndTime(oid)
        local diffTime = endTime - curTime
        if diffTime >= 0 then
            local time_str = GameUtil:formatTimeBySecond(diffTime, 999)
            time_text.text = time_str
        end
        LuaBehaviourUtil.setImg(luaBehaviour, "pet_icon", icon, "main_ui2")
        self.m_timer_text_list[cell_object] = { oid = oid, time_text = time_text, text_go = time_go }
    end

    
    --local skill_node = luaBehaviour_cell:FindGameObject("skill_node")
    --local isInTeam = self.m_model:checkInTeam(oid)
    --team_go:SetActive(isInTeam)
    --skill_node:SetActive(not isInTeam)
    --if not isInTeam then
    --    local killer_res, killer_icon_str = self.m_model:getKillerSkillQualityBgById(oid)
    --    LuaBehaviourUtil.setObjectVisible(luaBehaviour_cell, "killer_skill_img", killer_res)
    --    if killer_res then
    --        LuaBehaviourUtil.setImg(luaBehaviour_cell, "killer_skill_img", killer_icon_str, "main_ui2")    
    --    end
    --
    --    local helper_res, helper_icon_str = self.m_model:getHelperSkillQualityBgById(oid)
    --    LuaBehaviourUtil.setObjectVisible(luaBehaviour_cell, "helper_skill_img", helper_res)
    --    if helper_res then
    --        LuaBehaviourUtil.setImg(luaBehaviour_cell, "helper_skill_img", helper_icon_str, "main_ui2")
    --    end
    --end
end

function M:refreshCellTimer()
    for k, v in pairs(self.m_timer_text_list) do
        if self.m_model:checkIsEgg(v.oid) then
            local curTime = UserDataManager:getServerTime()
            local endTime = self.m_model:getEggEndTime(v.oid)
            local diffTime = endTime - curTime
            if diffTime >= 0 then
                local time_str = GameUtil:formatTimeBySecond(diffTime, 999)
                v.time_text.text = time_str
            else
                v.text.text_go:SetActive(false)
            end
            
        end
    end
end

return M