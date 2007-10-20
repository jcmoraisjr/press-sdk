(*
  PressObjects, English Translation Class
  Copyright (C) 2007 Joao Morais, Steven Mitchell

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressMessages_en;

{$I Press.inc}

interface

uses
  PressDialogs;

type
  TPressMessages_en = class(TPressMessages)
  protected
    procedure InternalIsDefaultChanged; override;
  end;

implementation

uses
  PressConsts;

resourcestring
  SAmbiguousClass_en = 'Ambiguous choice between classes ''%s'' and ''%s''';
  SAttributeAccessError_en = 'Cannot access the attribute %s(''%s'') as ''%s''';
  SAttributeConversionError_en = 'Attribute value conversion error %s(''%s''):' + #10 + '"%s"';
  SAttributeIsNotItem_en = 'Attribute %s(''%s'') is not a Part or Reference';
  SAttributeIsNotValue_en = 'Attribute %s(''%s'') is not a Value';
  SAttributeNotFound_en = 'Attribute %s(''%s'') not found';
  SAttributeTypeNotFound_en = 'Attribute ''%s'' not found';
  SCannotChangeOPFBroker_en = 'Cannot change the data broker';
  SCannotReleaseInstance_en = 'Cannot release instance ''%s''';
  SCannotStoreOrphanObject_en = 'Cannot store orphan object';
  SCannotUseAggregateFunctionHere_en = 'Cannot use aggregate function here';
  SClassIsNotPersistent_en = 'Class ''%s'' is not persistent';
  SClassNotFound_en = 'Class ''%s'' not found';
  SColumnDataParseError_en = 'Column data parse error %s(''%s''): "%s"';
  SComponentIsNotAControl_en = 'Component %s(''%s'') is not a control';
  SComponentNotFound_en = 'Component %s(''%s'') not found';
  SDatabaseIdentifierTooLong_en = 'The identifier is too long' + #10 + 'and will cause an error in the database:';
  SDisplayNamesAlreadyAssigned_en = 'DisplayNames is already assigned';
  SEnumItemNotFound_en = 'Enumeration ''%s'' not found';
  SEnumMetadataNotFound_en = 'Enumeration metadata ''%s'' not found';
  SEnumOutOfBounds_en = 'Enumeration ''%s'' is out of bounds (%d)';
  SFieldNotFound_en = 'Field ''%s'' not found';
  SInstanceAlreadyOwned_en = 'The instance %s(''%s'') already has an owner';
  SInstanceNotFound_en = 'Instance not found: %s(''%s'')';
  SInvalidAttributeClass_en = 'Attribute %s(''%s'') requires objects of class ''%s''';
  SInvalidAttributeValue_en = 'Value ''%s'' is invalid for %s(''%s'')';
  SInvalidClassInheritance_en = 'Class ''%s'' is not a descendant of ''%s''';
  SInvalidLogon_en = 'Invalid username or password';
  SMaxItemCountReached_en = '%d items were returned, the limit is %d';
  SMetadataNotFound_en = 'Metadata ''%s'' not found';
  SMetadataParseError_en = 'Metadata parse error: "(%d,%d) %s"' + SPressLineBreak + '"%s"';
  SNoLoggedUser_en = 'No user logged in';
  SNoReferenceOrDataAccess_en = 'Reference or DAO does not exist';
  SObjectChangedError_en = 'The object %s(''%s'') was modified in another session';
  SPasswordsDontMatch_en = 'Passwords don''t match';
  SPathReferencesNil_en = 'The path %s(''%s'') has attribute(s) with nil reference(s)';
  SPropertyIsReadOnly_en = 'The property ''%s.%s'' is read only';
  SPropertyNotFound_en = 'Property ''%s.%s'' not found';
  SSingletonClassNotFound_en = 'Singleton class ''%s'' not found';
  SStringLengthOutOfBounds_en = 'String length out of bounds';
  SStringOverflow_en = 'String overflow: %s(''%s'')';
  STokenExpected_en = '''%s'' was expected, but ''%s'' was found';
  STokenLengthOutOfBounds_en = 'Token length out of bounds';
  SUnassignedAttributeType_en = 'Unassigned attribute type %s(''%s'')';
  SUnassignedItemObjectClass_en = 'Unassigned business class Query item ''%s''';
  SUnassignedMainForm_en = 'Unassigned main form';
  SUnassignedModel_en = 'Unassigned Model';
  SUnassignedPersistenceConnector_en = 'Unassigned persistence connector';
  SUnassignedPersistenceService_en = 'Unassigned or non-PressObjects persistence service';
  SUnassignedPresenterForm_en = 'Class ''%s'' does not have form';
  SUnassignedPresenterParent_en = 'Class ''%s'' does not have a parent';
  SUnassignedServiceType_en = 'No service ''%s'' is assigned or registered';
  SUnassignedSubject_en = 'Unassigned Subject';
  SUnexpectedEof_en = 'Unexpected end of file';
  SUnexpectedMVPClassParam_en = 'MVP class ''%s'' has unexpected parameters';
  SUnsupportedAttribute_en = 'Unsupported attribute %s(''%s'')';
  SUnsupportedAttributeType_en = 'Unsupported attribute type ''%s''';
  SUnsupportedComponent_en = 'Unsupported component ''%s''';
  SUnsupportedConnector_en = 'Unsupported connector ''%s''';
  SUnsupportedControl_en = 'Unsupported control %s(''%s'')';
  SUnsupportedDisplayNames_en = 'Unsupported DisplayNames for attribute %s(''%s.%s'')';
  SUnsupportedFeature_en = 'Unsupported feature ''%s''';
  SUnsupportedFieldType_en = 'Unsupported field type ''%s''';
  SUnsupportedGraphicFormat_en = 'Unsupported graphic format';
  SUnsupportedModel_en = 'Model %s is not supported by ''%s''';
  SUnsupportedObject_en = 'No class %s supports objects ''%s''';
  SViewAccessError_en = 'Cannot access the view %s(''%s'') as ''%s''';

  SConnectionManagerCaption_en = 'Connector';

  SPressTodayCommand_en = 'Today';
  SPressLoadPictureCommand_en = 'Load Picture';
  SPressRemovePictureCommand_en = 'Remove Picture';
  SPressIncludeObjectCommand_en = 'Add new item';
  SPressAddItemCommand_en = 'Add item';
  SPressSelectItemCommand_en = 'Select items';
  SPressEditItemCommand_en = 'Edit item';
  SPressRemoveItemCommand_en = 'Delete item';
  SPressRefreshCommand_en = 'Refresh';
  SPressSaveFormCommand_en = 'Save';
  SPressCancelFormCommand_en = 'Cancel';
  SPressCloseFormCommand_en = 'Close';
  SPressExecuteQueryCommand_en = 'Execute';
  SPressAssignSelectionQueryCommand_en = 'Filter';
  SPressSelectAllCommand_en = 'Select All';
  SPressSelectNoneCommand_en = 'Deselect All';
  SPressSelectCurrentCommand_en = 'Select/Deselect Current';
  SPressSelectInvertCommand_en = 'Invert Selection';
  SPressSortByCommand_en = 'Sort by ''%s''';
  SPressManageReportCommand_en = 'Manage Report';

  SPressAttributeNameMsg_en = 'attribute name';
  SPressBooleanValueMsg_en = 'Boolean value';
  SPressClassNameMsg_en = 'class name';
  SPressExpressionMsg_en = 'Expression';
  SPressEofMsg_en = 'End of file';
  SPressFunctionMsg_en = 'Function';
  SPressIdentifierMsg_en = 'Identifier';
  SPressIntegerValueMsg_en = 'Integer';
  SPressLineBreakMsg_en = 'Line break';
  SPressNumberValueMsg_en = 'Number';
  SPressPropertyNameMsg_en = 'property name';
  SPressReportErrorMsg_en = ' ##Error## ';
  SPressStringDelimiterMsg_en = 'String delimiter';
  SPressStringValueMsg_en = 'String';

  SPressCancelChangesDialog_en = 'Cancel changes?';
  SPressConfirmRemoveOneItemDialog_en = 'One item selected. Confirm delete?';
  SPressConfirmRemoveItemsDialog_en = '%d items selected. Confirm delete?';
  SPressSaveChangesDialog_en = 'Save changes?';

{ TPressMessages_en }

procedure TPressMessages_en.InternalIsDefaultChanged;
begin
  if IsDefault then
  begin
    SAmbiguousClass := SAmbiguousClass_en;
    SAttributeAccessError := SAttributeAccessError_en;
    SAttributeConversionError := SAttributeConversionError_en;
    SAttributeIsNotItem := SAttributeIsNotItem_en;
    SAttributeIsNotValue := SAttributeIsNotValue_en;
    SAttributeNotFound := SAttributeNotFound_en;
    SAttributeTypeNotFound := SAttributeTypeNotFound_en;
    SCannotChangeOPFBroker := SCannotChangeOPFBroker_en;
    SCannotReleaseInstance := SCannotReleaseInstance_en;
    SCannotStoreOrphanObject := SCannotStoreOrphanObject_en;
    SCannotUseAggregateFunctionHere := SCannotUseAggregateFunctionHere_en;
    SClassIsNotPersistent := SClassIsNotPersistent_en;
    SClassNotFound := SClassNotFound_en;
    SColumnDataParseError := SColumnDataParseError_en;
    SComponentIsNotAControl := SComponentIsNotAControl_en;
    SComponentNotFound := SComponentNotFound_en;
    SDatabaseIdentifierTooLong := SDatabaseIdentifierTooLong_en;
    SDisplayNamesAlreadyAssigned := SDisplayNamesAlreadyAssigned_en;
    SEnumItemNotFound := SEnumItemNotFound_en;
    SEnumMetadataNotFound := SEnumMetadataNotFound_en;
    SEnumOutOfBounds := SEnumOutOfBounds_en;
    SFieldNotFound := SFieldNotFound_en;
    SInstanceAlreadyOwned := SInstanceAlreadyOwned_en;
    SInstanceNotFound := SInstanceNotFound_en;
    SInvalidAttributeClass := SInvalidAttributeClass_en;
    SInvalidAttributeValue := SInvalidAttributeValue_en;
    SInvalidClassInheritance := SInvalidClassInheritance_en;
    SInvalidLogon := SInvalidLogon_en;
    SMaxItemCountReached := SMaxItemCountReached_en;
    SMetadataNotFound := SMetadataNotFound_en;
    SMetadataParseError := SMetadataParseError_en;
    SNoLoggedUser := SNoLoggedUser_en;
    SNoReferenceOrDataAccess := SNoReferenceOrDataAccess_en;
    SObjectChangedError := SObjectChangedError_en;
    SPasswordsDontMatch := SPasswordsDontMatch_en;
    SPathReferencesNil := SPathReferencesNil_en;
    SPropertyIsReadOnly := SPropertyIsReadOnly_en;
    SPropertyNotFound := SPropertyNotFound_en;
    SSingletonClassNotFound := SSingletonClassNotFound_en;
    SStringLengthOutOfBounds := SStringLengthOutOfBounds_en;
    SStringOverflow := SStringOverflow_en;
    STokenExpected := STokenExpected_en;
    STokenLengthOutOfBounds := STokenLengthOutOfBounds_en;
    SUnassignedAttributeType := SUnassignedAttributeType_en;
    SUnassignedItemObjectClass := SUnassignedItemObjectClass_en;
    SUnassignedMainForm := SUnassignedMainForm_en;
    SUnassignedModel := SUnassignedModel_en;
    SUnassignedPersistenceConnector := SUnassignedPersistenceConnector_en;
    SUnassignedPersistenceService := SUnassignedPersistenceService_en;
    SUnassignedPresenterForm := SUnassignedPresenterForm_en;
    SUnassignedPresenterParent := SUnassignedPresenterParent_en;
    SUnassignedServiceType := SUnassignedServiceType_en;
    SUnassignedSubject := SUnassignedSubject_en;
    SUnexpectedEof := SUnexpectedEof_en;
    SUnexpectedMVPClassParam := SUnexpectedMVPClassParam_en;
    SUnsupportedAttribute := SUnsupportedAttribute_en;
    SUnsupportedAttributeType := SUnsupportedAttributeType_en;
    SUnsupportedComponent := SUnsupportedComponent_en;
    SUnsupportedConnector := SUnsupportedConnector_en;
    SUnsupportedControl := SUnsupportedControl_en;
    SUnsupportedDisplayNames := SUnsupportedDisplayNames_en;
    SUnsupportedFeature := SUnsupportedFeature_en;
    SUnsupportedFieldType := SUnsupportedFieldType_en;
    SUnsupportedGraphicFormat := SUnsupportedGraphicFormat_en;
    SUnsupportedModel := SUnsupportedModel_en;
    SUnsupportedObject := SUnsupportedObject_en;
    SViewAccessError := SViewAccessError_en;

    SConnectionManagerCaption := SConnectionManagerCaption_en;

    SPressTodayCommand := SPressTodayCommand_en;
    SPressLoadPictureCommand := SPressLoadPictureCommand_en;
    SPressRemovePictureCommand := SPressRemovePictureCommand_en;
    SPressIncludeObjectCommand := SPressIncludeObjectCommand_en;
    SPressAddItemCommand := SPressAddItemCommand_en;
    SPressSelectItemCommand := SPressSelectItemCommand_en;
    SPressEditItemCommand := SPressEditItemCommand_en;
    SPressRemoveItemCommand := SPressRemoveItemCommand_en;
    SPressRefreshCommand := SPressRefreshCommand_en;
    SPressSaveFormCommand := SPressSaveFormCommand_en;
    SPressCancelFormCommand := SPressCancelFormCommand_en;
    SPressCloseFormCommand := SPressCloseFormCommand_en;
    SPressExecuteQueryCommand := SPressExecuteQueryCommand_en;
    SPressAssignSelectionQueryCommand := SPressAssignSelectionQueryCommand_en;
    SPressSelectAllCommand := SPressSelectAllCommand_en;
    SPressSelectNoneCommand := SPressSelectNoneCommand_en;
    SPressSelectCurrentCommand := SPressSelectCurrentCommand_en;
    SPressSelectInvertCommand := SPressSelectInvertCommand_en;
    SPressSortByCommand := SPressSortByCommand_en;
    SPressManageReportCommand := SPressManageReportCommand_en;

    SPressAttributeNameMsg := SPressAttributeNameMsg_en;
    SPressBooleanValueMsg := SPressBooleanValueMsg_en;
    SPressClassNameMsg := SPressClassNameMsg_en;
    SPressExpressionMsg := SPressExpressionMsg_en;
    SPressEofMsg := SPressEofMsg_en;
    SPressFunctionMsg := SPressFunctionMsg_en;
    SPressIdentifierMsg := SPressIdentifierMsg_en;
    SPressIntegerValueMsg := SPressIntegerValueMsg_en;
    SPressLineBreakMsg := SPressLineBreakMsg_en;
    SPressNumberValueMsg := SPressNumberValueMsg_en;
    SPressPropertyNameMsg := SPressPropertyNameMsg_en;
    SPressReportErrorMsg := SPressReportErrorMsg_en;
    SPressStringDelimiterMsg := SPressStringDelimiterMsg_en;
    SPressStringValueMsg := SPressStringValueMsg_en;

    SPressCancelChangesDialog := SPressCancelChangesDialog_en;
    SPressConfirmRemoveOneItemDialog := SPressConfirmRemoveOneItemDialog_en;
    SPressConfirmRemoveItemsDialog := SPressConfirmRemoveItemsDialog_en;
    SPressSaveChangesDialog := SPressSaveChangesDialog_en;
  end;
  inherited;
end;

initialization
  TPressMessages_en.RegisterService;

end.
