-- =============================================================================
-- DATABASE SCHEMA: EL GROUP TELEGRAM & WHATSAPP BOT (OMNICHANNEL)
-- =============================================================================

-- Table 1: Outlets Information & Operational Metadata
CREATE TABLE IF NOT EXISTS outlets (
    id SERIAL PRIMARY KEY,
    outlet_key VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    location_url TEXT,
    operational_hours TEXT NOT NULL,
    pricelist_photo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table 2: Knowledge Base for FAQ, Rules, Services & Packages
CREATE TABLE IF NOT EXISTS knowledge (
    id SERIAL PRIMARY KEY,
    category VARCHAR(50) NOT NULL,
    question_pattern TEXT NOT NULL,
    answer_text TEXT NOT NULL,
    keywords TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table 3: Daily Admin Uploaded Barcode Images
CREATE TABLE IF NOT EXISTS bot_barcodes (
    id SERIAL PRIMARY KEY,
    outlet_key VARCHAR(50) UNIQUE NOT NULL,
    file_id TEXT NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT
);

-- Table 4: Admin Interactive Wizard State
CREATE TABLE IF NOT EXISTS bot_admin_state (
    admin_id BIGINT PRIMARY KEY,
    outlet_key VARCHAR(50) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table 5: 1-on-1 Chat Session State for Smart Auto-Takeover
CREATE TABLE IF NOT EXISTS bot_chat_sessions (
    chat_id TEXT PRIMARY KEY,
    is_paused BOOLEAN DEFAULT FALSE,
    paused_until TIMESTAMP WITH TIME ZONE,
    last_admin_activity TIMESTAMP WITH TIME ZONE,
    business_connection_id TEXT,
    channel VARCHAR(20) DEFAULT 'telegram',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table 6: Admin Users
CREATE TABLE IF NOT EXISTS admins (
    id SERIAL PRIMARY KEY,
    telegram_id BIGINT UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(50) DEFAULT 'admin',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table 7: Booking Leads & Customer Inquiries Log
CREATE TABLE IF NOT EXISTS booking_leads (
    id SERIAL PRIMARY KEY,
    guest_chat_id TEXT NOT NULL,
    channel VARCHAR(20) DEFAULT 'telegram',
    guest_name VARCHAR(100),
    guest_username VARCHAR(100),
    outlet_name VARCHAR(100),
    service_type VARCHAR(100),
    planned_arrival VARCHAR(100),
    guest_count INT DEFAULT 1,
    raw_inquiry TEXT,
    status VARCHAR(50) DEFAULT 'new',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- SEED DATA INITIALIZATION
-- =============================================================================

-- Seed Admin (Madam Vita Admin ID)
INSERT INTO admins (telegram_id, name, role) 
VALUES (8965842613, 'Madam Vita Admin', 'super_admin')
ON CONFLICT (telegram_id) DO NOTHING;

-- Seed Outlets
INSERT INTO outlets (outlet_key, name, location_url, operational_hours, pricelist_photo_url) VALUES
('centro',     'El Centro',           NULL, '14.00 – 01.00 WIB | Last Order 00.30', 'https://tikael.madamtikael.id/el_centro.jpeg'),
('spaPangjay', 'El Spa Pangjay',      NULL, '12.00 – 23.00 WIB | Last Order 22.30', 'https://tikael.madamtikael.id/el_spa_pangjay_new.jpeg'),
('seven',      'El Seven Club',       'https://g.co/kgs/XsooJhR', '18.00 – 04.00 WIB | Last Order 03.30', 'https://tikael.madamtikael.id/el_seven_club.jpeg'),
('norte',      'El Norte',            'https://g.co/kgs/2x2ah1j', '12.00 – 24.00 WIB | Last Order 23.30', 'https://tikael.madamtikael.id/el_norte.jpeg'),
('fenix',      'El Fenix',            NULL, '14.00 – 24.00 WIB | Last Order 23.30', 'https://tikael.madamtikael.id/el_fenix.jpeg'),
('spaKG',      'El Spa Gading',       'https://g.co/kgs/boEFS4t', '12.00 – 00.00 WIB | Last Order 23.30', 'https://tikael.madamtikael.id/el_spa_kelapa_gading.jpeg'),
('orca',       'El Orca',             'https://g.co/kgs/uftGAAa', '13.00 – 24.00 WIB | Last Order 23.30', 'https://tikael.madamtikael.id/el_orca_new.jpeg'),
('casa',       'El Casa',             'https://g.co/kgs/JbtEvHK', '13.00 – 24.00 WIB | Last Order 23.30', 'https://tikael.madamtikael.id/el_casa.jpeg'),
('memento',    'El Memento',          'https://share.google/NkCFC2E5gQHcVXI7Y', '13.00 – 01.00 WIB | Last Order 00.30', 'https://tikael.madamtikael.id/el_memento.jpeg')
ON CONFLICT (outlet_key) DO UPDATE SET 
    name = EXCLUDED.name,
    location_url = EXCLUDED.location_url,
    operational_hours = EXCLUDED.operational_hours,
    pricelist_photo_url = EXCLUDED.pricelist_photo_url;

-- Seed Knowledge Base
INSERT INTO knowledge (category, question_pattern, answer_text, keywords) VALUES
('jamops', 'Jam Operasional / Jam Buka Outlet', 
'⏰ <b>Jam Operasional EL Group (Buka Setiap Hari 😘):</b>
📍 EL CENTRO: 14.00 – 01.00 WIB (Last Order: 00.30 WIB)
📍 EL SPA PANGJAY: 12.00 – 23.00 WIB (Last Order: 22.30 WIB)
📍 EL SEVEN CLUB: 18.00 – 04.00 WIB (Last Order: 03.30 WIB)
📍 EL NORTE: 12.00 – 24.00 WIB (Last Order: 23.30 WIB)
📍 EL FENIX: 14.00 – 24.00 WIB (Last Order: 23.30 WIB)
📍 EL SPA GADING: 12.00 – 00.00 WIB (Last Order: 23.30 WIB)
📍 EL ORCA: 13.00 – 24.00 WIB (Last Order: 23.30 WIB)
📍 EL CASA: 13.00 – 24.00 WIB (Last Order: 23.30 WIB)
📍 EL MEMENTO: 13.00 – 01.00 WIB (Last Order: 00.30 WIB)', 'jam, ops, buka, tutup, operasional, last order, hari ini buka'),

('donotdo', 'Peraturan dan Larangan (Do Not Do)', 
'⚠️ PERATURAN & KETENTUAN EL GROUP:
DILARANG:
1. Membawa/mengonsumsi narkoba & zat terlarang.
2. Membawa senjata tajam/senjata api.
3. Membawa makanan & minuman dari luar.
4. Merekam video/mengambil foto selama room service.
5. Memaksa terapis melakukan tindakan di luar SOP.
6. Merusak fasilitas atau membawa pulang inventaris kamar.

Sanksi pelanggaran: Pemutusan layanan tanpa refund, denda, dan BLACKLIST PERMANEN.', 'aturan, dilarang, larangan, rules, donotdo, narkoba, fasilitas'),

('applymember', 'Registrasi Member EL Group', 
'🪪 Registrasi Member EL Group:
Ada kak 😊
Untuk pendaftaran member resmi EL Group, silakan kirim data ke Telegram @spakaraoke.
Member digital resmi: https://app.elgroupapp.com/', 'member, membership, daftar, benefit, kartu member'),

('estafet', 'Paket Estafet', 
'🔥 New Package Additional - ESTAFET:
- Pilih 3 ladies platinum di lokasi langsung (tidak bisa book).
- Durasi total 90 menit (3x FJ).
- Ladies ke-1: 30 menit.
- Ladies ke-2: 30 menit.
- Ladies ke-3: 30 menit.', 'estafet, paket, ladies, platinum'),

('threesome', 'Paket Threesome', 
'💦 PAKET THREESOME (KAMAR):
1. Durasi 2 Jam: 2x FJ, Total 4 Voucher (1 Ladies 2 Voucher).
2. Durasi 1 Jam: 1x FJ, Total 2 Voucher (1 Ladies 1 Voucher).', 'threesome, 3some, voucher, kamar'),

('doublejackpot', 'Paket Double Jackpot', 
'🎰 DOUBLE JACKPOT (Khusus El Seven):
- Durasi 60 menit, 2x 💦 (1x FJ + 1x HJ).
- Note: All You Can F (90 menit, max 3 ladies 30 menit, khusus grade GOLD).', 'jackpot, double, gold, seven'),

('ktv', 'Paket Karaoke KTV, Party & Pool Spa', 
'🎤 PAKET KARAOKE KTV & PARTY (Tersedia di EL CENTRO, EL FENIX & EL MEMENTO):
- Karaoke Regular: 2 Voucher (Durasi 3 Jam: 2 jam KTV + 1 jam Room Service).
- Karaoke Party: 4 Voucher (Durasi 4 Jam: 2 jam KTV + 1 jam Party + 1 jam Room Service).
- Pool Spa: 3 Voucher (Durasi 4 Jam: 2 jam KTV + 1 jam Bikini + 1 jam Room Service).
- Close Voucher: 5 - 6 Voucher (Durasi hingga esok 12.00 am - 10.00 am).', 'ktv, karaoke, party, pool, bikini, room'),

('celeb', 'Aturan Booking Celeb / Price List Celeb', 
'⭐ ATURAN BOOKING CELEB:
1. Wajib booking H-1 (1 hari sebelumnya).
2. Wajib membayar DP (uang muka) 50%.
3. Bisa request di semua Outlet EL Group.', 'celeb, booking, dp, h-1, price list celeb'),

('promo', 'Informasi Promo, Diskon & Event Harian', 
'Ada kak 😊 Promo dan update harian selalu kami bagikan di Grup Telegram resmi kami!

🔗 Join Grup Telegram: https://t.me/spajakartavip

Silakan gabung agar tidak ketinggalan info diskon & promo terbaru ya kak ✨', 'promo, diskon, discount, potongan, event, promo hari ini, promo malam ini, voucher'),

('payment', 'Metode Pembayaran', 
'Bisa kak 😊
Kami menerima:
💵 Tunai
💳 Debit
💳 Kredit
📱 QRIS
💳 Member EL
Pembayaran dilakukan melalui kasir outlet.', 'payment, pembayaran, bayar, qris, transfer, cash, kartu, debit, kredit'),

('parkir', 'Informasi Area Parkir', 
'Ya kak 😊
Tersedia area parkir untuk kendaraan roda dua maupun roda empat.
Ketersediaan area parkir menyesuaikan kondisi di masing-masing outlet.', 'parkir, parkiran, mobil, motor, roda dua, roda empat'),

('walk_in', 'Datang Langsung / Walk-In Tanpa Reservasi', 
'Tentu bisa kak 😊
Namun kami sangat menyarankan melakukan reservasi terlebih dahulu agar room dan kebutuhan layanan dapat dipersiapkan.
Jika datang langsung tanpa reservasi, ketersediaan room dan layanan akan menyesuaikan kondisi yang tersedia di outlet saat kedatangan.
Untuk mendapatkan QR/Barcode, kakak bisa menghubungi:
@EL_Group1_Bot', 'walk-in, datang langsung, tanpa booking, tanpa reservasi'),

('contact', 'Master Kontak Booking & Routing Resmi', 
'RESERVASI & CONTACT BOOKING RESMI 🔗

💙 Madam Vita (Reservasi Seluruh Cabang EL Group)
WhatsApp: https://wa.me/6281312464177
Telegram: @spakaraoke

👩‍💻 CS Bot 24 Jam:
Telegram: @EL_Group1_Bot', 'contact, kontak, admin, vita, whatsapp, wa, telegram, booking, cs'),

('lost_item', 'Barang Tertinggal / Lost and Found',
'Jangan khawatir kak 😊
Silakan informasikan:
• Nama:
• Cabang:
• Tanggal kunjungan:
• Jam kunjungan:
• Barang yang tertinggal:
Kami akan membantu meneruskan informasi tersebut kepada tim outlet untuk pengecekan.', 'barang, ketinggalan, tertinggal, lost, found, hp, dompet, tas'),

('ktp', 'Persyaratan KTP / Identitas',
'Untuk kebutuhan tertentu, identitas dapat diperlukan sesuai kebijakan outlet.
Jika kakak ingin memastikan sebelum datang, silakan sebutkan outlet yang ingin dikunjungi, nanti kami bantu informasikan.', 'ktp, usia, identitas, umur, id'),

('rekomendasi_talent', 'Informasi, Rekomendasi & Ketersediaan Talent / LC / Ladies / Therapist (Handover Admin)',
'Mohon bersabar ya kak, untuk informasi & rekomendasi therapist/LC sudah kami teruskan dan akan segera diinfokan langsung oleh Madam Vita 🙏✨
[ESCALATE_QUESTION: Tanya Info/Rekomendasi Therapist/LC]', 'recomen, recomended, rekomendasi siapa, siapa yang bagus, siapa yang cantik, ladies bagus, therapist rekomen, siapa yg recomen, siapa recomended, rekomendasi ladies, rekomendasi therapist, siapa yang ready, siapa yang masuk, absen ladies, absen therapist, foto ladies, spill ladies, katalog ladies, lc bagus, lc rekomen, therapist gading, therapist centro, therapist norte, therapist fenix'),

('recruitment', 'Lowongan Kerja / Recruitment', 
'Saat ini kami menerima kandidat untuk posisi:
• LC
• Therapist
Jika berminat, silakan kirim:
📸 Foto terbaru
🎥 Video perkenalan
Setelah itu, kandidat yang sesuai dapat membuat janji untuk proses QC/interview.
Mohon membawa KTP asli saat datang untuk proses verifikasi.', 'lowongan, loker, lowongan kerja, recruitment, rekrutmen, mau kerja, apply kerja'),

('rules_sop', 'Rules Resmi & Akses Masuk Kedatangan',
'📋 PERATURAN & KETENTUAN RESMI EL GROUP:
1. Bagi yang mau datang ke semua outlet EL GROUP bisa langsung hubungi Madam Vita (@spakaraoke).
2. Tamu bisa pilih Ladies lewat foto atau showing pilih langsung di lokasi.
3. Dibutuhkan Reservasi & Barcode untuk akses masuk & akses lift setiap kali mau datang.
4. Barcode di-scan di security saat kedatangan dan sebutkan atas nama Madam Vita.', 'sop, barcode, lift, keamanan, security, reservasi, akses, rules, aturan'),

('sop_room_service', 'SOP Room Service Resmi EL Group By Madam Vita',
'⚠️ WAJIB IKUTI SOP ⚠️
Demi kenyamanan bersama 👍🏻

👑 SOP ROOM SERVICE (By Madam Vita):
1. 👣 Baby shower
2. 🪷 Massage relaxsasi sensual
3. 🤍 Body message (BM)
4. 🐾 Mandi kucing (MK)
5. 🥭 Petik mangga (PM)
6. 🤲✨ Hand job (HJ)
7. 💨 Blow job (BJ)
8. 💕 Fuck job (FJ)', 'sop, room service, layanan kamar, baby shower, massage, bm, mk, pm, hj, bj, fj, aturan room, rules, ketentuan'),

('pool', 'Fasilitas Pool, Kolam Panas Dingin & Paket Pool Spa KTV',
'Ada kak 😊 Fasilitas pool / kolam tersedia di:

🌊 <b>Kolam Spa & Berendam (Kolam Panas/Dingin & Sauna):</b>
• EL Spa Pangjay (Jakpus)
• EL Spa Gading (Jakut)
• EL Orca (Jakbar)
• EL Memento (Jaksel)

🎤 <b>Paket Pool Spa KTV (Karaoke 4 Jam + Bikini):</b>
• EL Centro (Jakpus)
• EL Fenix (Jakut)

Rencana mau ke cabang mana kak? Biar kami bantu siapkan 😊✨', 'pool, kolam, berendam, kolam renang, kolam panas, kolam dingin, whirlpool, sauna, steam, bikini'),

('layanan_options', 'Perbedaan Layanan LC, Ladies Drink & Therapist',
'Hai kak 👋 EL Group ada 3 pilihan layanan:
1. LC (Ladies Company): Karaoke + Private 60 mnt (Bisa karaoke terlebih dahulu dan bisa langsung Private Session 1 voucher durasi 60 menit)
2. Ladies Drink: Minum 30 mnt + Private 60 mnt (Temani minum selama 30 menit, bisa langsung private session durasi 60 menit. Khusus untuk Talent EL Seven saja)
3. Therapist: Berendam + Pijat + Private 90 mnt (Temani berendam di kolam & lanjut dipijat dahulu, kemudian dilanjutkan dengan private session durasi 90 menit di EL Spa)', 'layanan, beda, perbedaan, lc, drink, therapist, terapis, karaoke, spa'),

('fr_review', 'Testimoni & Field Report (FR) Tamu',
'Hai kak 😊
Nggak semua tamu memberikan feedback atau review karena sebagian tamu lebih memilih menjaga privacy.
Tapi kakak nggak perlu khawatir ya. Talent EL GROUP sudah berpengalaman dan mendapatkan training secara berkala.
Kami selalu berusaha menjaga standar pelayanan agar kakak merasa nyaman, aman, dan puas selama berada di EL GROUP.
Ditunggu kedatangannya di EL GROUP 😘', 'fr, review, field report, testimoni, masukan, feedback'),

('kesehatan_ladies', 'Kesehatan & Bebas HIV Talent EL Group',
'Kak tenang aja ya 🙏 Ladies eL Group semua sudah cek kesehatan & bebas HIV. Ada dokternya juga yang rutin cek. Jadi aman & nyaman kok 😃', 'sehat, hiv, penyakit, dokter, aman, kesehatan, ladies, terapis'),

('lokasi_cabang', 'Daftar Lokasi & Alamat Outlet EL Group',
'👥 <b>EL GROUP OUTLET</b> 💕🇮🇩
Spa Massage, Karaoke, Lounge, Bar, Club

📍 <b>EL CENTRO</b>
• EL Centro — Lt. 8
• EL Spa Pangjay — Lt. 3
• EL Seven Club — Lt. 2
📌 Lokasi: Hotel Maxwell, Jl. Pangjay No.40 Jakpus
🗺️ Maps: https://g.co/kgs/XsooJhR

📍 <b>EL FENIX</b>
• EL Fenix — Lt. 10
• EL Spa Gading — Lt. 9
📌 Lokasi: Tower Harton City Hub, Jl. Boulevard Artha Gading Jakut
🗺️ Maps: https://g.co/kgs/boEFS4t

📍 <b>EL SEVEN CLUB</b>
📌 Lokasi: Hotel Maxwell Lt. 2, Jl. Pangjay No.40 Jakpus
🗺️ Maps: https://g.co/kgs/XsooJhR

📍 <b>EL NORTE</b>
📌 Lokasi: Ruko Galery II Mediterania Blok N8-M8, Jl. Pantai Indah Kapuk, Jakut
🗺️ Maps: https://g.co/kgs/2x2ah1j

📍 <b>EL ORCA</b>
📌 Lokasi: Green Lake City, Ruko Food City No.122-123 Duri Kosambi, Cengkareng
🗺️ Maps: https://g.co/kgs/uftGAAa

📍 <b>EL CASA</b>
📌 Lokasi: Ruko Neo Arcade, Jl. CBD Gading No.1-2 Blok A, Tangerang
🗺️ Maps: https://g.co/kgs/JbtEvHK

📍 <b>EL MEMENTO</b>
📌 Lokasi: Tappalunia, Jl. Wijaya I No.21, Petogogan, Kec. Kebayoran Baru, Jaksel
🗺️ Maps: https://share.google/NkCFC2E5gQHcVXI7Y', 'lokasi, cabang, alamat, outlet, dimana, mana saja, berapa cabang, maps, hotel maxwell, pangjay, pik, kelapa gading, glc, gading serpong, jaksel');
