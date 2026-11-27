# Helix TV — distribution (TestFlight)

Set up 2026-11-26 with Brandon at the keyboard.

- Apple team: Market Mavens LLC (GYWYUZLMZN), paid account (dev profiles valid 1 year).
- App ID registered: `com.helixmedia360.helixtv` (explicit, no capabilities). The iOS target's Wi-Fi-info entitlement was dropped so the team profile signs it.
- App Store Connect record: **Helix TV**, app id 6839888303, platforms iOS + tvOS, SKU `helixtv`, primary language English (U.S.).
  https://appstoreconnect.apple.com/apps/6839888303
- Xcode on the mini is signed in to the team (Xcode > Settings > Accounts), so archives/uploads run from the mini without Brandon. Build locally — never GitHub Actions.

## Devices (dev loop, no TestFlight needed)
- Apple TV "Living Room" paired (UDID eab8f268f46c389b1d958b5846f1c12c1744d6f9).
- iPhone "Brandons Iphone" (iPhone 16 Pro Max) paired over USB 2026-11-26, UDID 00008140-001A28840A0B001C; Wi-Fi installs after that.
- 3 Apple TVs in the house (4 soon) → they get the app via TestFlight, not pairing.

## Uploading (done from the mini)
`tools/upload-testflight.sh tvos|ios` = archive to ~/Library/Developer/Xcode/Archives/<date>/ + export/upload with
`~/.helixtv/export/ExportOptions.plist` (method app-store-connect, destination upload, team GYWYUZLMZN, automatic signing).
GOTCHA (2026-11-26): `xcodebuild -exportArchive` failed with "Copy failed" three times. Root cause: the IPA step runs
`/usr/bin/rsync` (Apple openrsync), which spawns the *server* side from PATH → Homebrew rsync 3.5.0 → "--extended-attributes:
unknown option". Fix = run with PATH=/usr/bin:/bin:/usr/sbin:/sbin (the script does). The dSYM warning for Libmpv.framework
is harmless (prebuilt binary, no symbols).

- tvOS build 1 uploaded 2026-11-26 22:46 as version 1.4.1 (70) — upstream Swiftfin's tvOS numbers; iOS target is 1.0 (1).
- Both targets now share MARKETING_VERSION 1.5.0 / CURRENT_PROJECT_VERSION 100 (bump the build number before every upload).
- iOS build uploaded 2026-11-26 23:03 as 1.5.0 (100). Fix needed first: the project-level Release config and the "Swiftfin iOS"
  Release config did not include XcodeConfig/Shared.xcconfig (no team) and hardcoded org.jellyfin.swiftfin — both fixed in the pbxproj.
- TestFlight groups: "Helix Internal" (internal, automatic distribution, tester = the App Store Connect account holder
  info@helixmedia360.com) and "Helix Family" (external, EMPTY — adding a build there triggers Beta App Review, which asks for a
  reviewer sign-in to the Jellyfin server; decided not to do that). Apple TVs use the personal Apple ID blaubach09@gmail.com →
  plan = invite it as an App Store Connect user (Customer Support role) and add to Helix Internal; same for family Apple IDs.

## Still to do before the first TestFlight build
1. 1024px App Store icons (iOS + tvOS layered), no transparency — Helix mark.
2. Phone branding/density pass (stock Swiftfin phone layouts today).
3. Archive + upload iOS and tvOS from the mini (xcodebuild archive / -exportArchive with method app-store-connect, or Xcode Organizer).
4. TestFlight: internal group for Brandon; public link for family (first external build gets a short Apple review). Builds expire after 90 days → re-upload at least quarterly.

## Device notes (2026-11-26)
- iPhone: `xcrun devicectl device capture screenshot --device <udid> --destination x.png` works when unlocked and on USB or the
  same Wi-Fi as the mini; there is no tap/key automation for iPhone (unlike the Apple TV via pyatv). Deep links
  (`swiftfin://<serverId>/<userId>/item/<id>`) exist but did not navigate when launched through devicectl.
- Screenshots fail while video plays (both platforms).
- Art speed: through Tailscale Funnel ~0.75 s per image; direct over the tailnet 0.06–0.15 s. Phones should run Tailscale.
