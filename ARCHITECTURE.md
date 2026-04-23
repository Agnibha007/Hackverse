# Phi - Architecture & Deployment Guide

## System Architecture

### High-Level Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        Client Browser                            │
│                  (React + TailwindCSS UI)                        │
└─────────────────────────────────┬───────────────────────────────┘
                                  │
                                  │ HTTPS
                                  │
┌─────────────────────────────────▼───────────────────────────────┐
│                    Frontend (Nginx)                              │
│              Port 80/443 - Static & Routes                       │
└─────────────────────────────────┬───────────────────────────────┘
                                  │
                                  │ REST API
                                  │
┌─────────────────────────────────▼───────────────────────────────┐
│                    Backend API (Express)                         │
│              Port 5000 - Business Logic                          │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │ Controllers  │  │  Services    │  │  Middlewares │           │
│  │  (HTTP)      │  │  (Logic)     │  │  (Auth/Val)  │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
└─────────────────────────────────┬───────────────────────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
┌───────────────────▼──────────────┐  ┌────────▼─────────────────┐
│     PostgreSQL Database           │  │   External Services     │
│  (Users, Missions, Sessions,      │  │  (Email, Auth, etc.)    │
│   Analytics)                      │  │                         │
└───────────────────────────────────┘  └─────────────────────────┘
```

### Component Interaction

```
┌─────────────────────────────────────────────────────────────┐
│                      Frontend (React)                        │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Pages (Login, Dashboard, Focus, Analytics)                  │
│         │                                                    │
│         ▼                                                    │
│  Components (NeonButton, Cards, Forms)                       │
│         │                                                    │
│         ▼                                                    │
│  Zustand Stores (Auth, Mission, Focus, Analytics)            │
│         │                                                    │
│         ▼                                                    │
│  Axios API Client (with interceptors)                        │
│         │                                                    │
└─────────┼──────────────────────────────────────────────────┘
          │
          │ HTTP/CORS
          │
┌─────────▼──────────────────────────────────────────────────┐
│                   Backend (Express.js)                       │
├────────────────────────────────────────────────────────────┤
│                                                              │
│  Routes (auth, missions, focus, analytics)                  │
│     │                                                       │
│     ▼                                                       │
│  Controllers (Handle requests)                              │
│     │                                                       │
│     ▼                                                       │
│  Services (Business logic & orchestration)                  │
│     │                                                       │
│     ▼                                                       │
│  Models (Database queries)                                  │
│     │                                                       │
└─────┼───────────────────────────────────────────────────────┘
      │
      │ SQL
      │
┌─────▼───────────────────────────────────────────────────────┐
│            PostgreSQL Database                               │
├────────────────────────────────────────────────────────────┤
│                                                              │
│  Tables:                                                    │
│  - users (with indexes on email, id)                        │
│  - missions (with indexes on user_id, status)               │
│  - focus_sessions (with indexes on user_id, date)           │
│  - analytics (with indexes on user_id, date)                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow Examples

### User Login Flow

```
1. User enters credentials in LoginPage
2. LoginPage calls useAuthStore.login()
3. Zustand calls api.post('/auth/login', credentials)
4. Axios attaches headers and sends to Backend
5. Backend AuthController receives request
6. AuthController calls AuthService.loginUser()
7. AuthService queries User model
8. User model executes SQL: SELECT * FROM users WHERE email = $1
9. Database returns user record
10. AuthService verifies password with bcryptjs
11. AuthService generates JWT token
12. Backend returns { user, token }
13. Zustand store updates with token and user
14. Axios interceptor adds token to localStorage
15. App redirects to /dashboard
16. Navigation component renders with user info
```

### Mission Creation Flow

```
1. User fills form in DashboardPage
2. MissionCard calls useStore.updateMission() with status change
3. Zustand calls api.patch('/missions/:id', updates)
4. Backend MissionController receives PATCH request
5. Auth middleware verifies JWT token
6. MissionController calls MissionService.updateMissionDetails()
7. MissionService calls Mission model
8. Model executes: UPDATE missions SET status = $1 WHERE id = $2
9. If status = 'completed', MissionService calls AuthService.awardXP()
10. XP is awarded and level is calculated
11. Analytics are updated with analytics service
12. Response returned to frontend
13. Zustand updates local missions array
14. UI re-renders showing updated mission
15. User stats automatically update
```

### Focus Session Tracking Flow

```
1. User starts session in FocusModePage
2. Timer counts down, updates component state
3. User ends session, calls recordSession()
4. Zustand posts session data to /api/focus/session
5. Backend FocusController receives POST
6. Auth middleware validates token
7. FocusController calls FocusService.startFocusSession()
8. FocusService creates session record in database
9. FocusService updates user's total_focus_minutes
10. FocusService calls updateDailyAnalyticsFromSessions()
11. Analytics are computed and updated
12. Response returned to frontend
13. Zustand updates focusHistory
14. DashboardPage fetches fresh metrics
15. UI updates showing new stats
```

## Database Schema Relationships

```
┌──────────────┐
│    users     │
├──────────────┤
│ id (PK)      │
│ email (UQ)   │
│ username     │
│ xp_points    │
│ level        │
│ focus_streak │
│ created_at   │
└──────┬───────┘
       │ 1:N
       │
       ├──────────────────┬─────────────────┬──────────────────┐
       │                  │                 │                  │
       ▼                  ▼                 ▼                  ▼
  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐
  │  missions   │  │focus_sessions│  │  analytics   │  │ (future)     │
  ├─────────────┤  ├─────────────┤  ├──────────────┤  │ notifications│
  │ id (PK)     │  │ id (PK)     │  │ id (PK)      │  │ user_id (FK) │
  │ user_id (FK)│  │ user_id (FK)│  │ user_id (FK) │  │ type         │
  │ title       │  │ mission_id  │  │ date         │  │ read         │
  │ priority    │  │ (FK)        │  │ metrics      │  │ created_at   │
  │ status      │  │ duration    │  │ (score, etc) │  └──────────────┘
  │ deadline    │  │ focus_qual  │  └──────────────┘
  │ xp_reward   │  │ created_at  │
  │ created_at  │  └─────────────┘
  └─────────────┘
```

## Security Architecture

```
┌──────────────────────────────────────────────────────┐
│              Security Layers                          │
├──────────────────────────────────────────────────────┤
│                                                       │
│  Browser:                                            │
│  ├─ HTTPS/TLS (in production)                       │
│  ├─ SameSite cookies                                │
│  └─ CSP headers                                      │
│                                                       │
│  Network:                                            │
│  ├─ CORS (controlled origins)                       │
│  ├─ Rate limiting                                   │
│  └─ DDoS protection (in production)                 │
│                                                       │
│  API:                                                │
│  ├─ JWT authentication                              │
│  ├─ Input validation (Zod)                          │
│  ├─ Helmet security headers                         │
│  └─ Authorization checks                            │
│                                                       │
│  Database:                                           │
│  ├─ Parameterized queries (SQL injection prevent)   │
│  ├─ Password hashing (bcryptjs)                     │
│  ├─ Row-level security (future)                     │
│  └─ Encryption at rest (optional)                   │
│                                                       │
└──────────────────────────────────────────────────────┘
```

## Deployment Architectures

### Development (Local)

```
User Machine:
├─ Frontend (Vite dev server) :5173
├─ Backend (Node dev server) :5000
└─ PostgreSQL (local) :5432
```

### Production (Docker Compose)

```
Docker Host:
├─ Frontend Container
│  └─ Nginx :80/:443
├─ Backend Container
│  └─ Node.js :5000
└─ PostgreSQL Container
   └─ PostgreSQL :5432
```

### Production (Cloud - Example with AWS/GCP/Azure)

```
┌─────────────────────────────────────────────┐
│         CDN / DDoS Protection               │
│              (CloudFlare)                   │
└────────────────┬────────────────────────────┘
                 │
┌────────────────▼────────────────────────────┐
│      Load Balancer                          │
│    (Application Load Balancer)              │
└────────────────┬────────────────────────────┘
                 │
      ┌──────────┴──────────┐
      │                     │
┌─────▼────────┐  ┌─────────▼────────┐
│ Frontend (x3) │  │ Backend (x3)     │
│  Container    │  │  Container       │
│  (Nginx)      │  │  (Node.js)       │
└──────────────┘  └────────┬─────────┘
                           │
                  ┌────────▼──────────┐
                  │ PostgreSQL RDS    │
                  │ (Managed)         │
                  │ (Multi-AZ)        │
                  └───────────────────┘
```

### Scaling Considerations

- **Frontend**: Static assets in CDN, multiple replicas behind LB
- **Backend**: Horizontal scaling with load balancer, stateless design
- **Database**: Read replicas, connection pooling, caching layer (Redis)
- **Storage**: S3 for user uploads, CDN for static content

## Monitoring & Observability

```
┌────────────────────────────────────────┐
│    Application Monitoring              │
├────────────────────────────────────────┤
│                                        │
│  Metrics:                              │
│  ├─ Request count & latency           │
│  ├─ Database query performance        │
│  └─ Error rates                       │
│                                        │
│  Logging:                              │
│  ├─ API request logs                  │
│  ├─ Database slow query logs          │
│  └─ Application errors                │
│                                        │
│  Tracing:                              │
│  ├─ Request flow through services     │
│  └─ Dependency tracking               │
│                                        │
│  Tools (Production):                   │
│  ├─ Prometheus (metrics)              │
│  ├─ ELK Stack (logging)               │
│  ├─ Jaeger (tracing)                  │
│  └─ Grafana (dashboards)              │
│                                        │
└────────────────────────────────────────┘
```

## Performance Optimization

### Frontend

- Code splitting with Vite
- Lazy loading routes
- Image optimization
- CSS minification
- Bundle analysis

### Backend

- Database connection pooling
- Query optimization with indexes
- Caching strategies
- Compression (gzip)
- Rate limiting

### Database

- Indexes on frequently queried columns
- Query optimization
- Connection pooling (pg-pool)
- Archive old data

## Environment Management

```
Development:
├─ .env.local
├─ localhost URLs
└─ Debug logging

Staging:
├─ .env.staging
├─ staging domain
└─ Reduced logging

Production:
├─ .env.production (secrets manager)
├─ production domain
├─ Minimal logging
└─ All optimizations enabled
```

---

For API details, see `API_DOCS.md`
For Frontend details, see `FRONTEND_DOCS.md`
