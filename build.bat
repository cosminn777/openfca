@echo off

REM This batch file builds the SpringGraph component and the 2 sample applications. The results are
REM    SpringGraph/bin/SpringGraph.swc
REM    Samples/xxx/bin/xxx.swf ... for each demo project
REM   
REM Make sure that your Flex SDK/bin directory is on your search path, for example
REM 	set path=C:\Program Files\Adobe\Flex Builder 2\Flex SDK 2\bin;%path%
REM To run from the command line, CD to the same folder that this bat file 
REM 	is in, then do "build.bat".
REM To run from Windows Explorer, just double-click the batch file.

REM build the SpringGraph component
compc.exe -source-path SpringGraph\src -output SpringGraph\bin\SpringGraph.swc -include-namespaces=http://www.adobe.com/2006/fc -namespace http://www.adobe.com/2006/fc SpringGraph/manifest.xml
