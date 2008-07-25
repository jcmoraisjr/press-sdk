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
  SPressSquareBrackets = '[]';
  SPressAttributePrefix = '_';
  SPressAttributeSeparator = '.';
  SPressIdentifierSeparator = '_';
  SPressDataSeparator = ':';
  SPressFieldDelimiter = ';';
{$ifdef unix}
  SPressLineBreak = #10;
{$else}
  SPressLineBreak = #13#10;
{$endif}
  SPressTrueString = 'True';
  SPressFalseString = 'False';
  SPressNilString = 'nil';
  SPressIdString = 'Id';
  SPressClassIdString = 'ClassId';
  SPressDefaultStringIdSize = 32;
  SPressLinkIdString = 'Id';
  SPressParentString = 'Parent';
  SPressChildString = 'Child';
  SPressItemPosString = 'ItemPos';
  SPressUpdateCountString = 'UpdateCount';
  SPressConfigFileExt = '.cf';
  SPressSubjectParamPrefix = 'par';
  SPressCalcString = 'Calc';
  SPressQueryItemsString = 'QueryItems';
// opf related
  SPressPrimaryKeyNamePrefix = 'PK_';
  SPressForeignKeyNamePrefix = 'FK_';
  SPressUniqueKeyNamePrefix = 'UK_';
  SPressIndexNamePrefix = 'IDX_';
  SPressTableAliasPrefix = 't_';
  SPressSubSelectTableAliasPrefix = 'ts%d_';
  SPressPersistentIdParamString = 'PressPersistId';
// MVP accessor names
  SPressPresenterAccessorName = '_Presenter';
  SPressModelAccessorName = '_Model';
  SPressSubjectAccessorName = '_Subject';
// user related
  SPressUserAdminId = 'admin';
// short cuts
  SPressAddCommandShortCut = 'F2';
  SPressChangeCommandShortCut = 'F3';
  SPressRemoveCommandShortCut = 'Ctrl+F8';
  SPressTodayCommandShortCut = 'Ctrl+D';
  SPressSelectAllCommandShortCut = 'Ctrl+A';
  SPressSelectNoneCommandShortCut = 'Ctrl+W';
  SPressSaveCommandShortCut = 'F12';
  SPressExecuteCommandShortCut = 'F11';
// service names
  SPressSessionServiceName = 'Session';
  SPressGeneratorServiceName = 'Generator';
  SPressOPFBrokerServiceName = 'OPFBroker';
  SPressUserServiceName = 'User';
  SPressMessagesServiceName = 'Messages';

var
  { TODO : Implement messages ID }
  // Error messages from core and adjacent classes
  SCannotReleaseInstance,
  SEnumItemNotFound,
  SInvalidIdentifier,
  SInvalidInterfaceTypecast,
  SInvalidLogon,
  SMethodNotFound,
  SNoLoggedUser,
  SPasswordsDontMatch,
  SPropertyIsReadOnly,
  SPropertyNotFound,
  SServiceNotFound,
  SStringLengthOutOfBounds,
  STokenExpected,
  STokenLengthOutOfBounds,
  SUnassignedServiceType,
  SUnexpectedEof,
  SUnsupportedFeature,
  SUnsupportedVariantType: string;

  // Error messages from the Data Type (Subject) framework
  SAttributeAccessError,
  SAttributeConversionError,
  SAttributeIsNotItem,
  SAttributeIsNotValue,
  SAttributeNotFound,
  SAttributeTypeNotFound,
  SCannotRecursivelyCreateMetadatas,
  SClassNotFound,
  SEnumMetadataNotFound,
  SEnumOutOfBounds,
  SInstanceAlreadyOwned,
  SInstanceNotFound,
  SInvalidAttributeClass,
  SInvalidAttributeName,
  SInvalidAttributeValue,
  SInvalidClassInheritance,
  SMetadataNotFound,
  SMetadataParseError,
  SNoReferenceOrDataAccess,
  SParseFormulaError,
  SPathReferencesNil,
  SSingletonClassNotFound,
  SStringOverflow,
  SUnsupportedAttribute,
  SUnsupportedAttributeType,
  SUnsupportedGraphicFormat: string;

  // Error messages from the MVP framework
  SAmbiguousClass,
  SColumnDataParseError,
  SComponentIsNotAControl,
  SComponentNotFound,
  SDisplayNamesAlreadyAssigned,
  SMaxItemCountReached,
  SUnassignedAttributeType,
  SUnassignedItemObjectClass,
  SUnassignedMainForm,
  SUnassignedModel,
  SUnassignedPresenterForm,
  SUnassignedPresenterParent,
  SUnassignedSubject,
  SUnassignedWidgetManager,
  SUnexpectedMVPClassParam,
  SUnsupportedComponent,
  SUnsupportedControl,
  SUnsupportedDisplayNames,
  SUnsupportedModel,
  SUnsupportedObject,
  SViewAccessError,
  SWidgetManagerAlreadyAssigned: string;

  // Error messages from the OPF framework
  SAttributeReferencesOwnedClass,
  SCannotChangeOPFBroker,
  SCannotStoreOrphanObject,
  SCannotUseAggregateFunctionHere,
  SClassIsNotPersistent,
  SDatabaseIdentifierTooLong,
  SFieldNotFound,
  SObjectChangedError,
  STargetClassIsNotPersistent,
  SUnassignedPersistenceService,
  SUnsupportedConnector,
  SUnsupportedFieldType: string;

  // Error messages from brokers
  SUnassignedPersistenceConnector: string;

  // Messages for visual components
  SConnectionManagerCaption: string;

  // Messages for Commands
  SPressTodayCommand,
  SPressLoadPictureCommand,
  SPressRemovePictureCommand,
  SPressIncludeObjectCommand,
  SPressAddItemCommand,
  SPressSelectItemCommand,
  SPressEditItemCommand,
  SPressRemoveItemCommand,
  SPressRefreshCommand,
  SPressSaveFormCommand,
  SPressCancelFormCommand,
  SPressCloseFormCommand,
  SPressExecuteQueryCommand,
  SPressAssignSelectionQueryCommand,
  SPressSelectAllCommand,
  SPressSelectNoneCommand,
  SPressSelectCurrentCommand,
  SPressSelectInvertCommand,
  SPressSortByCommand,
  SPressManageReportCommand: string;

  // Partial translations for parsers or another error messages
  SPressAttributeNameMsg,
  SPressBooleanValueMsg,
  SPressClassNameMsg,
  SPressExpressionMsg,
  SPressEofMsg,
  SPressFunctionMsg,
  SPressIdentifierMsg,
  SPressIntegerValueMsg,
  SPressLineBreakMsg,
  SPressNumberValueMsg,
  SPressPropertyNameMsg,
  SPressReportErrorMsg,
  SPressStringDelimiterMsg,
  SPressStringValueMsg: string;

  // Messages for dialog box
  SPressCancelChangesDialog,
  SPressConfirmRemoveOneItemDialog,
  SPressConfirmRemoveItemsDialog,
  SPressSaveChangesDialog: string;

implementation

end.
