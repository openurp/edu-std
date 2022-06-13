[#ftl/]

<div class="grid">
<table id="stat_grade" style="width:100%;">
<tr><td style="vertical-align:top">
  <h6 style="margin-bottom:2px;margin-top:2px;text-align:center">
  各学期成绩统计<span style="font-size:0.8rem;color: #999;">统计时间:${stdGpa.updatedAt?string("yyyy-MM-dd HH:mm")}</span>
  </h6>
  <table class="gridtable" style="width:100%;border:0.5px solid #006CB2">
    <thead class="gridhead">
      <tr>
        <th>学年学期</th>
        <th>课程门数</th>
        <th>总学分</th>
        <th>平均分</th>
        <th>平均绩点</th>
      </tr>
    </thead>
    <tbody>
        [#assign trClass="griddata-even"/]
        [#assign isDouble=false/]
        [#list stdGpa.semesterGpas?sort_by(["semester","code"]) as stdSemesterGpa]
            [#if isDouble]
              [#assign trClass="griddata-odd"/]
              [#assign isDouble=false/]
            [#else]
              [#assign trClass="griddata-even"/]
              [#assign isDouble=true/]
            [/#if]
            <tr class="${trClass}">
              <td>${(stdSemesterGpa.semester.schoolYear)!} ${(stdSemesterGpa.semester.name)!}</td>
              <td>${(stdSemesterGpa.gradeCount)!}</td>
              <td>${(stdSemesterGpa.credits)!}</td>
              <td>${(stdSemesterGpa.ga)!}</td>
              <td>${(stdSemesterGpa.gpa)!}</td>
            </tr>
          [/#list]
          [#if isDouble]
            [#assign trClass="griddata-odd"/]
            [#assign isDouble=false/]
          [#else]
            [#assign trClass="griddata-even"/]
            [#assign isDouble=true/]
          [/#if]
          <tr class="${trClass}">
              <td>在校汇总</td>
              <td>${stdGpa.gradeCount!}</td>
              <td>${stdGpa.credits!}</td>
              <td>${stdGpa.ga!}</td>
              <td>${stdGpa.gpa!}</td>
          </tr>
      [#if isDouble]
        [#assign trClass="griddata-odd"/]
        [#assign isDouble=false/]
      [#else]
        [#assign trClass="griddata-even"/]
        [#assign isDouble=true/]
      [/#if]
    </tbody>
  </table>
  </td>
  <td style="vertical-align:top">
  <div id="holder" style="width:400px;height:200px"></div>
  </td>
 </tr>
</table>
<script>
 [#assign seg100=0/]
 [#assign seg95=0/][#assign seg90=0/]
 [#assign seg85=0/][#assign seg80=0/]
 [#assign seg75=0/][#assign seg70=0/]
 [#assign seg65=0/][#assign seg60=0/]
 [#assign seg55=0/][#assign seg50=0/]
 [#assign seg45=0/][#assign seg40=0/]
 [#assign seg35=0/][#assign seg30=0/]
 [#assign seg00=0/]
 [#list semesterGrades?keys as s]
   [#assign seGrades=semesterGrades.get(s)/]
   [#list seGrades as g]
   [#if g.published]
        [#assign score=g.score!0/]
        [#if score<30][#assign seg00=seg00+1/]
        [#elseif score<35][#assign seg30=seg30+1/]
        [#elseif score<40][#assign seg35=seg35+1/]
        [#elseif score<45][#assign seg40=seg40+1/]
        [#elseif score<50][#assign seg45=seg45+1/]
        [#elseif score<55][#assign seg50=seg50+1/]
        [#elseif score<60][#assign seg55=seg55+1/]
        [#elseif score<65][#assign seg60=seg60+1/]
        [#elseif score<70][#assign seg65=seg65+1/]
        [#elseif score<75][#assign seg70=seg70+1/]
        [#elseif score<80][#assign seg75=seg75+1/]
        [#elseif score<85][#assign seg80=seg80+1/]
        [#elseif score<90][#assign seg85=seg85+1/]
        [#elseif score<95][#assign seg90=seg90+1/]
        [#elseif score<100][#assign seg95=seg95+1/]
        [#else][#assign seg100=seg100+1/][/#if]
   [/#if]
   [/#list]
 [/#list]
 require(["${base}/static/raphael/raphael-min.js"], function( Raphael ) {
   require(["${base}/static/raphael/g.raphael-min.js"], function( a1 ) {
     require(["${base}/static/raphael/g.line-min.js"], function( a1 ) {
      drawDigram();
     });
   });
 });

 function drawDigram(){
   var r = Raphael("holder");
   var line = r.linechart(20, 0, 400, 180, [[0,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100]], [[${seg00},${seg30},${seg35},${seg40}, ${seg45}, ${seg50}, ${seg55}, ${seg60}, ${seg65}, ${seg70},${seg75},${seg80},${seg85},${seg90},${seg95},${seg100}]],
     { nostroke: false, axis: "0 0 1 1", symbol: "circle", smooth: true });
     r.text(120, 20, "成绩分数、门数分布图");
     line.hoverColumn(function () {
        this.tags = r.set();
        for (var i = 0, ii = this.y.length; i < ii; i++) {
          this.tags.push(r.tag(this.x, this.y[i],this.values[i]+"门", 160, 10).insertBefore(this).attr([{ fill: "#fff" }, { fill: this.symbols[i].attr("fill") }]));
        }
    }, function () {
        this.tags && this.tags.remove();
    });
 }
</script>
</div>
