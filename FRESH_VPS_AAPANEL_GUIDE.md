# 🚀 PANDUAN DEPLOYMENT DARI NOL (FRESH VPS & AAPANEL) - BOT MADAM VITA

Panduan ini disusun khusus untuk **VPS yang baru di-setup**, menggunakan **aaPanel** (atau Terminal SSH) untuk menjalankan bot **EL Group Madam Vita (Telegram + WhatsApp Omnichannel)**.

---

## 📌 RANGKUMAN ALUR DEPLOYMENT

```text
[1] Connect SSH & Install aaPanel / Docker
       ↓
[2] Setup Subdomain & SSL di aaPanel (n8n.madamvita.com)
       ↓
[3] Clone Project dari GitHub ke VPS (`/opt/entertainment-ai`)
       ↓
[4] Setup `.env` Konfigurasi Madam Vita
       ↓
[5] Jalankan Container (`docker compose up -d`)
       ↓
[6] Login n8n & Import `workflows/master_bot_workflow.json`
       ↓
[7] Set Webhook Telegram & WhatsApp
```

---

## 🔹 TAHAP 1: KONEKSI SSH & INSTALL AAPANEL / DOCKER

### 1. Connect ke VPS via SSH:
```bash
ssh root@IP_VPS_ANDA
```

### 2. Install aaPanel di VPS Ubuntu:
```bash
wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh && bash install.sh aapanel
```
Setelah selesai, catat URL Login aaPanel, Username, dan Password yang tampil di terminal.

### 3. Install Software di App Store aaPanel:
Buka dashboard aaPanel di browser:
- Masuk ke menu **App Store**.
- Install **Nginx** (LNMP) versi terbaru.
- Install **Docker Manager**.

---

## 🔹 TAHAP 2: SETUP DOMAIN & REVERSE PROXY DI AAPANEL

1. **Pastikan DNS Record sudah mengarah ke IP VPS**:
   - A Record: `n8n.madamvita.com` ➔ `IP_VPS_ANDA`
   - A Record: `wa.madamvita.com` ➔ `IP_VPS_ANDA` *(opsional untuk WA)*

2. **Buat Website di aaPanel**:
   - Menu **Website** ➔ **Add Site**.
   - Domain Name: `n8n.madamvita.com`.
   - Submit.

3. **Pasang Sertifikat SSL (HTTPS)**:
   - Klik nama website `n8n.madamvita.com` ➔ Tab **SSL** ➔ Pilih **Let's Encrypt** ➔ Centang domain ➔ Klik **Apply**.
   - Aktifkan toggle **Force HTTPS**.

4. **Konfigurasi Reverse Proxy ke n8n**:
   - Di popup setting website `n8n.madamvita.com` ➔ Tab **Reverse Proxy** ➔ **Add Reverse Proxy**.
   - Proxy Name: `n8n_proxy`
   - Target URL: `http://127.0.0.1:5678`
   - Sent Domain: `$host`
   - Klik **Save**.

---

## 🔹 TAHAP 3: CLONE PROJECT KE VPS

Di terminal SSH VPS:

1. Masuk ke direktori `/opt`:
   ```bash
   mkdir -p /opt
   cd /opt
   ```

2. Clone repository:
   ```bash
   git clone https://github.com/USERNAME_ANDA/entertainment-ai-bot.git entertainment-ai
   ```
   *(Masukkan Username & Personal Access Token GitHub jika repo bersifat Private)*.

3. Masuk ke folder proyek & beri izin deploy script:
   ```bash
   cd /opt/entertainment-ai
   chmod +x deploy.sh
   ```

---

## 🔹 TAHAP 4: SETUP FILE `.env` & JALANKAN DOCKER

1. Buat file `.env` dari template:
   ```bash
   cp .env.example .env
   nano .env
   ```

2. Pastikan isi `.env` sebagai berikut:
   ```env
   N8N_HOST=n8n.madamvita.com
   POSTGRES_USER=elgroup_user
   POSTGRES_PASSWORD=PasswordDatabaseAman123!
   POSTGRES_DB=elgroup_db
   TELEGRAM_BOT_TOKEN=8652306942:AAFjb3sY4U0qqWBOvC9DF0BovHs6yDe4zn4
   ADMIN_TELEGRAM_ID=8965842613
   WA_API_KEY=elgroup_wa_secret_2026
   GROQ_API_KEY=gsk_xxxx...
   ```
   *(Simpan: `Ctrl + O`, `Enter`. Keluar: `Ctrl + X`)*.

3. Jalankan seluruh container Docker:
   ```bash
   docker compose up -d
   ```

4. Periksa status container:
   ```bash
   docker compose ps
   ```
   > Pastikan `entertainment_db`, `entertainment_n8n`, dan `entertainment_wa` berstatus **Up**.

---

## 🔹 TAHAP 5: SETUP WORKFLOW DI N8N BROWSER

1. Buka browser: `https://n8n.madamvita.com`
2. Lengkapi form **Owner Setup** (Nama, Email, Password akun n8n Anda).
3. **Import Workflow Master**:
   - Buka menu **Workflows** ➔ Klik **Import from File**.
   - Pilih file `workflows/master_bot_workflow.json` dari laptop Anda.
4. **Set Credentials di n8n**:
   - **PostgreSQL**:
     - Host: `postgres`
     - Database: `elgroup_db`
     - User: `elgroup_user`
     - Password: `PasswordDatabaseAman123!` *(sesuai .env)*
     - Port: `5432`
   - **Groq API**:
     - Masukkan API Key Groq Anda.
   - **Google Gemini API**:
     - Masukkan API Key Google AI Studio Anda *(sebagai backup AI)*.
5. Geser toggle status workflow ke **Active (ON)** di pojok kanan atas.

---

## 🔹 TAHAP 6: SET TELEGRAM WEBHOOK

Buka tab baru di browser Anda dan jalankan URL berikut:
```text
https://api.telegram.org/bot8652306942:AAFjb3sY4U0qqWBOvC9DF0BovHs6yDe4zn4/setWebhook?url=https://n8n.madamvita.com/webhook/telegram-webhook
```

Jika muncul respon:
```json
{"ok": true, "result": true, "description": "Webhook was set"}
```
Artinya Bot Telegram **@EL_Group1_Bot** sudah **100% AKTIF & TERHUBUNG!** 🎉

---

## 🔹 TAHAP 7: SCAN QR WHATSAPP (EVOLUTION API)

1. Buka browser: `http://IP_VPS_ANDA:8080/instance/connect/elgroup_bot`
   - Header API Key: `elgroup_wa_secret_2026`
2. Scan QR Code menggunakan aplikasi WhatsApp di HP Madam Vita (`6281312464177`).
3. Set Webhook WhatsApp internal:
   - Webhook URL: `http://entertainment_n8n:5678/webhook/whatsapp-incoming`
   - Event: `MESSAGES_UPSERT`
   - Webhook By Events: `true`

---

## 🔄 CARA UPDATE DI MASA DEPAN

Jika ada pembaruan script atau prompt di GitHub, cukup jalankan perintah ini di terminal VPS:
```bash
cd /opt/entertainment-ai
bash deploy.sh
```
Script `deploy.sh` akan otomatis me-pull kode terbaru dan me-restart container secara aman!
