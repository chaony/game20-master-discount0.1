---@class RelicChoiceNode:OOUIbase
---@field m_model SettlementModel
local M=class("RelicChoiceNode",LikeOO.OOUIbase)

M.m_uiName="Xiakedao/RelicChoiceNode"

function M:onEnter()
    --local optionalRelicData=self.m_model:optionalRelicData()
    local optionalRelicData=self.m_model.m_data.drop_heirlooms
    self:initHeirloomData(optionalRelicData)
    optionalRelicData=self.m_heirlooms_data
    local optionalRelicsTrans=self:findRectTransform("optionalRelics")
    local childNum=optionalRelicsTrans.childCount
    local child=nil
    local dataLen=#optionalRelicData
    for i = 1, childNum do
        child=optionalRelicsTrans:GetChild(i-1)
        if i<=dataLen then
            self:updateCellRelic(child,optionalRelicData[i],i)
            child.gameObject:SetActive(true)
        else
            child.gameObject:SetActive(false)
        end
    end

    self:setTextByLanKey("confirm_btn_text","new_str_1123")
    self:setTextByLanKey("common_title_text","new_str_1124")

    local onButtonClick=function(obj, name)
        if name=="confirm_btn" or name=="big_close_btn" then
            self:checkRelic()
        end
    end
    self.m_luaBehaviour:RegistButtonClick(onButtonClick)
end

function M:checkRelic()
    local function netCallback(response)

        if self.m_view then
            self:destroy()
        end
        self:destroy()
    end
    local  params= {heirloom=self.curCheckedId}
    self.m_model:getNetData("hero_isle_heirloom_rev", params, netCallback)
end

function M:initHeirloomData(heirlooms)
    local show_data = {}
    local heirlooms = heirlooms
    local heirloom = ConfigManager:getCfgByName("heirloom")
    for k,v in pairs(heirlooms) do
        local cfg = heirloom[v]
        if cfg then
            table.insert(show_data, {id = v, cfg = cfg})
        end
    end
    table.sort(show_data, function(data1, data2)
        return data1.cfg.quality > data2.cfg.quality
    end)
    self.m_heirlooms_data = show_data
end

function M:updateCellRelic(cell_object, cell_data,index)
    local data = cell_data
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local cfg = data.cfg
    CommonUIUtil:updateMazeStageRelicElement(cell_object, cfg)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "combat_node", false)
    local atkrating_ratio = cfg.atkrating_ratio or 0
    local atkrating_ratio_str = tostring(atkrating_ratio) .. "%"
    if atkrating_ratio > 0 then
        atkrating_ratio_str = "+" .. atkrating_ratio_str
    end
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_num_text", atkrating_ratio_str)
    --local combat_title_img = luaBehaviour:FindGameObject("combat_title_img")
    --GameUtil:setLanImgText(combat_title_img, "a_ui_zhanli")
    local attr_icon = luaBehaviour:FindGameObject("attr_icon")
    attr_icon:SetActive(true)
    local checkedGo=luaBehaviour:FindGameObject("checked")

    local function onButtonClick(obj, name)
        if self.curCheckedGo~=nil then
            self.curCheckedGo:SetActive(false)
        end
        self.curCheckedGo=checkedGo
        self.curCheckedGo:SetActive(true)

        self.curCheckedId=data.id
    end
    luaBehaviour:RegistButtonClick(onButtonClick)
    if index==1 then
        self.curCheckedId=data.id
    end
end
return M
