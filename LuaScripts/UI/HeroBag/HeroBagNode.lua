--- 逸闻
local M = class("HeroBagNode", LikeOO.OOUIbase)

M.m_uiName = "HeroBag/HeroBagNode"
M.m_iphoneXAdapter = true

local BASE_TAB = {
    {1, 2},
    {3},
    {6},
    {7},
    {8},
    {9},
    {10}
}

function M:onEnter()
    self.skillImproveGroup = ConfigManager:getCfgByName("skill_improve_group")
    local gray = self:findImage("gray")
    self.gray_mat = gray.material
    self.base_obj = self:findGameObject("base_obj")
    self.base_obj_fitter = self.base_obj:GetComponent("ContentImmediate")
    self.base_info_content = self:findGameObject("base_info_text")
    self.base_info_arrow = self:findGameObject("base_info_arrow")
    self.anecdote_content = self:findGameObject("anecdote_content")
    self.base_info_show = true
    self.anecdote = {}
    self:refreshUI()
end

function M:refreshUI()
    self:setBaseInfo()
    self:setDescInfo()
    --触发刷新自适应大小
    self.base_obj_fitter:ForceRefreshSize()
end

function M:setBaseInfo()
    local h_cfg = self.m_model:getCurHeroCfg()
    self:setTextByLanKey("base_info_title_text", "new_str_0578")
    self:setTextByLanKey("base_info_text", h_cfg.life)
    self.base_info_arrow.transform.localEulerAngles = Vector3.New(0, 0, -90)
    --for k,v in pairs(BASE_TAB) do
    --	local info_bg = self.base_info_content.transform:GetChild(k-1)
    --	if info_bg then
    --		local LuaBehaviour = UIUtil.findLuaBehaviour(info_bg)
    --		local bg_img = UIUtil.findImage(info_bg)
    --		bg_img.enabled = k%2 == 0
    --		if LuaBehaviour then
    --			if #v > 1 then
    --				LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"cell_title_2", true)
    --				LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"cell_count_2", true)
    --				local title1, count1 = self.m_model:getBaseInfoCellByIndex(v[1])
    --				LuaBehaviourUtil.setTextByLanKey (LuaBehaviour,"cell_name_1",count1)
    --				LuaBehaviourUtil.setTextByLanKey (LuaBehaviour,"cell_title_1",title1)
    --				local title2, count2 = self.m_model:getBaseInfoCellByIndex(v[2])
    --				LuaBehaviourUtil.setTextByLanKey (LuaBehaviour,"cell_count_2",count2)
    --				LuaBehaviourUtil.setTextByLanKey (LuaBehaviour,"cell_title_2",title2)
    --			else
    --				local title, count = self.m_model:getBaseInfoCellByIndex(v[1])
    --				LuaBehaviourUtil.setTextByLanKey (LuaBehaviour,"cell_name_1",count)
    --				LuaBehaviourUtil.setTextByLanKey (LuaBehaviour,"cell_title_1",title)
    --			end
    --		end
    --	end
    --end
    --if h_cfg then
    --	local num = self.base_info_content.transform.childCount
    --	for i=1,num do
    --  	  	local info_bg = self.base_info_content.transform:GetChild(i-1)
    --		local title, count = self.m_model:getBaseInfoCellByIndex(i)
    --		UIUtil.setTextByLanKey(info_bg,"cell_title_text",title)
    --		UIUtil.setTextByLanKey(info_bg,"cell_count_text",count)
    --	end
    --end
end

function M:setDescInfo()
    local num = self.anecdote_content.transform.childCount
    self.tab_list = {}
    for i = 1, num do
        self.anecdote[i] = {}
        local info_bg = self.anecdote_content.transform:GetChild(i - 1)
        local LuaBehaviour = UIUtil.findLuaBehaviour(info_bg)
        if LuaBehaviour then
            local count_text = LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "hero_info_text", self.m_model:getAncedoteDescByIndex(i))
            self.anecdote[i]["content"] = LuaBehaviour:FindGameObject("content")
            self.anecdote[i]["skill"] = LuaBehaviour:FindGameObject("skill" .. i .. "_btn").transform
            self.anecdote[i]["arrow"] = LuaBehaviour:FindGameObject("arrow").transform
            self.anecdote[i]["show"] = true
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "cell_info_text", self.m_model:getAncedotName(i))
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "arrow", true)
            self.anecdote[i]["arrow"].localEulerAngles = Vector3.New(0, 0, -90)
            if self.m_model:checkAncedoteOpenByIndex(i) == true then
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lock", false)
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "content", true)
                
                ---关闭技能部分
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "skill", false)
                --local anecdote_skill = self.m_model:getAncedoteSkillByIndex(i)
                --if anecdote_skill ~= 0 then
                --    self:setSkillInfo(LuaBehaviour, anecdote_skill)
                --else
                --    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "skill", false)
                --end
            else
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "arrow", false)
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lock", true)
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "content", false)
            end
            local RGBA = Color.New(245 / 255, 209 / 255, 129 / 255)
            local RGBB = Color.New(0.8, 0.8, 0.8)
        --count_text.color = self.m_model:checkAncedoteOpenByIndex(i) == true and  RGBA or RGBB
        end
        table.insert(self.tab_list, info_bg)
    end
end

function M:setSkillInfo(LuaBehaviour, anecdote_skill)
    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "skill", true)
    local skill = self.skillImproveGroup[anecdote_skill]
    LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "skill_name", skill.name)
    local icon = LuaBehaviourUtil.setImg(LuaBehaviour, "skillIcon", "a_ui_currency_jineng_linshi", "hero_ui")
    local skill_improve = self.m_model:getSKillImprove()
    if skill_improve ~= nil and table.indexof(skill_improve.groups, anecdote_skill) ~= false then
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "goto_btn", false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "skill_lock_text", false)
        if skill_improve.cur_id == anecdote_skill then
            icon.material = nil
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "skill_state", "anecdote_selected")
        else
            icon.material = self.gray_mat
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "skill_state", "anecdote_no_select")
        end
    else
        icon.material = self.gray_mat
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "skill_state", "anecdote_lock")
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "goto_btn", true)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "skill_lock_text", true)
    end
end

function M:showBaseInfo()
    self.base_info_show = self.base_info_show == false
    self.base_info_content:SetActive(self.base_info_show)
    if self.base_info_show == true then
        self.base_info_arrow.transform.localEulerAngles = Vector3.New(0, 0, -90)
    else
        self.base_info_arrow.transform.localEulerAngles = Vector3.New(0, 0, 0)
    end
end

function M:anecdoteOnClick(index)
    if self.m_model:checkAncedoteOpenByIndex(index) == true then
        self.anecdote[index]["show"] = self.anecdote[index]["show"] == false
        self.anecdote[index]["content"]:SetActive(self.anecdote[index]["show"])
        --触发刷新自适应大小
        self.base_obj_fitter:ForceRefreshSize()
        if self.anecdote[index]["show"] == true then
            self.anecdote[index]["arrow"].localEulerAngles = Vector3.New(0, 0, -90)
        else
            self.anecdote[index]["arrow"].localEulerAngles = Vector3.New(0, 0, 0)
        end
    else
        local h_cfg = self.m_model:getSelectHeroData()
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_0577", Language:getTextByKey(GlobalConfig.HERO_QUALITY_COMMON_SETTING[index + h_cfg.evo].name)), delay_close = 2})
    end
end

function M:skillOnClick(index)
    local anecdote_skill = self.m_model:getAncedoteSkillByIndex(index)
    if anecdote_skill ~= 0 then
        self.m_control:openView("Pops.SkillImprovePop", {skill_improve = anecdote_skill, click_transform = self.anecdote[index]["skill"]})
    end
end

return M
