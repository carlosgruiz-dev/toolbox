#!/bin/sh
exec scala "$0" "$@"
!#

/*
MIT License

Copyright (c) 2021 Carlos Gustavo Ruiz

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

import java.io.PrintWriter
import java.nio.file.{Paths, Files}
import scala.io.StdIn.readLine

object Main extends App {
    // default values
    val defaultScalaVersion = "2.13.6"
    val defaultSbtVersion = "1.5.5"
    val defaultProjectVersion = "0.0.1"
    val defaultProjectName = "My Project"
    val defaultProjectOrg = "com.example"
    
    // get current directory
    val currentDirectory = new java.io.File(".").getCanonicalPath
    
    // set templates for messages and files
    val helpMessage = """create-sbt-project.sh [OPTIONS] [folder name] 
                         | -h        -- help   : shows this message
                         | -i                  : interactive mode""".stripMargin
                                 
    val mainFile = """object Main extends App {
                     |    println("Hello, World!")
                     |}""".stripMargin
                                 
    val gitignoreFile = """### SBT ###
                          |dist/*
                          |target/
                          |lib_managed/
                          |src_managed/
                          |project/boot/
                          |project/plugins/project/
                          |.history
                          |.cache
                          |.lib/
                          |
                          |### Scala ###
                          |*.class
                          |*.log
                          |""".stripMargin

    // some methods
    def interactiveMode = {
        
        var projectName = readLine(s"Type project name (default: ${defaultProjectName}): ")
        val optProjectFolder = projectName match {
            case "" => "my-project"
            case x if x(0) == '-' || x(0) == ' ' => x.substring(1).replaceAll(" ", "-").toLowerCase
            case _ => projectName.replaceAll(" ", "-").toLowerCase
        }
        if (projectName == "") projectName = defaultProjectName
        
        var projectFolder = readLine(s"Type project folder (sugested: ${optProjectFolder}): ")
        if (projectFolder == "") projectFolder = optProjectFolder
        
        var projectOrg = readLine(s"Type project organization (default: ${defaultProjectOrg}): ")
        if (projectOrg == "") projectOrg = defaultProjectOrg
        
        var projectVersion = readLine(s"Type project version (default: ${defaultProjectVersion}): ")
        if (projectVersion == "") projectVersion = defaultProjectVersion
        
        var scalaVersion = readLine(s"Type Scala version (default: ${defaultScalaVersion}): ")
        if (scalaVersion == "") scalaVersion = defaultScalaVersion
        
        var sbtVersion = readLine(s"Type SBT version (default: ${defaultSbtVersion}): ")
        if (sbtVersion == "") sbtVersion = defaultSbtVersion
        
        createTree(projectFolder, projectName, projectVersion, projectOrg, scalaVersion, sbtVersion)
    }
    
    def createDirs(path: String) = Files.createDirectories(Paths.get(path))
    
    def writeFile(path: String, fileContent: String) = {
        val file = new java.io.File(path)
        val pw = new PrintWriter(file)
        pw.write(fileContent)
        pw.close()
    }
    
    def createTree(projectFolder: String, 
                   projectName: String = defaultProjectName,
                   projectVersion:  String = defaultProjectVersion,
                   projectOrg: String = defaultProjectOrg,
                   scalaVersion: String = defaultScalaVersion,
                   sbtVersion: String = defaultSbtVersion) = {
        if (!Files.exists(Paths.get(s"${currentDirectory}/${projectFolder}"))) {
            val paths = List(s"${currentDirectory}/${projectFolder}/project",
                             s"${currentDirectory}/${projectFolder}/src/main/resources",
                             s"${currentDirectory}/${projectFolder}/src/main/scala",
                             s"${currentDirectory}/${projectFolder}/src/main/java",
                             s"${currentDirectory}/${projectFolder}/src/test/resources",
                             s"${currentDirectory}/${projectFolder}/src/test/scala",
                             s"${currentDirectory}/${projectFolder}/src/test/java")
            paths.map(createDirs)
            
            writeFile(s"${currentDirectory}/${projectFolder}/src/main/scala/Main.scala", mainFile)
            writeFile(s"${currentDirectory}/${projectFolder}/src/test/scala/TestMain.scala", "")
            writeFile(s"${currentDirectory}/${projectFolder}/.gitignore", gitignoreFile)
            writeFile(s"${currentDirectory}/${projectFolder}/project/build.properties", s"sbt.version=${sbtVersion}")
            val buildSbt = s"""ThisBuild / scalaVersion := "${scalaVersion}"
                              |ThisBuild / organization := "${projectOrg}"
                              |name := "${projectName}"
                              |version := "${projectVersion}"
                              |""".stripMargin
            writeFile(s"${currentDirectory}/${projectFolder}/build.sbt", buildSbt)
            println("Project folders and files created!")
            
        } else {
            println(s"Folder '${projectFolder}' already exists.")
        }
    }
    
    args match {
        case x if args.contains("-h") || args.contains("--help") => println(helpMessage)
        case Array() =>  interactiveMode
        case x if args.contains("-i") => interactiveMode
        case Array(name) if name(0) != '-' => createTree(name)
        case _ => println(helpMessage)
    }
}


