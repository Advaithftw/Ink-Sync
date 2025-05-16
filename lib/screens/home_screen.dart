import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink_sync/colors.dart';
import 'package:ink_sync/common/widgets/loader.dart';
import 'package:ink_sync/models/document_model.dart';
import 'package:ink_sync/models/error_model.dart';
import 'package:ink_sync/repository/auth_repository.dart';
import 'package:ink_sync/repository/document_repository.dart';
import 'package:intl/intl.dart'; 
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void signOut(WidgetRef ref) {
    ref.read(authRepositoryProvider).signOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDocument(BuildContext context, WidgetRef ref) async {
    String token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
    final snackbar = ScaffoldMessenger.of(context);

    final errorModel = await ref.read(documentRepositoryProvider).createDocument(token);
    if (errorModel.data != null) {
      navigator.push('/document/${errorModel.data.id}');
    } else {
      snackbar.showSnackBar(
        SnackBar(
          content: Text(errorModel.error!),
          backgroundColor: kRedColor,
        ),
      );
    }
  }

  void navigateToDocument(BuildContext context, String id) {
    Routemaster.of(context).push('/document/$id');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: kWhitecolor,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'My Documents',
          style: const TextStyle(
            color: kBlackcolor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => createDocument(context, ref),
            icon: const Icon(Icons.add_circle_outline, color: kBlackcolor),
            tooltip: 'New Document',
          ),
          IconButton(
            onPressed: () => signOut(ref),
            icon: const Icon(Icons.logout, color: kRedColor),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: ref.watch(documentRepositoryProvider).getDocuments(user!.token),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }

            if (snapshot.hasError || snapshot.data == null || snapshot.data!.data == null) {
              return Center(
                child: Text(
                  'Failed to load documents.',
                  style: TextStyle(color: kRedColor),
                ),
              );
            }

            List<DocumentModel> documents = List<DocumentModel>.from(snapshot.data!.data);

            if (documents.isEmpty) {
              return const Center(
                child: Text(
                  "No documents yet.\nTap + to create your first one!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user.name}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final doc = documents[index];
                      final formattedDate = DateFormat.yMMMd().add_jm().format(doc.createdAt);

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          onTap: () => navigateToDocument(context, doc.id),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          title: Text(
                            doc.title.isEmpty ? "Untitled Document" : doc.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text("Created on $formattedDate"),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
