# InternTrackr 🚀

**InternTrackr** is a cross-platform mobile application designed to help university students seamlessly track their internship application pipelines, manage outreach, and organize their career journeys. Built with Flutter and Firebase, it provides a clean, modern, and highly responsive experience for managing applications from the "Wishlist" phase all the way to "Offer."

## ✨ Key Features

* **Secure Authentication:** User sign-up and login powered by Firebase Auth, featuring a live password security checklist and secure password resets.
* **Centralized Dashboard:** Keep track of all your internship applications (Applied, Interview, Offer, Rejected, Wishlist) in one organized view.
* **Visual Analytics:** Gain insights into your application success rate and pipeline health using interactive charts (`fl_chart`).
* **Interactive Map:** View company locations and remote hubs globally using integrated mapping (`flutter_map`).
* **Profile & Resume Management:** Upload, manage, and preview profile avatars and resume documents (PDF/DOCX) directly in the app, powered by Firebase Cloud Storage.
* **Custom Themes:** Beautifully designed UI with seamless Light and Dark mode toggling.
* **Offline Fallback:** Includes a local JSON data fallback for development testing and offline previewing.

## 🛠️ Tech Stack

* **Frontend:** Flutter & Dart
* **Backend:** Firebase (Authentication, Cloud Firestore, Cloud Storage)
* **State Management:** Provider (`ChangeNotifier`)
* **Key Packages:** 
  * `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
  * `provider` for state management
  * `fl_chart` for analytics
  * `flutter_map` & `latlong2` for interactive maps
  * `file_picker` & `image_picker` for media uploads
  * `shared_preferences` for local theme and session caching

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (>=3.0.0 <4.0.0)
* Dart SDK
* A Firebase Project (with Authentication, Firestore, and Storage enabled)

### Installation

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/YOUR_USERNAME/interntrackr.git](https://github.com/YOUR_USERNAME/interntrackr.git)
   cd interntrackr