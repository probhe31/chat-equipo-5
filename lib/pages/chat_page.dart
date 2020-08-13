import 'package:flutter/material.dart';
import 'package:flutter_flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class ChatPage extends StatefulWidget {
  static const String id = 'chat_page';
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      print(user);
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  /*
  void getMessages() async {
    final messages = await _firestore.collection('messages').getDocuments();
    for (var message in messages.documents) {
      print(message);
    }
  }
  */

  /*
  void messagesStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.documents) {
        print(message);
    }
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      var now = new DateTime.now().add(new Duration(days: 4));
                      String time =
                          (now.hour.toString() + ":" + now.minute.toString());

                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                        'time': time,
                        'date': now.toString(),
                        'timestamp': now.millisecondsSinceEpoch
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        //stream: _firestore.collection('messages').snapshots(),
        stream: _firestore
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ));
          }
          final messages = snapshot.data.documents;
          List<MessageBubble> messageBubbles = [];

          /*CollectionReference collectionsReference =
              Firestore.instance.collection("messages");

          Query collectionReference =
              Firestore.instance.collection("messages").orderBy('date').snapshots().toList();*/
          int index = 0;
          DateTime first;
          DateTime last;
          final DateFormat formatter = DateFormat('yMd');
          first = DateTime.tryParse(messages.last.data['date']);
          last = DateTime.tryParse(messages.first.data['date']);

          print("first " + first.toString());
          print("last " + last.toString());

          for (var message in messages) {
            final messageText = message.data['text'];
            final messageSender = message.data['sender'];
            final messageTime = message.data['time'];
            final messageDate = message.data['date'];
            final messageTimeStamp = message.data['timestamp'];
            var messagedatetime = DateTime.tryParse(messageDate);

            if (messagedatetime != null) {
              final currentUser = loggedInUser.email;

              if (messagedatetime.difference(last).inDays <= -1) {
                final messagDate2 =
                    DateBubble(date: formatter.format(last).toString());
                messageBubbles.add(messagDate2);

                last = messagedatetime;
              }

              final messageBubble = MessageBubble(
                  sender: messageSender,
                  text: messageText,
                  isMe: currentUser == messageSender,
                  time: messageTime,
                  date: messageDate,
                  timestamp: messageTimeStamp);
              messageBubbles.add(messageBubble);

              //print("index " + index.toString());

            }
            index++;
          }

          if (last != null) {
            final messagDate1 =
                DateBubble(date: formatter.format(last).toString());
            messageBubbles.add(messagDate1);
          }

          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: messageBubbles,
            ),
          );
        });
  }
}

class DateBubble extends MessageBubble {
  DateBubble({this.date});
  final String date;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Material(
            //borderRadius: BorderRadius.circular(30.0),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ),
            elevation: 5.0,
            color: Colors.green,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                date,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {this.sender,
      this.text,
      this.isMe,
      this.time,
      this.date,
      this.timestamp});
  final String sender;
  final String text;
  final String time;
  final String date;
  final bool isMe;
  final int timestamp;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender + " " + time,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            //borderRadius: BorderRadius.circular(30.0),
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black54,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
