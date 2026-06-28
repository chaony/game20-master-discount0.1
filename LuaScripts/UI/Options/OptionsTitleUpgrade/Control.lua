local M = class("OptionsTitleUpgradeControl",LikeOO.OOControlBase)

function M:onEnter()
    audio:SendEvtUI("Ui_JinJie")
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "big_close_btn2" then
        self:closeView()
    end
end

return M;
