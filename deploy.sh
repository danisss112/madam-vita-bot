#!/bin/bash
# =============================================================================
# AUTO DEPLOY SCRIPT FOR ENTERTAINMENT AI ASSISTANT (MADAM VITA)
# =============================================================================

echo "🔄 Stashing any local changes & pulling latest from Git..."
git stash
git pull origin main

echo "🐳 Rebuilding and restarting Docker containers..."
docker compose up -d

echo "🧹 Cleaning up unused Docker images..."
docker image prune -f

echo "🖼️ Syncing static assets to web root..."
for dir in /www/wwwroot/*vita* /www/wwwroot/tikael.madamtikael.id /www/wwwroot/tikael /var/www/html; do
  if [ -d "$dir" ]; then
    cp -rf assets/* "$dir/"
    echo "Copied assets to $dir"
  fi
done

echo "✅ Deployment completed successfully!"
