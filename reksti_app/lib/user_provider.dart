import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reksti_app/model/Shipment.dart';
import 'dart:convert';

import 'package:reksti_app/services/token_service.dart';
import 'package:reksti_app/services/logic_service.dart';

class UserProvider with ChangeNotifier {
  String? _profileRecipientName;
  String? _profileRecipientAddress;
  File? _profileImageFile;
  bool _isLoadingProfile = false;
  String _profileError = '';
  final _logicService = LogicService();
  final TokenStorageService tokenStorage = TokenStorageService();

  bool _hasFetchedInitialData = false;

  String? get profileRecipientName => _profileRecipientName;
  String? get profileRecipientAddress => _profileRecipientAddress;
  File? get profileImageFile => _profileImageFile;

  bool get isLoadingProfile => _isLoadingProfile;
  String get profileError => _profileError;

  UserProvider() {
    loadUserData();
  }

  Future<void> loadUserData({bool forceRefresh = false}) async {
    if ((_isLoadingProfile) && !forceRefresh) {
      return;
    }

    if (_hasFetchedInitialData && !forceRefresh) {
      if (_isLoadingProfile) {
        _isLoadingProfile = false;

        notifyListeners();
      }
      return;
    }

    _isLoadingProfile = true;

    _profileError = '';

    notifyListeners();

    try {
      final List<dynamic> rawShipmentData = await _logicService.getOrder();

      if (rawShipmentData.isNotEmpty) {
        final Shipment firstShipmentData = Shipment.fromJson(
          rawShipmentData.first as Map<String, dynamic>,
        );

        _profileRecipientAddress = firstShipmentData.recipientAddress;

        final List<Shipment> shipments =
            rawShipmentData.map((data) => Shipment.fromJson(data)).toList();
        List<ShipmentItem> allItems = [];
        for (var shipment in shipments) {
          allItems.addAll(shipment.items);
        }
      }
      final List<Shipment> shipments =
          rawShipmentData.map((data) => Shipment.fromJson(data)).toList();
      List<ShipmentItem> allItems = [];
      for (var shipment in shipments) {
        allItems.addAll(shipment.items);
      }

      _profileRecipientName = await tokenStorage.getUsername();
      await _loadPersistedProfileImage();
      _hasFetchedInitialData = true;
    } catch (e) {
      _profileError = "Gagal memuat data profil: ${e.toString()}";

      _hasFetchedInitialData = false;
    } finally {
      _isLoadingProfile = false;

      notifyListeners();
    }
  }

  Future<void> initializeSession() async {
    String? username = await tokenStorage.getUsername();
    print(
      "UserProvider DEBUG: initializeSession - username from tokenStorage: $username",
    );
    if (username != null && username.isNotEmpty) {
      print(
        "UserProvider: Session found for $username. Initializing and loading data.",
      );
      if (_profileRecipientName != username || !_hasFetchedInitialData) {
        await loadUserData(forceRefresh: false);
      } else {
        print(
          "UserProvider: Data for $username already loaded in this session.",
        );
        if (_isLoadingProfile) {
          _isLoadingProfile = false;

          notifyListeners();
        }
      }
    } else {
      notifyListeners();
    }
  }

  Future<void> _loadPersistedProfileImage() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String userPrefix = "${_profileRecipientName}_";

      List<FileSystemEntity> files = appDir.listSync();
      List<File> userImageFiles = [];

      for (var entity in files) {
        if (entity is File) {
          final String fileName = p.basename(entity.path);
          if (fileName.startsWith(userPrefix) && fileName.endsWith(".jpg")) {
            userImageFiles.add(entity);
          }
        }
      }

      if (userImageFiles.isEmpty) {
        _profileImageFile = null;

        return;
      }

      userImageFiles.sort((a, b) {
        try {
          String tsAString = p
              .basename(a.path)
              .replaceAll(userPrefix, '')
              .replaceAll('.jpg', '');
          String tsBString = p
              .basename(b.path)
              .replaceAll(userPrefix, '')
              .replaceAll('.jpg', '');
          int tsA = int.tryParse(tsAString) ?? 0;
          int tsB = int.tryParse(tsBString) ?? 0;
          return tsB.compareTo(tsA);
        } catch (e) {
          return 0;
        }
      });

      _profileImageFile = userImageFiles.first;
    } catch (e) {
      _profileImageFile = null;
    }
  }

  Future<String?> pickAndSaveProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    String? newImagePath;
    final Directory appDir = await getApplicationDocumentsDirectory();

    if (pickedImage != null) {
      final File imageFile = File(pickedImage.path);

      try {
        final String fileName =
            '${_profileRecipientName}_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final String localPath = p.join(appDir.path, fileName);

        final File newImage = await imageFile.copy(localPath);

        _profileImageFile = newImage;
        newImagePath = newImage.path;
        _profileError = '';

        notifyListeners();
        return newImagePath;
      } catch (e) {
        _profileError = "Gagal menyimpan gambar: ${e.toString()}";
        notifyListeners();
        return null;
      }
    } else {
      return null;
    }
  }

  Future<void> clearProfileDataOnLogout() async {
    await tokenStorage.deleteAllTokens();
    _profileImageFile = null;
    _profileRecipientName = null;
    _profileRecipientAddress = null;
    _profileError = '';
    _isLoadingProfile = false;
    _hasFetchedInitialData = false;

    print("UserProfileProvider: Profile data cleared for logout.");
    notifyListeners();
  }
}
