# 📋 MASTER CHECKLIST DEPLOYMENT - ENTERTAINMENT AI ASSISTANT V1

Dokumen ini adalah **Master Checklist Deployment Lengkap dari NOL** (mulai dari Reinstall OS VPS Ubuntu 22.04, Setup Git, Instalasi aaPanel/Docker, SSL HTTPS, hingga Bot Telegram Aktif).

Gunakan fitur checklist markdown (`- [x]`) untuk menandai setiap langkah yang selesai!

---

## 📌 TAHAP 0: REINSTALL OS VPS (FRESH START 0)

- [ ] **0.1. Reinstall OS VPS di Jagoan Hosting**
  - Login ke Member Area Jagoan Hosting (`member.jagoanhosting.com`).
  - Masuk ke **Services** -> Pilih VPS Anda.
  - Klik **Reinstall OS** -> Pilih **Ubuntu 22.04 LTS**.
  - Masukkan password root baru & simpan.
  - Tunggu 3–5 menit hingga status VPS `Running`.

- [ ] **0.2. Connect SSH Pertama Kali dari Laptop**
  - Buka Terminal / PowerShell di laptop:
    ```bash
    ssh root@IP_VPS_ANDA
    ```
  - Masukkan password root VPS baru Anda.

---

## 📌 TAHAP 1: SETUP GIT REPOSITORY (LAPTOP ↔ GITHUB)

- [ ] **1.1. Buat Repository di GitHub**
  - Buka [GitHub.com](https://github.com) -> Klik **New Repository**.
  - Nama Repo: `entertainment-ai-bot` (set ke **Private** atau **Public**).
  - Biarkan: `Add README` (Off), `Add .gitignore` (No .gitignore).
  - Klik **Create repository**. Salin URL repo Anda.

- [ ] **1.2. Push Kodingan dari Laptop ke GitHub**
  - Buka Terminal / PowerShell di laptop Anda di folder `c:\Users\Danis\Downloads\project`:
    ```bash
    git init
    git branch -M main
    git add .
    git commit -m "feat: initial commit entertainment ai assistant v1"
    git remote add origin https://github.com/USERNAME_ANDA/entertainment-ai-bot.git
    git push -u origin main
    ```

---

## 📌 TAHAP 2: INSTALASI AAPANEL & DOCKER DI VPS

- [ ] **2.1. Perintah Instalasi aaPanel di Ubuntu 22.04**
  - Copy-paste perintah berikut di Terminal VPS:
    ```bash
    wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh && bash install.sh aapanel
    ```
  - Saat ada pertanyaan `Do you want to install aaPanel to the /www directory now?(y/n):`, ketik **`y`** lalu tekan **Enter**.
  - Tunggu 2–4 menit hingga proses instalasi selesai.

- [ ] **2.2. Catat Informasi Login aaPanel**
  - Di akhir instalasi terminal, aaPanel akan menampilkan informasi login seperti ini:
    ```text
    ==================================================================
    aaPanel Internet Address: http://103.xxx.xxx.xxx:8888/xxxxxx
    aaPanel Internal Address: http://192.168.x.x:8888/xxxxxx
    username: xxxxxx
    password: xxxxxx
    ==================================================================
    ```
  - **Catat / Copy** URL Internet Address, Username, dan Password tersebut.

- [ ] **2.3. Login & Install Software di aaPanel App Store**
  - Buka URL aaPanel Internet Address di browser laptop Anda.
  - Masukkan Username & Password aaPanel Anda.
  - Setelah masuk Dashboard aaPanel:
    - Buka menu **App Store** di sidebar kiri.
    - Cari **Docker Manager** -> Klik **Install**.
    - Cari **Nginx** (versi 1.22 atau 1.24) -> Klik **Install** (Pilih mode *LNMP / Fast Install*).

- [ ] **2.4. (Alternatif 1-Line) Install Docker Murni via Terminal**
  - Jika Anda lebih suka tanpa UI aaPanel, cukup jalankan perintah Docker 1-line di terminal VPS:
    ```bash
    curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
    ```

- [ ] **2.5. Clone Proyek dari GitHub ke /www/wwwroot**
  - Jalankan di Terminal VPS (atau menu Terminal di dalam aaPanel):
    ```bash
    cd /www/wwwroot
    git clone https://github.com/USERNAME_ANDA/entertainment-ai-bot.git
    cd /www/wwwroot/entertainment-ai-bot
    chmod +x deploy.sh
    ```

---

## 📌 TAHAP 3: POINTING DOMAIN, ENVIRONMENT & SSL

- [ ] **3.1. Pointing A Record DNS Domain**
  - Buka DNS Manager domain Anda (Cloudflare / Namecheap / Rumahweb / dll).
  - Tambahkan A Record: Subdomain `n8n` -> Target **IP Public VPS** Anda.

- [ ] **3.2. Buat & Edit File `.env` di VPS**
  - Jalankan di Terminal VPS (atau via File Manager aaPanel di `/www/wwwroot/entertainment-ai-bot`):
    ```bash
    cd /www/wwwroot/entertainment-ai-bot
    cp .env.example .env
    nano .env
    ```
  - Isi variabel berikut:
    - `N8N_HOST=n8n.domainanda.com`
    - `POSTGRES_USER=elgroup_user`
    - `POSTGRES_PASSWORD=PasswordAman123!`
    - `TELEGRAM_BOT_TOKEN=8652306942:AAFjb3sY4U0qqWBOvC9DF0BovHs6yDe4zn4`
    - `OPENAI_API_KEY=sk-proj-xxxx...`
    - `ADMIN_TELEGRAM_ID=8965842613`
  - Simpan: `Ctrl + O`, `Enter`. Keluar: `Ctrl + X`.

- [ ] **3.3. Set Domain Nginx di VPS**
  - Edit file Nginx:
    ```bash
    nano nginx/conf.d/n8n.conf
    ```
  - Ganti `n8n.yourdomain.com` (ada 2 tempat) dengan domain Anda.
  - Simpan: `Ctrl + O`, `Enter`. Keluar: `Ctrl + X`.

- [ ] **3.4. Generate Sertifikat SSL Gratis (Certbot)**
  - Jalankan di Terminal VPS:
    ```bash
    apt update && apt install -y certbot
    certbot certonly --standalone -d n8n.domainanda.com
    ```

---

## 📌 TAHAP 4: MENJALANKAN DOCKER SERVICE

- [ ] **4.1. Start Container Docker**
  - Jalankan di VPS:
    ```bash
    cd /www/wwwroot/entertainment-ai-bot
    docker compose up -d
    ```

- [ ] **4.2. Cek Status Container**
  - Periksa status:
    ```bash
    docker compose ps
    ```
  - Pastikan `entertainment_db`, `entertainment_n8n`, dan `entertainment_nginx` berstatus **Up**.

---

## 📌 TAHAP 5: SETUP N8N & WORKFLOWS DI BROWSER

- [ ] **5.1. Buka n8n & Register Akun Admin Baru**
  - Akses `https://n8n.domainanda.com` di browser laptop.
  - Isi Form **Set up owner account** (Email, Nama, Password).

- [ ] **5.2. Import 5 File Workflow JSON**
  - Klik menu **Workflows** -> **Import from File**.
  - Import 5 file dari folder `workflows/`:
    1. `1_telegram_router.json`
    2. `2_admin_barcode_handler.json`
    3. `3_ai_chat_knowledge.json`
    4. `4_group_mention_handler.json`
    5. `5_booking_lead_notifier.json`

- [ ] **5.3. Menambahkan Credentials**
  - Menu **Credentials** -> **Add Credential**:
    - **PostgreSQL**: Host: `postgres`, DB: `elgroup_db`, User: `elgroup_user`, Pass: (Pass DB di `.env`), Port: `5432`.
    - **OpenAI**: Masukkan `OPENAI_API_KEY`.
    - **Telegram API**: Masukkan `TELEGRAM_BOT_TOKEN`.

- [ ] **5.4. Aktifkan Workflow**
  - Buka tiap workflow -> Geser toggle **Active** ke **ON** (Warna Hijau).

---

## 📌 TAHAP 6: SET TELEGRAM WEBHOOK & TESTING

- [ ] **6.1. Set Telegram Webhook**
  - Buka URL ini di browser:
    ```text
    https://api.telegram.org/bot8652306942:AAFjb3sY4U0qqWBOvC9DF0BovHs6yDe4zn4/setWebhook?url=https://n8n.domainanda.com/webhook/telegram-webhook
    ```
  - Pastikan muncul respon `{"ok": true, "result": true}`.

- [ ] **6.2. Uji Coba (Testing) Bot**
  - Test `/start` di Telegram -> Keyboard menu muncul.
  - Test `🎫 Barcode Masuk` -> Pilih outlet.
  - Test AI Chat: *"Jam buka El Norte jam berapa?"*
  - Test Booking Lead: *"Mau booking room besok jam 7 malam di El Seven"*.
  - Test Admin Command: `/updatebarcode`.

---

🔄 **CARA UPDATE KODINGAN DI MASA DEPAN:**
- **Di Laptop**: `git add .` -> `git commit -m "update"` -> `git push origin main`
- **Di VPS**: `cd /www/wwwroot/entertainment-ai-bot && ./deploy.sh`
