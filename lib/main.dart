import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Firebase connect karne ki koshish karo
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "YAHAN_API_KEY_LIKHEIN",
        authDomain: "YAHAN_AUTH_DOMAIN_LIKHEIN",
        projectId: "bfcablespos-1b3a7", 
        storageBucket: "YAHAN_STORAGE_BUCKET_LIKHEIN",
        messagingSenderId: "YAHAN_SENDER_ID_LIKHEIN",
        appId: "YAHAN_APP_ID_LIKHEIN",
      ),
    );
    
    // Agar connect ho jaye to app chalao
    runApp(const BFCablesApp());
    
  } catch (e) {
    // Agar connect NA ho (Error aa jaye) to yeh error screen dikhao
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Firebase Error:\n\n$e",
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      ),
    ));
  }
}

class BFCablesApp extends StatelessWidget {
  const BFCablesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BFCables POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFECF0F1),
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
    );
  }
}

// Main Screen with 4 Tabs
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const StockTab(),
    const CustomerTab(),
    const VendorTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BFCables POS", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF2C3E50),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Stock'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Vendors'),
        ],
      ),
    );
  }
}

// 1. Dashboard Tab
class DashboardTab extends StatelessWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Sales').orderBy('SyncedAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        var sales = snapshot.data!.docs;
        double totalAmount = 0;
        for (var sale in sales) {
          totalAmount += (sale['Total'] ?? 0).toDouble();
        }

        return Column(
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: totalAmount),
              duration: const Duration(seconds: 1),
              curve: Curves.easeOutCubic,
              builder: (context, double value, child) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(15),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Sales Amount", style: TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 10),
                      Text("Rs. ${value.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Align(alignment: Alignment.centerLeft, child: Text("Recent Bills", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)))),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: sales.length,
                itemBuilder: (context, index) {
                  var data = sales[index].data() as Map<String, dynamic>;
                  
                  return TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    curve: Curves.easeOut,
                    builder: (context, double value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InvoiceDetailScreen(invoiceData: data),
                            ),
                          );
                        },
                        leading: const Icon(Icons.receipt_long, color: Colors.blue),
                        title: Text("Invoice: ${data['InvoiceNo']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Customer: ${data['CustomerName']}\nDate: ${data['Date']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Rs. ${data['Total']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                            const SizedBox(width: 5),
                            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
// 2. Invoice Detail Screen (Jab bill par click ho)
class InvoiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> invoiceData;

  const InvoiceDetailScreen({Key? key, required this.invoiceData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> items = invoiceData['Items'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("Invoice: ${invoiceData['InvoiceNo']}"),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Customer: ${invoiceData['CustomerName']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(invoiceData['Date'], style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Amount:", style: TextStyle(fontSize: 16)),
                    Text("Rs. ${invoiceData['Total']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Paid Amount:", style: TextStyle(fontSize: 14, color: Colors.grey)),
                    Text("Rs. ${invoiceData['Paid']}", style: const TextStyle(fontSize: 14, color: Colors.blue)),
                  ],
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Items List", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            ),
          ),

          Expanded(
            child: items.isEmpty 
              ? const Center(child: Text("No items found for this invoice."))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    var item = items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent.withOpacity(0.1),
                          child: Text("${index + 1}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(item['ProductName'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Qty: ${item['Qty']} x Rs. ${item['UnitPrice']}"),
                        trailing: Text("Rs. ${item['Total']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 15)),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}

// 3. Stock Tab
class StockTab extends StatelessWidget {
  const StockTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var products = snapshot.data!.docs;
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            var data = products[index].data() as Map<String, dynamic>;
            double stock = (data['Stock'] ?? 0).toDouble();
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: ListTile(
                leading: Icon(Icons.inventory_2, color: stock > 10 ? Colors.green : Colors.red),
                title: Text(data['Name'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Sale Price: Rs. ${data['SalePrice']}"),
                trailing: Text("Stock: $stock", style: TextStyle(fontWeight: FontWeight.bold, color: stock > 10 ? Colors.green : Colors.red)),
              ),
            );
          },
        );
      },
    );
  }
}

// 4. Customers Tab
class CustomerTab extends StatelessWidget {
  const CustomerTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Customers').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var customers = snapshot.data!.docs;
        return ListView.builder(
          itemCount: customers.length,
          itemBuilder: (context, index) {
            var data = customers[index].data() as Map<String, dynamic>;
            double balance = (data['Balance'] ?? 0).toDouble();
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.person, color: Colors.white)),
                title: Text(data['Name'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Phone: ${data['Phone']}"),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Balance", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("Rs. ${balance.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold, color: balance > 0 ? Colors.red : Colors.green)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// 5. Vendors Tab
class VendorTab extends StatelessWidget {
  const VendorTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Vendors').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var vendors = snapshot.data!.docs;
        return ListView.builder(
          itemCount: vendors.length,
          itemBuilder: (context, index) {
            var data = vendors[index].data() as Map<String, dynamic>;
            double balance = (data['Balance'] ?? 0).toDouble();
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.local_shipping, color: Colors.white)),
                title: Text(data['Name'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Phone: ${data['Phone']}"),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Payable", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("Rs. ${balance.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold, color: balance > 0 ? Colors.red : Colors.green)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}