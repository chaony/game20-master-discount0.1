---@class AdditionSupportSystemView:OOPopBase
---@field m_model AdditionSupportSystemModel
local M = class("AdditionSupportSystemView",LikeOO.OOPopBase)

M.m_uiName = "AdditionSupportSystem/AdditionSupportSysPop"  -- prefab name
M.m_size_type = 2

function M:onEnter()
    self:initUI()
    --self:refreshUI()
end

function M:initUI()
    local toggle_name=nil
    for i = 1, 6 do
        toggle_name="martial_toggle_"..i
        local tog_btn = self:findToggle(toggle_name)
        local item = self:findGameObject(toggle_name)
        if self.m_model.selectType_index == i then
            UIUtil.setToggleIsOn(item.transform, true)
            UIUtil.setObjectVisible(item.transform, true,"UI_ShareLv_Xuanze_01")
        end
        UIUtil.addToggleListener(tog_btn, function(is_on, data)
            if is_on then
                self:updateMsg("tab_btn",{index = data})
                UIUtil.setObjectVisible(item.transform, true,"UI_ShareLv_Xuanze_01")
            else
                UIUtil.setObjectVisible(item.transform, false,"UI_ShareLv_Xuanze_01")
            end
        end, i, self.m_uiName)
    end

    self.m_gray_img = self:findImage("gray_img")

    self:setTextByLanKey("tip_text","supportSys_str_0002")
    self:setTextByLanKey("close_title_text","supportSys_str_0004")
    self.support_num_text_trans=self:findGameObject("support_num_text").transform

    self:switchTagView()
    self:updateUsageNum()
end

function M:refreshUI()
    self:switchTagView()
    self:updateUsageNum()
end

function M:switchTagView()
    local oids=self.m_model:getCurTagOids()

    for pos= 0, 4 do
        local hero_trans=self:findGameObject("hero_"..(pos+1)).transform
        local _pos=pos
        local oid=oids[tostring(pos)]
        if oid then
            local luaBehaviour=UIUtil.findLuaBehaviour(hero_trans,"MainHeroNodeCell")

            luaBehaviour:RegistButtonClick(function (obj,name)
                self.m_cur_click_hero_trans=hero_trans
                self.m_model:setCurOpPos(_pos)
                self.m_control:openView("HeroBag.AdditionSupportSystem.SelectSupportHero",
                        {support_oid= oid, race_id=self.m_model.m_race_id, selectedHeros=self.m_model:getCurTagOids()})
            end)
            self:updateHero(hero_trans,oid)
        else
            if self.m_model:isVacant() then
                --local empty_btn_trans=UIUtil.findTrans(hero_trans,"empty_btn")
                self:setEmptyState(hero_trans,true)
                UIUtil.setButtonClick(hero_trans,function(trans,params)
                    self.m_model:setCurOpPos(_pos)
                    self.m_control:openView("HeroBag.AdditionSupportSystem.SelectSupportHero",{
                        race_id=self.m_model.m_race_id,
                        selectedHeros=self.m_model:getCurTagOids(),
                        support_oid=oid
                    })
                    self.m_cur_click_hero_trans=hero_trans
                end,nil,"empty_btn")
            else
                self:setLockedState(hero_trans)
                UIUtil.setButtonClick(hero_trans,function(trans,params)
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("supportSys_str_0008"), delay_close = 2})
                end,nil,"lock_img")
            end
        end

        UIUtil.setTextByLanKey(hero_trans,"empty_text","supportSys_str_0003")
    end
end

function M:updateHero(hero_trans,oid)
    if oid and oid~="" then
        self:showHero(hero_trans,oid)
        self:updateAttriAddition(hero_trans,oid)
    else
        self:setEmptyState(hero_trans,true)
    end
end

function M:updateCurOp(oid)
    self:updateHero(self.m_cur_click_hero_trans,oid)
end


function M:updateAttriAddition(hero_trans, oid)
   local hero_data, _= UserDataManager.hero_data:getHeroDataById(oid)
    local attr_cfg=ConfigManager:getCfgByName("hero_help_attr")
    local is_fate = UserDataManager:getHeroIsFates(hero_data.oid)

    local evo=hero_data.evo
    --天命时不用后台evo直接100
    if is_fate then
        evo=100
    end
    local attrs=attr_cfg[evo].attrs

    local attr_trans=UIUtil.findTrans(hero_trans,"attr")
    self:setAttriNameText(attr_trans,"atk_text",attrs[1][1])
    self:setAttriNameText(attr_trans,"def_text",attrs[2][1])
    self:setAttriNameText(attr_trans,"hp_text",attrs[3][1])

    self:setAttriValueText(attr_trans,"atk_value_text",attrs[1][1],attrs[1][2])
    self:setAttriValueText(attr_trans,"def_value_text",attrs[2][1],attrs[2][2])
    self:setAttriValueText(attr_trans,"hp_value_text",attrs[3][1],attrs[3][2])
end

function M:setAttriNameText(hero_trans,textPath,nameKey)
    local name=GameUtil:getAttrsName("",nameKey)
    UIUtil.setText(hero_trans,name,textPath)
end

function M:setAttriValueText(hero_trans,textPath,id,num)
    local key = GameUtil:getAttrsKey(id)
    if GameUtil:canPerAttrTransition(key) == true then
        num = GameUtil:formatNum(num * 100)
    end
    if GameUtil:attrTransition(key) == true then
        UIUtil.setText(hero_trans, "+"..tostring(num).."%", textPath)
    else
        UIUtil.setText(hero_trans, "+"..tostring(num), textPath)
    end
end

function M:updateUsageNum()
    self:setTextByLanKey("support_num_text","supportSys_str_0001",self.m_model.usageNum,
            self.m_model.unlockNum)
end

function M:showHero(heroTrans,oid)
    self:setEmptyState(heroTrans,false)
    local MainHeroNodeCell_trans=UIUtil.findTrans(heroTrans,"MainHeroNodeCell")
    GameUtil:updateHeroContent(MainHeroNodeCell_trans.gameObject, oid)
end

function M:setEmptyState(heroTrans, empty)
    local notEmpty=not empty
    UIUtil.setObjectVisible(heroTrans, notEmpty,"MainHeroNodeCell")
    UIUtil.setObjectVisible(heroTrans, empty,"empty_btn")
    UIUtil.setObjectVisible(heroTrans, notEmpty,"attr")
    UIUtil.setObjectVisible(heroTrans, false,"lock_img")

    local bg=UIUtil.findImage(heroTrans,"bg")
    bg.material=nil
end

function M:setLockedState(heroTrans)
    UIUtil.setObjectVisible(heroTrans, false,"MainHeroNodeCell")
    UIUtil.setObjectVisible(heroTrans, false,"empty_btn")
    UIUtil.setObjectVisible(heroTrans, false,"attr")
    UIUtil.setObjectVisible(heroTrans, true,"lock_img")

    local bg=UIUtil.findImage(heroTrans,"bg")
    bg.material=self.m_gray_img.material
end



function M:destroy()
    M.super.destroy(self)
end
 

return M