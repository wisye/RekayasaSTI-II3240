import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ndef/ndef.dart';
import 'package:reksti_app/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:reksti_app/screens/home_page.dart';
import 'package:reksti_app/screens/profile_page.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:encrypt/encrypt.dart' as encrypt_lib;

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  int _bottomNavIndex = 1;
  ValueNotifier<String> result = ValueNotifier(
    "Dekatkan perangkat ke tag NFC...",
  );
  bool _isScanning = false;
  NFCAvailability _nfcAvailability = NFCAvailability.not_supported;

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
  }

  Future<void> _checkNfcAvailability() async {
    try {
      NFCAvailability availability = await FlutterNfcKit.nfcAvailability;
      if (mounted) {
        setState(() {
          _nfcAvailability = availability;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _nfcAvailability = NFCAvailability.not_supported;
          result.value = "Error memeriksa NFC: ${e.toString()}";
        });
      }
    }
  }

  Future<void> _startNfcScan() async {
    if (_nfcAvailability != NFCAvailability.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'NFC tidak tersedia atau tidak aktif (${_nfcAvailability.name}).',
          ),
        ),
      );
      return;
    }
    if (_isScanning) {
      return;
    }

    setState(() {
      _isScanning = true;
      result.value = "Mendekati tag NFC...";
    });

    try {
      NFCTag tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 20),
        iosAlertMessage: "Dekatkan Smartphone ke tag NFC",
        readIso14443A: true,
      );

      if (mounted) {
        setState(() {
          result.value =
              "Tag terdeteksi!\nID: ${tag.id}\nType: ${tag.type}\nStandard: ${tag.standard}";
        });
      }

      String basicTagInfo =
          "Tag terdeteksi!\nID: ${tag.id}\nType: ${tag.type.name}\nStandard: ${tag.standard}\n";
      result.value = basicTagInfo + "Membaca data NDEF...";

      String extractedTextForEncryption = "";

      if (tag.ndefAvailable == true) {
        String ndefRecordsText = "Data NDEF:\n";

        var ndefRecords = await FlutterNfcKit.readNDEFRecords(cached: false);

        if (ndefRecords.isEmpty) {
          ndefRecordsText +=
              "Tidak ada record NDEF yang dapat dibaca atau tag kosong.";
        }

        for (var records in ndefRecords) {
          ndefRecordsText += "${records.toString()}\n";
          try {
            final int status = records.payload!.first;
            final int languageCodeLength = status & 0x3F;
            extractedTextForEncryption = String.fromCharCodes(
              records.payload!.sublist(1 + languageCodeLength),
            );
            result.value =
                basicTagInfo + "Data NDEF Text ditemukan. Mengenkripsi...";

            break;
          } catch (e) {
            print("Error parsing NDEF Text Record: $e");
          }
        }

        if (extractedTextForEncryption.isEmpty && ndefRecords.isNotEmpty) {
          result.value =
              basicTagInfo +
              "Tag NDEF ditemukan, tapi tidak ada Text Record utama yang bisa dienkripsi dengan mudah.";
        } else if (ndefRecords.isEmpty) {
          result.value = basicTagInfo + "Tag NDEF terdeteksi, tapi kosong.";
        }

        if (mounted) {
          setState(() {
            if (extractedTextForEncryption.isNotEmpty) {
              final encryptedData = EncryptionService.encryptData(
                extractedTextForEncryption,
              );

              result.value =
                  "Data Asli:\n$extractedTextForEncryption\n\nData Terenkripsi (Base64):\n$encryptedData";
            } else {
              result.value = ndefRecordsText;
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            result.value += "\nTag tidak disupport aplikasi...";
          });
        }
      }
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() {
          result.value =
              "Error NFC: ${e.message ?? 'Operasi dibatalkan atau gagal.'}";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          result.value = "Error NFC: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }

      try {
        await FlutterNfcKit.finish(iosAlertMessage: "Sesi NFC Selesai.");
      } catch (e) {}
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),

      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/home_img1.png',
                width: screenSize.width * 0.6,

                fit: BoxFit.contain,
                alignment: Alignment.topLeft,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (
                BuildContext context,
                BoxConstraints viewportConstraints,
              ) {
                return SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 20.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Panduan Melakukan\nPindahan Tags NFC',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: screenSize.height * 0.04),
                            _buildInstructionCard(),
                            SizedBox(height: screenSize.height * 0.025),

                            if (_nfcAvailability == NFCAvailability.available)
                              ElevatedButton.icon(
                                icon: Icon(
                                  _isScanning
                                      ? Icons.stop_circle_outlined
                                      : Icons.nfc,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  _isScanning
                                      ? 'Membaca Tag...'
                                      : 'Mulai Pindai NFC',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _isScanning
                                          ? Colors.orangeAccent[400]
                                          : Colors.deepPurple[400],
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                onPressed: _isScanning ? null : _startNfcScan,
                              )
                            else
                              Text(
                                "NFC Status: ${_nfcAvailability.name.replaceAll('_', ' ')}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.red[700],
                                ),
                              ),
                            const SizedBox(height: 20),
                            ValueListenableBuilder<String>(
                              valueListenable: result,
                              builder: (context, value, child) {
                                if (value.isEmpty ||
                                    value ==
                                            "Dekatkan perangkat ke tag NFC..." &&
                                        !_isScanning) {
                                  return Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      value.isEmpty && !_isScanning
                                          ? "Hasil scan akan muncul di sini."
                                          : value,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  );
                                }
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  margin: const EdgeInsets.only(
                                    top: 8.0,
                                    bottom: 20.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.25),
                                        spreadRadius: 1,
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    value,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 1.5,
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      decoration: BoxDecoration(
        color: Color(0xFFE8CDFD).withOpacity(0.10),
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Column(
        children: [
          _buildInstructionStep(
            icon: Icons.nfc,
            text: 'Aktifkan NFC pada perangkat \nAnda lewat Settings',
          ),
          SizedBox(height: 30),
          _buildInstructionStep(
            icon: Icons.discount,
            text:
                'Letakkan bagian belakang \nperangkat pada tag NFC \nyang ingin dibaca.',
          ),
          SizedBox(height: 30),
          _buildInstructionStep(
            icon: Icons.article,
            text: 'Baca informasi yang \nterkandung dalam tag \ntersebut',
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep({required IconData icon, required String text}) {
    return Column(
      children: [
        Icon(icon, size: 48, color: Color(0xFFB379DF)),
        const SizedBox(height: 12),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Color(0xFF594A75), height: 1.4),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    const double barHeight = 160;
    String currentNavBarImage;

    switch (_bottomNavIndex) {
      case 0:
        currentNavBarImage = 'assets/images/navbar1.png';
        break;
      case 1:
        currentNavBarImage = 'assets/images/navbar2.png';
        break;
      case 2:
        currentNavBarImage = 'assets/images/navbar3.png';
        break;
      default:
        currentNavBarImage = 'assets/images/navbar3.png';
    }

    return Container(
      height: barHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(currentNavBarImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.05),
              child: Container(),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() => _bottomNavIndex = 1);
              },
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.05),
              child: Container(),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.05),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

class EncryptionService {
  static final _keyString = "my32lengthsupersecretnooneknows1";
  static final _ivString = "my16lengthivneed";

  static final encrypt_lib.Key _key = encrypt_lib.Key.fromUtf8(_keyString);
  static final encrypt_lib.IV _iv = encrypt_lib.IV.fromUtf8(_ivString);

  static final _encrypter = encrypt_lib.Encrypter(
    encrypt_lib.AES(_key, mode: encrypt_lib.AESMode.cbc, padding: 'PKCS7'),
  );

  static String encryptData(String plainText) {
    if (plainText.isEmpty) return '';
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      return "Encryption Failed";
    }
  }

  static String decryptData(String base64EncryptedText) {
    if (base64EncryptedText.isEmpty ||
        base64EncryptedText == "Encryption Failed")
      return '';
    try {
      final encryptedObject = encrypt_lib.Encrypted.fromBase64(
        base64EncryptedText,
      );
      final decrypted = _encrypter.decrypt(encryptedObject, iv: _iv);
      return decrypted;
    } catch (e) {
      return "Decryption Failed";
    }
  }
}
