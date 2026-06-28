---@class HeroEchoNode
---@field m_model HeroBagModel
-- SP侠客共鸣
local M = class("HeroEchoNode", LikeOO.OOUIbase)

M.m_uiName = "HeroBag/HeroEchoNode"

function M:onEnter()
    self.m_collect_attrs_node = self:findGameObject("collect_attrs_node")
    self.m_attr_node = self:findGameObject("attr_node")
    self.m_gray_material = self:findImage("gray").material
    self:setTextByLanKey("attr_title_text", "echo_text_007")
    self:setTextByLanKey("skill_title_text", "echo_text_008")
    self:setTextByLanKey("goto_btn_text", "echo_text_002")
    self:refreshUI()
end

function M:refreshUI()
    self:refreshHeadNode()
end

function M:refreshHeadNode()
    local hero, cfg = self.m_model:getSelectHeroData()
    local itemData = RewardUtil:getProcessRewardData({ RewardUtil.REWARD_TYPE_KEYS.HEROS, hero.id, 1, self.m_model.m_currentHeroIndex })
    local node = self:findGameObject("hero_node")
    GameUtil:updateItemElementByData(node, itemData)
    GameUtil:updateHeroInfo(node, itemData)
    self:setTextByLanKey("hero_shili_text", cfg.name)

    local attrs, skills = self.m_model:getEchoParams()
    local echo_level = hero.resonance_lv or 0
    --属性
    self:updateLoopScroll(attrs, self.m_collect_attrs_node, self.m_attr_node, echo_level <= 0)
    --技能
    self:setObjectVisible("skill1", false)
    self:setObjectVisible("skill2", false)
    if skills then
        for i, v in pairs(skills) do
            self:refreshSkill(v, echo_level)
        end
    end
end

--[[	
	属性列表
]]
function M:updateLoopScroll(cur_attrs, parentNode, itemNode, is_gray)
    parentNode:SetActive(false)
    local attrs = UserDataManager:newAppendAttrs(cur_attrs)
    local data = {}
    for i, v in pairs(attrs) do
        table.insert(data, { i, v })
    end
    UIUtil.destroyAllChild(parentNode.transform)
    for k, cell_data in ipairs(data) do
        local cell_object = GameUtil:instanceObject(itemNode, parentNode.transform)
        cell_object:SetActive(true)
        local transform = cell_object.transform
        local attr_name_text = nil
        local attr_value_text = nil
        local cp = UserDataManager:getNewAttrsNameByAttrId(cell_data[1])
        attr_name_text = UIUtil.setText(transform, cp, "attr_name_text")
        -- 四舍五入保留小数点后一位
        local attr_value = cell_data[2] or 0
        attr_value = math.floor(attr_value * 100 + 0.5) / 100
        if GameUtil:newAttrTransition(cell_data[1]) == true then
            attr_value_text = UIUtil.setText(transform, GameUtil:formatNum(attr_value) .. "%", "attr_value_text")
        else
            attr_value_text = UIUtil.setText(transform, GameUtil:formatNum(attr_value), "attr_value_text")
        end
        local attr_value_text_trans = UIUtil.findRectTransform(attr_value_text)
        UIUtil.setLocalPosition(attr_value_text_trans, attr_name_text.preferredWidth + 20)
        if is_gray then
            --attr_name_text.color = Color.New(1,1,1, 0.6)
            attr_value_text.color = Color.New(1,1,1, 0.6)
        else
            --attr_name_text.color = Color.New(1,1,1, 1)
            attr_value_text.color = Color.New(1,1,1, 1)
        end
    end
    parentNode:SetActive(true)
end

function M:refreshSkill(param, echo_lv)
    local index = param.index
    local lv = param.lv
    local object = self:findGameObject("skill" .. index)
    if object == nil then
        return
    end
    object:SetActive(true)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local icon_img = LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", param.icon, "skill_icon")
    local desc = ""
    if echo_lv < lv then
        desc = Language:getTextByKey(param.name) .. Language:getTextByKey("echo_text_006", lv) .. "\n" .. Language:getTextByKey(param.des)
        icon_img.material = self.m_gray_material
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img", true)
    else
        desc = Language:getTextByKey(param.name) .. "\n" ..Language:getTextByKey(param.des)
        icon_img.material = nil
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img", false)
    end
    LuaBehaviourUtil.setText(luaBehaviour,"desc_text", desc)
    --  添加监听
    --[[local params = {skill_id = skillID}
    local skill_detail = LuaBehaviourUtil.findGameObject(luaBehaviour,"icon_img")
    local function btnClick2(trans, params)
        params.click_obj = trans
        self:updateMsg("skill_detail", params)
    end
    UIUtil.setButtonClick(skill_detail.transform, btnClick2, params)]]--
end

function M:destroy()
    M.super.destroy(self)
end

return M