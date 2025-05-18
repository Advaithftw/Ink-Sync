import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:dart_quill_delta/dart_quill_delta.dart' as delta;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink_sync/colors.dart';
import 'package:ink_sync/models/document_model.dart';
import 'package:ink_sync/models/error_model.dart';
import 'package:ink_sync/repository/auth_repository.dart';
import 'package:ink_sync/repository/document_repository.dart';
import 'package:ink_sync/repository/socket_repository.dart';






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
  quill.QuillController _controller = quill.QuillController.basic();
  ErrorModel? errorModel;
  SocketRepository  socketRepository = SocketRepository();
  bool _isLoading = true;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    socketRepository.joinRoom(widget.id);
    fetchDocumentData();

    socketRepository.changeListener((data) {
      _controller?.compose(
        delta.Delta.fromJson(data['delta']),
        _controller?.selection ?? const TextSelection.collapsed(offset: 0),
        quill.ChangeSource.remote,
      );
    });
    Timer.periodic(const Duration(seconds: 3 ), (timer) {
      socketRepository.autoSave(<String, dynamic>{
        'delta': _controller.document.toDelta().toJson(),
        'room': widget.id,
      });
    });
  }

  void fetchDocumentData() async {
    setState(() {
      _isLoading = true;
    });
    
    ErrorModel errorModel = await ref.read(documentRepositoryProvider)
      .getDocumentById(ref.read(userProvider)!.token, widget.id);
    
    if(errorModel!.data != null) {
      titleController.text = (errorModel!.data as DocumentModel).title;
      _controller = quill.QuillController(
        document: errorModel!.data.content.isEmpty ? quill.Document() : quill.Document.fromDelta(delta.Delta.fromJson(errorModel!.data.content)),
        selection: const TextSelection.collapsed(offset: 0),
      );

    }
    
    setState(() {
      errorModel = errorModel;
      _isLoading = false;
    });

    _controller!.document.changes.listen((event)
    {
      if(event.source == quill.ChangeSource.local)
      {
        Map<String, dynamic> map = {
          'delta' : event.change.toJson(),
          'room': widget.id,
        };
        socketRepository.typing(map);
        
      }

    });

    
  }

  

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  void updateTitle(WidgetRef ref, String title) async {
    setState(() {
      _isSaving = true;
    });
    
    ref.read(documentRepositoryProvider).updateTitle(
      ref.read(userProvider)!.token,
      widget.id,
      title,
    );
    
    setState(() {
      _isSaving = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Document title updated'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  

void _showShareDialog() {
  final shareableLink = 'http://localhost:3000/#/document/${widget.id}';

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Share Document'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.link),
            title: Text('Copy link'),
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: shareableLink));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Link copied to clipboard')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Add collaborators'),
            onTap: () {
              Navigator.pop(context);
              
            },
          ),
          ListTile(
            leading: Icon(Icons.public),
            title: Text('Publish to web'),
            onTap: () {
              Navigator.pop(context);
              
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    if(_controller == null)
    {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: kBlueColor,
          ),
        ),
      );

    }
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: kBlueColor,
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Image.asset('assets/images/logo.jpg', height: 32),
            const SizedBox(width: 12),
            SizedBox(
              width: 180,
              child: TextField(
                controller: titleController,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kBlueColor),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  suffixIcon: _isSaving
                      ? Container(
                          width: 12,
                          height: 12,
                          padding: EdgeInsets.all(6),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kBlueColor,
                          ),
                        )
                      : Icon(Icons.check_circle, color: Colors.green, size: 16),
                ),
                onSubmitted: (value) {
                  updateTitle(ref, value);
                },
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.undo, color: Colors.grey[700]),
            onPressed: () {
              _controller.undo();
            },
            tooltip: 'Undo',
          ),
          IconButton(
            icon: Icon(Icons.redo, color: Colors.grey[700]),
            onPressed: () {
              _controller.redo();
            },
            tooltip: 'Redo',
          ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.more_vert, color: Colors.grey[700]),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              tooltip: 'More options',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _showShareDialog,
              icon: Icon(Icons.lock, size: 16),
              label: const Text(
                'Share',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlueColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
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
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: kBlueColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Document Options',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    titleController.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.download),
              title: Text('Export PDF'),
              onTap: () {
                Navigator.pop(context);
                // Handle PDF export
              },
            ),
            ListTile(
              leading: Icon(Icons.print),
              title: Text('Print'),
              onTap: () {
                Navigator.pop(context);
                // Handle print
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Version history'),
              onTap: () {
                Navigator.pop(context);
                // Handle version history
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Document settings'),
              onTap: () {
                Navigator.pop(context);
                // Handle settings
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[100],
            padding: EdgeInsets.symmetric(vertical: 4),
            child: quill.QuillSimpleToolbar(
              controller: _controller,
              configurations: const quill.QuillSimpleToolbarConfigurations(),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      // A4 paper
                      Container(
                        width: 595, // Standard A4 width at 72 DPI
                        constraints: BoxConstraints(minHeight: 842), // Standard A4 height but allows expansion
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 60.0),
                          child: quill.QuillEditor.basic(
                            controller: _controller,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  'Last edited just now',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Spacer(),
                Text(
                  'Saved',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kBlueColor,
        child: Icon(Icons.comment),
        onPressed: () {
          // Show comments panel
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Comments panel')),
          );
        },
      ),
    );
  }
}