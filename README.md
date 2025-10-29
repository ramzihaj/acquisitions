# Acquisitions API

A Node.js Express application with Neon Database, Drizzle ORM, and Arcjet security.

## Features

- **Express.js** - Fast, unopinionated web framework
- **Neon Database** - Serverless Postgres
- **Drizzle ORM** - TypeScript ORM
- **Arcjet** - Security and rate limiting
- **Docker Support** - Development and production environments
- **Authentication** - JWT-based auth system

## Quick Start

### Local Development (Without Docker)

```bash
# Install dependencies
npm install

# Set up environment variables
cp .env.example .env

# Run migrations
npm run db:migrate

# Start development server
npm run dev
```

The application will be available at http://localhost:3000

### Docker Development (With Neon Local)

```bash
# Start development environment with Neon Local
docker-compose -f docker-compose.dev.yml up --build

# Or use the helper script
./docker-start-dev.sh  # Linux/Mac
docker-start-dev.bat   # Windows
```

See [DOCKER_QUICK_START.md](./DOCKER_QUICK_START.md) for quick Docker instructions.

## Environment Variables

Create a `.env` file in the root directory:

```env
# Application
NODE_ENV=development
PORT=3000
LOG_LEVEL=info

# Database
DATABASE_URL=postgresql://user:password@host/database

# Security
ARCJET_KEY=your_arcjet_key
```

## Available Scripts

- `npm start` - Start production server
- `npm run dev` - Start development server with hot reload
- `npm run lint` - Run ESLint
- `npm run lint:fix` - Fix ESLint errors
- `npm run format` - Format code with Prettier
- `npm run format:check` - Check code formatting
- `npm run db:generate` - Generate database migrations
- `npm run db:migrate` - Run database migrations
- `npm run db:studio` - Open Drizzle Studio

## API Endpoints

### Health Check
```
GET /health
```

### Authentication
```
POST /api/auth/register
POST /api/auth/login
POST /api/auth/logout
```

### Users
```
GET /api/users
GET /api/users/:id
PUT /api/users/:id
DELETE /api/users/:id
```

## Docker Setup

This project supports Docker for both development and production environments:

### Development Environment
- Uses **Neon Local** - a local Postgres proxy running in Docker
- Supports hot reload for rapid development
- Ephemeral database branches for testing

### Production Environment
- Connects to **Neon Cloud** - serverless Postgres
- Optimized for production deployment
- Enhanced security settings

### Documentation

- **[DOCKER_QUICK_START.md](./DOCKER_QUICK_START.md)** - Quick reference for Docker commands
- **[DOCKER_README.md](./DOCKER_README.md)** - Complete Docker setup guide

### Quick Docker Commands

**Development:**
```bash
# Start
docker-compose -f docker-compose.dev.yml up --build

# Stop
docker-compose -f docker-compose.dev.yml down

# View logs
docker-compose -f docker-compose.dev.yml logs -f
```

**Production:**
```bash
# Start (requires .env.production)
docker-compose -f docker-compose.prod.yml --env-file .env.production up --build -d

# Stop
docker-compose -f docker-compose.prod.yml down

# View logs
docker-compose -f docker-compose.prod.yml logs -f
```

## Project Structure

```
acquisitions/
├── src/
│   ├── config/          # Configuration files
│   ├── controllers/     # Route controllers
│   ├── middleware/      # Custom middleware
│   ├── models/          # Database models (Drizzle)
│   ├── routes/          # API routes
│   ├── services/        # Business logic
│   ├── utils/           # Utility functions
│   ├── validations/     # Input validation (Zod)
│   ├── app.js           # Express app setup
│   ├── server.js        # Server initialization
│   └── index.js         # Entry point
├── drizzle/             # Database migrations
├── logs/                # Application logs
├── Dockerfile           # Multi-stage Docker build
├── docker-compose.dev.yml   # Development compose
├── docker-compose.prod.yml  # Production compose
├── drizzle.config.js    # Drizzle ORM config
└── package.json         # Dependencies
```

## Database

This project uses **Neon Database** with **Drizzle ORM**.

### Running Migrations

```bash
# Generate migration files
npm run db:generate

# Apply migrations
npm run db:migrate

# Open Drizzle Studio (database GUI)
npm run db:studio
```

### Development vs Production

- **Development**: Uses Neon Local (local Postgres proxy)
- **Production**: Uses Neon Cloud (serverless Postgres)

The database configuration automatically switches based on `NODE_ENV`.

## Security

- **Helmet** - Secure HTTP headers
- **CORS** - Cross-origin resource sharing
- **Arcjet** - Rate limiting and security rules
- **JWT** - JSON Web Tokens for authentication
- **bcrypt** - Password hashing

## Logging

Application uses **Winston** for structured logging:

- Logs are written to `logs/` directory
- Console output in development
- File output in production
- Request logging via Morgan

## Development

### Code Style

This project uses:
- **ESLint** - Code linting
- **Prettier** - Code formatting

```bash
# Check code style
npm run lint
npm run format:check

# Fix issues
npm run lint:fix
npm run format
```

### Hot Reload

Development mode uses Node's `--watch` flag for automatic reloading:

```bash
npm run dev
```

## Production Deployment

### Using Docker (Recommended)

1. Create `.env.production` with production credentials
2. Build and run the container:

```bash
docker-compose -f docker-compose.prod.yml --env-file .env.production up --build -d
```

### Manual Deployment

1. Set environment variables
2. Install dependencies: `npm ci --only=production`
3. Run migrations: `npm run db:migrate`
4. Start server: `npm start`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting
5. Submit a pull request

## License

ISC

## Support

For issues or questions:
- Open an issue on GitHub
- Check documentation in `DOCKER_README.md`
- Review Neon Database docs: https://neon.tech/docs
