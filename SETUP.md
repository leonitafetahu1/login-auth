# Setup Guide

This guide will help you run the ZITADEL login UI and console locally using Docker Compose.

## Prerequisites

- **Docker Desktop** installed and running
  - Download from: https://www.docker.com/products/docker-desktop
  - Make sure Docker is running before proceeding

## Quick Start

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd login-auth
```

### 2. Set Up Environment Variables (First Run)

**For the first run, you don't need to create a token manually!** ZITADEL will generate it automatically.

Simply start Docker Compose:

```bash
docker compose up
```

Wait for ZITADEL to finish initializing (you'll see "ZITADEL is ready" in the logs - this takes 1-2 minutes).

**Then get the auto-generated token:**

**Option 1: Using Command Line (Recommended)**
1. Open a **new terminal window** (keep Docker Compose running in the first one)
2. Navigate to the project: `cd login-auth`
3. Copy the token to `.env`:
   ```bash
   echo "ZITADEL_SERVICE_USER_TOKEN=$(cat machinekey/login-client.token)" > .env
   ```
4. Verify it worked: `cat .env` (should show the token)

**Option 2: Manual Method**
1. Open the file `machinekey/login-client.token` in a text editor
2. Copy the entire token (it's one long string, no spaces)
3. Create a file named `.env` in the root directory (`login-auth/.env`)
4. Add this line (replace with your actual token):
   ```
   ZITADEL_SERVICE_USER_TOKEN=your-copied-token-here
   ```

> **Note:** If `machinekey/login-client.token` is missing, create a new PAT for the login client through the ZITADEL console (see the section below) or temporarily use `machinekey/zitadel-admin-sa.token`.

**After creating .env, restart the login service:**
```bash
docker compose restart login
```

### 3. Configure public URLs (optional)

If you need to change the public links shown in the login UI (e.g., replace the demo pages with your own), edit `docker-compose.yml` and set:

```yaml
    environment:
      NEXT_PUBLIC_FOS_URL: https://your-first-link.example
      NEXT_PUBLIC_APP2_URL: https://your-second-link.example
```

After changing these values, rebuild the login image so the environment variables are baked into the Next.js build:

```bash
docker compose build login
docker compose up
```

### 4. Start Everything (Subsequent Runs)

If you already have a `.env` file with a token, simply run:

```bash
docker compose up
```

Run this single command:

```bash
docker compose up
```

This will:
- Start PostgreSQL database
- Start ZITADEL instance
- Build and start the login UI

**First time setup:** The first run may take 2-3 minutes as it builds the Docker images and initializes the database.

### 5. Access the Services

Once everything is running, you can access:

- **Login UI (Custom Design):** http://localhost:3000
- **ZITADEL Console:** http://localhost:8080/ui/console
- **Default Admin Login:**
  - Username: `admin@myorg.localhost` (or just `admin` if the UI shows the suffix)
  - Password: `Password1!`

## Stopping the Services

Press `Ctrl+C` in the terminal, or run:

```bash
docker compose down
```

To also remove volumes (fresh start):

```bash
docker compose down -v
```

## Creating a Service User Token Manually

If you need to create a new service user token (or the auto-generated one doesn't work):

### Step 1: Access ZITADEL Console

1. Make sure ZITADEL is running: `docker compose up`
2. Open http://localhost:8080/ui/console
3. Login with:
   - Username: `admin@myorg.localhost` (or just `admin`)
   - Password: `Password1!`

### Step 2: Create Service User

1. In the left sidebar, go to **Organization** → **Members** → **Service Users**
2. Click **New Service User**
3. Enter a name (e.g., "Login UI Service")
4. Click **Create**

### Step 3: Grant IAM Permissions

1. Still on the service user page, go to **Memberships** tab
2. Click **Add Membership**
3. Select **IAM** from the dropdown
4. Select the service user you just created
5. Choose role: **IAM_OWNER** (or at least **IAM_LOGIN_CLIENT**)
6. Click **Add**

### Step 4: Generate Personal Access Token

1. On the service user page, go to **Personal Access Tokens** tab
2. Click **New Personal Access Token**
3. Set expiration (or leave as "Never")
4. Click **Create**
5. **IMPORTANT:** Copy the token immediately - you won't be able to see it again!

### Step 5: Update .env File

```bash
echo "ZITADEL_SERVICE_USER_TOKEN=your-copied-token-here" > .env
docker compose restart login
```

## Troubleshooting

### Port Already in Use

If ports 3000 or 8080 are already in use:

1. Stop the conflicting service, or
2. Edit `docker-compose.yml` and change the port mappings:
   ```yaml
   ports:
     - "3001:3000"  # Change 3000 to 3001
     - "8081:8080"  # Change 8080 to 8081
   ```

### "Instance not found" Error

This usually means the `ZITADEL_SERVICE_USER_TOKEN` is missing or invalid:

1. Check that `.env` file exists and has the token
2. Verify the token is correct (no extra spaces or quotes)
3. Make sure the service user has IAM permissions

### Database Issues

If you need to reset everything:

```bash
docker compose down -v
docker compose up
```

This will delete all data and start fresh.

## Development Mode

If you want to run the login UI in development mode (with hot reload) instead of Docker:

1. Make sure Docker Compose is running (for ZITADEL and database)
2. In a separate terminal:
   ```bash
   cd apps/login
   export ZITADEL_SERVICE_USER_TOKEN="$(cat ../../machinekey/login-client.token)"
   export ZITADEL_API_URL="http://localhost:8080"
   pnpm install
   pnpm dev
   ```

## Need Help?

- Check the logs: `docker compose logs -f login`
- Check ZITADEL logs: `docker compose logs -f zitadel`
- Verify services are running: `docker compose ps`

