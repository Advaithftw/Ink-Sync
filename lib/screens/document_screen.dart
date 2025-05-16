import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink_sync/colors.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  

  @override
  ConsumerState<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController titleController = TextEditingController(text: 'Untitled Document');
  quill.QuillController _Controller = quill.QuillController.basic();
  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        actions : [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.lock,size : 16),

              label: const Text(
                'Share',
                style: TextStyle(
                  color: kBlackcolor,
                  fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style : ElevatedButton.styleFrom(
                  backgroundColor: kBlueColor,
                ),
              ),
    
          ),
        ],
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9.0),
          child: Row(children: [Image.asset('assets/images/logo.jpg',height : 40),
          const SizedBox(width: 10,),
          SizedBox(width : 180,child: TextField(
            decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder : OutlineInputBorder(
                borderSide: BorderSide(color: kBlueColor),
              ),
              contentPadding: EdgeInsets.only(left: 10)
            ),
            ),
            ),
          ],
                ),
        ),
      bottom : PreferredSize(
        preferredSize: const Size.fromHeight(1),
        
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: kGreyColor,
                width: 0.1,
              ),
            ),
          ),
          height: 1,
          
        ),  
      ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            quill.QuillSimpleToolbar(
              controller: _Controller,
              configurations: const quill.QuillSimpleToolbarConfigurations(),
            ),
            Expanded(child: SizedBox(
              child: Card(
                color: kWhitecolor,
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: quill.QuillEditor.basic(
                    controller: _Controller,
                    
                  
                  ),
                ),
              ),
            ))
          ]
        ),
      )
    );
  }
}