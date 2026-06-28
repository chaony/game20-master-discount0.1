local M = class("AttendanceBonusView",LikeOO.OOPopBase)

M.m_uiName = "SecretStore/AttendanceBonusPop"
M.m_iphoneXAdapter = true
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("common_title_text","secret_store_text4")
    self:refreshUI()
end

function M:refreshUI()
    self:createLoopScroll()
end

function M:createLoopScroll()
    local data = self.m_model.reward_data
    local sort_data = {}
    for k,v in pairs(data) do
        table.insert(sort_data,{k,reward = v.reward})
    end
    table.sort(sort_data,function (a,b)
       return a[1] < b[1]
    end)

    local temp_data = {}
    local buy_data = {}
    for k,v in ipairs(sort_data) do
        if self.m_model:sortState(v[1]) then
            table.insert(buy_data,v)
        else
            table.insert(temp_data,v)
        end
    end

    for k,v in ipairs(buy_data) do
        table.insert(temp_data,v)
    end
    
    
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("rebate_loopscroll")
        local params ={
            show_data = temp_data,
            loop_scroll_object = loopscroll,
            update_cell =function(index, cell_obj, cell_data)
                self:updateCell(index,cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(cell_data[1])
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(temp_data, true)
    end
end

function M:updateCell(index,cell_obj,cell_data)
    local luaBehaiour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaiour then
        local name_text = luaBehaiour:FindText("text_stateText")
        local des_text = luaBehaiour:FindText("text_rechargeLevelText")
        local signinnums_text = luaBehaiour:FindText("text_signinnums")
        local get_text = luaBehaiour:FindText("get_Text")
        local state_text = luaBehaiour:FindText("state_Text")
        get_text.text = Language:getTextByKey("secret_store_text5")
        des_text.text =   Language:getTextByKey("secret_store_text13",cell_data[1])
        name_text.text = Language:getTextByKey("secret_store_text14")
        state_text.text = Language:getTextByKey("secret_store_text15")
        signinnums_text.text = self:richText(tostring(math.min( self.m_model.m_record_total_days, cell_data[1]))) .. "/" .. cell_data[1]
        local get = self.m_model:getRewardState(cell_data[1])
        local complete = self.m_model:getState(cell_data[1])
        
        LuaBehaviourUtil.setObjectVisible(luaBehaiour, "btn_receiveBtn",complete and not get)    
        
        LuaBehaviourUtil.setObjectVisible(luaBehaiour, "state_Text", not complete)
        LuaBehaviourUtil.setObjectVisible(luaBehaiour, "get_Btn", get)
        
        local parent = luaBehaiour:FindGameObject("itemParent")
        GameUtil:createRewards(parent.transform, cell_data.reward, true, true, nil)
    end
end

function M:richText(str)
    local rich_Text_Color_Left = "<color=#c6611e>"
    local rich_Text_Color_Right = "</color>"
    return rich_Text_Color_Left .. str .. rich_Text_Color_Right
end

function M:destroy()
    M.super.destroy(self)
end

return M