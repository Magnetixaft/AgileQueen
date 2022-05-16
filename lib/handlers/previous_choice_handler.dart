import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PreviousChoiceHandler {
  static final PreviousChoiceHandler instance = PreviousChoiceHandler._();
  PreviousChoiceHandler._();

  void setPreviousOffice(String office) async{
    var previousChoices = await readPrevChoice();
    var newChoices = PreviousChoices(previousChoices.division, office);
    writeChoice(newChoices);
  }

  void setPreviousDivision(String division) async{
    var previousChoices = await readPrevChoice();
    var newChoices = PreviousChoices(division, previousChoices.office);
    writeChoice(newChoices);
  }

  /// Gets file with given txt-file.
  Future<File> get _localFile async {
    final pathFuture = await getApplicationDocumentsDirectory();
    final path = pathFuture.path;
    return File('$path/previous_choices.txt');
  }

  /// Reads file and returns contents as String.
  Future<PreviousChoices> readPrevChoice() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      var previousData = jsonDecode(contents);
      var division = previousData['division'] ?? 'null';
      var office = previousData['office'] ?? 'null';
      return PreviousChoices(division, office);
    } catch (e) {
      return PreviousChoices('error', 'error');
    }
  }

  /// Writes [choice] to the given txt-file.
  void writeChoice(PreviousChoices previousChoices) async {
    final file = await _localFile;
    var choiceMap = {'division': previousChoices.division, 'office':previousChoices.office};
    file.writeAsString(jsonEncode(choiceMap));
  }
}

class PreviousChoices {
  final String division;
  final String office;

  PreviousChoices(this.division, this.office);

  @override
  String toString() {
    return 'PreviousChoices{division: $division, office: $office}';
  }
}