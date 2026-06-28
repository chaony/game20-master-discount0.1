--- 恩怨
local M = class("MainGrudgeNode",LikeOO.OOUIbase)

M.m_uiName = "Main/MainGrudgeNode"
M.m_iphoneXAdapter = true

M.m_btn_lock_img = {
    [24] = {bnt_key = "arena_normal"},--演武擂台
    [25] = {bnt_key = "arena_higher_order"},--江湖论剑
    [64] = {bnt_key = "arena_peak"},--剑荡九州    
    [53] = {bnt_key = "lock_btn"},--逐鹿天下
 }

function M:onEnter()
    self.m_sliding = false
    --self.m_luaBehaviour:UseFingersSliding(handler(self,self.fingerSliding))
	self:refreshUI()
    audio:PauseSkillsBusVol()
    local new_rate = self.m_control.m_view.m_bg_scale
    local m_1 = self:findGameObject("bg_img")
    UIUtil.setLocalScale(m_1.transform, new_rate, new_rate)
end

function M:refreshUI()
	local arena_info = self.m_model.m_data.arena_info or {}
	self:setTextByLanKey("title_text_1", "ey_str_0003")
	self:setTextByLanKey("title_text_2", "ey_str_0006")
	self:setTextByLanKey("title_text_3", "ey_str_0001")
	self:setTextByLanKey("title_text_4", "ey_str_0002")
	self:setTextByLanKey("close_title_text", "new_str_0363")
    self:refreshRedPoint()
    local scroll_view = self:findGameObject("Scroll View")
    local scroll_bar = self:findGameObject("Scrollbar")
    self.m_scroll_rect = scroll_view:GetComponent("ScrollRect")
    self.m_scroll_bar = scroll_bar:GetComponent("Scrollbar")
    if self.m_scroll_rect then
        self.m_scroll_rect.horizontalNormalizedPosition = 0
        --self.m_scroll_bar.onValueChanged:AddListener(handler(self,self.ValueChange));
    end
    local chivalry_lock = BtnOpenUtil:isBtnOpen(40)
    -- self:setObjectVisible("change_last", chivalry_lock == true)
    self:setObjectVisible("change_last", false)
end

function M:ValueChange(num)
    local chivalry_lock = RedPointUtil:isFuncRedPointById(40)
    if num <= 0.05 then
        self:setObjectVisible("change_last",true)
    else
        self:setObjectVisible("change_last",false)
    end
end

function M:switchTabNode(index)

end

function M:refreshRedPoint()
	for k, v in pairs({ { "arena_normal_red_point", 24 }, { "arena_higher_red_point", 34 }, { "arena_peak_red_point", 64 }, { "wordboss_red_point", 50 } }) do
		local red_flag = RedPointUtil:isFuncRedPointById(v[2])
		self:setObjectVisible(v[1], red_flag == true)
	end	
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
        local chivalry_lock = BtnOpenUtil:isBtnOpen(40)
        if chivalry_lock == true and locat == true and Nnn < 0.05 then
            self:updateMsg("fingerSliding",3)
        end
    end
end

function M:destroy()
	audio:ResumeSkillsBusVol()
    M.super.destroy(self)
end

return M