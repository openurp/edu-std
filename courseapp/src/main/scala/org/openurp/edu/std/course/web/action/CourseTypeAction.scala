/*
 * Copyright (C) 2014, The OpenURP Software.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.openurp.edu.std.course.web.action

import org.beangle.commons.collection.Collections
import org.beangle.data.dao.OqlBuilder
import org.beangle.security.Securities
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.EntityAction
import org.openurp.base.edu.code.CourseType
import org.openurp.base.edu.model.Course
import org.openurp.base.std.model.Student
import org.openurp.edu.grade.model.CourseGrade
import org.openurp.edu.program.domain.CoursePlanProvider
import org.openurp.edu.program.model.{CourseGroup, CoursePlan}
import org.openurp.edu.std.app.model.CourseTypeChangeApply
import org.openurp.edu.std.course.web.support.StdProjectSupport

import java.time.Instant
import scala.collection.mutable

class CourseTypeAction extends EntityAction[CourseTypeChangeApply] with StdProjectSupport {

  var coursePlanProvider: CoursePlanProvider = _

  override def projectIndex(): View = {
    val me = getStudent()
    put("applies", entityDao.findBy(classOf[CourseTypeChangeApply], "std", me))
    forward("projectIndex")
  }

  def applyForm(): View = {
    val me = getStudent()
    put("std", me)
    this.coursePlanProvider.getCoursePlan(me) foreach { plan =>
      //登记成绩中出现课程
      val query = OqlBuilder.from(classOf[CourseGrade], "grade")
      query.where("grade.std = :std", me)
      query.where("grade.passed=true")
      val gradeList = entityDao.search(query)
      val courseGrades = Collections.newMap[Course, CourseGrade]
      gradeList.foreach { g => courseGrades.put(g.course, g) }
      //登记计划中出现的课程
      val courseInPlan = Collections.newSet[Course]
      for (g <- plan.groups; if g.parent.isEmpty) collectCourse(g, courseInPlan)
      //将相同的课程从成绩登记表中删除
      val courseInGradeAndPlan = Collections.intersection(courseGrades.keySet, courseInPlan)
      courseInGradeAndPlan foreach { c => courseGrades.remove(c) }
      put("grades", courseGrades)
      put("courseTypes", collectCourseType(me, plan))
    }
    forward()
  }

  def doApply(): View = {
    val apply = populateEntity(classOf[CourseTypeChangeApply], "apply")
    apply.std = getStudent()
    apply.updatedAt = Instant.now
    if apply.approved.contains(true) then
      redirect("index", "不能修改已经通过的申请")
    else
      entityDao.saveOrUpdate(apply)
      redirect("index", "申请成功")
  }

  def remove(): View = {
    val id = longId("apply")
    val apply = entityDao.get(classOf[CourseTypeChangeApply], id)
    if apply.approved.contains(true) then
      return redirect("index", "不能删除已经审核通过的申请")
    if !(apply.std.code == Securities.user) then
      return redirect("index", "不能删除别人的申请")
    entityDao.remove(apply)
    redirect("index", "成功删除申请")
  }

  private def collectCourseType(std: Student, plan: CoursePlan): collection.Set[CourseType] = {
    val types = Collections.newSet[CourseType]
    for (g <- plan.groups; if g.children.isEmpty) { //without subgroup
      if g.planCourses.isEmpty then // 1. without courses
        types.add(g.courseType)
      else if !g.autoAddup && g.courseType.optional then // 2. with some courses
        val sum = g.planCourses.map(_.course.getCredits(std.level)).sum
        if sum < g.credits then types.add(g.courseType)
    }
    types
  }

  private def collectCourse(g: CourseGroup, courseInPlan: mutable.Set[Course]): Unit = {
    for (pc <- g.planCourses) courseInPlan.add(pc.course)
    for (child <- g.children) collectCourse(child, courseInPlan)
  }
}
