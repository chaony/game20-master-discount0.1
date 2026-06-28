---@class SkillPopView:OOPopBase
---@field m_model SkillPopModel
local M = class("SkillPopView", LikeOO.OOPopBase)

M.m_uiName = "Pops/SkillPop"
M.m_size_type = 2

function M:onEnter()
    self:refreshUI()
end

function M:refreshUI()
    local contentNode = self:findGameObject("content_node")
    if self.m_model.m_is_ordinary_skill == 1 or self.m_model.m_is_ordinary_skill == 2 or self.m_model.m_is_ordinary_skill == 4 then --天命化星技能
        self:setTextByLanKey("title_text", self.m_model.m_title_text)
        self:setTextByLanKey("skill_text", self.m_model.m_skill_text)
        self:setObjectVisible("levelup_text", false)
    else
        local sk = self.m_model:getSkill()
        if self.m_model:getSkillCurLv() > 0 then
            local sk_name = Language:getTextByKey(sk.name)
            self:setTextByLanKey("title_text", sk_name)
        else
            local sk_name = Language:getTextByKey(sk.name)
            self:setTextByLanKey("title_text", sk_name)
        end
        self:setTextByLanKey("skill_text", self.m_model:getSkillBaseDesc(1))
        self:setTextByLanKey("levelup_text", self.m_model:getSkillDesc())
        self:setObjectVisible("levelup_text", true)
    end
    if self.m_model.m_click_transform then
       self:initSetPos()
    else
        UIUtil.setLocalPosition(contentNode.transform, 138 + (89 * self.m_model.m_skill_index - 1), -100, 0)
    end
    -- self:setObjectVisible("combat_text", false)
    -- self:setObjectVisible("combat_num", false)
    self:setObjectVisible("skill_improve", false)
end

function M:initSetPos()
    local contentNode = self:findGameObject("content_node")
    contentNode.transform.localPosition =  Vector3.New(10000,10000,0)
    local pos = self.content_node.transform.parent:InverseTransformPoint(self.m_model.m_click_transform.position)
    local content_w, content_h = 380, 20
    local width, height = self.m_rt.rect.width, self.m_rt.rect.height
    pos.y = math.max(math.min(pos.y, height * 0.5 - content_h * 0.5), -height * 0.5)
    pos.x = math.max(math.min(pos.x, width * 0.5 - content_w * 0.5), -width * 0.5 + content_w * 0.5)
    self.m_control:setOnceTimer(0.1, function ()
		local cont_rect = contentNode:GetComponent("RectTransform")
		if self.m_model.m_pivot then
			local d_pos = Vector3.New(pos.x, pos.y, pos.z) 
			if self.m_model.m_pivot.x ~= 0.5 then
				if self.m_model.m_pivot.x == 0 then
					d_pos.x = pos.x + content_w / 2
				elseif self.m_model.m_pivot.x == 1 then
					d_pos.x = pos.x - content_w / 2
				end
			end
			if self.m_model.m_pivot.y ~= 0.5 then
				local height = cont_rect.rect.height
				if self.m_model.m_pivot.y == 0 then
                    d_pos.y = pos.y - (height / 2)
				elseif self.m_model.m_pivot.y == 1 then
					d_pos.y = pos.y + (height / 2)
				end
			end
			contentNode.transform.localPosition = d_pos
		end
	end)
end





function M:setSkillImprove()
    self.skillImproveGroup = ConfigManager:getCfgByName("skill_improve_group")
    self.skillImproveTable = ConfigManager:getCfgByName("skill_improve")
    self.skillImprove = UserDataManager.skillImprove_data.m_skillImprove[self.m_model.m_hero_id]
    self.skill_improve_id = self:getSkillImproveId()

    local skill = self.skillImproveGroup[self.skill_improve_id]
    if skill ~= nil then
        self:setObjectVisible("skill_improve", true)

        self:setTextByLanKey("skill_name", skill.name)
        self:setTextByLanKey("des_text", skill.des)
        self:setImg("a_ui_currency_jineng_linshi", "hero_ui", "skillIcon")

        self:setSkillImproveState(self.skillImprove.cur_id == self.skill_improve_id)
    else
        self:setObjectVisible("skill_improve", false)
    end
end

function M:getSkillImproveId()
    if self.skillImprove ~= nil and self.skillImprove.groups ~= nil then
        for k1, v1 in pairs(self.skillImprove.groups) do
            for k2, v2 in pairs(self.skillImproveGroup[v1]["id"]) do
                local skill_id = self.skillImproveTable[v2]["skill_id"]
                for k3, v3 in pairs(self.m_model.m_skill) do
                    if skill_id == v3[1] then
                        return v1
                    end
                end
            end
        end
    end
    return 0
end

function M:onButtonClick(obj, name)
    M.super.onButtonClick(self, obj, name)
    if name == "select_btn" then
        local tips = Language:getTextByKey("anecdote_skill_tips", Language:getTextByKey(self.skillImproveGroup[self.skillImprove.cur_id].name))
        local params = {
            on_ok_call = function(msg)
                local function callfunc()
                    --UserDataManager.skillImprove_data:setCurId(self.m_model.m_hero_id, self.skill_improve_id)
                    self:setSkillImproveState(false)
                end
                self.m_model:getNetData("choose_improve", {hero_id = self.m_params.heroId, group_id = self.m_params.groupId}, callfunc)
            end,
            tow_close_btn = true,
            text = tips
        }
        self.m_control:openView("Pops.CommonPop", params, nil, true)
    end
end

function M:setSkillImproveState(select)
    if select then
        self:setTextByLanKey("select_text", "anecdote_selected")
        local btn = self:findButton("select_btn")
        btn.interactable = false
    else
        self:setTextByLanKey("select_text", "anecdote_select")
    end
end

return M
