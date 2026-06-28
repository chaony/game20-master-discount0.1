local M = class("EquipmentPopControl",LikeOO.OOControlBase)

function M:onEnter()
    if SceneManager.curScene.showMove ~= nil then
        SceneManager.curScene.showMove:SetDepth(80)
    end
    audio:SendEvtUI("Play_UI_Popup_1")
    self.m_guide_file_name = "UI.HeroInfo.EquipmentPop.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if self.m_model.m_callback then
			self.m_model.m_callback()	
		end
        self:closeView()
    elseif msg == "get_off_btn" then   
		self:getOffEqp()
    elseif msg == "intensify_btn" then
        --self:updateMsg("open_levelup",{heroid = self.m_model.m_heroid, pos = self.m_model.m_pos},"HeroInfo")
        local params = {
			callback = function ()
                self:updateMsg("update_equip", nil, "HeroBag")
			end,
			data = {heroid = self.m_model.m_heroid, pos = self.m_model.m_pos}
		}
        self:openView("HeroInfo.EquipmentLevelUp", params)
        self:closeView()
    elseif msg == "replace_btn" then --替换装备
        local function cl()
            self:updateMsg(99999)
        end
        self:openView("HeroInfo.EquipmentList",{heroid = self.m_model.m_heroid, pos = self.m_model.m_pos, eqp_oid = self.m_model.m_eqp_id,callback = cl})	
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
    elseif msg == "heros_look_btn" then
        self:openView("Pops.LookRewardTips",{rewards = self.m_model:getHerosLookData(), look_model = 1})
    elseif msg == "recoin_btn" then
        self:openView("HeroInfo.EquipmentRecoinPop", { hero_oid = self.m_model.m_heroid, pos = self.m_model.m_pos })
    elseif msg == "levelup_btn" then
        self:openView("HeroInfo.EquipSubliming", { hero_oid = self.m_model.m_heroid, pos = self.m_model.m_pos })
        self:updateMsg(99999)
    elseif msg == "update_equip" then  
        self.m_view:refreshUI()
    elseif msg == "smelt_btn" then
        self:openView("HeroInfo.EquipmentSmeltingPop")
        self:updateMsg(99999)
    elseif msg == "today_btn" then
        self.m_view.today = not self.m_view.today
        self.m_view:todayIsActive()
    end
end

--英雄脱装备 hero_oid: 英雄唯一id equip_oid: 装备唯一id auto: 一键脱装, 0:脱指定装备，1：一键脱装
function M:getOffEqp()
    local function callfunc()
        self:updateMsg("update_equip", nil, "HeroBag")
        self:updateMsg(99999)
    end
    self.m_model:getNetData("hero_equip_down",{hero_oid = self.m_model.m_heroid, pos = self.m_model.m_pos}, callfunc)
end

function M:onDestroy()
    if SceneManager.curScene.showMove ~= nil then
        SceneManager.curScene.showMove:SetDepth(120)
    end
end

return M