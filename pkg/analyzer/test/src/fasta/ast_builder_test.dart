// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/src/dart/error/syntactic_errors.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../diagnostics/parser_diagnostics.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AstBuilderTest);
  });
}

@reflectiveTest
class AstBuilderTest extends ParserDiagnosticsTest {
  void test_class_augment() {
    var parseResult = parseStringWithErrors(r'''
augment class A {}
''');
    parseResult.assertNoErrors();

    var node = parseResult.findNode.classDeclaration('class A {}');
    assertParsedNodeText(node, r'''
ClassDeclaration
  augmentKeyword: augment
  classKeyword: class
  name: A
  leftBracket: {
  rightBracket: }
''');
  }

  void test_class_commentReferences_beforeAbstract() {
    var parseResult = parseStringWithErrors(r'''
/** [String] */ abstract class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.classDeclaration('class A');
    assertParsedNodeText(
        node,
        r'''
ClassDeclaration
  documentationComment: Comment
    references
      CommentReference
        expression: SimpleIdentifier
          token: String @5
    tokens
      /** [String] */
        offset: 0
  abstractKeyword: abstract @16
  classKeyword: class @25
  name: A @31
  leftBracket: { @33
  rightBracket: } @34
''',
        withOffsets: true);
  }

  void test_class_commentReferences_beforeAnnotation() {
    var parseResult = parseStringWithErrors(r'''
/// See [int] and [String]
/// and [Object].
@Annotation
abstract class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.classDeclaration('class A');
    assertParsedNodeText(
        node,
        r'''
ClassDeclaration
  documentationComment: Comment
    references
      CommentReference
        expression: SimpleIdentifier
          token: int @9
      CommentReference
        expression: SimpleIdentifier
          token: String @19
      CommentReference
        expression: SimpleIdentifier
          token: Object @36
    tokens
      /// See [int] and [String]
        offset: 0
      /// and [Object].
        offset: 27
  metadata
    Annotation
      atSign: @ @45
      name: SimpleIdentifier
        token: Annotation @46
  abstractKeyword: abstract @57
  classKeyword: class @66
  name: A @72
  leftBracket: { @74
  rightBracket: } @75
''',
        withOffsets: true);
  }

  void test_class_commentReferences_complex() {
    var parseResult = parseStringWithErrors(r'''
/// This dartdoc comment [should] be ignored
@Annotation
/// This dartdoc comment is [included].
// a non dartdoc comment [inbetween]
/// See [int] and [String] but `not [a]`
/// ```
/// This [code] block should be ignored
/// ```
/// and [Object].
abstract class A {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.classDeclaration('class A');
    assertParsedNodeText(
        node,
        r'''
ClassDeclaration
  documentationComment: Comment
    references
      CommentReference
        expression: SimpleIdentifier
          token: included @86
      CommentReference
        expression: SimpleIdentifier
          token: int @143
      CommentReference
        expression: SimpleIdentifier
          token: String @153
      CommentReference
        expression: SimpleIdentifier
          token: Object @240
    tokens
      /// This dartdoc comment is [included].
        offset: 57
      /// See [int] and [String] but `not [a]`
        offset: 134
      /// ```
        offset: 175
      /// This [code] block should be ignored
        offset: 183
      /// ```
        offset: 223
      /// and [Object].
        offset: 231
  metadata
    Annotation
      atSign: @ @45
      name: SimpleIdentifier
        token: Annotation @46
  abstractKeyword: abstract @249
  classKeyword: class @258
  name: A @264
  leftBracket: { @266
  rightBracket: } @267
''',
        withOffsets: true);
  }

  void test_class_extendsClause_recordType() {
    var parseResult = parseStringWithErrors(r'''
class C extends (int, int) {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.classDeclaration('class C');
    assertParsedNodeText(
        node,
        r'''
ClassDeclaration
  classKeyword: class @0
  name: C @6
  leftBracket: { @27
  rightBracket: } @28
''',
        withOffsets: true);
  }

  void test_class_implementsClause_recordType() {
    var parseResult = parseStringWithErrors(r'''
class C implements (int, int) {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.classDeclaration('class C');
    assertParsedNodeText(
        node,
        r'''
ClassDeclaration
  classKeyword: class @0
  name: C @6
  implementsClause: ImplementsClause
    implementsKeyword: implements @8
  leftBracket: { @30
  rightBracket: } @31
''',
        withOffsets: true);
  }

  void test_class_macro() {
    var parseResult = parseStringWithErrors(r'''
macro class A {}
''');
    parseResult.assertNoErrors();

    var node = parseResult.findNode.classDeclaration('class A {}');
    assertParsedNodeText(node, r'''
ClassDeclaration
  macroKeyword: macro
  classKeyword: class
  name: A
  leftBracket: {
  rightBracket: }
''');
  }

  void test_class_withClause_recordType() {
    var parseResult = parseStringWithErrors(r'''
class C with (int, int) {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.classDeclaration('class C');
    assertParsedNodeText(
        node,
        r'''
ClassDeclaration
  classKeyword: class @0
  name: C @6
  withClause: WithClause
    withKeyword: with @8
  leftBracket: { @24
  rightBracket: } @25
''',
        withOffsets: true);
  }

  void test_classAlias_macro() {
    var parseResult = parseStringWithErrors(r'''
mixin M {}
macro class A = Object with M;
''');
    parseResult.assertNoErrors();

    var node = parseResult.findNode.classTypeAlias('class A');
    assertParsedNodeText(node, r'''
ClassTypeAlias
  typedefKeyword: class
  name: A
  equals: =
  macroKeyword: macro
  superclass: NamedType
    name: SimpleIdentifier
      token: Object
  withClause: WithClause
    withKeyword: with
    mixinTypes
      NamedType
        name: SimpleIdentifier
          token: M
  semicolon: ;
''');
  }

  void test_classTypeAlias_implementsClause_recordType() {
    var parseResult = parseStringWithErrors(r'''
class C = Object with M implements (int, int);
mixin M {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.classTypeAlias('class C');
    assertParsedNodeText(
        node,
        r'''
ClassTypeAlias
  typedefKeyword: class @0
  name: C @6
  equals: = @8
  superclass: NamedType
    name: SimpleIdentifier
      token: Object @10
  withClause: WithClause
    withKeyword: with @17
    mixinTypes
      NamedType
        name: SimpleIdentifier
          token: M @22
  implementsClause: ImplementsClause
    implementsKeyword: implements @24
  semicolon: ; @45
''',
        withOffsets: true);
  }

  void test_classTypeAlias_withClause_recordType() {
    var parseResult = parseStringWithErrors(r'''
class C = Object with (int, int);
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.classTypeAlias('class C');
    assertParsedNodeText(
        node,
        r'''
ClassTypeAlias
  typedefKeyword: class @0
  name: C @6
  equals: = @8
  superclass: NamedType
    name: SimpleIdentifier
      token: Object @10
  withClause: WithClause
    withKeyword: with @17
  semicolon: ; @32
''',
        withOffsets: true);
  }

  void test_constructor_factory_misnamed() {
    var parseResult = parseStringWithErrors(r'''
class A {
  factory B() => null;
}
''');
    parseResult.assertNoErrors();

    var node = parseResult.findNode.constructor('B()');
    assertParsedNodeText(node, r'''
ConstructorDeclaration
  factoryKeyword: factory
  returnType: SimpleIdentifier
    token: B
  parameters: FormalParameterList
    leftParenthesis: (
    rightParenthesis: )
  body: ExpressionFunctionBody
    functionDefinition: =>
    expression: NullLiteral
      literal: null
    semicolon: ;
''');
  }

  void test_constructor_wrongName() {
    var parseResult = parseStringWithErrors(r'''
class A {
  B() : super();
}
''');
    parseResult.assertErrors([
      error(ParserErrorCode.INVALID_CONSTRUCTOR_NAME, 12, 1),
    ]);

    var node = parseResult.findNode.constructor('B()');
    assertParsedNodeText(node, r'''
ConstructorDeclaration
  returnType: SimpleIdentifier
    token: B
  parameters: FormalParameterList
    leftParenthesis: (
    rightParenthesis: )
  separator: :
  initializers
    SuperConstructorInvocation
      superKeyword: super
      argumentList: ArgumentList
        leftParenthesis: (
        rightParenthesis: )
  body: EmptyFunctionBody
    semicolon: ;
''');
  }

  void test_enum_constant_name_dot() {
    var parseResult = parseStringWithErrors(r'''
enum E {
  v.
}
''');
    parseResult.assertErrors([
      error(ParserErrorCode.MISSING_IDENTIFIER, 14, 1),
      error(ParserErrorCode.EXPECTED_TOKEN, 14, 1),
    ]);

    var node = parseResult.findNode.enumConstantDeclaration('v.');
    assertParsedNodeText(node, r'''
EnumConstantDeclaration
  name: v
  arguments: EnumConstantArguments
    constructorSelector: ConstructorSelector
      period: .
      name: SimpleIdentifier
        token: <empty> <synthetic>
    argumentList: ArgumentList
      leftParenthesis: ( <synthetic>
      rightParenthesis: ) <synthetic>
''');
  }

  void test_enum_constant_name_dot_identifier_semicolon() {
    var parseResult = parseStringWithErrors(r'''
enum E {
  v.named;
}
''');
    parseResult.assertErrors([
      error(ParserErrorCode.EXPECTED_TOKEN, 13, 5),
    ]);

    var node = parseResult.findNode.enumConstantDeclaration('v.');
    assertParsedNodeText(node, r'''
EnumConstantDeclaration
  name: v
  arguments: EnumConstantArguments
    constructorSelector: ConstructorSelector
      period: .
      name: SimpleIdentifier
        token: named
    argumentList: ArgumentList
      leftParenthesis: ( <synthetic>
      rightParenthesis: ) <synthetic>
''');
  }

  void test_enum_constant_name_dot_semicolon() {
    var parseResult = parseStringWithErrors(r'''
enum E {
  v.;
}
''');
    parseResult.assertErrors([
      error(ParserErrorCode.EXPECTED_TOKEN, 13, 1),
      error(ParserErrorCode.MISSING_IDENTIFIER, 13, 1),
    ]);

    var node = parseResult.findNode.enumConstantDeclaration('v.');
    assertParsedNodeText(node, r'''
EnumConstantDeclaration
  name: v
  arguments: EnumConstantArguments
    constructorSelector: ConstructorSelector
      period: .
      name: SimpleIdentifier
        token: <empty> <synthetic>
    argumentList: ArgumentList
      leftParenthesis: ( <synthetic>
      rightParenthesis: ) <synthetic>
''');
  }

  void test_enum_constant_name_typeArguments_dot() {
    var parseResult = parseStringWithErrors(r'''
enum E {
  v<int>.
}
''');
    parseResult.assertErrors([
      error(ParserErrorCode.MISSING_IDENTIFIER, 19, 1),
      error(ParserErrorCode.EXPECTED_TOKEN, 19, 1),
    ]);

    var node = parseResult.findNode.enumConstantDeclaration('v<int>.');
    assertParsedNodeText(node, r'''
EnumConstantDeclaration
  name: v
  arguments: EnumConstantArguments
    typeArguments: TypeArgumentList
      leftBracket: <
      arguments
        NamedType
          name: SimpleIdentifier
            token: int
      rightBracket: >
    constructorSelector: ConstructorSelector
      period: .
      name: SimpleIdentifier
        token: <empty> <synthetic>
    argumentList: ArgumentList
      leftParenthesis: ( <synthetic>
      rightParenthesis: ) <synthetic>
''');
  }

  void test_enum_constant_name_typeArguments_dot_semicolon() {
    var parseResult = parseStringWithErrors(r'''
enum E {
  v<int>.;
}
''');
    parseResult.assertErrors([
      error(ParserErrorCode.MISSING_IDENTIFIER, 18, 1),
      error(ParserErrorCode.EXPECTED_TOKEN, 18, 1),
    ]);

    var node = parseResult.findNode.enumConstantDeclaration('v<int>');
    assertParsedNodeText(
        node,
        r'''
EnumConstantDeclaration
  name: v
  arguments: EnumConstantArguments
    typeArguments: TypeArgumentList
      leftBracket: <
      arguments
        NamedType
          name: SimpleIdentifier
            token: int
      rightBracket: >
    constructorSelector: ConstructorSelector
      period: .
      name: SimpleIdentifier
        token: <empty> <synthetic>
    argumentList: ArgumentList
      leftParenthesis: ( <synthetic>
      rightParenthesis: ) <synthetic>
''',
        withCheckingLinking: true);
  }

  void test_enum_constant_withTypeArgumentsWithoutArguments() {
    var parseResult = parseStringWithErrors(r'''
enum E<T> {
  v<int>;
}
''');
    parseResult.assertErrors([
      error(ParserErrorCode.EXPECTED_TOKEN, 19, 1),
    ]);

    var node = parseResult.findNode.enumConstantDeclaration('v<int>');
    assertParsedNodeText(node, r'''
EnumConstantDeclaration
  name: v
  arguments: EnumConstantArguments
    typeArguments: TypeArgumentList
      leftBracket: <
      arguments
        NamedType
          name: SimpleIdentifier
            token: int
      rightBracket: >
    argumentList: ArgumentList
      leftParenthesis: ( <synthetic>
      rightParenthesis: ) <synthetic>
''');
  }

  void test_enum_semicolon_null() {
    var parseResult = parseStringWithErrors(r'''
enum E {
  v
}
''');
    parseResult.assertNoErrors();

    var node = parseResult.findNode.enumDeclaration('enum E');
    assertParsedNodeText(node, r'''
EnumDeclaration
  enumKeyword: enum
  name: E
  leftBracket: {
  constants
    EnumConstantDeclaration
      name: v
  rightBracket: }
''');
  }

  void test_enum_semicolon_optional() {
    var parseResult = parseStringWithErrors(r'''
enum E {
  v;
}
''');
    parseResult.assertNoErrors();

    var node = parseResult.findNode.enumDeclaration('enum E');
    assertParsedNodeText(node, r'''
EnumDeclaration
  enumKeyword: enum
  name: E
  leftBracket: {
  constants
    EnumConstantDeclaration
      name: v
  semicolon: ;
  rightBracket: }
''');
  }

  void test_extension_onClause_recordType() {
    var parseResult = parseStringWithErrors(r'''
extension E on (int, int) {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.extensionDeclaration('extension E');
    assertParsedNodeText(
        node,
        r'''
ExtensionDeclaration
  extensionKeyword: extension @0
  name: E @10
  onKeyword: on @12
  extendedType: RecordTypeAnnotation
    leftParenthesis: ( @15
    positionalFields
      RecordTypeAnnotationPositionalField
        type: NamedType
          name: SimpleIdentifier
            token: int @16
      RecordTypeAnnotationPositionalField
        type: NamedType
          name: SimpleIdentifier
            token: int @21
    rightParenthesis: ) @24
  leftBracket: { @26
  rightBracket: } @27
''',
        withOffsets: true);
  }

  void test_getter_sameNameAsClass() {
    var parseResult = parseStringWithErrors(r'''
class A {
  get A => 0;
}
''');
    parseResult.assertErrors([
      error(ParserErrorCode.MEMBER_WITH_CLASS_NAME, 16, 1),
    ]);

    var node = parseResult.findNode.methodDeclaration('get A');
    assertParsedNodeText(node, r'''
MethodDeclaration
  propertyKeyword: get
  name: A
  body: ExpressionFunctionBody
    functionDefinition: =>
    expression: IntegerLiteral
      literal: 0
    semicolon: ;
''');
  }

  void test_library_augment() {
    var parseResult = parseStringWithErrors(r'''
library augment 'a.dart';
''');
    parseResult.assertNoErrors();

    var node = parseResult.findNode.libraryAugmentation('library');
    assertParsedNodeText(node, r'''
LibraryAugmentationDirective
  libraryKeyword: library
  augmentKeyword: augment
  uri: SimpleStringLiteral
    literal: 'a.dart'
  semicolon: ;
''');
  }

  void test_mixin_implementsClause_recordType() {
    var parseResult = parseStringWithErrors(r'''
class C {}
mixin M on C implements (int, int) {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.mixinDeclaration('mixin M');
    assertParsedNodeText(
        node,
        r'''
MixinDeclaration
  mixinKeyword: mixin @11
  name: M @17
  onClause: OnClause
    onKeyword: on @19
    superclassConstraints
      NamedType
        name: SimpleIdentifier
          token: C @22
  implementsClause: ImplementsClause
    implementsKeyword: implements @24
  leftBracket: { @46
  rightBracket: } @47
''',
        withOffsets: true);
  }

  void test_mixin_onClause_recordType() {
    var parseResult = parseStringWithErrors(r'''
mixin M on (int, int) {}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.mixinDeclaration('mixin M');
    assertParsedNodeText(
        node,
        r'''
MixinDeclaration
  mixinKeyword: mixin @0
  name: M @6
  onClause: OnClause
    onKeyword: on @8
  leftBracket: { @22
  rightBracket: } @23
''',
        withOffsets: true);
  }

  void test_recordLiteral() {
    var parseResult = parseStringWithErrors(r'''
final x = (0, a: 1);
''');
    parseResult.assertNoErrors();

    var node = parseResult.findNode.recordLiteral('(0');
    assertParsedNodeText(node, r'''
RecordLiteral
  leftParenthesis: (
  fields
    IntegerLiteral
      literal: 0
    NamedExpression
      name: Label
        label: SimpleIdentifier
          token: a
        colon: :
      expression: IntegerLiteral
        literal: 1
  rightParenthesis: )
''');
  }

  void test_recordLiteral_named_trailingComma() {
    var parseResult = parseStringWithErrors(r'''
final x = (0, a: 1,);
''');
    parseResult.assertNoErrors();

    var node = parseResult.findNode.recordLiteral('(0');
    assertParsedNodeText(node, r'''
RecordLiteral
  leftParenthesis: (
  fields
    IntegerLiteral
      literal: 0
    NamedExpression
      name: Label
        label: SimpleIdentifier
          token: a
        colon: :
      expression: IntegerLiteral
        literal: 1
  rightParenthesis: )
''');
  }

  void test_recordLiteral_positional_trailingComma() {
    var parseResult = parseStringWithErrors(r'''
final x = (0, 1,);
''');
    parseResult.assertNoErrors();

    var node = parseResult.findNode.recordLiteral('(0');
    assertParsedNodeText(node, r'''
RecordLiteral
  leftParenthesis: (
  fields
    IntegerLiteral
      literal: 0
    IntegerLiteral
      literal: 1
  rightParenthesis: )
''');
  }

  void test_recordTypeAnnotation_mixed() {
    var parseResult = parseStringWithErrors(r'''
void f((int, bool, {int a, bool b}) r) {}
''');
    parseResult.assertNoErrors();

    var node = parseResult.findNode.recordTypeAnnotation('(int');
    assertParsedNodeText(node, r'''
RecordTypeAnnotation
  leftParenthesis: (
  positionalFields
    RecordTypeAnnotationPositionalField
      type: NamedType
        name: SimpleIdentifier
          token: int
    RecordTypeAnnotationPositionalField
      type: NamedType
        name: SimpleIdentifier
          token: bool
  namedFields: RecordTypeAnnotationNamedFields
    leftBracket: {
    fields
      RecordTypeAnnotationNamedField
        type: NamedType
          name: SimpleIdentifier
            token: int
        name: a
      RecordTypeAnnotationNamedField
        type: NamedType
          name: SimpleIdentifier
            token: bool
        name: b
    rightBracket: }
  rightParenthesis: )
''');
  }

  void test_recordTypeAnnotation_named() {
    var parseResult = parseStringWithErrors(r'''
void f(({int a, bool b}) r) {}
''');
    parseResult.assertNoErrors();

    var node = parseResult.findNode.recordTypeAnnotation('({int');
    assertParsedNodeText(node, r'''
RecordTypeAnnotation
  leftParenthesis: (
  namedFields: RecordTypeAnnotationNamedFields
    leftBracket: {
    fields
      RecordTypeAnnotationNamedField
        type: NamedType
          name: SimpleIdentifier
            token: int
        name: a
      RecordTypeAnnotationNamedField
        type: NamedType
          name: SimpleIdentifier
            token: bool
        name: b
    rightBracket: }
  rightParenthesis: )
''');
  }

  void test_recordTypeAnnotation_named_trailingComma() {
    var parseResult = parseStringWithErrors(r'''
void f(({int a, bool b,}) r) {}
''');
    parseResult.assertNoErrors();

    var node = parseResult.findNode.recordTypeAnnotation('({int');
    assertParsedNodeText(node, r'''
RecordTypeAnnotation
  leftParenthesis: (
  namedFields: RecordTypeAnnotationNamedFields
    leftBracket: {
    fields
      RecordTypeAnnotationNamedField
        type: NamedType
          name: SimpleIdentifier
            token: int
        name: a
      RecordTypeAnnotationNamedField
        type: NamedType
          name: SimpleIdentifier
            token: bool
        name: b
    rightBracket: }
  rightParenthesis: )
''');
  }

  void test_recordTypeAnnotation_nullable() {
    var parseResult = parseStringWithErrors(r'''
void f((int, bool)? r) {}
''');
    parseResult.assertNoErrors();

    var node = parseResult.findNode.recordTypeAnnotation('(int');
    assertParsedNodeText(node, r'''
RecordTypeAnnotation
  leftParenthesis: (
  positionalFields
    RecordTypeAnnotationPositionalField
      type: NamedType
        name: SimpleIdentifier
          token: int
    RecordTypeAnnotationPositionalField
      type: NamedType
        name: SimpleIdentifier
          token: bool
  rightParenthesis: )
  question: ?
''');
  }

  void test_recordTypeAnnotation_positional() {
    var parseResult = parseStringWithErrors(r'''
void f((int, bool) r) {}
''');
    parseResult.assertNoErrors();

    var node = parseResult.findNode.recordTypeAnnotation('(int');
    assertParsedNodeText(node, r'''
RecordTypeAnnotation
  leftParenthesis: (
  positionalFields
    RecordTypeAnnotationPositionalField
      type: NamedType
        name: SimpleIdentifier
          token: int
    RecordTypeAnnotationPositionalField
      type: NamedType
        name: SimpleIdentifier
          token: bool
  rightParenthesis: )
''');
  }

  void test_recordTypeAnnotation_positional_trailingComma() {
    var parseResult = parseStringWithErrors(r'''
void f((int, bool,) r) {}
''');
    parseResult.assertNoErrors();

    var node = parseResult.findNode.recordTypeAnnotation('(int');
    assertParsedNodeText(node, r'''
RecordTypeAnnotation
  leftParenthesis: (
  positionalFields
    RecordTypeAnnotationPositionalField
      type: NamedType
        name: SimpleIdentifier
          token: int
    RecordTypeAnnotationPositionalField
      type: NamedType
        name: SimpleIdentifier
          token: bool
  rightParenthesis: )
''');
  }

  void test_superFormalParameter() {
    var parseResult = parseStringWithErrors(r'''
class A {
  A(super.a);
}
''');
    parseResult.assertNoErrors();

    var node = parseResult.findNode.superFormalParameter('super.a');
    assertParsedNodeText(node, r'''
SuperFormalParameter
  superKeyword: super
  period: .
  name: a
''');
  }
}
