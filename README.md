# 🚀 Entertainment AI Assistant - Deployment Guide (V1)

Sistem ini adalah rebuild lengkap dari nol untuk **EL Group Entertainment AI Assistant** berbasis **Docker**, **n8n**, **PostgreSQL**, **Nginx (SSL)**, **Telegram Bot API**, dan **OpenAI API**.

---

## 📁 Struktur File Proyek

```text
project/
├── docker-compose.yml           # Infrastruktur container (Postgres, n8n, Nginx)
├── .env.example                 # Config environment & credentials
├── nginx/
│   └── conf.d/
│       └── n8n.conf             # Nginx reverse proxy + SSL setup
├── postgres/
│   └── init.sql                 # Skema DB, Outlets, & Knowledge Base EL Group
└── workflows/                   # Workflow n8n siap import
    ├── 1_telegram_router.json
    ├── 2_admin_barcode_handler.json
    ├── 3_ai_chat_knowledge.json
    ├── 4_group_mention_handler.json
    └── 5_booking_lead_notifier.json
```

---

## ⚙️ Langkah 1: Persiapan di VPS

1. Connect ke VPS via SSH:
   ```bash
   ssh root@ip_vps_anda
   ```

2. Pastikan Docker & Docker Compose sudah terinstall di VPS:
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   ```

3. Buat folder proyek di VPS:
   ```bash
   mkdir -p /opt/entertainment-ai
   cd /opt/entertainment-ai
   ```

4. Upload/salin file dari repository ini ke folder `/opt/entertainment-ai` di VPS.

---

## 🔒 Langkah 2: Setting Environment & SSL

1. Salin `.env.example` menjadi `.env`:
   ```bash
   cp .env.example .env
   nano .env
   ```
   * Isikan `N8N_HOST` dengan domain Anda (misal `n8n.namadomain.com`).
   * Isikan `TELEGRAM_BOT_TOKEN`, `OPENAI_API_KEY`, dan `ADMIN_TELEGRAM_ID`.

2. Update domain di `nginx/conf.d/n8n.conf`:
   ```bash
   nano nginx/conf.d/n8n.conf
   ```
   Ganti `n8n.yourdomain.com` dengan nama domain aktual Anda.

3. Dapatkan sertifikat SSL gratis dengan Certbot (Let's Encrypt):
   ```bash
   apt install -y certbot
   certbot certonly --standalone -d n8n.yourdomain.com
   ```

---

## 🚀 Langkah 3: Menjalankan Container

Jalankan semua service dengan 1 perintah:
```bash
docker compose up -d
```

Periksa status container:
```bash
docker compose ps
```
Pastikan `entertainment_db`, `entertainment_n8n`, dan `entertainment_nginx` berstatus `Up`.

---

## 🌐 Langkah 4: Setup n8n & Webhook Telegram

1. Buka browser dan akses URL n8n Anda: `https://n8n.yourdomain.com`
2. Buat akun Admin n8n saat pertama kali dibuka.
3. Import 5 workflow dari folder `workflows/`:
   * Buka menu **Workflows** -> **Import from file** -> Pilih file JSON di folder `workflows/`.
4. Tambahkan Credentials di n8n:
   * **PostgreSQL Account**: Host `postgres`, Port `5432`, Database `elgroup_db`, User `elgroup_user`, Password sesuai `.env`.
   * **OpenAI Account**: Masukkan `OPENAI_API_KEY`.
   * **Telegram Bot Account**: Masukkan `TELEGRAM_BOT_TOKEN`.
5. Aktifkan semua Workflow (toggle **Active** ke ON).

6. Set Webhook Telegram ke n8n URL Anda:
   Buka URL berikut di browser Anda:
   ```text
   https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/setWebhook?url=https://n8n.yourdomain.com/webhook/telegram-webhook
   ```

---

## 🧪 Langkah 5: Uji Coba (Testing)

1. **Uji Command**: Buka bot di Telegram, ketik `/start`. Keyboard menu EL Group akan langsung muncul!
2. **Uji Barcode Masuk**: Tekan tombol `🎫 Barcode Masuk` -> Pilih outlet -> Bot akan mengecek status barcode valid hari ini (expired setiap jam 02.00 WIB).
3. **Uji AI Knowledge**: Ketik pertanyaan bebas seperti *"Jam buka El Norte jam berapa?"* atau *"Ada paket estafet gak?"*. AI akan menjawab secara cerdas berdasarkan database tanpa mengarang.
4. **Uji Admin Lead Handover**: Jika user bertanya *"Saya mau booking room di El Seven untuk besok"*, AI akan memicu `[NEED_ADMIN]` dan notifikasi lead langsung terkirim ke Admin Telegram ID (`8965842613`).
5. **Uji Admin Update Barcode**: Ketik `/updatebarcode` di Telegram dari akun Admin untuk mengunggah foto barcode cabang terbaru.

---

## 🗑️ Catatan File Lama (`botika.php`)
Setelah pengujian selesai dan sistem V1 berjalan lancar di VPS, Anda dapat menghapus file legacy `botika.php` dengan aman.
