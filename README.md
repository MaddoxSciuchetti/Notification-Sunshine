# Shining Sun

A minimal macOS 13+ menu-bar app for an Arduino RGB light sensor. It has no
normal window and no Dock icon. The menu-bar symbol shows one of three levels:
low, medium, or high sunlight.

## Run it

1. Open `Arduino/ShiningSun/ShiningSun.ino` in Arduino IDE, select the board and USB port,
   and upload it.
2. In Terminal, from this folder, run:

   ```sh
   ./scripts/build-app.sh
   open "dist/Shining Sun.app"
   ```

The app automatically looks for common Arduino USB serial device names and
connects at 9600 baud. Click the sun/cloud symbol in the right side of the macOS
menu bar to see the reading or enter an email address.

## Configure daily email

Automated email must be sent by a trusted server; an email-provider API key
must never be embedded in a distributed Mac app. Set `SunshineSubscriptionURL`
in `Resources/Info.plist` to your HTTPS subscription endpoint before building.

When the user clicks **Enable**, the app sends:

```json
{
  "email": "person@example.com",
  "timeZone": "America/Los_Angeles",
  "locale": "en_US",
  "sunlightLevel": "high"
}
```

The endpoint should validate/confirm the address, store the subscription, infer
or ask for the forecast location, and schedule a daily email containing the
weather and temperature. Any successful HTTP `2xx` response is shown as
“Daily weather email enabled”; other response bodies are shown as errors.

For production, use double opt-in, provide an unsubscribe link, keep provider
keys only on the server, and follow the email laws that apply to your users.

## Sensor calibration

The level uses the average mapped RGB value:

- Low: 0–84
- Medium: 85–169
- High: 170–255

Ambient sensors and wiring vary. Adjust the two thresholds in
`Sources/ShiningSun/SunlightReading.swift` after comparing readings in your
actual room. If the RGB LED is common-anode, write `255 - value` to each LED
channel in the Arduino sketch.
