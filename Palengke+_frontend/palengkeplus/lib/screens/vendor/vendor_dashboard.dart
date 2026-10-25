import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../services/api_service.dart';
import '../../widgets/palengke_loading.dart';

class VendorDashboard extends StatefulWidget {
  final String vendorUser;
  final ApiService api;

  const VendorDashboard({
    super.key,
    required this.vendorUser,
    required this.api,
  });

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  late Future<List<dynamic>> _myPricesFuture;
  late Future<List<dynamic>> _commoditiesFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _myPricesFuture = widget.api.fetchVendorPrices().then((list) {
        return list.where((item) =>
          item['vendor_name']?.toString().toLowerCase().trim() ==
          widget.vendorUser.toLowerCase().trim()
        ).toList();
      });
      _commoditiesFuture = widget.api.fetchCommodities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        title: const Text('Vendor Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: navy,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _myPricesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: PalengkeLoading());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final myPrices = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${widget.vendorUser}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: navy),
                      ),
                      const Text(
                        'Manage your stall inventory and prices here.',
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 24),
                      _buildStats(myPrices),
                      const SizedBox(height: 24),
                      const Text(
                        'MY LISTED PRICES',
                        style: TextStyle(color: green, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              if (myPrices.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🏪', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 16),
                        Text('No prices listed yet.', style: TextStyle(color: Colors.blueGrey)),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildPriceCard(myPrices[index]),
                      childCount: myPrices.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPriceSheet,
        backgroundColor: green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Price'),
      ),
    );
  }

  Widget _buildStats(List<dynamic> prices) {
    return Row(
      children: [
        Expanded(
          child: _statCard('Total Items', prices.length.toString(), Icons.inventory_2_outlined),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard('Active', prices.length.toString(), Icons.check_circle_outline),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: green, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: navy)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
        ],
      ),
    );
  }

  Widget _buildPriceCard(dynamic item) {
    final u = (item['unit'] ?? 'per kg').toString().toLowerCase();
    final isPiece = isPieceUnit(u);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: line),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F1E7),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(commodityEmoji(item['commodity']), style: const TextStyle(fontSize: 24)),
        ),
        title: Text(
          titleCase(item['commodity']),
          style: const TextStyle(fontWeight: FontWeight.bold, color: navy),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item['market']} · ${displayDate(item['date']?.toString() ?? '')}', style: const TextStyle(fontSize: 12)),
            if (item['notes'] != null && item['notes'].toString().isNotEmpty)
              Text(item['notes'].toString(), style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₱${formatPrice(item['price'])}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: navy),
                ),
                Text(
                  isPiece ? 'per piece' : unitLabel(u),
                  style: TextStyle(fontSize: 10, color: isPiece ? Colors.orange : Colors.blueGrey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: () => _confirmDelete(item),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(dynamic item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Price?'),
        content: Text('Are you sure you want to remove the price for ${item['commodity']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.api.deleteVendorPrice(item['id'] as int, username: widget.vendorUser);
        _refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Price removed successfully')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }




  void _showAddPriceSheet() async {
    final comms = await _commoditiesFuture;
    final names = comms.map((e) => e['name'].toString()).toList()..sort();
    String? selectedComm = names.isNotEmpty ? names.first : null;
    String unit = 'per kg';
    final priceController = TextEditingController();
    final marketController = TextEditingController();
    final notesController = TextEditingController();

    if (mounted) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setModalState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add New Price', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: navy)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedComm,
                    decoration: const InputDecoration(labelText: 'Commodity'),
                    items: names.map((n) => DropdownMenuItem(value: n, child: Text(titleCase(n)))).toList(),
                    onChanged: (v) => setModalState(() => selectedComm = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Price (₱)', prefixText: '₱ '),
                  ),
                  const SizedBox(height: 12),
                  const Text('Unit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'per kg', label: Text('per kg')),
                      ButtonSegment(value: 'per piece', label: Text('per piece')),
                    ],
                    selected: {unit},
                    onSelectionChanged: (s) => setModalState(() => unit = s.first),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: marketController,
                    decoration: const InputDecoration(labelText: 'Market/Stall Name', hintText: 'e.g., Tanauan Public Market'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Notes (Optional)', hintText: 'e.g., Freshly arrived'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () async {
                        final p = double.tryParse(priceController.text);
                        final m = marketController.text.trim();
                        if (p == null || selectedComm == null || m.isEmpty) {
                          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
                          return;
                        }
                        try {
                          await widget.api.submitVendorPrice(
                            commodity: selectedComm!,
                            price: p,
                            unit: unit,
                            vendorName: widget.vendorUser,
                            market: m,
                            notes: notesController.text.trim(),
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                          _refresh();
                        } catch (e) {
                          if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                      child: const Text('Submit Price', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
