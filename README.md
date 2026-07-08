<div align="center">

# 🌿 CivicFix
### Smart Complaint Management System

*A Solarpunk-themed civic engagement platform where citizens report, track, and upvote local infrastructure complaints — and administrators resolve them.*

[![Java](https://img.shields.io/badge/Java-17-orange?style=flat-square&logo=java)](https://openjdk.org/)
[![Tomcat](https://img.shields.io/badge/Tomcat-7%2F9-yellow?style=flat-square&logo=apache)](https://tomcat.apache.org/)
[![SQLite](https://img.shields.io/badge/SQLite-3.45-blue?style=flat-square&logo=sqlite)](https://sqlite.org/)
[![Maven](https://img.shields.io/badge/Maven-3.x-red?style=flat-square&logo=apachemaven)](https://maven.apache.org/)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

</div>

---

## 🚀 Live Demo

[https://filedalokhiseb.netlify.app/](https://filedalokhiseb.netlify.app/)


## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Deployment](#deployment)
- [Role-Based Access Control](#role-based-access-control)
- [Database Schema](#database-schema)
- [API / Servlet Endpoints](#api--servlet-endpoints)
- [Screenshots](#screenshots)
- [Contributing](#contributing)

---

## 🌱 Overview

**CivicFix** is a full-stack Java web application that empowers citizens to report civic issues (potholes, broken streetlights, water leaks, etc.) to local authorities. It provides a clean, role-separated interface for:

- **Citizens** — submit complaints, upvote existing issues, track resolution status, and earn bounty points.
- **Admins** — review complaints, update statuses, dispatch field teams, and manage the leaderboard.

The UI follows a **Solarpunk** aesthetic — lush greens, warm golds, glassmorphism cards, and animated gradients — reflecting a hopeful, eco-conscious vision of civic tech.

---

## ✨ Features

### Citizen Features
| Feature | Description |
|---------|-------------|
| 📝 **Submit Complaints** | File a new civic complaint with title, description, category, image upload, and automatic severity scoring |
| 🔺 **Upvote Issues** | Boost a complaint's severity score (+10 per vote) to prioritize it |
| 📊 **Live Dashboard** | View all open complaints sorted by severity and status |
| 🔍 **Complaint Details** | Click any complaint to see full details, images, dispatch logs |
| 🏆 **Leaderboard** | See top civic contributors ranked by points earned |
| 💎 **Bloom Points** | Earn and redeem bounty points for civic engagement |
| 🔐 **OTP Login** | Secure email-based OTP authentication |

### Admin Features
| Feature | Description |
|---------|-------------|
| 🗂️ **Control Matrix** | Admin dashboard with full complaint management |
| ✅ **Status Updates** | Update complaint status (OPEN → IN PROGRESS → RESOLVED) |
| 🚒 **Dispatch Teams** | Log field team dispatches with notes |
| 🗑️ **Soft Delete** | Archive complaints without permanent deletion |
| 📈 **Severity Management** | Manually adjust severity scores |
| 🔒 **Strict Role Isolation** | Admins cannot access citizen pages and vice versa |

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Backend** | Java 17, Jakarta Servlets |
| **Frontend** | JSP, HTML5, CSS3 (Vanilla), JavaScript |
| **Database** | SQLite 3 (via Xerial JDBC driver) |
| **Server** | Apache Tomcat 7/9 |
| **Build** | Apache Maven 3.x |
| **Email** | JavaMail API (OTP notifications) |
| **Deployment** | Docker + Render |

---

## 📁 Project Structure

```
CivicFix/
├── src/
│   └── main/
│       ├── java/com/civicfix/
│       │   ├── AppConfig.java              # App-wide configuration
│       │   ├── AppStartup.java             # ServletContextListener
│       │   ├── controller/
│       │   │   ├── AdminController.java    # Admin actions (delete, update)
│       │   │   ├── BountyServlet.java      # Bounty points handler
│       │   │   ├── DispatchServlet.java    # Field team dispatch
│       │   │   ├── IdentityServlet.java    # User identity & session
│       │   │   ├── OtpServlet.java         # OTP generation & validation
│       │   │   ├── RedeemServlet.java      # Points redemption
│       │   │   ├── StatusUpdateServlet.java# Complaint status updates
│       │   │   ├── SubmitComplaintServlet.java # New complaint handler
│       │   │   ├── UpdateComplaintServlet.java # Edit complaint handler
│       │   │   └── VoteServlet.java        # Upvote handler
│       │   ├── dao/
│       │   │   ├── ComplaintDAO.java       # Complaint DB operations
│       │   │   ├── DBConnection.java       # SQLite connection manager
│       │   │   └── UserDAO.java            # User DB operations
│       │   ├── model/
│       │   │   ├── Complaint.java          # Complaint POJO
│       │   │   └── User.java               # User POJO
│       │   ├── service/
│       │   │   ├── EmailService.java       # JavaMail OTP sender
│       │   │   └── OtpService.java         # OTP generation logic
│       │   └── validators/
│       │       └── EmailValidator.java     # Email format validation
│       └── webapp/
│           ├── index.jsp                   # Landing page
│           ├── login.jsp                   # Login / Register
│           ├── user-dashboard.jsp          # Citizen dashboard
│           ├── admin-dashboard.jsp         # Admin control matrix
│           ├── complaint-details.jsp       # Complaint detail view
│           ├── leaderboard.jsp             # Points leaderboard
│           ├── bloom.jsp                   # Bloom points store
│           ├── web.xml                     # Servlet mappings
│           └── uploads/                   # User-uploaded complaint images
├── civicfix.db                            # SQLite database file
├── pom.xml                                # Maven build config
├── Dockerfile                             # Docker image for deployment
├── render.yaml                            # Render deployment config
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites

- **Java 17+** — [Download](https://adoptium.net/)
- **Maven 3.6+** — [Download](https://maven.apache.org/download.cgi)
- **Git** — [Download](https://git-scm.com/)

### 1. Clone the Repository

```bash
git clone https://github.com/akshat3021/CivicFix.git
cd CivicFix
```

### 2. Build the Project

```bash
mvn clean package
```

### 3. Run Locally

```bash
mvn tomcat7:run
```

Then open your browser and go to:
```
http://localhost:8080/
```

### 4. Default Credentials

| Role | Username | Password |
|------|----------|----------|
| Admin | `admin1` | `admin123` |
| Citizen | `user1` | `pass123` |

> **Note:** You can register new citizen accounts from the login page.

---

## ☁️ Deployment

### Deploy on Render (Recommended)

CivicFix is pre-configured for one-click deployment on [Render](https://render.com).

1. **Fork** this repository to your GitHub account
2. Go to [render.com](https://render.com) → **New** → **Web Service**
3. Connect your GitHub repo
4. Render auto-detects `render.yaml` and configures everything
5. Click **Deploy** — your app will be live in ~5 minutes!

### Deploy with Docker

```bash
# Build the Docker image
docker build -t civicfix .

# Run the container
docker run -p 8080:8080 civicfix
```

Visit `http://localhost:8080` in your browser.

### Deploy to Standalone Tomcat

```bash
mvn package
cp target/CivicFix.war $TOMCAT_HOME/webapps/ROOT.war
$TOMCAT_HOME/bin/startup.sh
```

---

## 🔒 Role-Based Access Control

CivicFix enforces strict session isolation between roles:

```
                    ┌─────────────┐
                    │   Login     │
                    └──────┬──────┘
                           │
              ┌────────────┴────────────┐
              │                         │
        role = CITIZEN             role = ADMIN
              │                         │
              ▼                         ▼
    ┌──────────────────┐     ┌──────────────────────┐
    │  User Dashboard  │     │   Admin Control      │
    │  Complaint Feed  │     │   Matrix Dashboard   │
    │  Upvote / Submit │     │   Status Updates     │
    │  Leaderboard     │     │   Dispatch Teams     │
    └──────────────────┘     └──────────────────────┘
```

| Action | Citizen | Admin |
|--------|---------|-------|
| View complaints | ✅ | ✅ |
| Submit new complaint | ✅ | ❌ |
| Upvote complaint | ✅ | ❌ |
| Update complaint status | ❌ | ✅ |
| Dispatch field teams | ❌ | ✅ |
| Delete complaints | ❌ | ✅ |
| Access `/admin` route | ❌ → redirected to login | ✅ |
| Access `/user-dashboard` | ✅ | ❌ → redirected to admin |

---

## 🗄️ Database Schema

CivicFix uses **SQLite** (zero-config, file-based). The database file is `civicfix.db` in the project root.

### `users` table
```sql
CREATE TABLE users (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    username      TEXT UNIQUE NOT NULL,
    password      TEXT NOT NULL,
    email         TEXT UNIQUE NOT NULL,
    role          TEXT DEFAULT 'CITIZEN',   -- 'CITIZEN' or 'ADMIN'
    bloom_points  INTEGER DEFAULT 0
);
```

### `complaints` table
```sql
CREATE TABLE complaints (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    title           TEXT NOT NULL,
    description     TEXT,
    category        TEXT,
    severity_score  INTEGER DEFAULT 50,
    status          TEXT DEFAULT 'OPEN',    -- OPEN | IN PROGRESS | RESOLVED
    image_path      TEXT,
    user_id         INTEGER REFERENCES users(id),
    dispatch_status TEXT,
    dispatch_log    TEXT,
    bounty_pool     INTEGER DEFAULT 0,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### `user_votes` table
```sql
CREATE TABLE user_votes (
    username     TEXT,
    complaint_id INTEGER,
    PRIMARY KEY (username, complaint_id)    -- Prevents duplicate votes
);
```

---

## 🌐 API / Servlet Endpoints

| Servlet | URL Pattern | Method | Description |
|---------|-------------|--------|-------------|
| `IdentityServlet` | `/login` | POST | Login / Register |
| `OtpServlet` | `/otp` | POST | Send & verify OTP |
| `SubmitComplaintServlet` | `/submit` | POST | File a new complaint |
| `VoteServlet` | `/VoteServlet` | POST | Upvote a complaint |
| `StatusUpdateServlet` | `/update-status` | POST | Update complaint status (Admin) |
| `UpdateComplaintServlet` | `/update-complaint` | POST | Edit complaint details (Admin) |
| `AdminController` | `/admin` | GET/POST | Admin dashboard controller |
| `DispatchServlet` | `/dispatch` | POST | Log field team dispatch (Admin) |
| `BountyServlet` | `/bounty` | POST | Add bounty points to complaint |
| `RedeemServlet` | `/redeem` | POST | Redeem bloom points |

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. **Fork** the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m "Add: your feature description"`
4. Push to your fork: `git push origin feature/your-feature-name`
5. Open a **Pull Request** targeting the `main` branch

### Code Style
- Follow standard Java naming conventions
- Keep JSP files modular — avoid inline Java logic
- Always check the session `role` attribute for access control (never rely on `adminName`)

---

## 👥 Contributors

| Name | Role |
|------|------|
| **Akshat Aswal** | Project Lead, Backend |
| **Yasharthdhanai** | Frontend, Voting System |
| **MohitMangain10** | Admin Dashboard |
| **KudoRees** | Database & DAO Layer |

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">
Made with 💚 and the Solarpunk spirit — *technology in harmony with nature and community*
</div>
