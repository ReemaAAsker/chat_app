import 'package:chat_app/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageStreamBuilder extends StatelessWidget {
  const MessageStreamBuilder({super.key, required this.firebaseFire});
  final FirebaseFirestore firebaseFire;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firebaseFire.collection(collectionName).snapshots(),
      builder: (context, snapshot) {
        List<MessageWidget> messagesWidgets = [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(backgroundColor: Colors.orange),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Something went wrong',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Center(
            child: Text('No Messages', style: TextStyle(color: Colors.grey)),
          );
        }

        final List<QueryDocumentSnapshot<Object?>> messages =
            snapshot.data!.docs;

        for (var msg in messages) {
          final msgText = msg.get('text');
          final msgSender = msg.get('sender');
          bool isSenderMe = signedUser.email == msgSender;

          final messageWidget = MessageWidget(
            msgtext: msgText,
            senderEmail: msgSender,
            isSenderMe: isSenderMe,
          );
          messagesWidgets.add(messageWidget);
        }
        return Expanded(child: ListView(children: messagesWidgets));
      },
    );
  }
}

class MessageWidget extends StatelessWidget {
  final String senderEmail;
  final String msgtext;
  final bool isSenderMe;
  const MessageWidget({
    super.key,
    required this.msgtext,
    required this.senderEmail,
    required this.isSenderMe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isSenderMe
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          senderEmail,
          style: TextStyle(
            color: isSenderMe ? Colors.yellow[800]! : Colors.blue[800]!,
          ),
        ),
        Container(
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSenderMe ? Colors.blue[800]! : Colors.yellow[800]!,
            ),
            borderRadius: BorderRadius.only(
              topLeft: isSenderMe ? Radius.circular(0) : Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
              topRight: isSenderMe ? Radius.circular(10) : Radius.circular(0),
            ),
            color: Colors.grey[300],
          ),
          child: Text(msgtext),
        ),
      ],
    );
  }
}
