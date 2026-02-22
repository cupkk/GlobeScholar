# GlobeScholar (留学雷达) 🚀

A modern iOS application built with SwiftUI, MapKit, and SwiftData, designed to help students discover and track global academic opportunities (Summer Research, PhD openings, etc.).

This repository contains two main components:

1. **`iOSApp/`**: The native iOS application source code.
2. **`backend/`**: A serverless Python data pipeline powered by OpenAI and GitHub Actions.

---

## 📱 Part 1: How to Run the iOS App

To see the app running on your iPhone or Mac Simulator, follow these steps:

### 1. Create an Xcode Project

1. Open **Xcode** on your Mac.
2. Click **Create a new Xcode project**.
3. Select **iOS** -> **App**.
4. Name the product `GlobeScholar`, ensure the Interface is set to **SwiftUI** and Language is **Swift**. Storage can be set to None (we implemented our own SwiftData container).
5. Choose a location to save the Xcode project.

### 2. Import the Code

1. Open the folder where you created the Xcode project in Finder.
2. Delete the default `ContentView.swift` and `GlobeScholarApp.swift` (or whatever your main app file is named).
3. Drag and drop **all `.swift` files** from this repository's `iOSApp/` folder into your Xcode project navigator. Ensure "Copy items if needed" is checked.

### 3. Configure Assets & Permissions

#### Setup Dark Mode Colors

1. Open `Assets.xcassets` in Xcode.
2. Click the `+` at the bottom and create a new **Color Set**.
3. Rename it exactly to `BrandNavy`.
4. In the Attributes Inspector (right panel), set Appearances to **Any, Dark**.
5. Set the "Any" (Light mode) color to Hex `#1A365D`.
6. Set the "Dark" mode color to a lighter blue, e.g., Hex `#4A90E2`.

#### Add Privacy Permissions (`Info.plist`)

Because our app exports deadlines to the system calendar, Apple requires us to declare why we need this permission.

1. Click on your project name at the top of the Project Navigator.
2. Go to the **Info** tab.
3. Hover over the last row, click the `+` to add a new key.
4. Add: `Privacy - Calendars Write Only Access Usage Description` (or `NSCalendarsWriteOnlyAccessUsageDescription`).
5. Set the value to: `We need access to your calendar to export application deadlines.`

### 4. Build and Run!

- Select a simulator (e.g., iPhone 15 Pro) from the top bar.
- Press **Cmd + R** (or the Play button).
- The app will launch! On the very first launch, it will automatically inject localized mock data so you can see the maps and lists immediately.

---

## ⚙️ Part 2: How to Run the Backend Data Pipeline

We built a totally free, serverless backend that automatically scrapes unstructured data, uses AI to clean it into strict JSON, and hosts it.

### 1. Push to GitHub

If you haven't already, push this entire `GlobeScholar` folder to a GitHub repository.

### 2. Add OpenAI API Key

To let the Python cleaner intelligently parse unstructured text (like Reddit posts or raw HTML):

1. Go to your GitHub Repository -> **Settings** -> **Secrets and variables** -> **Actions**.
2. Click **New repository secret**.
3. Name: `OPENAI_API_KEY`.
4. Value: Paste your actual OpenAI API secret key.

### 3. Activate the Action

Our `.github/workflows/scraper.yml` is already configured.

- It will run automatically every day at 02:00 UTC.
- To test it immediately: Go to the **Actions** tab in your GitHub repo, select **Daily Data Scraper**, and click **Run workflow**.

### 4. Connect iOS to the Cloud (The Final Loop)

Once the Action runs successfully, it commits `opportunities.json` to the repo.

1. In your GitHub repo, navigate to `backend/scraper/opportunities.json`.
2. Click the **Raw** button to get the raw textual link (it should start with `https://raw.githubusercontent.com/...`).
3. Open `NetworkManager.swift` in Xcode.
4. Replace the `run.mocky.io` placeholder link on line 25 with your new raw GitHub URL.
5. Re-run the iOS app. Every time you open the app, it will silently sync the newest opportunities from GitHub directly into the phone's local SwiftData!

---

Enjoy building GlobeScholar! 🌍🎓
