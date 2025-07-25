import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_project_01/common/models/model_cart_item.dart';
import 'package:flutter_project_01/common/widgets/app_bar.dart';
import 'package:flutter_project_01/screens/cart/cart_utils/cart_mock_data.dart';
import 'package:flutter_project_01/screens/cart/cart_utils/cart_helper.dart';
import 'package:flutter_project_01/screens/cart/cart_widgets/cart_empty_widget.dart';
import 'package:flutter_project_01/screens/cart/cart_widgets/cart_item_list.dart';
import 'package:flutter_project_01/screens/cart/cart_widgets/cart_bottom_widget.dart';
import 'package:flutter_project_01/screens/cart/cart_utils/cart_singleton.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // 장바구니 아이템 목록
  //List<CartItem> cartItems = CartMockData.getCartItems();
  List<CartItem> cartItems = Cart().items;
  //List<CartItem> cartItems = CartMockData.getEmptyCart();

  // ----------------------------------------------------메소드-------------------------------------------------------------
  // 총 가격 계산
  int get totalPrice {
    return CartHelper.calculateTotalPrice();
  }

  // 수량 업데이트
  void updateQuantity(int index, int newQty) {
    setState(() {
      Cart().addItem(cartItems[index].item, quantity: newQty);
      CartHelper.updateItemQuantity(cartItems[index].item, newQty);
    });
  }

  // 아이템 삭제
  void removeItem(int index) {
    setState(() {
      Cart().removeItem(cartItems[index].item, quantity: 1);
      CartHelper.removeItemFromCart(cartItems[index].item, quantity: 1);
    });
  }

  // 구매 기능
  void onPurchasePressed() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('구매 확인'),
          content: Text(
            '총 ${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원의 상품을 구매하시겠습니까?',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Cart().clear();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('구매'),
            ),
          ],
        );
      },
    );
  }
  // ----------------------------------------------------메소드 종료-------------------------------------------------------------

  // ----------------------------------------------------빌드 시작-------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        showBackButton: true,
        showLogo: false,
        showCart: false,
        titleString: '장바구니',
      ),
      // AppBar(
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   title: const Text(
      //     '장바구니',
      //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      //   ),
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   centerTitle: true,
      //   foregroundColor: Colors.black,
      // ),
      body: Column(
        children: [
          // 장바구니 아이템 목록
          Expanded(
            child: Cart().items.isEmpty
                ? const CartEmptyWidget()
                : CartItemList(
                    cartItems: cartItems,
                    onQuantityChanged: updateQuantity,
                    onRemove: (index) => removeItem(index),
                  ),
          ),
          // 하단 결제 영역
          if (Cart().items.isNotEmpty)
            CartBottomWidget(
              totalPrice: totalPrice,
              onPurchasePressed: onPurchasePressed,
            ),
        ],
      ),
    );
  }

  // ----------------------------------------------------빌드 종료-------------------------------------------------------------
}
