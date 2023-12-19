import 'dart:io';

import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

import 'template.dart';

const softwarePackage = 'software-package';
const displayImage = 'display-image';
const fullSizeImage = 'full-size-image';
const flavor = 'flavor';
const bundleIdentifier = 'bundle-identifier';
const bundleVersion = 'bundle-version';

void main(List<String> args) {
  if (args.isEmpty) {
    print("""
--$softwarePackage\t\t:for software package url
--$displayImage   \t\t:for display-image url
--$fullSizeImage \t\t:for full-size-image url
--$flavor \t\t:for flavor of build that you want
""");
  }

  final parser = ArgParser()
    ..addOption(softwarePackage, abbr: 's')
    ..addOption(flavor, abbr: 'f')
    ..addOption(displayImage, abbr: 'i')
    ..addOption(fullSizeImage);

  ArgResults argResults = parser.parse(args);

  // Read the content of the YAML file
  final File yamlFile = File('pubspec.yaml');
  if (!yamlFile.existsSync()) {
    print('Error: YAML file not found.');
    return;
  }

  final String yamlContent = yamlFile.readAsStringSync();

  // Parse the YAML content into a YamlMap
  final YamlMap yamlMap = loadYaml(yamlContent);

  // Cast the YamlMap to Map<String, dynamic>
  final Map<String, dynamic> typedMap = yamlMap.cast<String, dynamic>();

  // Check if the YAML content was parsed successfully

  if (argResults[softwarePackage] == null || argResults[displayImage] == null || argResults[fullSizeImage] == null) {
    throw ('please enter option $softwarePackage, $displayImage, $fullSizeImage');
  }

  String bundleIdentifierParams = "${typedMap['flavorizr']['flavors']['${argResults[flavor]}']['ios']['bundleId']}";
  String bundleVersionParams = "1.0";
  String titleParams = "${typedMap['flavorizr']['flavors']['${argResults[flavor]}']['app']['name']}";

  final content = getTemplateContentWithEdit(
    argResults,
    bundleIdentifier: bundleIdentifierParams,
    bundleVersion: bundleVersionParams,
    title: titleParams,
  );

  print("result: $content");

  if (content == null) {
    throw ('!content for create file invalid');
  }

  saveDataToFile("build/ios/ipa/ats-connect.plist", content);
}

String? getTemplateContentWithEdit(ArgResults argResults,
    {required String bundleIdentifier, required String bundleVersion, required String title}) {
  // print(template);

  return template
      .replaceAll("%{$softwarePackage}", argResults[softwarePackage])
      .replaceAll("%{$displayImage}", argResults[displayImage])
      .replaceAll("%{$fullSizeImage}", argResults[fullSizeImage])
      .replaceAll("%{bundle-identifier}", bundleIdentifier)
      .replaceAll("%{bundle-version}", bundleVersion)
      .replaceAll("%{title}", title);
}

void saveDataToFile(String path, String template) {
  File fileGenerated = File(path);
  if (fileGenerated.existsSync()) {
    fileGenerated.deleteSync();
  }
  fileGenerated.createSync(recursive: true);
  fileGenerated.writeAsStringSync(template);
}
