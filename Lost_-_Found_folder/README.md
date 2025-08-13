# 📦 Lost & Found App

A streamlined platform to help reconnect students with their lost belongings, built with **Flutter** and **Supabase**.

---

## 🤔 What is this Lost & Found App?

This is a modern, cross-platform application designed to make managing lost and found items easy and efficient.  
Built for organizations like schools or universities, it provides a central place for administrators to post found items and for students to find and claim them.

* 📸 **Item Posting**: Admins can easily post photos and descriptions of found items.  
* 🔍 **Browse & Claim**: Students can browse the list of items, search for what they've lost, and submit a claim.  
* 🔒 **Secure & Centralized**: All data is managed securely in a Supabase backend.  
* 📱 **Cross-Platform**: Works smoothly on mobile and web, thanks to Flutter.

---

## ✨ Why Choose This App?

* 🎨 **Simple Interface** – Clean and intuitive UI for both admins and students.
* 🚀 **Fast & Reliable** – Built with modern technology for speed and responsiveness.
* 🔐 **Secure Roles** – Authentication with distinct roles for Admins and Users.
* 💡 **Beginner Friendly** – Well-organized codebase and straightforward setup.

---

## 🚀 Quick Start (5 Minutes!)

### Step 1: Check if you have Flutter
```bash
flutter --version
```
> Should show a recent version of Flutter.  
> Don't have Flutter? → [Install it here](https://docs.flutter.dev/get-started/install)

### Step 2: Get the App
```bash
# Download the app
git clone <repository-url>
cd lost_and_found_app

# Install all required packages
flutter pub get
```

### Step 3: Set up your Backend
```bash
# This project uses a .env file to store your Supabase keys.
cp .env.example .env
```
Now edit the `.env` file with your credentials (see "Easy Setup" below).

### Step 4: Start the App
```bash
flutter run
```

🎉 You're done! Your Lost & Found system is now running.

---

## 🛠 Easy Setup (Backend)

This project uses **Supabase** for database, authentication, and storage.

### Recommended Setup (Free Cloud)
No local database installation needed! Use the free tier from Supabase.

1. Sign up at [Supabase.io](https://supabase.io/) (free tier available).
2. Create a new project.
3. Go to **Project Settings → API** to find your **Project URL** and **anon** key.
4. Add them to your `.env` file.

**Example `.env` file:**
```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-long-anon-public-key
```

---

## 🎨 What Can You Do?

The app has two primary user experiences:

### As an Admin:
- Log in to the application.
- Access a dashboard to see all items.
- Post new found items (upload photo + description).
- View and manage claims submitted by students.

### As a User (Student):
- Log in to the application.
- See a gallery of all found items.
- Search and filter for a specific item.
- Submit a claim for a lost item.

---

## 📋 Features Overview

| Feature           | Description                                         | Who Can Use It      |
|-------------------|-----------------------------------------------------|---------------------|
| **Item Management** | Post, update, or remove found items.                | Admins              |
| **Claim Review**    | Approve or deny claims from students.               | Admins              |
| **Item Browse**     | Search and view details of found items.              | Users, Admins       |
| **Claim Submission**| Submit claim requests for lost items.               | Users (Students)    |

---

## 👥 User Types

👑 **Admin**  
* Can manage all items and claims.  
* Perfect for staff, faculty, or admins.

📖 **User (Student)**  
* Can browse and submit claims.  
* Perfect for students or organization members.

---

## 🆘 Need Help?

**Q:** I see a Supabase connection error when starting the app!  
**A:** Double-check that your `.env` file exists in the project root and that your keys are correct.

**Q:** How do I create an Admin account?  
**A:** Assign the "admin" role to a user in your Supabase database (e.g., via a `profiles` table).

**Q:** Can I reset everything?  
**A:** Yes, clear the data in your tables from the Supabase dashboard.

---

## 🏗 Technical Details

**Tech Stack**
- **Framework:** Flutter
- **Backend:** Supabase
- **State Management:** Supabase Flutter (for sessions & data)
- **Image Handling:** `image_picker`
- **Unique IDs:** `uuid`
- **Environment Variables:** `flutter_dotenv`
- **Internationalization:** `intl`

---

## 📄 License
This project is open-source under the **MIT License**.

---

## 🙏 Acknowledgments
* Built with ❤️ for communities to help each other.
* Special thanks to Flutter and Supabase creators.
