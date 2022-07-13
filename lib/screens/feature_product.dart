import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/product_repository.dart';
import 'package:active_ecommerce_flutter/ui_elements/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FeatureProduct extends StatefulWidget {
  @override
  State<FeatureProduct> createState() => _FeatureProductState();
}

class _FeatureProductState extends State<FeatureProduct> {
   List<dynamic> _brandList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _current_slider = 0;
  ScrollController _featuredProductScrollController;
  ScrollController _mainScrollController = ScrollController();
 

  DateTime convertTimeStampToDateTime(int timeStamp) {
    var dateToTimeStamp = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    return dateToTimeStamp;
  }

  AnimationController pirated_logo_controller;
  Animation pirated_logo_animation;

  var _carouselImageList = [];
  var _featuredCategoryList = [];
  // var _featuredCategoryList1 = [];
  var _featuredCategoryList2 = [];
  var _featuredProductList = [];
  bool _isProductInitial = true;
  bool _isCategoryInitial = true;
  bool _isCarouselInitial = true;
  int _totalProductData = 0;
  int _productPage = 1;
  bool _showProductLoadingContainer = false;
  int count = 0;
  bool showFlashdeal = true;
  @override
  void initState() {
  fetchFeaturedProducts() async {
    var productResponse = await ProductRepository().getFeaturedProducts(
      page: _productPage,
    );

    _featuredProductList.addAll(productResponse.products);
    _isProductInitial = false;
    _totalProductData = productResponse.meta.total;
    _showProductLoadingContainer = false;
    setState(() {});
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildHomeFeaturedProducts(context),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        AppLocalizations.of(context).todays_deal_products_screen_todays_deal,
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  buildHomeFeaturedProducts(context) {
    if (_isProductInitial && _featuredProductList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper().buildProductGridShimmer(
              scontroller: _featuredProductScrollController));
    } else if (_featuredProductList.length > 0) {
      //snapshot.hasData

      return GridView.builder(
        // 2
        //addAutomaticKeepAlives: true,

        itemCount:3,
         //(_featuredProductList.length),
        controller: _featuredProductScrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.618),
        padding: EdgeInsets.all(8),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          // 3
          return ProductCard(
              id: _featuredProductList[index].id,
              image: _featuredProductList[index].thumbnail_image,
              name: _featuredProductList[index].name,
              main_price: _featuredProductList[index].main_price,
              stroked_price: _featuredProductList[index].stroked_price,
              has_discount: _featuredProductList[index].has_discount);
        },
      );
    } else if (_totalProductData == 0) {
      return Center(
          child: Text(
              AppLocalizations.of(context).common_no_product_is_available));
    } else {
      return Container(); // should never be happening
    }
  }
}
