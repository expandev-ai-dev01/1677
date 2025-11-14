# AutoClean Backend API

Backend API for AutoClean - File management system for identifying and removing temporary files.

## Features

- RESTful API architecture
- TypeScript for type safety
- Express.js framework
- SQL Server database integration
- Multi-tenancy support
- Comprehensive error handling
- Request validation with Zod

## Prerequisites

- Node.js 18+ 
- SQL Server 2019+
- npm or yarn

## Installation

```bash
npm install
```

## Configuration

Copy `.env.example` to `.env` and configure your environment variables:

```bash
cp .env.example .env
```

## Development

```bash
npm run dev
```

## Build

```bash
npm run build
```

## Production

```bash
npm start
```

## Testing

```bash
npm test
```

## API Documentation

API is available at:
- Development: `http://localhost:3000/api/v1`
- Health check: `http://localhost:3000/health`

## Project Structure

```
src/
├── api/              # API controllers
├── routes/           # Route definitions
├── middleware/       # Express middleware
├── services/         # Business logic
├── utils/            # Utility functions
├── constants/        # Application constants
├── instances/        # Service instances
├── config/           # Configuration
└── server.ts         # Application entry point
```

## License

ISC