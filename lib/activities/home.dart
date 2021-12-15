import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:swazai_assignment/state_mamanement_provider.dart/home_provider.dart';
import 'package:swazai_assignment/utils/routes.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late HomeProvider provider;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? user = FirebaseAuth.instance.currentUser;
  CollectionReference dataCollection =
      FirebaseFirestore.instance.collection('data');

  final _formKey = GlobalKey<FormState>();
  final _updateFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Swazai Assignment"),
        actions: [
          IconButton(
              onPressed: () => showSignoutoutAlert(),
              icon: const Icon(Icons.logout))
        ],
      ),
      body: ChangeNotifierProvider(
        create: (context) => HomeProvider(),
        child: Builder(
          builder: (context) => Consumer<HomeProvider>(
            builder: (context, _provider, child) {
              provider = _provider;

              if (!provider.build) {
                WidgetsBinding.instance!
                    .addPostFrameCallback((_) => fetchData());
              }

              return SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      // Welcome Card
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          margin: const EdgeInsets.all(15),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Welcome back,"),
                                const SizedBox(height: 10),
                                const Text(
                                  "User.",
                                  style: TextStyle(fontSize: 28),
                                ),
                                Text("UID: ${user!.uid}"),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          margin: const EdgeInsets.all(15),
                          child: provider.documents == null
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : provider.documents!.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.hourglass_empty,
                                            size: 40,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "Empty Records",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                              "Tap on 'Add Record' button below to start."),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: provider.documents!.length,
                                      itemBuilder: (context, index) {
                                        DateTime dateTime = DateTime.parse(
                                            provider.documents![index]
                                                ['timestamp']);
                                        String dateTimeFormated = formatDate(
                                          dateTime,
                                          [
                                            hh,
                                            ':',
                                            nn,
                                            ' ',
                                            am,
                                            ' ',
                                            dd,
                                            '-',
                                            mm,
                                            '-',
                                            yyyy
                                          ],
                                        );
                                        return ListTile(
                                          title: Text(
                                              "Weight: ${provider.documents![index]['weight']}"),
                                          subtitle: Text(
                                              "Recorded at: $dateTimeFormated"),
                                          trailing: Wrap(
                                            children: [
                                              IconButton(
                                                onPressed: () =>
                                                    _updateEntryDialog(
                                                        context, index),
                                                icon: const Icon(Icons.edit),
                                              ),
                                              IconButton(
                                                onPressed: () =>
                                                    showDeleteAlert(index),
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        child: ElevatedButton(
                            onPressed: () => _addEntryDialog(context),
                            child: Text("Add New Entry")),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _addEntryDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Entry'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: provider.weightController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                labelText: "Current Weight (KG)",
                hintText: "Enter your current weight in KG.",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 1,
                  ),
                ),
              ),
              validator: (value) {
                if (value!.trim().isEmpty) {
                  return "Enter current weight to continue";
                }
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              // ignore: prefer_const_constructors
              child: Text('OK'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  addEntry();
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateEntryDialog(BuildContext context, int index) async {
    provider.updateWeightController.text = provider.documents![index]['weight'];
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Weight'),
          content: Form(
            key: _updateFormKey,
            child: TextFormField(
              controller: provider.updateWeightController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                labelText: "Weight (KG)",
                hintText: "Enter weight in KG.",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 1,
                  ),
                ),
              ),
              validator: (value) {
                if (value!.trim().isEmpty) {
                  return "Enter weight to update";
                }
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              // ignore: prefer_const_constructors
              child: Text('OK'),
              onPressed: () {
                if (_updateFormKey.currentState!.validate()) {
                  updateEntry(index);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  fetchData() {
    provider.build = true;
    dataCollection
        .orderBy("timestamp", descending: true)
        .where("_uid", isEqualTo: user!.uid)
        .snapshots()
        .listen((snapshot) {
      provider.documents = snapshot.docs;
    });
  }

  deleteEntry(int index) {
    dataCollection
        .doc(provider.documents![index].id)
        .delete()
        .then((value) => showSnackbar("Entry deleted successfully"));
  }

  Future<void> addEntry() {
    DateTime dateTime = DateTime.now();
    String dateTimeFormated = formatDate(
      dateTime,
      [yyyy, '-', mm, '-', dd, ' ', hh, ':', nn, ':', ss],
    );

    String weight = provider.weightController.text.trim();
    provider.weightController.text = "";
    return dataCollection.add({
      '_uid': user!.uid,
      'weight': weight,
      'timestamp': dateTimeFormated,
    });
  }

  updateEntry(index) {
    String weight = provider.updateWeightController.text.trim();
    provider.updateWeightController.text = "";
    dataCollection
        .doc(provider.documents![index].id)
        .update({"weight": weight}).then(
            (value) => showSnackbar("Entry updated successfully"));
  }

  showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  showDeleteAlert(int index) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Delete Entry"),
        content: const Text("Do you really want to delete?"),
        actions: <Widget>[
          TextButton(
            child: const Text("No"),
            onPressed: () => {
              Navigator.pop(context),
            },
          ),
          TextButton(
            child: const Text("Delete"),
            onPressed: () => {
              deleteEntry(index),
              Navigator.pop(context),
            },
          ),
        ],
      ),
    );
  }

  showSignoutoutAlert() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Signout"),
        content: const Text("Do you really want to signout?"),
        actions: <Widget>[
          TextButton(
            child: const Text("No"),
            onPressed: () => {
              Navigator.pop(context),
            },
          ),
          TextButton(
            child: const Text("Signout"),
            onPressed: () => {signout()},
          ),
        ],
      ),
    );
  }

  signout() {
    Navigator.of(context).pop();
    _auth.signOut().then((value) => Navigator.of(context)
        .pushNamedAndRemoveUntil(loginRoute, (route) => false));
  }
}
