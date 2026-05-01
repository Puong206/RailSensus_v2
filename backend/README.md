# RailSensus Backend API

RailSensus is a crowdsourcing platform for train enthusiasts (Railfans) to log and track locomotive operations. This is the backend REST API built with Node.js, Express, and MySQL (via Sequelize ORM).

## Features

- **JWT Authentication**: Secure user registration and login.
- **Role-Based Access Control**: `Admin` and `User` roles.
- **Crowdsourcing (Sensus)**: Log which locomotive pulls which train, along with GPS coordinates.
- **Reverse Geocoding**: Automatically fetches the location name in the background using OpenStreetMap Nominatim API.
- **Voting System**: Vote on the validity of census logs to build up a Trust Score. Transactions ensure data integrity.
- **Master Data Management**: Admins can manage train data and users.

## Prerequisites

- Node.js (v14+ recommended)
- MySQL Server

## Setup and Installation

1. **Clone the repository** (if applicable) or navigate to the project directory:
   ```bash
   cd railsensus-backend
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Configure Environment Variables**:
   Copy `.env.example` to `.env` and configure your database credentials and JWT secret.
   ```bash
   cp .env.example .env
   ```

4. **Database Setup**:
   Create the database in MySQL based on your `.env` configuration (default: `railsensus`). Then run the Sequelize migrations and seeders:
   ```bash
   npx sequelize-cli db:migrate
   npx sequelize-cli db:seed:all
   ```
   *Note: The seeder creates a default admin account:*
   - **Username**: `admin`
   - **Password**: `admin123`

5. **Run the Server**:
   ```bash
   npm run dev
   ```
   The server will start on `http://localhost:3000`. You can check the health status at `http://localhost:3000/api/health`.

## API Endpoints

### Public
- `GET /api/health` - API health check

### Auth
- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - Login and receive JWT

### Protected (Requires Bearer Token)
- **Lokomotif**
  - `GET /api/lokomotif` - Get all locomotives (with pagination/search)
  - `POST /api/lokomotif` - Create a new locomotive
  - `PUT /api/lokomotif/:id` - Update a locomotive
  - `DELETE /api/lokomotif/:id` - Delete a locomotive
- **Sensus**
  - `GET /api/sensus` - Get census feed
  - `POST /api/sensus` - Submit a new census log (triggers OpenStreetMap API)
  - `POST /api/sensus/:id/vote` - Vote `Valid` or `Invalid` on a census log

### Admin Protected (Requires Admin Role)
- **Kereta**
  - `GET /api/admin/kereta` - Get all trains
  - `POST /api/admin/kereta` - Create a train
  - `PUT /api/admin/kereta/:id` - Update a train
  - `DELETE /api/admin/kereta/:id` - Delete a train
- **Users**
  - `GET /api/admin/users` - Get all users
  - `DELETE /api/admin/users/:id` - Delete a user
