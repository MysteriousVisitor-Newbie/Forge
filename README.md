# Forge

A focused work planner for iPhone. SwiftUI + SwiftData. No third-party packages.

Plan the day, group work into projects, and track what actually shipped.

## What it includes

- **Today** — greeting, completion ring, overdue + due-today lists
- **Tasks** — inbox of all work, search, priority, due dates, swipe to complete or delete
- **Projects** — color-coded lists (Work, Personal, …) with live counts
- **Settings** — sample data, wipe completed, about
- Local persistence with **SwiftData** (stays on the device)
- Dark Mode and Dynamic Type

Requires **Xcode 16+**, **iOS 17+**, and a Mac. You do not need a paid Apple Developer account to run it on the Simulator. Running on a physical iPhone needs a free Apple ID in Signing.

## Open this in Xcode (5 minutes)

1. On a Mac, open **Xcode**.
2. **File → New → Project…**
3. Choose **iOS → App**. Click Next.
4. Set:
   - Product Name: `Forge`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **SwiftData** (if you see this option). If not, leave it off — the code already configures the container.
   - Uncheck Tests if you want a smaller project.
5. Save the project anywhere. Xcode creates `ForgeApp.swift` and `ContentView.swift`.
6. **Delete** the generated `ContentView.swift` and the generated model file if Xcode made one (`Item.swift` or similar).
7. Drag every file from this folder’s `Forge/` directory into the Xcode project navigator:
   - Choose **Copy items if needed**
   - Check **Add to targets: Forge**
8. Replace the generated `ForgeApp.swift` with the one from this repo (or paste its contents).
9. Select the **Forge** target → **General** → **Minimum Deployments: iOS 17.0**.
10. Pick an iPhone simulator and press **⌘R**.

On first launch the app seeds three projects and a handful of sample tasks so the UI is not empty.

## Signing for a real iPhone

1. Plug in the iPhone, trust the computer.
2. Target → **Signing & Capabilities** → Team → your Apple ID.
3. Change the Bundle Identifier to something unique, e.g. `com.yourname.Forge`.
4. On the phone: Settings → General → VPN & Device Management → trust your developer certificate.

App Store submission needs a paid Apple Developer Program membership ($99/year). This project is ready to extend, not packaged for the store.
