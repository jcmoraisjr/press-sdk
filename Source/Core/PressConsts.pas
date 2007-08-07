(*
  PressObjects, Consts unit
  Copyright (C) 2006-2007 Laserpress Ltda.

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
  SPressClassIdString = 'ClassId';
  SPressLinkIdString = 'Id';
  SPressParentString = 'Parent';
  SPressChildString = 'Child';
  SPressItemPosString = 'ItemPos';
  SPressUpdateCountString = 'UpdateCount';
  SPressConfigFileExt = '.cf';
  SPressPrimaryKeyNamePrefix = 'PK_';
  SPressForeignKeyNamePrefix = 'FK_';
  SPressUniqueKeyNamePrefix = 'UK_';
  SPressIndexNamePrefix = 'IDX_';
  SPressTableAliasPrefix = 't_';
  SPressPersistentIdParamString = 'PressPersistId';
  SPressCalcString = 'Calc';
  SPressQueryItemsString = 'QueryItems';
  SPressReportNativeValueSuffix = 'Value';
  SPressReportDisplayTextSuffix = 'DisplayText';
  SPressDAOServiceName = 'DAO';
  SPressOIDGeneratorServiceName = 'OIDGen';
  SPressOPFBrokerServiceName = 'OPFBroker';
  SPressUserServiceName = 'User';

resourcestring
  SAmbiguousClass = 'Ambiguidade entre as classes ''%s'' e ''%s''';
  SAttributeAccessError = 'Não é possível acessar o atributo %s(''%s'') como %s';
  SAttributeConversionError = 'Erro ao converter valor para o atributo %s(''%s''):' + #10 + '%s';
  SAttributeIsNotItem = 'O atributo %s(''%s'') não é Part ou Reference';
  SAttributeIsNotValue = 'O atributo %s(''%s'') não é Value';
  SAttributeNotFound = 'O atributo %s(''%s'') não foi encontrado';
  SAttributeTypeNotFound = 'O atributo %s não foi encontrado';
  SCannotChangeOPFBroker = 'Não é possível alterar o Broker de acesso a dados';
  SCannotReleaseInstance = 'Não é possível liberar a instância ''%s''';
  SClassIsNotPersistent = 'Classe ''%s'' não é persistente';
  SClassNotFound = 'Classe %s não encontrada';
  SColumnDataParseError = 'Erro ao interpretar dados da coluna %s(''%s''): "%s"';
  SComponentIsNotAControl = 'O componente %s(''%s'') não é um controle';
  SComponentNotFound = 'O componente %s(''%s'') não foi encontrado';
  SDatabaseIdentifierTooLong = 'Estes identificadores são muito grandes' + #10 + 'e causarão erro no banco de dados:';
  SDisplayNamesAlreadyAssigned = 'DisplayNames já foi associado';
  SEnumItemNotFound = 'Enumeration ''%s'' não encontrado';
  SEnumMetadataNotFound = 'Enumeration metadata %s não encontrado';
  SEnumOutOfBounds = 'Enumeration ''%s'' fora do limite (%d)';
  SFieldNotFound = 'Campo ''%s'' não foi encontrado';
  SInstanceNotFound = 'Instance not found: %s(%s)';
  SInvalidAttributeClass = 'O atributo %s(''%s'') requer objetos da classe %s';
  SInvalidAttributeValue = 'Valor ''%s'' inválido para %s(''%s'')';
  SInvalidClassInheritance = 'Classe ''%s'' não é decendente de ''%s''';
  SMaxItemCountReached = 'A consulta retornou %d itens, o limite é %d';
  SMetadataNotFound = 'Metadata ''%s'' não encontrado';
  SMetadataParseError = 'Erro ao interpretar metadata: "(%d,%d) %s"' + SPressLineBreak + '"%s"';
  SNoLoggedUser = 'Não existe usuário logado';
  SNoReferenceOrDataAccess = 'Não existe referência ou DAO';
  SObjectChangedError = 'O objeto %s(''%s'') foi alterado em outra sessão';
  SPathReferencesNil = 'O caminho %s(''%s'') possui atributo(s) Reference apontando para nil';
  SPersistentClassNotFound = 'Classe persistente %s não encontrada';
  SPropertyIsReadOnly = 'A propriedade ''%s.%s'' é somente leitura';
  SPropertyNotFound = 'A propriedade ''%s.%s'' não foi encontrada';
  SSingletonClassNotFound = 'Classe Singleton %s não encontrada';
  SStringLengthOutOfBounds = 'String muito grande';
  SStringOverflow = 'String overflow: %s(%s)';
  STokenExpected = '''%s'' esperado, mas ''%s'' foi encontrado';
  STokenLengthOutOfBounds = 'Token muito grande';
  SUnassignedAttributeType = 'Tipo de atributo não associado para %s(''%s'')';
  SUnassignedItemObjectClass = 'Classe de negócio dos itens da Query ''%s'' não está associado';
  SUnassignedMainForm = 'Formulário principal não está associado';
  SUnassignedModel = 'Model não está associado';
  SUnassignedPersistenceConnector = 'Conector de persistência não foi associado';
  SUnassignedPersistenceService = 'Serviço de persistência não foi associado ou não é do PressObjects';
  SUnassignedServiceType = 'Nenhum serviço %s foi associado ou registrado';
  SUnassignedSubject = 'Subject não foi associado';
  SUnexpectedEof = 'Final de arquivo inesperado';
  SUnexpectedMVPClassParam = 'Classe MVP %s inicializada com parâmetros inesperados';
  SUnsupportedAttribute = 'O atributo %s(''%s'') não é suportado';
  SUnsupportedAttributeType = 'O tipo de atributo %s não é suportado';
  SUnsupportedComponent = 'O componente %s não é suportado';
  SUnsupportedConnector = 'O conector ''%s'' não é suportado';
  SUnsupportedControl = 'O controle %s(''%s'') não é suportado';
  SUnsupportedDisplayNames = 'DisplayNames não é suportado para o atributo %s(''%s.%s'')';
  SUnsupportedFeature = 'Feature %s não é suportada';
  SUnsupportedFieldType = 'O tipo de campo ''%s'' não é suportado';
  SUnsupportedGraphicFormat = 'Formato de arquivo gráfico não suportado';
  SUnsupportedModel = 'Model %s não é suportado por %s';
  SUnsupportedObject = 'Nenhuma classe %s suporta objetos %s';
  SViewAccessError = 'Não é possível acessar a view %s(''%s'') como %s';

  SConnectionManagerCaption = 'Conector';

  SPressTodayCommand = 'Hoje';
  SPressLoadPictureCommand = 'Carregar figura';
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
  SPressSelectAllCommand = 'Selecionar tudo';
  SPressSelectNoneCommand = 'Remover seleção';
  SPressSelectCurrentCommand = 'Selecionar/remover atual';
  SPressSelectInvertCommand = 'Inverter seleção';
  SPressSortByCommand = 'Ordernar por ''%s''';
  SPressManageReportCommand = 'Gerenciar Relatório';

  SPressAttributeNameMsg = 'attribute name';
  SPressBooleanValueMsg = 'Valor lógico';
  SPressClassNameMsg = 'class name';
  SPressExpressionMsg = 'Expressão';
  SPressEofMsg = 'Final de arquivo';
  SPressFunctionMsg = 'Função';
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
