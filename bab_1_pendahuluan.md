# BAB 1: PENDAHULUAN

## 1.1 Latar Belakang
Pengelolaan keluhan dan permasalahan teknis (*IT support*) dalam suatu organisasi sering kali dilakukan secara manual, baik melalui komunikasi lisan, pesan singkat, maupun surat elektronik yang tidak terstruktur. Pendekatan konvensional tersebut menyulitkan proses pelacakan status penyelesaian masalah, pendistribusian beban kerja petugas, serta pendokumentasian riwayat penanganan suatu kasus. Akibatnya, baik pengguna yang melaporkan masalah, petugas yang menangani, maupun pihak manajemen yang mengawasi proses tersebut kesulitan memperoleh gambaran yang jelas mengenai status dan riwayat suatu laporan kendala.

Untuk mengatasi permasalahan tersebut, dibutuhkan suatu sistem *E-Ticketing* yang mampu menampung proses pelaporan, penugasan, pemantauan, dan penyelesaian tiket secara terpusat dan *real-time*. Aplikasi **Helpdesk Ticket** dikembangkan sebagai jawaban atas kebutuhan tersebut, dengan menghadirkan tiga peran pengguna yang berbeda yaitu *User* (pelapor), *Helpdesk Agent* (penangani), dan *Administrator* (pengawas sistem), sehingga setiap pihak memiliki akses dan tanggung jawab yang sesuai dengan perannya masing-masing.

Dari sisi teknologi, aplikasi ini dibangun menggunakan framework **Flutter** sebagai kerangka kerja *front-end* lintas platform dan **Supabase** sebagai layanan backend (*Backend-as-a-Service* / BaaS) yang menyediakan basis data PostgreSQL, autentikasi, penyimpanan berkas, dan kemampuan pembaruan data secara *real-time*. Kombinasi teknologi ini memungkinkan aplikasi berjalan secara online sepenuhnya tanpa mengandalkan basis data lokal, sehingga seluruh data tiket, riwayat perubahan, komentar diskusi, dan notifikasi tersinkronisasi secara langsung antar pengguna.

Laporan ini disusun berdasarkan hasil audit menyeluruh terhadap kode sumber aplikasi **Helpdesk Ticket**, yang mencakup struktur proyek, fitur, alur sistem, antarmuka pengguna, backend, dan skema basis data, sebagai bahan dokumentasi resmi untuk keperluan Ujian Akhir Semester (UAS).

---

## 1.2 Rumusan Masalah
Berdasarkan latar belakang di atas, rumusan masalah dalam pengembangan dan audit sistem ini adalah sebagai berikut:
1. Bagaimana merancang dan membangun sistem pelaporan tiket helpdesk berbasis mobile menggunakan Flutter dan Supabase yang mendukung otorisasi tiga peran pengguna (*User*, *Helpdesk*, *Admin*) secara aman?
2. Bagaimana mengimplementasikan sistem autentikasi, manajemen sesi pengguna, dan kontrol status aktif akun menggunakan *Supabase Authentication* dan tabel profil relasional?
3. Bagaimana merancang alur kerja pengerjaan tiket (*ticket lifecycle*) serta pencatatan audit log riwayat perubahan status tiket secara kronologis?
4. Bagaimana menerapkan mekanisme sinkronisasi obrolan diskusi dan pengiriman notifikasi instan secara *real-time* memanfaatkan fitur *PostgreSQL Realtime Stream* di Supabase?

---

## 1.3 Tujuan
Tujuan dari penulisan laporan dan pengembangan aplikasi ini adalah:
1. Mendokumentasikan secara menyeluruh arsitektur, fitur, dan alur kerja aplikasi **Helpdesk Ticket** berdasarkan hasil audit kode sumber.
2. Menjelaskan peran, hak akses, dan batas fungsionalitas (*Role-Based Access Control*) dari tiga jenis pengguna, yaitu *User*, *Helpdesk Agent*, dan *Administrator*.
3. Menjabarkan setiap layar antarmuka pengguna (UI/UX) aplikasi beserta fungsi, komponen desain, dan alur navigasi adaptifnya.
4. Menjelaskan proses integrasi backend yang menghubungkan aplikasi Flutter dengan layanan Supabase, khususnya fitur autentikasi, penyimpanan file lampiran, dan database real-time.
5. Mendeskripsikan struktur basis data relasional beserta skema relasi antar tabel (*Entity Relationship Diagram*) yang digunakan dalam sistem helpdesk.

---

## 1.4 Manfaat
Pengembangan aplikasi **Helpdesk Ticket** ini diharapkan dapat memberikan manfaat dari berbagai sudut pandang berikut:

### 1. Manfaat bagi User (Pelapor)
- **Kemudahan Pelaporan**: Mempermudah pengajuan tiket keluhan teknis kapan saja dan di mana saja melalui perangkat mobile dengan formulir yang terstruktur serta dukungan lampiran gambar bukti kendala.
- **Transparansi Proses**: Memberikan kejelasan pemantauan status penanganan tiket secara langsung (*real-time*), sehingga pengguna mengetahui petugas yang sedang menangani keluhan mereka.
- **Komunikasi Dua Arah**: Memfasilitasi media diskusi terintegrasi pada detail tiket untuk memberikan penjelasan tambahan kepada petugas tanpa memerlukan media komunikasi eksternal.

### 2. Manfaat bagi Helpdesk Agent (Petugas IT)
- **Fokus Kerja**: Mempermudah pengelolaan daftar tugas karena sistem hanya menampilkan dan memprioritaskan tiket yang secara spesifik ditugaskan kepada agen bersangkutan.
- **Efisiensi Update**: Memudahkan pembaruan status kemajuan pengerjaan tiket secara sistematis (*Open, Process, Pending, Done, Closed*).
- **Dokumentasi Diskusi**: Menyimpan riwayat komunikasi dengan pelapor secara terpusat pada tiket yang bersangkutan sebagai bahan evaluasi pengerjaan.

### 3. Manfaat bagi Administrator (Manajemen/Pengawas)
- **Pengawasan Menyeluruh**: Mempermudah pengawasan seluruh kinerja sistem helpdesk melalui dasbor statistik tiket (tiket masuk, tiket dalam pengerjaan, dan tiket selesai).
- **Manajemen Sumber Daya**: Memudahkan alokasi dan distribusi beban kerja secara adil dengan fitur penunjukan agen helpdesk (*ticket assignment*).
- **Keamanan Sistem**: Menyediakan kendali penuh atas manajemen akun pengguna, termasuk penentuan peran (*role*) dan penonaktifan akun (*deactivation*) yang tidak aktif atau bermasalah.

### 4. Manfaat Akademis
- **Penerapan Teori**: Sebagai sarana penerapan ilmu pemrograman perangkat bergerak (*mobile application development*) dan integrasi arsitektur cloud menggunakan pendekatan *Backend-as-a-Service* (BaaS).
- **Pemahaman Clean Architecture**: Meningkatkan pemahaman praktis mengenai pemisahan lapisan data (*data layer*) dan tampilan (*presentation layer*) menggunakan pola desain *Clean Architecture* dan state management *Provider* pada Flutter.
- **Dokumentasi Proyek**: Melatih kemampuan menyusun laporan teknis yang komprehensif mulai dari analisis kode sumber hingga struktur database relasional sebagai bekal di industri profesional.
