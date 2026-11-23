import 'package:flutter/material.dart';
import '../../database/app_database.dart';
import '../../services/academic_api_service.dart';
import '../common_widgets.dart';
import 'academic_widgets.dart';
class Pertemuan {
  final int nomor;
  final String topik;
  final String tanggal;
  final String? status; // null = belum ada absensi dari dosen
  final bool hasData;

  const Pertemuan({
    required this.nomor,
    required this.topik,
    required this.tanggal,
    this.status,
    this.hasData = false,
  });
}

class MataKuliahHadir {
  final String nama;
  final String jadwal;
  final List<Pertemuan> riwayat;

  const MataKuliahHadir({
    required this.nama,
    required this.jadwal,
    required this.riwayat,
  });
}

const List<String> daftarStatus = ['Hadir', 'Izin', 'Sakit', 'Alpa'];

const List<ListItem> pilihanMatkul = [
  ListItem(value: 0, name: 'Kecerdasan Buatan'),
  ListItem(value: 1, name: 'Pemrograman Web'),
  ListItem(value: 2, name: 'Basis Data Terdistribusi'),
  ListItem(value: 3, name: 'Keamanan Siber & Jaringan'),
  ListItem(value: 4, name: 'Rekayasa Perangkat Lunak'),
  ListItem(value: 5, name: 'Pemrograman Framework'),
  ListItem(value: 6, name: 'Statistika Komputasi'),
  ListItem(value: 7, name: 'Kewirausahaan'),
  ListItem(value: 8, name: 'UI/UX Design'),
  ListItem(value: 9, name: 'Internet of Things (IoT)'),
];

const List<MataKuliahHadir> dataKehadiran = [
  MataKuliahHadir(nama: 'Kecerdasan Buatan', jadwal: '14.00-15.20 Lantai 7, Ruangan 701', riwayat: []),
  MataKuliahHadir(nama: 'Pemrograman Web', jadwal: '08.00-10.00 Lantai 5, Ruang 502', riwayat: []),
  MataKuliahHadir(nama: 'Basis Data Terdistribusi', jadwal: '12.00-14.00 Lantai 6, Ruang 606', riwayat: []),
  MataKuliahHadir(nama: 'Keamanan Siber & Jaringan', jadwal: '10.00-12.00 Lab Keamanan, Lantai 4', riwayat: []),
  MataKuliahHadir(nama: 'Rekayasa Perangkat Lunak', jadwal: '08.00-10.30 Lantai 3, Ruang 304', riwayat: []),
  MataKuliahHadir(nama: 'Statistika Komputasi', jadwal: '13.30-15.00 Lantai 2, Ruang 201', riwayat: []),
  MataKuliahHadir(nama: 'Kewirausahaan', jadwal: '08.00-09.40 Lantai 4, Ruang 401', riwayat: []),
  MataKuliahHadir(nama: 'UI/UX Design', jadwal: '13.00-15.30 Lab Multimedia, Lantai 3', riwayat: []),
  MataKuliahHadir(nama: 'Internet of Things (IoT)', jadwal: '15.00-17.30 Lab Hardware & IoT, Lantai 5', riwayat: []),
  MataKuliahHadir(nama: 'Pemrograman Framework', jadwal: '10.20-13.00 Lantai 7, Ruangan 702', riwayat: []),
];

class KehadiranScreen extends StatefulWidget {
  final String? initialCourse;
  const KehadiranScreen({super.key, this.initialCourse});

  @override
  State<KehadiranScreen> createState() => _KehadiranScreenState();
}

class _KehadiranScreenState extends State<KehadiranScreen> {
  List<MataKuliahHadir> _listMatkul = List.from(dataKehadiran);
  List<ListItem> _dropdownItems = List.from(pilihanMatkul);
  late ListItem _selected;

  @override
  void initState() {
    super.initState();
    if (widget.initialCourse != null && widget.initialCourse!.isNotEmpty) {
      final idx = _dropdownItems.indexWhere((it) =>
          it.name.toLowerCase().contains(widget.initialCourse!.toLowerCase()) ||
          widget.initialCourse!.toLowerCase().contains(it.name.toLowerCase()));
      _selected = idx != -1 ? _dropdownItems[idx] : _dropdownItems.first;
    } else {
      _selected = _dropdownItems.first;
    }
    _loadFromDriftOrSeed();
    _refreshFromBackend();
  }

  Future<void> _loadFromDriftOrSeed() async {
    try {
      final cached = await AppDb.instance.getKehadiranFromDrift();
      if (cached.isNotEmpty) {
        _applyCachedData(cached);
      } else {
        final seedList = dataKehadiran.map((mk) => {
          'nama': mk.nama,
          'jadwal': mk.jadwal,
          'riwayat': mk.riwayat.map((p) => {
            'nomor': p.nomor,
            'topik': p.topik,
            'tanggal': p.tanggal,
            'status': p.status,
          }).toList(),
        }).toList();
        await AppDb.instance.saveKehadiranToDrift(seedList);
      }
    } catch (_) {}
  }

  void _applyCachedData(List<Map<String, dynamic>> cached) {
    final List<MataKuliahHadir> parsed = cached.map((c) {
      final riwayatList = (c['riwayat'] as List? ?? []).map((r) {
        final hasData = r['hasData'] == true || (r['status'] != null && r['status'].toString().isNotEmpty);
        return Pertemuan(
          nomor: r['nomor'] ?? 0,
          topik: 'Pertemuan ${r['nomor'] ?? 0}',
          tanggal: r['tanggal'] ?? '',
          status: hasData ? (r['status']?.toString()) : null,
          hasData: hasData,
        );
      }).toList();

      return MataKuliahHadir(
        nama: c['nama'] ?? '',
        jadwal: c['jadwal'] ?? '',
        riwayat: riwayatList,
      );
    }).toList();

    if (parsed.isNotEmpty && mounted) {
      setState(() {
        _listMatkul = parsed;
        _dropdownItems = List.generate(
          parsed.length,
          (i) => ListItem(value: i, name: parsed[i].nama),
        );
        if (widget.initialCourse != null && widget.initialCourse!.isNotEmpty) {
          final idx = _dropdownItems.indexWhere((it) =>
              it.name.toLowerCase().contains(widget.initialCourse!.toLowerCase()) ||
              widget.initialCourse!.toLowerCase().contains(it.name.toLowerCase()));
          if (idx != -1) {
            _selected = _dropdownItems[idx];
          } else if (_selected.value >= parsed.length) {
            _selected = _dropdownItems.first;
          } else {
            _selected = _dropdownItems[_selected.value];
          }
        } else if (_selected.value >= parsed.length) {
          _selected = _dropdownItems.first;
        } else {
          _selected = _dropdownItems[_selected.value];
        }
      });
    }
  }

  Future<void> _refreshFromBackend() async {
    try {
      final liveCourses = await AcademicApiService.fetchKehadiranCourses();
      if (liveCourses != null && liveCourses.isNotEmpty && mounted) {
        _applyCachedData(liveCourses);
        return;
      }
    } catch (_) {}

    final cached = await AppDb.instance.getKehadiranFromDrift();
    if (cached.isNotEmpty && mounted) {
      _applyCachedData(cached);
    }
  }

  int _hitung(MataKuliahHadir mk, String status) {
    int jumlah = 0;
    for (Pertemuan p in mk.riwayat) {
      if (p.hasData && p.status == status) {
        jumlah++;
      }
    }
    return jumlah;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? const Color(0xFF1E222A)
        : const Color(0xFFF7F9FC);

    final titleColor = isDark
        ? Colors.white
        : const Color(0xFF0F172A);

    final cardBg = isDark
        ? const Color(0xFF282D37)
        : Colors.white;

    final safeIndex = _selected.value.clamp(0, _listMatkul.isNotEmpty ? _listMatkul.length - 1 : 0);
    MataKuliahHadir mk = _listMatkul.isNotEmpty ? _listMatkul[safeIndex] : dataKehadiran[0];

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const BackHeaderBar(title: 'Kehadiran'),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshFromBackend,
              color: const Color(0xFF2563EB),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  YellowDropdown(
                    items: _dropdownItems,
                    selectedItem: _selected,
                    onChanged: (ListItem? value) {
                      if (value != null) {
                        setState(() {
                          _selected = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    mk.nama,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 13,
                        color: isDark
                            ? const Color(0xFF9AA4B8)
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        mk.jadwal,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF9AA4B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildRingkasan(mk, isDark, cardBg),
                  const SizedBox(height: 24),
                  _buildRiwayat(mk, isDark, cardBg, titleColor),
                  const SizedBox(height: 24),
                ],
              ),
              ),
            ),
          ),
          const BottomBar(currentIndex: 1),
        ],
      ),
    );
  }

  Widget _buildRingkasan(
    MataKuliahHadir mk,
    bool isDark,
    Color cardBg,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? const Color(0xFF3B4555)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.16 : 0.04,
            ),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ringkasan Presensi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? Colors.white
                      : const Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF323B4C)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${mk.riwayat.where((p) => p.hasData).length} Pertemuan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? const Color(0xFF93C5FD)
                        : const Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: daftarStatus.map((s) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _CountTile(
                    label: s,
                    jumlah: _hitung(mk, s),
                    isDark: isDark,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayat(
    MataKuliahHadir mk,
    bool isDark,
    Color cardBg,
    Color titleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Pertemuan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: titleColor,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              'Selesai',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFF93C5FD)
                    : const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Builder(
          builder: (_) {
            final adaAbsensi = mk.riwayat.any((p) => p.hasData);
            if (!adaAbsensi) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? const Color(0xFF3B4555) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy_rounded,
                      size: 40,
                      color: isDark ? const Color(0xFF4B5563) : const Color(0xFFCBD5E1),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Belum ada absensi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF6B7280) : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dosen belum menginput kehadiran untuk matkul ini',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF4B5563) : const Color(0xFFCBD5E1),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: mk.riwayat
                  .where((p) => p.hasData)
                  .map((p) => _RiwayatTile(pertemuan: p, isDark: isDark, cardBg: cardBg))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _CountTile extends StatelessWidget {
  final String label;
  final int jumlah;
  final bool isDark;

  const _CountTile({
    required this.label,
    required this.jumlah,
    required this.isDark,
  });

  Color _getStatusThemeColor(String status) {
    switch (status) {
      case 'Hadir':
        return isDark
            ? const Color(0xFF34D399)
            : const Color(0xFF10B981);
      case 'Izin':
        return isDark
            ? const Color(0xFFFBBF24)
            : const Color(0xFFF59E0B);
      case 'Sakit':
        return isDark
            ? const Color(0xFF60A5FA)
            : const Color(0xFF0284C7);
      case 'Alpa':
        return isDark
            ? const Color(0xFFF87171)
            : const Color(0xFFEF4444);
      default:
        return isDark
            ? const Color(0xFF9AA4B8)
            : const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = _getStatusThemeColor(label);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: themeColor.withValues(
          alpha: isDark ? 0.12 : 0.08,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeColor.withValues(
            alpha: isDark ? 0.4 : 0.3,
          ),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            '$jumlah',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: themeColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiwayatTile extends StatelessWidget {
  final Pertemuan pertemuan;
  final bool isDark;
  final Color cardBg;

  const _RiwayatTile({
    required this.pertemuan,
    required this.isDark,
    required this.cardBg,
  });

  Color _statusColor(String? status) {
    switch (status) {
      case 'Hadir':
        return isDark
            ? const Color(0xFF34D399)
            : const Color(0xFF10B981);
      case 'Izin':
        return isDark
            ? const Color(0xFFFBBF24)
            : const Color(0xFFF59E0B);
      case 'Sakit':
        return isDark
            ? const Color(0xFF60A5FA)
            : const Color(0xFF0284C7);
      case 'Alpa':
        return isDark
            ? const Color(0xFFF87171)
            : const Color(0xFFEF4444);
      default:
        return isDark
            ? const Color(0xFF9AA4B8)
            : const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(pertemuan.status ?? '-');
    final statusLabel = pertemuan.status ?? '-';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? const Color(0xFF3B4555)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.14 : 0.03,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2563EB).withValues(alpha: 0.35)
                  : const Color(0xFF2563EB).withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? const Color(0xFF60A5FA).withValues(alpha: 0.7)
                    : const Color(0xFFBFDBFE),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Text(
                '${pertemuan.nomor}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? const Color(0xFF93C5FD)
                      : const Color(0xFF2563EB),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pertemuan.topik,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? Colors.white
                        : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  pertemuan.tanggal,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? const Color(0xFF9AA4B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(
                alpha: isDark ? 0.12 : 0.08,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: statusColor.withValues(
                  alpha: isDark ? 0.4 : 0.3,
                ),
                width: 1,
              ),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
