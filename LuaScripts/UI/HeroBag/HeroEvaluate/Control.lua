---@class HeroEvaluateControl:OOControlBase
---@field m_model HeroEvaluateModel
local M = class("HeroEvaluateControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "CloseBtn" then    -- 返回
        self:closeView()
        --if self.m_model.new_reward and 	table.nums(self.m_model.new_reward) > 0 then
           -- self.m_model.m_callback({rewards=self.m_model.new_reward})
        --end
    elseif msg == "tab_btn" then
        if data ~= self.m_model.m_tab_index then
            self.m_model:setTabIndex(data)
            self.m_view:refreshUI()
        end
    elseif msg == "stars" or msg == "min_btn" then
       self:openView("HeroBag.HeroEvaluateScore")
    elseif msg =="update_score" then --点击打分确定按钮
        self:updateScore(data)
    elseif msg =="send_btn" then --点击评论按钮
        self:addComment()
    elseif msg == "give_no_btn" then --点赞评论
        self:likeComment(data)
    elseif msg == "give_yes_btn" then --q取消点赞评论
        self:unlikeComment(data)
    elseif msg == "comments_by_range" then --数据拉到底了 通过服务器取新的数据
        self:byRangeComment(data)
    elseif msg == "show_report" then
        self:openReport(data)
    end
end
function M:byRangeComment( data )
    local end_id = self.m_model.max_comment_id - #self.m_model.m_newlist_data
    if end_id > 0 then
        local function callfunc(response)
            self.m_model:addEvaluateData(response)
            self.m_view:refreshUI()
        end
        self.m_model:getNetData("hero_evaluate_comments_by_range", {hero_id = self.m_model.hero_oid,end_id = end_id}, callfunc)
    end
    
end


function M:addComment( ... )
    local text = self.m_view:getMsg()
    local function callfunc(response)
        self.m_model:setEvaluatelast_eva_ts(response)
        self.m_model:addEvaluateData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("hero_evaluate_add_comment", {hero_id = self.m_model.hero_oid,content = text}, callfunc)
end

function M:likeComment( data )
    local text = self.m_view:getMsg()
    local function callfunc(response)
        if response.comments ~= nil then
           self.m_model:setEvaluateData(response)
           self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("hero_evaluate_like", {hero_id = self.m_model.hero_oid,comment_id = data.cell_data.cmt_id}, callfunc)
end

function M:unlikeComment( data )
    local text = self.m_view:getMsg()
    local function callfunc(response)
        if response.comments ~= nil then
           self.m_model:setEvaluateData(response)
           self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("hero_evaluate_unlike", {hero_id = self.m_model.hero_oid,comment_id = data.cell_data.cmt_id}, callfunc)
end

function M:updateScore( data )
    if data.m_num >0 then
        local score = data.m_num * 2
        local function callfunc(response)
            self.m_model:setEvaluatehero_score(response)
            self.m_view:refreshUI()
        end
        self.m_model:getNetData("hero_evaluate_update_score", {hero_id = self.m_model.hero_oid,score = score }, callfunc)
    end
   
end

function M:openReport(index)
    local self_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
    local data = self.m_view.m_list_scroll.m_show_data[index]
    if tonumber(self_uid) == tonumber(data.uid) then
        return
    end
    local obj = self.m_view.m_list_scroll.m_cache_cells[index]
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local text_obj = luaBehaviour:FindGameObject("desc_text")
    self:openView("Pops.ReportBtnPop", {uid = data.uid, name = data.name, chat = data.content, module_id = 2, obj = text_obj})
end

return M