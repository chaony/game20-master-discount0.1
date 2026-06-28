---@class DepositoryPromotePopView:OOPopBase
---@field m_model DepositoryPopModel
local M = class("DepositoryPromotePopView",LikeOO.OOPopBase)

M.m_uiName = "SutraDepository/MysticDepositoryPromotePop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

local __TAB_BTN_NODE = {
    {btn_key = "all_togglebtn", lua_name = "", btn_text = "all_btn_text", text_key = "new_str_0044", open = true}, -- 全部
    {btn_key = "tian_togglebtn", lua_name = "", btn_text = "tian_btn_text", text_key = "mystic_str_0056", open = true,}, -- 先天
    {btn_key = "jue_togglebtn", lua_name = "", btn_text = "jue_btn_text", text_key = "mystic_str_0057", open = true}, -- 绝学
    {btn_key = "shen_togglebtn", lua_name = "", btn_text = "shen_btn_text", text_key = "mystic_str_0085", open = true, season = 4}, -- 神技
}

local __FUNC_TAB_BTN_NODE = {
    {btn_key = "canwu_togglebtn", lua_name = "", btn_text = "canwu_togglebtn_text", text_key = "mystic_str_0002", open = true}, -- 参悟
    {btn_key = "tuiyan_togglebtn", lua_name = "", btn_text = "tuiyan_togglebtn_text", text_key = "mystic_str_0075", open = true,}, -- 推演
}

function M:onEnter()
	self:setTextByLanKey("quick_add_btn_text", "mystic_str_0051")
    self:setTextByLanKey("ok_text", "new_str_0006")
    self:setTextByLanKey("cancle_text", "mystic_str_0083")
    self.promote_image = self:findImage("promote_btn")
    self.m_gray_image = self:findImage("gray_img")
    local show_tag_num = 0
    self.m_toggle_btns = {}
    for k,v in pairs(__TAB_BTN_NODE) do
        self:setTextByLanKey(v.btn_text, Language:getTextByKey(v.text_key))
        local tog_btn = self:findToggle(v.btn_key)
        if v.season then
            local season = UserDataManager:getCurSeason()
            v.open = season >= v.season
        end
        if v.open == true then
            show_tag_num = show_tag_num + 1
        end
        tog_btn.gameObject:SetActive(v.open)
        self.m_toggle_btns[k] = tog_btn
        local cur_tab_text = self:findText(v.btn_text)
        if k == self.m_model.m_sel_tab_index then
            tog_btn.isOn = true
        end
        --cur_tab_text.color = self.m_model.m_sel_tab_index == k and Color(68/255,85/255,128/255) or Color(85/255,125/255,162/255)
        cur_tab_text.color = self.m_model.m_sel_tab_index == k and GlobalConfig.COMMON_COLLOR.COMMON_25 or GlobalConfig.COMMON_COLLOR.COMMON_24
        UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
    end
    for k,v in pairs(__TAB_BTN_NODE) do
        local tog_btn = self:findToggle(v.btn_key)
        local back_ground = UIUtil.findImage(tog_btn.transform,"Background")
        local check_mark = UIUtil.findImage(back_ground.gameObject.transform,"Checkmark")
        if show_tag_num == 3 then
            tog_btn.transform.sizeDelta = Vector2.New(186, 60)
            UIUtil:setLocalDelta(back_ground.gameObject.transform, 186,60)
            UIUtil:setLocalDelta(check_mark.gameObject.transform, 186,60)
        else
            tog_btn.transform.sizeDelta = Vector2.New(140, 60)
            UIUtil:setLocalDelta(back_ground.gameObject.transform, 140,60)
            UIUtil:setLocalDelta(check_mark.gameObject.transform, 140,60)
        end
    end
    for k,v in pairs(__FUNC_TAB_BTN_NODE) do
        self:setTextByLanKey(v.btn_text, string.cutTextForString(Language:getTextByKey(v.text_key)))
        local tog_btn = self:findToggle(v.btn_key)
        tog_btn.gameObject:SetActive(v.open)
        local cur_tab_text = self:findText(v.btn_text)
        if k == self.m_model.m_sel_func_tab_index then
            tog_btn.isOn = true
        end
        cur_tab_text.color = self.m_model.m_sel_tab_index == k and GlobalConfig.COMMON_COLLOR.COMMON_25 or GlobalConfig.COMMON_COLLOR.COMMON_24
        UIUtil.addToggleListener(tog_btn, function(is_on)
            if is_on then
                self:updateMsg("func_toggle", k)
                cur_tab_text.color = GlobalConfig.COMMON_COLLOR.COMMON_25
            else
                cur_tab_text.color = GlobalConfig.COMMON_COLLOR.COMMON_24
            end
        end,nil,self.m_uiName)
    end
    
	self:refreshUI()	
end

function M:refreshUI(mystic)
    self:updateRightScroll() -- 刷新右侧秘籍列表
    if self.m_model.m_sel_func_tab_index == 1 then
        self:canwuFreshUI(mystic)
    elseif self.m_model.m_sel_func_tab_index == 2 then
        self:tuiyanFreshUI(mystic)
    end
end

function M:canwuFreshUI(mystic)
    self.m_model:resetMysticNextQuality() -- 重置下阶段合成品质
    -- 秘籍参悟按钮颜色
    self:setTextByLanKey("miji_tips", "mystic_str_0054")
    self:setTextByLanKey("promote_btn_text", "mystic_str_0002")
    self:setTextByLanKey("common_title_text", "mystic_str_0052")
    local needNum = self.m_model:screenSynthesisMysticNumByQuality(self.m_model.selMysticQuality)
    if table.nums(self.m_model.selMysticList)< needNum then
        self.promote_image.material = self.m_gray_image.material
    else
        self.promote_image.material = nil
    end
    for i = 3, 5 do
        self:setObjectVisible("mystic_node_"..i, i == needNum) -- 显示合成个数的节点
    end
    self:setObjectVisible("Image_di1", true)
    self:setObjectVisible("MysicItem_1", true)
    self:setObjectVisible("MysicItem_7_bg", false)
    self:setObjectVisible("MysicItem_7", false)
    self:setObjectVisible("quick_add_btn", true)
    self:setObjectVisible("promote_btn", true)
    self:setObjectVisible("cancle_btn", false)
    self:setObjectVisible("ok_btn", false)

    local mystic_node = self:findGameObject("mystic_node_"..needNum) -- 显示的底板的节点
    local myluaBehaviour = UIUtil.findLuaBehaviour(mystic_node)
    for i = 2, 5 do
        local mystic_item = self:findGameObject("MysicItem_"..i)
        local image_di = myluaBehaviour:FindGameObject("Image_di"..i)
        if i<= needNum then
            mystic_item.transform:SetParent(image_di.transform)
            mystic_item.transform.localScale = Vector3(0.8,0.8,1);
            mystic_item.transform.localPosition = Vector3.zero
            mystic_item:SetActive(true)
            image_di:SetActive(true)
        elseif i >=3 then
            mystic_item:SetActive(false)
        end
        if self.m_model.selMysticQuality == 0 then
            image_di:SetActive(false)
        end
    end

    for i = 1, 5 do
        local mysicItem = self:findGameObject("MysicItem_"..i)
        local m_oid = self.m_model.selMysticList[i]
        if m_oid then
            local cur_data, cur_cfg = self.m_model:getMysticDataByOid(m_oid)
            if cur_cfg then
                local reward_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.MYSTIC, tonumber(cur_data.id), cur_cfg.quality, oid = m_oid})
                self:updateBooksByData(mysicItem, reward_data, cur_cfg, cur_data)
                local data = {data_type = RewardUtil.REWARD_TYPE_KEYS.MYSTIC, quality = cur_cfg.quality, item_cfg = cur_cfg}
                GameUtil:creatEffectForEquip(mysicItem, data)
            end
        else
            self:updateBooksByData(mysicItem,nil,nil,nil,nil,i)
        end
    end

    self:refreshSyntheticNode(mystic) -- 合成秘籍节点

    local needNum = self.m_model:screenSynthesisMysticNumByQuality(self.m_model.selMysticQuality)
    self:setObjectVisible("help_btn",table.nums(self.m_model.selMysticList)==needNum)
    self:setObjectVisible("miji_tips2", false)
end

function M:tuiyanFreshUI(mystic)
    for i = 3, 5 do
        self:setObjectVisible("mystic_node_"..i, false)
    end
    for i = 1, 5 do
        self:setObjectVisible("MysicItem_"..i, false)
    end
    self:setObjectVisible("Image_di1", false)
    self:setObjectVisible("quick_add_btn", false)
    self:setTextByLanKey("promote_btn_text", "mystic_str_0075")
    self:setTextByLanKey("miji_tips", "mystic_str_0080")
    self:setObjectVisible("miji_tips2", true)
    self:setTextByLanKey("miji_tips2", "mystic_str_0081")
    self:setTextByLanKey("common_title_text", "mystic_str_0075")

    local m_oid = self.m_model.selMysticList[1]
    local quality = self.m_model.selMysticQuality
    local mysicItem = self:findGameObject("MysicItem_6")
    local show_help_btn_flag = false
    if m_oid then
        local cur_data, cur_cfg = self.m_model:getMysticDataByOid(m_oid)
        if cur_cfg then
            local reward_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.MYSTIC, tonumber(cur_data.id), cur_cfg.quality, oid = m_oid})
            self:updateBooksByData(mysicItem, reward_data, cur_cfg, cur_data)
            local data = {data_type = RewardUtil.REWARD_TYPE_KEYS.MYSTIC, quality = cur_cfg.quality, item_cfg = cur_cfg}
            GameUtil:creatEffectForEquip(mysicItem, data)
            show_help_btn_flag = cur_cfg.type ~= 3
        end
    else
        self:updateBooksByData(mysicItem,nil,nil,nil,nil,1)
    end
    
    if mystic then
        --self:refreshSyntheticNode(mystic)
        self:setObjectVisible("promote_btn", false)
        self:setObjectVisible("cancle_btn", true)
        self:setObjectVisible("ok_btn", true)

        self:setObjectVisible("help_btn",false)
        self:setObjectVisible("MysicItem_7_bg", false)
        self:setObjectVisible("MysicItem_7", false)
    else
        self:setObjectVisible("promote_btn", true)
        self:setObjectVisible("cancle_btn", false)
        self:setObjectVisible("ok_btn", false)

        self:setObjectVisible("help_btn",quality > 0)
        self:setObjectVisible("MysicItem_7_bg", quality > 0)
        if quality > 0 then
            self:setObjectVisible("MysicItem_7", true)
            local item = self:findGameObject("MysicItem_7")
            local cost_data = self.m_model:getTuiyanCost(quality, m_oid)
            GameUtil:updateItemElementByData(item, cost_data, true, true)
            if cost_data.user_num < cost_data.data_num then
                self.promote_image.material = self.m_gray_image.material
            else
                self.promote_image.material = nil
            end
        else
            self:setObjectVisible("MysicItem_7", false)
            self.promote_image.material = self.m_gray_image.material
        end
    end
end

-- 刷新合成后获得的秘籍展示
function M:refreshSyntheticNode(reward)
    local mysicItem = self:findGameObject("MysicItem_6")
    if not reward then reward = {} end
    local m_oid = reward[1]
    if m_oid then
        local cur_data, cur_cfg = self.m_model:getMysticDataByOid(m_oid)
        if cur_cfg then
            local reward_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.MYSTIC, tonumber(cur_data.id), cur_cfg.quality, oid = m_oid})
            self.m_model.m_reward_mystic = reward_data
            self:updateBooksByData(mysicItem, reward_data, cur_cfg, cur_data,nil,nil,true)
            local data = {data_type = RewardUtil.REWARD_TYPE_KEYS.MYSTIC, quality = cur_cfg.quality, item_cfg = cur_cfg}
            GameUtil:creatEffectForEquip(mysicItem, data)
        end
    else
        self:updateBooksByData(mysicItem, nil,nil,nil,true)
    end
end

function M:updateRightScroll()
    local all_mystic_list = {}
    if self.m_model.m_sel_func_tab_index == 1 then
        all_mystic_list = self.m_model:screeningMysticByQuality() -- 获取筛选后当前拥有的id
    elseif self.m_model.m_sel_func_tab_index == 2 then
        all_mystic_list = self.m_model:tuiyanScreeningMystic()
    end
    local rewardList = {}
    for i = 1, #all_mystic_list do
        local cfg = self.m_model:getMysticData(all_mystic_list[i].id)
        local reward_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.MYSTIC, tonumber(all_mystic_list[i].id), cfg.quality,
                                                             oid = all_mystic_list[i].oid, mystic_num = all_mystic_list[i].amount})
        rewardList[i] = reward_data
    end
    self.m_gift_tab = {}
    local data = rewardList
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self.m_gift_tab[index] = cell_obj
                self:updateLoopScroll(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, cell_data)
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data, true)
    end
end

-- 根据数据创建通用道具节点
function M:updateLoopScroll(index, obj, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local itemNode = luaBehaviour:FindGameObject("ItemNode")
    local itemNodeLuaBehaviour = UIUtil.findLuaBehaviour(itemNode)
    GameUtil:updateItemElementByData(itemNode, cell_data, true, false)
    local item_luaBehaviour = UIUtil.findLuaBehaviour(itemNode)
    LuaBehaviourUtil.setObjectVisible(item_luaBehaviour,"count_text",false)
    local sel_index = table.keyof(self.m_model.selMysticList, cell_data.oid)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sel_img",  false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sel_bg_node",  false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "put_out_btn", sel_index ~= nil)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "put_on_btn", sel_index == nil)
    -- 秘籍属性
    local attrs_pro = luaBehaviour:FindGameObject("attrs_pro")
    local attrs_node = luaBehaviour:FindGameObject("attrs_node")
    local attr_node = luaBehaviour:FindGameObject("attr_node")
    local item_name = luaBehaviour:FindText("item_name")
    item_name.text = Language:getTextByKey(cell_data.item_cfg.name)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "aomi_node", cell_data.item_cfg.type == 2 or cell_data.item_cfg.type == 3) -- 1 先天 2 绝学 3 神技
    local attrs = self.m_model:getMysticAllAttr(cell_data.item_cfg)
    self:updateAttrLoopScroll(attrs, attrs_node, attr_node)

    local group_cfg = self.m_model:getMysticBuffGroupById(cell_data.data_id)
    if table.nums(group_cfg) > 0 then
        local mysticCfg = group_cfg[1] or {} -- 先默认选第一个，未来可能要展示一本秘籍的多个技能(目前界面不允许这样显示)
        LuaBehaviourUtil.setImg(luaBehaviour,"group_skill_img", mysticCfg.icon, "skill_icon")
    end
    if self.m_model.m_sel_func_tab_index == 2 then
        if cell_data.item_cfg.push and cell_data.item_cfg.push == 1 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "put_on_btn", true)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "put_on_btn", false)
        end
    end
    local attrs_pro_fitter = attrs_pro:GetComponent("ContentImmediate")
    attrs_pro_fitter:ForceRefreshSize()--触发刷新自适应大小
end

--[[	
	属性列表
]]
function M:updateAttrLoopScroll(attrs, attrs_node, attr_node)
    UIUtil.destroyAllChild(attrs_node.transform) -- 移除所有子节点
    if not attrs then return end
    for k,cell_data in ipairs(attrs) do
        local cell_object = GameUtil:instanceObject(attr_node, attrs_node.transform)
        cell_object:SetActive(true)
        for i = 1, 2 do
            local transform = cell_object.transform
            if cell_data[i] then
                local cp = GameUtil:getAttrsName(cell_data[i][1])
                local attr_name_text = UIUtil.setText(transform, cp, "attr_name_text"..i)
                -- 四舍五入保留小数点后一位
                local attr_value = cell_data[i][2] or 0
                attr_value = math.floor(attr_value * 10 + 0.5)/10
                local attr_value_text = nil
                if GameUtil:attrTransition(cell_data[i][1]) == true then
                    attr_value_text = UIUtil.setText(transform, "+"..GameUtil:formatNum(attr_value).."%", "attr_value_text"..i)
                else
                    attr_value_text = UIUtil.setText(transform, "+"..GameUtil:formatNum(attr_value), "attr_value_text"..i)
                end
                local attr_value_text_trans = UIUtil.findRectTransform(attr_value_text)
                UIUtil.setLocalPosition(attr_value_text_trans, attr_name_text.preferredWidth + 20)
            else
                UIUtil.setText(transform, "", "attr_name_text"..i)
                UIUtil.setText(transform, "", "attr_value_text"..i)
            end
        end
    end
end

function M:updateBooksByData( obj, data, cfg, mystic_data, awardFlag, index, centerFlag)
	local object = obj
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local title_node = luaBehaviour:FindGameObject("title_node")
    local type_bg = luaBehaviour:FindGameObject("type_bg")
    local camp_img = luaBehaviour:FindGameObject("camp_img")
    local vocation_img = luaBehaviour:FindGameObject("vocation_img")
    local no_quality_up_img = luaBehaviour:FindGameObject("no_quality_up_img")
    local title_text = luaBehaviour:FindText("title_text")
    local duigoudi_img = luaBehaviour:FindGameObject("duigoudi_img")
    local lv_text = luaBehaviour:FindGameObject("lv_text")
    local have_panel = luaBehaviour:FindGameObject("have_panel")
    local no_panel = luaBehaviour:FindGameObject("no_panel")
    local up_image = luaBehaviour:FindGameObject("up_image")
    local lock_image = luaBehaviour:FindGameObject("lock_image")
    local stars = luaBehaviour:FindGameObject("stars")
    local tips_img = luaBehaviour:FindGameObject("tips_img")
    local red_point_img = luaBehaviour:FindGameObject("red_point_img")
    local count_text_bg_img = luaBehaviour:FindGameObject("count_text_bg_img")
    local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
    local ex_we_bg = luaBehaviour:FindGameObject("ex_we_bg")
    local ex_di_bg = luaBehaviour:FindGameObject("ex_di_bg")
    local item_img = luaBehaviour:FindImage("item_img")
    local quality_img = luaBehaviour:FindImage("quality_img")
    local cell_name = luaBehaviour:FindText("cell_name")
    
    red_point_img:SetActive(false)
    up_image:SetActive(false)
    ex_we_bg:SetActive(false)
    lock_image:SetActive(false)
    duigoudi_img:SetActive(false)
    title_node:SetActive(false)
    tips_img:SetActive(false)
    lv_bg_img:SetActive(false)
    ex_di_bg:SetActive(false)
    vocation_img:SetActive(false)
    stars:SetActive(false)
    count_text_bg_img:SetActive(false)
    no_quality_up_img:SetActive(false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"cell_name",false)
    if data then -- 有秘籍
        local type_meridian = GlobalConfig.TYPE_MERIDIAN[cfg.type]
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "type_name", type_meridian.short_name)
        LuaBehaviourUtil.setTextColor(luaBehaviour,"type_name",type_meridian.name_color)
        if mystic_data and mystic_data.owner and mystic_data.owner ~= "" then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"HeadNode",true)
            local cur_skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByOid(mystic_data.owner)
            if cur_skin_cfg then
                LuaBehaviourUtil.setImg(luaBehaviour, "tx_img", cur_skin_cfg.icon, "hero_head_ui")
            end
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"HeadNode",false)
        end
        --职业标识
        local class_meridian = GlobalConfig.CLASS_MERIDIAN[cfg.role_type or 0] or 0
        if class_meridian == 0 then
            vocation_img:SetActive(false)
        else
            vocation_img:SetActive(true)
            LuaBehaviourUtil.setImg(luaBehaviour, "vocation_img", class_meridian.pro_icon,  ResourceUtil:getLanAtlas())
        end
        have_panel:SetActive(true)
        no_panel:SetActive(false)
        type_bg:SetActive(false)
        camp_img:SetActive(true)
        LuaBehaviourUtil.setImg(luaBehaviour, "camp_img", type_meridian.pro_icon,  ResourceUtil:getLanAtlas())
        local frame = GlobalConfig.QUALITY_COMMON_SETTING[data.quality]
        LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", frame.frame_name, "equip_icon")
        LuaBehaviourUtil.setImg(luaBehaviour,"item_img", data.icon_name, data.atlas_name or "item_icon")
    else
        have_panel:SetActive(false)
        no_panel:SetActive(true)
        type_bg:SetActive(false)
        camp_img:SetActive(false)
        vocation_img:SetActive(false)
    end
    if awardFlag then -- 秘籍置灰
        have_panel:SetActive(true)
        no_panel:SetActive(false)
        type_bg:SetActive(false)
        camp_img:SetActive(false)
        vocation_img:SetActive(false)
        --LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", "a_ui_currency_dj_jin", "equip_icon")
        LuaBehaviourUtil.setImg(luaBehaviour,"item_img", "MJ_weizhi", "mystic_ui")
        --item_img.material = self.m_gray_image.material
        --quality_img.material = self.m_gray_image.material
        if self.m_model.m_next_quality ~= 0 then
            local frame = GlobalConfig.QUALITY_COMMON_SETTING[self.m_model.m_next_quality]
            LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", frame.frame_name, "equip_icon")
        else
            LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", "a_ui_currency_dj_hui", "equip_icon")
        end
    else
        item_img.material = nil
        quality_img.material = nil
    end

    if centerFlag then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"cell_name",true)
        local frame = GlobalConfig.QUALITY_COMMON_SETTING[data.quality]
        LuaBehaviourUtil.setTextColor(luaBehaviour,"cell_name",frame.RGBA)
        cell_name.text = Language:getTextByKey(cfg.name)
    end
    
    local needNum = self.m_model:screenSynthesisMysticNumByQuality(self.m_model.selMysticQuality)
    if index and index > needNum then -- 当合成需要的秘籍数小于位置，就加锁
        no_panel:SetActive(true)
        lock_image:SetActive(true)
    end
	
end

-- 筛选标签点击事件
function M:switchTabUpdate(is_on, update_key)
    if is_on then
        self:updateMsg(update_key)
    end
end

function M:switchTabNode(index, keep_offset)
    for k,v in pairs(__TAB_BTN_NODE) do
        local cur_tab_text = self:findText(v.btn_text)
        cur_tab_text.color = index == k and GlobalConfig.COMMON_COLLOR.COMMON_25 or GlobalConfig.COMMON_COLLOR.COMMON_24
    end
    self:updateRightScroll()
end


function M:showEffect( showflag)
    if self.m_model.m_sel_func_tab_index == 1 then
        local needNum = self.m_model:screenSynthesisMysticNumByQuality(self.m_model.selMysticQuality)
        for i = 1,needNum do
            local object = self:findGameObject("MysicItem_"..i)
            local luaBehaviour = UIUtil.findLuaBehaviour(object)
            local xiaoShi1 = luaBehaviour:FindGameObject("UI_MysticDepository_XiaoShi_001")
            local xiaoShi2 = luaBehaviour:FindGameObject("UI_MysticDepository_XiaoShi_002")
            xiaoShi1:SetActive(showflag)
            xiaoShi2:SetActive(showflag)
        end
        self:setObjectVisible("UI_MysticDepository_LineA_001", showflag)
        self:setObjectVisible("UI_MysticDepository_XiaoShi_003", showflag)
        self:setObjectVisible("UI_MysticDepository_XiaoShi_004", showflag)
        self:setObjectVisible("mystic_texiao_node_"..needNum, showflag)
        if not showflag then
            self:setObjectVisible("UI_MysticDepository_HeCheng_001", showflag)
        end

        self.m_control:setOnceTimer(0.5, function()
            if showflag then
                self:setObjectVisible("UI_MysticDepository_HeCheng_001", showflag)
            end
        end)
    else
        --self:setObjectVisible("UI_MysticDepository_LineA_001", showflag)
        self:setObjectVisible("UI_MysticDepository_XiaoShi_003", showflag)
        self:setObjectVisible("UI_MysticDepository_XiaoShi_004", showflag)
        if not showflag then
            self:setObjectVisible("UI_MysticDepository_HeCheng_001", showflag)
        end

        self.m_control:setOnceTimer(0.5, function()
            if showflag then
                self:setObjectVisible("UI_MysticDepository_HeCheng_001", showflag)
            end
        end)
    end
end

function M:tuiyanSaveInteractableBtns(flag)
    for i,v in pairs(__TAB_BTN_NODE) do
        local tog_btn = self:findToggle(v.btn_key)
        tog_btn.interactable = flag
    end
    for i,v in pairs(__FUNC_TAB_BTN_NODE) do
        local tog_btn = self:findToggle(v.btn_key)
        tog_btn.interactable = flag
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M