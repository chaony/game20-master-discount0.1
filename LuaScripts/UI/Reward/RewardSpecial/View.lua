local M = class("RewardSpecialView",LikeOO.OOPopBase)

M.m_uiName = "Reward/RewardHeroSpecialPop"
M.m_size_type = 2

function M:onEnter()	
    self.m_gray_image = self:findImage("gray_img")
    self:setTextByLanKey("common_title_text", "bounty_str_0014")
    self:refreshUI()
end

function M:refreshUI()
    self:updateScroll()
    self:updateDecs_Scroll()
end

function M:updateScroll()
    local data = self.m_model:getLeftTab()--[self.m_model.m_bounty_lv]
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                self:setCellHander(cell_object, data, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("select_bounty", index)
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data, true)
    end
end

local lv1_node = "Reward/reward_award_node"
local lv2_node = "Reward/tiao_node_duan"
local lv3_node = "Reward/tiao_node_chang"
local lv4_node = "Reward/reward_two_node"
local lv5_node ="Reward/lv3_tiao_node"

function M:setCellHander(obj, cur_cfg, index)
    local cfg = cur_cfg--[index][self.m_model.m_bounty_lv][index]
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local cur_data = self.m_model:getLockData(index) or 0
    local duigoudi_img = luaBehaviour:FindGameObject("duigoudi_img")
    local up_image = luaBehaviour:FindGameObject("up_image")
    local lock_img = luaBehaviour:FindGameObject("lock_img")
    local name_text = luaBehaviour:FindText("name_text")
    name_text.text = Language:getTextByKey(cfg.name)
    local max_num = self.m_model:getTaskNums(index)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "schedule_value_text", cur_data.."/"..max_num)
    LuaBehaviourUtil.setImg(luaBehaviour, "cell_icon", cfg.reward_show, "item_icon")
    for i = 1,7 do
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_"..i, cfg.star >=i)
    end
    if index == self.m_model.m_select_index then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light_img", true)
    else
       LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light_img", false)
    end
end

function M:updateDecs_Scroll()
    local table_cfg = self.m_model:getLeftTab()
    local cfg = table_cfg[self.m_model.m_bounty_lv][self.m_model.m_select_index]
    if cfg == nil then
        cfg = table_cfg[self.m_model.m_select_index]
    end
    self:setTextByLanKey("reward_name", cfg.name)
    local data =  self.m_model:getCurTabCfg()
    if self.m_desc_list_scroll == nil then
        local list_scroll = self:findGameObject("node_list_scroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                self:setCellValueHander(cell_object, cell_data, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "" then
                    
                end
            end,
        }
        self.m_desc_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_desc_list_scroll:reloadData(data)
    end
end

function M:setCellValueHander(obj, data, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        for k,v in ipairs(data) do
            local cell = luaBehaviour:FindGameObject("obj_"..k)
            cell:SetActive(v~=0)
            if v ~= 0 then
                self:updateBountyCellData(cell, v, index, k)
            end
        end
    end
end


function M:updateBountyCellData(object, id, index, k_index)
    local cfg = self.m_model:getBountyCfg(id)
    local LuaBehaviour = UIUtil.findLuaBehaviour(object)
    if LuaBehaviour then
        local top_lint = LuaBehaviour:FindGameObject("top_lint")
        local last_top_lint = LuaBehaviour:FindGameObject("last_top_lint")
        local last_bg_img = LuaBehaviour:FindGameObject("last_bg_img")
        local bottom_line = LuaBehaviour:FindGameObject("bottom_line")
        local bg_img = LuaBehaviour:FindGameObject("bg_img")
        local select_effect = LuaBehaviour:FindGameObject("select_effect")
        local suo = LuaBehaviour:FindGameObject("suo")
        local last_bg_bian = LuaBehaviour:FindGameObject("last_bg_bian")
        
        top_lint:SetActive(false)
        last_top_lint:SetActive(false)
        last_bg_img:SetActive(false)
        bottom_line:SetActive(false)
        select_effect:SetActive(false)
        last_bg_bian:SetActive(false)
        suo:SetActive(false)
        for i = 1,4 do
            local right_ = LuaBehaviour:FindGameObject("right_"..i)
            local left_ = LuaBehaviour:FindGameObject("left_"..i)
            right_:SetActive(false)
            left_:SetActive(false)
        end
        local name_text = LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "item_name_text", cfg.name)
        local itemNode = LuaBehaviour:FindGameObject("ItemNode")
        local itemEffect = LuaBehaviour:FindGameObject("itemEff")
        local function callback(obj, data)
            if obj ~= nil then
                local params = {
                    click_transform = obj.transform,
                    quest_id = id,
                    data = self.m_model:getAllLockConditions(id),
                    parent = self
                }
                GameUtil:lookBountyTips(self.m_control, params)
                audio:SendEvtUI("Play_UI_Tab")
            end
        end
        

        local cur_activate = self.m_model:bountyActivate(id)
        GameUtil:updateItemElement(itemNode, cfg.reward_show[1], false, false, callback)
        local item_LuaBehaviour = UIUtil.findLuaBehaviour(itemNode)
        if item_LuaBehaviour then
            if cfg.reward[1][1] == 301 then
                LuaBehaviourUtil.setImg(item_LuaBehaviour, "item_img", "DJ_tongqian", "item_icon")
            end
            local icon = item_LuaBehaviour:FindImage("item_img")
            local quality_img = item_LuaBehaviour:FindImage("quality_img")
            local duigoudi_img = item_LuaBehaviour:FindGameObject("duigoudi_img")
            if cur_activate == true then
                --icon.material = nil
                --quality_img.material = nil
                select_effect:SetActive(true)
                suo:SetActive(false)
            else
                --icon.material = self.m_gray_image.material
                suo:SetActive(true)
                --quality_img.material = self.m_gray_image.material
                select_effect:SetActive(false)
            end
            local accomplish = self.m_model:checkQuest(id)
      
            duigoudi_img:SetActive(accomplish )
           
            if accomplish then
                select_effect:SetActive(false)
            end

        end
        local bounty_icon = LuaBehaviour:FindImage("bounty_icon")
        if cur_activate == true then
            bounty_icon.material = nil
            --name_text.material = nil
        else
            bounty_icon.material = self.m_gray_image.material
            --name_text.material = self.m_gray_image.material
        end
        if index == 1 then
            local b_activate = self.m_model:checkBottonActivate(id, index)
            bottom_line:SetActive(true)
            self:updateLight(bottom_line, b_activate)
        else
            local pos_tab = self.m_model:getLastPos(id, index)
            local have_index = self.m_model:getIndexed(id, index)
            bottom_line:SetActive(have_index == true)
            if have_index == true then
                local b_activate = self.m_model:checkBottonActivate(id, index)
                self:updateLight(bottom_line, b_activate)
            end
            if self.m_model:checkFinalReward(id) == true then -- 是否为最终奖励
                last_top_lint:SetActive(true)
                last_bg_img:SetActive(true)
                last_bg_bian:SetActive(true)
                self:updateLight(last_top_lint, cur_activate)
                bg_img.transform.localPosition = Vector3(0,-32,0)
            else
                top_lint:SetActive(true)
                self:updateLight(top_lint, cur_activate)
                bg_img.transform.localPosition = Vector3(0,-15,0)
            end
       
            for k,v in pairs(pos_tab) do
                local last_pos = v
                if last_pos ~= -1 then
                    local diff = k_index - last_pos
                    local diff2 = last_pos - k_index
                    if diff >= 1 then
                        local left_ = LuaBehaviour:FindGameObject("left_"..diff)
                        left_:SetActive(true)
                        self:updateLight(left_, cur_activate)
                    elseif diff == 0 then
                    else
                        local right_ = LuaBehaviour:FindGameObject("right_"..diff2) 
                        right_:SetActive(true)
                        self:updateLight(right_, cur_activate)
                    end
                end
            end
        end
    end
end

function M:updateLight(obj, bl)
    --UIUtil.setObjectVisible(obj.transform, bl, "light_img")
    -- UIUtil.setObjectVisible(obj.transform, bl, "light_dian")
end

function M:createObj(name,parent)
    local obj = ResourceUtil:LoadUIGameObject(name,Vector3.zero,parent)
    return obj
end

return M