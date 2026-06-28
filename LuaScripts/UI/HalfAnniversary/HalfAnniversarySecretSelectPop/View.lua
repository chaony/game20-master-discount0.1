local M = class("GiftScrollSelectPopView", LikeOO.OOPopBase)

M.m_uiName = "GiftBag/GiftScrollSelectPop"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("common_title_text", "gf_str_0066")
    self:setTextByLanKey("main_title_text", "gf_str_0067")
	self:refreshUI()
    if self.m_scroll_view ~= nil then
        if self.m_model.m_select_big_id == 0 then
            self.m_scroll_view:moveToCellIndex(1)
        else
            local reward_tab = self.m_model:getBigReward()
            local index = 1
            for k,v in pairs(reward_tab) do
                if v.reward_id == self.m_model.m_select_big_id then
                    index = k
                end
            end
            self.m_scroll_view:moveToCellIndex(index)  
        end
    end
end

function M:refreshUI()
    self:createLoopScroll()
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    self.m_gift_tab = {}
    local data = self.m_model:getBigReward()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            one_line_count = 6, 
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self.m_gift_tab[index] = cell_obj
                self:updateTimItem(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "ItemNode" and cell_data.level <= self.m_model.m_floor then
                    self:updateMsg("select_reward", cell_data.reward_id)
                end
            end,
            ui_name = self.m_uiName,
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data, true)
    end
end

function M:updateTimItem(index, obj, cell_data)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    local cell_text = UIUtil.findText(obj.transform, "cell_text")
    local big_reward = self.m_model:getRewardById(cell_data.reward_id)
    local data = big_reward.reward[1]
    local get_num = self.m_model:checkBigRcvd(cell_data.reward_id)
    if LuaBehaviour then
        GameUtil:updateItemElement(obj, data, true, cell_data.level > self.m_model.m_floor)
        if cell_data.level > self.m_model.m_floor then
            cell_text.text = Language:getTextByKey("gf_str_0044", cell_data.level)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lock_image", true)
            UIUtil.setObjectVisible(obj.transform, false, "light_img")
        else
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lock_image", false)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "duigoudi_img", false)  
            UIUtil.setObjectVisible(obj.transform, cell_data.reward_id == self.m_model.m_select_big_id, "light_img")
            if get_num and get_num > 0 then
                if (cell_data.reward_num - get_num) >= 0  then
                    cell_text.text = (cell_data.reward_num - get_num).."/"..cell_data.reward_num
                    if (cell_data.reward_num - get_num) == 0 then
                        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "duigoudi_img", true)  
                    end
                else
                    cell_text.text = "0/"..cell_data.reward_num  
                    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "duigoudi_img", true)  
                end
            else
                cell_text.text = cell_data.reward_num.."/"..cell_data.reward_num
            end
        end
    end
    local check_btn = UIUtil.findButton(obj.transform,"check_btn")
    local function clickCallback(_, cell_data)
        self:updateMsg("check_btn", {dataTable = data, obj = obj} )
    end
    UIUtil.setButtonClick(check_btn.transform,clickCallback, cell_data)
end


function M:destroy()
    M.super.destroy(self)
end

return M