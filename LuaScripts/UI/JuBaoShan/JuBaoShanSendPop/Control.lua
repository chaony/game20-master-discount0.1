--悬赏列表
local M = class("JuBaoShanSendPopControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg, data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "clickHeroCell" then
        audio:SendEvtUI("Play_UI_HeroSelected");
        local cell_data = data.clickData;
        local index = data.index;
        local stateData = data.stateData;
        local show = stateData.show;
        local lock = stateData.lock;
        local evo_condition = {}
        --需要的条件
        local slotNum = 0;
        for i, v in pairs(cell_data.cell_config.slot) do
            slotNum = slotNum + 1;
            evo_condition[i] = v;
        end
        if lock == true then
            local lv = evo_condition[index][1]
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("jubaoShan_str_022", lv), delay_close = 2})
        elseif show == true then
            SceneManager:getCurSceneModel():FocusBuilding(cell_data)
            self:closeView()
        end
    end
end


return M;
