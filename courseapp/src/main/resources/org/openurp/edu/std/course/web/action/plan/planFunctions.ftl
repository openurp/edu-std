[#ftl]

[#-- 获得一个courseGroup的最深层次，自己的层次为1 --]
[#function myMaxDepth courseGroup]
    [#local max_level = 0 /]
    [#list courseGroup.children! as child]
        [#local t_level = myMaxDepth(child) /]
        [#if t_level > max_level]
            [#local max_level = t_level /]
        [/#if]
    [/#list]
    [#return max_level + 1 /]
[/#function]
[#-- 获得一个plan的课程组的最深层次 --]
[#function planMaxDepth plan]
    [#local max_level = 0 /]
    [#list plan.topGroups! as group]
        [#local t_level = myMaxDepth(group) /]
        [#if t_level > max_level]
            [#local max_level = t_level /]
        [/#if]
    [/#list]
    [#return max_level /]
[/#function]

[#-- 是叶子节点，叶子节点就是课程或没有课程的课程组 --]
[#function isLeaf obj]
    [#if obj.course??]    [#-- 是planCourse --]
        [#return true /]
    [#else]                [#-- 是courseGroup --]
        [#if (!obj.children?? || obj.children?size == 0) && (!obj.planCourses?? || obj.planCourses?size == 0)]
            [#return true /]
        [/#if]
    [/#if]
    [#return false /]
[/#function]

[#-- 一个课程组的最深的叶子处于第几层 --]
[#function myLeafMaxLevel courseGroup]
    [#if isLeaf(courseGroup)]    [#-- 如果是叶子节点 --]
        [#return 1 /]
    [/#if]
    [#if !courseGroup.children?? || courseGroup.children?size == 0] [#-- 不是叶子节点，但是也没有子课程组 --]
        [#return 2 /]
    [/#if]

    [#local max_level = 0 /]
    [#list courseGroup.children! as child]
        [#local t_level = myLeafMaxLevel(child) /]
        [#if t_level > max_level]
            [#local max_level = t_level /]
        [/#if]
    [/#list]
    [#return max_level + 1 /]
[/#function]

[#-- 一个培养计划的最深的叶子处于第几层 --]
[#function planLeafMaxLevel plan]
    [#local max_level = 0 /]
    [#list plan.topGroups! as group]
        [#local t_level = myLeafMaxLevel(group) /]
        [#if t_level > max_level]
            [#local max_level = t_level /]
        [/#if]
    [/#list]
    [#return max_level /]
[/#function]

[#-- 获得当前courseGroup的顶端courseGroup --]
[#function getTopCourseGroup group]
    [#if group.parent??]
        [#return getTopCourseGroup(group.parent) /]
    [#else]
        [#return group /]
    [/#if]
[/#function]

[#-- 获得一个courseGroup在自己的树里在第几层次 --]
[#function myCurrentLevel group]
    [#if group.parent??]
        [#return 1 + myCurrentLevel(group.parent) /]
    [#else]
        [#return 1 /]
    [/#if]
[/#function]

[#macro planMainTitle plan]${plan.program.department.name}&nbsp;${plan.program.major.name}专业[/#macro]
[#macro planSubTitle plan]${("("+ plan.program.direction.name + ")&nbsp;")!}&nbsp; ${plan.program.level.name}&nbsp;培养方案&nbsp;(${plan.program.grade})[/#macro]

[#macro displayCourse course]
  [#if enableLinkCourseInfo]
   <a href="${ems.base}/edu/course/info/${course.id}" target="_blank">${course.name}</a>
  [#else]
    ${course.name}
  [/#if]
[/#macro]
[#-- 获得一个课程组所应该colspan多少 --]
[#function fenleiSpan maxFenleiSpan group]
    [#if isLeaf(group)]
        [#-- 2 是因为需要跨 课程代码，课程名称两列 --]
        [#if group.parent??]
            [#if (!group.children?? || group.children?size == 0) && myCurrentLevel(group)!=teachPlanLeafLevels && fenleiSpan(maxFenleiSpan,group.parent)==1]
                [#return mustSpan + teachPlanLeafLevels - myCurrentLevel(group)/]
            [#else]
                [#return mustSpan/]
            [/#if]
        [#else]
            [#return mustSpan + maxFenleiSpan /]
        [/#if]
    [#else]
        [#local all_children_leaf =  true /]
        [#list group.children! as c]
            [#if !isLeaf(c)][#local all_children_leaf = false /][#break][/#if]
        [/#list]
        [#if all_children_leaf]
            [#return maxFenleiSpan - myCurrentLevel(group) + 1/]
        [#else]
            [#return 1/]
        [/#if]
    [/#if]
[/#function]

[#-- 获得自己和自己的祖宗所使用的分类一栏的colspan总和 --]
[#function HierarchyFenleiSpanSum maxFenleiSpan group]
    [#if !group.parent??]
        [#return fenleiSpan(maxFenleiSpan, group) /]
    [/#if]
    [#return fenleiSpan(maxFenleiSpan, group) + HierarchyFenleiSpanSum(maxFenleiSpan, group.parent) /]
[/#function]

[#-- 获得从树的顶端到自己的一条链 --]
[#function getHierarchyTree group]
    [#if group.parent??]
        [#return getHierarchyTree(group.parent) + [group] /]
    [/#if]
    [#return [group] /]
[/#function]

[#-- 把自己的向上的一条树统统画出来, eg. 爷爷/儿子/孙子 --]
[#macro drawAllAncestor courseGroup]
    [#local tree = getHierarchyTree(courseGroup) /]
    [#list tree as node]
        [#if (!node.parent??)]
            [#if  (node.children?size < 1) && (node.planCourses?size < 1)]
                <td class="group" colspan="${fenleiSpan(maxFenleiSpan, node)}">${node.courseType.name}</td>
            [/#if]
            [#if (node.children?size < 1) && (node.planCourses?size > 0)]
                <td class="group" colspan="${fenleiSpan(maxFenleiSpan, node)}" width="${fenleiWidth * maxFenleiSpan}px">${node.courseType.name}</td>
            [/#if]
            [#if (node.children?size > 0) ]
                <td class="group" colspan="${fenleiSpan(maxFenleiSpan, node)}" width="2%">${node.courseType.name}</td>
            [/#if]
        [#else]
            [#if (node.children?size < 1) && (node.planCourses?size < 1)]
                <td class="group" colspan="${fenleiSpan(maxFenleiSpan, node)}">${node.courseType.name}</td>
            [/#if]
            [#if (node.children?size < 1) && (node.planCourses?size > 0)]
                <td class="group" colspan="${fenleiSpan(maxFenleiSpan, node)}" width="2%">
                    ${node.courseType.name}
                </td>
            [/#if]
            [#if (node.children?size > 0)]
                <td class="group" colspan="${fenleiSpan(maxFenleiSpan, node)}" width="2%">${node.courseType.name}</td>
            [/#if]
        [/#if]
    [/#list]
[/#macro]

[#-- 计划课程的一格一格的学分信息 --]
[#macro planCourseCreditInfo planCourse]
    [#list plan.startTerm..plan.endTerm as i]
            <td class="credit_hour">
                [#if planCourse.terms?exists && (","+planCourse.terms+",")?contains(","+i+",")]√[#else]&nbsp;[/#if]
            </td>
    [/#list]
[/#macro]

[#-- 课程组的一格一格的学分信息 --]
[#macro courseGroupCreditInfo courseGroup]
    [#local i = 1 /]
    [#if  courseGroup.termCredits=="*"]
        [#list i..maxTerm as t]<td class="credit_hour">&nbsp;</td>[/#list]
    [#else]
        [#local termCredits= courseGroup.termCredits/]
        [#if termCredits?starts_with(",")]
            [#local termCredits= termCredits[1..termCredits?length-1] /]
        [/#if]
        [#if termCredits?ends_with(",")]
            [#local termCredits= termCredits[0..termCredits?length-2] /]
        [/#if]
        [#list termCredits[0..termCredits?length-1]?split(",") as credit]
          [#if (i<=maxTerm)]
            <td class="credit_hour">[#if credit!="0"]${credit}[#else]&nbsp;[/#if]</td>
            [#if !courseGroup.parent??]
                [#local current_totle=total_term_credit[i?string]!(0) /]
                [#assign total_term_credit=total_term_credit + {i:current_totle+credit?number} /]
                [#local i = i + 1 /]
            [/#if]
          [/#if]
        [/#list]
    [/#if]
[/#macro]
[#-- 计划课程的一格一格的周课时信息 --]
[#macro planCourseWeekHoursInfo planCourse]
    [#list plan.startTerm..plan.endTerm as i]
        <td class="credit_hour">[#if planCourse.terms?exists && (","+planCourse.terms+",")?contains(","+i+",")]${(planCourse.course.weekHours)?if_exists}[#else]&nbsp;[/#if]</td>
    [/#list]
[/#macro]

[#-- 需要完善，画出一个课程组 --]
[#macro drawGroup courseGroup courseTermInfoMacro groupTermInfoMacro]
    [#if isLeaf(courseGroup)]
        <tr>
            [@drawAllAncestor courseGroup /]
            <td class="credit_hour">${courseGroup.credits}</td>
            [@groupTermInfoMacro courseGroup /]
            <td>&nbsp;</td>
            <td class="credit_hour">&nbsp;${courseGroup.remark!}</td>
        </tr>
    [#else]
        [#list courseGroup.planCourses?sort_by(['course', 'code'])?sort_by(['terms']) as planCourse]
            [#assign courseCount = courseCount + 1]
        <tr>
            [@drawAllAncestor courseGroup /]

            [#-- 存在非叶子节点的子组 add on 2012-04-11 --]
            [#local exists_nonleaf_child = false /]
            [#list courseGroup.children as c]
                [#if !isLeaf(c) ][#local exists_nonleaf_child=true /][#break][/#if]
            [/#list]
            [#if exists_nonleaf_child]
                <td class="group" colspan="${maxFenleiSpan - myCurrentLevel(courseGroup)}">&nbsp;</td>
            [/#if]

            <td class="course">&nbsp;${planCourse.course.code!}</td>
            <td class="course">&nbsp;${courseCount}&nbsp;[@displayCourse planCourse.course/]</td>
            <td class="credit_hour">${(planCourse.course.credits)?default(0)}</td>
            [@courseTermInfoMacro planCourse /]
            <td class="credit_hour">${planCourse.department.name}</td>
            <td>[#if planCourse.compulsory && !courseGroup.autoAddup]必修 [/#if][#if planCourse.remark?exists]${planCourse.remark!}[#else]&nbsp;[/#if]</td>
        </tr>
        [/#list]
        [#list courseGroup.children! as child]
            [@drawGroup child courseTermInfoMacro groupTermInfoMacro/]
        [/#list]
        <tr>
            [@drawAllAncestor courseGroup /]
            <td colspan="${mustSpan + maxFenleiSpan - HierarchyFenleiSpanSum(maxFenleiSpan, courseGroup)}" class="credit_hour summary">
                [#if courseGroup.autoAddup]学分小计[#else]<font color="#1F3D83">应修学分</font>[/#if]
            </td>
            <td class="credit_hour summary">[#if courseGroup.autoAddup]${courseGroup.credits}[#else]<font color="#1F3D83">${courseGroup.credits}</font>[/#if]</td>
            [@groupTermInfoMacro courseGroup /]
            <td>&nbsp;</td>
            <td class="credit_hour">&nbsp;${courseGroup.remark!}</td>
        </tr>
    [/#if]
[/#macro]

[#-- 培养计划中课程组的层次, 默认为1层 --]
[#assign teachPlanLevels = planMaxDepth(plan) /]
[#if teachPlanLevels == 0]
    [#assign teachPlanLevels = 1 /]
[/#if]

[#-- 培养计划中叶子节点的最深层次, 默认为1层 --]
[#assign teachPlanLeafLevels = planLeafMaxLevel(plan) /]
[#if teachPlanLeafLevels == 0]
    [#assign teachPlanLeafLevels = 1 /]
[/#if]

[#-- 分类一栏的colspan --]
[#assign maxFenleiSpan = teachPlanLeafLevels - 1]
[#if maxFenleiSpan <= 0]
    [#assign maxFenleiSpan = 1 /]
[/#if]

[#-- 有时候必须跨的列数，在这里是课程名称和课程代码两列 --]
[#assign mustSpan = 2/]

[#assign courseCount = 0 /]
[#assign fenleiWidth = 10 /]

[#--
maxFenleiSpan:${maxFenleiSpan}<br>
mustSpan:${mustSpan}
--]

[#macro mergeCourseTypeCell plan t_planLevels bottomrows]
    function mergeCourseTypeCell(tableId) {
        var table = document.getElementById(tableId)
        for(var x = ${t_planLevels} - 1; x >= 0 ; x--) {
            var content = '';
            var firstY = -1;
            for(var y = 2; y < table.rows.length - ${bottomrows}; y++) {
                if(table.rows[y] == undefined || table.rows[y].cells[x] == undefined) {
                    continue;
                }
                if(content == table.rows[y].cells[x].innerHTML && table.rows[y].cells[x].className == 'group') {
                    table.rows[y].deleteCell(x);
                    table.rows[firstY].cells[x].rowSpan++;
                }
                else {
                    content = table.rows[y].cells[x].innerHTML;
                    // 如果是纯数字或‘学分小计’则不合并
                    if(table.rows[y].cells[x].className != 'group') {
                        content = '';
                    }
                    firstY = y;
                }
            }
        }
    }
    mergeCourseTypeCell('planInfoTable${plan.id}');
[/#macro]

[#macro planSupTitle plan]
    ${plan.status.fullName}
    生效日期：${plan.program.beginOn?string('yyyy-MM-dd')}
    失效日期：${(plan.program.endOn?string('yyyy-MM-dd'))!}
    最后修改时间：${(plan.program.updatedAt?string('yyyy-MM-dd HH:mm:ss'))!}
[/#macro]

[#macro planTitle plan]
<p style="text-align:center;color:#00108c;font-weight:bold;font-size:13pt;margin:0px 5px;">
    [#if plan.std??]
    ${plan.std.level.name}&nbsp;${(plan.std.stdType.name)!}&nbsp;${(plan.std.state.department.name)!}&nbsp;${plan.std.state.major.name}<br>${(plan.std.state.direction.name + "&nbsp;")!} ${plan.std.user.name}个人培养计划(${plan.std.state.grade})
    [#else]
    ${plan.program.level.name}&nbsp;${plan.program.stdType.name}&nbsp;${plan.program.department.name}&nbsp;${plan.program.major.name}<br>${(plan.program.direction.name + "&nbsp;")!} 专业培养计划(${plan.program.grade})
    [/#if]
</p>
[/#macro]
