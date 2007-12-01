(*
  PressObjects, Subject Classes
  Copyright (C) 2006-2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressSubject;

{$I Press.inc}

interface

uses
  SysUtils,
  {$IFNDEF D5Down}Variants,{$ENDIF}
  Classes,
  TypInfo,
  Contnrs,
  PressCompatibility,
  PressClasses,
  PressApplication,
  PressNotifier;

const
  { TODO : Remove the DAO and persistence info from the subject unit }
  CPressDAOService = CPressDataAccessServicesBase + $0001;

type
  { Metadata declarations }

  TPressEnumMetadata = class(TObject)
  private
    FItems: TStrings;
    FName: string;
    FTypeAddress: Pointer;
    function RemoveEnumItemPrefix(const AEnumName: string): string;
  public
    constructor Create(ATypeAddress: Pointer); overload;
    constructor Create(ATypeAddress: Pointer; AEnumValues: array of string); overload;
    destructor Destroy; override;
    property Items: TStrings read FItems;
    property Name: string read FName write FName;
    property TypeAddress: Pointer read FTypeAddress;
  end;

  TPressEnumMetadataIterator = class;

  TPressEnumMetadataList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressEnumMetadata;
    procedure SetItems(AIndex: Integer; Value: TPressEnumMetadata);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressEnumMetadata): Integer;
    function CreateIterator: TPressEnumMetadataIterator;
    function Extract(AObject: TPressEnumMetadata): TPressEnumMetadata;
    function IndexOf(AObject: TPressEnumMetadata): Integer;
    procedure Insert(Index: Integer; AObject: TPressEnumMetadata);
    function Remove(AObject: TPressEnumMetadata): Integer;
    property Items[AIndex: Integer]: TPressEnumMetadata read GetItems write SetItems; default;
  end;

  TPressEnumMetadataIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressEnumMetadata;
  public
    property CurrentItem: TPressEnumMetadata read GetCurrentItem;
  end;

  TPressObject = class;
  TPressObjectClass = class of TPressObject;
  TPressObjectArray = array of TPressObject;
  TPressObjectClassArray = array of TPressObjectClass;

  TPressCalcMetadata = class(TObject)
  private
    FListenedAttributes: TStrings;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddListenedAttribute(const AAttributePath: string);
    procedure BindCalcNotification(AInstance: TPressObject; ANotifier: TPressNotifier);
    procedure ReleaseCalcNotification(AInstance: TPressObject; ANotifier: TPressNotifier);
  end;

  PPressAttribute = ^TPressAttribute;
  TPressAttribute = class;
  TPressAttributeClass = class of TPressAttribute;
  TPressObjectMetadata = class;

  TPressAttributeMetadataClass = class of TPressAttributeMetadata;

  TPressModel = class;

  TPressAttributeMetadata = class(TPressStreamable)
  private
    { TODO : Refactor attribute metadatas to use attribute class inheritance,
      instead of object class inheritance. }
    { TODO : Implement data packet in the dao/persistence unit }
    FAttributeClass: TPressAttributeClass;
    FCalcMetadata: TPressCalcMetadata;
    FDefaultValue: string;
    FEditMask: string;
    FEnumMetadata: TPressEnumMetadata;
    FIsPersistent: Boolean;
    FModel: TPressModel;
    FName: string;
    FObjectClass: TPressObjectClass;
    FObjectClassMetadata: TPressObjectMetadata;
    FOwner: TPressObjectMetadata;
    FPersistentName: string;
    FPersLinkChildName: string;
    FPersLinkIdName: string;
    FPersLinkName: string;
    FPersLinkParentName: string;
    FPersLinkPosName: string;
    FShortName: string;
    FSize: Integer;
    FWeakReference: Boolean;
    function BuildPersLinkChildName: string;
    function BuildPersLinkName: string;
    function BuildPersLinkParentName: string;
    function GetPersLinkChildName: string;
    function GetPersLinkName: string;
    function GetPersLinkParentName: string;
    function GetShortName: string;
    procedure SetAttributeClass(Value: TPressAttributeClass);
    procedure SetCalcMetadata(Value: TPressCalcMetadata);
    procedure SetEnumMetadata(Value: TPressEnumMetadata);
    procedure SetObjectClass(Value: TPressObjectClass);
    function StorePersistentName: Boolean;
    function StorePersLinkChildName: Boolean;
    function StorePersLinkIdName: Boolean;
    function StorePersLinkName: Boolean;
    function StorePersLinkParentName: Boolean;
    function StorePersLinkPosName: Boolean;
    function StoreShortName: Boolean;
  protected
    procedure Finit; override;
    function GetAttributeName: string; virtual;
    function GetObjectClassName: string; virtual;
    procedure SetAttributeName(const Value: string); virtual;
    procedure SetName(const Value: string); virtual;
    procedure SetObjectClassName(const Value: string); virtual;
    property Model: TPressModel read FModel;
  public
    constructor Create(AOwner: TPressObjectMetadata); virtual;
    function CreateAttribute(AOwner: TPressObject): TPressAttribute;
    function IsEmbeddedLink: Boolean;
    property AttributeClass: TPressAttributeClass read FAttributeClass write SetAttributeClass;
    property AttributeName: string read GetAttributeName write SetAttributeName;
    property CalcMetadata: TPressCalcMetadata read FCalcMetadata write SetCalcMetadata;
    property EnumMetadata: TPressEnumMetadata read FEnumMetadata write SetEnumMetadata;
    property Name: string read FName write SetName;
    property ObjectClass: TPressObjectClass read FObjectClass write SetObjectClass;
    property ObjectClassMetadata: TPressObjectMetadata read FObjectClassMetadata;
    property ObjectClassName: string read GetObjectClassName write SetObjectClassName;
    property Owner: TPressObjectMetadata read FOwner;
    property Size: Integer read FSize write FSize;
  published
    property DefaultValue: string read FDefaultValue write FDefaultValue;
    property EditMask: string read FEditMask write FEditMask;
    property IsPersistent: Boolean read FIsPersistent write FIsPersistent default True;
    property PersistentName: string read FPersistentName write FPersistentName stored StorePersistentName;
    property PersLinkChildName: string read GetPersLinkChildName write FPersLinkChildName stored StorePersLinkChildName;
    property PersLinkIdName: string read FPersLinkIdName write FPersLinkIdName stored StorePersLinkIdName;
    property PersLinkName: string read GetPersLinkName write FPersLinkName stored StorePersLinkName;
    property PersLinkParentName: string read GetPersLinkParentName write FPersLinkParentName stored StorePersLinkParentName;
    property PersLinkPosName: string read FPersLinkPosName write FPersLinkPosName stored StorePersLinkPosName;
    property ShortName: string read GetShortName write FShortName stored StoreShortName;
    property WeakReference: Boolean read FWeakReference write FWeakReference default False;
  end;

  TPressAttributeMetadataIterator = class;

  TPressAttributeMetadataList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressAttributeMetadata;
    procedure SetItems(AIndex: Integer; Value: TPressAttributeMetadata);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressAttributeMetadata): Integer;
    function CreateIterator: TPressAttributeMetadataIterator;
    function IndexOf(AObject: TPressAttributeMetadata): Integer;
    function IndexOfName(const AName: string): Integer;
    procedure Insert(Index: Integer; AObject: TPressAttributeMetadata);
    function Remove(AObject: TPressAttributeMetadata): Integer;
    property Items[AIndex: Integer]: TPressAttributeMetadata read GetItems write SetItems; default;
  end;

  TPressAttributeMetadataIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressAttributeMetadata;
  public
    property CurrentItem: TPressAttributeMetadata read GetCurrentItem;
  end;

  TPressClassMap = class(TPressAttributeMetadataList)
  private
    FObjectMetadata: TPressObjectMetadata;
    procedure ReadMetadatas(AObjectMetadata: TPressObjectMetadata);
  public
    constructor Create(AObjectMetadata: TPressObjectMetadata);
    function FindMetadata(const APath: string): TPressAttributeMetadata;
    function MetadataByPath(const APath: string): TPressAttributeMetadata;
    property ObjectMetadata: TPressObjectMetadata read FObjectMetadata;
  end;

  TPressQueryMatchType = (
   mtNone, mtEqual,
   mtStarting, mtFinishing, mtContains,
   mtGreaterThan, mtGreaterThanOrEqual,
   mtLesserThan, mtLesserThanOrEqual);

  TPressQueryMetadata = class;

  TPressQueryAttributeMetadata = class(TPressAttributeMetadata)
  private
    FMatchType: TPressQueryMatchType;
    FDataName: string;
    FIncludeIfEmpty: Boolean;
  protected
    procedure SetName(const Value: string); override;
  public
    constructor Create(AOwner: TPressObjectMetadata); override;
  published
    property MatchType: TPressQueryMatchType read FMatchType write FMatchType default mtNone;
    property DataName: string read FDataName write FDataName;
    property IncludeIfEmpty: Boolean read FIncludeIfEmpty write FIncludeIfEmpty default False;
  end;

  TPressObjectMetadataClass = class of TPressObjectMetadata;

  TPressObjectMetadata = class(TPressStreamable)
  private
    FAttributeMetadatas: TPressAttributeMetadataList;
    FClassIdName: string;
    FIdMetadata: TPressAttributeMetadata;
    FIsPersistent: Boolean;
    FKeyName: string;
    FKeyType: string;
    FMap: TPressClassMap;
    FModel: TPressModel;
    FObjectClass: TPressObjectClass;
    FObjectClassName: string;
    FOwnerMetadata: TPressObjectMetadata;
    FOwnerPartsMetadata: TPressAttributeMetadata;
    FParent: TPressObjectMetadata;
    FPersistentName: string;
    FShortName: string;
    FUpdateCountName: string;
    function GetAttributeMetadatas: TPressAttributeMetadataList;
    function GetIdMetadata: TPressAttributeMetadata;
    function GetMap: TPressClassMap;
    function GetObjectClass: TPressObjectClass;
    function GetOwnerClass: string;
    function GetShortName: string;
    procedure SetIsPersistent(AValue: Boolean);
    procedure SetOwnerClass(const Value: string);
    procedure SetPersistentName(const Value: string);
    function StoreClassIdName: Boolean;
    function StoreKeyName: Boolean;
    function StoreKeyType: Boolean;
    function StorePersistentName: Boolean;
    function StoreShortName: Boolean;
    function StoreUpdateCountName: Boolean;
  protected
    procedure Finit; override;
    function InternalAttributeMetadataClass: TPressAttributeMetadataClass; virtual;
    property Model: TPressModel read FModel;
  public
    constructor Create(const AObjectClassName: string; AModel: TPressModel); virtual;
    function CreateAttributeMetadata: TPressAttributeMetadata;
    property AttributeMetadatas: TPressAttributeMetadataList read GetAttributeMetadatas;
    property IdMetadata: TPressAttributeMetadata read GetIdMetadata;
    property Map: TPressClassMap read GetMap;
    property ObjectClass: TPressObjectClass read GetObjectClass;
    property ObjectClassName: string read FObjectClassName;
    property OwnerMetadata: TPressObjectMetadata read FOwnerMetadata;
    property OwnerPartsMetadata: TPressAttributeMetadata read FOwnerPartsMetadata;
    property Parent: TPressObjectMetadata read FParent;
  published
    property ClassIdName: string read FClassIdName write FClassIdName stored StoreClassIdName;
    property KeyName: string read FKeyName write FKeyName stored StoreKeyName;
    property KeyType: string read FKeyType write FKeyType stored StoreKeyType;
    property IsPersistent: Boolean read FIsPersistent write SetIsPersistent default False;
    property OwnerClass: string read GetOwnerClass write SetOwnerClass;
    property PersistentName: string read FPersistentName write SetPersistentName stored StorePersistentName;
    property ShortName: string read GetShortName write FShortName stored StoreShortName;
    property UpdateCountName: string read FUpdateCountName write FUpdateCountName stored StoreUpdateCountName;
  end;

  TPressObjectMetadataIterator = class;

  TPressObjectMetadataList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressObjectMetadata;
    procedure SetItems(AIndex: Integer; Value: TPressObjectMetadata);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressObjectMetadata): Integer;
    function CreateIterator: TPressObjectMetadataIterator;
    function IndexOf(AObject: TPressObjectMetadata): Integer;
    procedure Insert(Index: Integer; AObject: TPressObjectMetadata);
    function Remove(AObject: TPressObjectMetadata): Integer;
    property Items[AIndex: Integer]: TPressObjectMetadata read GetItems write SetItems; default;
  end;

  TPressObjectMetadataIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressObjectMetadata;
  public
    property CurrentItem: TPressObjectMetadata read GetCurrentItem;
  end;

  TPressQueryStyle = (qsOQL, qsReference, qsCustom);

  TPressQueryMetadata = class(TPressObjectMetadata)
  private
    FIncludeSubClasses: Boolean;
    FItemObjectClass: TPressObjectClass;
    FOrderFieldName: string;
    FStyle: TPressQueryStyle;
    function GetItemObjectClass: TPressObjectClass;
    function GetItemObjectClassName: string;
    procedure SetItemObjectClass(Value: TPressObjectClass);
    procedure SetItemObjectClassName(const Value: string);
  protected
    function InternalAttributeMetadataClass: TPressAttributeMetadataClass; override;
  public
    constructor Create(const AObjectClassName: string; AModel: TPressModel); override;
    property IncludeSubClasses: Boolean read FIncludeSubClasses;
    property ItemObjectClass: TPressObjectClass read GetItemObjectClass write SetItemObjectClass;
    property ItemObjectClassName: string read GetItemObjectClassName write SetItemObjectClassName;
    property OrderFieldName: string read FOrderFieldName;
  published
    property Any: Boolean read FIncludeSubClasses write FIncludeSubClasses default False;
    property Order: string read FOrderFieldName write FOrderFieldName;
    property Style: TPressQueryStyle read FStyle write FStyle;
  end;

  { Memento and Save Point declarations }

  TPressSavePoint = type Integer;

  TPressSavedPoint = class(TObject)
  private
    FSavePoint: TPressSavePoint;
    FIsChanged: Boolean;
  public
    constructor Create(ASavePoint: TPressSavePoint; AIsChanged: Boolean);
    property SavePoint: TPressSavePoint read FSavePoint;
    property IsChanged: Boolean read FIsChanged;
  end;

  TPressSavedPointList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressSavedPoint;
    procedure SetItems(AIndex: Integer; AValue: TPressSavedPoint);
  public
    function IndexOfNearestSavePoint(ASavePoint: TPressSavePoint): Integer;
    function IsChanged(ASavePoint: TPressSavePoint): Boolean;
    function Last: TPressSavedPoint;
    function LastSavePoint: TPressSavePoint;
    procedure RegisterSavePoint(ASavePoint: TPressSavePoint; AIsChanged: Boolean);
    procedure Shrink(ASavePoint: TPressSavePoint);
    property Items[AIndex: Integer]: TPressSavedPoint read GetItems write SetItems; default;
  end;

  TPressAttributeMementoList = class;

  TPressObjectMemento = class(TObject)
  private
    FAttributes: TPressAttributeMementoList;
    FOwner: TPressObject;
    FSavedPoints: TPressSavedPointList;
    function GetAttributes: TPressAttributeMementoList;
    function GetSubjectChanged: Boolean;
  protected
    procedure Notify(AAttribute: TPressAttribute);
    procedure Unchange;
    property Attributes: TPressAttributeMementoList read GetAttributes;
    property Owner: TPressObject read FOwner;
    property SavedPoints: TPressSavedPointList read FSavedPoints;
  public
    constructor Create(AOwner: TPressObject);
    destructor Destroy; override;
    function ChangedSince(ASavePoint: TPressSavePoint): Boolean;
    procedure Restore(ASavedPoint: TPressSavePoint);
    function SavePoint: TPressSavePoint;
    property SubjectChanged: Boolean read GetSubjectChanged;
  end;

  TPressAttributeMemento = class(TObject)
  private
    FIsChanged: Boolean;
    FOwner: TPressAttribute;
  protected
    procedure Init; virtual;
    procedure Modifying; virtual;
    procedure Restore; virtual; abstract;
    procedure RestoreChanged;
    property IsChanged: Boolean read FIsChanged;
    property Owner: TPressAttribute read FOwner;
  public
    constructor Create(AOwner: TPressAttribute);
    destructor Destroy; override;
  end;

  TPressAttributeMementoIterator = class;

  TPressAttributeMementoList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressAttributeMemento;
    procedure SetItems(AIndex: Integer; Value: TPressAttributeMemento);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressAttributeMemento): Integer;
    function CreateIterator: TPressAttributeMementoIterator;
    function Extract(AObject: TPressAttributeMemento): TPressAttributeMemento;
    function IndexOf(AObject: TPressAttributeMemento): Integer;
    function IndexOfOwner(AOwner: TPressAttribute): Integer;
    procedure Insert(Index: Integer; AObject: TPressAttributeMemento);
    function Remove(AObject: TPressAttributeMemento): Integer;
    property Items[AIndex: Integer]: TPressAttributeMemento read GetItems write SetItems; default;
  end;

  TPressAttributeMementoIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressAttributeMemento;
  public
    property CurrentItem: TPressAttributeMemento read GetCurrentItem;
  end;

  { Model declaration }

  TPressModelEvent = class(TPressEvent)
  end;

  TPressModelBusinessClassChangedEvent = class(TPressModelEvent)
  end;

  TPressModelAttributeChangedEvent = class(TPressModelEvent)
  end;

  TPressModel = class(TObject)
  private
    FAttributes: TClassList;
    FClasses: TClassList;
    FClassIdStorageName: string;
    FClassIdType: TPressAttributeClass;
    FDefaultKeyType: TPressAttributeClass;
    FEnumMetadatas: TPressEnumMetadataList;
    FMetadatas: TPressObjectMetadataList;
    FMetadatasFetched: Boolean;
    {$IFNDEF PressRelease}
    FNotifier: TPressNotifier;
    procedure Notify(AEvent: TPressEvent);
    {$ENDIF}
    procedure ClearAllMetadatas;
    procedure FetchAllMetadatas;
    function GetClassIdType: TPressAttributeClass;
    procedure SetClassIdStorageName(const Value: string);
    procedure SetClassIdType(Value: TPressAttributeClass);
    procedure SetDefaultKeyType(Value: TPressAttributeClass);
  protected
    function InternalFindAttribute(const AAttributeName: string): TPressAttributeClass; virtual;
    function InternalFindClass(const AClassName: string): TPressObjectClass; virtual;
    function InternalParentMetadataOf(AMetadata: TPressObjectMetadata): TPressObjectMetadata; virtual;
    property EnumMetadatas: TPressEnumMetadataList read FEnumMetadatas;
    property Metadatas: TPressObjectMetadataList read FMetadatas;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddAttribute(AAttributeClass: TPressAttributeClass);
    procedure AddClass(AClass: TPressObjectClass);
    function AttributeByName(const AAttributeName: string): TPressAttributeClass;
    function ClassByName(const AClassName: string): TPressObjectClass;
    function CreateMetadataIterator: TPressObjectMetadataIterator;
    function EnumMetadataByName(const AEnumName: string): TPressEnumMetadata;
    function FindAttribute(const AAttributeName: string): TPressAttributeClass;
    function FindAttributeClass(const AAttributeName: string): TPressAttributeClass;
    function FindClass(const AClassName: string): TPressObjectClass;
    function FindEnumMetadata(const AEnumName: string): TPressEnumMetadata;
    function FindMetadata(const AClassName: string): TPressObjectMetadata;
    function MetadataByName(const AClassName: string): TPressObjectMetadata;
    function ParentMetadataOf(AMetadata: TPressObjectMetadata): TPressObjectMetadata;
    function RegisterEnumMetadata(AEnumAddress: Pointer; const AEnumName: string): TPressEnumMetadata; overload;
    function RegisterEnumMetadata(AEnumAddress: Pointer; const AEnumName: string; AEnumValues: array of string): TPressEnumMetadata; overload;
    function RegisterMetadata(const AMetadataStr: string): TPressObjectMetadata;
    procedure RemoveAttribute(AAttributeClass: TPressAttributeClass);
    procedure RemoveClass(AClass: TPressObjectClass);
    procedure UnregisterMetadata(AMetadata: TPressObjectMetadata);
    property ClassIdStorageName: string read FClassIdStorageName write SetClassIdStorageName;
    property ClassIdType: TPressAttributeClass read GetClassIdType write SetClassIdType;
    property DefaultKeyType: TPressAttributeClass read FDefaultKeyType write SetDefaultKeyType;
  end;

  { DAO Params declarations }

  TPressAttributeBaseType = (attUnknown, attString, attInteger, attFloat,
   attCurrency, attEnum, attBoolean, attDate, attTime, attDateTime, attVariant,
   attMemo, attBinary, attPicture,
   attPart, attReference, attParts, attReferences);

  TPressParam = class(TObject)
  private
    FName: string;
    FValue: Variant;
    FParamType: TPressAttributeBaseType;
  public
    constructor Create(const AName: string; AParamType: TPressAttributeBaseType);
    property Name: string read FName;
    property ParamType: TPressAttributeBaseType read FParamType;
    property Value: Variant read FValue write FValue;
  end;

  TPressParamIterator = class;

  TPressParamList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressParam;
    procedure SetItems(AIndex: Integer; AValue: TPressParam);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressParam): Integer;
    function CreateIterator: TPressParamIterator;
    procedure Insert(AIndex: Integer; AObject: TPressParam);
    property Items[AIndex: Integer]: TPressParam read GetItems write SetItems; default;
  end;

  TPressParamIterator = class(TPressIterator)
  end;

  { Abstract Subject declarations }

  TPressSubjectEvent = class(TPressEvent)
  protected
    {$IFNDEF PressLogSubjectEvents}
    function AllowLog: Boolean; override;
    {$ENDIF}
  end;

  TPressSubjectUnchangedEvent = class(TPressSubjectEvent)
  end;

  TPressSubjectChangedEvent = class(TPressSubjectEvent)
  end;

  TPressSubjectClass = class of TPressSubject;

  TPressSubject = class(TPressStreamable)
  private
    FChangedWhenDisabled: Boolean;
    FChangedWhenUpdating: Boolean;
    FChangesDisabled: Boolean;
    FChangesDisabledCount: Integer;
    FIsChanged: Boolean;
    FUpdating: Boolean;
    FUpdatingCount: Integer;
  protected
    procedure Changed(AUpdateIsChangedFlag: Boolean = True);
    procedure Changing;
    function GetSignature: string; virtual;
    procedure InternalChanged(AChangedWhenDisabled: Boolean); virtual;
    procedure InternalChangesDisabled; virtual;
    procedure InternalChangesEnabled; virtual;
    procedure InternalChanging; virtual;
    procedure InternalUnchanged; virtual;
    procedure InternalUpdateFinished; virtual;
    procedure InternalUpdateStarted; virtual;
  public
    procedure BeginUpdate;
    procedure DisableChanges;
    procedure EnableChanges;
    procedure EndUpdate;
    procedure Unchanged;
    property ChangesDisabled: Boolean read FChangesDisabled;
    property IsChanged: Boolean read FIsChanged;
    property Signature: string read GetSignature;
    property Updating: Boolean read FUpdating;
  end;

  TPressQuery = class;
  TPressProxyList = class;

  IPressDAO = interface(IInterface)
  ['{8B46DE54-6987-477B-8AA4-9176D66018D4}']
    procedure AssignObject(AObject: TPressObject);
    procedure BulkRetrieve(AProxyList: TPressProxyList; AStartingAt, AItemCount, ADepth: Integer);
    procedure Commit;
    procedure Dispose(AClass: TPressObjectClass; const AId: string);
    function ExecuteStatement(const AStatement: string; AParams: TPressParamList = nil): Integer;
    function GenerateOID(AClass: TPressObjectClass; const AAttributeName: string = ''): string;
    function OQLQuery(const AOQLStatement: string; AParams: TPressParamList = nil): TPressProxyList;
    procedure Refresh(AObject: TPressObject);
    procedure ReleaseObject(AObject: TPressObject);
    function Retrieve(AClass: TPressObjectClass; const AId: string; AMetadata: TPressObjectMetadata = nil): TPressObject;
    function RetrieveQuery(AQuery: TPressQuery): TPressProxyList;
    procedure Rollback;
    procedure ShowConnectionManager;
    function SQLProxy(const ASQLStatement: string; AParams: TPressParamList = nil): TPressProxyList;
    function SQLQuery(AClass: TPressObjectClass; const ASQLStatement: string; AParams: TPressParamList = nil): TPressProxyList;
    procedure StartTransaction;
    procedure Store(AObject: TPressObject);
  end;

  { Business Object base-type declarations }

  TPressObjectUnchangedEvent = class(TPressSubjectUnchangedEvent)
  end;

  TPressObjectChangedEvent = class(TPressSubjectChangedEvent)
  end;

  TPressLockingEvent = class(TPressSubjectEvent)
  end;

  TPressLockObjectEvent = class(TPressLockingEvent)
  end;

  TPressUnlockObjectEvent = class(TPressLockingEvent)
  end;

  TDate = TDateTime;
  TTime = TDateTime;

  TPressObjectOperation = procedure(AObject: TPressObject) of object;

  TPressAttributeList = class;
  TPressAttributeIterator = class;
  TPressStructure = class;

  TPressObject = class(TPressSubject)
  { TODO : Remove persistence members }
  private
    FAttributes: TPressAttributeList;
    FDataAccess: IPressDAO;
    FId: TPressAttribute;
    FMap: TPressClassMap;
    FMemento: TPressObjectMemento;
    FMetadata: TPressObjectMetadata;
    FOwnerAttribute: TPressStructure;
    FPersistentId: string;
    FPersUpdateCount: Integer;
    FUpdateCount: Integer;
    procedure AttributesDisableChanges;
    procedure AttributesEnableChanges;
    procedure CreateAttributes;
    function GetAttributes(AIndex: Integer): TPressAttribute;
    function GetDataAccess: IPressDAO;
    function GetId: string;
    function GetIsOwned: Boolean;
    function GetIsPersistent: Boolean;
    function GetIsUpdated: Boolean;
    function GetIsValid: Boolean;
    function GetMap: TPressClassMap;
    function GetMemento: TPressObjectMemento;
    function GetMetadata: TPressObjectMetadata;
    function GetObjectOwner: TPressObject;
    function GetPersistentName: string;
    procedure NotifyMemento(AAttribute: TPressAttribute);
    procedure SetId(const Value: string);
    procedure UnchangeAttributes;
  protected
    procedure AfterCreate; virtual;
    procedure AfterCreateAttributes; virtual;
    procedure AfterDispose; virtual;
    procedure AfterRetrieve; virtual;
    procedure AfterStore; virtual;
    procedure BeforeCreateAttributes; virtual;
    procedure BeforeDispose; virtual;
    procedure BeforeStore; virtual;
    procedure ClearOwnerContext;
    procedure Finit; override;
    function GetOwner: TPersistent; override;
    procedure Init; virtual;
    procedure InitInstance(ADataAccess: IPressDAO; AMetadata: TPressObjectMetadata);
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; virtual;
    procedure InternalCalcAttribute(AAttribute: TPressAttribute); virtual;
    procedure InternalChanged(AChangedWhenDisabled: Boolean); override;
    procedure InternalChangesDisabled; override;
    procedure InternalChangesEnabled; override;
    procedure InternalChanging; override;
    procedure InternalDispose(ADisposeMethod: TPressObjectOperation); virtual;
    function InternalIsValid: Boolean; virtual;
    procedure InternalLock; override;
    procedure InternalRefresh(ARefreshMethod: TPressObjectOperation); virtual;
    procedure InternalStore(AStoreMethod: TPressObjectOperation); virtual;
    procedure InternalUnchanged; override;
    procedure InternalUnlock; override;
    class function InternalMetadataStr: string; virtual;
    procedure NotifyChange;
    procedure NotifyUnchange;
    procedure SetOwnerContext(AOwner: TPressStructure);
  public
    constructor Create(ADataAccess: IPressDAO = nil; AMetadata: TPressObjectMetadata = nil);
    constructor Retrieve(const AId: string; ADataAccess: IPressDAO = nil; AMetadata: TPressObjectMetadata = nil);
    procedure Assign(Source: TPersistent); override;
    function AttributeByName(const AAttributeName: string): TPressAttribute;
    function AttributeByPath(const APath: string): TPressAttribute;
    function AttributeCount: Integer;
    class function ClassMap: TPressClassMap;
    class function ClassMetadata: TPressObjectMetadata;
    class function ClassMetadataStr: string;
    {$IFDEF FPC}class{$ENDIF} function ClassType: TPressObjectClass;
    function Clone: TPressObject;
    function CreateAttributeIterator: TPressAttributeIterator;
    procedure Dispose;
    function FindAttribute(const AAttributeName: string): TPressAttribute;
    function FindPathAttribute(const APath: string; ASilent: Boolean = True): TPressAttribute;
    class function ObjectMetadataClass: TPressObjectMetadataClass; virtual;
    procedure Refresh;
    class procedure RegisterClass;
    procedure Store;
    class procedure UnregisterClass;
    property Attributes[AIndex: Integer]: TPressAttribute read GetAttributes;
    property DataAccess: IPressDAO read GetDataAccess;
    property Id: string read GetId write SetId;
    property IsOwned: Boolean read GetIsOwned;
    property IsPersistent: Boolean read GetIsPersistent;
    property IsUpdated: Boolean read GetIsUpdated;
    property IsValid: Boolean read GetIsValid;
    property Map: TPressClassMap read GetMap;
    property Memento: TPressObjectMemento read GetMemento;
    property Metadata: TPressObjectMetadata read GetMetadata;
    property Owner: TPressObject read GetObjectOwner;
    property OwnerAttribute: TPressStructure read FOwnerAttribute;
    property PersistentId: string read FPersistentId;
    property PersistentName: string read GetPersistentName;
    property PersUpdateCount: Integer read FPersUpdateCount;
    property UpdateCount: Integer read FUpdateCount;
  end;

  TPressObjectIterator = class;

  TPressObjectList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressObject;
    procedure SetItems(AIndex: Integer; const Value: TPressObject);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressObject): Integer;
    function CreateIterator: TPressObjectIterator;
    function IndexOf(AObject: TPressObject): Integer;
    procedure Insert(Index: Integer; AObject: TPressObject);
    function Remove(AObject: TPressObject): Integer;
    property Items[AIndex: Integer]: TPressObject read GetItems write SetItems; default;
  end;

  TPressObjectIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressObject;
  public
    property CurrentItem: TPressObject read GetCurrentItem;
  end;

  TPressProxy = class;
  TPressProxyIterator = class;

  TPressQueryClass = class of TPressQuery;
  TPressQueryIterator = TPressProxyIterator;

  TPressQuery = class(TPressObject)
  private
    FQueryItems: TPressAttribute;  // TPressReferences;
    FItemsDataAccess: IPressDAO;
    FMatchEmptyAndNull: Boolean;
    FParams: TPressParamList;
    FStyle: TPressQueryStyle;
    function GetItemsDataAccess: IPressDAO;
    function GetMetadata: TPressQueryMetadata;
    function GetObjects(AIndex: Integer): TPressObject;
    function GetParams: TPressParamList;
    procedure SetStyle(AValue: TPressQueryStyle);
  protected
    procedure ConcatStatements(const AStatementStr, AConnectorToken: string; var ABuffer: string);
    procedure Finit; override;
    function GetFieldNamesClause: string; virtual;
    function GetFromClause: string; virtual;
    function GetGroupByClause: string; virtual;
    function GetOrderByClause: string; virtual;
    function GetWhereClause: string; virtual;
    procedure Init; override;
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    function InternalBuildStatement(AAttribute: TPressAttribute): string; virtual;
    procedure InternalExecute; virtual;
  public
    function Add(AObject: TPressObject): Integer;
    function AddAttributeParam(AAttribute: TPressAttribute): string;
    function AddParam(AParamType: TPressAttributeBaseType; const AName: string = ''): TPressParam;
    function AddValueParam(AValue: Variant; AAttributeType: TPressAttributeBaseType): string;
    procedure Clear;
    function Count: Integer;
    class function ClassMetadata: TPressQueryMetadata;
    function CreateIterator: TPressQueryIterator;
    procedure Execute;
    class function ObjectMetadataClass: TPressObjectMetadataClass; override;
    function Remove(AObject: TPressObject): Integer;
    function RemoveReference(AProxy: TPressProxy): Integer;
    property FieldNamesClause: string read GetFieldNamesClause;
    property FromClause: string read GetFromClause;
    property GroupByClause: string read GetGroupByClause;
    property ItemsDataAccess: IPressDAO read GetItemsDataAccess;
    property MatchEmptyAndNull: Boolean read FMatchEmptyAndNull write FMatchEmptyAndNull;
    property Metadata: TPressQueryMetadata read GetMetadata;
    property Objects[AIndex: Integer]: TPressObject read GetObjects; default;
    property OrderByClause: string read GetOrderByClause;
    property Params: TPressParamList read GetParams;
    property Style: TPressQueryStyle read FStyle write SetStyle;
    property WhereClause: string read GetWhereClause;
  end;

  TPressSingletonObject = class(TPressObject)
  protected
    class function SingletonOID: string; virtual;
  public
    constructor Instance;
    class procedure RegisterOID(AOID: string);
  end;

  { Proxy declarations }

  TPressProxyType = (ptOwned, ptShared, ptWeakReference);

  TPressProxyChangeType = (pctAssigning, pctDereferencing);

  TPressProxyChangeInstanceEvent = procedure(
   Sender: TPressProxy; Instance: TPressObject;
   ChangeType: TPressProxyChangeType) of object;

  TPressProxyChangeReferenceEvent = procedure(
   Sender: TPressProxy; AClass: TPressObjectClass; const AId: string) of object;

  TPressProxyRetrieveInstanceEvent = procedure(
   Sender: TPressProxy) of object;

  TPressProxy = class(TPressManagedObject)
  { TODO : Refactor some notifications and the Structure attributes
    in order to make the Proxy works as noiselessly as possible }
  private
    FAfterChangeInstance: TPressProxyChangeInstanceEvent;
    FAfterChangeReference: TPressProxyChangeReferenceEvent;
    FBeforeChangeInstance: TPressProxyChangeInstanceEvent;
    FBeforeChangeReference: TPressProxyChangeReferenceEvent;
    FBeforeRetrieveInstance: TPressProxyRetrieveInstanceEvent;
    FDataAccess: IPressDAO;
    FInstance: TPressObject;
    FOwner: TPressProxyList;
    FProxyType: TPressProxyType;
    FRefClass: TPressObjectClass;
    FRefCount: Integer;
    FRefID: string;
    procedure BulkRetrieve;
    procedure Dereference;
    function GetInstance: TPressObject;
    function GetObjectClassName: string;
    function GetObjectClassType: TPressObjectClass;
    function GetObjectId: string;
    function IsEmptyReference(ARefClass: TPressObjectClass; const ARefID: string): Boolean;
    procedure SetInstance(Value: TPressObject);
  protected
    procedure Finit; override;
  public
    constructor Create(AProxyType: TPressProxyType; AObject: TPressObject = nil);
    procedure Assign(Source: TPersistent); override;
    procedure AssignReference(const ARefClass, ARefID: string; ADataAccess: IPressDAO); overload;
    procedure AssignReference(ARefClass: TPressObjectClass; const ARefID: string; ADataAccess: IPressDAO); overload;
    procedure Clear;
    procedure ClearInstance;
    procedure ClearReference;
    function Clone: TPressProxy;
    function HasInstance: Boolean;
    function HasReference: Boolean;
    function IsEmpty: Boolean;
    function SameReference(AObject: TPressObject): Boolean; overload;
    function SameReference(const ARefClass, ARefID: string): Boolean; overload;
    function SameReference(ARefClass: TPressObjectClass; const ARefID: string): Boolean; overload;
    property AfterChangeInstance: TPressProxyChangeInstanceEvent read FAfterChangeInstance write FAfterChangeInstance;
    property AfterChangeReference: TPressProxyChangeReferenceEvent read FAfterChangeReference write FAfterChangeReference;
    property BeforeChangeInstance: TPressProxyChangeInstanceEvent read FBeforeChangeInstance write FBeforeChangeInstance;
    property BeforeChangeReference: TPressProxyChangeReferenceEvent read FBeforeChangeReference write FBeforeChangeReference;
    property BeforeRetrieveInstance: TPressProxyRetrieveInstanceEvent read FBeforeRetrieveInstance write FBeforeRetrieveInstance;
    property DataAccess: IPressDAO read FDataAccess;
    property Instance: TPressObject read GetInstance write SetInstance;
    property ObjectClassName: string read GetObjectClassName;
    property ObjectClassType: TPressObjectClass read GetObjectClassType;
    property ObjectId: string read GetObjectId;
    property ProxyType: TPressProxyType read FProxyType;
  end;

  TPressProxyListEvent = procedure(
   Sender: TPressProxyList;
   Item: TPressProxy; Action: TListNotification) of object;

  TPressProxyList = class(TPressList)
  private
    FDisableNotificationCount: Integer;
    FOnChangeList: TPressProxyListEvent;
    FProxyType: TPressProxyType;
    function CreateProxy: TPressProxy;
    function GetInstances(AIndex: Integer): TPressObject;
    function GetItems(AIndex: Integer): TPressProxy;
    function GetNotificationDisabled: Boolean;
    procedure SetInstances(AIndex: Integer; Value: TPressObject);
    procedure SetItems(AIndex: Integer; Value: TPressProxy);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    constructor Create(AOwnsObjects: Boolean; AProxyType: TPressProxyType);
    function Add(AObject: TPressProxy): Integer;
    function AddInstance(AObject: TPressObject): Integer;
    function AddReference(const ARefClass, ARefID: string; ADataAccess: IPressDAO): Integer;
    function CreateIterator: TPressProxyIterator;
    procedure DisableNotification;
    procedure EnableNotification;
    function Extract(AObject: TPressProxy): TPressProxy;
    function IndexOf(AObject: TPressProxy): Integer;
    function IndexOfInstance(AObject: TPressObject): Integer;
    function IndexOfReference(const ARefClass, ARefID: string): Integer;
    procedure Insert(Index: Integer; AObject: TPressProxy);
    procedure InsertInstance(Index: Integer; AObject: TPressObject);
    procedure InsertReference(Index: Integer; const ARefClass, ARefID: string; ADataAccess: IPressDAO);
    function Remove(AObject: TPressProxy): Integer;
    function RemoveInstance(AObject: TPressObject): Integer;
    function RemoveReference(const ARefClass, ARefID: string): Integer;
    property Instances[AIndex: Integer]: TPressObject read GetInstances write SetInstances;
    property Items[AIndex: Integer]: TPressProxy read GetItems write SetItems; default;
    property NotificationDisabled: Boolean read GetNotificationDisabled;
    property OnChangeList: TPressProxyListEvent read FOnChangeList write FOnChangeList;
    property ProxyType: TPressProxyType read FProxyType;
  end;

  TPressProxyIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressProxy;
  public
    property CurrentItem: TPressProxy read GetCurrentItem;
  end;

  { Attribute base-type declarations }

  TPressAttributeChangedEvent = class(TPressSubjectChangedEvent)
  end;

  TPressAttribute = class(TPressSubject)
  private
    FCalcUpdated: Boolean;
    FIsCalculating: Boolean;
    FIsNull: Boolean;
    FMetadata: TPressAttributeMetadata;
    FNotifier: TPressNotifier;
    FOwner: TPressObject;
    FUsePublishedGetter: Boolean;
    FUsePublishedSetter: Boolean;
    function CreateMemento: TPressAttributeMemento;
    function GetDataAccess: IPressDAO;
    function GetDefaultValue: string;
    function GetEditMask: string;
    function GetIsCalcAttribute: Boolean;
    function GetIsNull: Boolean;
    function GetName: string;
    function GetNotifier: TPressNotifier;
    function GetPersistentName: string;
    function GetUsePublishedGetter: Boolean;
    function GetUsePublishedSetter: Boolean;
    procedure InitPropInfo;
  protected
    function AccessError(const AAttributeName: string): EPressError;
    { TODO : Use exception messages from the PressDialog class }
    function ConversionError(E: EConvertError): EPressConversionError;
    function InvalidClassError(const AClassName: string): EPressError;
    function InvalidValueError(AValue: Variant; E: EVariantError): EPressError;
    { TODO : Review the need of As<Type> methods }
    procedure BindCalcNotification(AInstance: TPressObject);
    procedure Finit; override;
    function GetAsBoolean: Boolean; virtual;
    function GetAsCurrency: Currency; virtual;
    function GetAsDate: TDate; virtual;
    function GetAsDateTime: TDateTime; virtual;
    function GetAsFloat: Double; virtual;
    function GetAsInteger: Integer; virtual;
    function GetAsString: string; virtual;
    function GetAsTime: TTime; virtual;
    function GetAsVariant: Variant; virtual;
    function GetDisplayText: string; virtual;
    function GetIsEmpty: Boolean; virtual;
    procedure Initialize; virtual;
    procedure InternalChanged(AChangedWhenDisabled: Boolean); override;
    procedure InternalChanging; override;
    function InternalCreateMemento: TPressAttributeMemento; virtual; abstract;
    procedure InternalReset; virtual;
    function InternalTypeKinds: TTypeKinds; virtual;
    procedure Notify(AEvent: TPressEvent); virtual;
    procedure NotifyChange;
    procedure ReleaseCalcNotification(AInstance: TPressObject);
    procedure SetAsBoolean(AValue: Boolean); virtual;
    procedure SetAsCurrency(AValue: Currency); virtual;
    procedure SetAsDate(AValue: TDate); virtual;
    procedure SetAsDateTime(AValue: TDateTime); virtual;
    procedure SetAsFloat(AValue: Double); virtual;
    procedure SetAsInteger(AValue: Integer); virtual;
    procedure SetAsString(const AValue: string); virtual;
    procedure SetAsTime(AValue: TTime); virtual;
    procedure SetAsVariant(AValue: Variant); virtual;
    function ValidateChars(const AStr: string; const AChars: TChars): Boolean;
    procedure ValueAssigned(AUpdateIsChangedFlag: Boolean = True);
    procedure ValueUnassigned;
    procedure VerifyCalcAttribute;
    property UsePublishedGetter: Boolean read GetUsePublishedGetter;
    property UsePublishedSetter: Boolean read GetUsePublishedSetter;
    property Notifier: TPressNotifier read GetNotifier;
  public
    constructor Create(AOwner: TPressObject; AMetadata: TPressAttributeMetadata); virtual;
    class function AttributeBaseType: TPressAttributeBaseType; virtual; abstract;
    class function AttributeName: string; virtual; abstract;
    {$IFDEF FPC}class{$ENDIF} function ClassType: TPressAttributeClass;
    procedure Clear;
    function Clone: TPressAttribute;
    class procedure RegisterAttribute;
    class procedure UnregisterAttribute;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property AsCurrency: Currency read GetAsCurrency write SetAsCurrency;
    property AsDate: TDate read GetAsDate write SetAsDate;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsString: string read GetAsString write SetAsString;
    property AsTime: TTime read GetAsTime write SetAsTime;
    property AsVariant: Variant read GetAsVariant write SetAsVariant;
    property DataAccess: IPressDAO read GetDataAccess;
    property DefaultValue: string read GetDefaultValue;
    property DisplayText: string read GetDisplayText;
    property EditMask: string read GetEditMask;
    property IsCalcAttribute: Boolean read GetIsCalcAttribute;
    property IsCalculating: Boolean read FIsCalculating;
    property IsEmpty: Boolean read GetIsEmpty;
    property IsNull: Boolean read GetIsNull;
    property Metadata: TPressAttributeMetadata read FMetadata;
    property Name: string read GetName;
    property Owner: TPressObject read FOwner;
    property PersistentName: string read GetPersistentName;
  end;

  TPressAttributeList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressAttribute;
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressAttribute): Integer;
    function CreateIterator: TPressAttributeIterator;
    function FindAttribute(const AAttributeName: string): TPressAttribute;
    function IndexOf(AObject: TPressAttribute): Integer;
    procedure Insert(Index: Integer; AObject: TPressAttribute);
    function Remove(AObject: TPressAttribute): Integer;
    property Items[AIndex: Integer]: TPressAttribute read GetItems; default;
  end;

  TPressAttributeIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressAttribute;
  public
    property CurrentItem: TPressAttribute read GetCurrentItem;
  end;

  { Structured attributes declarations }

  TPressStructureUnassignObjectEvent = class(TPressSubjectEvent)
  private
    FUnassignedObject: TPressObject;
  public
    constructor Create(AOwner: TObject; AUnassignedObject: TPressObject);
    destructor Destroy; override;
    property UnassignedObject: TPressObject read FUnassignedObject;
  end;

  TPressReferenceChangedEvent = class(TPressSubjectEvent)
  private
    FInstance: TPressObject;
  public
    constructor Create(AOwner: TObject; AInstance: TPressObject);
    property Instance: TPressObject read FInstance;
  end;

  TPressStructureClass = class of TPressStructure;

  TPressStructure = class(TPressAttribute)
  private
    function GetObjectClass: TPressObjectClass;
  protected
    procedure AfterChangeInstance(Sender: TPressProxy; Instance: TPressObject; ChangeType: TPressProxyChangeType); virtual;
    procedure AfterChangeReference(Sender: TPressProxy; AClass: TPressObjectClass; const AId: string); virtual;
    procedure BeforeChangeInstance(Sender: TPressProxy; Instance: TPressObject; ChangeType: TPressProxyChangeType); virtual;
    procedure BeforeChangeItem(AItem: TPressObject); virtual;
    procedure BeforeChangeReference(Sender: TPressProxy; AClass: TPressObjectClass; const AId: string); virtual;
    procedure BeforeRetrieveInstance(Sender: TPressProxy); virtual;
    procedure BindInstance(AInstance: TPressObject); virtual;
    procedure BindProxy(AProxy: TPressProxy);
    procedure ChangedItem(AInstance: TPressObject; AUpdateIsChangedFlag: Boolean); virtual;
    procedure InternalAssignItem(AProxy: TPressProxy); virtual; abstract;
    procedure InternalAssignObject(AObject: TPressObject); virtual; abstract;
    function InternalProxyType: TPressProxyType; virtual; abstract;
    procedure InternalUnassignObject(AObject: TPressObject); virtual; abstract;
    procedure ReferenceChanged(AInstance: TPressObject);
    procedure ReleaseInstance(AInstance: TPressObject); virtual;
    procedure ValidateObject(AObject: TPressObject);
    procedure ValidateObjectClass(AClass: TPressObjectClass); overload;
    procedure ValidateObjectClass(const AClassName: string); overload;
    procedure ValidateProxy(AProxy: TPressProxy);
  public
    procedure AssignItem(AProxy: TPressProxy);
    procedure AssignObject(AObject: TPressObject);
    function ProxyType: TPressProxyType;
    procedure UnassignObject(AObject: TPressObject);
    class function ValidObjectClass: TPressObjectClass; virtual;
    property ObjectClass: TPressObjectClass read GetObjectClass;
  end;

procedure PressAssignPersistentId(AObject: TPressObject; const AId: string);
procedure PressAssignUpdateCount(AObject: TPressObject; ANewValue: Integer);
procedure PressAssignPersistentUpdateCount(AObject: TPressObject);
procedure PressEvolveUpdateCount(AObject: TPressObject);
function PressModel: TPressModel;
function PressDefaultDAO: IPressDAO;

implementation

uses
  PressConsts,
  {$IFDEF PressLog}PressLog,{$ENDIF}
  PressAttributes,
  PressMetadata;

type
  TPressQueryItems = class(TPressReferences)
  protected
    procedure InternalUnassignObject(AObject: TPressObject); override;
  end;

var
  _SingletonIDs: IPressHolder; //TStrings;
  _Model: IPressHolder; //TPressModel;

function PressSingletonIDs: TStrings;
begin
  if not Assigned(_SingletonIDs) then
    _SingletonIDs := TPressHolder.Create(TStringList.Create);
  Result := TStrings(_SingletonIDs.Instance);
end;

{ Global routines }

function PressModel: TPressModel;
begin
  if not Assigned(_Model) then
    _Model := TPressHolder.Create(TPressModel.Create);
  Result := TPressModel(_Model.Instance);
end;

procedure PressAssignPersistentId(AObject: TPressObject; const AId: string);
begin
  if AObject.FPersistentId <> AId then
  begin
    if AId <> '' then
      AObject.FId.AsString := AId;  // friend class
    AObject.FPersistentId := AId;  // friend class
  end;
end;

procedure PressAssignUpdateCount(AObject: TPressObject; ANewValue: Integer);
begin
  AObject.FUpdateCount := ANewValue;  // friend class
  AObject.FPersUpdateCount := ANewValue;  // friend class
end;

procedure PressAssignPersistentUpdateCount(AObject: TPressObject);
begin
  AObject.FPersUpdateCount := AObject.FUpdateCount;  // friend classes
end;

procedure PressEvolveUpdateCount(AObject: TPressObject);
begin
  if AObject.UpdateCount < Pred(High(AObject.UpdateCount)) then
    Inc(AObject.FUpdateCount)  // friend class
  else
    AObject.FUpdateCount := 1;  // friend class
end;

function PressDefaultDAO: IPressDAO;
begin
  Result := PressApp.Registry[CPressDAOService].DefaultService as IPressDAO;
end;

{ TPressEnumMetadata }

constructor TPressEnumMetadata.Create(ATypeAddress: Pointer);
var
  I: Integer;
  VTypeData: PTypeData;
begin
  inherited Create;
  FTypeAddress := ATypeAddress;
  VTypeData := GetTypeData(FTypeAddress);
  FItems := TStringList.Create;
  for I := VTypeData^.MinValue to VTypeData^.MaxValue do
    FItems.Add(RemoveEnumItemPrefix(GetEnumName(FTypeAddress, I)));
end;

constructor TPressEnumMetadata.Create(
  ATypeAddress: Pointer; AEnumValues: array of string);
var
  I, J: Integer;
  VTypeData: PTypeData;
begin
  inherited Create;
  FTypeAddress := ATypeAddress;
  VTypeData := GetTypeData(FTypeAddress);
  FItems := TStringList.Create;
  J := Low(AEnumValues);
  for I := VTypeData^.MinValue to VTypeData^.MaxValue do
    if J <= High(AEnumValues) then
    begin
      FItems.Add(AEnumValues[J]);
      Inc(J);
    end else
      FItems.Add(RemoveEnumItemPrefix(GetEnumName(FTypeAddress, I)));
end;

destructor TPressEnumMetadata.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TPressEnumMetadata.RemoveEnumItemPrefix(
  const AEnumName: string): string;
var
  I: Integer;
  VLen: Integer;
begin
  VLen := Length(AEnumName);
  for I := 1 to VLen do
    if AEnumName[I] in ['A'..'Z'] then
    begin
      Result := Copy(AEnumName, I, VLen);
      Exit;
    end;
  Result := AEnumName;
end;

{ TPressEnumMetadataList }

function TPressEnumMetadataList.Add(AObject: TPressEnumMetadata): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressEnumMetadataList.CreateIterator: TPressEnumMetadataIterator;
begin
  Result := TPressEnumMetadataIterator.Create(Self);
end;

function TPressEnumMetadataList.Extract(
  AObject: TPressEnumMetadata): TPressEnumMetadata;
begin
  Result := inherited Extract(AObject) as TPressEnumMetadata;
end;

function TPressEnumMetadataList.GetItems(
  AIndex: Integer): TPressEnumMetadata;
begin
  Result := inherited Items[AIndex] as TPressEnumMetadata;
end;

function TPressEnumMetadataList.IndexOf(
  AObject: TPressEnumMetadata): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressEnumMetadataList.Insert(
  Index: Integer; AObject: TPressEnumMetadata);
begin
  inherited Insert(Index, AObject);
end;

function TPressEnumMetadataList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressEnumMetadataList.Remove(
  AObject: TPressEnumMetadata): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressEnumMetadataList.SetItems(
  AIndex: Integer; Value: TPressEnumMetadata);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressEnumMetadataIterator }

function TPressEnumMetadataIterator.GetCurrentItem: TPressEnumMetadata;
begin
  Result := inherited CurrentItem as TPressEnumMetadata;
end;

{ TPressCalcMetadata }

procedure TPressCalcMetadata.AddListenedAttribute(
  const AAttributePath: string);
begin
  FListenedAttributes.Add(AAttributePath);
end;

procedure TPressCalcMetadata.BindCalcNotification(
  AInstance: TPressObject; ANotifier: TPressNotifier);
var
  I: Integer;
begin
  for I := 0 to Pred(FListenedAttributes.Count) do
    { TODO : only one level }
    ANotifier.AddNotificationItem(
     AInstance.AttributeByPath(FListenedAttributes[I]), [
     TPressAttributeChangedEvent]);
end;

constructor TPressCalcMetadata.Create;
begin
  FListenedAttributes := TStringList.Create;
end;

destructor TPressCalcMetadata.Destroy;
begin
  FListenedAttributes.Free;
  inherited;
end;

procedure TPressCalcMetadata.ReleaseCalcNotification(
  AInstance: TPressObject; ANotifier: TPressNotifier);
var
  I: Integer;
begin
  for I := 0 to Pred(FListenedAttributes.Count) do
    ANotifier.RemoveNotificationItem(
     AInstance.AttributeByPath(FListenedAttributes[I]));
end;

{ TPressAttributeMetadata }

function TPressAttributeMetadata.BuildPersLinkChildName: string;
begin
  if Assigned(Owner) then
    if IsEmbeddedLink then
      Result := ObjectClassMetadata.IdMetadata.PersistentName
    else
      Result := ShortName + SPressIdString
  else
    Result := SPressChildString + SPressIdString;
end;

function TPressAttributeMetadata.BuildPersLinkName: string;
begin
  if Assigned(Owner) then
    if IsEmbeddedLink then
      Result := ObjectClassMetadata.PersistentName
    else
      Result := Owner.ShortName + '_' + ShortName
  else
    Result := '_' + ShortName;
end;

function TPressAttributeMetadata.BuildPersLinkParentName: string;
begin
  if Assigned(Owner) then
    Result := Owner.ShortName + SPressIdString
  else
    Result := SPressParentString + SPressIdString;
end;

constructor TPressAttributeMetadata.Create(AOwner: TPressObjectMetadata);
begin
  inherited Create;
  { TODO : Validate Owner }
  FOwner := AOwner;
  if Assigned(FOwner) then
  begin
    FOwner.AttributeMetadatas.Add(Self);
    FModel := FOwner.Model;
  end else
    FModel := PressModel;
  FIsPersistent := True;
  FPersLinkIdName := SPressIdString;
  FPersLinkPosName := SPressItemPosString;
end;

function TPressAttributeMetadata.CreateAttribute(
  AOwner: TPressObject): TPressAttribute;
begin
  if Assigned(FAttributeClass) then
    Result := FAttributeClass.Create(AOwner, Self)
  else
    raise EPressError.CreateFmt(SUnassignedAttributeType,
     [AOwner.ClassName, Name]);
end;

procedure TPressAttributeMetadata.Finit;
begin
  FCalcMetadata.Free;
  if Assigned(FOwner) then
    FOwner.AttributeMetadatas.Extract(Self);
  inherited;
end;

function TPressAttributeMetadata.GetAttributeName: string;
begin
  if Assigned(FAttributeClass) then
    Result := FAttributeClass.AttributeName
  else
    Result := '';
end;

function TPressAttributeMetadata.GetObjectClassName: string;
begin
  if Assigned(FObjectClass) then
    Result := FObjectClass.ClassName
  else
    Result := '';
end;

function TPressAttributeMetadata.GetPersLinkChildName: string;
begin
  if FPersLinkChildName = '' then
    FPersLinkChildName := BuildPersLinkChildName;
  Result := FPersLinkChildName;
end;

function TPressAttributeMetadata.GetPersLinkName: string;
begin
  if FPersLinkName = '' then
    FPersLinkName := BuildPersLinkName;
  Result := FPersLinkName;
end;

function TPressAttributeMetadata.GetPersLinkParentName: string;
begin
  if FPersLinkParentName = '' then
    FPersLinkParentName := BuildPersLinkParentName;
  Result := FPersLinkParentName;
end;

function TPressAttributeMetadata.GetShortName: string;
begin
  if FShortName = '' then
    FShortName := FPersistentName;
  Result := FShortName;
end;

function TPressAttributeMetadata.IsEmbeddedLink: Boolean;
begin
  Result := Assigned(FOwner) and Assigned(FObjectClassMetadata) and
   (FOwner = FObjectClassMetadata.OwnerMetadata);
end;

procedure TPressAttributeMetadata.SetAttributeClass(
  Value: TPressAttributeClass);
begin
  if FAttributeClass <> Value then
  begin
    FAttributeClass := Value;

    { TODO : Improve }
    { TODO : Implement estimated size per-attribute type after
      implementing metadata inheritance per attribute class }
    if (FSize = 0) and (FAttributeClass.AttributeBaseType in [
     attInteger, attFloat, attCurrency, attEnum, attBoolean,
     attDate, attTime, attDateTime]) then
      FSize := 10;
    if (FEditMask = '') and (FAttributeClass = TPressCurrency) then
      FEditMask := ',0.00';

  end;
end;

procedure TPressAttributeMetadata.SetAttributeName(const Value: string);
var
  VAttributeClass: TPressAttributeClass;
begin
  VAttributeClass := Model.FindAttribute(Value);
  if not Assigned(VAttributeClass) then
    raise EPressError.CreateFmt(SUnsupportedAttributeType, [Value]);
  AttributeClass := VAttributeClass;
end;

procedure TPressAttributeMetadata.SetCalcMetadata(Value: TPressCalcMetadata);
begin
  FCalcMetadata.Free;
  FCalcMetadata := Value;
end;

procedure TPressAttributeMetadata.SetEnumMetadata(Value: TPressEnumMetadata);
begin
  FEnumMetadata.Free;
  FEnumMetadata := Value;
end;

procedure TPressAttributeMetadata.SetName(const Value: string);
begin
  FName := Value;
  if FPersistentName = '' then
    FPersistentName := FName;
end;

procedure TPressAttributeMetadata.SetObjectClass(Value: TPressObjectClass);
begin
  if (Value <> FObjectClass) and Assigned(FAttributeClass) and
   FAttributeClass.InheritsFrom(TPressStructure) then
  begin
    if not Value.InheritsFrom(
     TPressStructureClass(FAttributeClass).ValidObjectClass) then
      raise EPressError.CreateFmt(SInvalidClassInheritance, [Value.ClassName,
       TPressStructureClass(FAttributeClass).ValidObjectClass.ClassName]);
    if Assigned(Owner) and Assigned(FObjectClassMetadata) and
     (FObjectClassMetadata.OwnerMetadata = Owner) then
      FObjectClassMetadata.FOwnerPartsMetadata := nil;  // friend class
    FObjectClass := Value;
    if Assigned(FObjectClass) then
    begin
      FObjectClassMetadata := FObjectClass.ClassMetadata;
      if Assigned(Owner) and (FObjectClassMetadata.OwnerMetadata = Owner) then
        FObjectClassMetadata.FOwnerPartsMetadata := Self;  // friend class
    end else
      FObjectClassMetadata := nil;
  end;
end;

procedure TPressAttributeMetadata.SetObjectClassName(const Value: string);
begin
  if ObjectClassName <> Value then
    ObjectClass := Model.ClassByName(Value);
end;

function TPressAttributeMetadata.StorePersistentName: Boolean;
begin
  Result := IsPersistent and not SameText(FPersistentName, FName);
end;

function TPressAttributeMetadata.StorePersLinkChildName: Boolean;
begin
  Result := (FPersLinkChildName <> '') and
   not SameText(FPersLinkChildName, BuildPersLinkChildName);
end;

function TPressAttributeMetadata.StorePersLinkIdName: Boolean;
begin
  Result := not SameText(FPersLinkIdName, SPressIdString);
end;

function TPressAttributeMetadata.StorePersLinkName: Boolean;
begin
  Result := (FPersLinkName <> '') and
   not SameText(FPersLinkName, BuildPersLinkName);
end;

function TPressAttributeMetadata.StorePersLinkParentName: Boolean;
begin
  Result := (FPersLinkParentName <> '') and
   not SameText(FPersLinkParentName, BuildPersLinkParentName);
end;

function TPressAttributeMetadata.StorePersLinkPosName: Boolean;
begin
  Result := not SameText(FPersLinkIdName, SPressItemPosString);
end;

function TPressAttributeMetadata.StoreShortName: Boolean;
begin
  Result := (FShortName <> '') and not SameText(FShortName, FName);
end;

{ TPressAttributeMetadataList }

function TPressAttributeMetadataList.Add(
  AObject: TPressAttributeMetadata): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressAttributeMetadataList.CreateIterator: TPressAttributeMetadataIterator;
begin
  Result := TPressAttributeMetadataIterator.Create(Self);
end;

function TPressAttributeMetadataList.GetItems(
  AIndex: Integer): TPressAttributeMetadata;
begin
  Result := inherited Items[AIndex] as TPressAttributeMetadata;
end;

function TPressAttributeMetadataList.IndexOf(
  AObject: TPressAttributeMetadata): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

function TPressAttributeMetadataList.IndexOfName(const AName: string): Integer;
begin
  for Result := 0 to Pred(Count) do
    if SameText(Items[Result].Name, AName) then
      Exit;
  Result := -1;
end;

procedure TPressAttributeMetadataList.Insert(Index: Integer;
  AObject: TPressAttributeMetadata);
begin
  inherited Insert(Index, AObject);
end;

function TPressAttributeMetadataList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressAttributeMetadataList.Remove(
  AObject: TPressAttributeMetadata): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressAttributeMetadataList.SetItems(
  AIndex: Integer; Value: TPressAttributeMetadata);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressAttributeMetadataIterator }

function TPressAttributeMetadataIterator.GetCurrentItem: TPressAttributeMetadata;
begin
  Result := inherited CurrentItem as TPressAttributeMetadata;
end;

{ TPressClassMap }

constructor TPressClassMap.Create(AObjectMetadata: TPressObjectMetadata);
begin
  inherited Create(False);
  FObjectMetadata := AObjectMetadata;
  ReadMetadatas(AObjectMetadata);
end;

function TPressClassMap.FindMetadata(const APath: string): TPressAttributeMetadata;
var
  VMetadata: TPressAttributeMetadata;
  VPos: Integer;
  VIndex: Integer;
begin
  VPos := Pos(SPressAttributeSeparator, APath);
  if VPos = 0 then
  begin
    VIndex := IndexOfName(APath);
    if VIndex >= 0 then
      Result := Items[VIndex]
    else if SameText(APath, SPressIdString) then
      Result := ObjectMetadata.IdMetadata
    else
      Result := nil;
  end else
  begin
    VIndex := IndexOfName(Copy(APath, 1, VPos - 1));
    if VIndex >= 0 then
    begin
      VMetadata := Items[VIndex];
      if VMetadata.AttributeClass.InheritsFrom(TPressStructure) then
        Result := VMetadata.ObjectClass.ClassMap.
         FindMetadata(Copy(APath, VPos + 1, Length(APath) - VPos))
      else
        Result := nil;
    end else
      Result := nil;
  end;
end;

function TPressClassMap.MetadataByPath(
  const APath: string): TPressAttributeMetadata;
begin
  Result := FindMetadata(APath);
  if not Assigned(Result) then
    raise EPressError.CreateFmt(
     SAttributeNotFound, [FObjectMetadata.ObjectClassName, APath]);
end;

procedure TPressClassMap.ReadMetadatas(AObjectMetadata: TPressObjectMetadata);
var
  VCurrentMetadata: TPressAttributeMetadata;
  VIndex: Integer;
begin
  if not Assigned(AObjectMetadata) then
    Exit;
  ReadMetadatas(AObjectMetadata.Parent);
  with AObjectMetadata.AttributeMetadatas.CreateIterator do
  try
    BeforeFirstItem;
    while NextItem do
    begin
      VCurrentMetadata := CurrentItem;
      VIndex := IndexOfName(VCurrentMetadata.Name);
      if VIndex = -1 then
        Add(VCurrentMetadata)
      else
        { TODO : Merge with the inherited metadata }
        Items[VIndex] := VCurrentMetadata;
    end;
  finally
    Free;
  end;
end;

{ TPressQueryAttributeMetadata }

constructor TPressQueryAttributeMetadata.Create(
  AOwner: TPressObjectMetadata);
begin
  inherited Create(AOwner);
  FMatchType := mtNone;
  FIncludeIfEmpty := False;
end;

procedure TPressQueryAttributeMetadata.SetName(const Value: string);
begin
  inherited;
  if FDataName = '' then
    FDataName := Value;
end;

{ TPressObjectMetadata }

constructor TPressObjectMetadata.Create(
  const AObjectClassName: string; AModel: TPressModel);
begin
  inherited Create;
  FObjectClassName := AObjectClassName;
  FClassIdName := SPressClassIdString;
  FUpdateCountName := SPressUpdateCountString;
  FModel := AModel;
  FParent := FModel.ParentMetadataOf(Self);
  if Assigned(FParent) then
    IsPersistent := FParent.IsPersistent;
  FKeyName := SPressIdString;
  FKeyType := FModel.DefaultKeyType.AttributeName;
  FModel.Metadatas.Add(Self);
end;

function TPressObjectMetadata.CreateAttributeMetadata: TPressAttributeMetadata;
begin
  Result := InternalAttributeMetadataClass.Create(Self);
end;

procedure TPressObjectMetadata.Finit;
begin
  FMap.Free;
  FAttributeMetadatas.Free;
  FIdMetadata.Free;
  inherited;
end;

function TPressObjectMetadata.GetAttributeMetadatas: TPressAttributeMetadataList;
begin
  if not Assigned(FAttributeMetadatas) then
    FAttributeMetadatas := TPressAttributeMetadataList.Create(True);
  Result := FAttributeMetadatas;
end;

function TPressObjectMetadata.GetIdMetadata: TPressAttributeMetadata;
begin
  if not Assigned(FIdMetadata) then
  begin
    { TODO : Inherited synchronization }
    FIdMetadata := InternalAttributeMetadataClass.Create(nil);
    FIdMetadata.Name := KeyName;
    FIdMetadata.AttributeName := KeyType;
    FIdMetadata.Size := 32;
  end;
  Result := FIdMetadata;
end;

function TPressObjectMetadata.GetMap: TPressClassMap;
begin
  if not Assigned(FMap) then
    FMap := TPressClassMap.Create(Self);
  Result := FMap;
end;

function TPressObjectMetadata.GetObjectClass: TPressObjectClass;
begin
  if not Assigned(FObjectClass) then
    FObjectClass := Model.ClassByName(FObjectClassName);
  Result := FObjectClass;
end;

function TPressObjectMetadata.GetOwnerClass: string;
begin
  if Assigned(FOwnerMetadata) then
    Result := FOwnerMetadata.ObjectClassName
  else
    Result := '';
end;

function TPressObjectMetadata.GetShortName: string;
begin
  if FShortName = '' then
    FShortName := FPersistentName;
  Result := FShortName;
end;

function TPressObjectMetadata.InternalAttributeMetadataClass: TPressAttributeMetadataClass;
begin
  Result := TPressAttributeMetadata;
end;

procedure TPressObjectMetadata.SetIsPersistent(AValue: Boolean);
begin
  if Assigned(Parent) and not Parent.IsPersistent then
    FIsPersistent := AValue
  else
    FIsPersistent := True;
  if not IsPersistent then
    FPersistentName := ''
  else if FPersistentName = '' then
    FPersistentName := FObjectClassName;
end;

procedure TPressObjectMetadata.SetOwnerClass(const Value: string);
begin
  FOwnerMetadata := Model.MetadataByName(Value);
end;

procedure TPressObjectMetadata.SetPersistentName(const Value: string);
begin
  FPersistentName := Value;
  if FPersistentName <> '' then
    IsPersistent := True;
end;

function TPressObjectMetadata.StoreClassIdName: Boolean;
begin
  Result := not SameText(FClassIdName, SPressClassIdString);
end;

function TPressObjectMetadata.StoreKeyName: Boolean;
begin
  Result := not SameText(FKeyName, SPressIdString);
end;

function TPressObjectMetadata.StoreKeyType: Boolean;
begin
  Result := not SameText(FKeyType, FModel.DefaultKeyType.AttributeName);
end;

function TPressObjectMetadata.StorePersistentName: Boolean;
begin
  Result := IsPersistent and not SameText(FPersistentName, FObjectClassName);
end;

function TPressObjectMetadata.StoreShortName: Boolean;
begin
  Result := (FShortName <> '') and not SameText(FShortName, FObjectClassName);
end;

function TPressObjectMetadata.StoreUpdateCountName: Boolean;
begin
  Result := not SameText(FUpdateCountName, SPressUpdateCountString);
end;

{ TPressObjectMetadataList }

function TPressObjectMetadataList.Add(
  AObject: TPressObjectMetadata): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressObjectMetadataList.CreateIterator: TPressObjectMetadataIterator;
begin
  Result := TPressObjectMetadataIterator.Create(Self);
end;

function TPressObjectMetadataList.GetItems(
  AIndex: Integer): TPressObjectMetadata;
begin
  Result := inherited Items[AIndex] as TPressObjectMetadata;
end;

function TPressObjectMetadataList.IndexOf(
  AObject: TPressObjectMetadata): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressObjectMetadataList.Insert(Index: Integer;
  AObject: TPressObjectMetadata);
begin
  inherited Insert(Index, AObject);
end;

function TPressObjectMetadataList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressObjectMetadataList.Remove(
  AObject: TPressObjectMetadata): Integer;
var
  I: Integer;
begin
  if Assigned(AObject) then
  begin
    for I := Pred(Count) downto 0 do
      if Items[I].Parent = AObject then
        Remove(Items[I]);
    Result := inherited Remove(AObject);
  end else
    Result := -1;
end;

procedure TPressObjectMetadataList.SetItems(
  AIndex: Integer; Value: TPressObjectMetadata);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressObjectMetadataIterator }

function TPressObjectMetadataIterator.GetCurrentItem: TPressObjectMetadata;
begin
  Result := inherited CurrentItem as TPressObjectMetadata;
end;

{ TPressQueryMetadata }

constructor TPressQueryMetadata.Create(
  const AObjectClassName: string; AModel: TPressModel);
begin
  inherited Create(AObjectClassName, AModel);
  FStyle := qsOQL;
end;

function TPressQueryMetadata.GetItemObjectClass: TPressObjectClass;
begin
  if not Assigned(FItemObjectClass) then
    raise EPressError.CreateFmt(SUnassignedItemObjectClass, [ClassName]);
  Result := FItemObjectClass;
end;

function TPressQueryMetadata.GetItemObjectClassName: string;
begin
  Result := ItemObjectClass.ClassName;
end;

function TPressQueryMetadata.InternalAttributeMetadataClass: TPressAttributeMetadataClass;
begin
  Result := TPressQueryAttributeMetadata;
end;

procedure TPressQueryMetadata.SetItemObjectClass(Value: TPressObjectClass);
var
  VAttributeMetadata: TPressAttributeMetadata;
  I: Integer;
begin
  if FItemObjectClass <> Value then
  begin
    I := AttributeMetadatas.IndexOfName(SPressQueryItemsString);
    if I = -1 then
    begin
      VAttributeMetadata := InternalAttributeMetadataClass.Create(Self);
      VAttributeMetadata.Name := SPressQueryItemsString;
      VAttributeMetadata.AttributeName := TPressQueryItems.AttributeName;
    end else
      VAttributeMetadata := AttributeMetadatas[I];
    VAttributeMetadata.ObjectClass := Value;
    FItemObjectClass := Value;
  end;
end;

procedure TPressQueryMetadata.SetItemObjectClassName(const Value: string);
begin
  if not Assigned(FItemObjectClass) or
   (FItemObjectClass.ClassName <> Value) then
    ItemObjectClass := Model.ClassByName(Value);
end;

{ TPressSavedPoint }

constructor TPressSavedPoint.Create(
  ASavePoint: TPressSavePoint; AIsChanged: Boolean);
begin
  inherited Create;
  FSavePoint := ASavePoint;
  FIsChanged := AIsChanged;
end;

{ TPressSavedPointList }

function TPressSavedPointList.GetItems(AIndex: Integer): TPressSavedPoint;
begin
  Result := inherited Items[AIndex] as TPressSavedPoint;
end;

function TPressSavedPointList.IndexOfNearestSavePoint(
  ASavePoint: TPressSavePoint): Integer;
begin
  for Result := Pred(Count) downto 0 do
    if Items[Result].SavePoint <= ASavePoint then
      Exit;
  Result := -1;
end;

function TPressSavedPointList.IsChanged(ASavePoint: TPressSavePoint): Boolean;
var
  VIndex: Integer;
begin
  VIndex := IndexOfNearestSavePoint(ASavePoint);
  Result := (VIndex >= 0) and Items[VIndex].IsChanged;
end;

function TPressSavedPointList.Last: TPressSavedPoint;
begin
  Result := inherited Last as TPressSavedPoint;
end;

function TPressSavedPointList.LastSavePoint: TPressSavePoint;
begin
  if Count > 0 then
    Result := Last.SavePoint
  else
    Result := 0;
end;

procedure TPressSavedPointList.RegisterSavePoint(
  ASavePoint: TPressSavePoint; AIsChanged: Boolean);
begin
  Add(TPressSavedPoint.Create(ASavePoint, AIsChanged));
end;

procedure TPressSavedPointList.SetItems(
  AIndex: Integer; AValue: TPressSavedPoint);
begin
  inherited Items[AIndex] := AValue;
end;

procedure TPressSavedPointList.Shrink(ASavePoint: TPressSavePoint);
begin
  Count := IndexOfNearestSavePoint(ASavePoint - 1) + 1;
end;

{ TPressObjectMemento }

function TPressObjectMemento.ChangedSince(ASavePoint: TPressSavePoint): Boolean;
begin
  Result := Assigned(FAttributes) and (FAttributes.Count > ASavePoint);
end;

constructor TPressObjectMemento.Create(AOwner: TPressObject);
begin
  inherited Create;
  {$IFDEF PressLogSubjectMemento}PressLogMsg(Self, 'Creating ' + AOwner.Signature, []);{$ENDIF}
  FSavedPoints := TPressSavedPointList.Create(True);
  FOwner := AOwner;
end;

destructor TPressObjectMemento.Destroy;
begin
  {$IFDEF PressLogSubjectMemento}PressLogMsg(Self, 'Destroying ' + Owner.Signature, []);{$ENDIF}
  FSavedPoints.Free;
  FAttributes.Free;
  inherited;
end;

function TPressObjectMemento.GetAttributes: TPressAttributeMementoList;
begin
  if not Assigned(FAttributes) then
    FAttributes := TPressAttributeMementoList.Create(True);
  Result := FAttributes;
end;

function TPressObjectMemento.GetSubjectChanged: Boolean;
begin
  Result := Assigned(FAttributes) and (FAttributes.Count > 0);
end;

procedure TPressObjectMemento.Notify(AAttribute: TPressAttribute);
var
  VMemento: TPressAttributeMemento;
begin
{$IFDEF PressLogSubjectMemento}
  PressLogMsg(Self, Format('Notifying %s (%s)', [Owner.Signature, AAttribute.Signature]), []);
{$ENDIF}
  if Attributes.IndexOfOwner(AAttribute) < SavedPoints.LastSavePoint then
  begin
    VMemento := AAttribute.CreateMemento;  // friend class
    try
      VMemento.Modifying;
      Attributes.Add(VMemento);
    except
      VMemento.Free;
      raise;
    end;
  end;
end;

procedure TPressObjectMemento.Restore(ASavedPoint: TPressSavePoint);
var
  I: Integer;
begin
{$IFDEF PressLogSubjectMemento}
  PressLogMsg(Self, 'Restoring ' + Owner.Signature, []);
{$ENDIF}
  if Assigned(FAttributes) and (FAttributes.Count > ASavedPoint) then
  begin
    if ASavedPoint < 0 then
      ASavedPoint := 0;
    try
      Owner.DisableChanges;
      for I := Pred(FAttributes.Count) downto ASavedPoint do
        FAttributes[I].Restore;
    finally
      Owner.EnableChanges;
    end;
    if not SavedPoints.IsChanged(ASavedPoint) then
      Owner.Unchanged;
    FAttributes.Count := ASavedPoint;
    SavedPoints.Shrink(ASavedPoint);
  end;
end;

function TPressObjectMemento.SavePoint: TPressSavePoint;
begin
  if Assigned(FAttributes) then
    Result := FAttributes.Count
  else
    Result := 0;
  SavedPoints.RegisterSavePoint(Result, Owner.IsChanged);
end;

procedure TPressObjectMemento.Unchange;
begin
  if Assigned(FAttributes) then
    FAttributes.Clear;
end;

{ TPressAttributeMemento }

constructor TPressAttributeMemento.Create(AOwner: TPressAttribute);
begin
  inherited Create;
  FOwner := AOwner;
  FOwner.AddRef;
  Init;
end;

destructor TPressAttributeMemento.Destroy;
begin
  FOwner.Free;
  inherited;
end;

procedure TPressAttributeMemento.Init;
begin
end;

procedure TPressAttributeMemento.Modifying;
begin
  {$IFDEF PressLogSubjectMemento}PressLogMsg(Self, 'Modifying ' + Owner.Signature);{$ENDIF}
  FIsChanged := FOwner.IsChanged;
end;

procedure TPressAttributeMemento.RestoreChanged;
begin
  if not FIsChanged then
    Owner.Unchanged;
end;

{ TPressAttributeMementoList }

function TPressAttributeMementoList.Add(
  AObject: TPressAttributeMemento): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressAttributeMementoList.CreateIterator: TPressAttributeMementoIterator;
begin
  Result := TPressAttributeMementoIterator.Create(Self);
end;

function TPressAttributeMementoList.Extract(
  AObject: TPressAttributeMemento): TPressAttributeMemento;
begin
  Result := inherited Extract(AObject) as TPressAttributeMemento;
end;

function TPressAttributeMementoList.GetItems(
  AIndex: Integer): TPressAttributeMemento;
begin
  Result := inherited Items[AIndex] as TPressAttributeMemento;
end;

function TPressAttributeMementoList.IndexOf(
  AObject: TPressAttributeMemento): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

function TPressAttributeMementoList.IndexOfOwner(
  AOwner: TPressAttribute): Integer;
begin
  for Result := 0 to Pred(Count) do
    if Items[Result].FOwner = AOwner then
      Exit;
  Result := -1;
end;

procedure TPressAttributeMementoList.Insert(
  Index: Integer; AObject: TPressAttributeMemento);
begin
  inherited Insert(Index, AObject);
end;

function TPressAttributeMementoList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressAttributeMementoList.Remove(
  AObject: TPressAttributeMemento): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressAttributeMementoList.SetItems(
  AIndex: Integer; Value: TPressAttributeMemento);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressAttributeMementoIterator }

function TPressAttributeMementoIterator.GetCurrentItem: TPressAttributeMemento;
begin
  Result := inherited CurrentItem as TPressAttributeMemento;
end;

{ TPressModel }

procedure TPressModel.AddAttribute(AAttributeClass: TPressAttributeClass);
begin
  FAttributes.Add(AAttributeClass);
  TPressModelAttributeChangedEvent.Create(Self).Notify;
end;

procedure TPressModel.AddClass(AClass: TPressObjectClass);
begin
  FClasses.Add(AClass);
  FMetadatasFetched := False;
  TPressModelBusinessClassChangedEvent.Create(Self).Notify;
end;

function TPressModel.AttributeByName(
  const AAttributeName: string): TPressAttributeClass;
begin
  Result := FindAttribute(AAttributeName);
  if not Assigned(Result) then
    raise EPressError.CreateFmt(SAttributeTypeNotFound, [AAttributeName]);
end;

function TPressModel.ClassByName(
  const AClassName: string): TPressObjectClass;
begin
  Result := FindClass(AClassName);
  if not Assigned(Result) then
    raise EPressError.CreateFmt(SClassNotFound, [AClassName]);
end;

procedure TPressModel.ClearAllMetadatas;

  function FindRootMetadata: TPressObjectMetadata;
  var
    I: Integer;
  begin
    for I := 0 to Pred(Metadatas.Count) do
    begin
      Result := Metadatas[I];
      if Result.ObjectClassName = TPressObject.ClassName then
        Exit;
    end;
    Result := nil;
  end;

begin
  Metadatas.Remove(FindRootMetadata);
  FMetadatasFetched := False;
  TPressModelBusinessClassChangedEvent.Create(Self).Notify;
end;

constructor TPressModel.Create;
begin
  inherited Create;
  FAttributes := TClassList.Create;
  FClasses := TClassList.Create;
  FMetadatas := TPressObjectMetadataList.Create(True);
  FEnumMetadatas := TPressEnumMetadataList.Create(True);
  FDefaultKeyType := TPressString;
  {$IFNDEF PressRelease}
  FNotifier := TPressNotifier.Create({$IFDEF FPC}@{$ENDIF}Notify);
  FNotifier.AddNotificationItem(PressApp, [TPressApplicationRunningEvent]);
  {$ENDIF}
end;

function TPressModel.CreateMetadataIterator: TPressObjectMetadataIterator;
begin
  FetchAllMetadatas;
  Result := Metadatas.CreateIterator;
end;

destructor TPressModel.Destroy;
begin
  FAttributes.Free;
  FClasses.Free;
  FMetadatas.Free;
  FEnumMetadatas.Free;
  {$IFNDEF PressRelease}
  FNotifier.Free;
  {$ENDIF}
  inherited;
end;

function TPressModel.EnumMetadataByName(
  const AEnumName: string): TPressEnumMetadata;
begin
  Result := FindEnumMetadata(AEnumName);
  if not Assigned(Result) then
    raise EPressError.CreateFmt(SEnumMetadataNotFound, [AEnumName]);
end;

procedure TPressModel.FetchAllMetadatas;
var
  I: Integer;
begin
  if not FMetadatasFetched then
  begin
    FMetadatasFetched := True;
    try
      for I := 0 to Pred(FClasses.Count) do
        TPressObjectClass(FClasses[I]).ClassMap;
    except
      FMetadatasFetched := False;
      raise;
    end;
  end;
end;

function TPressModel.FindAttribute(
  const AAttributeName: string): TPressAttributeClass;
begin
  Result := InternalFindAttribute(AAttributeName);
end;

function TPressModel.FindAttributeClass(
  const AAttributeName: string): TPressAttributeClass;
var
  I: Integer;
begin
  for I := 0 to Pred(FAttributes.Count) do
  begin
    Result := TPressAttributeClass(FAttributes[I]);
    if SameText(Result.ClassName, AAttributeName) then
      Exit;
  end;
  Result := nil;
end;

function TPressModel.FindClass(
  const AClassName: string): TPressObjectClass;
begin
  Result := InternalFindClass(AClassName);
end;

function TPressModel.FindEnumMetadata(
  const AEnumName: string): TPressEnumMetadata;
var
  I: Integer;
begin
  for I := 0 to Pred(FEnumMetadatas.Count) do
  begin
    Result := FEnumMetadatas[I];
    if SameText(Result.Name, AEnumName) then
      Exit;
  end;
  Result := nil;
end;

function TPressModel.FindMetadata(
  const AClassName: string): TPressObjectMetadata;
var
  I: Integer;
begin
  FetchAllMetadatas;
  for I := 0 to Pred(Metadatas.Count) do
  begin
    Result := Metadatas[I];
    if SameText(Result.ObjectClassName, AClassName) then
      Exit;
  end;
  Result := nil;
end;

function TPressModel.GetClassIdType: TPressAttributeClass;
begin
  if ClassIdStorageName = '' then
    Result := TPressString
  else if not Assigned(FClassIdType) then
    Result := DefaultKeyType
  else
    Result := FClassIdType;
end;

function TPressModel.InternalFindAttribute(
  const AAttributeName: string): TPressAttributeClass;
var
  I: Integer;
begin
  for I := 0 to Pred(FAttributes.Count) do
  begin
    Result := TPressAttributeClass(FAttributes[I]);
    if SameText(Result.AttributeName, AAttributeName) then
      Exit;
  end;
  Result := nil;
end;

function TPressModel.InternalFindClass(
  const AClassName: string): TPressObjectClass;
var
  I: Integer;
begin
  for I := 0 to Pred(FClasses.Count) do
  begin
    Result := TPressObjectClass(FClasses[I]);
    if SameText(Result.ClassName, AClassName) then
      Exit;
  end;
  Result := nil;
end;

function TPressModel.InternalParentMetadataOf(
  AMetadata: TPressObjectMetadata): TPressObjectMetadata;
var
  VObjectClass: TPressObjectClass;
begin
  VObjectClass := AMetadata.ObjectClass;
  if VObjectClass <> TPressObject then
    Result := TPressObjectClass(VObjectClass.ClassParent).ClassMetadata
  else
    Result := nil;
end;

function TPressModel.MetadataByName(
  const AClassName: string): TPressObjectMetadata;
begin
  Result := FindMetadata(AClassName);
  if not Assigned(Result) then
    raise EPressError.CreateFmt(SMetadataNotFound, [AClassName]);
end;

{$IFNDEF PressRelease}
procedure TPressModel.Notify(AEvent: TPressEvent);
begin
  FetchAllMetadatas;
end;
{$ENDIF}

function TPressModel.ParentMetadataOf(
  AMetadata: TPressObjectMetadata): TPressObjectMetadata;
begin
  Result := InternalParentMetadataOf(AMetadata);
end;

function TPressModel.RegisterEnumMetadata(AEnumAddress: Pointer;
  const AEnumName: string): TPressEnumMetadata;
begin
  Result := TPressEnumMetadata.Create(AEnumAddress);
  Result.Name := AEnumName;
  FEnumMetadatas.Add(Result);
end;

function TPressModel.RegisterEnumMetadata(AEnumAddress: Pointer;
  const AEnumName: string;
  AEnumValues: array of string): TPressEnumMetadata;
begin
  Result := TPressEnumMetadata.Create(AEnumAddress, AEnumValues);
  Result.Name := AEnumName;
  FEnumMetadatas.Add(Result);
end;

function TPressModel.RegisterMetadata(
  const AMetadataStr: string): TPressObjectMetadata;
begin
  Result := TPressMetaParser.ParseMetadata(AMetadataStr, Self);
end;

procedure TPressModel.RemoveAttribute(
  AAttributeClass: TPressAttributeClass);
begin
  FAttributes.Remove(AAttributeClass);
  TPressModelAttributeChangedEvent.Create(Self).Notify;
end;

procedure TPressModel.RemoveClass(AClass: TPressObjectClass);
var
  VIndex: Integer;
  I: Integer;
begin
  if AClass = TPressObject then
    Exit;
  VIndex := FClasses.IndexOf(AClass);
  if VIndex >= 0 then
  begin
    for I := Pred(FClasses.Count) downto 0 do
      if FClasses[I].ClassParent = AClass then
        RemoveClass(TPressObjectClass(FClasses[I]));
    for I := 0 to Pred(Metadatas.Count) do
      if Metadatas[I].ObjectClassName = AClass.ClassName then
      begin
        Metadatas.Delete(I);
        Break;
      end;
    FClasses.Delete(VIndex);
    TPressModelBusinessClassChangedEvent.Create(Self).Notify;
  end;
end;

procedure TPressModel.SetClassIdStorageName(const Value: string);
begin
  FClassIdStorageName := Value;
  ClearAllMetadatas;
end;

procedure TPressModel.SetClassIdType(Value: TPressAttributeClass);
begin
  if not Assigned(Value) then
    raise EPressError.CreateFmt(SUnsupportedAttributeType, [SPressNilString]);
  FClassIdType := Value;
  ClearAllMetadatas;
end;

procedure TPressModel.SetDefaultKeyType(Value: TPressAttributeClass);
begin
  if not Assigned(Value) then
    raise EPressError.CreateFmt(SUnsupportedAttributeType, [SPressNilString]);
  FDefaultKeyType := Value;
  ClearAllMetadatas;
end;

procedure TPressModel.UnregisterMetadata(AMetadata: TPressObjectMetadata);
begin
  Metadatas.Remove(AMetadata);
end;

{ TPressParam }

constructor TPressParam.Create(
  const AName: string; AParamType: TPressAttributeBaseType);
begin
  inherited Create;
  FName := AName;
  FParamType := AParamType;
end;

{ TPressParamList }

function TPressParamList.Add(AObject: TPressParam): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressParamList.CreateIterator: TPressParamIterator;
begin
  Result := TPressParamIterator.Create(Self);
end;

function TPressParamList.GetItems(AIndex: Integer): TPressParam;
begin
  Result := inherited Items[AIndex] as TPressParam;
end;

procedure TPressParamList.Insert(AIndex: Integer; AObject: TPressParam);
begin
  inherited Insert(AIndex, AObject);
end;

function TPressParamList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

procedure TPressParamList.SetItems(AIndex: Integer; AValue: TPressParam);
begin
  inherited Items[AIndex] := AValue;
end;

{ TPressSubjectEvent }

{$IFNDEF PressLogSubjectEvents}
function TPressSubjectEvent.AllowLog: Boolean;
begin
  Result := False;
end;
{$ENDIF}

{ TPressSubject }

procedure TPressSubject.BeginUpdate;
begin
  Inc(FUpdatingCount);
  if FUpdatingCount = 1 then
  begin
    FUpdating := True;
    InternalUpdateStarted;
  end;
end;

procedure TPressSubject.Changed(AUpdateIsChangedFlag: Boolean);
begin
  if not ChangesDisabled then
  begin
    if not Updating then
    begin
      if AUpdateIsChangedFlag then
        FIsChanged := True;
      InternalChanged(False);
    end else
      FChangedWhenUpdating := True;
  end else
    FChangedWhenDisabled := True;
end;

procedure TPressSubject.Changing;
begin
  if not ChangesDisabled then
    InternalChanging;
end;

procedure TPressSubject.DisableChanges;
begin
  Inc(FChangesDisabledCount);
  if FChangesDisabledCount = 1 then
  begin
    FChangesDisabled := True;
    InternalChangesDisabled;
  end;
end;

procedure TPressSubject.EnableChanges;
begin
  if not ChangesDisabled then
    Exit;
  Dec(FChangesDisabledCount);
  FChangesDisabled := FChangesDisabledCount > 0;
  if not ChangesDisabled then
  begin
    if FChangedWhenDisabled then
    begin
      FChangedWhenDisabled := False;
      InternalChanged(True);
    end;
    InternalChangesEnabled;
  end;
end;

procedure TPressSubject.EndUpdate;
begin
  if not Updating then
    Exit;
  Dec(FUpdatingCount);
  FUpdating := FUpdatingCount > 0;
  if not Updating then
  begin
    if FChangedWhenUpdating then
    begin
      FChangedWhenUpdating := False;
      Changed;
    end;
    InternalUpdateFinished;
  end;
end;

function TPressSubject.GetSignature: string;
begin
  Result := ClassName;
end;

procedure TPressSubject.InternalChanged(AChangedWhenDisabled: Boolean);
begin
end;

procedure TPressSubject.InternalChangesDisabled;
begin
end;

procedure TPressSubject.InternalChangesEnabled;
begin
end;

procedure TPressSubject.InternalChanging;
begin
end;

procedure TPressSubject.InternalUnchanged;
begin
end;

procedure TPressSubject.InternalUpdateFinished;
begin
end;

procedure TPressSubject.InternalUpdateStarted;
begin
end;

procedure TPressSubject.Unchanged;
begin
  FIsChanged := False;
  InternalUnchanged;
end;

{ TPressObject }

procedure TPressObject.AfterCreate;
begin
end;

procedure TPressObject.AfterCreateAttributes;
begin
end;

procedure TPressObject.AfterDispose;
begin
end;

procedure TPressObject.AfterRetrieve;
begin
end;

procedure TPressObject.AfterStore;
begin
end;

procedure TPressObject.Assign(Source: TPersistent);
begin
  if Source is ClassType then
  begin
    with TPressObject(Source).CreateAttributeIterator do
    try
      FirstItem;  // skip Id attribute
      while NextItem do
        FAttributes[CurrentPosition].Assign(CurrentItem);
    finally
      Free;
    end;
  end else
    inherited;
end;

function TPressObject.AttributeByName(const AAttributeName: string): TPressAttribute;
begin
  Result := FindAttribute(AAttributeName);
  if not Assigned(Result) then
    raise EPressError.CreateFmt(SAttributeNotFound, [ClassName, AAttributeName]);
end;

function TPressObject.AttributeByPath(const APath: string): TPressAttribute;
begin
  Result := FindPathAttribute(APath, False);
  if not Assigned(Result) then
    raise EPressError.CreateFmt(SPathReferencesNil, [ClassName, APath]);
end;

function TPressObject.AttributeCount: Integer;
begin
  Result := FAttributes.Count;
end;

procedure TPressObject.AttributesDisableChanges;
var
  I: Integer;
begin
  if Assigned(FAttributes) then
    for I := 0 to Pred(FAttributes.Count) do
      FAttributes[I].DisableChanges;
end;

procedure TPressObject.AttributesEnableChanges;
var
  VAttributesChanged: Boolean;
  VAttribute: TPressAttribute;
  I: Integer;
begin
  VAttributesChanged := False;
  if Assigned(FAttributes) then
    for I := 0 to Pred(FAttributes.Count) do
    begin
      VAttribute := FAttributes[I];
      VAttributesChanged := VAttributesChanged or
       VAttribute.FChangedWhenDisabled;  // friend class
      VAttribute.EnableChanges;
    end;
  if VAttributesChanged then
    NotifyChange;
end;

procedure TPressObject.BeforeCreateAttributes;
begin
end;

procedure TPressObject.BeforeDispose;
begin
end;

procedure TPressObject.BeforeStore;
begin
end;

class function TPressObject.ClassMap: TPressClassMap;
begin
  Result := ClassMetadata.Map;
end;

class function TPressObject.ClassMetadata: TPressObjectMetadata;
begin
  Result := PressModel.FindMetadata(ClassName);
  if not Assigned(Result) then
    Result := PressModel.RegisterMetadata(ClassMetadataStr);
end;

class function TPressObject.ClassMetadataStr: string;
var
  VMetadataMethod, VParentMetadataMethod: function: string of object;
  VObjectClass: TPressObjectClass;
begin
  Result := '';
  if Self <> TPressObject then
  begin
    VMetadataMethod := {$IFDEF FPC}@{$ENDIF}InternalMetadataStr;
    VObjectClass := TPressObjectClass(ClassParent);
    VParentMetadataMethod :=
     {$IFDEF FPC}@{$ENDIF}VObjectClass.InternalMetadataStr;
    if TMethod(VMetadataMethod).Code <> TMethod(VParentMetadataMethod).Code then
      Result := VMetadataMethod();
  end;
  if Result = '' then
    Result := ClassName;
end;

{$IFDEF FPC}class{$ENDIF} function TPressObject.ClassType: TPressObjectClass;
begin
  Result := TPressObjectClass(inherited ClassType);
end;

procedure TPressObject.ClearOwnerContext;
begin
  FOwnerAttribute := nil;
end;

function TPressObject.Clone: TPressObject;
begin
  Result := ClassType.Create(FDataAccess, FMetadata);
  Result.Assign(Self);
end;

constructor TPressObject.Create(
  ADataAccess: IPressDAO; AMetadata: TPressObjectMetadata);
begin
  inherited Create;
  InitInstance(ADataAccess, AMetadata);
  AfterCreate;
end;

function TPressObject.CreateAttributeIterator: TPressAttributeIterator;
begin
  Result := FAttributes.CreateIterator;
end;

procedure TPressObject.CreateAttributes;
var
  VAttributePtr: PPressAttribute;
  VAttribute: TPressAttribute;
  VMetadata: TPressAttributeMetadata;
begin
  BeforeCreateAttributes;
  FId := Metadata.IdMetadata.CreateAttribute(Self);
  FAttributes.Add(FId);
  with Map.CreateIterator do
  try
    BeforeFirstItem;
    while NextItem do
    begin
      VMetadata := CurrentItem;
      VAttribute := VMetadata.CreateAttribute(Self);
      FAttributes.Add(VAttribute);
      VAttributePtr := InternalAttributeAddress(VMetadata.Name);
      if Assigned(VAttributePtr) then
        VAttributePtr^ := VAttribute;
    end;
  finally
    Free;
  end;
  with CreateAttributeIterator do
  try
    BeforeFirstItem;
    while NextItem do
      CurrentItem.BindCalcNotification(Self);  // friend class
  finally
    Free;
  end;
  AfterCreateAttributes;
end;

procedure TPressObject.Dispose;
begin
  if IsPersistent then
    DataAccess.Dispose(ClassType, PersistentId);
end;

function TPressObject.FindAttribute(const AAttributeName: string): TPressAttribute;
begin
  Result := FAttributes.FindAttribute(AAttributeName);
end;

function TPressObject.FindPathAttribute(
  const APath: string; ASilent: Boolean): TPressAttribute;

  function AttributeSearch(const AAttributeName: string): TPressAttribute;
  begin
    if ASilent then
      Result := FindAttribute(AAttributeName)
    else
      Result := AttributeByName(AAttributeName);
  end;

var
  P: Integer;
  VItemPart: string;
begin
  P := Pos(SPressAttributeSeparator, APath);
  if P = 0 then
    Result := AttributeSearch(APath)
  else
  begin
    VItemPart := Copy(APath, 1, P-1);
    Result := AttributeSearch(VItemPart);
    if Result is TPressItem then
      if Assigned(TPressItem(Result).Value) then
        Result := TPressItem(Result).Value.
         FindPathAttribute(Copy(APath, P+1, Length(APath)-P), ASilent)
      else
        Result := nil
    else
      if ASilent then
        Result := nil
      else
        raise EPressError.CreateFmt(SAttributeIsNotItem,
         [ClassName, VItemPart]);
  end;
end;

procedure TPressObject.Finit;
begin
  DisableChanges;
  if Assigned(FDataAccess) then
    FDataAccess.ReleaseObject(Self);
  FMemento.Free;
  FAttributes.Free;
  inherited;
end;

function TPressObject.GetAttributes(AIndex: Integer): TPressAttribute;
begin
  Result := FAttributes[AIndex];
end;

function TPressObject.GetDataAccess: IPressDAO;
begin
  if not Assigned(FDataAccess) then
  begin
    FDataAccess := PressDefaultDAO;
    FDataAccess.AssignObject(Self);
  end;
  Result := FDataAccess;
end;

function TPressObject.GetId: string;
begin
  Result := FId.AsString;
end;

function TPressObject.GetIsOwned: Boolean;
begin
  Result := Assigned(FOwnerAttribute);
end;

function TPressObject.GetIsPersistent: Boolean;
begin
  Result := FPersistentId <> '';
end;

function TPressObject.GetIsUpdated: Boolean;
var
  VAttribute: TPressAttribute;
  I: Integer;
begin
  if IsPersistent then
  begin
    Result := not IsChanged;
    if not Result then
      for I := 0 to Pred(AttributeCount) do
      begin
        VAttribute := Attributes[I];
        if Assigned(VAttribute.Metadata) and
         VAttribute.Metadata.IsPersistent and VAttribute.IsChanged then
          Exit;
      end;
    Result := True;
  end else
    Result := False;
end;

function TPressObject.GetIsValid: Boolean;
begin
  Result := InternalIsValid;
end;

function TPressObject.GetMap: TPressClassMap;
begin
  if not Assigned(FMap) then
    FMap := Metadata.Map;
  Result := FMap;
end;

function TPressObject.GetMemento: TPressObjectMemento;
begin
  if not Assigned(FMemento) then
    FMemento := TPressObjectMemento.Create(Self);
  Result := FMemento;
end;

function TPressObject.GetMetadata: TPressObjectMetadata;
begin
  if not Assigned(FMetadata) then
    FMetadata := ClassMetadata;
  Result := FMetadata;
end;

function TPressObject.GetObjectOwner: TPressObject;
begin
  if Assigned(FOwnerAttribute) then
    Result := FOwnerAttribute.Owner
  else
    Result := nil;
end;

function TPressObject.GetOwner: TPersistent;
begin
  Result := Owner;
end;

function TPressObject.GetPersistentName: string;
begin
  Result := Metadata.PersistentName;
end;

procedure TPressObject.Init;
begin
end;

procedure TPressObject.InitInstance(
  ADataAccess: IPressDAO; AMetadata: TPressObjectMetadata);
begin
  FDataAccess := ADataAccess;
  FMetadata := AMetadata;
  FAttributes := TPressAttributeList.Create(True);
  DisableChanges;
  try
    CreateAttributes;
    if Assigned(FDataAccess) then
      FDataAccess.AssignObject(Self);
    Init;
  finally
    EnableChanges;
  end;
end;

function TPressObject.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  Result := FieldAddress(SPressAttributePrefix + AAttributeName);
end;

procedure TPressObject.InternalCalcAttribute(AAttribute: TPressAttribute);
begin
end;

procedure TPressObject.InternalChanged(AChangedWhenDisabled: Boolean);
begin
  inherited;
  NotifyChange;
  if Assigned(FOwnerAttribute) then
    FOwnerAttribute.ChangedItem(Self, not AChangedWhenDisabled);  // friend class
end;

procedure TPressObject.InternalChangesDisabled;
begin
  inherited;
  AttributesDisableChanges;
end;

procedure TPressObject.InternalChangesEnabled;
begin
  inherited;
  AttributesEnableChanges;
end;

procedure TPressObject.InternalChanging;
begin
  inherited;
  if Assigned(FOwnerAttribute) then
    FOwnerAttribute.BeforeChangeItem(Self);  // friend class
end;

procedure TPressObject.InternalDispose(ADisposeMethod: TPressObjectOperation);
begin
  ADisposeMethod(Self);
end;

function TPressObject.InternalIsValid: Boolean;
begin
  Result := True;
end;

procedure TPressObject.InternalLock;
begin
  inherited;
  { TODO : Implement lock attributes }
  TPressLockObjectEvent.Create(Self).Notify;
end;

class function TPressObject.InternalMetadataStr: string;
begin
  Result := '';
end;

procedure TPressObject.InternalRefresh(ARefreshMethod: TPressObjectOperation);
begin
  ARefreshMethod(Self);
end;

procedure TPressObject.InternalStore(AStoreMethod: TPressObjectOperation);
begin
  AStoreMethod(Self);
end;

procedure TPressObject.InternalUnchanged;
begin
  inherited;
  UnchangeAttributes;
  NotifyUnchange;
end;

procedure TPressObject.InternalUnlock;
begin
  inherited;
  { TODO : Implement lock attributes }
  TPressUnlockObjectEvent.Create(Self).Notify;
end;

procedure TPressObject.NotifyChange;
begin
  {$IFDEF PressLogSubjectChanges}PressLogMsg(Self, Format('Object %s changed', [Signature]));{$ENDIF}
  TPressObjectChangedEvent.Create(Self).Notify;
end;

procedure TPressObject.NotifyMemento(AAttribute: TPressAttribute);
begin
  if Assigned(FMemento) then
    FMemento.Notify(AAttribute);
end;

procedure TPressObject.NotifyUnchange;
begin
  {$IFDEF PressLogSubjectChanges}PressLogMsg(Self, Format('Object %s unchanged', [Signature]));{$ENDIF}
  TPressObjectUnchangedEvent.Create(Self).Notify;
end;

class function TPressObject.ObjectMetadataClass: TPressObjectMetadataClass;
begin
  Result := TPressObjectMetadata;
end;

procedure TPressObject.Refresh;
begin
  DataAccess.Refresh(Self);
end;

class procedure TPressObject.RegisterClass;
begin
  PressModel.AddClass(Self);
end;

constructor TPressObject.Retrieve(const AId: string;
  ADataAccess: IPressDAO; AMetadata: TPressObjectMetadata);
var
  VInstance: TPressObject;
begin
  inherited Create;
  if not Assigned(ADataAccess) then
    ADataAccess := PressDefaultDAO;
  VInstance := ADataAccess.Retrieve(ClassType, AId, AMetadata);
  if Assigned(VInstance) then
  begin
    inherited FreeInstance;
    Self := VInstance;
  end else
  begin
    InitInstance(ADataAccess, AMetadata);
    DisableChanges;
    try
      FId.AsString := AId;
    finally
      EnableChanges;
    end;
  end;
end;

procedure TPressObject.SetId(const Value: string);
begin
  FId.AsString := Value;
end;

procedure TPressObject.SetOwnerContext(AOwner: TPressStructure);
begin
  FOwnerAttribute := AOwner;
end;

procedure TPressObject.Store;
begin
  DataAccess.Store(Self);
end;

procedure TPressObject.UnchangeAttributes;
begin
  with CreateAttributeIterator do
  try
    BeforeFirstItem;
    while NextItem do
      CurrentItem.Unchanged;
  finally
    Free;
  end;
end;

class procedure TPressObject.UnregisterClass;
begin
  PressModel.RemoveClass(Self);
end;

{ TPressObjectList }

function TPressObjectList.Add(AObject: TPressObject): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressObjectList.CreateIterator: TPressObjectIterator;
begin
  Result := TPressObjectIterator.Create(Self);
end;

function TPressObjectList.GetItems(AIndex: Integer): TPressObject;
begin
  Result := inherited Items[AIndex] as TPressObject;
end;

function TPressObjectList.IndexOf(AObject: TPressObject): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressObjectList.Insert(Index: Integer; AObject: TPressObject);
begin
  inherited Insert(Index, AObject);
end;

function TPressObjectList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressObjectList.Remove(AObject: TPressObject): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressObjectList.SetItems(AIndex: Integer; const Value: TPressObject);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressObjectIterator }

function TPressObjectIterator.GetCurrentItem: TPressObject;
begin
  Result := inherited CurrentItem as TPressObject;
end;

{ TPressQuery }

function TPressQuery.Add(AObject: TPressObject): Integer;
begin
  Result := TPressReferences(FQueryItems).Add(AObject);
end;

function TPressQuery.AddAttributeParam(AAttribute: TPressAttribute): string;
var
  VParamType: TPressAttributeBaseType;
  VParamValue: Variant;
  VParam: TPressParam;
begin
  if AAttribute is TPressValue then
  begin
    VParamType := AAttribute.AttributeBaseType;
    VParamValue := AAttribute.AsVariant;
  end else if AAttribute is TPressReference then
  begin
    if Assigned(AAttribute.Metadata) then
      VParamType :=
       AAttribute.Metadata.ObjectClassMetadata.IdMetadata.AttributeClass.AttributeBaseType
    else
      VParamType := attUnknown;
    if Assigned(TPressReference(AAttribute).Value) then
      VParamValue := TPressReference(AAttribute).Value.PersistentId
    else
      VParamValue := Null;
  end else
    VParamType := attUnknown;
  if VParamType = attUnknown then
    raise EPressError.CreateFmt(SUnsupportedAttributeType, [
     AAttribute.AttributeName]);
  VParam := AddParam(VParamType);
  VParam.Value := VParamValue;
  Result := VParam.Name;
end;

function TPressQuery.AddParam(
  AParamType: TPressAttributeBaseType; const AName: string): TPressParam;
var
  VName: string;
begin
  if AName <> '' then
    VName := AName
  else
    VName := SPressSubjectParamPrefix + IntToStr(Params.Count + 1);
  Result := TPressParam.Create(VName, AParamType);
  Params.Add(Result);
end;

function TPressQuery.AddValueParam(
  AValue: Variant; AAttributeType: TPressAttributeBaseType): string;
var
  VParam: TPressParam;
begin
  VParam := AddParam(AAttributeType);
  VParam.Value := AValue;
  Result := VParam.Name;
end;

class function TPressQuery.ClassMetadata: TPressQueryMetadata;
begin
  Result := inherited ClassMetadata as TPressQueryMetadata;
end;

procedure TPressQuery.Clear;
begin
  TPressReferences(FQueryItems).Clear;
end;

procedure TPressQuery.ConcatStatements(
  const AStatementStr, AConnectorToken: string; var ABuffer: string);
begin
  if AStatementStr <> '' then
    if ABuffer = '' then
      ABuffer := '(' + AStatementStr + ')'
    else
      ABuffer := ABuffer + ' ' + AConnectorToken + ' (' + AStatementStr + ')';
end;

function TPressQuery.Count: Integer;
begin
  Result := TPressReferences(FQueryItems).Count
end;

function TPressQuery.CreateIterator: TPressQueryIterator;
begin
  Result := TPressReferences(FQueryItems).CreateIterator;
end;

procedure TPressQuery.Execute;
begin
  Params.Clear;
  InternalExecute;
end;

procedure TPressQuery.Finit;
begin
  FParams.Free;
  inherited;
end;

function TPressQuery.GetFieldNamesClause: string;
begin
  Result := '*';
end;

function TPressQuery.GetFromClause: string;
begin
  Result := Metadata.ItemObjectClassName;
end;

function TPressQuery.GetGroupByClause: string;
begin
  Result := '';
end;

function TPressQuery.GetItemsDataAccess: IPressDAO;
begin
  { TODO : Improve Items DAO assignment }
  if not Assigned(FItemsDataAccess) then
    FItemsDataAccess := DataAccess;
  Result := FItemsDataAccess;
end;

function TPressQuery.GetMetadata: TPressQueryMetadata;
begin
  Result := inherited Metadata as TPressQueryMetadata;
end;

function TPressQuery.GetObjects(AIndex: Integer): TPressObject;
begin
  Result := TPressReferences(FQueryItems)[AIndex];
end;

function TPressQuery.GetOrderByClause: string;
begin
  { TODO : Removed PersistentName searching; implement path translation }
  Result := Metadata.OrderFieldName;
end;

function TPressQuery.GetParams: TPressParamList;
begin
  if not Assigned(FParams) then
    FParams := TPressParamList.Create(True);
  Result := FParams;
end;

function TPressQuery.GetWhereClause: string;
begin
  Result := '';
  with CreateAttributeIterator do
  try
    First;
    Next;  // skip Id and QueryItems attributes
    while NextItem do
      { TODO : Improve connector token storage }
      ConcatStatements(InternalBuildStatement(CurrentItem), 'and', Result);
  finally
    Free;
  end;
end;

procedure TPressQuery.Init;
begin
  inherited;
  FMatchEmptyAndNull := True;
  FStyle := Metadata.Style;
end;

function TPressQuery.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, SPressQueryItemsString) then
    Result := Addr(FQueryItems)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

function TPressQuery.InternalBuildStatement(
  AAttribute: TPressAttribute): string;
var
  VMetadata: TPressQueryAttributeMetadata;

  function FormatOperatorItem(const AOperator: string): string;
  begin
    Result := Format('%s %s :%s', [
     VMetadata.DataName, AOperator, AddAttributeParam(AAttribute)]);
  end;

  function FormatStringItem(const AParamValue: string): string;
  begin
    Result := Format('%s like :%s', [
     VMetadata.DataName, AddValueParam(AParamValue, attString)]);
  end;

  function FormatContainsItem: string;
  begin
    if AAttribute is TPressReference then
      Result := Format(':%s in %s', [
       AddAttributeParam(AAttribute), VMetadata.DataName])
    else
      Result := FormatStringItem('%' + AAttribute.AsString + '%');
  end;

  function IsEmptyStatement: string;
  begin
    Result := Format('%s = :%s', [
     VMetadata.DataName, AddValueParam('', attString)]);
  end;

  function IsNullStatement: string;
  begin
    Result := Format('%s is null', [VMetadata.DataName]);
  end;

begin
  Result := '';
  if not (AAttribute.Metadata is TPressQueryAttributeMetadata) then
    Exit;
  VMetadata := TPressQueryAttributeMetadata(AAttribute.Metadata);
  if not AAttribute.IsEmpty or
   (not AAttribute.IsNull and not (AAttribute is TPressString)) then
    case VMetadata.MatchType of
      mtEqual:
        Result := FormatOperatorItem('=');
      mtStarting:
        Result := FormatStringItem(AAttribute.AsString + '%');
      mtFinishing:
        Result := FormatStringItem('%' + AAttribute.AsString);
      mtContains:
        Result := FormatContainsItem;
      mtGreaterThan:
        Result := FormatOperatorItem('>');
      mtGreaterThanOrEqual:
        Result := FormatOperatorItem('>=');
      mtLesserThan:
        Result := FormatOperatorItem('<');
      mtLesserThanOrEqual:
        Result := FormatOperatorItem('<=');
    end
  else if VMetadata.IncludeIfEmpty then
    if AAttribute is TPressString then
      if MatchEmptyAndNull then
        Result := Format('(%s) or (%s)', [IsNullStatement, IsEmptyStatement])
      else if AAttribute.IsNull then
        Result := IsNullStatement
      else
        Result := IsEmptyStatement
    else
      Result := IsNullStatement;
end;

procedure TPressQuery.InternalExecute;
begin
  TPressReferences(FQueryItems).AssignProxyList(
   ItemsDataAccess.RetrieveQuery(Self));
end;

class function TPressQuery.ObjectMetadataClass: TPressObjectMetadataClass;
begin
  Result := TPressQueryMetadata;
end;

function TPressQuery.Remove(AObject: TPressObject): Integer;
begin
  Result := TPressReferences(FQueryItems).Remove(AObject);
end;

function TPressQuery.RemoveReference(AProxy: TPressProxy): Integer;
begin
  Result := TPressReferences(FQueryItems).RemoveReference(AProxy);
end;

procedure TPressQuery.SetStyle(AValue: TPressQueryStyle);
begin
  if FStyle <> AValue then
  begin
    FStyle := AValue;
    Clear;
  end;
end;

{ TPressSingletonObject }

constructor TPressSingletonObject.Instance;
begin
  Self := inherited Retrieve(SingletonOID) as TPressSingletonObject;
end;

class procedure TPressSingletonObject.RegisterOID(AOID: string);
begin
  PressSingletonIDs.Values[ClassName] := AOID;
end;

class function TPressSingletonObject.SingletonOID: string;
begin
  Result := PressSingletonIDs.Values[ClassName];
  if Result = '' then
    raise EPressError.CreateFmt(SSingletonClassNotFound, [ClassName]);
end;

{ TPressProxy }

procedure TPressProxy.Assign(Source: TPersistent);
var
  VSource: TPressProxy;
begin
  if Source is TPressProxy then
  begin
    VSource := TPressProxy(Source);
    if VSource.HasInstance then
    begin
      if VSource.FInstance <> FInstance then
      begin
        Instance := VSource.FInstance;
        if ProxyType = ptOwned then
          FInstance.AddRef;
      end;
    end else if VSource.HasReference then
      AssignReference(VSource.FRefClass, VSource.FRefID, VSource.FDataAccess)
    else
      Clear;
  end else
    inherited Assign(Source);
end;

procedure TPressProxy.AssignReference(
  const ARefClass, ARefID: string; ADataAccess: IPressDAO);
begin
  AssignReference(PressModel.ClassByName(ARefClass), ARefID, ADataAccess);
end;

procedure TPressProxy.AssignReference(
  ARefClass: TPressObjectClass; const ARefID: string; ADataAccess: IPressDAO);
begin
  if Assigned(FBeforeChangeReference) then
    FBeforeChangeReference(Self, ARefClass, ARefID);
  ClearInstance;
  FRefClass := ARefClass;
  FRefID := ARefID;
  FDataAccess := ADataAccess;
  if Assigned(FAfterChangeReference) then
    FAfterChangeReference(Self, ARefClass, ARefID);
end;

procedure TPressProxy.BulkRetrieve;
var
  VIndex: Integer;
begin
  if Assigned(FOwner) and (FOwner.Count > 1) and Assigned(FDataAccess) then
  begin
    VIndex := FOwner.IndexOf(Self);
    if VIndex >= 0 then
      FDataAccess.BulkRetrieve(FOwner, VIndex, 50, 0);
  end;
end;

procedure TPressProxy.Clear;
begin
  ClearInstance;
  ClearReference;
end;

procedure TPressProxy.ClearInstance;
begin
  if not HasInstance then
    Exit;
  if Assigned(FBeforeChangeInstance) then
    FBeforeChangeInstance(Self, nil, pctAssigning);
  if ProxyType <> ptWeakReference then
    FreeAndNil(FInstance)
  else
    FInstance := nil;
  if Assigned(FAfterChangeInstance) then
    FAfterChangeInstance(Self, nil, pctAssigning);
end;

procedure TPressProxy.ClearReference;
begin
  if not HasReference then
    Exit;
  if Assigned(FBeforeChangeReference) then
    FBeforeChangeReference(Self, nil, '');
  FRefClass := nil;
  FRefID := '';
  if Assigned(FAfterChangeReference) then
    FAfterChangeReference(Self, nil, '');
end;

function TPressProxy.Clone: TPressProxy;
begin
  Result := TPressProxy.Create(ProxyType);
  Result.Assign(Self);
end;

constructor TPressProxy.Create(
  AProxyType: TPressProxyType; AObject: TPressObject);
begin
  inherited Create;
  FRefCount := 1;
  FProxyType := AProxyType;
  Instance := AObject;
end;

procedure TPressProxy.Dereference;
var
  VInstance: TPressObject;
begin
  if HasReference and Assigned(FDataAccess) then
  begin
    VInstance := FDataAccess.Retrieve(ObjectClassType, FRefID);
    { TODO : Implement IsBroken support }
    if not Assigned(VInstance) then
      raise EPressError.CreateFmt(
       SInstanceNotFound, [FRefClass.ClassName, FRefID]);
    if Assigned(FBeforeChangeInstance) then
      FBeforeChangeInstance(Self, VInstance, pctDereferencing);
    if ProxyType <> ptWeakReference then
      FreeAndNil(FInstance)
    else
      VInstance.Release;
    FInstance := VInstance;
    FRefClass := nil;
    FRefID := '';
    if Assigned(FAfterChangeInstance) then
      FAfterChangeInstance(Self, VInstance, pctDereferencing);
  end else
    raise EPressError.Create(SNoReferenceOrDataAccess);
end;

procedure TPressProxy.Finit;
begin
  if ProxyType <> ptWeakReference then
    FInstance.Free;
  inherited;
end;

function TPressProxy.GetInstance: TPressObject;
begin
  if Assigned(FBeforeRetrieveInstance) then
    FBeforeRetrieveInstance(Self);
  if HasReference and not HasInstance then
  begin
    BulkRetrieve;
    if not HasInstance then
      Dereference;
  end;
  Result := FInstance;
end;

function TPressProxy.GetObjectClassName: string;
begin
  if HasInstance then
    Result := FInstance.ClassName
  else if Assigned(FRefClass) then
    Result := FRefClass.ClassName
  else
    Result := '';
end;

function TPressProxy.GetObjectClassType: TPressObjectClass;
begin
  if HasInstance then
    Result := FInstance.ClassType
  else
    Result := FRefClass;
end;

function TPressProxy.GetObjectId: string;
begin
  if HasInstance then
    Result := FInstance.Id
  else
    Result := FRefId;
end;

function TPressProxy.HasInstance: Boolean;
begin
  Result := Assigned(FInstance);
end;

function TPressProxy.HasReference: Boolean;
begin
  Result := not IsEmptyReference(FRefClass, FRefID);
end;

function TPressProxy.IsEmpty: Boolean;
begin
  Result := not HasInstance and not HasReference;
end;

function TPressProxy.IsEmptyReference(
  ARefClass: TPressObjectClass; const ARefID: string): Boolean;
begin
  Result := ARefID = '';
end;

function TPressProxy.SameReference(AObject: TPressObject): Boolean;
begin
  if Assigned(AObject) then
    if HasInstance then
      Result := AObject = FInstance
    else
      Result := AObject.IsPersistent and (AObject.PersistentId = FRefID) and
       (not Assigned(FRefClass) or (AObject is FRefClass))
  else
    Result := IsEmpty;
end;

function TPressProxy.SameReference(const ARefClass, ARefID: string): Boolean;
begin
  Result := SameReference(PressModel.ClassByName(ARefClass), ARefID);
end;

function TPressProxy.SameReference(
  ARefClass: TPressObjectClass; const ARefID: string): Boolean;
begin
  if HasInstance then
    Result := FInstance.IsPersistent and (FInstance.PersistentId = ARefID) and
     (not Assigned(ARefClass) or (FInstance is ARefClass))
  else if HasReference then
    Result := (FRefID = ARefID) and
     (not Assigned(ARefClass) or
      (Assigned(FRefClass) and FRefClass.InheritsFrom(ARefClass)))
  else
    Result := IsEmptyReference(ARefClass, ARefID);
end;

procedure TPressProxy.SetInstance(Value: TPressObject);
var
  VChangeType: TPressProxyChangeType;
begin
  if FInstance <> Value then
  begin
    if SameReference(Value) then
      VChangeType := pctDereferencing
    else
      VChangeType := pctAssigning;
    if Assigned(FBeforeChangeInstance) then
      FBeforeChangeInstance(Self, Value, VChangeType);
    if Assigned(Value) then
    begin
      FDataAccess := Value.FDataAccess;
      if ProxyType = ptShared then
        Value.AddRef;
    end;
    if ProxyType <> ptWeakReference then
      FreeAndNil(FInstance);
    FInstance := Value;
    FRefClass := nil;
    FRefID := '';
    if Assigned(FAfterChangeInstance) then
      FAfterChangeInstance(Self, Value, VChangeType);
  end;
end;

{ TPressProxyList }

function TPressProxyList.Add(AObject: TPressProxy): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressProxyList.AddInstance(AObject: TPressObject): Integer;
var
  VProxy: TPressProxy;
begin
  VProxy := CreateProxy;
  try
    VProxy.Instance := AObject;
    Result := Add(VProxy);
  except
    Extract(VProxy);
    VProxy.Free;
    raise;
  end;
end;

function TPressProxyList.AddReference(
  const ARefClass, ARefID: string; ADataAccess: IPressDAO): Integer;
var
  VProxy: TPressProxy;
begin
  VProxy := CreateProxy;
  try
    VProxy.AssignReference(ARefClass, ARefID, ADataAccess);
    Result := Add(VProxy);
  except
    Extract(VProxy);
    VProxy.Free;
    raise;
  end;
end;

constructor TPressProxyList.Create(
  AOwnsObjects: Boolean; AProxyType: TPressProxyType);
begin
  inherited Create(AOwnsObjects);
  FProxyType := AProxyType;
end;

function TPressProxyList.CreateIterator: TPressProxyIterator;
begin
  Result := TPressProxyIterator.Create(Self);
end;

function TPressProxyList.CreateProxy: TPressProxy;
begin
  Result := TPressProxy.Create(FProxyType, nil);
end;

procedure TPressProxyList.DisableNotification;
begin
  Inc(FDisableNotificationCount);
end;

procedure TPressProxyList.EnableNotification;
begin
  if FDisableNotificationCount > 0 then
    Dec(FDisableNotificationCount);
end;

function TPressProxyList.Extract(AObject: TPressProxy): TPressProxy;
begin
  Result := inherited Extract(AObject) as TPressProxy;
end;

function TPressProxyList.GetInstances(AIndex: Integer): TPressObject;
begin
  Result := Items[AIndex].Instance;
end;

function TPressProxyList.GetItems(AIndex: Integer): TPressProxy;
begin
  Result := inherited Items[AIndex] as TPressProxy;
end;

function TPressProxyList.GetNotificationDisabled: Boolean;
begin
  Result := FDisableNotificationCount > 0;
end;

function TPressProxyList.IndexOf(AObject: TPressProxy): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

function TPressProxyList.IndexOfInstance(AObject: TPressObject): Integer;
begin
  for Result := 0 to Pred(Count) do
    if Items[Result].SameReference(AObject) then
      Exit;
  Result := -1;
end;

function TPressProxyList.IndexOfReference(
  const ARefClass, ARefID: string): Integer;
begin
  for Result := 0 to Pred(Count) do
    if Items[Result].SameReference(ARefClass, ARefID) then
      Exit;
  Result := -1;
end;

procedure TPressProxyList.Insert(Index: Integer; AObject: TPressProxy);
begin
  inherited Insert(Index, AObject);
end;

procedure TPressProxyList.InsertInstance(
  Index: Integer; AObject: TPressObject);
var
  VProxy: TPressProxy;
begin
  VProxy := CreateProxy;
  try
    VProxy.Instance := AObject;
    Insert(Index, VProxy);
  except
    Extract(VProxy);
    VProxy.Free;
    raise;
  end;
end;

procedure TPressProxyList.InsertReference(
  Index: Integer; const ARefClass, ARefID: string; ADataAccess: IPressDAO);
var
  VProxy: TPressProxy;
begin
  VProxy := CreateProxy;
  try
    Insert(Index, VProxy);
    VProxy.AssignReference(ARefClass, ARefID, ADataAccess);
  except
    Extract(VProxy);
    VProxy.Free;
    raise;
  end;
end;

function TPressProxyList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

procedure TPressProxyList.Notify(Ptr: Pointer; Action: TListNotification);
begin
  if (Action = lnAdded) and not Assigned(TPressProxy(Ptr).FOwner) then
    TPressProxy(Ptr).FOwner := Self  // friend class
  else if TPressProxy(Ptr).FOwner = Self then  {lnExtracted, lnDeleted}
    TPressProxy(Ptr).FOwner := nil;  // friend class
  if Assigned(FOnChangeList) and not NotificationDisabled then
    FOnChangeList(Self, TPressProxy(Ptr), Action);
  inherited;
end;

function TPressProxyList.Remove(
  AObject: TPressProxy): Integer;
begin
  Result := inherited Remove(AObject);
end;

function TPressProxyList.RemoveInstance(
  AObject: TPressObject): Integer;
begin
  Result := IndexOfInstance(AObject);
  if Result >= 0 then
    Delete(Result);
end;

function TPressProxyList.RemoveReference(
  const ARefClass, ARefID: string): Integer;
begin
  Result := IndexOfReference(ARefClass, ARefID);
  if Result >= 0 then
    Delete(Result);
end;

procedure TPressProxyList.SetInstances(AIndex: Integer; Value: TPressObject);
begin
  Items[AIndex].Instance := Value;
end;

procedure TPressProxyList.SetItems(
  AIndex: Integer; Value: TPressProxy);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressProxyIterator }

function TPressProxyIterator.GetCurrentItem: TPressProxy;
begin
  Result := inherited CurrentItem as TPressProxy;
end;

{ TPressAttribute }

function TPressAttribute.AccessError(const AAttributeName: string): EPressError;
begin
  Result := EPressError.CreateFmt(
   SAttributeAccessError, [ClassName, Name, AAttributeName]);
end;

procedure TPressAttribute.BindCalcNotification(AInstance: TPressObject);
begin
  if IsCalcAttribute and Assigned(AInstance) then
    Metadata.CalcMetadata.BindCalcNotification(AInstance, Notifier);
end;

{$IFDEF FPC}class{$ENDIF} function TPressAttribute.ClassType: TPressAttributeClass;
begin
  Result := TPressAttributeClass(inherited ClassType);
end;

procedure TPressAttribute.Clear;
begin
  if not FIsNull then
  begin
    Changing;
    InternalReset;
    ValueUnassigned;
  end;
end;

function TPressAttribute.Clone: TPressAttribute;
begin
  Result := ClassType.Create(nil, nil);
  Result.DisableChanges;
  try
    Result.Assign(Self);
  except
    Result.Free;
    raise;
  end;
  Result.EnableChanges;
end;

function TPressAttribute.ConversionError(
  E: EConvertError): EPressConversionError;
begin
  Result := EPressConversionError.CreateFmt(
   SAttributeConversionError, [ClassName, Name, E.Message]);
end;

constructor TPressAttribute.Create(
  AOwner: TPressObject; AMetadata: TPressAttributeMetadata);
begin
  inherited Create;
  FOwner := AOwner;
  FMetadata := AMetadata;
  DisableChanges;
  try
    Initialize;
  finally
    EnableChanges;
  end;
  InitPropInfo;
end;

function TPressAttribute.CreateMemento: TPressAttributeMemento;
begin
  Result := InternalCreateMemento;
end;

procedure TPressAttribute.Finit;
begin
  FNotifier.Free;
  inherited;
end;

function TPressAttribute.GetAsBoolean: Boolean;
begin
  raise AccessError(TPressBoolean.AttributeName);
end;

function TPressAttribute.GetAsCurrency: Currency;
begin
  Result := AsFloat;
end;

function TPressAttribute.GetAsDate: TDate;
begin
  raise AccessError(TPressDate.AttributeName);
end;

function TPressAttribute.GetAsDateTime: TDateTime;
begin
  raise AccessError(TPressDateTime.AttributeName);
end;

function TPressAttribute.GetAsFloat: Double;
begin
  raise AccessError(TPressFloat.AttributeName);
end;

function TPressAttribute.GetAsInteger: Integer;
begin
  raise AccessError(TPressInteger.AttributeName);
end;

function TPressAttribute.GetAsString: string;
begin
  raise AccessError(TPressString.AttributeName);
end;

function TPressAttribute.GetAsTime: TTime;
begin
  raise AccessError(TPressTime.AttributeName);
end;

function TPressAttribute.GetAsVariant: Variant;
begin
  raise AccessError(TPressVariant.AttributeName);
end;

function TPressAttribute.GetDataAccess: IPressDAO;
begin
  if Assigned(Owner) then
    Result := Owner.DataAccess
  else
    Result := nil;
end;

function TPressAttribute.GetDefaultValue: string;
begin
  if Assigned(Metadata) then
    Result := Metadata.DefaultValue
  else
    Result := '';
end;

function TPressAttribute.GetDisplayText: string;
begin
  if EditMask <> '' then
    Result := FormatMaskText(EditMask, AsString)
  else
    Result := AsString;
end;

function TPressAttribute.GetEditMask: string;
begin
  if Assigned(Metadata) then
    Result := Metadata.EditMask
  else
    Result := '';
end;

function TPressAttribute.GetIsCalcAttribute: Boolean;
begin
  Result := Assigned(Metadata) and Assigned(Metadata.CalcMetadata)
end;

function TPressAttribute.GetIsEmpty: Boolean;
begin
  Result := IsNull;
end;

function TPressAttribute.GetIsNull: Boolean;
begin
  VerifyCalcAttribute;
  Result := FIsNull;
end;

function TPressAttribute.GetName: string;
begin
  if Assigned(Metadata) then
    Result := Metadata.Name
  else
    Result := '';
end;

function TPressAttribute.GetNotifier: TPressNotifier;
begin
  if not Assigned(FNotifier) then
    FNotifier := TPressNotifier.Create({$IFDEF FPC}@{$ENDIF}Notify);
  Result := FNotifier;
end;

function TPressAttribute.GetPersistentName: string;
begin
  if Assigned(Metadata) then
    Result := Metadata.PersistentName
  else
    Result := '';
end;

function TPressAttribute.GetUsePublishedGetter: Boolean;
begin
  Result := FUsePublishedGetter and not ChangesDisabled;
end;

function TPressAttribute.GetUsePublishedSetter: Boolean;
begin
  Result := FUsePublishedSetter and not ChangesDisabled;
end;

procedure TPressAttribute.Initialize;
begin
  if DefaultValue <> '' then
    AsString := DefaultValue
  else
    Clear;
end;

procedure TPressAttribute.InitPropInfo;
var
  VPropInfo: PPropInfo;
begin
  if Assigned(Owner) and Assigned(Metadata) then
  begin
    VPropInfo := GetPropInfo(Owner, Metadata.Name);
    if Assigned(VPropInfo) and
     (VPropInfo^.PropType^.Kind in InternalTypeKinds) then
    begin
      FUsePublishedGetter := Assigned(VPropInfo^.GetProc);
      FUsePublishedSetter := Assigned(VPropInfo^.SetProc);
    end;
  end;
end;

procedure TPressAttribute.InternalChanged(AChangedWhenDisabled: Boolean);
begin
  inherited;
  NotifyChange;
  if Assigned(FOwner) then
    FOwner.Changed(not AChangedWhenDisabled);
end;

procedure TPressAttribute.InternalChanging;
begin
  inherited;
  if Assigned(FOwner) and not IsCalculating then
    FOwner.NotifyMemento(Self);  // friend class
end;

procedure TPressAttribute.InternalReset;
begin
end;

function TPressAttribute.InternalTypeKinds: TTypeKinds;
begin
  Result := [];
end;

function TPressAttribute.InvalidClassError(const AClassName: string): EPressError;
begin
  Result := EPressError.CreateFmt(
   SInvalidAttributeClass, [ClassName, Name, AClassName]);
end;

function TPressAttribute.InvalidValueError(AValue: Variant;
  E: EVariantError): EPressError;
begin
  Result := EPressError.CreateFmt(
   SInvalidAttributeValue, [VarToStr(AValue), ClassName, Name]);
end;

procedure TPressAttribute.Notify(AEvent: TPressEvent);
begin
  if AEvent is TPressAttributeChangedEvent and IsCalcAttribute then
  begin
    FCalcUpdated := False;
    Changed(False);
  end;
end;

procedure TPressAttribute.NotifyChange;
begin
  {$IFDEF PressLogSubjectChanges}PressLogMsg(Self, Format('Attribute %s changed', [Signature]));{$ENDIF}
  TPressAttributeChangedEvent.Create(Self).Notify;
end;

class procedure TPressAttribute.RegisterAttribute;
begin
  { TODO : Check duplicated attribute name }
  PressModel.AddAttribute(Self);
end;

procedure TPressAttribute.ReleaseCalcNotification(AInstance: TPressObject);
begin
  if IsCalcAttribute and Assigned(AInstance) then
    Metadata.CalcMetadata.ReleaseCalcNotification(AInstance, Notifier);
end;

procedure TPressAttribute.SetAsBoolean(AValue: Boolean);
begin
  raise AccessError(TPressBoolean.AttributeName);
end;

procedure TPressAttribute.SetAsCurrency(AValue: Currency);
begin
  AsFloat := AValue;
end;

procedure TPressAttribute.SetAsDate(AValue: TDate);
begin
  raise AccessError(TPressDate.AttributeName);
end;

procedure TPressAttribute.SetAsDateTime(AValue: TDateTime);
begin
  raise AccessError(TPressDateTime.AttributeName);
end;

procedure TPressAttribute.SetAsFloat(AValue: Double);
begin
  raise AccessError(TPressFloat.AttributeName);
end;

procedure TPressAttribute.SetAsInteger(AValue: Integer);
begin
  raise AccessError(TPressInteger.AttributeName);
end;

procedure TPressAttribute.SetAsString(const AValue: string);
begin
  raise AccessError(TPressString.AttributeName);
end;

procedure TPressAttribute.SetAsTime(AValue: TTime);
begin
  raise AccessError(TPressTime.AttributeName);
end;

procedure TPressAttribute.SetAsVariant(AValue: Variant);
begin
  raise AccessError(TPressVariant.AttributeName);
end;

class procedure TPressAttribute.UnregisterAttribute;
begin
  PressModel.RemoveAttribute(Self);
end;

function TPressAttribute.ValidateChars(
  const AStr: string; const AChars: TChars): Boolean;
var
  I: Integer;
  VStrLen: Integer;
begin
  Result := False;
  VStrLen := Length(AStr);
  for I := 1 to VStrLen do
    if not (AStr[I] in AChars) then
      Exit;
  Result := True;
end;

procedure TPressAttribute.ValueAssigned(AUpdateIsChangedFlag: Boolean);
begin
  FIsNull := False;
  Changed(AUpdateIsChangedFlag);
end;

procedure TPressAttribute.ValueUnassigned;
begin
  FIsNull := True;
  Changed;
end;

procedure TPressAttribute.VerifyCalcAttribute;
begin
  if IsCalculating then
    Exit;
  if not FCalcUpdated and IsCalcAttribute and Assigned(Owner) then
  begin
    FIsCalculating := True;
    try
      Owner.InternalCalcAttribute(Self);  // friend class
      FCalcUpdated := True;
    finally
      FIsCalculating := False;
    end;
  end;
end;

{ TPressAttributeList }

function TPressAttributeList.Add(AObject: TPressAttribute): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressAttributeList.CreateIterator: TPressAttributeIterator;
begin
  Result := TPressAttributeIterator.Create(Self);
end;

function TPressAttributeList.FindAttribute(
  const AAttributeName: string): TPressAttribute;
var
  I: Integer;
begin
  for I := 0 to Pred(Count) do
  begin
    Result := Items[I];
    if SameText(Result.Name, AAttributeName) then
      Exit;
  end;
  Result := nil;
end;

function TPressAttributeList.GetItems(AIndex: Integer): TPressAttribute;
begin
  Result := inherited Items[AIndex] as TPressAttribute;
end;

function TPressAttributeList.IndexOf(AObject: TPressAttribute): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressAttributeList.Insert(Index: Integer; AObject: TPressAttribute);
begin
  inherited Insert(Index, AObject);
end;

function TPressAttributeList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressAttributeList.Remove(AObject: TPressAttribute): Integer;
begin
  Result := inherited Remove(AObject);
end;

{ TPressAttributeIterator }

function TPressAttributeIterator.GetCurrentItem: TPressAttribute;
begin
  Result := inherited CurrentItem as TPressAttribute;
end;

{ TPressStructureUnassignObjectEvent }

constructor TPressStructureUnassignObjectEvent.Create(
  AOwner: TObject; AUnassignedObject: TPressObject);
begin
  inherited Create(AOwner);
  FUnassignedObject := AUnassignedObject;
  if Assigned(FUnassignedObject) then
    FUnassignedObject.AddRef;
end;

destructor TPressStructureUnassignObjectEvent.Destroy;
begin
  FUnassignedObject.Free;
  inherited;
end;

{ TPressReferenceChangedEvent }

constructor TPressReferenceChangedEvent.Create(AOwner: TObject;
  AInstance: TPressObject);
begin
  inherited Create(AOwner);
  FInstance := AInstance;
end;

{ TPressStructure }

procedure TPressStructure.AfterChangeInstance(
  Sender: TPressProxy; Instance: TPressObject;
  ChangeType: TPressProxyChangeType);
begin
  if Assigned(Instance) then
    BindInstance(Instance);
  if ChangeType = pctAssigning then
    if Assigned(Instance) then
      ValueAssigned
    else
      ValueUnassigned;
end;

procedure TPressStructure.AfterChangeReference(
  Sender: TPressProxy; AClass: TPressObjectClass; const AId: string);
begin
  if not Sender.IsEmpty then
    ValueAssigned
  else
    ValueUnassigned;
end;

procedure TPressStructure.AssignItem(AProxy: TPressProxy);
begin
  InternalAssignItem(AProxy);
end;

procedure TPressStructure.AssignObject(AObject: TPressObject);
begin
  InternalAssignObject(AObject);
end;

procedure TPressStructure.BeforeChangeInstance(
  Sender: TPressProxy; Instance: TPressObject;
  ChangeType: TPressProxyChangeType);
begin
  if ChangeType = pctAssigning then
  begin
    ValidateObject(Instance);
    if Sender.HasInstance then
      ReleaseInstance(Sender.Instance);
    Changing;
  end;
end;

procedure TPressStructure.BeforeChangeItem(AItem: TPressObject);
begin
end;

procedure TPressStructure.BeforeChangeReference(
  Sender: TPressProxy; AClass: TPressObjectClass; const AId: string);
begin
  if Assigned(AClass) then
    ValidateObjectClass(AClass);
  Changing;
end;

procedure TPressStructure.BeforeRetrieveInstance(Sender: TPressProxy);
begin
end;

procedure TPressStructure.BindInstance(AInstance: TPressObject);
begin
  Notifier.AddNotificationItem(AInstance, [TPressObjectChangedEvent]);
  { TODO : Bind owner's attributes calc notifications }
end;

procedure TPressStructure.BindProxy(AProxy: TPressProxy);
begin
  AProxy.AfterChangeInstance := {$IFDEF FPC}@{$ENDIF}AfterChangeInstance;
  AProxy.AfterChangeReference := {$IFDEF FPC}@{$ENDIF}AfterChangeReference;
  AProxy.BeforeChangeInstance := {$IFDEF FPC}@{$ENDIF}BeforeChangeInstance;
  AProxy.BeforeChangeReference := {$IFDEF FPC}@{$ENDIF}BeforeChangeReference;
  AProxy.BeforeRetrieveInstance := {$IFDEF FPC}@{$ENDIF}BeforeRetrieveInstance;
  if AProxy.HasInstance then
    BindInstance(AProxy.Instance);
end;

procedure TPressStructure.ChangedItem(
  AInstance: TPressObject; AUpdateIsChangedFlag: Boolean);
begin
end;

function TPressStructure.GetObjectClass: TPressObjectClass;
begin
  if Assigned(Metadata) then
    Result := Metadata.ObjectClass
  else
    Result := ValidObjectClass;
end;

function TPressStructure.ProxyType: TPressProxyType;
begin
  Result := InternalProxyType;
end;

procedure TPressStructure.ReferenceChanged(AInstance: TPressObject);
begin
  TPressReferenceChangedEvent.Create(Self, AInstance).Notify;
end;

procedure TPressStructure.ReleaseInstance(AInstance: TPressObject);
begin
  if Assigned(AInstance) then
  begin
    { TODO : Release owner's attributes calc notifications }
    Notifier.RemoveNotificationItem(AInstance);
  end;
end;

procedure TPressStructure.UnassignObject(AObject: TPressObject);
begin
  with TPressStructureUnassignObjectEvent.Create(Self, AObject) do
    try
      InternalUnassignObject(AObject);
    finally
      Notify;
    end;
end;

procedure TPressStructure.ValidateObject(AObject: TPressObject);
begin
  if Assigned(AObject) then
    ValidateObjectClass(AObject.ClassType);
end;

procedure TPressStructure.ValidateObjectClass(AClass: TPressObjectClass);
begin
  if not AClass.InheritsFrom(ObjectClass) then
    raise InvalidClassError(ObjectClass.ClassName);
end;

procedure TPressStructure.ValidateObjectClass(const AClassName: string);
begin
  ValidateObjectClass(PressModel.ClassByName(AClassName));
end;

procedure TPressStructure.ValidateProxy(AProxy: TPressProxy);
begin
  if AProxy.HasInstance then
    ValidateObject(AProxy.Instance)
  else if AProxy.HasReference then
    ValidateObjectClass(AProxy.ObjectClassName);
end;

class function TPressStructure.ValidObjectClass: TPressObjectClass;
begin
  Result := TPressObject;
end;

{ TPressQueryItems }

procedure TPressQueryItems.InternalUnassignObject(AObject: TPressObject);
begin
  { TODO : Cache }
  AObject.Dispose;
  inherited;
end;

initialization
  PressApp.Registry[CPressDAOService].ServiceTypeName := SPressDAOServiceName;
  TPressObject.RegisterClass;
  TPressQuery.RegisterClass;
  TPressSingletonObject.RegisterClass;
  TPressString.RegisterAttribute;
  TPressInteger.RegisterAttribute;
  TPressFloat.RegisterAttribute;
  TPressCurrency.RegisterAttribute;
  TPressEnum.RegisterAttribute;
  TPressBoolean.RegisterAttribute;
  TPressDate.RegisterAttribute;
  TPressTime.RegisterAttribute;
  TPressDateTime.RegisterAttribute;
  TPressVariant.RegisterAttribute;
  TPressMemo.RegisterAttribute;
  TPressBinary.RegisterAttribute;
  TPressPart.RegisterAttribute;
  TPressReference.RegisterAttribute;
  TPressParts.RegisterAttribute;
  TPressReferences.RegisterAttribute;
  TPressQueryItems.RegisterAttribute;

finalization
  TPressQuery.UnregisterClass;
  TPressSingletonObject.UnregisterClass;
  TPressString.UnregisterAttribute;
  TPressInteger.UnregisterAttribute;
  TPressFloat.UnregisterAttribute;
  TPressCurrency.UnregisterAttribute;
  TPressEnum.UnregisterAttribute;
  TPressBoolean.UnregisterAttribute;
  TPressDate.UnregisterAttribute;
  TPressTime.UnregisterAttribute;
  TPressDateTime.UnregisterAttribute;
  TPressVariant.UnregisterAttribute;
  TPressMemo.UnregisterAttribute;
  TPressBinary.UnregisterAttribute;
  TPressPart.UnregisterAttribute;
  TPressReference.UnregisterAttribute;
  TPressParts.UnregisterAttribute;
  TPressReferences.UnregisterAttribute;
  TPressQueryItems.UnregisterAttribute;

end.
