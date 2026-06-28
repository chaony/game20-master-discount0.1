local M = class("DepositoryPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.SutraDepository.DepositoryPop.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "upgrade_btn" then
        local _,mystic_cfg =  self.m_model:getMysticData()
        local params = {}
        params.slot_id = mystic_cfg.type
        params.mystic_id = self.m_model.m_oid
        self:updateMsg("put_mystic", params, "SutraDepository")
        self:updateMsg("check_guide", nil, "SutraDepository")
        self:closeView()
    elseif msg == "promote_btn" then -- 参悟按钮
        --self:openView("SutraDepository.DepositoryPromotePop")
        local params = {}
        params.id = self.m_model.m_oid
        self:openView("SutraDepository",params)
        self:closeView()
    elseif msg == "remove_btn" then -- 卸下
        if self.m_model.m_mode == 3 then
            self:insetMysticDown()
        else
            self:heroMysticDown()
        end
    elseif msg == "replace_btn" then -- 替换
        if self.m_model.m_mode == 3 then
            self:replaceInsetMystic()
        else
            local params = {
                heroid = self.m_model.m_heroid,
                pos = self.m_model.m_pos,
                is_replace=true,
            }
            self:openView("HeroInfo.MeridianList", params) --穿戴秘籍
        end
        self:updateMsg(99999)
    elseif msg == "group_detail_btn" then
        local mystic_group = self.m_model:getMysticGroup()
        if mystic_group then
            self:openView("SutraDepository.DepositoryGropSkillTips", {id = self.m_model.m_oid})
        end
    elseif msg == "buy_btn" then
        if self.m_model.m_ok_call_func then
            self:updateMsg(99999)
            if self.m_model.m_ok_call_func then
                local params = {}
                if self.m_model.m_isToday then
                    params = {isToday = self.m_view.today_callback,cur_server_ts = self.m_view.cur_server_ts,reward_isOk = true}
                end
                self.m_model.m_ok_call_func(params)
            end
        end
    elseif msg == "today_btn" then
        self.m_view.today = not self.m_view.today
        self.m_view:todayIsActive()
    elseif msg == "inset_btn" then
        self:openView("SutraDepository", {id = self.m_model.m_oid})
        self:closeView()
    end
end

function M:putMysticRequest(params)
    if params then
        local function putCallback(response)
            --self.m_view:showEffect(response)
            self:openView("SutraDepository.DepositoryPopNode", {cur_m_oid=self.m_model.m_oid})
            --self:updateMsg("update_data", nil, "SutraDepository")
            audio:SendEvtUI("UI_MiJi_LevelUp")
        end
        self.m_model:getNetData("mystic_up_sta", params, putCallback)
    end
end

--英雄-卸下秘籍 hero_oid: 英雄唯一id pos: 位置，1-4
function M:heroMysticDown(callback)
    local params = {hero_oid = self.m_model.m_heroid, pos = self.m_model.m_pos}
    local function putCallback(response)
        self:updateMsg("update_mystic",{state = "down"},"HeroBag")
        if callback then
            callback()
        end
        self:updateMsg(99999)
    end
    self.m_model:getNetData("hero_mystic_down", params, putCallback)
end

------------------- 镶嵌相关 -----------------------------
-- 卸下镶嵌秘籍
function M:insetMysticDown()
    local params = {mystic_id = self.m_model.m_params.id, mystic_oid = self.m_model.m_mystic_data.oid, pos = self.m_model.m_pos - 1}
    local function putCallback(response)
        self:updateMsg("update_mystic",nil,"HeroBag")
        self:updateMsg("update_data",nil,"SutraDepository")
        self:updateMsg(99999)
    end
    self.m_model:getNetData("hero_mystic_inlay_take_off", params, putCallback)
end

-- 替换镶嵌秘籍
function M:replaceInsetMystic()
    local params = {}
    params.id = self.m_model.m_params.id
    params.mystic_data = self.m_model.m_params.mystic_data
    params.pos = self.m_model.m_pos
    self:openView("SutraDepository.DepositoryInsetPop", params)
end

return M
