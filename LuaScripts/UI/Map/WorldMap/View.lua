local M = class("WorldMapView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "Map/WorldMap"
M.m_iphoneXAdapter = true
--
function M:onEnter()
    self:creatChapter()
end

function M:creatChapter()
    local chapter_list = self.m_model:getChapterList()
    local chapter_pos = self.m_model:getChapterPos()
    local stage_btns = self:findGameObject("stage_btns")
    for k,v in pairs(chapter_list) do
        local stage_obj = self:creatPrefabe(stage_btns)
        UIUtil.setLocalPosition(stage_obj.transform,chapter_pos[k][1],chapter_pos[k][2],0)
        UIUtil.setObjectVisible(stage_obj.transform,k == self.m_model.cur_chapter,"cur_stage")
        local function click()
            self:updateMsg("click_stage", k)
        end
        UIUtil.setButtonClick(stage_obj.transform,click)
    end
end

function M:creatPrefabe(stage_btns)
    local btns = ResourceUtil:LoadUIGameObject("Map/worldmap_iden", Vector3.zero, stage_btns)
    return btns
end

return M