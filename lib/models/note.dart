class Note {
  String id;
  String? user;
  bool isRequest;
  DateTime? sentTime;
  String? notesName;
  String? messageBody;
  String? subject;
  String? filename;
  String? fileUrl;

  Note({
    this.id = "",
    this.user,
    this.isRequest = false,
    this.sentTime,
    this.subject,
    this.filename,
    this.notesName,
    this.messageBody,
    this.fileUrl,
  });
}
