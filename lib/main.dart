import 'package:args/args.dart';
import 'package:ats_cli/build_over_the_air/main.dart' as build_the_air;

const commandBuild = 'build';
const commandGenerate = 'generate';
void main(List<String> argruments) {
  final parser = ArgParser()
    ..addCommand(commandBuild)
    ..addCommand(commandGenerate);

  ArgResults argResults = parser.parse(argruments);

  if (argResults.command?.name == null) {
    throw ('invalid command name');
  }

  switch (argResults.command?.name) {
    case commandBuild:
      build_the_air.main(argruments);
      break;
    case commandGenerate:
      break;

    default:
  }
}
