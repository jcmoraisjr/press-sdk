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
  SPressSubjectParamPrefix = 'par';
  SPressPrimaryKeyNamePrefix = 'PK_';
  SPressForeignKeyNamePrefix = 'FK_';
  SPressUniqueKeyNamePrefix = 'UK_';
  SPressIndexNamePrefix = 'IDX_';
  SPressTableAliasPrefix = 't_';
  SPressSubSelectTableAliasPrefix = 'ts%d_';
  SPressPersistentIdParamString = 'PressPersistId';
  SPressCalcString = 'Calc';
  SPressQueryItemsString = 'QueryItems';
  SPressUserAdminId = 'admin';
  SPressReportNativeValueSuffix = 'Value';
  SPressReportDisplayTextSuffix = 'DisplayText';
  SPressDAOServiceName = 'DAO';
  SPressOIDGeneratorServiceName = 'OIDGen';
  SPressOPFBrokerServiceName = 'OPFBroker';
  SPressUserServiceName = 'User';
  SPressMessagesServiceName = 'Messages';

var
  { TODO : Implement messages ID }
  // Error messages from core and adjacent classes
  SCannotReleaseInstance,
  SEnumItemNotFound,
  SInvalidLogon,
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
  SUnsupportedFeature: string;

  // Error messages from the Data Type (Subject) framework
  SAttributeAccessError,
  SAttributeConversionError,
  SAttributeIsNotItem,
  SAttributeIsNotValue,
  SAttributeNotFound,
  SAttributeTypeNotFound,
  SClassNotFound,
  SEnumMetadataNotFound,
  SEnumOutOfBounds,
  SInstanceAlreadyOwned,
  SInstanceNotFound,
  SInvalidAttributeClass,
  SInvalidAttributeValue,
  SInvalidClassInheritance,
  SMetadataNotFound,
  SMetadataParseError,
  SNoReferenceOrDataAccess,
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
  SUnexpectedMVPClassParam,
  SUnsupportedComponent,
  SUnsupportedControl,
  SUnsupportedDisplayNames,
  SUnsupportedModel,
  SUnsupportedObject,
  SViewAccessError: string;

  // Error messages from the OPF framework
  SCannotChangeOPFBroker,
  SCannotStoreOrphanObject,
  SCannotUseAggregateFunctionHere,
  SClassIsNotPersistent,
  SDatabaseIdentifierTooLong,
  SFieldNotFound,
  SObjectChangedError,
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
