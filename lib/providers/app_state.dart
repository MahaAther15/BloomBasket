import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/order.dart';

class AppState extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Google Sign In - Works for both Mobile & Web
  late final GoogleSignIn _googleSignIn;

  User? _user;
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  List<Product> _products = [];
  List<CartItem> _cart = [];
  List<Product> _favorites = [];
  List<BBOrder> _orders = [];

  // Local storage variables
  String? _localUsersFilePath;
  Map<String, dynamic> _currentUserData = {};

  List<Product> get products => _products;
  List<CartItem> get cart => _cart;
  List<Product> get favorites => _favorites;
  List<BBOrder> get orders => _orders;

  double get cartTotal => _cart.fold(0.0, (sum, item) => sum + item.totalPrice);
  int get cartItemCount => _cart.fold(0, (sum, item) => sum + item.quantity);
  bool get isSignedIn => _user != null;

  AppState() {
    _initGoogleSignIn();
    _checkAuthState();
    _loadSampleProducts();
    _initLocalStorage();
  }

  void _initGoogleSignIn() {
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      clientId: const String.fromEnvironment(
        'googleClientId',
        defaultValue:
            "352717362565-mjjnb1nhd53tvg7ed34dlijo8nub0sib.apps.googleusercontent.com",
      ),
    );
  }

  void _checkAuthState() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      print("🔐 Auth state changed: ${user?.email ?? 'No user'}");

      if (user != null) {
        _loadUserLocalData(user.uid);
      } else {
        _currentUserData = {};
        _cart.clear();
        _favorites.clear();
        _orders.clear();
      }

      notifyListeners();
    });
  }

  // ✅ Initialize local storage
  Future<void> _initLocalStorage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _localUsersFilePath = '${directory.path}/bloombasket_users.json';

      // Create file if it doesn't exist
      final file = File(_localUsersFilePath!);
      if (!await file.exists()) {
        final initialData = {
          'users': [],
          'version': '1.0',
          'lastUpdated': DateTime.now().toIso8601String()
        };
        await file.writeAsString(jsonEncode(initialData));
      }

      print("✅ Local storage initialized at: $_localUsersFilePath");
    } catch (e) {
      print("❌ Error initializing local storage: $e");
    }
  }

  // ✅ Save user data locally
  Future<void> _saveUserLocalData(User user, {String? username}) async {
    try {
      if (_localUsersFilePath == null) {
        await _initLocalStorage();
      }

      final file = File(_localUsersFilePath!);
      final contents = await file.readAsString();
      Map<String, dynamic> data = jsonDecode(contents);

      List<dynamic> users = data['users'] ?? [];

      // Check if user already exists
      int existingIndex = users.indexWhere((u) => u['uid'] == user.uid);

      final userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': username ?? user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'createdAt': DateTime.now().toIso8601String(),
        'lastLoginAt': DateTime.now().toIso8601String(),
        'favorites': _favorites.map((p) => p.id).toList(),
        'cart': _cart
            .map((item) => {
                  'productId': item.product.id,
                  'productName': item.product.name,
                  'productPrice': item.product.price,
                  'quantity': item.quantity,
                })
            .toList(),
        'orders': _orders
            .map((order) => {
                  'id': order.id,
                  'totalAmount': order.totalAmount,
                  'orderDate': order.orderDate.toIso8601String(),
                  'status': order.status.toString(),
                  'deliveryAddress': order.deliveryAddress,
                })
            .toList(),
      };

      if (existingIndex != -1) {
        // Update existing user
        users[existingIndex] = userData;
      } else {
        // Add new user
        users.add(userData);
      }

      data['users'] = users;
      data['lastUpdated'] = DateTime.now().toIso8601String();
      await file.writeAsString(jsonEncode(data));

      _currentUserData = userData;
      print("✅ User data saved locally: ${user.email}");
    } catch (e) {
      print("❌ Error saving user data locally: $e");
    }
  }

  // ✅ Load user data from local storage
  Future<void> _loadUserLocalData(String uid) async {
    try {
      if (_localUsersFilePath == null) {
        await _initLocalStorage();
      }

      final file = File(_localUsersFilePath!);
      if (!await file.exists()) return;

      final contents = await file.readAsString();
      Map<String, dynamic> data = jsonDecode(contents);

      List<dynamic> users = data['users'] ?? [];
      final userData = users.firstWhere(
        (u) => u['uid'] == uid,
        orElse: () => null,
      );

      if (userData != null) {
        _currentUserData = userData;

        // Load favorites
        List<String> favoriteIds =
            List<String>.from(userData['favorites'] ?? []);
        _favorites =
            _products.where((p) => favoriteIds.contains(p.id)).toList();

        // Load cart items
        List<dynamic> cartItems = userData['cart'] ?? [];
        _cart = [];
        for (var item in cartItems) {
          final product = _products.firstWhere(
            (p) => p.id == item['productId'],
            orElse: () => Product(
              id: item['productId'],
              name: item['productName'],
              description: '',
              price: (item['productPrice'] as num).toDouble(),
              imageUrl: '',
              category: '',
              tags: [],
            ),
          );
          final cartItem = CartItem(product: product);
          cartItem.quantity = item['quantity'];
          _cart.add(cartItem);
        }

        // Load orders
        List<dynamic> ordersData = userData['orders'] ?? [];
        _orders = ordersData.map((orderJson) {
          return BBOrder(
            id: orderJson['id'],
            items: [], // You might want to store items separately
            totalAmount: (orderJson['totalAmount'] as num).toDouble(),
            orderDate: DateTime.parse(orderJson['orderDate']),
            status: _parseOrderStatus(orderJson['status']),
            deliveryAddress: orderJson['deliveryAddress'],
          );
        }).toList();

        notifyListeners();
        print("✅ Local user data loaded for: ${userData['email']}");
      }
    } catch (e) {
      print("❌ Error loading local user data: $e");
    }
  }

  // ✅ Update local user data
  Future<void> _updateUserLocalData(Map<String, dynamic> updates) async {
    try {
      if (_user == null) return;

      if (_localUsersFilePath == null) {
        await _initLocalStorage();
      }

      final file = File(_localUsersFilePath!);
      final contents = await file.readAsString();
      Map<String, dynamic> data = jsonDecode(contents);

      List<dynamic> users = data['users'] ?? [];
      int index = users.indexWhere((u) => u['uid'] == _user!.uid);

      if (index != -1) {
        users[index] = {...users[index], ...updates};
        data['users'] = users;
        data['lastUpdated'] = DateTime.now().toIso8601String();
        await file.writeAsString(jsonEncode(data));
        _currentUserData = users[index];
        print("✅ Local user data updated");
      }
    } catch (e) {
      print("❌ Error updating local user data: $e");
    }
  }

  OrderStatus _parseOrderStatus(String status) {
    switch (status) {
      case 'OrderStatus.confirmed':
        return OrderStatus.confirmed;
      case 'OrderStatus.prepared':
        return OrderStatus.prepared;
      case 'OrderStatus.outForDelivery':
        return OrderStatus.outForDelivery;
      case 'OrderStatus.delivered':
        return OrderStatus.delivered;
      default:
        return OrderStatus.confirmed;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      print("📧 Signing in with email: $email");
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _user = _auth.currentUser;

      // Save user profile locally
      if (_user != null) {
        await _saveUserLocalData(_user!);
      }

      notifyListeners();
      print("✅ Email sign in successful");
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else {
        message = e.message ?? 'Login failed. Please try again.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('An error occurred. Please try again.');
    }
  }

  Future<void> signUp(String email, String password, String username) async {
    try {
      print("📝 Signing up with email: $email");
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.updateDisplayName(username);
      await userCredential.user?.reload();

      _user = _auth.currentUser;

      // Save newly created user profile locally with username
      if (_user != null) {
        await _saveUserLocalData(_user!, username: username);
      }

      notifyListeners();
      print("✅ Sign up successful");
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else {
        message = e.message ?? 'Sign up failed. Please try again.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('An error occurred. Please try again.');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      print("1️⃣ Starting Google Sign In...");
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("2️⃣ User cancelled sign in");
        return;
      }

      print("2️⃣ Google User: ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print("3️⃣ Got authentication tokens");

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      _user = userCredential.user;

      // Save user profile locally
      if (_user != null) {
        await _saveUserLocalData(_user!);
      }

      notifyListeners();

      print("✅ Google Sign In Successful: ${_user?.email}");
    } catch (e) {
      print("❌ Google Sign In Error: $e");
      throw Exception('Google Sign In failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      print("🚪 Signing out...");

      // Save current session data before signing out
      if (_user != null && _localUsersFilePath != null) {
        await _updateUserLocalData({
          'lastLoginAt': DateTime.now().toIso8601String(),
          'favorites': _favorites.map((p) => p.id).toList(),
          'cart': _cart
              .map((item) => {
                    'productId': item.product.id,
                    'productName': item.product.name,
                    'productPrice': item.product.price,
                    'quantity': item.quantity,
                  })
              .toList(),
          'orders': _orders
              .map((order) => {
                    'id': order.id,
                    'totalAmount': order.totalAmount,
                    'orderDate': order.orderDate.toIso8601String(),
                    'status': order.status.toString(),
                    'deliveryAddress': order.deliveryAddress,
                  })
              .toList(),
        });
      }

      await _googleSignIn.signOut();
      await _auth.signOut();
      _user = null;
      _cart.clear();
      _favorites.clear();
      _orders.clear();
      _currentUserData = {};
      notifyListeners();
      print("✅ Signed out successfully");
    } catch (e) {
      print('❌ Sign Out Error: $e');
      throw Exception('Error signing out. Please try again.');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("✅ Password reset email sent to: $email");
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to send reset email');
    }
  }

  // ✅ Get all local users (for debugging)
  Future<List<Map<String, dynamic>>> getAllLocalUsers() async {
    try {
      if (_localUsersFilePath == null) {
        await _initLocalStorage();
      }

      final file = File(_localUsersFilePath!);
      if (!await file.exists()) return [];

      final contents = await file.readAsString();
      Map<String, dynamic> data = jsonDecode(contents);

      return List<Map<String, dynamic>>.from(data['users'] ?? []);
    } catch (e) {
      print("❌ Error getting local users: $e");
      return [];
    }
  }

  // ✅ Get current user data
  Map<String, dynamic> getCurrentUserData() {
    return _currentUserData;
  }

  void _loadSampleProducts() {
    _products = [
      Product(
        id: '1',
        name: 'Midnight Peony',
        description:
            'A deep, mysterious arrangement of dark peonies and forest greens.',
        price: 85.0,
        imageUrl: 'assets/images/blackrose.webp',
        category: 'Seasonal',
        tags: ['Luxury', 'Dark'],
      ),
      Product(
        id: '2',
        name: 'Alabaster Lily',
        description: 'Pure white lilies paired with delicate eucalyptus.',
        price: 65.0,
        imageUrl: 'assets/images/lilly.jfif',
        category: 'Boutique',
        tags: ['Elegant', 'White'],
      ),
      Product(
        id: '3',
        name: 'Gilded Rose',
        description: 'Classic red roses with a touch of gold-sprayed foliage.',
        price: 95.0,
        imageUrl: 'assets/images/flower.png',
        category: 'Artisanal',
        tags: ['Romance', 'Gold'],
      ),
      Product(
        id: '6',
        name: 'Rose Gold Delight',
        description: 'Rose gold colored roses with delicate accents.',
        price: 90.0,
        imageUrl: 'assets/images/images (1).jfif',
        category: 'Artisanal',
        tags: ['Luxury', 'Gold'],
      ),
      Product(
        id: '7',
        name: 'Cherry Blossom',
        description: 'Delicate pink blossoms evoking springtime elegance.',
        price: 60.0,
        imageUrl: 'assets/images/images (2).jfif',
        category: 'Seasonal',
        tags: ['Pink', 'Spring'],
      ),
      Product(
        id: '8',
        name: 'White Orchid',
        description: 'Pure white orchid arrangement for sophisticated décor.',
        price: 80.0,
        imageUrl: 'assets/images/images (3).jfif',
        category: 'Boutique',
        tags: ['Elegant', 'White'],
      ),
      Product(
        id: '9',
        name: 'Golden Sunflower',
        description:
            'Bright sunflowers with golden accents for a cheerful vibe.',
        price: 58.0,
        imageUrl: 'assets/images/images (4).jfif',
        category: 'Seasonal',
        tags: ['Sunny', 'Yellow'],
      ),
      Product(
        id: '11',
        name: 'Coral Peony',
        description: 'Soft coral peonies perfect for romantic occasions.',
        price: 78.0,
        imageUrl: 'assets/images/images (6).jfif',
        category: 'Boutique',
        tags: ['Romantic', 'Coral'],
      ),
      Product(
        id: '13',
        name: 'Blush Rose',
        description: 'Gentle pink roses for subtle elegance.',
        price: 68.0,
        imageUrl: 'assets/images/images (8).jfif',
        category: 'Boutique',
        tags: ['Pink', 'Elegant'],
      ),
      Product(
        id: '14',
        name: 'Royal Amaranth',
        description: 'Vibrant red amaranth for a bold statement.',
        price: 62.0,
        imageUrl: 'assets/images/images (9).jfif',
        category: 'Artisanal',
        tags: ['Bold', 'Red'],
      ),
      Product(
        id: '15',
        name: 'Silk Tulip',
        description: 'Elegant silk tulip arrangement for lasting beauty.',
        price: 73.0,
        imageUrl: 'assets/images/images (10).jfif',
        category: 'Boutique',
        tags: ['Silk', 'Elegant'],
      ),
      Product(
        id: '16',
        name: 'Amber Daisy',
        description: 'Cheerful amber daisies adding sunny vibes.',
        price: 50.0,
        imageUrl: 'assets/images/images (11).jfif',
        category: 'Seasonal',
        tags: ['Sunny', 'Daisy'],
      ),
      Product(
        id: '17',
        name: 'Midnight Orchid',
        description: 'Dark orchid arrangement for an exotic night look.',
        price: 88.0,
        imageUrl: 'assets/images/images (12).jfif',
        category: 'Artisanal',
        tags: ['Dark', 'Exotic'],
      ),
      Product(
        id: '18',
        name: 'Pearl Lily',
        description: 'Luminous white lilies with pearl accents.',
        price: 77.0,
        imageUrl: 'assets/images/images (13).jfif',
        category: 'Boutique',
        tags: ['Luminous', 'White'],
      ),
      Product(
        id: '21',
        name: 'Ruby Amaryllis',
        description: 'Stunning deep red petals for a grand holiday feel.',
        price: 82.0,
        imageUrl: 'assets/images/images (17).jfif',
        category: 'Seasonal',
        tags: ['Holiday', 'Red'],
      ),
      Product(
        id: '22',
        name: 'Azure Hydrangea',
        description: 'Lush clouds of blue petals for a refreshing look.',
        price: 64.0,
        imageUrl: 'assets/images/images (18).jfif',
        category: 'Boutique',
        tags: ['Blue', 'Fresh'],
      ),
      Product(
        id: '23',
        name: 'Velvet Anemone',
        description: 'Striking black-centered flowers with white petals.',
        price: 72.0,
        imageUrl: 'assets/images/images (19).jfif',
        category: 'Artisanal',
        tags: ['Contrast', 'Elegant'],
      ),
      Product(
        id: '24',
        name: 'Peach Carnation',
        description: 'Soft ruffled petals in a warm pastel peach hue.',
        price: 48.0,
        imageUrl: 'assets/images/images (20).jfif',
        category: 'Seasonal',
        tags: ['Pastel', 'Warm'],
      ),
      Product(
        id: '25',
        name: 'Imperial Protea',
        description: 'Exotic king protea for a bold, architectural statement.',
        price: 110.0,
        imageUrl: 'assets/images/images (21).jfif',
        category: 'Artisanal',
        tags: ['Exotic', 'Premium'],
      ),
      Product(
        id: '27',
        name: 'Snowdrop Trio',
        description: 'Delicate bell-shaped blooms for winter elegance.',
        price: 45.0,
        imageUrl: 'assets/images/images (23).jfif',
        category: 'Seasonal',
        tags: ['Winter', 'White'],
      ),
      Product(
        id: '28',
        name: 'Indigo Delphinium',
        description: 'Tall spires of deep blue blossoms.',
        price: 75.0,
        imageUrl: 'assets/images/images (24).jfif',
        category: 'Boutique',
        tags: ['Tall', 'Blue'],
      ),
      Product(
        id: '31',
        name: 'Midnight Calla',
        description: 'Dark purple, almost black calla lilies for high drama.',
        price: 98.0,
        imageUrl: 'assets/images/images (27).jfif',
        category: 'Artisanal',
        tags: ['Dark', 'Luxury'],
      ),
      Product(
        id: '32',
        name: 'Sweet Pea Cloud',
        description: 'Whimsical and fragrant pastel sweet pea mix.',
        price: 62.0,
        imageUrl: 'assets/images/download.jfif',
        category: 'Boutique',
        tags: ['Soft', 'Scented'],
      ),
      Product(
        id: '33',
        name: 'Dahlia Fire',
        description: 'Complex geometric petals in fiery orange and red.',
        price: 76.0,
        imageUrl: 'assets/images/download (1).jfif',
        category: 'Seasonal',
        tags: ['Geometric', 'Vibrant'],
      ),
      Product(
        id: '34',
        name: 'Silver Sage Eucalyptus',
        description: 'Aromatic silver-green leaves to complement any space.',
        price: 40.0,
        imageUrl: 'assets/images/download (2).jfif',
        category: 'Seasonal',
        tags: ['Green', 'Modern'],
      ),
      Product(
        id: '35',
        name: 'Blushing Astilbe',
        description: 'Feathery plumes of pink for a fairytale garden vibe.',
        price: 68.0,
        imageUrl: 'assets/images/download (3).jfif',
        category: 'Boutique',
        tags: ['Feathery', 'Pink'],
      ),
      Product(
        id: '36',
        name: 'Gothic Tulip',
        description: 'Deep maroon tulips for an alternative aesthetic.',
        price: 65.0,
        imageUrl: 'assets/images/download (4).jfif',
        category: 'Artisanal',
        tags: ['Gothic', 'Unique'],
      ),
      Product(
        id: '37',
        name: 'Champagne Lisianthus',
        description: 'Creamy champagne blooms that look like silk.',
        price: 85.0,
        imageUrl: 'assets/images/download (5).jfif',
        category: 'Boutique',
        tags: ['Silk', 'Cream'],
      ),
      Product(
        id: '39',
        name: 'Starry Jasmine',
        description: 'Clusters of white flowers with a heavenly scent.',
        price: 55.0,
        imageUrl: 'assets/images/download (7).jfif',
        category: 'Boutique',
        tags: ['White', 'Fragrant'],
      ),
      Product(
        id: '40',
        name: 'Obsidian Calla',
        description: 'The ultimate luxury in deep black floral design.',
        price: 120.0,
        imageUrl: 'assets/images/download (8).jfif',
        category: 'Artisanal',
        tags: ['Black', 'Elite'],
      ),
      Product(
        id: '41',
        name: 'Wild Bluebells',
        description: 'Woodland charm in a delicate bunch.',
        price: 49.0,
        imageUrl: 'assets/images/download (9).jfif',
        category: 'Seasonal',
        tags: ['Wild', 'Blue'],
      ),
      Product(
        id: '42',
        name: 'Lemon Grass Lily',
        description: 'Pale yellow lilies with fresh citrus undertones.',
        price: 70.0,
        imageUrl: 'assets/images/download (10).jfif',
        category: 'Boutique',
        tags: ['Yellow', 'Zesty'],
      ),
      Product(
        id: '43',
        name: 'Frosty Succulent',
        description: 'Long-lasting silver-toned succulent arrangement.',
        price: 45.0,
        imageUrl: 'assets/images/images.jfif',
        category: 'Artisanal',
        tags: ['Modern', 'Durable'],
      ),
    ];
  }

  // ==================== ADMIN METHODS ====================
  void addProduct(Product product) {
    _products.insert(0, product);
    notifyListeners();
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: status);
      
      // Update in local storage if user is logged in
      if (_user != null) {
         _updateUserLocalData({
          'orders': _orders
              .map((order) => {
                    'id': order.id,
                    'totalAmount': order.totalAmount,
                    'orderDate': order.orderDate.toIso8601String(),
                    'status': order.status.toString(),
                    'deliveryAddress': order.deliveryAddress,
                  })
              .toList(),
        });
      }
      notifyListeners();
    }
  }

  // ==================== CART METHODS ====================
  void addToCart(Product product) {
    final index = _cart.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _cart[index].quantity++;
    } else {
      _cart.add(CartItem(product: product));
    }

    // Save to local storage if user is logged in
    if (_user != null) {
      _updateUserLocalData({
        'cart': _cart
            .map((item) => {
                  'productId': item.product.id,
                  'productName': item.product.name,
                  'productPrice': item.product.price,
                  'quantity': item.quantity,
                })
            .toList(),
      });
    }

    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cart.removeWhere((i) => i.product.id == product.id);

    // Save to local storage if user is logged in
    if (_user != null) {
      _updateUserLocalData({
        'cart': _cart
            .map((item) => {
                  'productId': item.product.id,
                  'productName': item.product.name,
                  'productPrice': item.product.price,
                  'quantity': item.quantity,
                })
            .toList(),
      });
    }

    notifyListeners();
  }

  void clearCart() {
    _cart.clear();

    // Save to local storage if user is logged in
    if (_user != null) {
      _updateUserLocalData({'cart': []});
    }

    notifyListeners();
  }

  void updateQuantity(Product product, int quantity) {
    final index = _cart.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      if (quantity <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index].quantity = quantity;
      }

      // Save to local storage if user is logged in
      if (_user != null) {
        _updateUserLocalData({
          'cart': _cart
              .map((item) => {
                    'productId': item.product.id,
                    'productName': item.product.name,
                    'productPrice': item.product.price,
                    'quantity': item.quantity,
                  })
              .toList(),
        });
      }

      notifyListeners();
    }
  }

  // ==================== FAVORITES METHODS ====================
  bool isFavorite(Product product) {
    return _favorites.any((p) => p.id == product.id);
  }

  void toggleFavorite(Product product) {
    if (isFavorite(product)) {
      _favorites.removeWhere((p) => p.id == product.id);
    } else {
      _favorites.add(product);
    }

    // Save to local storage if user is logged in
    if (_user != null) {
      _updateUserLocalData({
        'favorites': _favorites.map((p) => p.id).toList(),
      });
    }

    notifyListeners();
  }

  // ==================== ORDER METHODS ====================
  void placeOrder(String address) {
    if (_cart.isEmpty) return;

    final newOrder = BBOrder(
      id: 'BB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      items: List<CartItem>.from(_cart),
      totalAmount: cartTotal,
      orderDate: DateTime.now(),
      status: OrderStatus.confirmed,
      deliveryAddress: address,
    );

    _orders.insert(0, newOrder);

    // Save orders to local storage if user is logged in
    if (_user != null) {
      _updateUserLocalData({
        'orders': _orders
            .map((order) => {
                  'id': order.id,
                  'totalAmount': order.totalAmount,
                  'orderDate': order.orderDate.toIso8601String(),
                  'status': order.status.toString(),
                  'deliveryAddress': order.deliveryAddress,
                })
            .toList(),
      });
    }

    _cart.clear();
    notifyListeners();
  }

  // ✅ Get user's order history
  List<BBOrder> getUserOrders() {
    return _orders;
  }

  // ✅ Clear all local data (for testing)
  Future<void> clearAllLocalData() async {
    try {
      if (_localUsersFilePath == null) {
        await _initLocalStorage();
      }

      final file = File(_localUsersFilePath!);
      final initialData = {
        'users': [],
        'version': '1.0',
        'lastUpdated': DateTime.now().toIso8601String()
      };
      await file.writeAsString(jsonEncode(initialData));

      _currentUserData = {};
      print("✅ All local data cleared");
    } catch (e) {
      print("❌ Error clearing local data: $e");
    }
  }
}
