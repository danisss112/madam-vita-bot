# 🤖 MEMORY & PROJECT RULES - EL GROUP TELEGRAM & WHATSAPP BOT

Dokumen ini berisi konfigurasi tetap, aturan sistem, arsitektur, dan SOP yang selalu diingat untuk proyek **EL Group Entertainment AI Assistant (Omnichannel: Telegram + WhatsApp)**.

---

## 🔑 1. IDENTITAS, NOMOR RESMI & ADMIN
- **Telegram Bot Token**: `8652306942:AAFjb3sY4U0qqWBOvC9DF0BovHs6yDe4zn4`
- **Username Bot**: `@EL_Group1_Bot`
- **Admin Resmi (Madam Vita)**: `8965842613` (HANYA ID INI yang memiliki akses Admin / Takeover).
- **Telegram Pribadi Madam Vita**: `@spakaraoke`
- **Nomor WhatsApp Resmi Bot**: `6281312464177` (Madam Vita).
- **Link WhatsApp Madam Vita**: `https://wa.me/6281312464177`
- **Grup Telegram Resmi**: `https://t.me/spajakartavip` (Sesi Forum Topic ID: `1` untuk diskusi/info & reservasi paling atas).
- **N8N Host**: `n8n.madamvita.com`

---

## 📱 2. INTEGRASI WHATSAPP (EVOLUTION API v2)
- **Service Name**: `evolution-api` (Container: `entertainment_wa`)
- **Docker Image**: `evoapicloud/evolution-api:latest`
- **API Key**: `elgroup_wa_secret_2026`
- **Instance Name**: `elgroup_bot`
- **Database Schema**: Terisolasi pada PostgreSQL URI `?schema=evolution_api`
- **Cache Config**: `CACHE_REDIS_ENABLED=false` & `CACHE_LOCAL_ENABLED=true` (tanpa Redis server luar).
- **Webhook URL Internal (Docker)**: `http://entertainment_n8n:5678/webhook/whatsapp-incoming` dengan event `MESSAGES_UPSERT`.
- **Kirim Teks WA**: `POST http://evolution-api:8080/message/sendText/elgroup_bot`
- **Kirim Gambar WA**: `POST http://evolution-api:8080/message/sendMedia/elgroup_bot`

---

## ⚡ 3. SMART AUTO-TAKEOVER (TELEGRAM & WHATSAPP)
1. **Khusus DM Pribadi (1-on-1 Business Chat, Private Telegram & WhatsApp)**.
2. **Auto-Pause (5 Menit)**:
   - **Telegram Business**: Ketika Admin (`8965842613`) membalas pesan tamu (`fromId !== chatId`), bot otomatis **DIAM (PAUSED)** selama **5 menit**.
   - **WhatsApp**: Ketika Madam Vita membalas chat tamu langsung dari aplikasi WhatsApp HP (`fromMe = true`), bot otomatis **DIAM (PAUSED)** selama **5 menit**.
   - Setiap kali Admin membalas lagi, timer 5 menit di-reset dari awal.
3. **Auto-Resume (24/7)**:
   - Jika setelah 5 menit Admin tidak membalas lagi dan tamu mengirim chat baru, bot otomatis **mengambil alih** dan membalas tamu.
4. **Perintah Cepat Admin Telegram**:
   - `/pause`: Mengunci bot diam 2 jam.
   - `/resume` (atau `/unpause`): Membuka kunci bot agar aktif kembali seketika.

---

## 🎫 4. SISTEM BARCODE MASUK RESMI (TELEGRAM & WHATSAPP)
1. **Admin Update Barcode**:
   - Admin upload foto barcode harian via perintah `/updatebarcode` di Telegram (`bot_barcodes`).
   - Jadwal reset otomatis setiap hari jam **02:00 WIB** (`Schedule Reset Barcode 02:00 WIB`).
2. **Tamu Minta Barcode di WhatsApp / Telegram**:
   - Keyword: *"minta barcode"*, *"minta akses"*, *"barcode el centro"*, *"akses fenix"*, dll.
   - Jika sebut cabang: Bot langsung mengirimkan **Foto QR Code Barcode Masuk Resmi** + Lokasi + Nomor Lantai + SOP *"Sebutkan atas nama Madam Vita"*.
   - Jika belum sebut cabang: Bot membalas dengan daftar pilihan nama outlet lengkap.

---

## 💬 5. ALUR PERCAKAPAN RESERVASI & PERTANYAAN KHUSUS
1. **Pertanyaan Aneh / Di Luar SOP / Di Luar Knowledge**:
   - Bot membalas ramah: *"Mohon bersabar ya kak, pertanyaan Kakak sudah kami teruskan dan akan segera dijawab langsung oleh Madam Vita 🙏✨"*
   - AI menyertakan tag `[ESCALATE_QUESTION: <ringkasan>]`.
   - Node `Send AI Reply Smart` mengirim notifikasi alert lengkap ke Telegram Madam Vita (`8965842613`) dengan link langsung chat tamu (WA / Telegram).
2. **Alur Reservasi Interaktif**:
   - **Tahap 1 (Tanya detail)**: Bot menanyakan outlet tujuan (*Centro, Pangjay, Seven, Norte, Fenix, KG, Orca, Casa, Memento*) dan rencana jam kedatangan.
   - **Tahap 2 (Konfirmasi)**: Setelah tamu menyebutkan cabang & jam, bot mengonfirmasi data dicatat dan diteruskan ke Madam Vita (`[BOOKING_LEAD: ...]`), lalu mengirim notifikasi rincian booking lengkap ke Admin Telegram Madam Vita (`8965842613`).
3. **Kontak Reservasi**:
   - Semua reservasi dan booking di seluruh cabang ditangani langsung oleh **Madam Vita** (`@spakaraoke` / `https://wa.me/6281312464177`).

---

## 💆‍♀️ 6. SOP ROOM SERVICE & 3 FOTO RULES LENGKAP
Setiap kali tamu meminta atau menanyakan **Rules / SOP / SOP Room Service** (baik lewat tombol menu `📋 RULES`, perintah `/rules`, atau chat biasa), bot mengirimkan **3 Foto Berurutan**:
1. 🖼️ **Foto 1 (Rules Attention Guys)**: `https://tikael.madamtikael.id/botikar2c.jpeg`
   - *Caption*: `📌 <b>ATTENTION GUYS</b>\nMau ke EL Group ?\nWajib baca dulu ya !`
2. 🖼️ **Foto 2 (3 Pilihan Layanan)**: `https://tikael.madamtikael.id/rules_layanan.jpeg`
   - *Caption*: `<b>EL GROUP - 3 PILIHAN:</b>\n\nMau booking yang mana ?`
3. 🖼️ **Foto 3 (Poster SOP Room Service Pink)**: `https://tikael.madamtikael.id/sop_room.jpeg`
   - *Caption*: `⚠️ <b>WAJIB IKUTI SOP</b> ⚠️\nDemi kenyamanan bersama 👍🏻`

- **8 Rangkaian Layanan SOP Room Service (By Madam Vita)**:
  1. 👣 **Baby shower**
  2. 🪷 **Massage relaxsasi sensual**
  3. 🤍 **Body message (BM)**
  4. 🐾 **Mandi kucing (MK)**
  5. 🥭 **Petik mangga (PM)**
  6. 🤲✨ **Hand job (HJ)**
  7. 💨 **Blow job (BJ)**
  8. 💕 **Fuck job (FJ)**

---

## 🧠 7. DUAL-ENGINE AI CS (GROQ PRIMARY + GOOGLE GEMINI BACKUP)
Untuk menjamin bot tidak pernah mati saat kuota gratisan Groq habis:
1. **Engine Utama**: **Groq Chat Model** (`llama-3.1-8b-instant`)
   - Kapasitas tinggi: 20.000 TPM / 500.000 TPD.
   - Respon super cepat (< 500ms).
   - Window Memory Buffer dipatok `contextWindowLength: 4` (menghemat token 60%).
2. **Engine Cadangan (Auto-Fallback)**: **Google Gemini Chat Model** (`gemini-1.5-flash`)
   - Kuota gratis: 1.000.000 TPM / 15 RPM.
   - Aktif otomatis via jalur error (`onError: continueErrorOutput`) jika Groq terkena Rate Limit 429 atau error server.
3. **Omnichannel Unified Router**: Keduanya mengalir ke node yang sama (`Send AI Reply Smart`) untuk dikirim ke Telegram maupun WhatsApp.

---

## 🚀 8. DEPLOYMENT & ASSET SYNC AUTOMATION
- **Script Deploy**: `deploy.sh`
- **Generator Script**: `scratch/build_clean_workflow.js`
- **Output Target**: `workflows/master_bot_workflow.json`
- **Aturan Node n8n**: Selalu gunakan `.first().json` (contoh: `$('Is AI Needed').first().json`) dan **HINDARI** `.item.json`.
