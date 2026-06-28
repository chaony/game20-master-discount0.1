---@class SutraDepositoryView:OOPopBase
---@field m_model SutraDepositoryModel
local M = class("SutraDepositoryView",LikeOO.OOPopBase)

M.m_uiName = "SutraDepository/MysticDepository"
M.m_size_type = 1
M.m_iphoneXAdapter = true

local __TAB_BTN_NODE = {
	{btn = "all_togglebtn", red_point_img = "all_red_point_img", btn_text = "all_btn_text", str = "new_str_0065"},
	{btn = "xiantian_atk_togglebtn", red_point_img = "xiantian_atk_red_point_img", btn_text = "xiantian_atk_btn_text", str = "mystic_str_0056"},
    {btn = "juexue_togglebtn", red_point_img = "juexue_red_point_img", btn_text = "juexue_btn_text",  str = "mystic_str_0057"},
    {btn = "shenji_togglebtn", red_point_img = "shenji_red_point_img", btn_text = "shenji_btn_text",  str = "mystic_str_0085", season = 3},
}

function M:onEnter()
	self.m_desc_value_active = true
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 54})
	self:setTextByLanKey("close_title_text", "mystic_str_0001")
    self:setTextByLanKey("base_attrs_title_text", "mystic_str_0045")
    self:setTextByLanKey("break_text", "mystic_str_0099")
    self:setTextByLanKey("mysic_effect_title_text", "mystic_str_00100")
    self:setTextByLanKey("mysic_attri_title_text", "mystic_str_00101")
    self:setTextByLanKey("intensify_text", "mystic_str_00102")
    self:setTextByLanKey("unlock_text", "mystic_str_00103")
    self:setTextByLanKey("unlock_btn_text", "mystic_str_00104")
    self:setTextByLanKey("intensify_btn_text", "mystic_str_00105")
    self:setTextByLanKey("break_btn_text", "mystic_str_00106")
    self:setTextByLanKey("maxLv_tip_text", "mystic_str_00109")
    --self:setTextByLanKey("channel_attr_title_text", "mystic_str_0046")
    --self:setTextByLanKey("group_skill_title_text", "mystic_str_0050")
    --self:setTextByLanKey("pingfen_text", "mystic_str_0084")
    --self:setTextByLanKey("inset_attr_title_text", "mystic_str_0091")
    --self:setTextByLanKey("inset_skill_attr_title_text", "mystic_str_0092")
    --self:setTextByLanKey("zh_title_text", "miji_ay_text")
    --self:setTextByLanKey("inset_sort_node_text", "mystic_str_0098")
    self.gray_img = self:findImage("gray_img")
    self.MysicItem = self:findGameObject("MysicItem")

	for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v.btn)
        local text_str = self:findText(v.btn_text)
		if i == self.m_model.m_tab_index then
			tog_btn.isOn = true
            --text_str.color = Color.New(1,1,1)
            text_str.color = GlobalConfig.COMMON_COLLOR.COMMON_25
        else
            --text_str.color = Color.New(0.5,0.5,0.5)
            text_str.color = GlobalConfig.COMMON_COLLOR.COMMON_24
		end
        text_str.text = string.cutTextForString(Language:getTextByKey(v.str)) 
        if v.season and v.season > 0 then
            self:setObjectVisible(v.btn, self.m_model:showShenJi() == true)
        else
            self:setObjectVisible(v.btn, true)
        end
		UIUtil.addToggleListener(tog_btn, function(is_on, data) 
            local cur_node = __TAB_BTN_NODE[data]
            local cur_text_str = self:findText(cur_node.btn_text)
			if is_on then 
				self:updateMsg("tab_btn",data) 
                cur_text_str.color = GlobalConfig.COMMON_COLLOR.COMMON_25
            else
                cur_text_str.color = GlobalConfig.COMMON_COLLOR.COMMON_24
			end 
		end, i, self.m_uiName)
		self:setObjectVisible(v.red_point_img, false)
	end

    self.m_mystic = {}

    self:refreshUI()
    if self.m_model.m_index ~= 1 then
        self.m_list_scroll:moveToCellIndex(self.m_model.m_index)
    end
    audio:SendEvtUI("Amb_2D_LangHuanGe")
end

function M:updateScroll(keep_offset)
    local data = self.m_model.m_list_data
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 3,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                self:setCellHander(cell_object, cell_data, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                self:updateMsg("select_mystic", {oid = cell_data.id, cell_obj = cell_object,index = index})
                LuaBehaviourUtil.setObjectVisible(luaBehaviour,"red_point_img",false)
                UserDataManager.mystic_data:removeOneNewIds(cell_data.id)
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data, keep_offset)
    end
end

function M:setCellHander(obj, cell_data, index)
    local new_bl = false
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local lock_img = luaBehaviour:FindGameObject("lock_img")
    local mystic_data, mystic_cfg
    if type(cell_data) == "number" then
        mystic_cfg = UserDataManager.mystic_data:getMysticConfigByCid(cell_data)
    else
        mystic_data, mystic_cfg = cell_data.data, cell_data.cfg
        new_bl = self.m_model:checkMysticNewRedPoint(cell_data.id)
    end 
    
    local type_meridian = GlobalConfig.TYPE_MERIDIAN[mystic_cfg.type]
    local name_list =  string.split(Language:getTextByKey(mystic_cfg.name),"·")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_name", mystic_cfg.name)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"HeadNode",false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"cell_name",true)
    
    local item_img = LuaBehaviourUtil.setImg(luaBehaviour,"item_img", mystic_cfg.icon or mystic_cfg.icon_name, "item_icon")
    local title_node = luaBehaviour:FindGameObject("title_node")
    local duigoudi_img = luaBehaviour:FindGameObject("duigoudi_img")
    local have_panel = luaBehaviour:FindGameObject("have_panel")
    local no_panel = luaBehaviour:FindGameObject("no_panel")
    local up_image = luaBehaviour:FindGameObject("up_image")
    local tips_img = luaBehaviour:FindGameObject("tips_img")
    local red_point_img = luaBehaviour:FindGameObject("red_point_img")
    local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
    local ex_we_bg = luaBehaviour:FindGameObject("ex_we_bg")
    local ex_di_bg = luaBehaviour:FindGameObject("ex_di_bg")
    local cell_di_bg = luaBehaviour:FindGameObject("cell_di_bg")
    red_point_img:SetActive(new_bl)
    ex_di_bg:SetActive(false)
    cell_di_bg:SetActive(false)
    have_panel:SetActive(true)
    no_panel:SetActive(false)
    up_image:SetActive(false)
    ex_we_bg:SetActive(false)
    duigoudi_img:SetActive(false)
    title_node:SetActive(false)
    tips_img:SetActive(false)
    lv_bg_img:SetActive(false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "count_text", false)  
    if type(cell_data) == "table" and cell_data.alive == false then
        local quality_img = luaBehaviour:FindImage("quality_img")
        local item_img = luaBehaviour:FindImage("item_img")
        quality_img.material = self.gray_img.material
        item_img.material = self.gray_img.material
        if mystic_cfg.type == 1 then
            LuaBehaviourUtil.setImg(luaBehaviour, "type_bg", "a_lhg_xiantian_weikaiqi", ResourceUtil:getLanAtlas())
            LuaBehaviourUtil.setImg(luaBehaviour, "camp_img", "a_lhg_xiantian_weikaiqi",  ResourceUtil:getLanAtlas())
        elseif mystic_cfg.type == 2 then   
            LuaBehaviourUtil.setImg(luaBehaviour, "type_bg", "a_lhg_juexue_weikaiqi", ResourceUtil:getLanAtlas())
            LuaBehaviourUtil.setImg(luaBehaviour, "camp_img", "a_lhg_juexue_weikaiqi",  ResourceUtil:getLanAtlas())
        elseif mystic_cfg.type == 3 then  
            LuaBehaviourUtil.setImg(luaBehaviour, "type_bg", "a_lhg_shenpin_weikaiqi", ResourceUtil:getLanAtlas())
            LuaBehaviourUtil.setImg(luaBehaviour, "camp_img", "a_lhg_shenpin_weikaiqi",  ResourceUtil:getLanAtlas())
        end
    else
        local quality_img = luaBehaviour:FindImage("quality_img")
        local item_img = luaBehaviour:FindImage("item_img")
        quality_img.material = nil
        item_img.material = nil
        if mystic_cfg.type == 1 then
            LuaBehaviourUtil.setImg(luaBehaviour, "type_bg", "a_lhg_xiantian", ResourceUtil:getLanAtlas())
            LuaBehaviourUtil.setImg(luaBehaviour, "camp_img", "a_lhg_xiantian",  ResourceUtil:getLanAtlas())
        elseif mystic_cfg.type == 2 then
            LuaBehaviourUtil.setImg(luaBehaviour, "type_bg", "a_lhg_juexue", ResourceUtil:getLanAtlas())
            LuaBehaviourUtil.setImg(luaBehaviour, "camp_img", "a_lhg_juexue",  ResourceUtil:getLanAtlas())
        elseif mystic_cfg.type == 3 then
            LuaBehaviourUtil.setImg(luaBehaviour, "type_bg", "a_lhg_shenpin", ResourceUtil:getLanAtlas())
            LuaBehaviourUtil.setImg(luaBehaviour, "camp_img", "a_lhg_shenpin",  ResourceUtil:getLanAtlas())
        end
        if type(cell_data) == "table" and cell_data.num and cell_data.num > 1 then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "count_text", cell_data.num)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "count_text", true)
        end
    end
    if mystic_cfg.role_type ~= 0 and mystic_cfg.role_type ~= nil then
        local class_meridian = GlobalConfig.CLASS_MERIDIAN[mystic_cfg.role_type]
        if class_meridian and class_meridian ~= 0 then
            LuaBehaviourUtil.setImg(luaBehaviour, "vocation_img", class_meridian.pro_icon,  ResourceUtil:getLanAtlas())
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"vocation_img",true)
        end
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"vocation_img",false)
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_image", index == self.m_model.m_index)
    local frame_name = GlobalConfig.QUALITY_COMMON_SETTING[mystic_cfg.quality]
    LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", frame_name.frame_name, "equip_icon")
    local starGo = luaBehaviour:FindGameObject("stars")
    self:setStarLv(starGo.transform,cell_data.star_lv)
    local data = {data_type = RewardUtil.REWARD_TYPE_KEYS.MYSTIC, quality = mystic_cfg.quality, item_cfg = mystic_cfg}
    GameUtil:creatEffectForEquip(obj, data)
    if type(cell_data) == "number" then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_name", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_name2", false)
    end
end

function M:setToggle()
	local tab = __TAB_BTN_NODE[self.m_model.m_tab_index]
	local tog_btn = self:findToggle(tab.btn)
	tog_btn.isOn = true 
end

function M:refreshUI(keep_offset)
	self:refreshRedPoint()
    self:updateScroll(keep_offset)
    self:updateMysticBaseData()
end

function M:updateMysticBaseData()
    local data = self.m_model:getMysticListDataByIndex(self.m_model.m_index)
    local mystic_data, mystic_cfg = data.data, data.cfg
    local mystic_buff_cfg1 =data.mystic_buff_cfg1
    local cfg_lv=data.cur_cfg_lv
    local next_cfg_lv=data.next_cfg_lv
    local star_cfg=data.star_cfg
    local next_star_cfg=data.next_star_cfg

    self:setObjectVisible("mysic_effect1",mystic_buff_cfg1~=nil)
    self:setObjectVisible("mysic_effect2",mystic_buff_cfg1==nil)
    if mystic_buff_cfg1~=nil then
        local des=Language:getTextByKey(mystic_buff_cfg1.des)
        if data.mystic_buff_cfg2 then
            local des2=Language:getTextByKey(data.mystic_buff_cfg2.des)
            des=des.."\n"..des2
        end
        self:setText("mysic_effect_text", des)

    else
        local attr=star_cfg.attrs[1]
        local attr_cfg = GameUtil:getAttrCfg(attr[1])
        self:setText("cell_1_type_text",Language:getTextByKey(attr_cfg.name) .. ":")
        self:setText("cell_1_vein_desc",
       "+" .. (attr_cfg.is_percent == 1 and tostring(attr[2]*100) .. "%" or tostring(attr[2])))

        self:setObjectVisible("mysic_effect2_cell_2",#star_cfg.attrs>1)

        if #star_cfg.attrs>1 then
            attr=star_cfg.attrs[2]
            attr_cfg = GameUtil:getAttrCfg(attr[1])
            self:setText("cell_2_type_text",Language:getTextByKey(attr_cfg.name) .. ":")
            self:setText("cell_2_vein_desc",
                    "+" .. (attr_cfg.is_percent == 1 and tostring(attr[2]*100) .. "%" or tostring(attr[2])))
        end
    end

    self:setObjectVisible("unlock",not data.alive)
    self:setObjectVisible("break",data.alive and data.canBreakStar)
    self:setObjectVisible("intensify",data.alive and (not data.canBreakStar))
    self:setTextByLanKey("mysic_name_text", mystic_cfg.name)

    if data.alive then
        if data.canBreakStar then
            self:setObjectVisible("maxLv_tip_text",data.isMaxStarLv)
            self:setObjectVisible("less_maxLv",not data.isMaxStarLv)
            if not data.isMaxStarLv then
                local curStarsTrans=self:findGameObject("curStars").transform
                self:setObjectVisible("star_0_Lv",data.star_lv==0)
                curStarsTrans.gameObject:SetActive(data.star_lv~=0)
                if data.star_lv~=0 then
                    self:setStarLv(curStarsTrans,data.star_lv)
                end
                local nextStarsTrans=self:findGameObject("nextStars").transform
                self:setStarLv(nextStarsTrans,data.star_lv+1)
                local cost_name=ConfigManager:getCfgByName("item")[next_star_cfg.cost[1][2]].name
                curStarsTrans=Language:getTextByKey(cost_name)

                local curIsXianTian=self.m_model:curIsXianTian()
                self:setObjectVisible("skill_detail_btn",not curIsXianTian)
                local attrs=star_cfg.attrs
                if curIsXianTian then
                    self:setStarUpgradeAtrrChange(attrs[1][1],attrs[1][2],next_star_cfg.attrs[1][2],1)
                    self:setObjectVisible("attr2",#attrs==2)
                    self:setObjectVisible("attr3",#attrs==3)
                    if #attrs==2 then
                        self:setStarUpgradeAtrrChange(attrs[2][1],attrs[2][2],next_star_cfg.attrs[2][2],2)
                    end
                    if #attrs==3 then
                        self:setStarUpgradeAtrrChange(attrs[3][1],attrs[3][2],next_star_cfg.attrs[3][2],3)
                    end
                else
                    self:setObjectVisible("attr2",false)
                    self:setObjectVisible("attr3",false)
                    local pre_buff_name=self.m_model:getBuffNameById(star_cfg.buff[1])
                    local next_buff_name=self.m_model:getBuffNameById(next_star_cfg.buff[1])
                    self:setTextByLanKey("pre_lv_text1",pre_buff_name)
                    self:setTextByLanKey("next_lv_text1",next_buff_name)
                end
                self:setTextByLanKey("pre_num_text","mystic_str_00108",data.canEquipNum)
                self:setTextByLanKey("next_num_text","mystic_str_00108",data.nextCanEquipNum)
                self:setText("piece_name_text1",curStarsTrans)
                local break_cost_item_go=self:findGameObject("break_cost_item")
                GameUtil:updateItemElement(break_cost_item_go,{103,next_star_cfg.cost[1][2],0},false,true)
                self:setNumText("piece_num_text1",next_star_cfg.cost[1][2],next_star_cfg.cost[1][3])
                local _,itemCfg=UserDataManager.item_data:getItemDataById(next_star_cfg.cost[1][2])
                self:setImg( itemCfg.icon, "item_icon","piece_icon")
            end
        else
            self:setTextByLanKey("breakTip","mystic_str_00110",data.breakDiffValue)
            self:setNumText("piece_num_text2",next_cfg_lv.cost[1][2],next_cfg_lv.cost[1][3])
            local attrs=cfg_lv.attrs
            local attr_cfg = GameUtil:getAttrCfg(attrs[1][1])
            local attr_cfg_name=Language:getTextByKey(attr_cfg.name)
            self:setText("pre_attri1",attr_cfg_name..":"..attrs[1][2])
            self:setText("next_attri1",attr_cfg_name..":"..next_cfg_lv.attrs[1][2])

            local intensify_cost_item_go=self:findGameObject("intensify_cost_item")
            GameUtil:updateItemElement(intensify_cost_item_go,{103,cfg_lv.cost[1][2],0},false,true)
            self:setObjectVisible("arr2",#attrs==2)
            self:setObjectVisible("arr3",#attrs==3)
            if #attrs==2 then
                attr_cfg = GameUtil:getAttrCfg(attrs[2][1])
                attr_cfg_name=Language:getTextByKey(attr_cfg.name)
                self:setText("pre_attri2",attr_cfg_name..":"..attrs[2][2])
                self:setText("next_attri2",attr_cfg_name..":"..next_cfg_lv.attrs[2][2])
            elseif #attrs==3 then
                attr_cfg = GameUtil:getAttrCfg(attrs[3][1])
                attr_cfg_name=Language:getTextByKey(attr_cfg.name)
                self:setText("pre_attri3",attr_cfg_name..":"..attrs[3][2])
                self:setText("next_attri3",attr_cfg_name..":"..next_cfg_lv.attrs[3][2])
            end
        end
    else
        local unlock_cost_item_go=self:findGameObject("unlock_cost_item")
        GameUtil:updateItemElement(unlock_cost_item_go,{103,next_star_cfg.cost[1][2],0},false,true)
        local needNum=mystic_cfg.chip_num
        self:setNumText("piece_num_text3",mystic_cfg.chip_id,needNum)
        local cost_name=ConfigManager:getCfgByName("item")[next_star_cfg.cost[1][2]].name
        self:setTextByLanKey("piece_name_text2", cost_name)
        self:setImg( mystic_cfg.icon or mystic_cfg.icon_name, "item_icon","piece_icon2")
    end

    self:setTextByLanKey("mysic_lv_text","mystic_str_00111",data.mystic_lv)
    local luaBehaviour = UIUtil.findLuaBehaviour(self.MysicItem)
    LuaBehaviourUtil.setImg(luaBehaviour,"item_img", mystic_cfg.icon or mystic_cfg.icon_name, "item_icon")
    local frame_name = GlobalConfig.QUALITY_COMMON_SETTING[mystic_cfg.quality]
    LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", frame_name.frame_name, "equip_icon")
    local type_meridian = GlobalConfig.TYPE_MERIDIAN[mystic_cfg.type]
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "type_name", type_meridian.short_name)
    LuaBehaviourUtil.setTextColor(luaBehaviour,"type_name",type_meridian.name_color)
    LuaBehaviourUtil.setImg(luaBehaviour, "camp_img", type_meridian.pro_icon,  ResourceUtil:getLanAtlas())
    if mystic_cfg.role_type ~= 0 and mystic_cfg.role_type ~= nil then
        local class_meridian = GlobalConfig.CLASS_MERIDIAN[mystic_cfg.role_type]
        LuaBehaviourUtil.setImg(luaBehaviour, "vocation_img", class_meridian.pro_icon,  ResourceUtil:getLanAtlas())
        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"vocation_img",true)
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"vocation_img",false)
    end

    local starGo =LuaBehaviourUtil.findGameObject(luaBehaviour,"stars")
    self:setStarLv(starGo.transform,data.star_lv)

    local reward_data = {data_type = RewardUtil.REWARD_TYPE_KEYS.MYSTIC, quality = mystic_cfg.quality,item_cfg = mystic_cfg}
    GameUtil:creatEffectForEquip(self.MysicItem, reward_data)

    self:updateAllAttrLoopScroll()

end

function M:setStarUpgradeAtrrChange(attr_id,cur_attr_value,next_attr_value,index)
    local attr_cfg = GameUtil:getAttrCfg(attr_id)
    local attr_cfg_name=Language:getTextByKey(attr_cfg.name)
    cur_attr_value=attr_cfg.is_percent == 1 and tostring(cur_attr_value*100) .. "%" or tostring(cur_attr_value)
    next_attr_value=attr_cfg.is_percent == 1 and tostring(next_attr_value*100) .. "%" or tostring(next_attr_value)
    self:setText("pre_lv_text"..index,attr_cfg_name..":"..cur_attr_value)
    self:setText("next_lv_text"..index,attr_cfg_name..":"..next_attr_value)
end

--不足数置红
function M:setNumText(text,itemId,needNum)
    local data=UserDataManager.item_data:getItemDataById(itemId)
    local curNum=data.num
    local numStr=nil
    if curNum>=needNum then
        numStr=string.format("<color=#2FFF00>%d</color>/%d",curNum,needNum)
    else
        numStr=string.format("<color=#FF0000>%d</color>/%d",curNum,needNum)
    end
    self:setText(text,numStr)
end

function M:setStarLv(starParentTrans, curStarLv)
    local childCount=starParentTrans.childCount
    local index=0
    local starGo=nil
    for i = 1, childCount do
        starGo=starParentTrans:Find("star_"..i).gameObject
        starGo:SetActive(i<=curStarLv)
    end
end

function M:refreshGroup(cfg, group_cfg)
	if group_cfg ~= nil and next(group_cfg) ~= nil then
		local mysticCfg = group_cfg[1] or {} -- 先默认选第一个，未来可能要展示一本秘籍的多个技能(目前界面不允许这样显示)
		--self:setTextByLanKey("zh_name_text", mysticCfg.name)
		self:setTextByLanKey("propey_name", mysticCfg.des)
		self:setImg(mysticCfg.icon,"skill_icon","group_skill_img")

		local grid_race = self:findGameObject("zh_node") -- 已废弃
		local mystic_id = mysticCfg.mystic_id or {}
        if mysticCfg then
            self:setObjectVisible("zh_desc", true)
        else
            self:setObjectVisible("zh_desc", false)
        end
		-- self:setObjectVisible("zh_desc", #mystic_id > 0)
		grid_race:SetActive(false)-- 隐藏原来的套装
		
		--local buff_cfg = {}
		--local mystic_buff_cfg = ConfigManager:getCfgByName("mystic_buff")
		--for i, v in pairs(cfg.buff) do
		--	buff_cfg[#buff_cfg+1] = mystic_buff_cfg[v]
		--end
        
		if mysticCfg then
			self:setTextByLanKey("text", Language:getTextByKey(mysticCfg.des))
            self:setTextByLanKey("zh_name_text", Language:getTextByKey(mysticCfg.name))
            if mysticCfg.des_class and mysticCfg.des_class ~= "" then
                local vocation_text = self:setObjectVisible("vocation_text", true)
                self:setTextByLanKey("vocation_text", Language:getTextByKey(mysticCfg.des_class))
                vocation_text.transform:GetComponent('ContentSizeFitter'):SetLayoutVertical()
            else
                self:setObjectVisible("vocation_text", false)
            end
		end
		self:setObjectVisible("group_lock_img", false)
		self:setObjectVisible("group_skill_img", true)
		local group_skill_img_com = self:findImage("group_skill_img")
		group_skill_img_com.material = nil
	else
        self:setObjectVisible("vocation_text", false)
		self:setObjectVisible("zh_desc", false)
	end
end


function M:refreshRedPoint()
	for i,v in ipairs(__TAB_BTN_NODE) do
		local flag = self.m_model:getRedPoint(i)
		local node = self:findGameObject(v.red_point_img)
		node:SetActive(flag)
	end
end

function M:upgradeMystic(stic_data)
	local data,cur_cfg
	if stic_data.mystic_id then
		data, cur_cfg = UserDataManager.mystic_data:getMysticDataById(stic_data.mystic_id)
	end
    local mystic_icon =  self:findGameObject("item_"..cur_cfg.type)
    mystic_icon:SetActive(true)
    GameUtil:updateItemElement(mystic_icon, {RewardUtil.REWARD_TYPE_KEYS.MYSTIC, data.id, cur_cfg.quality, oid = stic_data.mystic_id}, false, false)
    self.m_update_type = cur_cfg.type
    local back = UIUtil.findImage(btn_obj.transform)

    local mystic_img = UIUtil.findTrans(btn_obj.transform,"mystic_img")
    local atk_effect = UIUtil.findTrans(btn_obj.transform,"atk_effect")
end

function M:updateBooksNoData(object, index)
    object:SetActive(false)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local have_panel = luaBehaviour:FindGameObject("have_panel")
    local no_panel = luaBehaviour:FindGameObject("no_panel")
    have_panel:SetActive(false)
    no_panel:SetActive(true)
    local function clickCallback()
        self:updateMsg("grid_click", index)
    end
    UIUtil.setButtonClick(object,clickCallback)
    LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", "a_ui_currency_dj_hui", "equip_icon")
    local stars = luaBehaviour:FindGameObject("stars")
    stars:SetActive(false)
end

function M:createObj(name,parent)
    local obj = ResourceUtil:LoadUIGameObject(name,Vector3.zero,parent)
    return obj
end

function M:playSyntheticMysticAnim()
    local cell_obj = self.m_list_scroll.m_cache_cells[self.m_model.m_index]
    if not IsNull(cell_obj) then
        self:lockTouch()
        local UI_MysticDepository_Miji_02 = self:findGameObject("UI_MysticDepository_Miji_02")
        local select_cell_obj_trans = cell_obj.transform
        local trans = UI_MysticDepository_Miji_02.transform
        local pos = select_cell_obj_trans.parent:TransformPoint(select_cell_obj_trans.localPosition) --世界坐标
        pos = trans.parent:InverseTransformPoint(pos) -- 相对坐标
        trans.localPosition = pos
        UI_MysticDepository_Miji_02:SetActive(true)
        self.m_control:setOnceTimer(1.2,function()
            self:unlockTouch()
            UI_MysticDepository_Miji_02:SetActive(false)
            self:refreshUI(true)
        end)
    else
        self:refreshUI(true)
    end
end

--[[	
	属性列表
]]
function M:updateAllAttrLoopScroll()
    local data = self.m_model:getAllAttr()
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("all_attrs_loopscroll")
        local params = {
            show_data = data,
            one_line_count = 2,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local attr = cell_data
                local transform = cell_object.transform
                local attr_cfg = GameUtil:getAttrCfg(attr[1])
                UIUtil.setTextByLanKey(transform, "type_text", Language:getTextByKey(attr_cfg.name) .. ":")
                UIUtil.setTextByLanKey(transform, "vein_desc", "+" .. (attr_cfg.is_percent == 1 and tostring(attr[2]*100) .. "%" or tostring(attr[2])))
                --UIUtil.setTextByLanKey(transform, "vein_desc", Language:getTextByKey(attr_cfg.name) .. "+" .. (attr_cfg.is_percent == 1 and tostring(attr[2]*100) .. "%" or tostring(attr[2])))
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)

            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data)
    end
end

function M:updateChannelAttrLoopScroll()
    local data = self.m_model:getChannelAttr()
    if next(data) == nil then
        self:setObjectVisible("channel_attr_title_text", false)
        self:setObjectVisible("channel_attr_node", false)
    end

    if self.m_channel_attrs_scroll_view == nil then
        local loopscroll = self:findGameObject("channel_attrs_loopscroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local attr = cell_data.attr
                local transform = cell_object.transform
                local attr_cfg = GameUtil:getAttrCfg(attr[1])
                local type_str = Language:getTextByKey(attr_cfg.name) .. ":"
                local value = type_str.. "+" .. (attr_cfg.is_percent == 1 and tostring(attr[2]*100) .. "%" or tostring(attr[2]))
                if cell_data.open then
                    UIUtil.setTextByLanKey(transform, "vein_desc", value)
                    UIUtil.setTextColor(transform, Color( 155/255, 173/255, 213/255, 1), "type_text")
                    UIUtil.setTextColor(transform, Color( 107/255, 243/255, 28/255, 1), "vein_desc")
                else
                    local type_meridian = GlobalConfig.TYPE_MERIDIAN_OLD[cell_data.meridian_type]
                    local global_cfg = GlobalConfig.TYPE_MERIDIAN[cell_data.mystic_type]
                    local str = value.."  ".. Language:getTextByKey("tid#Meridianstips_1",Language:getTextByKey(type_meridian.name),cell_data.lv)
                    UIUtil.setTextByLanKey(transform, "vein_desc", str)
                    UIUtil.setTextColor(transform, Color(1,0.94, 0.8, 1), "vein_desc")
                    UIUtil.setTextColor(transform, Color( 1,0.94, 0.8, 1), "type_text")
                end
            end,
        }
        self.m_channel_attrs_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_channel_attrs_scroll_view:reloadData(data)
    end
end

-- 镶嵌属性
function M:updateInsetAttrLoopScroll()
    local data = self.m_model:getInsetAttr()
    if next(data) == nil then
        self:setObjectVisible("inset_attr_node", false)
    else
        self:setObjectVisible("inset_attr_node", true)
    end
    if self.m_Inset_attrs_scroll_view == nil then
        local loopscroll = self:findGameObject("inset_attrs_loopscroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
                local mystic = self.m_model:getMysticListDataByIndex(self.m_model.m_index)
                local effect_flag = UserDataManager.mystic_data:getWaitUpAttr(mystic.id, cell_data)
                if effect_flag then 
                    self.m_control:setOnceTimer(0.4, function()
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"UI_UnionArtifactPop_JingYan_01", true)
                    end)
                    self.m_control:setOnceTimer(0.7, function()
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"UI_UnionArtifactPop_JingYan_01", false)
                    end)
                end
                local attr = cell_data.attr
                local num = cell_data.num
                local attr_cfg = GameUtil:getAttrCfg(attr[1])
                local type_str = Language:getTextByKey(attr_cfg.name) .. ":"
                local count = math.floor(num/cell_data.condition[2])
                local value = attr_cfg.is_percent == 1 and tostring(attr[2]*count*100) .. "%" or tostring(attr[2])
                local quality_cfg = GlobalConfig.QUALITY_COMMON_SETTING[cell_data.condition[3]]
                local condition_str = "???"
                if cell_data.condition[1] == 1 then
                    condition_str = Language:getTextByKey(quality_cfg.name) .. Language:getTextByKey("shareLv_str_0023")
                elseif cell_data.condition[1] == 2 then
                    condition_str = Language:getTextByKey(quality_cfg.name) .. Language:getTextByKey("shareLv_str_0023")
                    if cell_data.type == 1 then -- 先天
                        condition_str = condition_str .. Language:getTextByKey("mystic_str_0056")
                    elseif cell_data.type == 2 then -- 绝技
                        condition_str = condition_str .. Language:getTextByKey("mystic_str_0057")
                    elseif cell_data.type == 3 then -- 神技
                        condition_str = condition_str .. Language:getTextByKey("mystic_str_0085")
                    end
                elseif cell_data.condition[1] == 3 then
                    condition_str = Language:getTextByKey(cell_data.name)
                end
                local add_value = attr_cfg.is_percent == 1 and tostring(attr[2]*100) .. "%" or tostring(attr[2])
                local str = type_str .. "+" .. value .. Language:getTextByKey("mystic_str_0088",cell_data.condition[2], condition_str, add_value)
                if num >= cell_data.condition[2] then
                    LuaBehaviourUtil.setText(luaBehaviour, "vein_desc", str)
                    LuaBehaviourUtil.setTextColor(luaBehaviour,"vein_desc", Color( 107/255, 243/255, 28/255, 1))
                else
                    LuaBehaviourUtil.setText(luaBehaviour, "vein_desc", str)
                    LuaBehaviourUtil.setTextColor(luaBehaviour,"vein_desc", Color( 0.68,0.35, 0.18, 1))
                end
            end,
        }
        self.m_Inset_attrs_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_Inset_attrs_scroll_view:reloadData(data)
    end
end

-- 奥义解放
function M:updateInsetSkillAttrLoopScroll()
    local data = self.m_model:getInsetSkillAttr()
    if next(data) == nil then
        self:setObjectVisible("inset_skill_attr_node", false)
    else
        self:setObjectVisible("inset_skill_attr_node", true)
    end
    if self.m_Inset_skill_attrs_scroll_view == nil then
        local loopscroll = self:findGameObject("inset_skill_attrs_loopscroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
                local num = cell_data.num
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "vein_desc", cell_data.des)
                if num >= cell_data.condition[2] then
                    LuaBehaviourUtil.setTextColor(luaBehaviour,"vein_desc", Color( 107/255, 243/255, 28/255, 1))
                else
                    LuaBehaviourUtil.setTextColor(luaBehaviour,"vein_desc", Color( 0.68,0.35, 0.18, 1))
                end
            end,
        }
        self.m_Inset_skill_attrs_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_Inset_skill_attrs_scroll_view:reloadData(data)
    end
end

-- 镶嵌列表
function M:updateInsetScroll()
    local data = self.m_model:getInsetSlot()
    if self.m_inset_slot_list_scroll == nil then
        local list_scroll = self:findGameObject("inset_list_scroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 3,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                if cell_data.id then
                    self:setCellHander(cell_object, cell_data.id)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"camp_img", true)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"red_point_img", false)
                else
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"have_panel", false)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"no_panel", true)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"no_quality_up_img", false)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"vocation_img", false)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"camp_img", false)
                    local mystic_data = self.m_model:getMysticListDataByIndex(self.m_model.m_index)
                    if self.m_model:checkMysticNewRedPoint(mystic_data.id) then
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"red_point_img", true)
                    else
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"red_point_img", false)
                    end
                    if index == 1 then
                        local show_finger = UserDataManager.local_data:getUserDataByKey("mystic_inset_finger", 1)
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"item_finger_sp", show_finger == 1)
                    end
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("click_inset_slot", {data = cell_data, slot = index})
                local show_finger = UserDataManager.local_data:getUserDataByKey("mystic_inset_finger", 1)
                if show_finger == 1 then
                    UserDataManager.local_data:setUserDataByKey("mystic_inset_finger", 0)
                end
            end
        }
        self.m_inset_slot_list_scroll = LoopScrollViewUtil.new(params)
        --list_scroll:GetComponent("ScrollRect").vertical = false
    else
        self.m_inset_slot_list_scroll:reloadData(data)
    end
    
end

function M:destroy()
    audio:SendEvtUI("Reset_Lpf_Amb_2D_wind_bird_water_frog")
    audio:SendEvtBGM("Set_State_ShiWu01")
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end

return M