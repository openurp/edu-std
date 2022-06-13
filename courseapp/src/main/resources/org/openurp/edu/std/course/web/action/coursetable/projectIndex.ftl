[#ftl]
[@b.head/]
<div class="container">
<script language="JavaScript" type="text/JavaScript" src="${base}/static/edu/TaskActivity.js?v=20210313"></script>
[@b.toolbar title="我的课表"/]
[@urp_base.semester_bar value=semester! formName='courseTableForm']
  <label class="title">课表类型:</label>
  <input type="hidden" name="projectId" value="${std.project.id}">
  <input type="hidden" name="setting.category" value="${setting.category}">
  [#if setting.category=="std"]个人课表[#else]<a href="#" onclick="searchTable('std')">个人课表</a>[/#if]
  [#if (std.state.squad)??]|[#if setting.category=="squad"]${std.state.squad.name}班级课表[#else]<a href="#" onclick="searchTable('squad')">${std.state.squad.name}班级课表</a>[/#if][/#if]
  |
  <label for="weekIndex" class="title">教学周:</label>
    <select id="weekIndex" name="weekIndex" onchange="searchTable()" style="width:120px">
      <option value="*">全部</option>
      [#list 1..semester.weeks as i]<option value="${i}" [#if weekIndex==i?string]selected="selected"[/#if] >第${i}周</option>[/#list]
    </select>
    |
[/@]
 [#macro getTeacherNames(beanList)][#list beanList as bean][#if bean_index>0],[/#if]${(bean.user.name)!}[/#list][/#macro]
 [#macro getListName(beanList)][#list beanList as bean][#if bean_index>0],[/#if]${(bean.name)!}[/#list][/#macro]
 [#include "courseTableStyle.ftl"/]
 [@initCourseTable table,1/]
 [#if setting.displayClazz]
   <br>
   [#assign taskList=table.clazzes]
   [#if table.category=="squad"][#include "squadTaskList.ftl"/][#else][#include "stdTaskList.ftl"/][/#if]
 [/#if]
<script language="JavaScript">
  var form = document.courseTableForm;
     function resetWeek(){
       $("#weekIndex").val("*")
     }
     function searchTable(category){
       if(category){
          form['setting.category'].value=category;
       }
       if(jQuery("#courseTableType").val()=="std"){
         bg.form.addInput(form,"ids","${(std.id)!}");
       }else{
         bg.form.addInput(form,"ids","${(std.state.squad.id)!}");
       }
       bg.form.submit(form,'${b.url("!projectIndex")}');
     }
 </script>
</div>
[@b.foot/]
