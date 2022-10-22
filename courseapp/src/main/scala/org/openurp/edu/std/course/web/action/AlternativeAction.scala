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
import org.beangle.commons.lang.Strings
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.security.Securities
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.EntityAction
import org.openurp.base.edu.model.Course
import org.openurp.base.model.Project
import org.openurp.base.std.model.Student
import org.openurp.code.service.CodeService
import org.openurp.edu.grade.domain.CourseGradeProvider
import org.openurp.edu.grade.model.CourseGrade
import org.openurp.edu.program.domain.{AlternativeCourseProvider, CoursePlanProvider}
import org.openurp.edu.program.model.{CoursePlan, SharePlan, StdAlternativeCourse}
import org.openurp.edu.std.app.model.AlternativeApply
import org.openurp.edu.std.course.web.support.StdProjectSupport

import java.time.Instant
import scala.collection.mutable

class AlternativeAction extends EntityAction[AlternativeApply] with StdProjectSupport {

  var coursePlanProvider: CoursePlanProvider = _

  var alternativeCourseProvider: AlternativeCourseProvider = _

  var courseGradeProvider: CourseGradeProvider = _

  var codeService: CodeService = _

  override def projectIndex(): View = {
    val me = getStudent()
    val builder = OqlBuilder.from(classOf[AlternativeApply], "apply")
      .where("apply.std=:std", me)
    put("applies", entityDao.search(builder))
    forward("projectIndex")
  }

  def applyForm(): View = {
    val std = getStudent()
    put("std", std)
    put("planCourses", planCourses(std))
    put("gradeCourses", gradeCourses(std))
    forward()
  }

  private def planCourses(std: Student): collection.Seq[Course] = {
    val courses = Collections.newSet[Course]
    coursePlanProvider.getCoursePlan(std) foreach { plan =>
      for (courseGroup <- plan.groups; planCourse <- courseGroup.planCourses) {
        courses.add(planCourse.course)
      }
    }
    val spQuery = OqlBuilder.from(classOf[SharePlan], "sp")
    spQuery.where("sp.project=:project and sp.level=:level", std.project, std.level.toLevel)
    spQuery.where(":grade between sp.fromGrade and sp.toGrade", std.state.get.grade)
    entityDao.search(spQuery) foreach { sp =>
      for (cg <- sp.groups; planCourse <- cg.planCourses) {
        courses.add(planCourse.course)
      }
    }
    courses.toBuffer.sortBy(_.name)
  }

  def gradeCourses(std: Student): collection.Seq[Course] = {
    courseGradeProvider.getPublished(std).map(_.course).distinct
  }

  def doApply(): View = {
    val apply = populateEntity(classOf[AlternativeApply], "apply")
    apply.std = getStudent()

    val project = getProject()
    val originIdStr = get("originIds", "") // 原课程代码串
    val substituteIdStr = get("substituteIds", "") // 替换课程代码串
    fillCourse(project, apply.olds, originIdStr)
    fillCourse(project, apply.news, substituteIdStr)
    var stdCourseSubId: Long = 0
    if (apply.persisted) {
      stdCourseSubId = apply.id
    }
    if (apply.olds.isEmpty || apply.news.isEmpty) {
      redirect("index", "保存失败")
    } else {
      val builder = OqlBuilder.from(classOf[StdAlternativeCourse], "stdAlternativeCourse")
      builder.where("stdAlternativeCourse.std.id=:stdId", apply.std.id)
        .where("stdAlternativeCourse.std.project= :project", project)
      if (stdCourseSubId != 0) {
        builder.where("stdAlternativeCourse.id !=:stdCourseSubId", stdCourseSubId)
      }
      val stdAlternativeCourses = entityDao.search(builder)
      if (stdAlternativeCourses.nonEmpty) {
        for (stdCourseSub <- stdAlternativeCourses) {
          if (stdCourseSub.olds == apply.olds && stdCourseSub.news == apply.news) {
            return redirect("index", "该替代课程组合已存在!")
          }
        }
      }
      apply.updatedAt = Instant.now()
      if (isDoubleAlternativeCourse(apply)) {
        entityDao.saveOrUpdate(apply)
        redirect("index", "info.save.success")
      } else {
        redirect("index", "原课程与替代课程一样!")
      }
    }
  }

  private def fillCourse(project: Project, courses: mutable.Set[Course], courseCodeSeq: String): Unit = {
    val courseCodes = Strings.split(courseCodeSeq, ",")
    courses.clear()
    if (courseCodes != null) for (i <- courseCodes.indices) {
      val query = OqlBuilder.from(classOf[Course], "course").cacheable()
        .where("course.id = :id", courseCodes(i).toLong)
        .where("course.project = :project", project)
      courses ++= entityDao.search(query)
    }
  }

  /**
   * 由于前台不好判断原课程和替代
   * 课程是否一样所以放到后台判断
   *
   * @param apply 替代申请
   * @return true:原课程和替代课程不一样 false:原课程与替代课程一样
   */
  private def isDoubleAlternativeCourse(apply: AlternativeApply): Boolean = {
    var bool = false
    val courseOrigins = apply.olds
    val courseSubstitutes = apply.news
    for (Origin <- courseOrigins) {
      if (!courseSubstitutes.contains(Origin)) bool = true
    }
    for (Substitute <- courseSubstitutes) {
      if (!courseOrigins.contains(Substitute)) bool = true
    }
    bool
  }

  def remove: View = {
    val id = longId("apply")
    val apply = entityDao.get(classOf[AlternativeApply], id)
    if (apply.approved.contains(true)) return redirect("index", "不能删除已经审核通过的申请")
    val me = Securities.user
    if (!(apply.std.code == me)) return redirect("index", "不能删除别人的申请")
    entityDao.remove(apply)
    redirect("index", "成功删除申请")
  }

}
