import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

class yuroundedView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        // Não usamos layout XML, vamos desenhar diretamente
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Get screen dimensions
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;

        // Get user settings
        var backgroundColor = Application.Properties.getValue("BackgroundColor") as Number;
        var hourColor = Application.Properties.getValue("HourColor") as Number;
        var minuteColor = Application.Properties.getValue("MinuteColor") as Number;
        var timeFormat = Application.Properties.getValue("TimeFormat") as Number;
        var showNotificationIndicator = Application.Properties.getValue("ShowNotificationIndicator") as Boolean;
        
        // Battery settings
        var showBattery = Application.Properties.getValue("ShowBattery") as Boolean;
        var batteryFontSize = Application.Properties.getValue("BatteryFontSize") as Number;
        var batteryDisplayStyle = Application.Properties.getValue("BatteryDisplayStyle") as Number;
        var batteryColorSetting = Application.Properties.getValue("BatteryColor") as Number;
        var batteryPosition = Application.Properties.getValue("BatteryPosition") as Number;
        
        // Date settings
        var showDate = Application.Properties.getValue("ShowDate") as Boolean;
        var dateFormat = Application.Properties.getValue("DateFormat") as Number;
        var datePosition = Application.Properties.getValue("DatePosition") as Number;
        var dateColor = Application.Properties.getValue("DateColor") as Number;
        
        // Seconds settings
        var showSeconds = Application.Properties.getValue("ShowSeconds") as Boolean;
        var secondsColor = Application.Properties.getValue("SecondsColor") as Number;
        
        // Bluetooth settings
        var showBluetooth = Application.Properties.getValue("ShowBluetooth") as Boolean;
        var bluetoothPosition = Application.Properties.getValue("BluetoothPosition") as Number;
        var bluetoothColor = Application.Properties.getValue("BluetoothColor") as Number;

        // Clear the screen with background color
        dc.setColor(backgroundColor, backgroundColor);
        dc.clear();

        // Get the current time
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var minutes = clockTime.min;

        if (timeFormat == null) {
            timeFormat = 0;
        }

        var use24Hour = System.getDeviceSettings().is24Hour;
        if (timeFormat == 1) {
            use24Hour = true;
        } else if (timeFormat == 2) {
            use24Hour = false;
        }

        // Convert to 12-hour format if needed
        if (!use24Hour) {
            if (hours == 0) {
                hours = 12;
            } else if (hours > 12) {
                hours = hours - 12;
            }
        }

        // Format hours and minutes as strings
        var hoursString = hours.format("%d");
        var minutesString = minutes.format("%02d");

        // Set font - using largest available system font
        var largeFont = Graphics.FONT_NUMBER_THAI_HOT;

        // Calculate better vertical positioning for centering
        // Move both numbers closer to true center
        var spacing = 50; // Spacing between hour and minute
        
        // Draw hours (top) - with bold effect by drawing multiple times
        dc.setColor(hourColor, Graphics.COLOR_TRANSPARENT);
        var hoursY = centerY - spacing; // Position above center
        
        // Draw the hour text multiple times with slight offsets to create a bold effect
        dc.drawText(centerX, hoursY, largeFont, hoursString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(centerX + 1, hoursY, largeFont, hoursString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(centerX, hoursY + 1, largeFont, hoursString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(centerX + 1, hoursY + 1, largeFont, hoursString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw minutes (bottom) - with bold effect
        dc.setColor(minuteColor, Graphics.COLOR_TRANSPARENT);
        var minutesY = centerY + spacing; // Position below center
        
        // Draw the minute text multiple times with slight offsets to create a bold effect
        dc.drawText(centerX, minutesY, largeFont, minutesString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(centerX + 1, minutesY, largeFont, minutesString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(centerX, minutesY + 1, largeFont, minutesString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(centerX + 1, minutesY + 1, largeFont, minutesString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        
        // Draw seconds if enabled (small, below minutes)
        if (showSeconds) {
            var seconds = clockTime.sec;
            var secondsString = seconds.format("%02d");
            var secondsFont = Graphics.FONT_XTINY;
            var secondsY = minutesY + 55; // Position further below minutes
            
            dc.setColor(secondsColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, secondsY, secondsFont, secondsString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
        
        // Draw date if enabled
        if (showDate) {
            var now = Time.now();
            var dateString = "";
            
            // Format date based on user preference
            if (dateFormat == 0 || dateFormat == 1) {
                // Day/Month or Month/Day - use FORMAT_SHORT for numbers
                var dateInfo = Gregorian.info(now, Time.FORMAT_SHORT);
                if (dateFormat == 0) {
                    // Day/Month
                    dateString = dateInfo.day.format("%d") + "/" + dateInfo.month.format("%d");
                } else {
                    // Month/Day
                    dateString = dateInfo.month.format("%d") + "/" + dateInfo.day.format("%d");
                }
            } else {
                // Weekday - use FORMAT_MEDIUM for strings
                var dateInfo = Gregorian.info(now, Time.FORMAT_MEDIUM);
                if (dateFormat == 2) {
                    // Weekday (full) - use custom function
                    var dateInfoShort = Gregorian.info(now, Time.FORMAT_SHORT);
                    dateString = getDayOfWeekString(dateInfoShort.day_of_week, false);
                } else {
                    // Weekday (short) - use system string
                    dateString = dateInfo.day_of_week;
                }
            }
            
            var dateFont = Graphics.FONT_XTINY;
            var dateX, dateY;
            var dateJustify;
            
            // Position based on user preference
            if (datePosition == 0) {
                // Top
                dateX = centerX;
                dateY = 35;
                dateJustify = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
            } else if (datePosition == 1) {
                // Bottom
                dateX = centerX;
                dateY = height - 35;
                dateJustify = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
            } else if (datePosition == 2) {
                // Left
                dateX = 35;
                dateY = centerY;
                dateJustify = Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER;
            } else {
                // Right
                dateX = width - 35;
                dateY = centerY;
                dateJustify = Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER;
            }
            
            dc.setColor(dateColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(dateX, dateY, dateFont, dateString, dateJustify);
        }
        
        // Draw Bluetooth indicator if enabled
        if (showBluetooth) {
            var deviceSettings = System.getDeviceSettings();
            
            // phoneConnected is available since API 1.1.0
            if (deviceSettings.phoneConnected) {
                var btX, btY;
                var btSize = 6; // Size of the Bluetooth icon
                
                // Position based on user preference
                if (bluetoothPosition == 0) {
                    // Top Left
                    btX = 35;
                    btY = 35;
                } else if (bluetoothPosition == 1) {
                    // Top Right
                    btX = width - 35;
                    btY = 35;
                } else if (bluetoothPosition == 2) {
                    // Bottom Left
                    btX = 35;
                    btY = height - 35;
                } else {
                    // Bottom Right
                    btX = width - 35;
                    btY = height - 35;
                }
                
                // Draw simple Bluetooth symbol (filled circle)
                dc.setColor(bluetoothColor, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(btX, btY, btSize);
            }
        }

        // Draw notification indicator if enabled and there are notifications
        if (showNotificationIndicator) {
            var deviceSettings = System.getDeviceSettings();
            var notificationCount = 0;
            
            // Check if device supports notification count
            if (deviceSettings has :notificationCount) {
                notificationCount = deviceSettings.notificationCount;
            }
            
            // Draw red dot if there are notifications
            if (notificationCount > 0) {
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(centerX, 70, 10); // Larger red dot, positioned lower
            }
        }

        // Draw battery level if enabled
        if (showBattery) {
            var stats = System.getSystemStats();
            var battery = stats.battery;
            
            // Determine battery color
            var batteryColor;
            if (batteryColorSetting == -1) {
                // Auto mode: use alert colors or contrast color
                if (battery <= 20) {
                    batteryColor = Graphics.COLOR_RED;
                } else if (battery <= 50) {
                    batteryColor = Graphics.COLOR_YELLOW;
                } else {
                    // Use a color that contrasts with background
                    if (backgroundColor == 0x000000) {
                        batteryColor = Graphics.COLOR_WHITE;
                    } else {
                        batteryColor = Graphics.COLOR_BLACK;
                    }
                }
            } else {
                // Use custom color
                batteryColor = batteryColorSetting;
            }
            
            // Determine battery position based on user preference
            var batteryY;
            if (batteryPosition == 0) {
                // Top
                batteryY = 30;
            } else if (batteryPosition == 1) {
                // Middle (side of time)
                batteryY = centerY;
            } else {
                // Bottom (default)
                batteryY = height - 30;
            }
            
            // Check display style: 0 = Percentage, 1 = Icon (Bar)
            if (batteryDisplayStyle == 0) {
                // Display as percentage text
                var batteryString = battery.format("%.0f") + "%";
                
                // Select font size based on user preference
                var batteryFont;
                if (batteryFontSize == 0) {
                    batteryFont = Graphics.FONT_SMALL;
                } else if (batteryFontSize == 1) {
                    batteryFont = Graphics.FONT_MEDIUM;
                } else {
                    batteryFont = Graphics.FONT_LARGE;
                }
                
                // Draw battery text
                dc.setColor(batteryColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(centerX, batteryY, batteryFont, batteryString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            } else {
                // Display as icon (battery bar)
                // Calculate bar dimensions based on font size preference
                var barWidth;
                var barHeight;
                
                if (batteryFontSize == 0) {
                    // Small
                    barWidth = 60;
                    barHeight = 12;
                } else if (batteryFontSize == 1) {
                    // Medium
                    barWidth = 80;
                    barHeight = 16;
                } else {
                    // Large
                    barWidth = 100;
                    barHeight = 20;
                }
                
                var barX = centerX - (barWidth / 2);
                var barY = batteryY - (barHeight / 2);
                
                // Draw battery outline (border)
                dc.setColor(batteryColor, Graphics.COLOR_TRANSPARENT);
                dc.drawRoundedRectangle(barX, barY, barWidth, barHeight, 3);
                
                // Draw battery tip (small rectangle on the right)
                var tipWidth = 4;
                var tipHeight = barHeight / 2;
                var tipX = barX + barWidth;
                var tipY = barY + (barHeight / 4);
                dc.fillRoundedRectangle(tipX, tipY, tipWidth, tipHeight, 2);
                
                // Calculate fill width based on battery percentage
                var fillWidth = ((barWidth - 4) * battery / 100).toNumber();
                
                // Draw battery fill (inner bar)
                if (fillWidth > 0) {
                    dc.setColor(batteryColor, Graphics.COLOR_TRANSPARENT);
                    dc.fillRoundedRectangle(barX + 2, barY + 2, fillWidth, barHeight - 4, 2);
                }
            }
        }
    }

    // Helper function to get day of week string
    function getDayOfWeekString(dayOfWeek as Number, isShort as Boolean) as String {
        var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
        var daysShort = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
        
        if (isShort) {
            return daysShort[dayOfWeek - 1];
        } else {
            return days[dayOfWeek - 1];
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
