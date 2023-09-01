import 'dart:async';

import 'package:docs_clone_flutter/models/document_model.dart';
import 'package:docs_clone_flutter/models/error_model.dart';
import 'package:docs_clone_flutter/repository/auth_repository.dart';
import 'package:docs_clone_flutter/repository/document_repository.dart';
import 'package:docs_clone_flutter/repository/socket_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:routemaster/routemaster.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController _titlecontroller =
      TextEditingController(text: "Untitled document");

  quill.QuillController? _controller;

  ErrorModel? errorModel;
  SocketRepository socketRepository = SocketRepository();

  @override
  void initState() {
    socketRepository.joinRoom(widget.id);
    fetchDocumentData();
    socketRepository.changeListener((data) {
      _controller?.compose(
          quill.Delta.fromJson(data['delta']),
          _controller?.selection ?? const TextSelection.collapsed(offset: 0),
          quill.ChangeSource.REMOTE);
    });
    super.initState();

    Timer.periodic(const Duration(seconds: 2), (timer) {
      socketRepository.autoSave({
        'room': widget.id,
        'delta': _controller?.document.toDelta().toJson(),
      });
    });
  }

  void fetchDocumentData() async {
    errorModel = await ref.read(documentRepositoryProvider).getDocumentById(
          ref.read(userProvider)!.token,
          widget.id,
        );

    print(errorModel!.error);

    if (errorModel!.data != null) {
      _titlecontroller.text = (errorModel!.data as DocumentModel).title;
      _controller = quill.QuillController(
        document: errorModel!.data.content.isEmpty
            ? quill.Document()
            : quill.Document.fromDelta(
                quill.Delta.fromJson(errorModel!.data.content),
              ),
        selection: const TextSelection.collapsed(offset: 0),
      );

      setState(() {});
    }

    _controller!.document.changes.listen((event) {
      if (event.source == quill.ChangeSource.LOCAL) {
        Map<String, dynamic> map = {
          'delta': event.change,
          'room': widget.id,
        };
        socketRepository.typing(map);
      }
    });
  }

  void updateTitle(WidgetRef ref, String value) async {
    ref.read(documentRepositoryProvider).updateTitle(
        token: ref.read(userProvider)!.token, id: widget.id, title: value);
  }

  @override
  void dispose() {
    _titlecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(
        body: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
          leading: Container(),
          backgroundColor: Colors.white,
          elevation: 2,
          title: Row(children: [
            GestureDetector(
              onTap: () {
                Routemaster.of(context).replace('/');
              },
              child: Image.asset(
                "assets/images/docs-logo.png",
                height: 30,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: 200,
              child: TextField(
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400, color: Colors.black),
                onSubmitted: ((value) => updateTitle(ref, value)),
                controller: _titlecontroller,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 10)),
              ),
            )
          ]),
          actions: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                            text:
                                'http://localhost:54354/#/document/${widget.id}'))
                        .then((value) => ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                                content: Text("Link copied to clipboard"))));
                  },
                  icon: const Icon(Icons.share),
                  label: const Text(
                    "Share",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  )),
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 0.1,
                ),
              ),
            ),
          )),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            quill.QuillToolbar.basic(controller: _controller!),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: quill.QuillEditor.basic(
                      controller: _controller!,
                      readOnly: false, // true for view only mode
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
