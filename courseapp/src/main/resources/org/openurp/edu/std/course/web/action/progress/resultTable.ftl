[#ftl/]
<div class="grid" style="border:0.5px solid #006CB2">
<table width="100%" class="gridtable">
  <thead class="gridhead">
    <tr>
      <th width="5%">课程</th>
      <th width="10%">代码</th>
      <th width="30%">名称</th>
      <th>学分</th>
      <th>完成学分</th>
      <th>成绩</th>
      <th>通过否</th>
      <th width="20%">备注</th>
    </tr>
  </thead>
  [@groupsData planAuditResult.topGroupResults,1/]
</table>
</div>
[#macro groupsData courseGroups,lastNum]
  [#list courseGroups as group]
    <tr class="darkColumn" style="font-weight: bold">
      <td colspan="3" style="padding-left: 5px;text-align: left;">[#list 1..lastNum as d][/#list]${sg.next(lastNum)}&nbsp;${(group.name)?if_exists}[#if (group.children?size>0)]<span style="font-weight: normal">([#if (group.groupRelation.relation)?default('and')='and']所有子项均应满足要求[#else]所有子项至少一项满足要求[/#if])</span>[/#if]</td>
      <td align="center">${(group.auditStat.requiredCredits)?default('')}</td>
      <td align="center">${(group.auditStat.passedCredits)?default('')} [#if ((group.auditStat.convertedCredits)>0)](转换${(group.auditStat.convertedCredits)}学分)[/#if]</td>
      <td></td>
      <td align="center">
        [#if group.passed]是[#else]<font color='red'>[#if (group.auditStat.requiredCredits > group.auditStat.passedCredits+group.auditStat.convertedCredits)]缺${(group.auditStat.requiredCredits)-(group.auditStat.passedCredits)-(group.auditStat.convertedCredits)}分[#else]否[/#if]</font>
        [#if (group.auditStat.requiredCount > group.auditStat.passedCount)]<font color='red'>缺${(group.auditStat.requiredCount)-(group.auditStat.passedCount)}门</font>[/#if]
        [/#if]
      </td>
      <td align="center">&nbsp;</td>
    </tr>
     [#list group.courseResults as courseResult]
     [#local coursePassed=courseResult.passed/]
     <tr>
         <td align="center">${courseResult_index+1}</td>
         <td width="10%" style="padding-left: 5px;text-align: left;">${(courseResult.course.code)?default('')}</td>
         <td style="padding-left: 5px;text-align: left;">${(courseResult.course.name)?default('')}</td>
         <td align="center">${(courseResult.course.credits)?default('')}</td>
         <td align="center">[#if coursePassed]${(courseResult.course.credits)?default('')}[#else]0[/#if]</td>
         <td align="center">${courseResult.scores!}</td>
         <td align="center">${courseResult.passed?string("是","<font color='red'>否</font>")}</td>
         <td align="center">${courseResult.remark?if_exists}</td>
     </tr>
     [/#list]
      [#if (group.children?size!=0)]
      ${sg.reset(lastNum+1)}
      [@groupsData group.children,lastNum+1/]
    [/#if]
  [/#list]
[/#macro]
