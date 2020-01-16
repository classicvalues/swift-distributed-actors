#!/usr/bin/env ruby

#
#   process_test_files.rb
#
#   Copyright 2016 Tony Stone
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#   Created by Tony Stone on 5/4/16.
#
require 'getoptlong'
require 'fileutils'
require 'pathname'

include FileUtils

#
# This ruby script will auto generate LinuxMain.swift and the +XCTest.swift extension files for Swift Package Manager on Linux platforms.
#
# See https://github.com/apple/swift-corelibs-xctest/blob/master/Documentation/Linux.md
#
def header(fileName)
  string = <<-eos
//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Distributed Actors open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift Distributed Actors project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.md for the list of Swift Distributed Actors project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import XCTest

///
/// NOTE: This file was generated by generate_linux_tests.rb
///
/// Do NOT edit this file directly as it will be regenerated automatically when needed.
///
    eos

  string
    .sub('<FileName>', File.basename(fileName))
    .sub('<Date>', Time.now.to_s)
end

def createExtensionFile(fileName, classes)
  extensionFile = fileName.sub! '.swift', '+XCTest.swift'
  print 'Creating file: ' + extensionFile + "\n"

  File.open(extensionFile, 'w') do |file|
    file.write header(extensionFile)
    file.write "\n"

    for classArray in classes
      file.write 'extension ' + classArray[0] + " {\n"
      file.write '    static var allTests: [(String, (' + classArray[0] + ") -> () throws -> Void)] {\n"
      file.write "        return [\n"

      for funcName in classArray[1]
        file.write '            ("' + funcName + '", ' + funcName + "),\n"
      end

      file.write "        ]\n"
      file.write "    }\n"
      file.write "}\n"
    end
  end
end

def createLinuxMain(testsDirectory, allTestSubDirectories, files)
  fileName = testsDirectory + '/LinuxMain.swift'
  print 'Creating file: ' + fileName + "\n"

  File.open(fileName, 'w') do |file|
    file.write header(fileName)
    file.write "\n"

    file.write "#if os(Linux) || os(FreeBSD)\n"
    for testSubDirectory in allTestSubDirectories.sort { |x, y| x <=> y }
      file.write '@testable import ' + testSubDirectory + "\n"
    end
    file.write "\n"
    file.write "XCTMain([\n"

    testCases = []
    for classes in files
      for classArray in classes
        testCases << classArray[0]
      end
    end

    for testCase in testCases.sort { |x, y| x <=> y }
      file.write '    testCase(' + testCase + ".allTests),\n"
    end
    file.write "])\n"
    file.write "#endif\n"
  end
end

def parseSourceFile(fileName)
  puts 'Parsing file:  ' + fileName + "\n"

  classes = []
  currentClass = nil
  inIfLinux = false
  inElse    = false
  ignore    = false

  #
  # Read the file line by line
  # and parse to find the class
  # names and func names
  #
  File.readlines(fileName).each do |line|
    if inIfLinux
      if /\#else/.match(line)
        inElse = true
        ignore = true
      else
        if /\#end/.match(line)
          inElse = false
          inIfLinux = false
          ignore = false
        end
        end
    else
      if /\#if[ \t]+os\(Linux\)/.match(line)
        inIfLinux = true
        ignore = false
        end
    end

    next if ignore
    # Match class or func
    match = line[/class[ \t]+[a-zA-Z0-9_]*(?=[ \t]*:[ \t]*XCTestCase)|class[ \t]+[a-zA-Z0-9_]*(?=[ \t]*:[ \t]*[a-zA-Z0-9_]*TestBase)|[\/ \t]*func[ \t]+test[a-zA-Z0-9_]*(?=[ \t]*\(\))/, 0]

    if match

      if match[/class/, 0] == 'class'
        className = match.sub(/^class[ \t]+/, '')
        #
        # Create a new class / func structure
        # and add it to the classes array.
        #
        currentClass = [className, []]
        classes << currentClass
      elsif !match.start_with?("//") # Must be a func
        funcName = match.sub(/^[\/ \t]*func[ \t]+/, '')
        #
        # Add each func name the the class / func
        # structure created above.
        #
        next if currentClass.nil? # prevents script from crashing for files that don't contain test methods
        currentClass[1] << funcName
      end
    end
  end
  classes
end

#
# Main routine
#
#

testsDirectory = 'Tests'

options = GetoptLong.new(['--tests-dir', GetoptLong::OPTIONAL_ARGUMENT])
options.quiet = true

begin
  options.each do |option, value|
    case option
    when '--tests-dir'
      testsDirectory = value
    end
  end
rescue GetoptLong::InvalidOption
end

allTestSubDirectories = []
allFiles = []


Dir[testsDirectory + '/*'].each do |subDirectory|
  next unless File.directory?(subDirectory)
  def findTestClasses(subDirectory, allFiles)
    directoryHasClasses = false
    Dir[subDirectory + "/*"].each do |fileName|
      if File.directory? fileName
        directoryHasClasses |= findTestClasses(fileName, allFiles)
        next
      elsif !(File.file? fileName) || !(fileName =~ /Test(s?)\.swift$/)
        next
      end

      fileClasses = parseSourceFile(fileName)

      #
      # If there are classes in the
      # test source file, create an extension
      # file for it.
      #
      next unless fileClasses.count > 0
      createExtensionFile(fileName, fileClasses)
      directoryHasClasses = true
      allFiles << fileClasses
    end

    return directoryHasClasses
  end

  directoryHasClasses = findTestClasses(subDirectory, allFiles)

  if directoryHasClasses
    allTestSubDirectories << Pathname.new(subDirectory).split.last.to_s
  end
end

#
# Last step is the create a LinuxMain.swift file that
# references all the classes and funcs in the source files.
#
if allFiles.count > 0
  createLinuxMain(testsDirectory, allTestSubDirectories, allFiles)
end
# eof
