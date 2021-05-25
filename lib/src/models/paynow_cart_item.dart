class PaynowCartItem {
  final String title;
  final double price;
  final String imageUrl;


  PaynowCartItem({
    this.title,
    this.price,
    this.imageUrl
  });

  static fromJson(json){
    return PaynowCartItem(
        title: json['title'],
        price: json['price'],
        imageUrl: json['imageUrl']
    );
  }
}