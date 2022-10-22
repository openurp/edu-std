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

import org.beangle.commons.text.seq.SeqNumStyle.{ARABIC, HANZI}
import org.beangle.commons.text.seq.{MultiLevelSeqGenerator, SeqNumStyle, SeqPattern}
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.web.action.view.View
import org.openurp.edu.grade.model.PlanAuditResult
import org.openurp.edu.std.course.web.support.StdProjectSupport

class ProgressAction extends StdProjectSupport {

  var entityDao: EntityDao = _

  override def projectIndex(): View = {
    val std = getStudent()
    val query = OqlBuilder.from(classOf[PlanAuditResult], "r")
    query.where("r.std = :std", std)
    val result = entityDao.search(query).headOption
    put("planAuditResult", result)

    val sg = new MultiLevelSeqGenerator
    // 'A2','A3','B1','B2','B3','C1','C2','C3','D1','D2','D3','F'
    sg.add(new SeqPattern(HANZI, "{1}"))
    sg.add(new SeqPattern(HANZI, "({2})"))
    sg.add(new SeqPattern(ARABIC, "{3}"))
    sg.add(new SeqPattern(ARABIC, "{3}.{4}"))
    sg.add(new SeqPattern(ARABIC, "{3}.{4}.{5}"))
    sg.add(new SeqPattern(ARABIC, "{3}.{4}.{5}.{6}"))
    sg.add(new SeqPattern(ARABIC, "{3}.{4}.{5}.{6}.{7}"))
    sg.add(new SeqPattern(ARABIC, "{3}.{4}.{5}.{6}.{7}.{8}"))
    sg.add(new SeqPattern(ARABIC, "{3}.{4}.{5}.{6}.{7}.{8}.{9}"))
    put("sg", sg)
    forward("projectIndex")
  }
}
