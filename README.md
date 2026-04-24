# Phi

A gamified study dashboard built for students who want to actually enjoy tracking their productivity. Think cyberpunk aesthetics meets Pomodoro timer meets RPG progression system — you earn XP for completing study missions, maintain focus streaks, chat with an AI mentor that knows your actual stats, organize everything by subject, and study together with friends in real time.

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

**aria.ai** — A GROQ-powered chat assistant that's been given your actual profile data as context: your XP, level, streak, active missions, subjects, and today's productivity score. It gives personalized advice rather than generic study tips. Conversation history is saved to the database so it remembers previous sessions.

**Analytics** — Daily productivity scores, weekly focus distribution charts, all-time records, and monthly trend summaries. Everything is calculated from real session data, not estimates.

**Squad** — Add friends, see when they're online or studying, chat one-on-one, start shared Pomodoro sessions, and compete on a collectibles leaderboard. Presence updates every 15 seconds. Chat persists between sessions.

**Collectibles** — Meme cards you earn by hitting milestones: signing up, creating your first mission, logging your first session, chatting with aria.ai for the first time, and every level up. There are 11 total. When you earn one, a full-screen celebration popup appears with confetti. They live in the Drops section.

**Gamification** — XP system, compounding levels (100 XP for level 2, 200 for level 3, 400 for level 4, doubling each time), focus streaks, and a daily goal progress bar.

---

## Getting started

The app is live. Just open it in your browser and create an account.

You can sign up with an email and password, or use Google Sign-In to skip the verification step entirely. Google accounts are verified automatically and go straight to onboarding.

If you sign up with email, you'll get a 6-digit verification code in your inbox. Enter it on the verification screen and you're in. Check your spam folder if it doesn't show up within a minute or two.

---

## First time setup

After your first login, you'll go through a two-step setup:

1. Pick a call sign — this is how you'll be addressed inside the app
2. Set your main objective — what you're primarily studying for

Both are saved and shown on your dashboard. After that, a quick walkthrough tour runs automatically covering every section of the app. It only shows once.

---

## Using the app

**Dashboard** is your home base. It shows your active missions, XP, level, focus streak, daily goal progress, and a weekly overview. From here you can log a focus session or create a new mission without leaving the page.

**Focus** is the Pomodoro timer. Pick a duration, set your focus quality level, hit start. When you're done (or want to stop early), the session gets saved and your stats update.

**Subjects** lets you create color-coded study domains. Tag missions and focus sessions to them. Each subject card shows how much time you've put in and how many missions you've completed.

**Stats** shows your full analytics breakdown — today's productivity score, your agent profile (level, XP, streak, total focus time), all-time records, weekly focus distribution, and a monthly trend summary.

**Squad** is the social hub. Search for other users by username, send friend requests, accept or reject incoming ones. Once you're friends, you can see their online/studying status in real time, open a chat window, start a shared study session together, or check where you rank on the collectibles leaderboard.

**aria.ai** is the AI mentor. It already knows your stats when you open it — just start talking. Ask it to build a study plan, explain a concept, suggest what to work on today, or anything else study-related.

**Drops** is the collectibles section. It shows all 11 meme cards — earned ones show the image and the date you got them, locked ones show a padlock until you hit the milestone.

---

## Your profile

Click your username in the top navigation bar to open the profile menu. From there you can edit your username, sign out, or delete your account (requires typing your username to confirm — this is permanent).

---

## How XP and levels work

You earn XP by completing missions. Each mission has an XP reward you set when creating it. Activating a mission also gives a small bonus.

Levels use a compounding formula — 100 XP to reach level 2, 200 more for level 3, 400 for level 4, and so on. Each level requires double the XP of the previous one. Early levels are quick, later ones take real work.

---

## How the productivity score works

Your daily score (0 to 100) is calculated from three things: missions completed that day, total focus minutes logged, and number of sessions. It updates automatically every time you complete a mission or log a session. It resets at midnight.

---

## How aria.ai works

aria.ai uses Groq's Llama 3.3 70B model. Before every message, the backend builds a fresh context snapshot with your current stats — XP, level, streak, active missions, subjects studied, and today's score. It also includes the last 20 messages from your conversation so it can follow the thread.

The system prompt tells it to give specific, data-driven advice rather than generic tips. If your streak is 0, it'll push you to start. If you've been studying Physics for 300 minutes this week, it'll factor that in.

---

## How Squad works

Presence is updated every time you open the Squad page and polled every 15 seconds. When you start a study session, your status automatically changes to "studying" with the subject name visible to your friends. Ending the session sets you back to online.

Chat messages are stored in the database and loaded when you open a conversation. The chat window polls for new messages every 5 seconds. You can only message people you're friends with.

Study sessions are shared Pomodoro timers. The host creates one with a subject and duration, friends can see it in the "Join Friend" tab and jump in. The timer starts when the first person joins. The host can end it early; everyone else can leave without ending it for others.

The leaderboard ranks you and your friends by collectibles earned, with XP as a tiebreaker. Gold, silver, and bronze for the top three.

---

## Tech stack

**Backend** — Node.js, Express, PostgreSQL, JWT auth, Zod validation, bcryptjs, Nodemailer, Google Auth Library, Groq SDK, Helmet, rate limiting

**Frontend** — React 18, Vite, Zustand, TailwindCSS, Axios, React Router v6, Lucide React

---

## License

MIT. Do whatever you want with it.
