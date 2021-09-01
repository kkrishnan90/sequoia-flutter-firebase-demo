// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController txtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes Fire'),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter notes here...',
              ),
              controller: txtController,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (txtController.text.isNotEmpty) {
                FirebaseFirestore.instance
                    .collection('notes')
                    .add({'text': '${txtController.text}', 'completed': false});
                print(txtController.text);
                txtController.clear();
              } else {
                final snackbar = SnackBar(content: Text('Please enter notes'));
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
              }
            },
            child: Text('Add note'),
          ),
          Expanded(
            flex: 1,
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('notes').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          FirebaseFirestore.instance
                              .collection('notes')
                              .doc(documents[index].id)
                              .update({
                            'completed': !documents[index].data()['completed']
                          });
                        },
                        child: ListTile(
                          title: Text(documents[index].data()['text']),
                          trailing: documents[index].data()['completed']
                              ? Icon(Icons.check_circle_outline)
                              : Icon(Icons.radio_button_unchecked),
                        ),
                      );
                    },
                  );
                }
                if (snapshot.hasError) {
                  print(snapshot.error.toString());
                  return Text("Error in loading data");
                }
                return Text("loading error");
              },
            ),
          ),
        ],
      ),
    );
  }
}
