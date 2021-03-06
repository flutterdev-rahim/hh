import 'dart:convert';

import 'package:active_ecommerce_flutter/custom/CommonFunctoins.dart';
import 'package:active_ecommerce_flutter/dummy_data/featured_categories.dart';
import 'package:active_ecommerce_flutter/dummy_data/flash_deals.dart';
import 'package:active_ecommerce_flutter/helpers/addons_helper.dart';
import 'package:active_ecommerce_flutter/helpers/business_setting_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/providers/locale_provider.dart';
import 'package:active_ecommerce_flutter/repositories/brand_repository.dart';
import 'package:active_ecommerce_flutter/repositories/flash_deal_repository.dart';
import 'package:active_ecommerce_flutter/screens/categories_list2.dart';
import 'package:active_ecommerce_flutter/screens/feature_product.dart';
import 'package:active_ecommerce_flutter/screens/filter.dart';
import 'package:active_ecommerce_flutter/screens/flash_deal_list.dart';
import 'package:active_ecommerce_flutter/screens/flash_deal_products.dart';
import 'package:active_ecommerce_flutter/screens/product_details.dart';
import 'package:active_ecommerce_flutter/screens/todays_deal_products.dart';
import 'package:active_ecommerce_flutter/screens/top_selling_products.dart';
import 'package:active_ecommerce_flutter/screens/category_products.dart';
import 'package:active_ecommerce_flutter/screens/category_list.dart';
import 'package:active_ecommerce_flutter/ui_elements/brand_square_card.dart';
import 'package:active_ecommerce_flutter/ui_elements/mini_product_card.dart';
import 'package:active_ecommerce_flutter/ui_sections/drawer.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:active_ecommerce_flutter/repositories/sliders_repository.dart';
import 'package:active_ecommerce_flutter/repositories/category_repository.dart';
import 'package:active_ecommerce_flutter/repositories/product_repository.dart';
import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/ui_elements/product_card.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  Home({Key key, this.title, this.show_back_button = false, go_back = true})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  bool show_back_button;
  bool go_back;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  List<dynamic> _brandList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _current_slider = 0;
  List flashDealproductlist = [];
  ScrollController _featuredProductScrollController;
  ScrollController _mainScrollController = ScrollController();
  List<CountdownTimerController> _timerControllerList = [];

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

  void initState() {
    flashDealData();
    showFlashdeal = true;
    // print("app_mobile_language.en${app_mobile_language.$}");
    // print("app_language.${app_language.$}");
    // print("app_language_rtl${app_language_rtl.$}");

    // TODO: implement initState
    super.initState();
    // In initState()
    if (AppConfig.purchase_code == "") {
      initPiratedAnimation();
    }
    // getcategoriedata();
    fetchAll();

    _mainScrollController.addListener(() {
      //print("position: " + _xcrollController.position.pixels.toString());
      //print("max: " + _xcrollController.position.maxScrollExtent.toString());

      if (_mainScrollController.position.pixels ==
          _mainScrollController.position.maxScrollExtent) {
        setState(() {
          _productPage++;
        });
        _showProductLoadingContainer = true;
        fetchFeaturedProducts();
      }
    });
  }

  fetchAll() {
    fetchCarouselImages();
    fetchFeaturedCategories();
    fetchFeaturedProducts();
    // buildFlashDealLisst(context);
    // AddonsHelper().setAddonsData();
    // BusinessSettingHelper().setBusinessSettingData();
  }

  fetchBrandData() async {
    var brandResponse = await BrandRepository().getBrands();
    _brandList.addAll(brandResponse.brands);

    setState(() {});
  }

  fetchCarouselImages() async {
    var carouselResponse = await SlidersRepository().getSliders();
    carouselResponse.sliders.forEach((slider) {
      _carouselImageList.add(slider.photo);
    });
    _isCarouselInitial = false;
    setState(() {});
  }

  fetchFeaturedCategories() async {
    var categoryResponse = await CategoryRepository().getFeturedCategories();
    _featuredCategoryList.addAll(categoryResponse.categories);
    _isCategoryInitial = false;
    setState(() {});
  }

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

  reset() {
    _carouselImageList.clear();
    _featuredCategoryList.clear();
    _isCarouselInitial = true;
    _isCategoryInitial = true;
    _featuredCategoryList2.clear();

    setState(() {});

    resetProductList();
  }

  Future<void> _onRefresh() async {
    reset();
    fetchAll();
  }

  resetProductList() {
    _featuredProductList.clear();
    buildProductList(context);
    _isProductInitial = true;
    _totalProductData = 0;
    _productPage = 1;
    _showProductLoadingContainer = false;
    setState(() {});
  }

  initPiratedAnimation() {
    pirated_logo_controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    pirated_logo_animation = Tween(begin: 40.0, end: 60.0).animate(
        CurvedAnimation(
            curve: Curves.bounceOut, parent: pirated_logo_controller));

    pirated_logo_controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        pirated_logo_controller.repeat();
      }
    });

    pirated_logo_controller.forward();
  }

  getcategoriedata() {
    if (_featuredCategoryList.length % 2 != 0) {
      count = 1;
    }
    for (int i = (_featuredCategoryList.length / 2).toInt() + count;
        i < _featuredCategoryList.length;
        i++) {
      setState(() {
        _featuredCategoryList2.add(_featuredCategoryList[i]);
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pirated_logo_controller?.dispose();
    _mainScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (showFlashdeal) {
    //   showFlashdeal = false;

    // for (int i = 0; i < _featuredCategoryList.length / 2; i++) {
    //   setState(() {
    //     _featuredCategoryList2.add(_featuredCategoryList[i]);
    //   });
    // }

    if (_featuredCategoryList.length % 2 != 0) {
      count = 1;
    }
    for (int i = (_featuredCategoryList.length / 2).toInt() + count;
        i < _featuredCategoryList.length;
        i++) {
      setState(() {
        _featuredCategoryList2.add(_featuredCategoryList[i]);
      });
    }
    // print('List Length Is : ${_featuredCategoryList1.length}');
    //print(_featuredCategoryList1.length);

    // print('List Length Is : ${_featuredCategoryList1.length}');

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    //print(MediaQuery.of(context).viewPadding.top);

    return WillPopScope(
      onWillPop: () async {
        CommonFunctions(context).appExitDialog();
        return widget.go_back;
      },
      child: Directionality(
        textDirection:
            app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
            // key: _scaffoldKey,
            backgroundColor: Colors.white,
            appBar: buildAppBar(statusBarHeight, context),
            drawer: MainDrawer(),
            body: Stack(
              children: [
                RefreshIndicator(
                  color: MyTheme.accent_color,
                  backgroundColor: Colors.white,
                  onRefresh: _onRefresh,
                  displacement: 0,
                  child: CustomScrollView(
                    controller: _mainScrollController,
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildListDelegate([
                          AppConfig.purchase_code == ""
                              ? Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    0.0,
                                    16.0,
                                    0.0,
                                    0.0,
                                  ),
                                  child: Container(
                                    height: 140,
                                    color: Colors.black,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                            left: 20,
                                            top: 0,
                                            child: AnimatedBuilder(
                                                animation:
                                                    pirated_logo_animation,
                                                builder: (context, child) {
                                                  return Image.asset(
                                                    "assets/pirated_square.png",
                                                    height:
                                                        pirated_logo_animation
                                                            .value,
                                                    color: Colors.white,
                                                  );
                                                })),
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 24.0, left: 24, right: 24),
                                            child: Text(
                                              "This is a pirated app. Do not use this. It may have security issues.",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(
                                6.0,
                                16.0,
                                6.0,
                                0.0,
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    color: Colors.white,
                                    height: 47,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Rich in Varienty',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 12)),
                                                  Text(
                                                      '1000+ New items Everyday',
                                                      style: TextStyle())
                                                ],
                                              ),
                                            ),
                                          ),
                                          VerticalDivider(),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Safe & Trust',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 12)),
                                                  Text('Secure Payment',
                                                      style: TextStyle())
                                                ],
                                              ),
                                            ),
                                          ),
                                          VerticalDivider(),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Friendly Services',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 12)),
                                                  Text(
                                                      '7 day Satisfaction Guarantee',
                                                      style: TextStyle())
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  buildHomeCarouselSlider(context),
                                ],
                              )),
                          // Padding(
                          //   padding: const EdgeInsets.fromLTRB(
                          //     8.0,
                          //     16.0,
                          //     8.0,
                          //     0.0,
                          //   ),
                          // child: buildHomeMenuRow(context),
                          // ),
                        ]),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate([
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              6.0,
                              16.0,
                              6.0,
                              0.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Categories :',
                                  // AppLocalizations.of(context).home_screen_featured_categories,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CategoryList2()));
                                      },
                                      child: Text(
                                        'SHOP MORE',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: MyTheme.Grey_third),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 12,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            0.0,
                            16.0,
                            0.0,
                            0.0,
                          ),
                          child: SizedBox(
                              height: 300,
                              child: buildHomeFeaturedCategories2(context)),
                        ),
                      ),
                      // SliverToBoxAdapter(
                      //   child: Padding(
                      //     padding: const EdgeInsets.fromLTRB(
                      //       16.0,
                      //       16.0,
                      //       0.0,
                      //       0.0,
                      //     ),
                      //     child: SizedBox(
                      //       height: 14,
                      //       child: buildHomeFeaturedCategoriess(context),
                      //     ),
                      //   ),
                      // ),
                      SliverList(
                        delegate: SliverChildListDelegate([
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              6.0,
                              16.0,
                              6.0,
                              0.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Flash Deal',
                                      // AppLocalizations.of(context).home_screen_featured_categories,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    buildFlashDealLisst(context),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    FlashDealList()));
                                      },
                                      child: Text(
                                        'SHOP MORE',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: MyTheme.Grey_third),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 12,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            0.0,
                            16.0,
                            0.0,
                            0.0,
                          ),
                          child: SizedBox(
                              height: 165,
                              child: ListView.builder(
                                  itemCount: flashDealproductlist.length,
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemExtent: 120,
                                  //  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return ProductDetails(
                                              id: flashDealproductlist[index]
                                                  ['id']);
                                        }));
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          side: new BorderSide(
                                              color: MyTheme.white, width: 0.0),
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                        elevation: 0.0,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                  width: double.infinity,
                                                  height:
                                                      (MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              36) /
                                                          3.5,
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                              top: Radius
                                                                  .circular(16),
                                                              bottom:
                                                                  Radius.zero),
                                                      child: FadeInImage
                                                          .assetNetwork(
                                                        placeholder:
                                                            'assets/placeholder.png',
                                                        image: flashDealproductlist[
                                                                index]
                                                            ['thumbnail_image'],
                                                        fit: BoxFit.fill,
                                                      ))),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    8, 0, 8, 0),
                                                child: Text(
                                                  flashDealproductlist[index]
                                                      ['name'],
                                                  // widget.name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                      color: MyTheme.font_grey,
                                                      fontSize: 11,
                                                      height: 1.2,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    8, 0, 8, 0),
                                                child: Text(
                                                  flashDealproductlist[index]
                                                          ['main_price']
                                                      .toString(),
                                                  //widget.main_price,
                                                  textAlign: TextAlign.left,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      color:
                                                          MyTheme.accent_color,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                              flashDealproductlist[index]
                                                      ['has_discount']
                                                  ? Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              8, 0, 8, 0),
                                                      child: Text(
                                                        flashDealproductlist[
                                                                    index][
                                                                'stroked_price']
                                                            .toString(),
                                                        textAlign:
                                                            TextAlign.left,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            color: MyTheme
                                                                .medium_grey,
                                                            fontSize: 9,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    )
                                                  : Container(),
                                            ]),
                                      ),
                                    );

                                    //  MiniProductCard(
                                    //   id:flashDealproductlist[index]['id'] ,
                                    //  image:flashDealproductlist[index]['thumbnail_image']
                                    //  //'https://www.tamampk.com/'+'${flashDealproductlist[index]['']}',
                                    // );
                                  })),
                        ),
                      ),

                      SliverList(
                          delegate: SliverChildListDelegate([
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            6.0,
                            16.0,
                            6.0,
                            0.0,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return CategoryProducts(
                                          category_id: 4,
                                          category_name: "Women's Fashion",
                                          //"Kid's Fashion",
                                        );
                                      }));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.brown,
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      height: 150,
                                      width: 170,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(
                                          'https://tamampk.com/public/assets/img/app/shape-banenr-7.png',
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return CategoryProducts(
                                              category_id: 9,
                                              category_name: "Health & Fitness"
                                              //"Kid's Fashion",
                                              );
                                        }));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        height: 150,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Image.network(
                                            'https://tamampk.com/public/assets/img/app/denim-banner-8.png',
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return CategoryProducts(
                                              category_id: 10,
                                              category_name: "Sports & Outdoors"
                                              //"Kid's Fashion",
                                              );
                                        }));
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          height: 150,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: Image.network(
                                              'https://tamampk.com/public/assets/img/app/gadget-banner-4.png',
                                              fit: BoxFit.fill,
                                            ),
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return CategoryProducts(
                                          category_id: 12,
                                          category_name: "Home & Lifestyle",
                                          //"Kid's Fashion",
                                        );
                                      }));
                                    },
                                    child: Container(
                                        height: 120,
                                        width: 240,
                                        decoration: BoxDecoration(
                                            color: Colors.brown,
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Image.network(
                                            'https://tamampk.com/public/assets/img/app/enjoy-banner-2.gif',
                                            fit: BoxFit.fill,
                                          ),
                                        )),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return CategoryProducts(
                                            category_id: 18,
                                            category_name: "Wedding",
                                            //"Kid's Fashion",
                                          );
                                        }));
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          height: 120,
                                          //width: 240,

                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: Image.network(
                                              'https://tamampk.com/public/assets/img/app/woman-fashion-1.png',
                                              fit: BoxFit.fill,
                                            ),
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return CategoryProducts(
                                          category_id: 5,
                                          category_name: "Men's Fashion",
                                          //"Kid's Fashion",
                                        );
                                      }));
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        height: 120,
                                        width: 240,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Image.network(
                                            'https://tamampk.com/public/assets/img/app/man-fashion-3.png',
                                            fit: BoxFit.fill,
                                          ),
                                        )),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return CategoryProducts(
                                            category_id: 60,
                                            category_name:
                                                "Computer & Accessories",
                                            //"Kid's Fashion",
                                          );
                                        }));
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          height: 120,
                                          //width: 220,

                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: Image.network(
                                              'https://tamampk.com/public/assets/img/app/eletric-banner-5.png',
                                              fit: BoxFit.fill,
                                            ),
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return CategoryProducts(
                                          category_id: 339,
                                          category_name:
                                              "Pakistani Traditional",
                                          //"Kid's Fashion",
                                        );
                                      }));
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        height: 120,
                                        width: 240,
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: Image.network(
                                                  'https://tamampk.com/public/assets/img/app/winter_banner_9.png',
                                                  fit: BoxFit.fill,
                                                  width: double.infinity,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return CategoryProducts(
                                            category_id: 7,
                                            category_name: "babies & toys",
                                            //"Kid's Fashion",
                                          );
                                        }));
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          height: 120,
                                          //width: 220,

                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: Image.network(
                                              'https://tamampk.com/public/assets/img/app/baby-banner-6.png',
                                              fit: BoxFit.fill,
                                            ),
                                          )),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ])),

                      // SliverToBoxAdapter(
                      //   child: Padding(
                      //       padding: const EdgeInsets.fromLTRB(
                      //         16.0,
                      //         16.0,
                      //         0.0,
                      //         0.0,
                      //       ),
                      //       child: FlashDealProducts()),
                      // ),

                      SliverList(
                        delegate: SliverChildListDelegate([
                          SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    10.0,
                                    16.0,
                                    6.0,
                                    0.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)
                                            .home_screen_featured_products,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          TodaysDealProducts()));
                                            },
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return TodaysDealProducts();
                                                }));
                                              },
                                              child: Text(
                                                'SHOP MORE',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: MyTheme.Grey_third),
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 12,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    0.0,
                                    10.0,
                                    8.0,
                                    0.0,
                                  ),
                                  child: buildHomeFeaturedProducts(context),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    6.0,
                                    0.0,
                                    6.0,
                                    0.0,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              0.0,
                                              10.0,
                                              0.0,
                                              0.0,
                                            ),
                                            child: Text(
                                              "Today\'s Deal :",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              TodaysDealProducts()));
                                                },
                                                child: Container(
                                                  padding:EdgeInsets.only(top:10),
                                                  child: Text(
                                                    'SHOP MORE',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            MyTheme.Grey_third),
                                                  ),
                                                ),
                                              ),
                                              Container(     padding:EdgeInsets.only(top:10),
                                                child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 12,
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            0.0,
                                            16.0,
                                            0.0,
                                            0.0,
                                          ),
                                          child: buildProductList(context)
                                          //TodaysDealProducts(),
                                          ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 80,
                          )
                        ]),
                      ),
                    ],
                  ),
                ),
                Align(
                    alignment: Alignment.center,
                    child: buildProductLoadingContainer())
              ],
            )),
      ),
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

        itemCount: (_featuredProductList.length),
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

  buildHomeFeaturedCategoriess(context) {
    if (_isCategoryInitial && _featuredCategoryList.length == 0) {
      return Row(
        children: [
          Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 32) / 3)),
          Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 32) / 3)),
          Padding(
              padding: const EdgeInsets.only(right: 0.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 32) / 3)),
        ],
      );
    } else if (_featuredCategoryList.length > 0) {
      //snapshot.hasData
      return Container(
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: _featuredCategoryList2.length,
            itemExtent: 120,
            itemBuilder: (context, index) {
              // if (index.isEven) {
              return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                      child: Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          shape: RoundedRectangleBorder(
                            side: new BorderSide(
                                color: MyTheme.light_grey, width: 1.0),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          elevation: 0.0,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                    //width: 100,
                                    height: 100,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16),
                                            bottom: Radius.zero),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return CategoryProducts(
                                                category_id:
                                                    _featuredCategoryList[index]
                                                        .id,
                                                category_name:
                                                    _featuredCategoryList[index]
                                                        .name,
                                              );
                                            }));
                                          },
                                          child: FadeInImage.assetNetwork(
                                            placeholder:
                                                'assets/placeholder.png',
                                            image: _featuredCategoryList2
                                                        .length !=
                                                    0
                                                ? _featuredCategoryList2[index]
                                                    .banner
                                                : null,
                                            fit: BoxFit.fill,
                                          ),
                                        ))),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
                                  child: Container(
                                    height: 32,
                                    child: Text(
                                      _featuredCategoryList2[index].name,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: MyTheme.font_grey),
                                    ),
                                  ),
                                ),
                              ]))));
              // } else {}
              // return SizedBox(
              //   height: 0,
              //   width: 0,
              // );
            }),
      );
    } else if (!_isCategoryInitial && _featuredCategoryList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context).home_screen_no_category_found,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  buildFlashProduct(contex) {
    ListView.builder(
        itemCount: flashDealproductlist.length,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemExtent: 120,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Container(
            child: Text(flashDealproductlist[index]['id'].toString()),
          );
        });
  }

  buildHomeFeaturedCategories2(context) {
    if (_isCategoryInitial && _featuredCategoryList.length == 0) {
      return Row(
        children: [
          Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 32) / 3)),
          Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 32) / 3)),
          Padding(
              padding: const EdgeInsets.only(right: 0.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 32) / 3)),
        ],
      );
    } else if (_featuredCategoryList.length > 0) {
      //snapshot.hasData
      return Container(
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: (_featuredCategoryList.length / 2).toInt(),
            itemExtent: 120,
            itemBuilder: (context, index) {
              // if (index.isOdd) {
              return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return CategoryProducts(
                            category_id: _featuredCategoryList[index].id,
                            category_name: _featuredCategoryList[index].name,
                          );
                        }));
                      },
                      child: Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          shape: RoundedRectangleBorder(
                            side: new BorderSide(
                                color: MyTheme.light_grey, width: 1.0),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          elevation: 0.0,
                          child: Column(
                            children: [
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                        //width: 100,
                                        height: 100,
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(16),
                                                bottom: Radius.zero),
                                            child: FadeInImage.assetNetwork(
                                              placeholder:
                                                  'assets/placeholder.png',
                                              image:
                                                  _featuredCategoryList[index]
                                                      .banner,
                                              fit: BoxFit.fill,
                                            ))),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
                                      child: Container(
                                        height: 32,
                                        child: Text(
                                          _featuredCategoryList[index].name,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: MyTheme.font_grey),
                                        ),
                                      ),
                                    ),
                                  ]),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                        //width: 100,
                                        height: 100,
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(16),
                                                bottom: Radius.zero),
                                            child: FadeInImage.assetNetwork(
                                              placeholder:
                                                  'assets/placeholder.png',
                                              image:
                                                  _featuredCategoryList2[index]
                                                      .banner,
                                              fit: BoxFit.fill,
                                            ))),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
                                      child: Container(
                                        height: 32,
                                        child: Text(
                                          _featuredCategoryList2[index].name,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: MyTheme.font_grey),
                                        ),
                                      ),
                                    ),
                                  ]),
                            ],
                          ))));
            }

            // return Container(height: 10,
            // color: Colors.amber,
            // );
            ),
      );
    } else if (!_isCategoryInitial && _featuredCategoryList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context).home_screen_no_category_found,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  buildHomeMenuRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return CategoryList(
                is_top_category: true,
              );
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 4 - 4,
            child: Column(
              children: [
                Container(
                    height: 47,
                    width: 47,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: MyTheme.light_grey, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/top_categories.png"),
                    )),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    AppLocalizations.of(context).home_screen_top_categories,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(122, 122, 122, 1),
                        fontWeight: FontWeight.w300),
                  ),
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return Filter(
                selected_filter: "brands",
              );
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 4 - 4,
            child: Column(
              children: [
                Container(
                    height: 47,
                    width: 47,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: MyTheme.light_grey, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/brands.png"),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(AppLocalizations.of(context).home_screen_brands,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(122, 122, 122, 1),
                            fontWeight: FontWeight.w300))),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return TopSellingProducts();
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 4 - 4,
            child: Column(
              children: [
                Container(
                    height: 47,
                    width: 47,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: MyTheme.light_grey, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/top_sellers.png"),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                        AppLocalizations.of(context).home_screen_top_sellers,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(122, 122, 122, 1),
                            fontWeight: FontWeight.w300))),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return TodaysDealProducts();
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 4 - 4,
            child: Column(
              children: [
                Container(
                    height: 47,
                    width: 47,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: MyTheme.light_grey, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/todays_deal.png"),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                        AppLocalizations.of(context).home_screen_todays_deal,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(122, 122, 122, 1),
                            fontWeight: FontWeight.w300))),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return FlashDealList();
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 4 - 4,
            child: Column(
              children: [
                Container(
                    height: 47,
                    width: 47,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: MyTheme.light_grey, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/flash_deal.png"),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                        AppLocalizations.of(context).home_screen_flash_deal,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(122, 122, 122, 1),
                            fontWeight: FontWeight.w300))),
              ],
            ),
          ),
        )
      ],
    );
  }

  buildHomeCarouselSlider(context) {
    if (_isCarouselInitial && _carouselImageList.length == 0) {
      return Padding(
        padding: const EdgeInsets.only(left: 4.0, right: 4.0),
        child: Shimmer.fromColors(
          baseColor: MyTheme.shimmer_base,
          highlightColor: MyTheme.shimmer_highlighted,
          child: Container(
            height: 120,
            width: double.infinity,
            color: Colors.white,
          ),
        ),
      );
    } else if (_carouselImageList.length > 0) {
      return CarouselSlider(
        options: CarouselOptions(
            aspectRatio: 2.67,
            viewportFraction: 1,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 4),
            autoPlayAnimationDuration: Duration(milliseconds: 1000),
            autoPlayCurve: Curves.easeInCubic,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              setState(() {
                _current_slider = index;
              });
            }),
        items: _carouselImageList.map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Stack(
                children: <Widget>[
                  Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/placeholder_rectangle.png',
                            image: i,
                            fit: BoxFit.fill,
                          ))),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _carouselImageList.map((url) {
                        int index = _carouselImageList.indexOf(url);
                        return Container(
                          width: 7.0,
                          height: 7.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _current_slider == index
                                ? MyTheme.white
                                : Color.fromRGBO(112, 112, 112, .3),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          );
        }).toList(),
      );
    } else if (!_isCarouselInitial && _carouselImageList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context).home_screen_no_carousel_image_found,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  AppBar buildAppBar(double statusBarHeight, BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: GestureDetector(
        onTap: () {
          _scaffoldKey.currentState.openDrawer();
        },
        child: widget.show_back_button
            ? Builder(
                builder: (context) => IconButton(
                    icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
                    onPressed: () {
                      if (!widget.go_back) {
                        return;
                      }
                      return Navigator.of(context).pop();
                    }),
              )
            : Builder(
                builder: (context) => Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 18.0, horizontal: 0.0),
                  child: Container(
                    child: Image.asset(
                      'assets/hamburger.png',
                      height: 16,
                      //color: MyTheme.dark_grey,
                      color: MyTheme.dark_grey,
                    ),
                  ),
                ),
              ),
      ),
      title: Container(
        height: kToolbarHeight +
            statusBarHeight -
            (MediaQuery.of(context).viewPadding.top > 40 ? 16.0 : 16.0),
        //MediaQuery.of(context).viewPadding.top is the statusbar height, with a notch phone it results almost 40, without a notch it shows 24.0.For safety we have checked if its greater than thirty
        child: Container(
          child: Padding(
              padding: app_language_rtl.$
                  ? const EdgeInsets.only(top: 14.0, bottom: 14, left: 12)
                  : const EdgeInsets.only(top: 14.0, bottom: 14, right: 12),
              // when notification bell will be shown , the right padding will cease to exist.
              child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Filter();
                    }));
                  },
                  child: buildHomeSearchBox(context))),
        ),
      ),
      elevation: 0.0,
      titleSpacing: 0,
      actions: <Widget>[
        InkWell(
          onTap: () {
            ToastComponent.showDialog(
                AppLocalizations.of(context).common_coming_soon, context,
                gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
          },
          child: Visibility(
            visible: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
              child: Image.asset(
                'assets/bell.png',
                height: 16,
                color: MyTheme.dark_grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  buildHomeSearchBox(BuildContext context) {
    return TextField(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Filter();
        }));
      },
      autofocus: false,
      decoration: InputDecoration(
          hintText: AppLocalizations.of(context).home_screen_search,
          hintStyle: TextStyle(fontSize: 12.0, color: MyTheme.textfield_grey),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyTheme.textfield_grey, width: 0.4),
            borderRadius: const BorderRadius.all(
              const Radius.circular(16.0),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyTheme.textfield_grey, width: 1.0),
            borderRadius: const BorderRadius.all(
              const Radius.circular(16.0),
            ),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.search,
              color: MyTheme.textfield_grey,
              size: 20,
            ),
          ),
          contentPadding: EdgeInsets.all(0.0)),
    );
  }

  Container buildProductLoadingContainer() {
    return Container(
      height: _showProductLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalProductData == _featuredProductList.length
            ? AppLocalizations.of(context).common_no_more_products
            : AppLocalizations.of(context).common_loading_more_products),
      ),
    );
  }

  buildFlashDealLisst(context) {
    return Container(
      // height: 164,
      child: FutureBuilder(
          future: FlashDealRepository().getFlashDeals(),
          builder: (context, snapshot) {
            //snapshot.hasData
            var flashDealResponse = snapshot.data;
            return Container(
              padding: EdgeInsets.only(top: 5),
              //  height: 164,
              //  color: Colors.black,
              child: flashDealResponse != null
                  ? buildFlashDealListItem(
                      flashDealResponse,
                    )
                  : Container(),
            );
          }),
    );
  }

  String timeText(String txt, {default_length = 3}) {
    var blank_zeros = default_length == 3 ? "000" : "00";
    var leading_zeros = "";
    if (txt != null) {
      if (default_length == 3 && txt.length == 1) {
        leading_zeros = "00";
      } else if (default_length == 3 && txt.length == 2) {
        leading_zeros = "0";
      } else if (default_length == 2 && txt.length == 1) {
        leading_zeros = "0";
      }
    }

    var newtxt = (txt == null || txt == "" || txt == null.toString())
        ? blank_zeros
        : txt;

    // print(txt + " " + default_length.toString());
    // print(newtxt);

    if (default_length > txt.length) {
      newtxt = leading_zeros + newtxt;
    }
    //print(newtxt);

    return newtxt;
  }

  buildFlashDealListItem(
    flashDealResponse,
  ) {
    DateTime end = convertTimeStampToDateTime(
        flashDealResponse.flash_deals[0].date); // YYYY-mm-dd
    DateTime now = DateTime.now();
    int diff = end.difference(now).inMilliseconds;
    int endTime = diff + now.millisecondsSinceEpoch;

    void onEnd() {}

    CountdownTimerController time_controller =
        CountdownTimerController(endTime: endTime, onEnd: onEnd);
    _timerControllerList.add(time_controller);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: CountdownTimer(
        controller: _timerControllerList[0],
        widgetBuilder: (_, CurrentRemainingTime time) {
          return GestureDetector(
            onTap: () {
              if (time == null) {
                ToastComponent.showDialog(
                    AppLocalizations.of(context)
                        .flash_deal_list_screen_flash_deal_has_ended,
                    context,
                    gravity: Toast.CENTER,
                    duration: Toast.LENGTH_LONG);
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return FlashDealProducts(
                    flash_deal_id: flashDealResponse.flash_deals[0].id,
                    // flash_deal_name: flashDealResponse.flash_deals[index].title,
                  );
                }));
              }
            },
            child: Container(
              // height: 147,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Card(
                  //   shape: RoundedRectangleBorder(
                  //     side:
                  //         new BorderSide(color: MyTheme.light_grey, width: 1.0),
                  //     borderRadius: BorderRadius.circular(16.0),
                  //   ),
                  //   elevation: 0.0,
                  //   child: Container(
                  //       width: double.infinity,
                  //       height: 100,
                  //       child: ClipRRect(
                  //           borderRadius: BorderRadius.circular(16.0),
                  //           child: FadeInImage.assetNetwork(
                  //             placeholder: 'assets/placeholder_rectangle.png',
                  //             image:
                  //                 flashDealResponse.flash_deals[index].banner,
                  //             fit: BoxFit.fill,
                  //           ))),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(bottom: 8.0),
                  //   child: Text(
                  //     flashDealResponse.flash_deals[index].title,
                  //     maxLines: 1,
                  //     style: TextStyle(
                  //         color: MyTheme.dark_grey,
                  //         fontSize: 16,
                  //         fontWeight: FontWeight.w600),
                  //   ),
                  // ),
                  Container(
                    height: 20,
                    width: 140,
                    child: Center(
                        child: time == null
                            ? Text(
                                AppLocalizations.of(context)
                                    .flash_deal_list_screen_ended,
                                style: TextStyle(
                                    color: MyTheme.accent_color,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600),
                              )
                            : buildTimerRowRow(time)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  buildTimerRowRow(CurrentRemainingTime time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(2)),
          padding: EdgeInsets.all(2),
          child: Center(
            child: Text(
              timeText(time.days.toString(), default_length: 2),
              style: TextStyle(
                  color: MyTheme.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 2.0, right: 2.0),
          child: Text(
            ":",
            style: TextStyle(
                color: MyTheme.accent_color,
                fontSize: 16.0,
                fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(2)),
          padding: EdgeInsets.all(2),
          child: Text(
            timeText(time.hours.toString(), default_length: 2),
            style: TextStyle(
                color: MyTheme.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 2.0, right: 2.0),
          child: Text(
            ":",
            style: TextStyle(
                color: MyTheme.accent_color,
                fontSize: 16.0,
                fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(2)),
          padding: EdgeInsets.all(2),
          child: Text(
            timeText(time.min.toString(), default_length: 2),
            style: TextStyle(
                color: MyTheme.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 2.0, right: 2.0),
          child: Text(
            ":",
            style: TextStyle(
                color: MyTheme.accent_color,
                fontSize: 16.0,
                fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(2)),
          padding: EdgeInsets.all(2),
          child: Text(
            timeText(time.sec.toString(), default_length: 2),
            style: TextStyle(
                color: MyTheme.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  buildProductList(context) {
    return FutureBuilder(
        future: ProductRepository().getTodaysDealProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            //snapshot.hasError
            /*print("product error");
            print(snapshot.error.toString());*/
            return Container();
          } else if (snapshot.hasData) {
            var productResponse = snapshot.data;
            return SingleChildScrollView(
              child: GridView.builder(
                // 2
                //addAutomaticKeepAlives: true,
                itemCount: productResponse.products.length,
                //  controller: _scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.618),
                // padding: EdgeInsets.all(16),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  // 3
                  return ProductCard(
                    id: productResponse.products[index].id,
                    image: productResponse.products[index].thumbnail_image,
                    name: productResponse.products[index].name,
                    main_price: productResponse.products[index].main_price,
                    stroked_price:
                        productResponse.products[index].stroked_price,
                    has_discount: productResponse.products[index].has_discount,
                  );
                },
              ),
            );
          } else {
            return ShimmerHelper().buildProductGridShimmer(
                // scontroller: _scrollController
                );
          }
        });
  }

  Future flashDealData() async {
    try {
      var url = 'https://www.tamampk.com/api/v2/flash-deal-products/3';
      http.Response response = await http.get(Uri.parse(url));
      var data = jsonDecode(response.body)['data'];
      //  final json = jsonDecode(response.body);

      print('Subeeeeeeee $data');
      setState(() {
        flashDealproductlist = data;
      });
      return data;
    } catch (err) {
      print(err.toString());
    }
  }
}
