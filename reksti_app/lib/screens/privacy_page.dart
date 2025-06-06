import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

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
              'Privacy Policy',
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
                      'Kami di SIMILIKITI berkomitmen untuk melindungi privasi Anda. Kebijakan ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi data pribadi Anda.',
                    ),

                    _buildSectionTitle(
                      '1. Informasi yang Kami Kumpulkan',
                      context,
                    ),

                    _buildParagraph(
                      'Kami mengumpulkan data pribadi yang Anda berikan saat mendaftar, seperti nama, email, dan informasi terkait verifikasi obat (misalnya, data NFC), serta informasi teknis seperti perangkat yang digunakan dan data penggunaan aplikasi.',
                    ),
                    _buildSectionTitle('2. Penggunaan Informasi', context),

                    _buildParagraph(
                      'Informasi yang kami kumpulkan digunakan untuk menyediakan layanan seperti verifikasi obat, pelacakan distribusi, dan pembuatan laporan. Kami juga menggunakan data untuk meningkatkan kinerja aplikasi dan memberikan dukungan pelanggan.',
                    ),

                    _buildSectionTitle('3. Keamanan Data', context),
                    _buildParagraph(
                      ' Kami menerapkan langkah-langkah keamanan untuk melindungi data Anda dari akses yang tidak sah. Namun, kami tidak dapat menjamin keamanan penuh atas data yang dikirimkan melalui internet.',
                    ),
                    _buildSectionTitle('4. Berbagi Informasi', context),
                    _buildParagraph(
                      'Kami tidak membagikan informasi pribadi Anda dengan pihak ketiga, kecuali untuk memenuhi kewajiban hukum atau dengan izin Anda. Data dapat dibagikan dengan mitra yang mendukung layanan kami.',
                    ),
                    _buildSectionTitle('5. Perubahan Kebijakan', context),
                    _buildParagraph(
                      'Kami dapat memperbarui kebijakan ini. Perubahan akan diberitahukan melalui aplikasi atau email, dan berlaku segera setelah diposting.',
                    ),

                    _buildSectionTitle('7. Kontak Kami', context),
                    _buildParagraph(
                      'Jika Anda memiliki pertanyaan atau ingin mengakses/memperbarui data pribadi Anda, silakan hubungi kami di similikiti@gmail.com.',
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
