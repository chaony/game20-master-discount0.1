local M = class("JewelNewPopControl",LikeOO.OOControlBase)

function M:onEnter()
    --audio:SendEvtUI("Ui_JinJie")
    --self.m_guide_file_name = "UI.Jewel.JewelNewPop.Guide"
end

--[[function M:startGuide()
    M.super.startGuide(self)
    --self:triggerGuide()
end]]--

function M:onHandle(msg , data)
    if msg == 99999 then
        --self:updateMsg("close_new", nil, "Jewel.JewelGacha")
        self:updateMsg("close_new", nil, "Jewel.JewelGachaResultPop")
        local callback = self.m_model.m_callback
        if type(callback) == "function" then
            callback()
        end
        self:closeView()
    elseif msg == "big_close_btn" then
        self:closeView()
    end
end

return M