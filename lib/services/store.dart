import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crescendo/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:crescendo/models/cart_item.dart';
import '../consts.dart';
import '../models/product.dart';
import '../models/product_multi_photos.dart';

class Store {
  final _store = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  addProduct(Product product) async {
    await _store.collection(KProductCollection).add({
      KProductName: product.name,
      KProductPrice: product.price,
      KProductDescription: product.description,
      KProductImageUrl: product.imageUrl
    });
  }

  addProductMultiPhotos(MultiProduct product) async {
    var docRef = _store.collection(KProductCollection).doc();
    await docRef.set({
      KProductName: product.name,
      KProductPrice: product.price,
      KProductDescription: product.description,
    });
    product.imageUrls?.forEach((url) {
      docRef.collection(KProductImages).add({KProductImageUrl: url});
    });
  }

  Future<String> uploadPhoto(fileName, filePath) async {
    File file = File(filePath);
    String? url;
    try {
      await _storage.ref('products/$fileName').putFile(file);
      url = await _storage.ref('products/$fileName').getDownloadURL();
    } on FirebaseException catch (e) {
      print(e);
    }
    return url as String;
  }

  Future<List<String>> uploadMultiPhotos(
      List<String> fileNames, List<String> filePaths) async {
    List<String> urls = [];
    for (int i = 0; i < fileNames.length; i++) {
      File file = File(filePaths[i]);
      try {
        await _storage.ref('products/${fileNames[i]}').putFile(file);
        urls.add(
            await _storage.ref('products/${fileNames[i]}').getDownloadURL());
      } on FirebaseException catch (e) {
        print(e);
      }
    }
    return urls;
  }

  Future<List<Product>> getProduct() async {
    List<Product> products = [];
    await _store.collection('products').get().then((snapshot) {
      snapshot.docs.forEach((doc) {
        products.add(Product(
            name: doc[KProductName],
            price: doc[KProductPrice],
            description: doc[KProductDescription],
            imageUrl: doc[KProductImageUrl]));
      });
    });
    return products;
  }

  Future<List<MultiProduct>> getProductMultiPhotos() async {
    List<MultiProduct> products = [];
    await _store.collection('products').get().then((snapshot) {
      snapshot.docs.forEach((doc) async {
        String docId = doc.id;
        List<String> urls = [];
        await _store
            .collection('products')
            .doc(docId)
            .collection(KProductImages)
            .get()
            .then((snapshot) {
          snapshot.docs.forEach((doc) {
            urls.add(doc[KProductImageUrl]);
          });
        });

        products.add(MultiProduct(
            name: doc[KProductName],
            price: doc[KProductPrice],
            description: doc[KProductDescription],
            imageUrls: urls));
      });
    });
    return products;
  }

  Future<List<MyUser>> getUser() async {
    List<MyUser> users = [];
    await _store.collection(KUsers).get().then((snapshot) {
      snapshot.docs.forEach((doc) {
        users.add(MyUser(
            name: doc[KUserName],
            email: doc[KUserEmail],
            address: doc[KUserAddress],
            phone: doc[KUserPhone]));
      });
    });
    return users;
  }

  getUserByEmail(String email) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    // User found, return the document
    return result.docs.first;
  }

  void editUser(data, email) async {
    QuerySnapshot snapshot = await _store
        .collection('users')
        .where(KUserEmail, isEqualTo: email)
        .get();
    var id = snapshot.docs.first;
    await _store.collection('users').doc(id.id).update(data);
  }

  Stream<QuerySnapshot> loadProcuts() {
    return _store.collection(KProductCollection).snapshots();
  }

  Future<List<DocumentSnapshot>> loadProcutImages(String docId) async {
    QuerySnapshot snapshot = await _store
        .collection(KProductCollection)
        .doc(docId)
        .collection(KProductImages)
        .get();
    return snapshot.docs;
  }

  void deleteProduct(docId) {
    _store.collection(KProductCollection).doc(docId).delete();
  }

  editProduct(data, docId) async {
    await _store.collection(KProductCollection).doc(docId).update(data);
  }

  removeDiscount(docId) async {
    await _store.collection(KProductCollection).doc(docId).update({
      KProductDiscount: FieldValue.delete(),
    });
  }

  void storeOrder(
      String address,
      String phone,
      String userName,
      String email,
      String deliveryAddress,
      String totalPrice,
      String additional,
      List<CartItem> cart,
      String state) async {
    var docRef = _store.collection(KOrders).doc();
    await docRef.set({
      KTotalPrice: totalPrice,
      KAddress: address,
      KPhone: phone,
      KUserName: userName,
      KOrderDeliveryAddress: deliveryAddress,
      KOrderState: state,
      KOrderAdditional: additional,
      KUserEmail: email
    });
    for (var item in cart) {
      await docRef.collection(KItems).add({
        KProductName: item.product.name,
        KProductPrice: item.product.price,
        KProductQuantity: item.quantity,
        KProductDiscount: item.product.discount,
      });
    }
  }

  void editOrderState(docId, String newState) async {
    await _store
        .collection('orders')
        .doc(docId)
        .update({KOrderState: newState});
  }

  Stream<QuerySnapshot> loadOrders() {
    return _store.collection('orders').snapshots();
  }

  Stream<QuerySnapshot> loadOrderDetails(docId) {
    return _store
        .collection('orders')
        .doc(docId)
        .collection(KItems)
        .snapshots();
  }

  Stream<QuerySnapshot> loadOrdersItems(docId) {
    return _store
        .collection('orders')
        .doc(docId)
        .collection(KItems)
        .snapshots();
  }

  Stream<QuerySnapshot> loadUserOrders(String email) {
    final result = FirebaseFirestore.instance
        .collection('orders')
        .where('email', isEqualTo: email)
        .snapshots();

    // User found, return the document
    return result;
  }

  storeUser(String email, String userName, String phone, String address) async {
    await _store.collection(KUsers).add({
      KUserEmail: email,
      KUserName: userName,
      KUserPhone: phone,
      KUserAddress: address
    });
  }
}
