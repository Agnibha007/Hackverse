# Phi — Project Summary

Phi started as a simple idea: studying is boring because nothing about it feels like progress. You sit down, you read things, you close the laptop, and you have no real sense of what you accomplished. So we built something that changes that framing entirely — a study dashboard that treats your work like a game, tracks everything that matters, and actually shows you getting better over time.

The app is live at https://hackverse-frontend.vercel.app/. The backend lives at https://github.com/Agnibha007/Hackverse_Backend.git and the frontend at https://github.com/Agnibha007/Hackverse_Frontend.git.

---

## What it is

At its core, Phi is a productivity system for students. You create missions (study tasks with priorities, deadlines, and XP rewards), log focus sessions with a built-in Pomodoro timer, organize everything by subject, and watch your stats update in real time. There's an AI mentor called aria.ai that knows your actual data — your streak, your active missions, how many minutes you've studied this week — and gives advice based on that instead of generic tips. There's a social layer where you can add friends, see when they're online or studying, chat, and do shared Pomodoro sessions together. And there's a collectibles system that drops meme cards when you hit milestones, with a full-screen celebration popup when you earn one.

The aesthetic is cyberpunk/synthwave — dark backgrounds, neon pink and blue accents, glitch text effects, scanline overlays. It's deliberately over the top. The idea is that if the interface feels like a game, you're more likely to actually open it.

---

## How it's built

The backend is Node.js with Express, talking to a PostgreSQL database. Authentication is JWT-based with bcryptjs for password hashing. New users who sign up with email get a 6-digit OTP sent to their inbox via Gmail SMTP — Google Sign-In users skip that entirely and go straight to onboarding. Validation runs through Zod, security headers through Helmet, and there's rate limiting on auth endpoints to prevent abuse.

The database has 15 tables: users, missions, focus_sessions, analytics, mission_items, subjects, daily_goals, ai_conversations, collectibles, friend_requests, friendships, presence, messages, study_sessions, and study_session_participants. Migrations run automatically on startup so deploying to a fresh database just works.

The frontend is React 18 with Vite, Zustand for state, TailwindCSS with custom design tokens for the neon color palette, and React Router for navigation. The whole thing is split into lazy-loaded chunks so the initial load is fast. State is organized into domain stores — auth, missions, focus, analytics, subjects, AI, collectibles, social, chat, study sessions — each handling their own API calls and updates.

---

## Features

Missions are the main unit of work. You create one with a title, priority level (low through critical), deadline, and XP reward. Activating a mission opens a workspace where you can add todos, jot down thoughts, and build named checklists — all saved to the database. Completing a mission awards the XP and updates your daily analytics immediately.

Focus sessions can be logged manually or through the built-in timer. You pick a duration, set a quality level (distracted, normal, focused, deep focus), and hit start. When you finish, the session gets saved, your streak updates, and your daily goal progress bar moves.

Subjects let you tag missions and sessions to a study domain. Each subject card shows total minutes studied, missions completed, and a progress bar. aria.ai uses this data when giving advice.

The analytics page shows your full picture: today's productivity score, your XP and level, focus streak, all-time records, and a weekly focus distribution chart.

aria.ai is powered by Groq's Llama 3.3 70B model. Before every message, the backend builds a fresh context snapshot with your current stats and injects it into the system prompt. The last 20 messages of conversation history are included so it can follow the thread.

The Squad page is the social hub. You can search for other users by username, send friend requests, and once accepted, see their presence status (online, offline, or studying with subject name). There's a 1-on-1 chat that persists to the database and polls every 5 seconds for new messages. You can start a shared Pomodoro session — the host picks a subject and duration, friends can see it and join, and everyone sees the same countdown timer with a live participant list. The leaderboard ranks you and your friends by collectibles earned.

The collectibles system drops meme cards at specific milestones: signing up, creating your first mission, logging your first session, sending your first aria.ai message, and every level up. There are 11 collectibles total. When you earn one, a full-screen celebration popup appears with animated confetti particles, the meme image, and a flavor text description. The Drops page shows all 11 slots — earned ones show the meme and date, locked ones show a padlock.

Levels use a compounding XP formula: 100 XP to reach level 2, 200 more for level 3, 400 for level 4, and so on — doubling each time.

---

## Onboarding

New users go through a two-step setup after their first login: pick a call sign (displayed throughout the app) and set a main objective (what they're studying for). Both are saved to the database. After completing onboarding, a feature walkthrough tour runs automatically — seven slides covering every section of the app. It only shows once.

---

## Tech stack

Backend: Node.js, Express, PostgreSQL, JWT, bcryptjs, Zod, Nodemailer, Google Auth Library, Groq SDK, Helmet, express-rate-limit.

Frontend: React 18, Vite, Zustand, TailwindCSS, Axios, React Router v6, Lucide React.

Deployed on Render (backend, Docker container) and Vercel (frontend, static).

---

## What's not in here

There's no mobile app, just a responsive web app with a bottom tab bar on mobile. There's no offline mode. Real-time features (presence, chat) use polling rather than WebSockets — presence polls every 15 seconds, chat every 5 seconds. The AI mentor requires a Groq API key. Email verification requires Gmail SMTP credentials — without them, signup auto-verifies locally.
