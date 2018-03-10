#!/usr/bin/env bash

#
# ktinit.sh -- Helper script for creating gradle-based Kotlin project.
# Copyright (C) 2018 by Harald Lapp <harald@octris.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

if ! command -v gradle >/dev/null 2>&1; then
    echo "gradle is required!"
    exit 1
elif ! command -v kotlin >/dev/null 2>&1; then
    echo "kotlin is required!"
    exit 1
elif [[ "$(kotlin -version)" =~ ^Kotlin[[:blank:]]version[[:blank:]]([0-9]+\.[0-9]+\.[0-9]+) ]]; then
    version=${BASH_REMATCH[1]}
else
    echo "Unable to determine version of Kotlin"
    exit 1
fi

if [ "$1" = "" ]; then
    echo "usage: ktinit.sh path"
    echo "  the specified path must not exist"
    exit 1
fi

if [ -x "$1" ]; then
    echo "The specified path already exists!"
    exit 1
fi

mkdir -p "$1"

if [ $? -ne 0 ]; then
    echo "Unable to create directory!"
    exit 1
fi

cd "$1"

if [ $? -ne 0 ]; then
    echo "Unable to change directory!"
    exit 1
fi

gradle init --type java-library

rm -r src/main/java
rm -r src/test
mkdir -p src/main/kotlin

cat << EOF > .gitignore
/build
/.gradle
/gradle/wrapper/gradle-wrapper.properties
EOF

cat << EOF > build.gradle
apply plugin: "kotlin"
apply plugin: "application"

buildscript {
    ext.kotlin_version = '$version'

    repositories {
        jcenter()
    }

    dependencies {
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:\$kotlin_version"
    }
}

mainClassName = "_DefaultPackage"

repositories {
    jcenter()
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jre8:\$kotlin_version"
    implementation "org.jetbrains.kotlin:kotlin-stdlib:\$kotlin_version"
}
EOF

