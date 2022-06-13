[#ftl]
[@b.head/]
<div class="container">
  [@b.toolbar title="课程成绩"]
    bar.addBack("${b.text("action.back")}");
  [/@]
  [#include "grades_normal.ftl"/]
</div>
[@b.foot/]
