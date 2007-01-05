(*
  PressObjects, Consts unit
  Copyright (C) 2006 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressConsts;

{$I Press.inc}

interface

const
  SPressMaxItemCount = 100;
  SPressBrackets = '()';
  SPressAttributePrefix = '_';
  SPressAttributeSeparator = '.';
  SPressIdentifierSeparator = '_';
  SPressDataSeparator = ':';
  SPressFieldDelimiter = ';';
  SPressLineBreak = #10;
  SPressTrueString = 'True';
  SPressFalseString = 'False';
  SPressNilString = 'nil';
  SPressIdString = 'Id';
  SPressCalcString = 'Calc';
  SPressQueryItemsString = 'QueryItems';
  SPressReportNativeValueSuffix = 'Value';
  SPressReportDisplayTextSuffix = 'DisplayText';

resourcestring
  SAmbiguousConcreteClass = 'Classe concreta ambígua (%s e %s) para o objeto %s';
  SAttributeAccessError = 'Não é possível acessar o atributo %s(''%s'') como %s';
  SAttributeConversionError = 'Erro ao converter valor para o atributo %s(''%s''):' + #10 + '%s';
  SAttributeIsNotItem = 'O atributo %s(''%s'') não é Part ou Reference';
  SAttributeIsNotValue = 'O atributo %s(''%s'') não é Value';
  SAttributeNotFound = 'O atributo %s(''%s'') não foi encontrado';
  SClassNotFound = 'Classe %s não encontrada';
  SColumnDataParseError = 'Erro ao interpretar dados da coluna %s(''%s''): "%s"';
  SComponentIsNotAControl = 'O componente %s(''%s'') não é um controle';
  SComponentNotFound = 'O componente %s(''%s'') não foi encontrado';
  SDialogClassIsAssigned = 'Classe do objeto de diálogo já está associado';
  SEnumItemNotFound = 'Enumeration ''%s'' não encontrado';
  SEnumMetadataNotFound = 'Enumeration metadata %s não encontrado';
  SEnumOutOfBounds = 'Enumeration ''%s'' fora do limite (%d)';
  SInstanceNotFound = 'Instance not found: %s(%s)';
  SInvalidAttributeClass = 'O atributo %s(''%s'') requer objetos da classe %s';
  SInvalidAttributeValue = 'Valor ''%s'' inválido para %s(''%s'')';
  SInvalidClassInheritance = 'Classe ''%s'' não é decendente de ''%s''';
  SMaxItemCountReached = 'A consulta retornou %d itens, o limite é %d';
  SMetadataParseError = 'Erro ao interpretar metadata: "(%d,%d) %s"' + SPressLineBreak + '"%s"';
  SNonRelatedClasses = 'Classes %s e %s não são relacionadas';
  SNoLoggedUser = 'Não existe usuário logado';
  SNoReference = 'Não existe referência';
  SPathReferencesNil = 'O caminho %s(''%s'') possui atributo(s) Reference apontando para nil';
  SPersistentClassNotFound = 'Classe persistente %s não encontrada';
  SSingletonClassNotFound = 'Classe Singleton %s não encontrada';
  SStringLengthOutOfBounds = 'String muito grande';
  SStringOverflow = 'String overflow: %s(%s)';
  STokenExpected = '''%s'' esperado, mas ''%s'' foi encontrado';
  STokenLengthOutOfBounds = 'Token muito grande';
  SUnassignedAttributeType = 'Tipo de atributo não associado para %s(''%s'')';
  SUnassignedCandidateClasses = 'Classes candidata não estão associadas';
  SUnassignedTargetClass = 'Classe alvo não está associada';
  SUnassignedMainForm = 'Formulário principal não está associado';
  SUnassignedMainPresenter = 'Presenter principal não está associado';
  SUnassignedModel = 'Model não está associado';
  SUnassignedPersistenceConnector = 'Conector de persistência não foi associado';
  SUnassignedServiceType = 'Nenhum serviço %s foi associado ou registrado';
  SUnassignedSubject = 'Subject não foi associado';
  SUnexpectedEof = 'Final de arquivo inesperado';
  SUnexpectedMVPClassParam = 'Classe MVP %s inicializada com parâmetros inesperados';
  SUnsupportedAttribute = 'O atributo %s(''%s'') não é suportado';
  SUnsupportedAttributeType = 'O tipo de atributo %s não é suportado';
  SUnsupportedComponent = 'O componente %s não é suportado';
  SUnsupportedControl = 'O controle %s(''%s'') não é suportado';
  SUnsupportedDisplayName = 'DisplayName não é suportado para o atributo %s(''%s.%s'')';
  SUnsupportedFeature = 'Feature %s não é suportada';
  SUnsupportedModel = 'Model %s não é suportado por %s';
  SUnsupportedObject = 'Nenhuma classe %s suporta objetos %s';
  SViewAccessError = 'Não é possível acessar a view %s(''%s'') como %s';

  SConnectionManagerCaption = 'Conector';

  SPressTodayCommand = 'Hoje';
  SPressLoadPictureCommand = 'Adicionar figura';
  SPressRemovePictureCommand = 'Remover figura';
  SPressIncludeObjectCommand = 'Cadastrar novo item';
  SPressAddItemCommand = 'Adicionar item';
  SPressSelectItemCommand = 'Selecionar itens';
  SPressEditItemCommand = 'Alterar item';
  SPressRemoveItemCommand = 'Remover item';
  SPressSaveFormCommand = 'Salvar';
  SPressCancelFormCommand = 'Cancelar';
  SPressCloseFormCommand = 'Fechar';
  SPressExecuteQueryCommand = 'Executar';
  SPressAssignSelectionQueryCommand = 'Selecionar';

  SPressAttributeNameMsg = 'attribute name';
  SPressBooleanValueMsg = 'Valor lógico';
  SPressClassNameMsg = 'class name';
  SPressEofMsg = 'Final de arquivo';
  SPressIdentifierMsg = 'Identificador';
  SPressIntegerValueMsg = 'Inteiro';
  SPressLineBreakMsg = 'Quebra de linha';
  SPressNumberValueMsg = 'Número';
  SPressPropertyNameMsg = 'property name';
  SPressReportErrorMsg = ' ##Erro## ';
  SPressStringDelimiterMsg = 'Delimitador de string';
  SPressStringValueMsg = 'String';

  SPressCancelChangesDialog = 'Cancelar alterações?';
  SPressConfirmRemoveOneItemDialog = 'Um item selecionado. Confirma remoção?';
  SPressConfirmRemoveItemsDialog = '%d itens selecionados. Confirma remoção?';
  SPressSaveChangesDialog = 'Gravar alterações?';

implementation

end.
