[#ftl]
<div class="container-fluid" style="font-family:宋体;">
[#if doc?exists]
  [#list doc.sections as section]
    <p style="font-weight:bold;font-size:1.2rem;text-align:left;margin:1rem 0rem 1rem 1rem">${seqPattern.next}.${section.name!}</p>
    <p style="text-align:left;margin-bottom:0px">
        ${sections.get(section.id)!}
    </p>
  [/#list]
[#else]
    没有找到你的培养方案或者在制定过程中尚未发布。
[/#if]
</div>
