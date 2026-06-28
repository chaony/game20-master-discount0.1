local M = class("HeavenBlessSelectRewardPopView", LikeOO.OOPopBase)

M.m_uiName = "GiftBag/HeavenBlessSelectRewardPop"
M.m_size_type = 2
function M:onEnter()
    self.item_list = { 
        [1] = {}, --甲级
        [2] = {}, --乙级
    }
    self:refreshUI()
    self:setTextByLanKey("text_ok","new_str_0315")
end

function M:refreshUI()
    self:setObjectVisible("unUse", false)

    self:refreshList()
    self:refreshGroupTitle()
end

function M:refreshList()
    local data1 = self.m_model:getRewardCfgDataByLevel(1)
    local data2 = self.m_model:getRewardCfgDataByLevel(2)

    self:InitScrollView(self.scrollView1, data1, 1)
    self:InitScrollView(self.scrollView2, data2, 2)
end

function M:InitScrollView(scrollView, data, num)
    if scrollView == nil then
        local loopscroll = self:findGameObject("scroll_levelRewarditem" .. num)
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:refreshItem(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "infoBtn" then
                    local awardData = RewardUtil:getProcessRewardData(cell_data.reward[1])
                    local data_type = awardData.data_type
                    if data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
                        if awardData.oid then
                            static_rootControl:openView("HeroInfo.EquipmentPop", { equip_id = awardData.oid })
                        else
                            static_rootControl:openView("HeroInfo.EquipmentPop", { equip_cfg_id = awardData.data_id, look_model = 3 })
                        end
                    elseif data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
                        static_rootControl:openView("Item.ItemDetail", { show_data = awardData, display = true }, nil, true)
                    elseif data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT or data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS_EXT then
                        static_rootControl:openView("Pops.HeroLookInfo", { hero_id = awardData.data_id, is_new = false })
                    elseif data_type == RewardUtil.REWARD_TYPE_KEYS.HERO_SKIN then
                        static_rootControl:openView("Pops.HeroSkinLookInfo", { is_new = false, skin_id = awardData.data_id })
                    elseif data_type == RewardUtil.REWARD_TYPE_KEYS.MYSTIC then
                        static_rootControl:openView("SutraDepository.DepositoryPop", { oid = awardData.data_id, mode = 2 })
                    elseif data_type == RewardUtil.REWARD_TYPE_KEYS.TITLE then
                        static_rootControl:openView("Title.TitleDetail", { show_data = awardData, display = true })
                    else
                        static_rootControl:openView("Pops.CommonItemTipsPop", { data = awardData, target_obj = cell_object })
                    end
                end
            end
        }
        scrollView = LoopScrollViewUtil.new(params)
    else
        scrollView:reloadData(data)
    end
end

function M:switchSelectId(id, cell_obj)

end

function M:refreshItem(index, cell_obj, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaviour then
        local selectItemObj = luaBehaviour:FindGameObject("selectNode")
        --selectItemObj:SetActive(self:checkSelectRewardListHas(cell_data.id))
        self.item_list[cell_data.level][index] = luaBehaviour
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "infoBtn", true)
        GameUtil:updateItemElement(cell_obj, cell_data.reward[1], true, false, function()
            
            if cell_data.level == 1 then
                if self.m_model.select_reward_list[1] == nil then
                    self.m_model.select_reward_list[1] = cell_data.id
                    selectItemObj:SetActive(true)
                else
                    if self.m_model.select_reward_list[1]== cell_data.id then
                        self.m_model.select_reward_list[1] = nil
                        selectItemObj:SetActive(false)
                    end
                end
            end
            if cell_data.level == 2 then
                for i = 2, 3 do
                    if self.m_model.select_reward_list[i] == nil and not self:checkSelectRewardListHas(cell_data.id) then
                        self.m_model.select_reward_list[i] = cell_data.id
                        selectItemObj:SetActive(true)   --设置已选择图标
                        break
                    elseif self.m_model.select_reward_list[i] == cell_data.id then
                        self.m_model.select_reward_list[i] = nil
                        selectItemObj:SetActive(false)
                        break
                    end
                end
                
            end
            self:refreshGroupTitle()
        end)
        
    end
end

function M:refreshGroupTitle()
    self:setTextByLanKey("text_levelNodeTitle1","gf_str_0145") --甲级
    self:setTextByLanKey("text_levelNodeTitle2","gf_str_0146") --乙级

    local totalNum = self:getSelectRewardListLevelNum(1) + self:getSelectRewardListLevelNum(2)
    local txt = Language:getTextByKey("gf_str_0144") .."(" .. totalNum .."/3)"
    self:setTextByLanKey("text_levelNodeTitle",txt )
    
    self:setTextByLanKey("text_levelNodeNum1" , self:getSelectRewardListLevelNum(1) .. "/1")
    self:setTextByLanKey("text_levelNodeNum2" , self:getSelectRewardListLevelNum(2) .. "/2")
    
end

--已选择的奖励列表是否包含rewardId
function M:checkSelectRewardListHas(rewardId)
    for i, v in pairs(self.m_model.select_reward_list) do
        if rewardId == v then 
            return true    
        end
    end
    return false
end

function M:getSelectRewardListLevelNum(levelNum)
    local result = 0
    if levelNum == 1 then 
        result = self.m_model.select_reward_list[1] and 1 or 0   
    end
    
    if levelNum == 2 then
        for i = 2, 3 do
           result = result + (self.m_model.select_reward_list[i] and 1 or 0)
        end

    end
    return result
end

return M














