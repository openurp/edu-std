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

package org.openurp.edu.std.course.web

import org.beangle.cdi.bind.BindModule
import org.openurp.base.edu.service.impl.TimeSettingServiceImpl
import org.openurp.base.service.impl.SemesterServiceImpl
import org.openurp.code.service.impl.CodeServiceImpl
import org.openurp.edu.clazz.domain.{DefaultClazzProvider, DefaultExamTakerProvider}
import org.openurp.edu.grade.domain.DefaultCourseGradeProvider
import org.openurp.edu.program.domain.{DefaultAlternativeCourseProvider, DefaultCoursePlanProvider, DefaultProgramProvider}
import org.openurp.edu.std.course.web.action.*

class DefaultModule extends BindModule {

  override def binding(): Unit = {
    bind(classOf[PlanAction])
    bind(classOf[AlternativeAction])
    bind(classOf[CourseTypeAction])

    bind(classOf[GradeAction])
    bind(classOf[CoursetableAction])
    bind(classOf[ExamtableAction])
    bind(classOf[ProgressAction])

    bind(classOf[CodeServiceImpl])
    bind(classOf[DefaultCoursePlanProvider])
    bind(classOf[DefaultProgramProvider])
    bind(classOf[DefaultAlternativeCourseProvider])
    bind(classOf[DefaultCourseGradeProvider])
    bind(classOf[DefaultClazzProvider])
    bind(classOf[SemesterServiceImpl])
    bind(classOf[TimeSettingServiceImpl])
    bind(classOf[DefaultExamTakerProvider])
  }

}
