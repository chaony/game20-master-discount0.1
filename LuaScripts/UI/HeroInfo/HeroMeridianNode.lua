--- 经脉
local M = class("HeroMeridianNode",LikeOO.OOUIbase)

M.m_uiName = "HeroInfo/HeroMeridianNode"

M.RenMai = "UI_HeroInfo_RenMai_001" --任脉激活特效
M.DuMai = "UI_HeroInfo_DuMai_001" --督脉激活特效
M.QiJing = "UI_HeroInfo_QiJing_001" --奇经激活特效
M.QiHai = "UI_HeroInfo_QiHai_001" --气海 （可激活经脉的特效）
M.JuQi = "UI_HeroInfo_JuQi_001" --聚气 --（激活经脉的特效）

--M.m_iphoneXAdapter = true
function M:onEnter()
    self.m_cur_qihai = nil
    self.gray = self:findImage("gray")
    self:refreshUI()    
    self:setTextByLanKey("activate_text", "激活")
    self:setTextByLanKey("intensify_text", "冲击穴道")
    local function callback()
        self:setObjectVisible("skill_content", false)
    end
    self.m_control:setOnceTimer(0.1, callback)
    local function callback()
        self:setObjectVisible("skill_content", true)
    end
    self.m_control:setOnceTimer(0.15, callback)
end

function M:refreshUI(bl)
    local atr_1, atr_2 = self.m_model:getMeridianAttrs()
    self:updateLoopScroll(atr_1, atr_2)
    self:setObjectVisible("activate_btn", not self.m_model.sig_active)
    self:setObjectVisible("intensify_btn", self.m_model.sig_active)
    if self.m_model:checkMaxSig() == true then
        self:setObjectVisible("activate_btn", false)
        self:setObjectVisible("icon_node", false)
        self:setObjectVisible("intensify_btn", false)
    end
    self:setObjectVisible("un_show_1", true)
    self:setObjectVisible("un_show_2", true)
    self:setObjectVisible("un_show_3", true)
    self.cur_active_effect = self.RenMai
    if self.m_model.sig_lv >= 30 then
        GameUtil:setLanImgText(self:findRectTransform("left_title_img"), "a_ws_jm_title_qijing")
        self.pass = self:findGameObject("points_3")
        self.light_point_name = "a_ws_jm_qijing_yikai"
        self.light_pass_name = "a_ws_jm_qijing_xian"
        self:setObjectVisible("un_show_1", false)
        self:setObjectVisible("un_show_2", false)
        self:setObjectVisible("un_show_3", false)
        self.cur_active_effect = self.QiJing
    elseif self.m_model.sig_lv >= 20 then
        GameUtil:setLanImgText(self:findRectTransform("left_title_img"), "a_ws_jm_title_qijing")
        self.pass = self:findGameObject("points_3")
        self.light_point_name = "a_ws_jm_qijing_yikai"
        self.light_pass_name = "a_ws_jm_qijing_xian"
        self:setObjectVisible("un_show_1", false)
        self:setObjectVisible("un_show_2", false)
        self.cur_active_effect = self.QiJing
    elseif self.m_model.sig_lv >= 10 then
        GameUtil:setLanImgText(self:findRectTransform("left_title_img"), "a_ws_jm_title_dumai")
        self.pass = self:findGameObject("points_2")
        self.light_point_name = "a_ws_jm_dumai_yikai"
        self.light_pass_name = "a_ws_jm_dumai_xian"
        self:setObjectVisible("un_show_1", false)
        self.cur_active_effect = self.DuMai
    else
        GameUtil:setLanImgText(self:findRectTransform("left_title_img"), "a_ws_jm_title_renmai")
        self.pass = self:findGameObject("points_1") 
        self.light_point_name = "a_ws_jm_renmai_yikai"
        self.light_pass_name = "a_ws_jm_renmai_xian"
        self.cur_active_effect = self.RenMai
    end
    self:setPass()
    self:setCons()
    self:updateSkill()
    self:setSpine()
end

function M:setCons()
    self.m_icon_node = self:findGameObject("icon_node")
    local cost = self.m_model.sig_nextdata.levelup_cost
    if self.cost_item ~= nil then
        GameUtil:updateItemElement(self.cost_item, cost[1], false, true)
    else
        self.cost_item = GameUtil:createItemElement(cost[1], false, true)
    end
    self.cost_item.transform:SetParent(self.m_icon_node.transform, false)
    local data_special = RewardUtil:getProcessRewardData(cost[1])
    local need_num = cost[1][3]
    local cur_num = data_special.user_num
    local luaBehaviour = UIUtil.findLuaBehaviour(self.cost_item)
    local str = need_num.."/"..cur_num
    local text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "count_text", str)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"count_text",true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"count_text_bg_img",true)
end

function M:setPass()
    self:setObjectVisible("points_1", false)
    self:setObjectVisible("points_2", false)
    self:setObjectVisible("points_3", false)
    self.pass:SetActive(true)
    local index = self.m_model:getPassNumByIndex()
    local num = self.pass.transform.childCount
	for i=1, num do
        local pass_cell = self.pass.transform:GetChild(i-1)
        local luaBehaviour = UIUtil.findLuaBehaviour(pass_cell)
        local cell_data = self.m_model:getPassNameByIndex(i - 1)
        local tx_parent = luaBehaviour:FindGameObject("point_icon")
        if tx_parent then
            UIUtil.destroyAllChild(tx_parent.transform)
        end
        if luaBehaviour then
            local pass_name = LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"pass_name", cell_data.lv_name)
        end
        if self.m_model.sig_active == true and i < index then
            --LuaBehaviourUtil.setImg(luaBehaviour, "point_icon", self.light_point_name, "hero_ui")
            LuaBehaviourUtil.setImg(luaBehaviour, "pass_img", self.light_pass_name, "hero_ui")
            if tx_parent then
                self:creatEffect(self.cur_active_effect, tx_parent)
            end
        elseif self.m_model.sig_active == true and i == index then
            self.m_cur_qihai = tx_parent
            --LuaBehaviourUtil.setImg(luaBehaviour, "point_icon", "a_ws_jm_daikai", "hero_ui")  
            LuaBehaviourUtil.setImg(luaBehaviour, "pass_img", "a_ws_jm_xian", "hero_ui") 
            if tx_parent then
                self:creatEffect(self.QiHai, tx_parent)
            end
        else    
            --LuaBehaviourUtil.setImg(luaBehaviour, "point_icon", "a_ws_jm_weikai", "hero_ui")
            LuaBehaviourUtil.setImg(luaBehaviour, "pass_img", "a_ws_jm_xian", "hero_ui")
        end
    end
end

--[[	
	属性列表
]]
function M:updateLoopScroll(attrs, next_attrs)
	local tab = {}
    for i, v in pairs(attrs) do
        if next_attrs then
            if next_attrs[i] ~= nil then
                table.insert(tab, {v[1], v[2], next_attrs[i][2]})
            else
                table.insert(tab, {v[1], v[2], 0})     
            end
            
        else
            table.insert(tab, {v[1], v[2], 0})
        end
    end
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("attr_loopscroll")
        local params = {
            show_data = tab,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:setProCell(cell_object, cell_data)
            end,
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(tab)
    end
end

function M:setProCell(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local cp = GameUtil:getAttrsName(GameUtil:getAttrsKey(data[1]))
        local value2 = self.m_model:getAttrByBaseOn(data)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attr_name_text", cp)
        local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
        local hero_enumeration_item = hero_enumeration[data[1]]
        if hero_enumeration_item.base_on_id ~= 0 then
            local attr_value = data[2] * 100 or 0
            local attr_value2 = data[3] * 100 or 0
            local attr_value_text = LuaBehaviourUtil.setText(luaBehaviour, "num_1", "+"..GameUtil:formatNum(attr_value).."%")
            local attr_value2_text = LuaBehaviourUtil.setText(luaBehaviour, "num_2", "+"..GameUtil:formatNum(attr_value2).."%")
        else
            local attr_value = data[2] or 0
            attr_value = math.floor(attr_value * 10 + 0.5)/10
            local attr_value_text = LuaBehaviourUtil.setText(luaBehaviour, "num_1", "+"..GameUtil:formatNum(attr_value))
            local attr_value2 = data[3] or 0
            attr_value2 = math.floor(attr_value2 * 10 + 0.5)/10
            local attr_value2_text = LuaBehaviourUtil.setText(luaBehaviour, "num_2", "+"..GameUtil:formatNum(attr_value2))
            if attr_value2 == 0 then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num_2", false)
            else
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num_2", true)
            end
        end
    end
end

function M:updateSkill()
    if self.m_model.sig_cfg then
        self:setTextByLanKey("cur_skill_desc", self.m_model.sig_data.des1)
        self:setTextByLanKey("progress1_desc", self.m_model.sig_data.des2)
        self:setTextByLanKey("progress2_desc", self.m_model.sig_data.des3)
        self:setTextByLanKey("progress3_desc", self.m_model.sig_data.des4)
        self:setTextByLanKey("progress1_name", "任脉圆满")
        self:setTextByLanKey("progress2_name", "督脉圆满")
        self:setTextByLanKey("progress3_name", "融会贯通")
        if self.m_model.sig_lv >= 10 then
            self:setImg("a_ui_shuzhi_di","common_ui","progress_1")
        else
            self:setImg("a_ui_shuzhihui_di","common_ui","progress_1")
        end
        if self.m_model.sig_lv >= 20 then
            self:setImg("a_ui_shuzhi_di","common_ui","progress_2")
        else
            self:setImg("a_ui_shuzhihui_di","common_ui","progress_2")
        end
        if self.m_model.sig_lv >= 30 then
            self:setImg("a_ui_shuzhi_di","common_ui","progress_3")
        else
            self:setImg("a_ui_shuzhihui_di","common_ui","progress_3")
        end
    end
end

--[[
    @desc: 英雄动画
]]
function M:setSpine()
	local icon = self.m_model:getHeroBigAnim()
	if self.cacheSpineName == icon then
		return
	else
		self.cacheSpineName = icon	
	end
	local pos_x = -8
	local pos_y = -8
	local play_img = self:findGameObject("hero_spine")
 	local sg = play_img:GetComponent("SkeletonGraphic")
	local hehe = ResourceUtil:GetSk(self.cacheSpineName, "rolespine_"..string.lower(self.cacheSpineName))
	sg.skeletonDataAsset = hehe
	sg:Initialize(true)
	local linshi_pos =self.m_model:getSpinePos()
	pos_x = pos_x + linshi_pos[1]
	pos_y = pos_y + linshi_pos[2]
	UIUtil.setLocalPosition(play_img.transform,pos_x, pos_y, 0)
end

function M:onButtonClick(obj, name)
    if name == "sk_1_img" then
        local icon = self:findGameObject("sk_1_img")
        self.m_control:openView("Pops.MeridianSkillPop", {click_transform = icon.transform, desc = self.m_model.sig_data.des1 })
    elseif name == "sk_2_img" then   
        local icon = self:findGameObject("sk_2_img")
        self.m_control:openView("Pops.MeridianSkillPop", {click_transform = icon.transform, desc = self.m_model.sig_data.des2 })
    elseif name == "sk_3_img" then   
        local icon = self:findGameObject("sk_3_img")
        self.m_control:openView("Pops.MeridianSkillPop", {click_transform = icon.transform, desc = self.m_model.sig_data.des3 })
    else
        self:updateMsg(name)
    end
end

--[[
    排序
]]
function M:sort(pros)
    pros = pros or {}
    local function sortFunc(id_one, id_two)
        local id_1 = self.m_model:getIndexByHeroEnumId(id_one)
        local id_2 = self.m_model:getIndexByHeroEnumId(id_two)
        return id_one[1] < id_two[1]
    end
    table.sort(pros, sortFunc)
end

function M:creatEffect(tx_name, prent)
    local item = ResourceUtil:GetUIEffectItem("HeroInfo/"..tx_name, prent)
    --item.transform:SetParent(prent.transform, false)
end

function M:creatCurEffect()
    if self.m_cur_qihai then
        self:creatEffect(self.JuQi, self.m_cur_qihai)
    end
end

return M