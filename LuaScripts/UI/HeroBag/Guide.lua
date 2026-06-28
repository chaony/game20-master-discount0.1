local guide = class("HeroBag", LikeOO.OOGuideBase)

-- 点击升级
function guide:excuteGuideFunc1(info)
	local lv = info.target[1]
	if self.m_model.m_cur_Lv < lv then
        local hero_bag = self.m_view.m_cur_tab_node["right"]
        if hero_bag == nil then
            return
        end
        -- self.m_control.slid_lock = true
        local function m_levelupclick()
            self.m_control:updateMsg("click_up")
        end
        hero_bag.m_cur_tab_node:addActionChangAn("levet_up_btn",m_levelupclick)

	    local node = hero_bag.m_cur_tab_node:findGameObject("levet_up_btn")
	    if node then
	        self.m_listener = {
	            key = "click_up",
	        }   
	        self:guideTargetNode(node.transform, 1, 1)
	    end
	else
		self:doNextGuide()
	end
end

-- 一键穿装
function guide:excuteGuideFunc2(info)
    local hero_node = self.m_view.m_cur_tab_node["center"]
    local node = hero_node:findGameObject("put_on_btn")
    if node then
        -- self.m_control.slid_lock = true
        self.m_listener = {
            key = "put_on_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 长按升级
function guide:excuteGuideFunc3(info)
    local lv = info.target[1]
    if self.m_model.m_cur_Lv < lv then
        local hero_bag = self.m_view.m_cur_tab_node["right"]
        if hero_bag == nil then
            return
        end
        -- self.m_control.slid_lock = true
        local function m_levelupclick()
            --GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#GuideAsk_086"), delay_close = 2})
            self.m_control:updateMsg("click_up")
        end
        local function m_leveluppress()
            self.m_control:updateMsg("pass_on")
        end
        hero_bag.m_cur_tab_node:addActionChangAn("levet_up_btn",m_levelupclick, m_leveluppress)

        local node = hero_bag.m_cur_tab_node:findGameObject("levet_up_btn")
        if node then
            self.m_listener = {
                key = "pass_on",
                key2 = "click_up",
                --check = function()
                --    return self.m_model.m_cur_Lv >= lv
                --end
            }
            self:guideTargetNode(node.transform, 1, 1, nil, 2)
        end
    else
        self:doNextGuide()
    end
end

-- 点击特定武神
function guide:excuteGuideFunc4(info)
    local target = info.target[1]
    local hero_bag = self.m_view.m_cur_tab_node["left"]
    local node = nil
    self.m_view:lockTouch()
    local function endCallBack()
        self.m_view:unlockTouch()
        for i,v in ipairs(hero_bag.m_list_scroll.m_show_data or {}) do
            local hero, cfg = UserDataManager.hero_data:getHeroDataById(v)
            if cfg.id == target then
                hero_bag.m_list_scroll:moveToCellIndex(i)
                break
            end
        end

        for i,v in ipairs(hero_bag.m_list_scroll.m_show_data or {}) do
            local hero, cfg = UserDataManager.hero_data:getHeroDataById(v)
            if cfg.id == target then
                local cell_node = hero_bag.m_list_scroll.m_cache_cells[i]
                if cell_node then
                    node = cell_node
                    break
                end
            end
        end

        if node then
            self.m_listener = {
                key = "select_hero",
                check = function (data)
                    local hero, cfg = UserDataManager.hero_data:getHeroDataById(data.id)
                    if cfg.id == target then
                        return true
                    end
                end
            }
            self:guideTargetNode(node.transform, 1, 1)
        else

        end
    end
    self.m_control:setOnceTimer(0.28, endCallBack)
end

-- 点击养成
function guide:excuteGuideFunc5(info)
    local hero_center = self.m_view.m_cur_tab_node["center"]
    local node = hero_center:findGameObject("cultivate_btn")
    if node then
        self.m_listener = {
            key = "cultivate_btn",
        }   
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 升级后返回挂机界面
function guide:excuteGuideFunc6(info)
    self.m_listener = {
        key = 99999,
    }
    local btn = self.m_view:findGameObject("close_btn")
    if btn then 
        local function clickback()
            Logger.log("HeroBag back guid ---------")
            self.m_control:sendLvUpNet(function()
                self.m_control:updateMsg("common_refresh",nil,"parent")
            end)
        end
        self:guideTargetNode(btn.transform, 1, 3, nil,nil,nil,nil,nil,nil,clickback)
    end
end

-- 点击神兵
function guide:excuteGuideFunc7(info)
    local hero_center = self.m_view.m_cur_tab_node["center"]
    local node = hero_center:findGameObject("eq5_btn")
    if node then
        self.m_listener = {
            key = "eq5_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 点击经脉
function guide:excuteGuideFunc8(info)
    local hero_center = self.m_view.m_cur_tab_node["center"]
    local node = hero_center:findGameObject("activate_btn")
    if node then
        self.m_listener = {
            key = "activate_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 激活经脉
function guide:excuteGuideFunc9(info)
    local hero_center = self.m_view.m_cur_tab_node["center"]
    local node = hero_center:findGameObject("intensify_btn")
    if node then
        self.m_listener = {
            key = "intensify_btn",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 点击身上有蓝以上装备的英雄
function guide:excuteGuideFunc10(info)
    local target = info.target[1]
    local heros = self.m_model.hero_list
    local node = nil

    for i,v in ipairs(heros) do
        local hero, cfg = UserDataManager.hero_data:getHeroDataById(v)
        local flag = false 
        for k,vv in pairs(hero.equips or {}) do
            local equ_cfg = UserDataManager.equip_data:getEquipConfigByCid(vv.id)
            if equ_cfg and equ_cfg.quality >= target and vv.lv == 0 then
                flag = true
                break
            end
        end
        if flag then
            local hero_bag = self.m_view.m_cur_tab_node["left"]
            hero_bag.m_list_scroll:moveToCellIndex(i)
            local cell_node = hero_bag.m_list_scroll.m_cache_cells[i]
            if cell_node then
                node = cell_node
                break
            end
        end
    end

    if node then
        self.m_listener = {
            key = "select_hero",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 点击蓝以上装备
function guide:excuteGuideFunc11(info)
    local target = info.target[1]
    local equ_list = self.m_model:getHeroEquList()
    local node = nil
    local key = ""
    for k,v in pairs(equ_list) do
        local equ_cfg = UserDataManager.equip_data:getEquipConfigByCid(v.id)
        if equ_cfg and equ_cfg.quality >= target and v.lv == 0 then
            key = "eq" .. k .. "_btn"
            node = self.m_view.m_cur_tab_node["center"]:findGameObject(key)
        end
    end
    if node then
        self.m_listener = {
            key = key,
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 点击羁绊中的详情按钮
function guide:excuteGuideFunc12(info)
    local hero_right = self.m_view.m_cur_tab_node["right"]
    if hero_right == nil then
        return
    end
    local obj = hero_right.m_cur_tab_node.m_list_scroll.m_cache_cells[1]
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    local node = LuaBehaviour:FindGameObject("guide_node")
    if node then
        self.m_listener = {
            key = "guide_fetter",
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 点击开启经脉的英雄
function guide:excuteGuideFunc13(info)
    local heros = self.m_model.hero_list
    local node = nil
    self.m_view:lockTouch()
    local hero_bag = self.m_view.m_cur_tab_node["left"]
    local function endCallBack()
        self.m_view:unlockTouch()
        for i,v in ipairs(heros) do
            local hero, cfg = UserDataManager.hero_data:getHeroDataById(v)
            local open_evo = ConfigManager:getMeridianOpenEvoByPos(1)
            if hero and hero.evo >= open_evo and cfg.evo >= 5 then
                local hero_bag = self.m_view.m_cur_tab_node["left"]
                hero_bag.m_list_scroll:moveToCellIndex(i)
                local cell_node = hero_bag.m_list_scroll.m_cache_cells[i]
                if cell_node then
                    node = cell_node
                    break
                end
            end
        end

        if node then
            self.m_listener = {
                key = "select_hero",
            }
            self:guideTargetNode(node.transform, 1, 1)
        end
    end
    self.m_control:setOnceTimer(0.28, endCallBack)
end

-- 点击经脉栏位
function guide:excuteGuideFunc14(info)
    local node = nil
    local key = ""
    for i = 1, 4 do
        local mai_img = self.m_view:findImage("mai_img_" .. i)
        local open_flag = self.m_model:meridanOpenFlagByPos(i)
        if open_flag then
            node = mai_img
            key = "mai_img_" .. i
        end
    end
    
    if node then
        self.m_listener = {
            key = key,
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 点击秘籍栏位
function guide:excuteGuideFunc15(info)
    local mystics = self.m_model:getHeroMysticData()
    for _,mystic_id in pairs(mystics) do
        if mystic_id ~= 0 then
            UserDataManager.guide_data:skipCurGuide()
            return
        end
    end
    local node = nil
    local key = ""
    local hero_right = self.m_view.m_cur_tab_node["right"]
    if hero_right == nil then
        return
    end
    if hero_right.m_cur_tab_node == nil then
        return
    end
    for i = 1, 4 do
        local mai_eq_btn = hero_right.m_cur_tab_node:findGameObject("mystic_eq_btn_" .. i)
        local open_flag = self.m_model:meridanOpenFlagByPos(i)
        if open_flag then
            node = mai_eq_btn
            key = "mystic_eq_btn_" .. i
        end
    end
    if node then
        self.m_listener = {
            key = key,
        }
        self:guideTargetNode(node.transform, 1, 1)
    end
end

-- 点击升级至xx级
function guide:excuteGuideFunc16(info)
    local hero_bag = self.m_view.m_cur_tab_node["right"]
    if hero_bag == nil then
        return
    end
    local can_q, q_lv = self.m_model:checkCanQuickLevelUp()
    if can_q == true then
        local node = hero_bag.m_cur_tab_node:findGameObject("quick_levet_up_btn")
        if node then
            self.m_listener = {
                key = "quick_levet_up_btn",
            }
            node:SetActive(true)
            self:guideTargetNode(node.transform, 1, 1)
        else
            self:doNextGuide()
        end
    else
        self:doNextGuide()
    end
end

-- 点击第几个侠客
function guide:excuteGuideFunc17(info)
    local target = info.target[1] or 1
    local hero_bag = self.m_view.m_cur_tab_node["left"]
    local node = nil
    hero_bag.m_list_scroll:moveToCellIndex(target)
    local cell_node = hero_bag.m_list_scroll.m_cache_cells[target]
    if cell_node then
        node = cell_node
    end
    if node then
        self.m_listener = {
            key = "select_hero",
        }
        self:guideTargetNode(node.transform, 1, 1)
    else
        self:doNextGuide()
    end
end

return guide