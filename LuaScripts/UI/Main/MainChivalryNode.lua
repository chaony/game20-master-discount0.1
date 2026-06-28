--- 侠义
local M = class("MainChivalryNode",LikeOO.OOUIbase)

M.m_uiName = "Main/MainChivalryNode"
M.m_iphoneXAdapter = true

M.m_btn_lock_img = {
    [16] = {bnt_key = "bounty_btn"},--悬赏
    [18] = {bnt_key = "labyrinth_btn"},--轮回地牢
    [20] = {bnt_key = "pagoda_btn"},--锁妖塔    
    [31] = {bnt_key = "rpg_map_btn"},--神舟探秘
    [50] = {bnt_key = "boss_btn"},--世界boss
    [53] = {bnt_key = "lock_btn"},--四象浮屠
 }

function M:onCreate()
    self.m_sliding = false
	--self.m_luaBehaviour:UseFingersSliding(handler(self,self.fingerSliding))
end

function M:onEnter()
    self:setTextByLanKey("race_tower_text", "xy_str_0002")
    self:setTextByLanKey("tower_text", "xy_str_0005")
    self:setTextByLanKey("quest_text", "xy_str_0003")
    self:setTextByLanKey("hidden_text", "xy_str_0004")
    self:setTextByLanKey("boss_text", "xy_str_0001")
    self:setTextByLanKey("reward_text", "xy_str_0006")
    self:setTextByLanKey("close_title_text", "new_str_0362")
    self:refreshUI()
    audio:PauseSkillsBusVol()
    local scroll_view = self:findGameObject("Scroll View")
    local scroll_bar= self:findGameObject("Scrollbar")
    self.m_scroll_rect = scroll_view:GetComponent("ScrollRect")
    self.m_scroll_bar = scroll_bar:GetComponent("Scrollbar")
    if self.m_scroll_rect then
        self.m_scroll_rect.horizontalNormalizedPosition = 0
        --self.m_scroll_bar.onValueChanged:AddListener(handler(self,self.ValueChange));
    end
    local new_rate = self.m_control.m_view.m_bg_scale
    local m_1 = self:findGameObject("bg_img")
    if m_1 ~= nil then
        UIUtil.setLocalScale(m_1.transform, new_rate, new_rate)
    else
        Logger.logError(" MainChivalryNode 中的 m_1 是 nil ")
    end
end

function M:ValueChange(num)
    local city_lock = RedPointUtil:isFuncRedPointById(39)
    local grudge_lock = RedPointUtil:isFuncRedPointById(41)
    if num <= 0.05 and city_lock == true then
        self:setObjectVisible("change_last",true)
        self:setObjectVisible("change_next",false)
    elseif num >= 0.95 then
        self:setObjectVisible("change_last",false)
        self:setObjectVisible("change_next",true)
    else
        self:setObjectVisible("change_last",false)
        self:setObjectVisible("change_next",false)
    end
end

function M:refreshUI()
    local race_tower_status = self.m_model.m_data.race_tower_status or {} -- 种族开启状态 [种族类型], 有就开启
    local tower_race = ConfigManager:getCfgByName("tower_race")
    for k,v in pairs(tower_race) do
        local open_week = v.open_week or {}
        local open_flag = self.m_model:getRaceTowerOpenByRace(k)
        self:setObjectVisible("bottom_bg_" .. k, not open_flag)
        if not open_flag then
            self:setTextByLanKey("race_" .. k .. "_bottom_text", "new_str_0280", table.concat(open_week, "/"))
        end
    end
    self:setObjectVisible("MainChivalryNode_Show", false)
    self:refreshRedPoint()
    local city_lock = BtnOpenUtil:isBtnOpen(39)
    -- self:setObjectVisible("change_last", city_lock == true)
    self:setObjectVisible("change_last", false)
    local grudge_lock = BtnOpenUtil:isBtnOpen(41)
    -- self:setObjectVisible("change_next", grudge_lock == true)
    self:setObjectVisible("change_next", false)
end


function M:refreshRedPoint()
	for k, v in pairs({ { "labyrinth_btn_red_point", 3 }, { "bounty_btn_red_point", 27 }, { "rpg_red_point", 31 }, { "wordboss_red_point", 50 } }) do
		local red_flag = RedPointUtil:isFuncRedPointById(v[2])
		self:setObjectVisible(v[1], red_flag == true)
	end	
end

function M:show_Anim()
	self:setObjectVisible("MainChivalryNode_Show", true)
	self.m_luaBehaviour:RunAnim("MainChivalryNode_Show", nil, 1)
end

function M:jumpBuild(open_id)
    local build_cfg = self.m_btn_lock_img[open_id]
    if build_cfg then
        local map_scroll = self:findGameObject("Scroll View")
        local scroll_rect = map_scroll:GetComponent("ScrollRect")
        local viewport = self:findGameObject("Viewport")
        local view_rect = viewport.transform.rect
        local build = self:findGameObject(build_cfg.bnt_key)
        local parent = build.transform.parent
        local rect = parent.rect
        local posx = build.transform.localPosition.x
        local value = 0.5 + posx/(rect.width-view_rect.width*0.5)
        scroll_rect.horizontalNormalizedPosition = value
    end
end

function M:fingerSliding(locat)
    if not self.m_sliding then
        return
    end
    if self.m_control:checkHasChild() then
        return
    end
    if self.m_scroll_rect then
        local Nnn =  self.m_scroll_rect.horizontalNormalizedPosition
        if locat == true and Nnn < 0.05 then
            local check_lock = BtnOpenUtil:isBtnOpen(39)
            if check_lock == true then
                self:updateMsg("fingerSliding",2)  
            end
        elseif locat == false and Nnn > 0.95 then  
            local check_lock = BtnOpenUtil:isBtnOpen(41)
            if check_lock == true then
                self:updateMsg("fingerSliding",4)
            end
        end
    end
end

function M:destroy()
    audio:ResumeSkillsBusVol()
    M.super.destroy(self)
end

return M