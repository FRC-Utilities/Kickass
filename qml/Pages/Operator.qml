/*
 * Copyright (c) 2015-2017 Alex Spataru <alex_spataru@outlook.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Controls.Universal 2.0

import DriverStation 1.0

import "../Widgets"
import "../Globals.js" as Globals

Pane {    
    //
    // Disable robot if user changes to another page
    //
    onVisibleChanged: enableBt.checked = false

    //
    // Functions to control the visibility of the joystick controls
    // from main.qml, used when users press the back button on Android
    //
    function hideJoysticks() { enableBt.checked = false }
    readonly property alias showingJoysticks: joysticks.visible

    //
    // Disable the robot when joystick count changes
    //
    Connections {
        target: QJoysticks
        onCountChanged: enableBt.checked = false
    }

    //
    // Disable robot when communications state is changed
    //
    Connections {
        target: DS
        onEmergencyStoppedChanged: enableBt.checked = false
        onRobotCommunicationsChanged: enableBt.checked = false
    }

    //
    // Holds all the widgets
    //
    ColumnLayout {
        anchors.fill: parent
        spacing: Globals.spacing

        //
        // Operator and Joystick selector
        //
        StackView {
            id: stack
            initialItem: controls
            Layout.fillWidth: true
            Layout.fillHeight: true

            Controls {
                id: controls
                visible: false
            }

            Joysticks {
                id: joysticks
                visible: false
                simulation: false
            }
        }

        //
        // Enabled disabled button
        //
        Button {
            id: enableBt
            checkable: true
            highlighted: true
            checked: DS.enabled
            Layout.fillWidth: true
            Layout.maximumWidth: 312
            Material.theme: Material.Light
            Universal.theme: Universal.Dark
            anchors.horizontalCenter: parent.horizontalCenter
            text: checked ? qsTr ("Disable") : qsTr ("Enable")

            onCheckedChanged: {
                var enabled = checked

                //
                // User tried to enable robot when it cannot be enabled
                //
                if (enabled && !DS.canBeEnabled)
                    enabled = false

                //
                // Update button state if neccessary
                //
                checked = enabled

                //
                // Show joysticks if robot is in teleop and enabled
                //
                if (DS.isTeleoperated && enabled) {
                    stack.push (joysticks)
                    joysticks.visible = true
                }

                //
                // Robot is not in teleop, hide joysticks
                //
                else {
                    stack.pop()
                    joysticks.visible = false
                }

                //
                // Finally, enable or disable the robot
                //
                DS.enabled = enabled
            }
        }
    }
}
