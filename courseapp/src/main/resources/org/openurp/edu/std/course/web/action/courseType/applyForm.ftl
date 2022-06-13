[#ftl]
[@b.head /]
[@b.toolbar title="学生个人成绩课程类别变更申请"]
    bar.addBack();
[/@]
[#if grades??]
[@b.form name="applyForm" theme="list"  action="!doApply" onsubmit="return checkCourse()"]
    [@b.field label="学号" required='true']${std.user.code} ${std.user.name}    [/@]
    [@b.field label="课程成绩" required='true']
        <select id="grade" name="apply.course.id" style="width:300px;" onchange="changeType(this.form,this.value)">
         <option value="">请选择课程...</option>
         [#list grades?keys as course]
            <option value="${(course.id)!}">${course.name}${course.code} ${grades.get(course).courseType.name}</option>
         [/#list]
        </select>
    [/@]

    [@b.select label="新的类别" required='true' name="apply.newType.id" items=courseTypes style="width:200px"/]
    [@b.textarea name='apply.remark' label='备注' cols="46" rows="2" value="${(apply.remark?html)!}" required="true" maxlength="200" comment="最多200字"/]
    [@b.formfoot]
        <input type="hidden" name="apply.oldType.id" value=""/>
        <input type="hidden" name="projectId" value="${std.project.id}"/>
        [@b.submit value="action.submit" /]
    [/@]
[/@]

<script>
    var gradeTypes={}
    [#list grades?keys as c]
      gradeTypes["${c.id}"]=${grades.get(c).courseType.id};
    [/#list]

    function changeType(form,courseId){
      if(courseId){
        form['apply.oldType.id'].value=gradeTypes[courseId];
      }else{
        form['apply.oldType.id'].value="";
      }
    }

    function checkCourse(){
        var form=document.applyForm;
        if(!form['apply.oldType.id'].value){
          alert("请选择需要更改类别的成绩");
          return false;
        }
        return true;
    }
</script>
[#else]
   没有找到你的培养计划和成绩。
[/#if]
[@b.foot /]
