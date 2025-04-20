import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const FinanceWalletApp());

class FinanceWalletApp extends StatelessWidget {
  const FinanceWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Wallet',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> transactions = [];

  String selectedCurrency = "₺";
  String selectedLanguage = "tr";

  final Map<String, Map<String, String>> localizedText = {
    "tr": {
      "title": "FinanceWallet",
      "expense": "Gider",
      "income": "Gelir",
      "balance": "Bakiye",
      "addTransaction": "İşlem Ekle",
      "description": "Açıklama",
      "date": "Tarih",
      "amount": "Tutar",
      "save": "Kaydet",
      "currencySelect": "Para Birimi Seç",
      "languageSelect": "Dil Seç",
    },
    "en": {
      "title": "FinanceWallet",
      "expense": "Expense",
      "income": "Income",
      "balance": "Balance",
      "addTransaction": "Add Transaction",
      "description": "Description",
      "date": "Date",
      "amount": "Amount",
      "save": "Save",
      "currencySelect": "Select Currency",
      "languageSelect": "Select Language",
    },
    "de": {
      "title": "FinanzWallet",
      "expense": "Ausgabe",
      "income": "Einnahme",
      "balance": "Kontostand",
      "addTransaction": "Transaktion hinzufügen",
      "description": "Beschreibung",
      "date": "Datum",
      "amount": "Betrag",
      "save": "Speichern",
      "currencySelect": "Währung wählen",
      "languageSelect": "Sprache wählen",
    },
    "fr": {
      "title": "Portefeuille",
      "expense": "Dépense",
      "income": "Revenu",
      "balance": "Solde",
      "addTransaction": "Ajouter une transaction",
      "description": "Description",
      "date": "Date",
      "amount": "Montant",
      "save": "Enregistrer",
      "currencySelect": "Choisir la devise",
      "languageSelect": "Choisir la langue",
    },
    "nl": {
      "title": "Financiën",
      "expense": "Uitgave",
      "income": "Inkomen",
      "balance": "Balans",
      "addTransaction": "Transactie toevoegen",
      "description": "Beschrijving",
      "date": "Datum",
      "amount": "Bedrag",
      "save": "Opslaan",
      "currencySelect": "Valuta kiezen",
      "languageSelect": "Taal kiezen",
    },
    "ar": {
      "title": "المحفظة",
      "expense": "المصروف",
      "income": "الدخل",
      "balance": "الرصيد",
      "addTransaction": "إضافة عملية",
      "description": "الوصف",
      "date": "التاريخ",
      "amount": "المبلغ",
      "save": "حفظ",
      "currencySelect": "اختر العملة",
      "languageSelect": "اختر اللغة",
    },
  };

  String getText(String key) {
    return localizedText[selectedLanguage]?[key] ?? key;
  }

  double get totalExpense => transactions
      .where((t) => t['type'] == 'expense')
      .fold(0, (sum, t) => sum + t['amount']);
  double get totalIncome => transactions
      .where((t) => t['type'] == 'income')
      .fold(0, (sum, t) => sum + t['amount']);
  double get balance => totalIncome - totalExpense;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(transactions);
    await prefs.setString('transactions', encoded);
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('transactions');
    if (data != null) {
      setState(() {
        transactions = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  void _showAddTransactionPopup() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final dateController = TextEditingController();
    final amountController = TextEditingController();
    String selectedType = "expense";

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFFB98BA9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            getText("addTransaction"),
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "İsim"),
                ),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: getText("description"),
                  ),
                ),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: getText("date")),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: getText("amount")),
                ),
                DropdownButton<String>(
                  value: selectedType,
                  items: [
                    DropdownMenuItem(
                      value: "income",
                      child: Text(getText("income")),
                    ),
                    DropdownMenuItem(
                      value: "expense",
                      child: Text(getText("expense")),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => selectedType = value!);
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      transactions.add({
                        "name": nameController.text,
                        "desc": descController.text,
                        "date": dateController.text,
                        "amount": double.tryParse(amountController.text) ?? 0,
                        "type": selectedType,
                      });
                      _saveTransactions();
                    });
                    Navigator.pop(context);
                  },
                  child: Text(getText("save")),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditTransactionPopup(int index) {
    final transaction = transactions[index];

    final nameController = TextEditingController(text: transaction["name"]);
    final descController = TextEditingController(text: transaction["desc"]);
    final dateController = TextEditingController(text: transaction["date"]);
    final amountController = TextEditingController(
      text: transaction["amount"].toString(),
    );
    String selectedType = transaction["type"];

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFFB98BA9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            getText("addTransaction"),
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "İsim"),
                ),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: getText("description"),
                  ),
                ),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: getText("date")),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: getText("amount")),
                ),
                DropdownButton<String>(
                  value: selectedType,
                  items: [
                    DropdownMenuItem(
                      value: "income",
                      child: Text(getText("income")),
                    ),
                    DropdownMenuItem(
                      value: "expense",
                      child: Text(getText("expense")),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => selectedType = value!);
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      transactions[index] = {
                        "name": nameController.text,
                        "desc": descController.text,
                        "date": dateController.text,
                        "amount": double.tryParse(amountController.text) ?? 0,
                        "type": selectedType,
                      };
                      _saveTransactions();
                    });
                    Navigator.pop(context);
                  },
                  child: Text(getText("save")),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCurrencyPopup() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF7D6E9B),
            title: Text(
              getText("currencySelect"),
              style: const TextStyle(color: Colors.white),
            ),
            content: DropdownButton<String>(
              value: selectedCurrency,
              dropdownColor: const Color(0xFF7D6E9B),
              items:
                  ["₺", "\$", "€", "£"].map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() => selectedCurrency = value!);
                Navigator.pop(context);
              },
            ),
          ),
    );
  }

  void _showLanguagePopup() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF7D6E9B),
            title: Text(
              getText("languageSelect"),
              style: const TextStyle(color: Colors.white),
            ),
            content: DropdownButton<String>(
              value: selectedLanguage,
              dropdownColor: const Color(0xFF7D6E9B),
              items:
                  ["tr", "en", "de", "fr", "nl", "ar"].map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(
                        e.toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() => selectedLanguage = value!);
                Navigator.pop(context);
              },
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3E206D), Color(0xFFB4527F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoCard(getText("expense"), totalExpense, Colors.red),
                    _infoCard(getText("income"), totalIncome, Colors.green),
                    _infoCard(getText("balance"), balance, Colors.blue),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.language, color: Colors.white),
                      onPressed: _showLanguagePopup,
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_money, color: Colors.white),
                      onPressed: _showCurrencyPopup,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final t = transactions[index];
                      return Card(
                        color: Colors.white24,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          title: Text(
                            t["name"],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "${t["desc"]} • ${t["date"]}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Text(
                            "${t['type'] == 'income' ? '+' : '-'}${t["amount"]} $selectedCurrency",
                            style: const TextStyle(color: Colors.white),
                          ),
                          onLongPress: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              builder: (_) {
                                return Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.edit),
                                        title: const Text('Düzenle'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _showEditTransactionPopup(index);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.delete),
                                        title: const Text('Sil'),
                                        onTap: () {
                                          setState(() {
                                            transactions.removeAt(index);
                                            _saveTransactions();
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionPopup,
        backgroundColor: const Color(0xFFED88B9),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _infoCard(String title, double value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              "$value $selectedCurrency",
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
