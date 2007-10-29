(*
  PressObjects, Brazilian Portuguese Translation Class
  Copyright (C) 2007 Joao Morais

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressMessages_ptbr;

{$I Press.inc}

interface

uses
  PressApplication;

type
  TPressMessages_ptbr = class(TPressMessages)
  protected
    procedure InternalIsDefaultChanged; override;
  end;

implementation

uses
  PressConsts;

resourcestring
  SAmbiguousClass_ptbr = 'Ambiguidade entre as classes ''%s'' e ''%s''';
  SAttributeAccessError_ptbr = 'Não é possível acessar o atributo %s(''%s'') como ''%s''';
  SAttributeConversionError_ptbr = 'Erro ao converter valor para o atributo %s(''%s''):' + #10 + '"%s"';
  SAttributeIsNotItem_ptbr = 'O atributo %s(''%s'') não é Part ou Reference';
  SAttributeIsNotValue_ptbr = 'O atributo %s(''%s'') não é Value';
  SAttributeNotFound_ptbr = 'O atributo %s(''%s'') não foi encontrado';
  SAttributeTypeNotFound_ptbr = 'O atributo ''%s'' não foi encontrado';
  SCannotChangeOPFBroker_ptbr = 'Não é possível alterar o Broker de acesso a dados';
  SCannotReleaseInstance_ptbr = 'Não é possível liberar a instância ''%s''';
  SCannotStoreOrphanObject_ptbr = 'Não é possível gravar objetos órfãos';
  SCannotUseAggregateFunctionHere_ptbr = 'Não é possível utilizar função de agregação aqui';
  SClassIsNotPersistent_ptbr = 'Classe ''%s'' não é persistente';
  SClassNotFound_ptbr = 'Classe ''%s'' não encontrada';
  SColumnDataParseError_ptbr = 'Erro ao interpretar dados da coluna %s(''%s''): "%s"';
  SComponentIsNotAControl_ptbr = 'O componente %s(''%s'') não é um controle';
  SComponentNotFound_ptbr = 'O componente %s(''%s'') não foi encontrado';
  SDatabaseIdentifierTooLong_ptbr = 'Estes identificadores são muito grandes' + #10 + 'e causarão erro no banco de dados:';
  SDisplayNamesAlreadyAssigned_ptbr = 'DisplayNames já foi associado';
  SEnumItemNotFound_ptbr = 'Enumeration ''%s'' não encontrado';
  SEnumMetadataNotFound_ptbr = 'Enumeration metadata ''%s'' não encontrado';
  SEnumOutOfBounds_ptbr = 'Enumeration ''%s'' fora do limite (%d)';
  SFieldNotFound_ptbr = 'Campo ''%s'' não foi encontrado';
  SInstanceAlreadyOwned_ptbr = 'O objeto %s(''%s'') já possui proprietário';
  SInstanceNotFound_ptbr = 'Instance not found: %s(''%s'')';
  SInvalidAttributeClass_ptbr = 'O atributo %s(''%s'') requer objetos da classe ''%s''';
  SInvalidAttributeValue_ptbr = 'Valor ''%s'' inválido para %s(''%s'')';
  SInvalidClassInheritance_ptbr = 'Classe ''%s'' não é decendente de ''%s''';
  SInvalidLogon_ptbr = 'Nome de usuário ou senha incorretos';
  SMaxItemCountReached_ptbr = 'A consulta retornou %d itens, o limite é %d';
  SMetadataNotFound_ptbr = 'Metadata ''%s'' não encontrado';
  SMetadataParseError_ptbr = 'Erro ao interpretar metadata: "(%d,%d) %s"' + SPressLineBreak + '"%s"';
  SNoLoggedUser_ptbr = 'Não existe usuário logado';
  SNoReferenceOrDataAccess_ptbr = 'Não existe referência ou DAO';
  SObjectChangedError_ptbr = 'O objeto %s(''%s'') foi alterado em outra sessão';
  SPasswordsDontMatch_ptbr = 'As senhas não são iguais';
  SPathReferencesNil_ptbr = 'O caminho %s(''%s'') possui atributo(s) Reference apontando para nil';
  SPropertyIsReadOnly_ptbr = 'A propriedade ''%s.%s'' é somente leitura';
  SPropertyNotFound_ptbr = 'A propriedade ''%s.%s'' não foi encontrada';
  SSingletonClassNotFound_ptbr = 'Classe Singleton ''%s'' não encontrada';
  SStringLengthOutOfBounds_ptbr = 'String muito grande';
  SStringOverflow_ptbr = 'String overflow: %s(''%s'')';
  STokenExpected_ptbr = '''%s'' esperado, mas ''%s'' foi encontrado';
  STokenLengthOutOfBounds_ptbr = 'Token muito grande';
  SUnassignedAttributeType_ptbr = 'Tipo de atributo não associado para %s(''%s'')';
  SUnassignedItemObjectClass_ptbr = 'Classe de negócio dos itens da Query ''%s'' não está associado';
  SUnassignedMainForm_ptbr = 'Formulário principal não está associado';
  SUnassignedModel_ptbr = 'Model não está associado';
  SUnassignedPersistenceConnector_ptbr = 'Conector de persistência não foi associado';
  SUnassignedPersistenceService_ptbr = 'Serviço de persistência não foi associado ou não é do PressObjects';
  SUnassignedPresenterForm_ptbr = 'A classe ''%s'' não possui form';
  SUnassignedPresenterParent_ptbr = 'A classe ''%s'' não possui parent';
  SUnassignedServiceType_ptbr = 'Nenhum serviço ''%s'' foi associado ou registrado';
  SUnassignedSubject_ptbr = 'Subject não foi associado';
  SUnexpectedEof_ptbr = 'Final de arquivo inesperado';
  SUnexpectedMVPClassParam_ptbr = 'Classe MVP ''%s'' inicializada com parâmetros inesperados';
  SUnsupportedAttribute_ptbr = 'O atributo %s(''%s'') não é suportado';
  SUnsupportedAttributeType_ptbr = 'O tipo de atributo ''%s'' não é suportado';
  SUnsupportedComponent_ptbr = 'O componente ''%s'' não é suportado';
  SUnsupportedConnector_ptbr = 'O conector ''%s'' não é suportado';
  SUnsupportedControl_ptbr = 'O controle %s(''%s'') não é suportado';
  SUnsupportedDisplayNames_ptbr = 'DisplayNames não é suportado para o atributo %s(''%s.%s'')';
  SUnsupportedFeature_ptbr = 'Feature ''%s'' não é suportada';
  SUnsupportedFieldType_ptbr = 'O tipo de campo ''%s'' não é suportado';
  SUnsupportedGraphicFormat_ptbr = 'Formato de arquivo gráfico não suportado';
  SUnsupportedModel_ptbr = 'Model ''%s'' não é suportado por ''%s''';
  SUnsupportedObject_ptbr = 'Nenhuma classe ''%s'' suporta objetos ''%s''';
  SViewAccessError_ptbr = 'Não é possível acessar a view %s(''%s'') como ''%s''';

  SConnectionManagerCaption_ptbr = 'Conector';

  SPressTodayCommand_ptbr = 'Hoje';
  SPressLoadPictureCommand_ptbr = 'Carregar figura';
  SPressRemovePictureCommand_ptbr = 'Remover figura';
  SPressIncludeObjectCommand_ptbr = 'Cadastrar novo item';
  SPressAddItemCommand_ptbr = 'Adicionar item';
  SPressSelectItemCommand_ptbr = 'Selecionar itens';
  SPressEditItemCommand_ptbr = 'Alterar item';
  SPressRemoveItemCommand_ptbr = 'Remover item';
  SPressRefreshCommand_ptbr = 'Atualizar';
  SPressSaveFormCommand_ptbr = 'Salvar';
  SPressCancelFormCommand_ptbr = 'Cancelar';
  SPressCloseFormCommand_ptbr = 'Fechar';
  SPressExecuteQueryCommand_ptbr = 'Executar';
  SPressAssignSelectionQueryCommand_ptbr = 'Selecionar';
  SPressSelectAllCommand_ptbr = 'Selecionar tudo';
  SPressSelectNoneCommand_ptbr = 'Remover seleção';
  SPressSelectCurrentCommand_ptbr = 'Selecionar/remover atual';
  SPressSelectInvertCommand_ptbr = 'Inverter seleção';
  SPressSortByCommand_ptbr = 'Ordernar por ''%s''';
  SPressManageReportCommand_ptbr = 'Gerenciar Relatório';

  SPressAttributeNameMsg_ptbr = 'nome de atributo';
  SPressBooleanValueMsg_ptbr = 'Valor lógico';
  SPressClassNameMsg_ptbr = 'nome de classe';
  SPressExpressionMsg_ptbr = 'Expressão';
  SPressEofMsg_ptbr = 'Final de arquivo';
  SPressFunctionMsg_ptbr = 'Função';
  SPressIdentifierMsg_ptbr = 'Identificador';
  SPressIntegerValueMsg_ptbr = 'Inteiro';
  SPressLineBreakMsg_ptbr = 'Quebra de linha';
  SPressNumberValueMsg_ptbr = 'Número';
  SPressPropertyNameMsg_ptbr = 'nome de propriedade';
  SPressReportErrorMsg_ptbr = ' ##Erro## ';
  SPressStringDelimiterMsg_ptbr = 'Delimitador de string';
  SPressStringValueMsg_ptbr = 'String';

  SPressCancelChangesDialog_ptbr = 'Cancelar alterações?';
  SPressConfirmRemoveOneItemDialog_ptbr = 'Um item selecionado. Confirma remoção?';
  SPressConfirmRemoveItemsDialog_ptbr = '%d itens selecionados. Confirma remoção?';
  SPressSaveChangesDialog_ptbr = 'Gravar alterações?';

{ TPressMessages_ptbr }

procedure TPressMessages_ptbr.InternalIsDefaultChanged;
begin
  if IsDefault then
  begin
    SAmbiguousClass := SAmbiguousClass_ptbr;
    SAttributeAccessError := SAttributeAccessError_ptbr;
    SAttributeConversionError := SAttributeConversionError_ptbr;
    SAttributeIsNotItem := SAttributeIsNotItem_ptbr;
    SAttributeIsNotValue := SAttributeIsNotValue_ptbr;
    SAttributeNotFound := SAttributeNotFound_ptbr;
    SAttributeTypeNotFound := SAttributeTypeNotFound_ptbr;
    SCannotChangeOPFBroker := SCannotChangeOPFBroker_ptbr;
    SCannotReleaseInstance := SCannotReleaseInstance_ptbr;
    SCannotStoreOrphanObject := SCannotStoreOrphanObject_ptbr;
    SCannotUseAggregateFunctionHere := SCannotUseAggregateFunctionHere_ptbr;
    SClassIsNotPersistent := SClassIsNotPersistent_ptbr;
    SClassNotFound := SClassNotFound_ptbr;
    SColumnDataParseError := SColumnDataParseError_ptbr;
    SComponentIsNotAControl := SComponentIsNotAControl_ptbr;
    SComponentNotFound := SComponentNotFound_ptbr;
    SDatabaseIdentifierTooLong := SDatabaseIdentifierTooLong_ptbr;
    SDisplayNamesAlreadyAssigned := SDisplayNamesAlreadyAssigned_ptbr;
    SEnumItemNotFound := SEnumItemNotFound_ptbr;
    SEnumMetadataNotFound := SEnumMetadataNotFound_ptbr;
    SEnumOutOfBounds := SEnumOutOfBounds_ptbr;
    SFieldNotFound := SFieldNotFound_ptbr;
    SInstanceAlreadyOwned := SInstanceAlreadyOwned_ptbr;
    SInstanceNotFound := SInstanceNotFound_ptbr;
    SInvalidAttributeClass := SInvalidAttributeClass_ptbr;
    SInvalidAttributeValue := SInvalidAttributeValue_ptbr;
    SInvalidClassInheritance := SInvalidClassInheritance_ptbr;
    SInvalidLogon := SInvalidLogon_ptbr;
    SMaxItemCountReached := SMaxItemCountReached_ptbr;
    SMetadataNotFound := SMetadataNotFound_ptbr;
    SMetadataParseError := SMetadataParseError_ptbr;
    SNoLoggedUser := SNoLoggedUser_ptbr;
    SNoReferenceOrDataAccess := SNoReferenceOrDataAccess_ptbr;
    SObjectChangedError := SObjectChangedError_ptbr;
    SPasswordsDontMatch := SPasswordsDontMatch_ptbr;
    SPathReferencesNil := SPathReferencesNil_ptbr;
    SPropertyIsReadOnly := SPropertyIsReadOnly_ptbr;
    SPropertyNotFound := SPropertyNotFound_ptbr;
    SSingletonClassNotFound := SSingletonClassNotFound_ptbr;
    SStringLengthOutOfBounds := SStringLengthOutOfBounds_ptbr;
    SStringOverflow := SStringOverflow_ptbr;
    STokenExpected := STokenExpected_ptbr;
    STokenLengthOutOfBounds := STokenLengthOutOfBounds_ptbr;
    SUnassignedAttributeType := SUnassignedAttributeType_ptbr;
    SUnassignedItemObjectClass := SUnassignedItemObjectClass_ptbr;
    SUnassignedMainForm := SUnassignedMainForm_ptbr;
    SUnassignedModel := SUnassignedModel_ptbr;
    SUnassignedPersistenceConnector := SUnassignedPersistenceConnector_ptbr;
    SUnassignedPersistenceService := SUnassignedPersistenceService_ptbr;
    SUnassignedPresenterForm := SUnassignedPresenterForm_ptbr;
    SUnassignedPresenterParent := SUnassignedPresenterParent_ptbr;
    SUnassignedServiceType := SUnassignedServiceType_ptbr;
    SUnassignedSubject := SUnassignedSubject_ptbr;
    SUnexpectedEof := SUnexpectedEof_ptbr;
    SUnexpectedMVPClassParam := SUnexpectedMVPClassParam_ptbr;
    SUnsupportedAttribute := SUnsupportedAttribute_ptbr;
    SUnsupportedAttributeType := SUnsupportedAttributeType_ptbr;
    SUnsupportedComponent := SUnsupportedComponent_ptbr;
    SUnsupportedConnector := SUnsupportedConnector_ptbr;
    SUnsupportedControl := SUnsupportedControl_ptbr;
    SUnsupportedDisplayNames := SUnsupportedDisplayNames_ptbr;
    SUnsupportedFeature := SUnsupportedFeature_ptbr;
    SUnsupportedFieldType := SUnsupportedFieldType_ptbr;
    SUnsupportedGraphicFormat := SUnsupportedGraphicFormat_ptbr;
    SUnsupportedModel := SUnsupportedModel_ptbr;
    SUnsupportedObject := SUnsupportedObject_ptbr;
    SViewAccessError := SViewAccessError_ptbr;

    SConnectionManagerCaption := SConnectionManagerCaption_ptbr;

    SPressTodayCommand := SPressTodayCommand_ptbr;
    SPressLoadPictureCommand := SPressLoadPictureCommand_ptbr;
    SPressRemovePictureCommand := SPressRemovePictureCommand_ptbr;
    SPressIncludeObjectCommand := SPressIncludeObjectCommand_ptbr;
    SPressAddItemCommand := SPressAddItemCommand_ptbr;
    SPressSelectItemCommand := SPressSelectItemCommand_ptbr;
    SPressEditItemCommand := SPressEditItemCommand_ptbr;
    SPressRemoveItemCommand := SPressRemoveItemCommand_ptbr;
    SPressRefreshCommand := SPressRefreshCommand_ptbr;
    SPressSaveFormCommand := SPressSaveFormCommand_ptbr;
    SPressCancelFormCommand := SPressCancelFormCommand_ptbr;
    SPressCloseFormCommand := SPressCloseFormCommand_ptbr;
    SPressExecuteQueryCommand := SPressExecuteQueryCommand_ptbr;
    SPressAssignSelectionQueryCommand := SPressAssignSelectionQueryCommand_ptbr;
    SPressSelectAllCommand := SPressSelectAllCommand_ptbr;
    SPressSelectNoneCommand := SPressSelectNoneCommand_ptbr;
    SPressSelectCurrentCommand := SPressSelectCurrentCommand_ptbr;
    SPressSelectInvertCommand := SPressSelectInvertCommand_ptbr;
    SPressSortByCommand := SPressSortByCommand_ptbr;
    SPressManageReportCommand := SPressManageReportCommand_ptbr;

    SPressAttributeNameMsg := SPressAttributeNameMsg_ptbr;
    SPressBooleanValueMsg := SPressBooleanValueMsg_ptbr;
    SPressClassNameMsg := SPressClassNameMsg_ptbr;
    SPressExpressionMsg := SPressExpressionMsg_ptbr;
    SPressEofMsg := SPressEofMsg_ptbr;
    SPressFunctionMsg := SPressFunctionMsg_ptbr;
    SPressIdentifierMsg := SPressIdentifierMsg_ptbr;
    SPressIntegerValueMsg := SPressIntegerValueMsg_ptbr;
    SPressLineBreakMsg := SPressLineBreakMsg_ptbr;
    SPressNumberValueMsg := SPressNumberValueMsg_ptbr;
    SPressPropertyNameMsg := SPressPropertyNameMsg_ptbr;
    SPressReportErrorMsg := SPressReportErrorMsg_ptbr;
    SPressStringDelimiterMsg := SPressStringDelimiterMsg_ptbr;
    SPressStringValueMsg := SPressStringValueMsg_ptbr;

    SPressCancelChangesDialog := SPressCancelChangesDialog_ptbr;
    SPressConfirmRemoveOneItemDialog := SPressConfirmRemoveOneItemDialog_ptbr;
    SPressConfirmRemoveItemsDialog := SPressConfirmRemoveItemsDialog_ptbr;
    SPressSaveChangesDialog := SPressSaveChangesDialog_ptbr;
  end;
  inherited;
end;

initialization
  TPressMessages_ptbr.RegisterService;

end.
