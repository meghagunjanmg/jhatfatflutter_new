class VendorList {
  int? vendorCategoryId;
  String? categoryName;
  String? categoryImage;
  String? uiType;
  List<Vendors>? vendors;

  VendorList(
      {this.vendorCategoryId,
        this.categoryName,
        this.categoryImage,
        this.uiType,
        this.vendors});

  VendorList.fromJson(Map<String, dynamic> json) {
    vendorCategoryId = json['vendor_category_id'];
    categoryName = json['category_name'];
    categoryImage = json['category_image'];
    uiType = json['ui_type'];
    if (json['vendors'] != null) {
      vendors = <Vendors>[];
      json['vendors'].forEach((v) {
        vendors?.add(Vendors.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vendor_category_id'] = vendorCategoryId;
    data['category_name'] = categoryName;
    data['category_image'] = categoryImage;
    data['ui_type'] = uiType;
    if (vendors != null) {
      data['vendors'] = vendors?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Vendors {
  String? vendorName;
  String? vendorPhone;
  int? vendorId;
  String? vendorLogo;
  int? vendorCategoryId;
  String? lat;
  String? lng;
  int? deliveryRange;
  String? onlineStatus;
  String? about;
  String? vendorLoc;
  double? distance;

  Vendors(
      {this.vendorName,
        this.vendorPhone,
        this.vendorId,
        this.vendorLogo,
        this.vendorCategoryId,
        this.lat,
        this.lng,
        this.deliveryRange,
        this.onlineStatus,
        this.about,
        this.vendorLoc,
        this.distance});

  Vendors.fromJson(Map<String, dynamic> json) {
    vendorName = json['vendor_name'];
    vendorPhone = json['vendor_phone'];
    vendorId = json['vendor_id'];
    vendorLogo = json['vendor_logo'];
    vendorCategoryId = json['vendor_category_id'];
    lat = json['lat'];
    lng = json['lng'];
    deliveryRange = json['delivery_range'];
    onlineStatus = json['online_status'];
    about = json['about'];
    vendorLoc = json['vendor_loc'];
    distance = json['distance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vendor_name'] = vendorName;
    data['vendor_phone'] = vendorPhone;
    data['vendor_id'] = vendorId;
    data['vendor_logo'] = vendorLogo;
    data['vendor_category_id'] = vendorCategoryId;
    data['lat'] = lat;
    data['lng'] = lng;
    data['delivery_range'] = deliveryRange;
    data['online_status'] = onlineStatus;
    data['about'] = about;
    data['vendor_loc'] = vendorLoc;
    data['distance'] = distance;
    return data;
  }
}