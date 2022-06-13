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
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.web.action.view.View
import org.openurp.base.service.SemesterService
import org.openurp.code.edu.model.ExamType
import org.openurp.edu.clazz.domain.{ClazzProvider, ExamTakerProvider}
import org.openurp.edu.clazz.model.CourseTaker
import org.openurp.edu.exam.model.{ExamActivity, ExamNotice, ExamRoom, ExamTaker}
import org.openurp.edu.std.course.web.support.StdProjectSupport

import java.util
import java.util.List

class ExamtableAction extends StdProjectSupport {

  var entityDao: EntityDao = _
  var clazzProvider: ClazzProvider = _
  var examTakerProvider: ExamTakerProvider = _
  var semesterService: SemesterService = _

  override def projectIndex(): View = {
    val project = getCurrentProject()
    val std = getCurrentStudent()
    val semester = getSemester(semesterService)
    val courseTakers = clazzProvider.getStdClazzes(semester, std)

    val finalTakers = Collections.newMap[CourseTaker, ExamTaker]
    val otherTakers = Collections.newMap[CourseTaker, ExamTaker]
    val examTakers = examTakerProvider.getStdTakers(semester, std).groupBy(_.clazz)
    if (courseTakers.nonEmpty) {
      courseTakers foreach { courseTaker =>
        examTakers.get(courseTaker.clazz).foreach { ets =>
          ets.find(et => et.examType.id == ExamType.Final) foreach { examTaker =>
            finalTakers.put(courseTaker, examTaker)
          }
          ets.find(et => et.examType.id != ExamType.Final) foreach { examTaker =>
            otherTakers.put(courseTaker, examTaker)
          }
        }
      }
    }
    put("semester", semester)
    put("courseTakers", courseTakers)
    put("finalTakers", finalTakers)
    put("otherTakers", otherTakers)
    //查找考试通知
    val noticeQuery = OqlBuilder.from(classOf[ExamNotice], "notice")
    noticeQuery.where("notice.project=:project", project)
    noticeQuery.where("notice.semester=:semester", semester)
    val notices = entityDao.search(noticeQuery)
    put("finalExamNotice", notices.find(_.examType.id == ExamType.Final))
    put("otherExamNotice", notices.find(_.examType.id != ExamType.Final))
    forward("projectIndex")
  }

}
