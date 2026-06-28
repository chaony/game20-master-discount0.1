local M = class("NewFuncOpenControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Pops.NewFuncOpen.Guide"
    audio:SendEvtUI("UI_NewFunction")
end

function M:startGuide()
    --招募开启引导
    if self.m_model.m_function_id == 13 then --只有招募开启引导
        local have_guide = UserDataManager.guide_data:setAnyTeamGuide(59, 0)
        if have_guide then
            if self.m_guide then
                self.m_guide:start()
            end
        end
        return
    end
    --悟道开启引导
    if self.m_model.m_function_id == 9 then
        local have_guide = UserDataManager.guide_data:setAnyTeamGuide(29, 0)
        if have_guide then
            if self.m_guide then
                self.m_guide:start()
            end
        end
        return
    end
    --酒楼开启引导
    if self.m_model.m_function_id == 473 then
        local have_guide = UserDataManager.guide_data:setAnyTeamGuide(60, 0)
        if have_guide then
            if self.m_guide then
                self.m_guide:start()
            end
        end
        return
    end
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "continue_btn" then
        self:userGuideGoto(0)
    elseif msg == "ok_btn" then
        self:userGuideGoto(1)
    end
end

--一 -- 关卡解锁是否点击前往  config_id 引导组id action 0 未前往  1 前往
function M:userGuideGoto(action)
    local cfg = self.m_model:getFirstOpenFuncCfg()
    local guide_team = nil
    if cfg and cfg.guide_team then
        guide_team = cfg.guide_team
        local have_guide = UserDataManager.guide_data:setAnyTeamGuide(cfg.guide_team)
        --Logger.log(have_guide, "have_guide guide_team : " .. tostring(cfg.guide_team))
    end
    local function callfunc(response)
        if action == 1 then
            if self:hasChild("Settlement") then
                self:openView("Loading.SyncLoadBigLoading",  {isShowBg = true})
            end
            self:updateMsg(99999, { is_new_open_func = true }, "Settlement")
            if self.m_model.m_callback then
                self.m_model.m_callback()
            end
        end
        self:closeView()
    end
    self.m_model:getNetData("user_guide_goto", {config_id = guide_team, action = action}, callfunc)
end

return M