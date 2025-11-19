import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import 'product_detail_screen.dart';
import 'package:audioplayers/audioplayers.dart';


class ScannerScreen extends StatefulWidget {
  final bool isActive;
  const ScannerScreen({Key? key, required this.isActive}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isProcessing = false;

  @override
  void didUpdateWidget(covariant ScannerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.start();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playBeep() async {
    await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
  }

  Future<void> _handleBarcode(BarcodeCapture barcodeCapture) async {
    if (_isProcessing) return;

    if (barcodeCapture.barcodes.isEmpty) return;
    final barcode = barcodeCapture.barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() => _isProcessing = true);

    final barcodeValue = barcode.rawValue!;
    
    // Stop scanning temporarily
    await _controller.stop();

    try {
      // Check if product exists
      final existingProduct = await _dbHelper.getProductByBarcode(barcodeValue);

      if (existingProduct != null) {
        // Product exists - add to cart
        if (mounted) {
          final cartProvider = Provider.of<CartProvider>(context, listen: false);
          await _playBeep();
          cartProvider.addToCart(existingProduct);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${existingProduct.name} added to cart'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Product doesn't exist - navigate to add product screen
        if (mounted) {
          final newProduct = Product(
            barcode: barcodeValue,
            name: '',
            price: 0.0,
            purchasingAmount: 0.0,
          );

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: newProduct),
            ),
          );

          if (result == true && mounted) {
            // Product was saved, fetch it and add to cart
            final savedProduct = await _dbHelper.getProductByBarcode(barcodeValue);
            if (savedProduct != null) {
              final cartProvider = Provider.of<CartProvider>(context, listen: false);
              cartProvider.addToCart(savedProduct);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Product added and added to cart'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
      // Resume scanning
      if (mounted) {
        await _controller.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode/QR Code'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Point camera at barcode or QR code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

