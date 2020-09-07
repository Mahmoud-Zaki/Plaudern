import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:plaudern/Controllers/utils.dart';
import 'package:plaudern/screens/VideoCall/Request/RequestScreen.dart';

class FullStatue extends StatelessWidget {
  List Status;
  int index;

  FullStatue({this.Status, this.index});
  @override
  Widget build(BuildContext context) {
    return RequestScreen(
        scafold:Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              Carousel(
                animationDuration: Duration(seconds: 3),
                autoplayDuration: Duration(seconds: 6),
                boxFit: BoxFit.cover,
                autoplay: true,
                dotColor: Theme.of(context).accentColor,
                dotIncreasedColor: Theme.of(context).primaryColor,
                dotSize: 10,
                dotBgColor: Colors.transparent,
                indicatorBgPadding: 2,
                images: List.generate(Status.length, (i) => CachedNetworkImage(
                  imageUrl: Status[i]['story'],
                  imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                            colorFilter:
                            ColorFilter.mode(Colors.transparent, BlendMode.colorBurn)),
                      ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(Status[i]['photo']),
                      ),
                      title: Text(Status[i]['name'],),
                      subtitle: Text(readTimestamp(Status[i]['dateandtime']),),
                    ),
                    ),
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),),
              ),
            ],
          ),
        ),
        ),
    );
  }
}