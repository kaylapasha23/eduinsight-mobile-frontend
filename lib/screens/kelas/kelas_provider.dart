import 'package:flutter/material.dart';

/// Keys are formatted as "ClassName|TaskTitle"
class KelasProvider extends ChangeNotifier {
  // Tasks that were originally "selesai" (pre-submitted mock data)
  final Set<String> _initiallyCompleted = {
    'UI/UX|CBL 2: Low-Fidelity',
    'Statistika dan Data|Quizziz Matriks',
    'Kecerdasan Buatan|AI Klasik dan Modern',
    'Pemrograman Web|Tipe Data dan Method',
    'IoT|Pertemuan Pertama IoT',
    'Pemrograman Web|Pertemuan Pertama Pemweb',
    'Sistem Informasi|Pertemuan Pertama Sistem Informasi',
  };

  // Tasks the user manually marked as selesai
  final Set<String> _userCompleted = {};

  // Tasks that have a document uploaded (but not yet marked selesai)
  final Set<String> _docUploaded = {};

  Set<String> get completedKeys => {..._initiallyCompleted, ..._userCompleted};

  bool isCompleted(String key) => completedKeys.contains(key);
  bool isInitiallyCompleted(String key) => _initiallyCompleted.contains(key);
  bool hasDoc(String key) => _docUploaded.contains(key) || _initiallyCompleted.contains(key);

  int get selesaiCount => completedKeys.length;
  int get segeraCount => 3 - _userCompleted.length; // 3 initial segera tasks

  void uploadDoc(String key) {
    _docUploaded.add(key);
    _userCompleted.add(key); // When user uploads doc, it marks task as submitted
    notifyListeners();
  }

  void markComplete(String key) {
    _userCompleted.add(key); // Marked complete without attaching document
    notifyListeners();
  }

  void cancelSubmission(String key) {
    _initiallyCompleted.remove(key);
    _userCompleted.remove(key);
    _docUploaded.remove(key);
    notifyListeners();
  }

  String mockFileName(String key) {
    if (key.contains('Quizziz')) return 'Screenshot_Skor.png';
    if (key.contains('Low-Fidelity')) return 'Wireframe_LowFidelity.pdf';
    if (key.contains('JavaScript')) return 'PengenalanJS.zip';
    if (key.contains('Node.js')) return 'Screenshot_NodeVersion.png';
    if (key.contains('Sejarah')) return 'SejarahKomputer.pdf';
    if (key.contains('AI Klasik')) return 'AIKlasikModern.pdf';
    if (key.contains('Tipe Data')) return 'TipeDataMethod.js';
    if (key.contains('Pertama IoT')) return 'CatatanIoT.pdf';
    if (key.contains('Pertama Pemweb')) return 'CatatanPemweb.pdf';
    if (key.contains('Pertama Sistem')) return 'CatatanSisffo.pdf';
    return 'Dokumen_Tugas.pdf';
  }
}
