[#ftl]
[@b.head/]
<div class="container-fluid">
[@b.toolbar title="期末考试安排"/]
[@urp_base.semester_bar value=semester!/]
[@b.messages slash='3'/]

<table width="100%" class="formTable">
  <tr align="center" bgcolor="#C7DBFF" height="23px">
    <td width="7%">课程序号</td>
    <td width="27%">课程名称</td>
    <td width="22%">课程类别</td>
    <td width="20%">考试时间</td>
    <td width="15%">考场(座位号)</td>
    <td width="9%">考试情况</td>
    [#--
    <td width="7%">补缓申请</td>
    <td width="7%">申请状态</td>
    --]
  </tr>
  [#list courseTakers?sort_by(["clazz","crn"]) as taker]
  [#if taker_index%2==1][#assign class="grayStyle"][/#if]
  [#if taker_index%2==0][#assign class="brightStyle"][/#if]
  <tr class="${class}" align="center" height="23px">
    <td>${(taker.clazz.crn)!}</td>
    <td>${(taker.clazz.course.name)!}</td>
    <td>${(taker.clazz.courseType.name)!}</td>
    [#if finalTakers.get(taker)?? ]
      [#assign examTaker = finalTakers.get(taker) /]
      [#if finalTakers.get(taker).activity?? && finalTakers.get(taker).activity.examOn??]
        [#assign activity = finalTakers.get(taker).activity]
        <td>
          [#if activity.publishState.timePublished]
            [#if activity.examOn??]${activity.examOn?string('yyyy-MM-dd')}&nbsp;&nbsp;[/#if][#if activity.beginAt?? && activity.endAt??]${(activity.beginAt)!}~${(activity.endAt)!}[/#if]
          [#else]
            <font color="BBC4C3">[尚未发布]</font>
          [/#if]
        </td>
        <td>[#if activity.publishState.roomPublished]${(examTaker.examRoom.room.name)!}(${examTaker.seatNo})[#else]<font color="BBC4C3">[尚未发布]</font>[/#if]</td>
        <td>${(examTaker.examStatus.name)!}</td>
       [#--<td>
          [#if examApplyMap?? && examApplyMap[examTaker.id?string]??]
            [@b.a href="!printApply?examApplyId=${examApplyMap[examTaker.id?string].id}"]查看[/@]
            [#if allowApplyDelay?? && allowApplyDelay]
              [#if examApplyMap[examTaker.id?string].passed??]
                [#if !examApplyMap[examTaker.id?string].passed]
                  [@b.a href="!editApply?examApplyType=DELAY&semester.id=${semester.id}&examTakerId=${examTaker.id}"]重新申请[/@]
                  [@b.a href="!cancelApply?examApplyType=DELAY&examTakerId=${examTaker.id}&examApplyId=${examApplyMap[examTaker.id?string].id}"]撤销[/@]
                [/#if]
              [#else]
                [@b.a href="!cancelApply?examApplyType=DELAY&examTakerId=${examTaker.id}&examApplyId=${examApplyMap[examTaker.id?string].id}"]撤销[/@]
              [/#if]
            [/#if]
          [#else]
            [#if examTaker.examStatus.id != DELAY]
              [@b.a href="!editApply?examApplyType=DELAY&semester.id=${semester.id}&examTakerId=${examTaker.id}"]申请[/@]
            [/#if]
          [/#if]
        </td>
        <td>
          [#if examApplyMap?? && examApplyMap[examTaker.id?string]??]
            <b>${(examApplyMap[examTaker.id?string].passed?string("<font color='green'>通过</font>","<font color='red'>不通过</font>"))!}</b>
          [/#if]
        </td>
        --]
      [#else]
        <td colspan="3"><font color="BBC4C3">[尚未安排]</font></td>
        [#--
        <td></td>
        <td></td>
        --]
      [/#if]
    [#else]
       <td colspan="3"><font color="BBC4C3">[无考试记录]</font></td>
       [#--
       <td></td>
       <td></td>
       --]
    [/#if]
  </tr>
  [/#list]
</table>
[#if finalExamNotice??]
<div class="callout callout-info">
  ${finalExamNotice.studentNotice!}
</div>
[/#if]

[#if otherTakers?size>0]
<div style="height: 30px;"></div>
[@b.toolbar title="补缓考试安排"/]
<table width="100%" class="formTable">
  <tr align="center" bgcolor="#C7DBFF" height="23px">
    <td width="10%">课程序号</td>
    <td width="21%">课程名称</td>
    <td width="18%">课程类别</td>
    <td width="20%">考试时间</td>
    <td width="18%">考场(座位号)</td>
    <td width="13%">考试情况</td>
  </tr>
  [#list otherTakers?keys?sort_by(["clazz","crn"]) as taker]
    [#if taker_index%2==1][#assign class="grayStyle"][/#if]
    [#if taker_index%2==0][#assign class="brightStyle"][/#if]
    <tr class="${class}" align="center" height="23px">
      <td>${(taker.clazz.crn)!}</td>
      <td>${(taker.clazz.course.name)!}</td>
      <td>${(taker.clazz.courseType.name)!}</td>
      [#assign examTaker = otherTakers.get(taker) /]
      [#if examTaker.activity??]
        [#assign activity=examTaker.activity/]
        <td>
          [#if activity.publishState.timePublished]
            ${(activity.examOn?string('yyyy-MM-dd'))!}[#if activity.examOn??]&nbsp;&nbsp;[/#if][#if activity.beginAt?? && activity.endAt??]${activity.beginAt}~${activity.endAt}[/#if]
          [#else]
            <font color="BBC4C3">[尚未发布]</font>
          [/#if]
        </td>
        <td>[#if activity.publishState.roomPublished]${(examTaker.examRoom.room.name)!}(${examTaker.seatNo})[#else]<font color="BBC4C3">[尚未发布]</font>[/#if]</td>
        <td>${(examTaker.examStatus.name)!}</td>
      [#else]
        <td colspan="3"><font color="BBC4C3">[尚未安排]</font></td>
      [/#if]
    </tr>
  [/#list]
</table>
[#if otherExamNotice??]
<div class="callout callout-info">
  ${otherExamNotice.studentNotice!}
</div>
[/#if]
[/#if]
</div>
[@b.foot/]
