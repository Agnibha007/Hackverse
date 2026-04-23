# Phi - Deployment Guide

## Production Deployment Checklist

### Pre-Deployment

- [ ] All tests passing
- [ ] Code review completed
- [ ] Security audit performed
- [ ] Performance benchmarks met
- [ ] Documentation updated
- [ ] Environment variables configured
- [ ] Database migrations tested
- [ ] SSL certificates ready
- [ ] Backup strategy in place
- [ ] Monitoring configured

## Deployment Methods

### Method 1: Docker Compose (VPS/Self-Hosted)

**Prerequisites:**

- Docker & Docker Compose installed
- Domain name configured
- SSL certificate (Let's Encrypt)

**Steps:**

1. Clone repository on server:

```bash
git clone <repository-url>
cd Hackverse
```

2. Configure environment:

```bash
# Backend
cp backend/.env.example backend/.env
nano backend/.env
# Update DATABASE_URL, JWT_SECRET, CORS_ORIGIN

# Frontend
cp frontend/.env.example frontend/.env.local
nano frontend/.env.local
# Update VITE_API_URL
```

3. Build and start containers:

```bash
docker-compose up -d
```

4. Initialize database:

```bash
docker-compose exec backend npm run migrate
```

5. Verify deployment:

```bash
curl http://localhost/health
curl http://localhost:5000/health
```

### Method 2: Railway.app

Railway offers simple one-click deployment.

1. Connect GitHub repository
2. Create PostgreSQL plugin
3. Set environment variables:
   - DATABASE_URL (auto-generated)
   - JWT_SECRET
   - NODE_ENV=production
   - CORS_ORIGIN=https://your-domain.com

4. Deploy

### Method 3: Vercel (Frontend) + Render (Backend)

**Frontend (Vercel):**

1. Push to GitHub
2. Import project in Vercel
3. Set environment variables
4. Deploy

**Backend (Render):**

1. Create PostgreSQL database
2. Create Web Service
3. Connect GitHub repo
4. Set environment variables
5. Deploy

### Method 4: AWS Deployment

**Architecture:**

- RDS PostgreSQL
- ECS for containers
- Application Load Balancer
- CloudFront CDN
- S3 for static assets

**Steps:**

1. Create RDS PostgreSQL:

```bash
aws rds create-db-instance \
  --db-instance-identifier phi-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --allocated-storage 20 \
  --master-username admin
```

2. Build and push Docker images:

```bash
# Backend
docker build -t phi-backend:latest ./backend
aws ecr get-login-password | docker login --username AWS --password-stdin <ECR_URI>
docker tag phi-backend:latest <ECR_URI>/phi-backend:latest
docker push <ECR_URI>/phi-backend:latest

# Frontend
docker build -t phi-frontend:latest ./frontend
docker tag phi-frontend:latest <ECR_URI>/phi-frontend:latest
docker push <ECR_URI>/phi-frontend:latest
```

3. Create ECS task definitions and services
4. Configure ALB and Target Groups
5. Set up CloudFront distribution
6. Configure Route53 DNS

## Environment Variables

### Backend Production

```env
NODE_ENV=production
PORT=5000
DATABASE_URL=postgresql://user:pass@db-host:5432/phi
JWT_SECRET=<strong-random-string-32-chars-min>
JWT_EXPIRY=7d
CORS_ORIGIN=https://yourdomain.com
LOG_LEVEL=info
```

### Frontend Production

```env
VITE_API_URL=https://api.yourdomain.com/api
```

## SSL/TLS Setup

### Using Let's Encrypt with Nginx

```bash
# Install Certbot
sudo apt-get install certbot python3-certbot-nginx

# Get certificate
sudo certbot certonly --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer
```

### Update Nginx Config

```nginx
server {
    listen 443 ssl http2;
    server_name yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    # SSL best practices
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # ... rest of config
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}
```

## Database Backup & Recovery

### Backup Strategy

```bash
# Daily backup script
#!/bin/bash
BACKUP_DIR="/backups/phi"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# PostgreSQL backup
pg_dump phi > $BACKUP_DIR/phi_$DATE.sql

# Compress
gzip $BACKUP_DIR/phi_$DATE.sql

# Upload to cloud storage
aws s3 cp $BACKUP_DIR/phi_$DATE.sql.gz s3://backups/phi/

# Keep only last 30 days
find $BACKUP_DIR -name "*.sql.gz" -mtime +30 -delete
```

### Restore from Backup

```bash
# Restore PostgreSQL
psql phi < backup_file.sql

# Or from compressed backup
gunzip < backup_file.sql.gz | psql phi
```

## Monitoring & Logging

### Application Logging

```bash
# View backend logs
docker-compose logs -f backend

# View frontend logs
docker-compose logs -f frontend

# View database logs
docker-compose logs -f postgres
```

### Health Checks

```bash
# Backend health
curl https://api.yourdomain.com/health

# Frontend health
curl https://yourdomain.com/health
```

### Key Metrics to Monitor

- Response times (p50, p95, p99)
- Error rates (4xx, 5xx)
- Database query time
- Connection pool usage
- CPU and memory usage
- Disk space
- Network I/O

## Performance Optimization

### Frontend

```bash
# Analyze bundle size
npm run build --analyze

# Compress assets
gzip -r dist/

# Cache strategies in nginx.conf
location ~* \.(js|css)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### Backend

```javascript
// Connection pooling
const pool = new Pool({
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Query caching (future optimization)
// Implement Redis caching for frequently accessed data
```

### Database

```sql
-- Analyze query performance
EXPLAIN ANALYZE SELECT * FROM missions WHERE user_id = 1 AND status = 'active';

-- Create indexes for common queries
CREATE INDEX idx_missions_user_status ON missions(user_id, status);
CREATE INDEX idx_focus_sessions_user_date ON focus_sessions(user_id, session_date);

-- Vacuum and analyze
VACUUM ANALYZE;
```

## Security Hardening

### Backend Security

```javascript
// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: "Too many requests",
});

app.use(limiter);

// Helmet security headers
app.use(helmet());

// CORS configuration
app.use(
  cors({
    origin: process.env.CORS_ORIGIN,
    credentials: true,
  }),
);
```

### Database Security

```sql
-- Create application user (non-superuser)
CREATE ROLE app_user WITH LOGIN PASSWORD 'secure_password';

-- Grant specific permissions
GRANT CONNECT ON DATABASE phi TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;

-- No superuser privileges
ALTER ROLE app_user NOINHERIT;
```

### Infrastructure Security

- Enable firewall
- Restrict inbound ports (only 80, 443)
- Use VPN for database access
- Enable HTTPS everywhere
- Regular security updates
- Implement DDoS protection
- Configure WAF rules

## Rollback Procedure

```bash
# Keep previous version tagged
git tag v1.0.0
git tag v1.0.1

# If rollback needed
docker-compose down
git checkout v1.0.0
docker-compose up -d

# Database rollback (if schema changed)
# Restore from backup or run migration rollback script
```

## Scaling Strategy

### Horizontal Scaling

```bash
# Scale backend services
docker-compose scale backend=3

# Configure load balancer to distribute traffic
```

### Database Scaling

```sql
-- Create read replica
-- In production PostgreSQL, set up streaming replication

-- Connection pooling with PgBouncer
# pgbouncer.ini
[databases]
phi = host=db_host port=5432 dbname=phi

[pgbouncer]
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 25
```

### Caching Layer (Future)

```javascript
// Add Redis caching
const redis = require("redis");
const client = redis.createClient({
  host: "localhost",
  port: 6379,
});

// Cache user stats
app.get("/api/analytics/dashboard", async (req, res) => {
  const cacheKey = `dashboard:${req.user.id}`;

  const cached = await client.get(cacheKey);
  if (cached) return res.json(JSON.parse(cached));

  const stats = await fetchStats(req.user.id);
  await client.setex(cacheKey, 300, JSON.stringify(stats)); // 5 min TTL
  res.json(stats);
});
```

## Disaster Recovery

### RTO/RPO Targets

- **RTO** (Recovery Time Objective): < 1 hour
- **RPO** (Recovery Point Objective): < 15 minutes

### Recovery Procedures

1. **Database Failure:**
   - Restore from latest backup
   - Run migrations
   - Verify data integrity

2. **Application Server Failure:**
   - Deploy new instance
   - Verify database connectivity
   - Health checks pass

3. **Complete System Failure:**
   - Provision new infrastructure
   - Restore database from backup
   - Deploy latest code
   - Run migrations
   - Verify all services

## Post-Deployment

- [ ] Verify all endpoints functioning
- [ ] Test authentication flow
- [ ] Check analytics calculations
- [ ] Review error logs
- [ ] Monitor performance metrics
- [ ] Confirm backups running
- [ ] Update documentation
- [ ] Notify users
- [ ] Schedule post-deployment review

## Troubleshooting

### Common Issues

**Issue: Database connection timeout**

```bash
# Check connection settings
psql -h localhost -U neon_user -d phi -c "SELECT 1;"

# Verify credentials in .env
# Check firewall rules
```

**Issue: 502 Bad Gateway**

```bash
# Check backend service
docker-compose logs backend

# Verify backend is running
curl http://localhost:5000/health
```

**Issue: Frontend not loading**

```bash
# Check nginx logs
docker-compose logs frontend

# Verify frontend build
docker-compose exec frontend ls -la /usr/share/nginx/html/
```

## Maintenance Schedule

- **Daily**: Monitor logs and metrics
- **Weekly**: Review performance metrics, backup verification
- **Monthly**: Security patches, dependency updates
- **Quarterly**: Performance optimization, capacity planning
- **Annually**: Disaster recovery testing, security audit

---

For support, contact the development team or create an issue on GitHub.
