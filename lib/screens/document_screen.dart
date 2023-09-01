import 'package:docs_clone_flutter/models/document_model.dart';
import 'package:docs_clone_flutter/models/error_model.dart';
import 'package:docs_clone_flutter/repository/auth_repository.dart';
import 'package:docs_clone_flutter/repository/document_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController _titlecontroller =
      TextEditingController(text: "Untitled document");

  quill.QuillController _controller = quill.QuillController.basic();

  ErrorModel? errorModel;

  @override
  void initState() {
    fetchDocumentData();
    super.initState();
  }

  void fetchDocumentData() async {
    errorModel = await ref.read(documentRepositoryProvider).getDocumentById(
          ref.read(userProvider)!.token,
          widget.id,
        );

    print(errorModel!.error);

    if (errorModel!.data != null) {
      _titlecontroller.text = (errorModel!.data as DocumentModel).title;

      setState(() {});
    }
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
    return Scaffold(
      appBar: AppBar(
          leading: Container(),
          backgroundColor: Colors.white,
          elevation: 2,
          title: Row(children: [
            Image.asset(
              "assets/images/docs-logo.png",
              height: 30,
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
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.lock),
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
            quill.QuillToolbar.basic(controller: _controller),
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
                      controller: _controller,
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
