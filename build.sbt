name := "neo4j-browser"

organization := "org.neo4j.app"

version := "0.0.2"

scalaVersion := "2.10.2"

scalaSource in Compile <<= baseDirectory(_ / "tools" / "src" / "main")

scalaSource in Test <<= baseDirectory(_ / "tools" / "src" / "test")

resourceDirectory in Compile <<= baseDirectory(_ / "dist")

resourceDirectory in Test <<= baseDirectory(_ / "dist")

target <<= baseDirectory { _ / "tools" / "target" }

mainClass in (Compile, run) := Some("org.neo4j.tools.localgraph.LocalGraph")

resolvers ++= Seq(
  "Local Maven Repository" at "file://"+Path.userHome.absolutePath+"/.m2/repository",
  "Neo4j Snapshots" at "http://m2.neo4j.org/content/groups/everything/"
)

libraryDependencies ++= Seq(
    "org.neo4j"      % "neo4j-community" % "2.0.0-M04" % "test",
    "org.neo4j.app"  % "neo4j-server"    % "2.0.0-M04" % "test",
    "org.neo4j.app"  % "neo4j-server"    % "2.0.0-M04" % "test" classifier "static-web",
    "com.sun.jersey" % "jersey-core"     % "1.14"         % "test",
    "com.sun.jersey" % "jersey-server"   % "1.14"         % "test",
    "com.sun.jersey" % "jersey-servlet"  % "1.14"         % "test"
  )


// publish!
crossPaths := false

publishMavenStyle := true

publishTo <<= version { (v: String) =>
  if (v.trim.endsWith("SNAPSHOT"))
    // Some("snapshots" at "http://m2.neo4j.org/content/repositories/snapshots")
    Some(Resolver.file("file", new File(Path.userHome.absolutePath+"/.m2/repository")))
  else
    Some(Resolver.file("file", new File(Path.userHome.absolutePath+"/.m2/repository")))
}