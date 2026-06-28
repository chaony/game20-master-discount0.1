local M = class("PetFactoryAddFoodPopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "close_btn" or msg == "big_close_btn" then
        self:closeView()
    elseif msg == "ok_btn" then -- 使用道具
        if self.m_model.m_idle_start_time <= 0 then
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pet_factory_text_0027"), delay_close = 2 })
        else
            self:useItem()
        end
    elseif msg == "max_btn" then -- 使用道具
        if self.m_model.m_max_num <= 0 then
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pet_factory_text_0030"), delay_close = 2 })
            return
        end
        
        self.m_model:addUseNumMax()
        if self.m_view then
            self.m_view:updateUseNum()
        end
    elseif msg == "minus_one_btn" then
        self.m_model:addUseNum(-1)
        if self.m_view then
            self.m_view:updateUseNum()    
        end
    elseif msg == "add_one_btn" then
        self.m_model:addUseNum(1)
        if self.m_view then
            self.m_view:updateUseNum()
        end
    end
end

-- 投喂
function M:useItem()
    local num = self.m_model:getNum()
    local inputNum = self.m_view:getSearchText()
    if inputNum == "" or inputNum == "-" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0546"), delay_close = 2})
        return
    end
    if num <= 0 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0546"), delay_close = 2})
        return
    end

    -- 投喂超出数量溢出时，弹出提示
    local isOverflow = num > self.m_model.m_best_num
    if isOverflow then
        local params =
        {
            on_ok_call = function(msg)
                local function callback(response)
                    response.tag = "pet_factory_add_food"
                    self:updateMsg("pet_factory_update_ui", response, "PetBreeding.PetFactoryPop")
                    self:notifyGetPetIndexData()
                    self:closeView()
                end

                print("[REQ _ADD_FOOD]" .. table.dump({num = self.m_model.m_num}, true, 5))
                self.m_model:getNetData("pet_factory_add_food", {num = self.m_model.m_num}, callback)
            end,
            text = Language:getTextByKey("pet_factory_text_0022"),
            ok_text = Language:getTextByKey("pet_factory_text_0023"),
            cancel_text = Language:getTextByKey("pet_factory_text_0024"), 
        }
        self:openView("Pops.CommonPop", params)  
    else
        local function netCallback(response)
            response.tag = "pet_factory_add_food"
            self:updateMsg("pet_factory_update_ui", response, "PetBreeding.PetFactoryPop")
            self:notifyGetPetIndexData()
            self:closeView()
        end
        
        print("[REQ _ADD_FOOD]" .. table.dump({num = self.m_model.m_num}, true, 5))
        self.m_model:getNetData("pet_factory_add_food", {num = self.m_model.m_num}, netCallback)
    end
end

-- 通知刷新数据
function M:notifyGetPetIndexData()
    self:updateMsg("update_pet_index", nil, "PetBreeding.PetBreedingMain")
end

return M
