import org.openurp.parent.Dependencies._
import org.openurp.parent.Settings._

ThisBuild / organization := "org.openurp.edu.std"
ThisBuild / version := "0.0.2-SNAPSHOT"

ThisBuild / scmInfo := Some(
  ScmInfo(
    url("https://github.com/openurp/edu-std"),
    "scm:git@github.com:openurp/edu-std.git"
  )
)

ThisBuild / developers := List(
  Developer(
    id = "chaostone",
    name = "Tihua Duan",
    email = "duantihua@gmail.com",
    url = url("http://github.com/duantihua")
  )
)

ThisBuild / description := "OpenURP Edu std"
ThisBuild / homepage := Some(url("http://openurp.github.io/edu-std/index.html"))

val apiVer = "0.26.0"
val starterVer = "0.0.21"
val baseVer = "0.1.30"
val openurp_edu_api = "org.openurp.edu" % "openurp-edu-api" % apiVer
val openurp_std_api = "org.openurp.std" % "openurp-std-api" % apiVer
val openurp_stater_web = "org.openurp.starter" % "openurp-starter-web" % starterVer
val openurp_base_tag = "org.openurp.base" % "openurp-base-tag" % baseVer


lazy val root = (project in file("."))
  .settings()
  .aggregate(courseapp)

lazy val courseapp = (project in file("courseapp"))
  .enablePlugins(WarPlugin, UndertowPlugin)
  .settings(
    name := "openurp-edu-std-courseapp",
    common,
    libraryDependencies ++= Seq(openurp_stater_web, openurp_base_tag, beangle_serializer_text),
    libraryDependencies ++= Seq(openurp_edu_api, openurp_std_api, beangle_ems_app)
  )

publish / skip := true
