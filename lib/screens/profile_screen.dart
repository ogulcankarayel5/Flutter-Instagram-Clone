import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterinstagramclone/models/user_data.dart';
import 'package:flutterinstagramclone/models/user_model.dart';
import 'package:flutterinstagramclone/services/database_service.dart';
import 'package:flutterinstagramclone/utils/constants.dart';
import 'package:provider/provider.dart';

import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final String currentUserId;
  ProfileScreen({this.currentUserId,this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isFollowing=false;
  int followerCount = 0;
  int followingCount = 0;


  _displayButton(User user) {
    return user.id == Provider.of<UserData>(context).currentUserId
        ? Container(
            width: 200.0,
            child: FlatButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(
                    user: user,
                  ),
                ),
              ),
              color: Colors.blue,
              textColor: Colors.white,
              child: Text(
                'Edit Profile',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          )
        : Container(
            width: 200.0,
            child: FlatButton(
              onPressed: _followOrUnfollow,
              color: isFollowing ? Colors.grey[200] : Colors.blue,
              textColor:isFollowing ? Colors.black: Colors.white,
              child: Text(
                isFollowing ? 'Unfollow' : 'Follow',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
  }

  _followOrUnfollow(){
    if(isFollowing){
      _unfollowUser();
    }
    else{
      _followUser();
    }
  }

  _unfollowUser(){
    DatabaseService.unfollowUser(currentUserId: widget.currentUserId,userId: widget.userId);
    setState(() {
      isFollowing=false;
      followerCount--;

    });
  }

  _followUser(){
    DatabaseService.followUser(currentUserId:widget.currentUserId, userId:widget.userId);
    setState(() {
      isFollowing=true;
      followerCount++;
    });
  }
  _setupFollowers() async{
    int userFollowerCount = await DatabaseService.numFollowers(widget.userId);
    setState(() {
      followerCount=userFollowerCount;
    });
  }

  _setupFollowing() async{
    int userFollowingCount=await DatabaseService.numFollowing(widget.userId);
    setState(() {
      followingCount=userFollowingCount;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setupIsFollowing();
    _setupFollowing();
    _setupFollowers();

  }

  _setupIsFollowing() async{
    bool isFollowingUser = await DatabaseService.isFollowingUser(currentUserId: widget.currentUserId,userId: widget.userId);
    setState(() {
      isFollowing=isFollowingUser;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Instagram',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Billabong',
            fontSize: 35.0,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: usersRef.document(widget.userId).get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          User user = User.fromDoc(snapshot.data);

          return ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 0.0),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 50.0,
                      backgroundImage: user.profileImageUrl.isEmpty
                          ? AssetImage('assets/images/indir.jpg')
                          : CachedNetworkImageProvider(user.profileImageUrl),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Text(
                                    '12',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'posts',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    followerCount.toString(),
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'followers',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    followingCount.toString(),
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'following',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          _displayButton(user),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Container(
                      height: 80.0,
                      child: Text(
                        user.bio,
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ),
                    Divider(),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
