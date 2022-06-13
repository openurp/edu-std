[#ftl]
[@b.head /]
[@b.toolbar title="学生个人替代课程申请"]
    bar.addBack();
[/@]
<style>
  #alternativeCourseForm fieldset.listset li > label.title{
      min-width:120px;
  }
</style>
[@b.form name="alternativeCourseForm" theme="list"  action="!doApply"]
    [@b.field label="学号" required='true']${std.user.code} ${std.user.name}    [/@]
    [@b.select label="原课程(计划内)" name="originIds" items=planCourses required='true'
               option=r"${item.name} (${item.code} ${item.credits}学分)"
               comment="计划中的课程" style="width:500px;" multiple="true"/]

    [@b.select label="替代课程(有成绩)" name="substituteIds" items=gradeCourses required='true'
               option=r"${item.name} (${item.code} ${item.credits}学分)"
               comment="成绩中的课程" style="width:500px;" multiple="true"/]
    [@b.textarea name='apply.remark' label='备注' cols="46" rows="2" value="${(apply.remark?html)!}" required="true" maxlength="200" comment="最多200字"/]
    [@b.formfoot]
        <input type="hidden" name="projectId" value="${std.project.id}"/>
        [@b.submit value="action.submit" /]
    [/@]
[/@]
[@b.foot /]
