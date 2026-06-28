local M = class("WorldMapGuideControl",LikeOO.OOControlBase)

function M:onEnter()
	
end

function M:onHandle(msg , data)
	if msg == 99999 or msg == "CloseBtn" then    -- 返回
		self:closeView()
    elseif msg == "shouye_btn" then
        self:excuteGoTOAction(1)
    elseif msg == "jianghu_btn" then
        self:excuteGoTOAction(33)
    elseif msg == "go_to" then
        audio:SendEvtUI("UI_Go")
        self:excuteGoTOAction(data)
	end
end

function M:excuteGoTOAction(func_id)
    if func_id then
        local jump = ConfigManager:getCfgByName("jump")
        local jump_item = jump[func_id]
        if jump_item then
            local open_condition_id = jump_item.open_condition_id or 0
            local open_flag, tips_str = BtnOpenUtil:isBtnOpen(open_condition_id)
            if open_flag == true then
                if func_id == 24 then --论剑山庄
                    if self:checkLunJianShanZhangGoToMain() then
                        func_id = 37
                    end
                elseif func_id == 32 then --天机楼
                    local race_open_flag = BtnOpenUtil:isBtnOpen(73)
                    if race_open_flag == true then
                        func_id = 86
                    end
                elseif func_id == 18 then --闯王宝藏
                    local function netDataCallBack(response)
                        if response.finish == 0 and response.cells ~= nil and _G.next(response.cells) ~= nil then
                            self:goTo({18, response})
                        else
                            self:goTo({38, response})
                        end
                    end
                    self.m_model:getNetData("maze_index", nil, netDataCallBack);
                    return
                end
                self:goTo(func_id)
            else
                GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
            end
        end
    end
end

function M:goTo(data)
    data = data or {}
    if type(data) == "number" then
        data = {data}
    end
    if self.m_model:isInSceneNow(data[1]) == false then
        local not_close_tab = {["Loading.SyncLoadBigLoading"] = 1, ["Loading.SmallLoading"] = 1, ["Loading.BattleLoading"] = 1, ["Loading.BigLoading"] = 1}
        local view_name = self.m_model:getViewName(data[1])
        if view_name then
            not_close_tab[view_name] = 1
        end
        local time_before_close_parent = 0.3
        if data[1] == 1 then --返回主页
            if self.m_model.m_pop_from_func_id == 33 then --从江湖
                time_before_close_parent = 0.15
            else 
                time_before_close_parent = 0.2
            end
        end
        local function callbackFunc()
            self:updateMsg("close_btn" ,nil ,"parent") --单独用来关掉事务node
            static_rootControl:closeAllViewPop(not_close_tab)
        end
        self:setOnceTimer(time_before_close_parent, callbackFunc)
        QuickOpenFuncUtil:openFunc(data)
    else
        self:closeView()
    end
end

function M:checkLunJianShanZhangGoToMain()
    if self.m_model:checkLunJianShanZhuangSubOpen() then
        return true
    end
    return false
end

function M:checkTianJiLouGoToMain()
    if self.m_model:checkTianJiLouSubOpen() == true then
        return true
    end
    return false
end

return M