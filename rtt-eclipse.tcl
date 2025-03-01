#===============================================================================
# \file rtt.tcl
# \version 1.0.1 fork
#
# \brief
# The tcl script which starts the RTT server. Is used by the CAPSENSE(TM) Tuner 
# application.
#
#===============================================================================
# \copyright
# Copyright 2023-2024 Cypress Semiconductor Corporation
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#===============================================================================

# Check if a mandatory MODUS_TOOL_GCC variable exists
if { ![info exists MODUS_TOOL_GCC] } {
    puts stderr "[info script]: Error: Variable MODUS_TOOL_GCC is missing"
    shutdown
}

# Check if a mandatory ELF_FILE variable exists
if { ![info exists ELF_FILE] } {
    puts stderr "[info script]: Error: Variable ELF_FILE is missing"
    shutdown
}

# Check if a mandatory PSOC_DEVICE variable exists
if { ![info exists PSOC_DEVICE] } {
    puts stderr "[info script]: Error: Variable PSOC_DEVICE is missing"
    shutdown
}

# Check if RTT_PORT_START variable exists
if { ![info exists RTT_PORT_START] } {
    set RTT_PORT_START 50566
    puts stdout "[info script]: Info: Variable RTT_PORT_START is missing, using default $RTT_PORT_START"
}

# Check if RTT_PORT_COUNT variable exists
if { ![info exists RTT_PORT_COUNT] } {
    set RTT_PORT_COUNT 2
    puts stdout "[info script]: Info: Variable RTT_PORT_COUNT is missing, using default $RTT_PORT_COUNT"
}

# Check if RTT_POLL_INTERVAL variable exists
if { ![info exists RTT_POLL_INTERVAL] } {
    set RTT_POLL_INTERVAL 5
    puts stdout "[info script]: Info: Variable RTT_POLL_INTERVAL is missing, using default $RTT_POLL_INTERVAL ms"    
}

set NM "$MODUS_TOOL_GCC/bin/arm-none-eabi-nm"
set nmOutput ""
if [ catch {set nmOutput [exec $NM "--defined-only" "-C" "-p" $ELF_FILE]} ] {
    puts stderr "Could not run $NM on $ELF_FILE"
    puts stderr $::errorCode
    if [info exists ::errorInfo] {
        puts stderr $::errorInfo
    }
    shutdown
}

set rttCbAddr ""
foreach line [split $nmOutput "\n"] {
    set line [string trim $line]
    if [regexp {^([0-9a-fA-F]+) . _SEGGER_RTT$} $line all rttCbAddr] {
        puts stderr "[info script]: Info: Found symbol '_SEGGER_RTT' @ 0x${rttCbAddr} in executable '$ELF_FILE'"
        # Puts "Found '$all' -> $rttCbAddr"
        break
    }
}

if [string equal $rttCbAddr ""] {
    puts stderr "[info script]: Error: Could not find symbol '_SEGGER_RTT' in executable '$ELF_FILE'"
    shutdown
}

set reset_delay 1000

proc echoAndRun {args} {
    puts stdout "Command: [info script]: ${args}"
    eval $args
}

proc printChannels {} {
    puts stdout "[info script]: RTT Channel Info"
    set prefix "  Up Channels:   Host <-- Device"
    foreach item [rtt channellist] {
        puts stdout $prefix
        for {set i 0} {$i < [llength $item]} {incr i} {
            puts -nonewline stdout "    $i => "
            set channels [lindex $item $i]
            set last [expr {[llength $channels] - 1}]
            for {set j 0} {$j <= $last} {incr j} {
                if {$j % 2} {
                    puts -nonewline stdout "[lindex $channels $j]"
                    puts -nonewline stdout [expr {($j < $last) ? ", " : ""}]
                } else {
                    puts -nonewline stdout "[lindex $channels $j]: "
                }
            }
            puts stdout ""
        }
        set prefix "  Down Channels: Host --> Device"
    }
}

proc startRTT {} {
    global rttCbAddr RTT_PORT_COUNT RTT_PORT_START RTT_STARTED RTT_POLL_INTERVAL
    echoAndRun rtt setup "0x$rttCbAddr" 10 {SEGGER RTT}
    for {set i 0} {$i < $RTT_PORT_COUNT} {incr i} {
        set port [expr {$RTT_PORT_START + $i}]
        # Puts stdout "[info script]: Info: Trying to start server for RTT channel $i on TCP port $port"
        echoAndRun rtt server start $port $i
        set RTT_STARTED 1
    }
    echoAndRun rtt polling_interval $RTT_POLL_INTERVAL
    echoAndRun rtt start

    printChannels
}

# Following will prevent a sysresetq or other resets
set ENABLE_ACQUIRE 0
set PSOC4_USE_ACQUIRE 0

# Let OpenOCD finish all the way before we start RTT.
after 500 {
    startRTT
}
