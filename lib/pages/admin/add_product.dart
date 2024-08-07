import 'package:crescendo/components/custom_button.dart';
import 'package:crescendo/consts.dart';
import 'package:crescendo/models/product.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';

import '../../components/custom_bottom_sheet.dart';
import '../../components/custom_textfield.dart';
import '../../services/store.dart';

class AddProduct extends StatefulWidget {
  static final String id = 'add-product';

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  late String _name, _price, _description;
  var path, name;
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  Store _store = Store();

  void showMySheet(String text, double height) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      context: context,
      builder: (context) {
        return CustomButtomSheet(textMessage: text, height: height);
      },
    );
  }

  selectPhoto() async {
    final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
        type: FileType.custom);
    if (result == null) {
      showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (context) {
          return CustomButtomSheet(
              textMessage: "No file selected", height: 200);
        },
      );
    }
    path = result?.files.single.path;
    name = result?.files.single.name;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return ProgressHUD(
      child: Scaffold(
        body: Form(
          key: _key,
          child: SafeArea(
              child: Center(
            child: ListView(
              children: [
                SizedBox(height: 90),
                CustomTextField(
                  hint: "Name",
                  onClick: (value) {
                    _name = value as String;
                  },
                ),
                SizedBox(height: 10),
                CustomTextField(
                  hint: "Price",
                  onClick: (value) {
                    _price = value as String;
                  },
                ),
                SizedBox(height: 10),
                SizedBox(height: 10),
                CustomTextField(
                  hint: "Description",
                  onClick: (value) {
                    _description = value as String;
                  },
                ),
                SizedBox(height: 20),
                CustomButton(callback: selectPhoto, text: "Select photo"),
                Visibility(
                  visible: name == null ? false : true,
                  child: name == null
                      ? const SizedBox(
                          height: 10,
                        )
                      : Center(
                          child: Text(
                            name as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                ),
                SizedBox(height: 20),
                Builder(builder: (context) {
                  return CustomButton(
                      callback: () async {
                        final progress = ProgressHUD.of(context);
                        progress?.show();
                        if (_key.currentState?.validate() ?? true) {
                          String imageUrl =
                              await _store.uploadPhoto(name, path);
                          _key.currentState?.save();
                          _store.addProduct(Product(
                              name: _name,
                              price: _price,
                              description: _description,
                              imageUrl: imageUrl));
                          showMySheet("Product Addeed", height);
                        }
                        progress?.dismiss();
                      },
                      text: "Add product");
                })
              ],
            ),
          )),
        ),
      ),
    );
  }
}
