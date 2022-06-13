[#ftl]
[#if doc?exists]
  [#list doc.sections as section]
    <p style="color:#00108c;font-weight:bold;font-size:10pt;text-align:left;">${seqPattern.next()}.${(section.name?html)!}</p>
    <p style="text-align:left;">
        ${(section.contents?html)!}
    </p>
  [/#list]
[#else]
    没有找到你的培养方案或者在制定过程中尚未发布。
[/#if]
