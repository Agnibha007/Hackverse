#!/bin/bash

# Neon Drive - Setup Script
# This script helps with initial setup and database configuration

echo "🚀 Neon Drive - Initialization Script"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Node.js
echo "📋 Checking Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v)
    echo -e "${GREEN}✓ Node.js ${NODE_VERSION} found${NC}"
else
    echo -e "${RED}✗ Node.js not found. Please install Node.js 18+${NC}"
    exit 1
fi

# Check PostgreSQL
echo ""
echo "📋 Checking PostgreSQL..."
if command -v psql &> /dev/null; then
    PG_VERSION=$(psql --version)
    echo -e "${GREEN}✓ ${PG_VERSION}${NC}"
else
    echo -e "${YELLOW}⚠ PostgreSQL not found. Make sure PostgreSQL is installed and running${NC}"
fi

# Backend setup
echo ""
echo "📦 Setting up Backend..."
cd backend
if [ -f ".env" ]; then
    echo -e "${YELLOW}⚠ .env already exists${NC}"
else
    cp .env.example .env
    echo -e "${GREEN}✓ Created .env file${NC}"
fi

npm install
echo -e "${GREEN}✓ Backend dependencies installed${NC}"

# Frontend setup
echo ""
echo "📦 Setting up Frontend..."
cd ../frontend
if [ -f ".env.local" ]; then
    echo -e "${YELLOW}⚠ .env.local already exists${NC}"
else
    cp .env.example .env.local
    echo -e "${GREEN}✓ Created .env.local file${NC}"
fi

npm install
echo -e "${GREEN}✓ Frontend dependencies installed${NC}"

echo ""
echo "======================================"
echo -e "${GREEN}✓ Setup Complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Update database URL in backend/.env"
echo "2. Run migrations: cd backend && npm run migrate"
echo "3. Start backend: npm run dev"
echo "4. Start frontend (in new terminal): cd frontend && npm run dev"
echo ""
echo "Frontend: http://localhost:5173"
echo "Backend: http://localhost:5000"
echo ""
