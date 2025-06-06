import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SyaratPage extends StatelessWidget {
  const SyaratPage({super.key});

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.6),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "  • ",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),

          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final Color pageBackgroundColor = Color(0xFFFAF4F5);
    final Color cardBackgroundColor = Color(0xFFE8CDFD);
    return Stack(
      children: [
        Container(color: pageBackgroundColor),

        Positioned(
          top: 0,
          left: 0,
          child: Opacity(
            opacity: 0.4,
            child: Image.asset(
              'assets/images/home_img1.png',
              width: screenSize.width * 0.7,
              height: screenSize.height * 0.4,
              fit: BoxFit.contain,
              alignment: Alignment.topLeft,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Syarat dan Ketentuan',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.08),
                      spreadRadius: 2,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildParagraph(
                      'Dengan menggunakan aplikasi SIMILIKITI, Anda setuju untuk mematuhi syarat dan ketentuan yang berlaku. Aplikasi ini hanya dapat digunakan oleh pengguna yang telah mendaftar dengan informasi yang akurat. Pengguna bertanggung jawab atas keamanan akun dan data pribadi mereka.',
                    ),

                    _buildSectionTitle('FUNGSI APLIKASI', context),

                    _buildBulletPoint(
                      'Verifikasi Obat: Verifikasi keaslian obat melalui NFC tag.',
                    ),
                    _buildBulletPoint(
                      'Pelacakan Distribusi: Melacak status pengiriman dan kondisi obat.',
                    ),
                    _buildBulletPoint(
                      'Laporan dan Audit: Membuat laporan untuk tujuan audit.',
                    ),

                    _buildSectionTitle('KEWAJIBAN PENGGUNA', context),
                    _buildBulletPoint(
                      'Gunakan aplikasi sesuai dengan hukum yang berlaku.',
                    ),
                    _buildBulletPoint(
                      'Jaga kerahasiaan akun dan data pribadi.',
                    ),
                    _buildBulletPoint(
                      'Setujui pengumpulan dan penggunaan data sesuai kebijakan privasi.',
                    ),

                    _buildSectionTitle('HAK KEPEMILIKAN DAN LISENSI', context),
                    _buildBulletPoint(
                      'Semua konten aplikasi dilindungi hak cipta.',
                    ),
                    _buildBulletPoint(
                      'Lisensi terbatas diberikan untuk menggunakan aplikasi.',
                    ),
                    const SizedBox(height: 40),
                    _buildParagraph(
                      'Aplikasi disediakan “sebagaimana adanya”, tanpa jaminan terkait ketersediaan atau performa, dan kami tidak bertanggung jawab atas gangguan atau downtime. Data pengguna akan diproses sesuai dengan kebijakan privasi, meskipun kami tidak dapat menjamin sepenuhnya keamanan data. Kami berhak untuk mengubah syarat dan ketentuan ini sewaktu-waktu, dengan pemberitahuan melalui aplikasi. Kami juga berhak membatasi atau menghentikan akses pengguna yang melanggar ketentuan. Syarat dan ketentuan ini diatur oleh hukum Indonesia, dan setiap perselisihan akan diselesaikan di pengadilan yang berwenang di Indonesia.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
