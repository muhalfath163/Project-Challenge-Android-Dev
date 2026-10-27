import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study Jam Counter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Study Jam Counter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Map<String, int> _attendanceData = {};
  late String _selectedDate;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedDate = _formatDate(today);
    _attendanceData[_selectedDate] = 0;
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Fungsi bantuan untuk mempercantik tampilan tanggal di rekap (YYYY-MM-DD -> DD/MM/YYYY)
  String _displayDate(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length == 3) return "${parts[2]}/${parts[1]}/${parts[0]}";
    return dateStr;
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple.shade400,
              onPrimary: Colors.white,
              onSurface: Colors.deepPurple.shade900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate = _formatDate(picked);
      setState(() {
        _selectedDate = formattedDate;
        if (!_attendanceData.containsKey(_selectedDate)) {
          _attendanceData[_selectedDate] = 0;
        }
      });
    }
  }

  int get _currentCount => _attendanceData[_selectedDate] ?? 0;

  void _incrementCounter() {
    setState(() {
      _attendanceData[_selectedDate] = _currentCount + 1;
    });
  }

  void _decrementCounter() {
    if (_currentCount > 0) {
      setState(() {
        _attendanceData[_selectedDate] = _currentCount - 1;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kehadiran tidak bisa minus, bro!'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _resetCounter() {
    setState(() {
      _attendanceData[_selectedDate] = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data tanggal $_selectedDate berhasil di-reset'),
        backgroundColor: Colors.deepPurple.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // WIDGET BARU: Fungsi untuk menampilkan Rekap Data (Bottom Sheet)
  void _showAttendanceSummary(BuildContext context) {
    // Urutkan data dari tanggal terbaru ke terlama
    final sortedEntries = _attendanceData.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // Agar bisa ditarik ke atas jika datanya banyak
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6, // Tinggi panel 60% layar
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              // Drag handle (garis kecil di atas panel)
              const SizedBox(height: 12),
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              
              // Judul
              Text(
                'Rekap Kehadiran',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total ${_attendanceData.length} hari tercatat',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
              const Divider(height: 30, thickness: 1),

              // List Data
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: sortedEntries.length,
                  itemBuilder: (context, index) {
                    final entry = sortedEntries[index];
                    final isToday = entry.key == _formatDate(DateTime.now());
                    
                    return Card(
                      elevation: 0,
                      color: isToday ? Colors.deepPurple.shade50 : Colors.grey.shade50,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isToday ? Colors.deepPurple.shade200 : Colors.transparent,
                        )
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isToday ? Colors.deepPurple.shade100 : Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.calendar_month,
                            color: isToday ? Colors.deepPurple.shade700 : Colors.grey.shade600,
                          ),
                        ),
                        title: Text(
                          _displayDate(entry.key),
                          style: TextStyle(
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday ? Colors.deepPurple.shade900 : Colors.black87,
                          ),
                        ),
                        subtitle: isToday ? const Text('Hari Ini') : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${entry.value}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: entry.value > 0 ? Colors.green.shade600 : Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Hadir',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.deepPurple.shade900,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        actions: [
          // TOMBOL BARU: Ikon untuk membuka Rekap Data
          IconButton(
            icon: const Icon(Icons.format_list_bulleted),
            tooltip: 'Lihat Rekap Data',
            onPressed: () => _showAttendanceSummary(context),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade100,
              Colors.purple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  
                  // Gambar Anime
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      'https://i.pinimg.com/736x/3d/bb/ee/3dbbee4629fa0d902b849b40266571e2.jpg',
                      height: 170,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 170,
                          color: Colors.grey.shade200,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 170,
                          width: double.infinity,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Kartu Identitas
                  Card(
                    elevation: 6,
                    shadowColor: Colors.deepPurple.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.transparent,
                            backgroundImage: const NetworkImage(
                              'https://i.pinimg.com/736x/3b/96/2c/3b962c46211617a6e5b19752ba65a271.jpg',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Muhammad Alfath Irsyadul Huda',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'NIM: 255150319111002',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tombol Kalender
                  InkWell(
                    onTap: () => _pickDate(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.deepPurple.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_month, size: 18, color: Colors.deepPurple.shade400),
                          const SizedBox(width: 8),
                          Text(
                            _selectedDate,
                            style: TextStyle(
                              color: Colors.deepPurple.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down, color: Colors.deepPurple.shade400),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Kotak Angka Counter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.deepPurple.shade200, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.shade100,
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ]
                    ),
                    child: Text(
                      '$_currentCount',
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.w900,
                        color: Colors.deepPurple.shade700,
                        height: 1.1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Teks Status Dinamis
                  Text(
                    _currentCount == 0 
                        ? 'Belum ada yang hadir di tanggal ini' 
                        : '$_currentCount orang sudah diabsen',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tombol Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _decrementCounter,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                          elevation: 5,
                        ),
                        child: const Icon(Icons.remove, size: 32),
                      ),
                      const SizedBox(width: 30),
                      ElevatedButton(
                        onPressed: _incrementCounter,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade500,
                          foregroundColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                          elevation: 5,
                        ),
                        child: const Icon(Icons.add, size: 32),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Tombol Reset
                  TextButton.icon(
                    onPressed: _resetCounter,
                    icon: Icon(Icons.restart_alt, color: Colors.deepPurple.shade400, size: 20),
                    label: Text(
                      'Reset',
                      style: TextStyle(
                        color: Colors.deepPurple.shade400,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}