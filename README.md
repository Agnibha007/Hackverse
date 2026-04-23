# Phi

A gamified study dashboard built for students who want to actually enjoy tracking their productivity. Think cyberpunk aesthetics meets Pomodoro timer meets RPG progression system — you earn XP for completing study missions, maintain focus streaks, chat with an AI mentor that knows your actual stats, and organize everything by subject.

The actual development history, commits, and code changes live in two separate repositories:

- Backend: https://github.com/Agnibha007/Hackverse_Backend.git
- Frontend: https://github.com/Agnibha007/Hackverse_Frontend.git

The live app is at: https://hackverse-frontend.vercel.app/

---

## What it does

The core idea is simple: studying feels more engaging when it's framed as a game. Instead of a plain to-do list, you have **missions** with priority levels and XP rewards. Instead of a generic timer, you have a **focus mode** that records session quality and feeds into real analytics. Instead of a static dashboard, everything updates live as you work.

**Missions** — Create study tasks with titles, descriptions, priority (low to critical), deadlines, and XP rewards. Activate a mission to open its workspace, where you can add todos, jot down thoughts, and build checklists — all saved to the database. Complete a mission and the XP gets added to your profile automatically.

**Focus Sessions** — Log study sessions with duration and a quality rating (distracted, normal, focused, deep focus). There's also a built-in Pomodoro-style timer on the Focus page. Every session updates your daily analytics, streak count, and total focus minutes in real time.

**Subjects** — Organize missions and sessions by subject (Math, Physics, whatever you're studying). Each subject shows total minutes studied, missions completed, and a progress bar. The AI mentor also uses this data when giving advice.

**ARIA (AI Mentor)** — A GROQ-powered chat assistant that's been given your actual profile data as context: your XP, level, streak, active missions, subjects, and today's productivity score. It gives personalized advice rather than generic study tips. Conversation history is saved to the database so it remembers previous sessions.

**Analytics** — Daily productivity scores, weekly focus distribution charts, all-time records, and monthly trend summaries. Everything is calculated from real session data, not estimates.

**Gamification** — XP system, levels (every 100 XP), focus streaks, and a daily goal progress bar. Small things, but they add up.

---

## Getting started

The app is live. Just open it in your browser and create an account.

You can sign up with an email and password, or use Google Sign-In to skip the verification step entirely. Google accounts are verified automatically and go straight to onboarding.

If you sign up with email, you'll get a verification link in your inbox. Click it and you'll be taken directly into the app. Check your spam folder if it doesn't show up within a minute or two.

---

## First time setup (onboarding)

After your first login, you'll go through a two-step setup:

1. Pick a call sign — this is your username inside the app
2. Set your main objective — what you're primarily studying for

That's it. You'll land on the dashboard and can start using everything immediately.

---

## Using the app

**Dashboard** is your home base. It shows your active missions, XP, level, focus streak, daily goal progress, and a weekly overview. From here you can log a focus session or create a new mission without leaving the page.

**Focus** is the Pomodoro timer. Pick a duration, set your focus quality level, hit start. When you're done (or want to stop early), the session gets saved and your stats update. The timer also has a manual session logger if you want to record something you already did.

**Subjects** lets you create color-coded study domains. Once you have subjects set up, you can tag missions and focus sessions to them. Each subject card shows how much time you've put in and how many missions you've completed for it.

**Stats** shows your full analytics breakdown — today's productivity score, your agent profile (level, XP, streak, total focus time), all-time records, weekly focus distribution, and a monthly trend summary.

**ARIA** is the AI mentor. It already knows your stats when you open it — just start talking. Ask it to build a study plan, explain a concept, suggest what to work on today, or anything else study-related. Your conversation history is saved between sessions.

---

## Your profile

Click your username in the top navigation bar to open the profile menu. From there you can:

- Edit your username
- Sign out
- Delete your account (requires typing your username to confirm — this is permanent)

---

## How XP and levels work

You earn XP by completing missions. Each mission has an XP reward you set when creating it (between 10 and 500). Activating a mission also gives you a small bonus.

Every 100 XP moves you up a level. Your level is shown next to your username in the nav bar and on the analytics page.

---

## How the productivity score works

Your daily score (0 to 100) is calculated from three things: missions completed that day, total focus minutes logged, and number of sessions. It updates automatically every time you complete a mission or log a session. It resets at midnight.

---

## How the AI mentor works

ARIA uses Groq's Llama 3.3 70B model. Before every message, the backend builds a fresh context snapshot with your current stats — XP, level, streak, active missions, subjects studied, and today's score. It also includes the last 20 messages from your conversation so it can follow the thread.

The system prompt tells it to give specific, data-driven advice rather than generic tips. If your streak is 0, it'll push you to start. If you've been studying Physics for 300 minutes this week, it'll factor that in. It's not a generic chatbot — it actually knows what you've been doing.

---

## Tech stack

**Backend** — Node.js, Express, PostgreSQL, JWT auth, Zod validation, bcryptjs, Nodemailer, Google Auth Library, Groq SDK, Helmet, rate limiting

**Frontend** — React 18, Vite, Zustand, TailwindCSS, Axios, React Router v6, Lucide React

---

## License

MIT. Do whatever you want with it.
