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

package org.openurp.edu.std.course.web.support

import org.beangle.data.dao.EntityDao
import org.beangle.security.Securities
import org.beangle.web.action.support.{ActionSupport, ServletSupport}
import org.beangle.web.action.view.View
import org.openurp.base.model.{Project, Semester}
import org.openurp.base.service.SemesterService
import org.openurp.base.std.model.Student

import java.time.LocalDate

trait StdProjectSupport extends ActionSupport with ServletSupport {

  def entityDao: EntityDao

  def projectIndex(): View

  def index(): View = {
    val stds = getStudents()
    if stds.size == 1 then
      request.setAttribute("student", stds.head)
      request.setAttribute("project", stds.head.project)
      projectIndex()
    else
      if stds.nonEmpty then
        val projects = stds.map(_.project)
        put("projects", projects)
        put("defaultProjectId", getInt("projectId", projects.head.id))
      else
        put("projects", List.empty[Project])
        put("defaultProjectId", 0)
      forward()
  }

  protected final def getStudents(): Seq[Student] = {
    entityDao.findBy(classOf[Student], "user.code" -> Securities.user)
  }

  protected final def getSemester(semesterService: SemesterService): Semester = {
    getInt("semester.id") match {
      case None => semesterService.get(getCurrentProject(), LocalDate.now)
      case Some(id) => entityDao.get(classOf[Semester], id)
    }
  }

  protected final def getCurrentProject(): Project = {
    val project = request.getAttribute("project")
    if (null != project) project.asInstanceOf[Project]
    else
      getInt("projectId") match {
        case Some(projectId) => entityDao.get(classOf[Project], projectId)
        case None => null
      }
  }

  protected final def getCurrentStudent(): Student = {
    val std = request.getAttribute("student")
    if (null != std) std.asInstanceOf[Student]
    else
      val project = getCurrentProject()
      val stds = entityDao.findBy(classOf[Student], "project" -> project, "user.code" -> Securities.user)
      stds.head
  }

}
