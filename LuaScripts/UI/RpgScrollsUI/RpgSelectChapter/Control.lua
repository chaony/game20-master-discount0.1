local M = class("RpgSelectChapterControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "click" then
        local params =  {
            ok_text = "重新开始",
            cancel_text = "继续",
            text = "目前正在攻略xx，放弃进度重新开始吗？",
            on_ok_call = function ()
                self:resetChapter(data)
            end,
            m_on_cancel_call = function ()
                self:resetChapter(data)
            end
        }
        if self.m_model:checkIsIn() == true then
            self:openView("RpgScrollsUI.RpgHintPop",params)
        else
            self:enterChapter(data)
        end
    elseif msg == "check" then
        local c_cfg, c_data = self.m_model:getChapterCfgByCId(data.c_id)
        self:openView("RpgScrollsUI.RpgEndPop", {c_id = data.c_id, ending_list = c_data.ending_list} ) 
    end
end

function M:resetChapter(c_id)
    local function receivetCallback(response)
     
    end
    self.m_model:getNetData("rpg_reset_chapter", {team_id = self.m_model.m_team_id, chapter_id = c_id}, receivetCallback)
end

function M:enterChapter(obj)
    local function receivetCallback(response)
        self:updateMsg(99999)
        self:openView("Shiguang",{ chapter_id = obj.c_id , team_id =  self.m_model.m_team_id } )
    end
    self.m_model:getNetData("rpg_enter_chapter", {team_id = self.m_model.m_team_id, chapter_id = obj.c_id }, receivetCallback)
end

return M
