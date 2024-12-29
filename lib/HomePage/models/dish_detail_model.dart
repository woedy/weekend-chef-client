class DishDetailModel {
  String? message;
  Data? data;

  DishDetailModel({this.message, this.data});

  DishDetailModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  Dish? dish;
  List<ClosestChef>? closestChef;
  List<RelatedFoods>? relatedFoods;
  List<Custom>? custom;
  List<Ingredients>? ingredients;

  Data(
      {this.dish,
      this.closestChef,
      this.relatedFoods,
      this.custom,
      this.ingredients});

  Data.fromJson(Map<String, dynamic> json) {
    dish = json['dish'] != null ? new Dish.fromJson(json['dish']) : null;
    if (json['closest_chef'] != null) {
      closestChef = <ClosestChef>[];
      json['closest_chef'].forEach((v) {
        closestChef!.add(new ClosestChef.fromJson(v));
      });
    }
    if (json['related_foods'] != null) {
      relatedFoods = <RelatedFoods>[];
      json['related_foods'].forEach((v) {
        relatedFoods!.add(new RelatedFoods.fromJson(v));
      });
    }
    if (json['custom'] != null) {
      custom = <Custom>[];
      json['custom'].forEach((v) {
        custom!.add(new Custom.fromJson(v));
      });
    }
    if (json['ingredients'] != null) {
      ingredients = <Ingredients>[];
      json['ingredients'].forEach((v) {
        ingredients!.add(new Ingredients.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.dish != null) {
      data['dish'] = this.dish!.toJson();
    }
    if (this.closestChef != null) {
      data['closest_chef'] = this.closestChef!.map((v) => v.toJson()).toList();
    }
    if (this.relatedFoods != null) {
      data['related_foods'] =
          this.relatedFoods!.map((v) => v.toJson()).toList();
    }
    if (this.custom != null) {
      data['custom'] = this.custom!.map((v) => v.toJson()).toList();
    }
    if (this.ingredients != null) {
      data['ingredients'] = this.ingredients!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Dish {
  String? dishId;
  String? name;
  String? description;
  String? basePrice;
  String? coverPhoto;
  String? categoryName;
  int? quantity;
  String? value;
  bool? customizable;
  List<DishGallery>? dishGallery;
  List<Ingredients>? ingredients;

  Dish(
      {this.dishId,
      this.name,
      this.description,
      this.basePrice,
      this.coverPhoto,
      this.categoryName,
      this.quantity,
      this.value,
      this.customizable,
      this.dishGallery,
      this.ingredients});

  Dish.fromJson(Map<String, dynamic> json) {
    dishId = json['dish_id'];
    name = json['name'];
    description = json['description'];
    basePrice = json['base_price'];
    coverPhoto = json['cover_photo'];
    categoryName = json['category_name'];
    quantity = json['quantity'];
    value = json['value'];
    customizable = json['customizable'];
    if (json['dish_gallery'] != null) {
      dishGallery = <DishGallery>[];
      json['dish_gallery'].forEach((v) {
        dishGallery!.add(new DishGallery.fromJson(v));
      });
    }
    if (json['ingredients'] != null) {
      ingredients = <Ingredients>[];
      json['ingredients'].forEach((v) {
        ingredients!.add(new Ingredients.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dish_id'] = this.dishId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['base_price'] = this.basePrice;
    data['cover_photo'] = this.coverPhoto;
    data['category_name'] = this.categoryName;
    data['quantity'] = this.quantity;
    data['value'] = this.value;
    data['customizable'] = this.customizable;
    if (this.dishGallery != null) {
      data['dish_gallery'] = this.dishGallery!.map((v) => v.toJson()).toList();
    }
    if (this.ingredients != null) {
      data['ingredients'] = this.ingredients!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DishGallery {
  String? dishGalleryId;
  String? caption;
  String? photo;

  DishGallery({this.dishGalleryId, this.caption, this.photo});

  DishGallery.fromJson(Map<String, dynamic> json) {
    dishGalleryId = json['dish_gallery_id'];
    caption = json['caption'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dish_gallery_id'] = this.dishGalleryId;
    data['caption'] = this.caption;
    data['photo'] = this.photo;
    return data;
  }
}

class Ingredients {
  String? ingredientId;
  String? name;
  String? photo;

  Ingredients({this.ingredientId, this.name, this.photo});

  Ingredients.fromJson(Map<String, dynamic> json) {
    ingredientId = json['ingredient_id'];
    name = json['name'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ingredient_id'] = this.ingredientId;
    data['name'] = this.name;
    data['photo'] = this.photo;
    return data;
  }
}

class ClosestChef {
  User? user;
  String? chefId;
  String? kitchenLocation;

  ClosestChef({this.user, this.chefId, this.kitchenLocation});

  ClosestChef.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    chefId = json['chef_id'];
    kitchenLocation = json['kitchen_location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['chef_id'] = this.chefId;
    data['kitchen_location'] = this.kitchenLocation;
    return data;
  }
}

class User {
  String? userId;
  String? email;
  String? firstName;
  String? lastName;
  String? phone;
  String? photo;

  User(
      {this.userId,
      this.email,
      this.firstName,
      this.lastName,
      this.phone,
      this.photo});

  User.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    email = json['email'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    phone = json['phone'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['email'] = this.email;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['phone'] = this.phone;
    data['photo'] = this.photo;
    return data;
  }
}

class RelatedFoods {
  String? dishId;
  String? name;
  String? coverPhoto;
  String? description;

  RelatedFoods({this.dishId, this.name, this.coverPhoto, this.description});

  RelatedFoods.fromJson(Map<String, dynamic> json) {
    dishId = json['dish_id'];
    name = json['name'];
    coverPhoto = json['cover_photo'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dish_id'] = this.dishId;
    data['name'] = this.name;
    data['cover_photo'] = this.coverPhoto;
    data['description'] = this.description;
    return data;
  }
}

class Custom {
  String? customOptionId;
  String? name;
  String? photo;
  String? price;
  int quantity;  // Local quantity to manage for customization

  Custom({
    this.customOptionId,
    this.name,
    this.photo,
    this.price,
    this.quantity = 0,  // Default to 0 if quantity isn't provided
  });

  Custom.fromJson(Map<String, dynamic> json) : quantity = 0 {
    customOptionId = json['custom_option_id'];
    name = json['name'];
    photo = json['photo'];
    price = json['price'];
    // Notice that 'quantity' is not coming from the server, we initialize it to 0
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['custom_option_id'] = this.customOptionId;
    data['name'] = this.name;
    data['photo'] = this.photo;
    data['price'] = this.price;
    data['quantity'] = this.quantity;  // Include the local quantity when sending data back
    return data;
  }
}
