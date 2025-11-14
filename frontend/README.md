# AutoClean Frontend

A React-based frontend application for the AutoClean file cleanup tool.

## Features

- Identify and remove temporary files
- Detect duplicate files
- Free up disk space
- Modern, responsive UI with Tailwind CSS

## Tech Stack

- React 19.2.0
- TypeScript 5.6.3
- Vite 5.4.11
- React Router 7.9.3
- TanStack Query 5.90.2
- Tailwind CSS 3.4.14
- Axios 1.12.2
- Zustand 5.0.8

## Getting Started

### Prerequisites

- Node.js 18+ and npm

### Installation

1. Install dependencies:
```bash
npm install
```

2. Create environment file:
```bash
cp .env.example .env
```

3. Update `.env` with your API configuration:
```
VITE_API_URL=http://localhost:3000
VITE_API_VERSION=v1
VITE_API_TIMEOUT=30000
```

### Development

Start the development server:
```bash
npm run dev
```

The application will be available at `http://localhost:5173`

### Build

Create a production build:
```bash
npm run build
```

### Preview

Preview the production build:
```bash
npm run preview
```

## Project Structure

```
src/
├── app/                 # Application configuration
│   ├── App.tsx         # Root component
│   └── router.tsx      # Routing configuration
├── assets/             # Static assets
│   └── styles/         # Global styles
├── core/               # Core utilities and components
│   ├── components/     # Shared components
│   ├── lib/           # Library configurations
│   ├── types/         # Global types
│   └── utils/         # Utility functions
├── domain/            # Business domains
├── pages/             # Page components
│   ├── layouts/       # Layout components
│   ├── Home/          # Home page
│   └── NotFound/      # 404 page
└── main.tsx           # Application entry point
```

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint

## API Integration

The application uses Axios for API communication with two separate clients:

- `publicClient` - For public endpoints (no authentication)
- `authenticatedClient` - For protected endpoints (requires token)

API configuration is managed in `src/core/lib/api.ts`

## State Management

- **Server State**: TanStack Query for data fetching and caching
- **Client State**: Zustand for global state management
- **Local State**: React hooks for component-level state

## Styling

The project uses Tailwind CSS for styling. Global styles are defined in `src/assets/styles/globals.css`

## License

MIT