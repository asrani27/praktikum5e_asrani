import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List items = [];
  bool isLoading = true;

  String baseUrl = "http://localhost:8000/api/barang";

  @override
  void initState() {
    super.initState();
    fetchBarang();
  }

  // ==============================
  // GET DATA
  // ==============================
  Future<void> fetchBarang() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        setState(() {
          items = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print("Error GET: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Exception GET: $e");
      setState(() => isLoading = false);
    }
  }

  // ==============================
  // POST (TAMBAH BARANG)
  // ==============================
  Future<void> createBarang(String nama, int harga) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "nama": nama,
          "harga": harga,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        fetchBarang(); // Refresh data
      } else {
        print("Error POST: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception POST: $e");
    }
  }

  // ==============================
  // PUT (EDIT BARANG)
  // ==============================
  Future<void> updateBarang(int id, String nama, int harga) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/$id"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "nama": nama,
          "harga": harga,
        }),
      );

      if (response.statusCode == 200) {
        fetchBarang(); // Refresh data
      } else {
        print("Error PUT: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception PUT: $e");
    }
  }

  // ==============================
  // DELETE (HAPUS BARANG)
  // ==============================
  Future<void> deleteBarang(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$id"),
      );

      if (response.statusCode == 200) {
        fetchBarang();
      } else {
        print("Error DELETE: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception DELETE: $e");
    }
  }

  // ============================================================
  // DIALOG EDIT DATA (TERHUBUNG PUT / UPDATE API)
  // ============================================================
  void _showEditDialog(int index) {
    final barang = items[index];

    final TextEditingController nameController =
        TextEditingController(text: barang['nama']);
    final TextEditingController priceController =
        TextEditingController(text: barang['harga'].toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Edit Barang",
          style: TextStyle(color: Color(0xFF1976D2)),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nama Barang",
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: "Harga",
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              updateBarang(
                barang['id'],
                nameController.text,
                int.tryParse(priceController.text) ?? 0,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1976D2)),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIALOG TAMBAH DATA (POST API)
  // ============================================================
  void _showAddDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Tambah Barang",
          style: TextStyle(color: Color(0xFF1976D2)),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nama Barang",
                prefixIcon: Icon(Icons.inventory_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: "Harga",
                prefixIcon: Icon(Icons.attach_money_outlined),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              createBarang(
                nameController.text,
                int.tryParse(priceController.text) ?? 0,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1976D2)),
            child: const Text("Tambah"),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KONFIRMASI HAPUS DATA
  // ============================================================
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Barang?"),
        content: const Text("Data tidak bisa kembali setelah dihapus."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              deleteBarang(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text(
          "Dashboard Barang - ANDI 5E",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 2,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : items.isEmpty
                ? const Center(
                    child: Text(
                      "Belum ada barang.",
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final barang = items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF1976D2),
                            child: Icon(Icons.inventory, color: Colors.white),
                          ),
                          title: Text(
                            barang['nama'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                          subtitle: Text(
                            "Rp ${barang['harga']}",
                            style: const TextStyle(color: Colors.black54),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Color(0xFF1976D2)),
                                onPressed: () => _showEditDialog(index),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(barang['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF1976D2),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Tambah Barang",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
