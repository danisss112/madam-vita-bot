# 📱 PANDUAN LENGKAP INTEGRASI WHATSAPP KE n8n (EL GROUP AI BOT)

Dokumen ini berisi panduan langkah demi langkah (*step-by-step*) untuk menghubungkan sistem **EL Group Entertainment AI Bot** yang sudah berjalan di VPS (n8n + PostgreSQL + Telegram) ke **WhatsApp**, menggunakan **Evolution API (Multi-Device Gateway)**.

---

## 📑 DAFTAR ISI
1. [Arsitektur & Cara Kerja](#1-arsitektur--cara-kerja)
2. [Prasyarat & Persiapan](#2-prasyarat--persiapan)
3. [Langkah 1: Update Docker Compose di VPS](#3-langkah-1-update-docker-compose-di-vps)
4. [Langkah 2: Jalankan Container di VPS](#4-langkah-2-jalankan-container-di-vps)
5. [Langkah 3: Buka Port / Setup Reverse Proxy (aaPanel/Nginx)](#5-langkah-3-buka-port--setup-reverse-proxy-aapanelnginx)
6. [Langkah 4: Buat Instance & Scan QR Code WhatsApp](#6-langkah-4-buat-instance--scan-qr-code-whatsapp)
7. [Langkah 5: Sambungkan Webhook ke n8n](#7-langkah-5-sambungkan-webhook-ke-n8n)
8. [Langkah 6: Konfigurasi Workflow di n8n](#8-langkah-6-konfigurasi-workflow-di-n8n)
9. [Langkah 7: Smart Auto-Takeover di WhatsApp](#9-langkah-7-smart-auto-takeover-di-whatsapp)
10. [Troubleshooting & Perawatan](#10-troubleshooting--perawatan)

---

## 1. Arsitektur & Cara Kerja

Dengan arsitektur ini, **Telegram dan WhatsApp berbagi satu otak AI (Groq Llama 3.3), satu database PostgreSQL, dan Knowledge SOP yang sama**:

```mermaid
flowchart TD
    subgraph Pengguna
        TG_USER[Pelanggan Telegram]
        WA_USER[Pelanggan WhatsApp]
    end

    subgraph VPS Docker Network
        TG_BOT[Telegram Webhook]
        EVO[Evolution API :8080]
        N8N[n8n Automation Engine :5678]
        PG[(PostgreSQL DB :5432)]
        AI[Groq Llama 3.3 AI Agent]
    end

    TG_USER <--> TG_BOT <--> N8N
    WA_USER <--> EVO <--> N8N
    
    N8N <--> PG
    N8N <--> AI

    N8N -.->|Notifikasi Lead & Takeover| ADMIN[Madam Vita Admin : 8965842613]
```

### ✨ Keunggulan Metode Ini:
- **100% Gratis**: Tidak ada biaya per percakapan ke Meta.
- **Bisa Pakai Nomor yang Sudah Ada**: Cukup scan QR code dari aplikasi WhatsApp di HP (WA Biasa maupun WA Business).
- **Auto-Takeover Terintegrasi**: Jika Madam Vita membalas chat tamu dari HP, bot otomatis diam (*pause*) 5 menit.

---

## 2. Prasyarat & Persiapan

Sebelum memulai, pastikan hal-hal berikut sudah siap:
1. **Akses SSH ke VPS** (Tempat n8n dan Docker sudah berjalan).
2. **HP dengan Aplikasi WhatsApp** (Nomor resmi yang akan dijadikan asisten CS).
3. **API Key Rahasia** untuk mengamankan koneksi Evolution API (Contoh: `elgroup_wa_secret_2026`).

---

## 3. Langkah 1: Update Docker Compose di VPS

Buka file `docker-compose.yml` di server VPS Anda dan tambahkan service **`evolution-api`**:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    container_name: entertainment_db
    restart: always
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-elgroup_user}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-PasswordAman123!}
      POSTGRES_DB: ${POSTGRES_DB:-elgroup_db}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./postgres/init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "127.0.0.1:5432:5432"
    networks:
      - entertainment_net

  n8n:
    image: docker.n8n.io/n8nio/n8n:latest
    container_name: entertainment_n8n
    restart: always
    environment:
      - N8N_HOST=${N8N_HOST:-n8n.madamvita.com}
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - NODE_ENV=production
      - WEBHOOK_URL=https://${N8N_HOST:-n8n.madamvita.com}/
      - GENERIC_TIMEZONE=Asia/Jakarta
      - N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
      - N8N_DIAGNOSTICS_ENABLED=false
    volumes:
      - n8n_data:/home/node/.n8n
    ports:
      - "127.0.0.1:5678:5678"
    depends_on:
      - postgres
    networks:
      - entertainment_net

  # ========================================================
  # SERVICE TAMBAHAN: WHATSAPP MULTI-DEVICE GATEWAY
  # ========================================================
  evolution-api:
    image: evoapicloud/evolution-api:latest
    container_name: entertainment_wa
    restart: always
    environment:
      - SERVER_URL=http://evolution-api:8080
      - AUTHENTICATION_API_KEY=elgroup_wa_secret_2026
      - DATABASE_PROVIDER=postgresql
      - DATABASE_CONNECTION_URI=postgresql://elgroup_user:PasswordAman123!@postgres:5432/elgroup_db?schema=evolution_api
      - DATABASE_SAVE_DATA_INSTANCE=true
      - DATABASE_SAVE_DATA_NEW_MESSAGE=true
      - DATABASE_SAVE_MESSAGE_UPDATE=true
      - DATABASE_CONNECTION_CLIENT_NAME=evolution_wa
      - WEBSOCKET_ENABLED=true
      - CACHE_REDIS_ENABLED=false
      - CACHE_LOCAL_ENABLED=true
      - LOG_LEVEL=ERROR,WARN,INFO
      - DEL_INSTANCE=false
    ports:
      - "8080:8080"
    depends_on:
      - postgres
    networks:
      - entertainment_net

volumes:
  postgres_data:
  n8n_data:

networks:
  entertainment_net:
    driver: bridge
```

---

## 4. Langkah 2: Jalankan Container di VPS

Login ke terminal SSH VPS Anda, lalu jalankan perintah berikut:

```bash
# 1. Pindah ke direktori project
cd ~/project

# 2. Jalankan container baru di background
docker compose up -d

# 3. Periksa status ketiga container
docker compose ps
```

**Output yang diharapkan:**
```text
NAME                IMAGE                               STATUS
entertainment_db    postgres:16-alpine                  Up
entertainment_n8n   docker.n8n.io/n8nio/n8n:latest      Up
entertainment_wa    evolutionapi/evolution-api:v2.1.2    Up (healthy)
```

---

## 5. Langkah 3: Buka Port / Setup Reverse Proxy (aaPanel/Nginx)

Jika Anda menggunakan **aaPanel** atau **Nginx Reverse Proxy**:

### Opsi A: Menggunakan Subdomain (Direkomendasikan)
1. Buat Subdomain DNS `wa.madamvita.com` mengarah ke IP VPS Anda.
2. Di aaPanel: **Website** ➔ **Add Site** ➔ `wa.madamvita.com`.
3. Buka tab **Reverse Proxy** ➔ **Add Reverse Proxy**:
   - Target URL: `http://127.0.0.1:8080`
   - Sent domain: `$host`
4. Aktifkan **SSL (Let's Encrypt)**.

### Opsi B: Akses Langsung via IP Port 8080
Buka firewall port `8080` di aaPanel / VPS Security Group:
```bash
ufw allow 8080/tcp
```

---

## 6. Langkah 4: Buat Instance & Scan QR Code WhatsApp

### 1. Buat Instance WhatsApp Baru
Jalankan perintah ini di terminal VPS (atau via Postman/cURL):

```bash
curl -X POST http://localhost:8080/instance/create \
  -H "apikey: elgroup_wa_secret_2026" \
  -H "Content-Type: application/json" \
  -d '{
    "instanceName": "elgroup_bot",
    "token": "elgroup_token_123",
    "qrcode": true,
    "integration": "WHATSAPP-BAILEYS"
  }'
```

### 2. Dapatkan QR Code untuk Discan
Buka browser Anda dan akses URL berikut:
`http://IP-VPS-ANDA:8080/instance/connect/elgroup_bot`
*(Ganti `IP-VPS-ANDA` dengan IP VPS Anda, atau gunakan domain `https://wa.madamvita.com/instance/connect/elgroup_bot`)*.

### 3. Scan Menggunakan WhatsApp di HP:
1. Buka aplikasi WhatsApp di HP Anda.
2. Masuk ke **Menu (Titik 3)** / **Pengaturan** ➔ **Perangkat Tertaut (Linked Devices)**.
3. Klik **Tautkan Perangkat**.
4. Scan QR Code yang muncul di layar browser.
5. Tunggu 5 detik hingga status berubah menjadi **Connected** ✅.

---

## 7. Langkah 5: Sambungkan Webhook ke n8n

Setelah WhatsApp terhubung, kita arahkan seluruh pesan masuk agar otomatis dikirim ke n8n:

Jalankan perintah ini di terminal VPS:

```bash
curl -X POST http://localhost:8080/webhook/set/elgroup_bot \
  -H "apikey: elgroup_wa_secret_2026" \
  -H "Content-Type: application/json" \
  -d '{
    "webhook": {
      "enabled": true,
      "url": "http://entertainment_n8n:5678/webhook/whatsapp-incoming",
      "byEvents": false,
      "base64": false,
      "events": [
        "MESSAGES_UPSERT"
      ]
    }
  }'
```

> 💡 **Info Jaringan Docker:** Karena n8n dan Evolution API berada di jaringan `entertainment_net` yang sama, URL webhook cukup menggunakan nama container internal: `http://entertainment_n8n:5678/webhook/whatsapp-incoming`.

---

## 8. Langkah 6: Konfigurasi Workflow di n8n

Di dalam canvas n8n, buat alur kerja WhatsApp:

```mermaid
flowchart LR
    W1[Webhook Trigger\nPOST /webhook/whatsapp-incoming] --> W2[Code Node: Parse WA Payload]
    W2 --> W3[Check Is AI Needed & Not Paused]
    W3 --> W4[AI Agent Groq Llama 3.3\n+ Knowledge Base]
    W4 --> W5[HTTP Request:\nSend WA Text / Image]
```

### 1. Webhook Node:
- **HTTP Method**: `POST`
- **Path**: `whatsapp-incoming`
- **Response Mode**: `Immediately` (Response code: `200`)

### 2. Code Node (Parse WhatsApp Message):
```javascript
const item = $input.item.json;
const data = item.data || {};
const key = data.key || {};

// Abaikan jika pesan dikirim oleh bot itu sendiri (fromMe)
const fromMe = Boolean(key.fromMe);
const remoteJid = key.remoteJid || '';

// Hanya proses pesan dari private chat (akhiran @s.whatsapp.net), bukan dari grup (@g.us)
const isPrivateChat = remoteJid.endsWith('@s.whatsapp.net');

let userPhone = remoteJid.replace('@s.whatsapp.net', '');
let pushName = data.pushName || 'Tamu WhatsApp';
let messageText = '';

if (data.message) {
  messageText = data.message.conversation ||
                data.message.extendedTextMessage?.text ||
                data.message.imageMessage?.caption || '';
}

messageText = messageText.trim();

// Format standar internal
return {
  channel: 'whatsapp',
  chatId: userPhone,
  fromId: userPhone,
  senderName: pushName,
  text: messageText,
  remoteJid: remoteJid,
  fromMe: fromMe,
  isValid: Boolean(!fromMe && isPrivateChat && messageText.length > 0)
};
```

### 3. HTTP Request Node (Kirim Balasan Teks ke WhatsApp):
- **Method**: `POST`
- **URL**: `http://evolution-api:8080/message/sendText/elgroup_bot`
- **Header**:
  - `apikey`: `elgroup_wa_secret_2026`
  - `Content-Type`: `application/json`
- **Body JSON**:
  ```json
  {
    "number": "={{ $json.remoteJid }}",
    "text": "={{ $json.aiOutput }}"
  }
  ```

### 4. HTTP Request Node (Kirim Foto / Price List / Lokasi ke WhatsApp):
Jika AI menyertakan URL gambar (misal foto cabang / price list):
- **Method**: `POST`
- **URL**: `http://evolution-api:8080/message/sendMedia/elgroup_bot`
- **Header**:
  - `apikey`: `elgroup_wa_secret_2026`
  - `Content-Type`: `application/json`
- **Body JSON**:
  ```json
  {
    "number": "={{ $json.remoteJid }}",
    "mediatype": "image",
    "media": "={{ $json.imageUrl }}",
    "caption": "={{ $json.captionText }}"
  }
  ```

---

## 9. Langkah 7: Smart Auto-Takeover di WhatsApp

Logika auto-takeover WhatsApp bekerja persis seperti Telegram Business:

1. **Madam Vita membalas chat tamu dari aplikasi WhatsApp di HP:**
   - Event `MESSAGES_UPSERT` akan memiliki flag `fromMe: true`.
   - Node session akan mengupdate tabel `bot_chat_sessions`:
     ```sql
     UPDATE bot_chat_sessions 
     SET is_paused = TRUE, 
         paused_until = NOW() + INTERVAL '5 minutes' 
     WHERE chat_id = $1;
     ```
2. **Bot Otomatis Diam (Paused):**
   - Selama 5 menit sejak balasan terakhir Madam Vita, bot tidak akan membalas chat tamu tersebut.
3. **Auto-Resume (24/7):**
   - Jika setelah 5 menit Madam Vita tidak membalas lagi dan tamu chat kembali, bot otomatis aktif mengambil alih.

---

## 10. Troubleshooting & Perawatan

### 1. Cara Cek Status & Log Evolution API di VPS:
```bash
docker compose logs -f evolution-api
```

### 2. Jika WhatsApp Terputus (Logout dari HP / Update WA):
Cukup generate ulang QR code dengan membuka:
`http://IP-VPS-ANDA:8080/instance/connect/elgroup_bot`
lalu scan kembali dari menu **Perangkat Tertaut** di WhatsApp HP.

### 3. Cara Restart Service WhatsApp:
```bash
docker compose restart evolution-api
```

### 4. Cek Webhook n8n:
Buka n8n ➔ **Executions** ➔ periksa apakah data pesan WhatsApp masuk secara real-time saat Anda mengirim pesan ke nomor bot.

---

*Dokumen ini dibuat otomatis untuk tim pengembang EL Group Entertainment AI Assistant.*
