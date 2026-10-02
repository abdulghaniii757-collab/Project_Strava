import 'package:flutter/material.dart';

const _orange = Color(0xFFFC4C02);
const _bg = Color(0xFF121212);
const _card = Color(0xFF1E1E1E);
const _muted = Color(0xFFA0A0A0);

class _Faq {
  const _Faq(this.icon, this.question, this.answer);

  final IconData icon;
  final String question;
  final String answer;
}

const _faqs = [
  _Faq(
    Icons.add_circle_outline,
    'Gimana cara mencatat aktivitas?',
    'Tekan tombol + (oranye) di bawah layar atau di pojok kiri atas halaman '
        'Profil. Isi nama, jenis olahraga, jarak, durasi, dan tanggal, lalu simpan.',
  ),
  _Faq(
    Icons.edit_outlined,
    'Gimana cara edit atau hapus aktivitas?',
    'Buka tab Aktivitas di Profil, pilih aktivitasnya, lalu pakai tombol edit '
        'atau hapus di halaman detail.',
  ),
  _Faq(
    Icons.search,
    'Gimana cara mencari aktivitas lama?',
    'Tekan ikon kaca pembesar di halaman Profil, lalu ketik nama atau jenis '
        'aktivitas (misal "Sepeda").',
  ),
  _Faq(
    Icons.photo_camera_outlined,
    'Gimana cara ganti foto profil?',
    'Ketuk foto atau inisial namamu di Profil, lalu pilih Ambil Foto atau Pilih '
        'dari Galeri. Fotonya juga bisa dihapus dari menu yang sama.',
  ),
  _Faq(
    Icons.flag_outlined,
    'Apa itu Target Mingguan?',
    'Target jarak yang mau kamu capai tiap minggu (Senin–Minggu). Ubah lewat '
        'tombol "Ubah" di kartu Target Mingguan atau dari Pengaturan.',
  ),
  _Faq(
    Icons.local_fire_department_outlined,
    'Gimana Beruntun dihitung?',
    'Beruntun adalah jumlah minggu berturut-turut yang punya minimal satu '
        'aktivitas. Kalau minggu ini belum ada aktivitas, hitungan mulai dari '
        'minggu lalu.',
  ),
  _Faq(
    Icons.military_tech_outlined,
    'Gimana cara membuka lencana?',
    'Lencana terbuka otomatis waktu syaratnya terpenuhi, misal total jarak 50 km '
        'atau 10 aktivitas. Ketuk lencana untuk lihat syaratnya.',
  ),
  _Faq(
    Icons.checkroom,
    'Apa gunanya Perlengkapan?',
    'Untuk mencatat sepatu atau sepeda yang kamu pakai. Total jaraknya dihitung '
        'dari semua aktivitas dengan jenis olahraga yang sama.',
  ),
  _Faq(
    Icons.storage_outlined,
    'Datanya disimpan di mana?',
    'Semua data disimpan di perangkat ini saja. Data hilang kalau aplikasi '
        'di-uninstall atau kalau kamu pilih "Reset semua data" di Pengaturan.',
  ),
];

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        title: const Text('Bantuan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Pertanyaan yang sering ditanyakan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: _card,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: Theme(
              // hilangin garis bawaan ExpansionTile waktu dibuka
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: Column(
                children: [
                  for (var i = 0; i < _faqs.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: Color(0xFF2E2E2E)),
                    ExpansionTile(
                      leading: Icon(_faqs[i].icon, color: _orange),
                      title: Text(
                        _faqs[i].question,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      iconColor: _orange,
                      collapsedIconColor: _muted,
                      childrenPadding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
                      expandedAlignment: Alignment.centerLeft,
                      children: [
                        Text(
                          _faqs[i].answer,
                          style: const TextStyle(color: _muted, height: 1.4),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
