[#ftl]
[@b.head/]
[#if projects?size>0]
<ul class="nav">
  [#list projects as project]
  <li class="nav-item">
    <a class="nav-link [#if project.id=defaultProjectId]active[/#if]" [#if project.id=defaultProjectId]href="javascript:void(0);"[#else] onclick="return bg.Go(this,null)" href="${b.url('!index?projectId=${project.id}')}"[/#if]>${project.name}</a>
  </li>
  [/#list]
</ul>
[@b.div href="!projectIndex?projectId=${defaultProjectId}"/]
[#else]
没有数据!
[/#if]
[@b.foot/]
