[#ftl]
[@b.head /]
<div class="container-fluid">
  [#include "nav.ftl"/]
  [@b.toolbar title="个人替代课程课程申请"]
    bar.addItem("申请","apply()",'action-new');
    function apply(){bg.form.submit(document.applyForm); }
  [/@]

  [@b.grid sortable="true" items=applies var="apply" style="border:0.5px solid #006CB2"]
    [@b.row]
      [@b.col width='25%' title="原课程代码、名称、学分"]
        [#list apply.olds as course] ${course.code} ${course.name} (${course.credits}) [#sep]<br>[/#list]
      [/@]
      [@b.col width='25%' title="替代课程代码、名称、学分"]
        [#list apply.news as course]${course.code} ${course.name} (${course.credits})[#sep]<br>[/#list]
      [/@]
      [@b.col width='10%' title="更新日期" property="updatedAt"]
         ${(apply.updatedAt?string('yy-MM-dd'))!}
      [/@]
      [@b.col width='10%' title="是否通过" property="approved"]
        [#if apply.approved??]
         ${apply.approved?string('是','否')} [#if !apply.approved]<span style="color:red">(${apply.reply!})</span>[/#if]
        [#else]
          未审核
        [/#if]
      [/@]
      [@b.col width="20%" title="说明" property="remark"/]
      [@b.col width="10%" title="操作"]
        [#if !((apply.approved)!false)]
          [@b.a href="!remove?apply.id="+apply.id]删除[/@]
        [/#if]
      [/@]
    [/@]
  [/@]
  [@b.form name="applyForm" action="!applyForm"]
    <input name="projectId" value="${project.id}" type="hidden"/>
  [/@]
  <div style="margin:auto;text-align: center;"><button onclick="apply()" class="btn btn-primary">开始申请</button></div>
</div>
[@b.foot /]
