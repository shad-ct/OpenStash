# OpenStash

**Curate your mind. Discover, save, and organize insights that matter.**

OpenStash is a modern, open-source knowledge curation platform designed for deep learning in a fast-paced world. It aggregates articles, podcasts, and books into bite-sized, actionable insights, allowing you to build your personal wisdom library.

![OpenStash Preview](https://via.placeholder.com/800x400?text=OpenStash+UI+Preview) <!-- Replace with real screenshot if available -->

## ✨ Key Features

- **Dual-Mode Feed**: Switch between a classic list view and an immersive, vertical **TikTok-style feed** for focused reading.
- **Micro-Learning**: Knowledge is distilled into "Idea Cards"—digestible points that respect your time.
- **Smart Summarization**: Powered by an AI-driven backend that fetches and summarizes articles from various RSS feeds and sources.
- **Offline First**: Full offline support using **Drift (SQLite)** caching, ensuring your insights are available even without a connection.
- **Gamified Streaks**: Build a daily reading habit with the integrated streak system and activity calendar.
- **Glassmorphic UI**: A premium, modern design with frosted-glass effects, smooth animations, and a sleek dark mode.

## 🚀 Tech Stack

### Frontend (Flutter)
- **Framework**: Flutter (Dart)
- **State Management**: State-driven UI with efficient refreshes.
- **Persistence**: Drift (SQLite) for offline data and Shared Preferences for settings.
- **Animations**: `flutter_animate` for smooth micro-interactions.

### Backend (Node.js)
- **Runtime**: Node.js / Express
- **Database**: MongoDB (via Mongoose)
- **Aggregation**: Automated jobs for fetching and summarizing fresh content.

## 🛠️ Getting Started

### Prerequisites
- Flutter SDK
- Node.js (v16+)
- MongoDB instance

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/shad-ct/OpenStash.git
   cd OpenStash
   ```

2. **Frontend Setup**
   ```bash
   flutter pub get
   flutter run
   ```

3. **Backend Setup**
   ```bash
   cd server
   npm install
   # Configure your .env file
   npm start
   ```

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests to help make OpenStash better.

---
Created with ❤️ by [Shad-CT](mailto:contactshadct@gmail.com)
