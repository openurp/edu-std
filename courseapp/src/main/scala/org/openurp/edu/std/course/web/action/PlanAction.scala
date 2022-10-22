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
import org.beangle.commons.text.seq.{HanZiSeqStyle, RomanSeqStyle, SeqPattern}
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.ems.app.Ems
import org.beangle.web.action.context.ActionContext
import org.beangle.web.action.support.ActionSupport
import org.beangle.web.action.view.View
import org.openurp.base.model.{AuditStatus, Project}
import org.openurp.base.service.ProjectPropertyService
import org.openurp.base.std.model.Student
import org.openurp.code.edu.model.TeachingNature
import org.openurp.code.service.CodeService
import org.openurp.edu.Features
import org.openurp.edu.program.domain.{AlternativeCourseProvider, CoursePlanProvider}
import org.openurp.edu.program.model.{ExecutionPlan, Program, ProgramDoc}
import org.openurp.edu.std.course.web.support.StdProjectSupport

class PlanAction extends StdProjectSupport {

  var entityDao: EntityDao = _

  var coursePlanProvider: CoursePlanProvider = _

  var alternativeCourseProvider: AlternativeCourseProvider = _

  var codeService: CodeService = _

  var projectPropertyService: ProjectPropertyService = _

  override def projectIndex(): View = {
    val std = getStudent()
    val project = std.project
    coursePlanProvider.getCoursePlan(std) foreach { plan =>
      val majorAlternativeCourses = alternativeCourseProvider.getMajorAlternatives(std)
      val stdAlternativeCourses = alternativeCourseProvider.getStdAlternatives(std)
      put("plan", plan)
      put("teachingNatures", codeService.get(classOf[TeachingNature])) //展示多类课时
      put("majorAlternativeCourses", majorAlternativeCourses)
      put("stdAlternativeCourses", stdAlternativeCourses)
      put("hasProgramDoc", false)
      coursePlanProvider.getExecutionPlan(std) foreach { executionPlan =>
        if executionPlan.program.status == AuditStatus.Passed then
          val builder = OqlBuilder.from(classOf[ProgramDoc], "pd")
          builder.where("pd.program =:program", executionPlan.program)
          val docs = entityDao.search(builder)
          put("hasProgramDoc", docs.nonEmpty)
      }
    }
    put("ems", Ems)
    put("enableLinkCourseInfo", projectPropertyService.get(project, Features.ProgramLinkCourseEnabled, false))
    forward("projectIndex")
  }

  def programDoc(): View = {
    val program = entityDao.get(classOf[Program], getLong("program.id").getOrElse(0L))
    if program.status == AuditStatus.Passed then
      val request_locale = ActionContext.current.locale
      val builder = OqlBuilder.from(classOf[ProgramDoc], "pd")
      builder.where("pd.program =:program", program)
      builder.where("pd.docLocale=:locale", request_locale)
      val seqPattern =
        if (request_locale == new java.util.Locale("zh", "CN")) new SeqPattern(new HanZiSeqStyle, "{1}")
        else new SeqPattern(new RomanSeqStyle, "{1}")
      put("seqPattern", seqPattern)
      val docs = entityDao.search(builder)
      val sections = Collections.newMap[Long, String]
      docs foreach { doc =>
        doc.sections foreach { s =>
          var content = s.contents
          content = Strings.replace(content, " ", "&nbsp;");
          content = Strings.replace(content, "\r", "");
          content = Strings.replace(content, "\t", "&nbsp;&nbsp;");
          content = Strings.replace(content, "\n", "<br>&nbsp;&nbsp;");
          sections.put(s.id, "&nbsp;&nbsp;" + content);
        }
        put("sections", sections)
      }
      put("doc", docs.headOption)
    forward()
  }
}
