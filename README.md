# Segger RTT integration demo

This is a demo for Segger RTT integration. Last tested with ModusToolbox Tools Package 3.4 and Eclipse for ModusToolbox 3.4.

Open modus shell (type "modus-shell" in Windows start, or open from \ModusToolbox\tools_3.4\modus-shell\Cygwin.bat or use your terminal), navigate to your folder, then:

VSCode instructions:

1.	git clone https://github.com/mykz-cy/rtt-test.git
2.	cd rtt-test
3.	make getlibs
4.	make vscode
5.	open vscode, open the workspace from file
6.	copy the launch config parts from the rtt-test\vscodelaunchconfigadd file into your rtt-test\.vscode\launch.json
7.	Launch debug

Eclipse instructions:

1. git clone https://github.com/mykz-cy/rtt-test.git
2. Open Eclipse for ModusToolbox
3. Create new Eclipse workspace in the same directory you now have the rtt-test folder
4. In Eclipse select "Import existing application in place" and point to the folder where your rtt-test folder is located. WWait until project is created and imported (might take some time because it is importing libraries)
5. Try debugging. If successul stop session and modify the launch configurations as in the rtt-test/openocdlaunchconfigeclipse file in this repo. Fix paths to elf and tools.
6. Launch debug session. While running in main loop open telnet at localhost 50566 (and 50567) and see output.  


See ModusToolbox community post here: https://community.infineon.com/t5/ModusToolbox/Using-Segger-RTT-library-in-ModusToolbox/td-p/965434