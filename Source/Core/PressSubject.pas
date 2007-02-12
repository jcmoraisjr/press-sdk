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
  {$IFDEF D6+}Variants,{$ENDIF}
  Classes,
  TypInfo,
  Contnrs,
  Graphics,
  PressCompatibility,
  PressClasses,
  PressApplication,
  PressNotifier;

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
    FAttributeClass: TPressAttributeClass;
    FAttributeName: string;
    FCalcMetadata: TPressCalcMetadata;
    FDefaultValue: string;
    FEditMask: string;
    FEnumMetadata: TPressEnumMetadata;
    FIsPersistent: Boolean;
    FModel: TPressModel;
    FName: string;
    FObjectClass: TPressObjectClass;
    FOwner: TPressObjectMetadata;
    FPersistentName: string;
    FSize: Integer;
    function GetObjectClassName: string;
    procedure SetAttributeName(const Value: string);
    procedure SetCalcMetadata(Value: TPressCalcMetadata);
    procedure SetEnumMetadata(Value: TPressEnumMetadata);
    procedure SetObjectClass(Value: TPressObjectClass);
    procedure SetObjectClassName(const Value: string);
  protected
    procedure SetName(const Value: string); virtual;
    property Model: TPressModel read FModel;
  public
    constructor Create(AOwner: TPressObjectMetadata); virtual;
    destructor Destroy; override;
    function CreateAttribute(AOwner: TPressObject): TPressAttribute;
    property AttributeClass: TPressAttributeClass read FAttributeClass;
    property AttributeName: string read FAttributeName write SetAttributeName;
    property CalcMetadata: TPressCalcMetadata read FCalcMetadata write SetCalcMetadata;
    property EnumMetadata: TPressEnumMetadata read FEnumMetadata write SetEnumMetadata;
    property Name: string read FName write SetName;
    property ObjectClass: TPressObjectClass read FObjectClass write SetObjectClass;
    property ObjectClassName: string read GetObjectClassName write SetObjectClassName;
    property Owner: TPressObjectMetadata read FOwner;
  published
    property DefaultValue: string read FDefaultValue write FDefaultValue;
    property EditMask: string read FEditMask write FEditMask;
    property IsPersistent: Boolean read FIsPersistent write FIsPersistent default True;
    property PersistentName: string read FPersistentName write FPersistentName;
    property Size: Integer read FSize write FSize;
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

  TPressMap = class(TPressAttributeMetadataList)
  private
    FObjectMetadata: TPressObjectMetadata;
    procedure ReadMetadatas(AObjectMetadata: TPressObjectMetadata);
  public
    constructor Create(AObjectMetadata: TPressObjectMetadata);
    function FindMetadata(const APath: string): TPressAttributeMetadata;
    function MetadataByPath(const APath: string): TPressAttributeMetadata;
    property ObjectMetadata: TPressObjectMetadata read FObjectMetadata;
  end;

  TPressObjectMetadataClass = class of TPressObjectMetadata;

  TPressObjectMetadata = class(TPressStreamable)
  private
    FAttributeMetadatas: TPressAttributeMetadataList;
    FIdMetadata: TPressAttributeMetadata;
    FKeyName: string;
    FMap: TPressMap;
    FModel: TPressModel;
    FObjectClassName: string;
    FParent: TPressObjectMetadata;
    FPersistentName: string;
    function GetAttributeMetadatas: TPressAttributeMetadataList;
    function GetIdMetadata: TPressAttributeMetadata;
    function GetMap: TPressMap;
  protected
    function InternalAttributeMetadataClass: TPressAttributeMetadataClass; virtual;
    property Model: TPressModel read FModel;
  public
    constructor Create(AObjectClassName: string; AModel: TPressModel);
    destructor Destroy; override;
    function CreateAttributeMetadata: TPressAttributeMetadata;
    property AttributeMetadatas: TPressAttributeMetadataList read GetAttributeMetadatas;
    property IdMetadata: TPressAttributeMetadata read GetIdMetadata;
    property Map: TPressMap read GetMap;
    property ObjectClassName: string read FObjectClassName;
    property Parent: TPressObjectMetadata read FParent;
  published
    property KeyName: string read FKeyName write FKeyName;
    property PersistentName: string read FPersistentName write FPersistentName;
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

  { Memento declarations }

  TPressAttributeMementoList = class;

  TPressObjectMemento = class(TObject)
  private
    FAttributes: TPressAttributeMementoList;
    FIsChanged: Boolean;
    FOwner: TPressObject;
    function GetAttributes: TPressAttributeMementoList;
    function GetSubjectChanged: Boolean;
  protected
    procedure Notify(AAttribute: TPressAttribute);
    property Attributes: TPressAttributeMementoList read GetAttributes;
    property IsChanged: Boolean read FIsChanged;
    property Owner: TPressObject read FOwner;
  public
    constructor Create(AOwner: TPressObject);
    destructor Destroy; override;
    procedure Restore;
    property SubjectChanged: Boolean read GetSubjectChanged;
  end;

  TPressObjectMementoIterator = class;

  TPressObjectMementoList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressObjectMemento;
    procedure SetItems(AIndex: Integer; Value: TPressObjectMemento);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressObjectMemento): Integer;
    function CreateIterator: TPressObjectMementoIterator;
    function Extract(AObject: TPressObjectMemento): TPressObjectMemento;
    function IndexOf(AObject: TPressObjectMemento): Integer;
    procedure Insert(Index: Integer; AObject: TPressObjectMemento);
    function Remove(AObject: TPressObjectMemento): Integer;
    property Items[AIndex: Integer]: TPressObjectMemento read GetItems write SetItems; default;
  end;

  TPressObjectMementoIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressObjectMemento;
  public
    property CurrentItem: TPressObjectMemento read GetCurrentItem;
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

  TPressModel = class(TPressService)
  private
    FAttributes: TClassList;
    FClasses: TClassList;
    FEnumMetadatas: TPressEnumMetadataList;
    FKeyType: string;
    FMetadatas: TPressObjectMetadataList;
    {$IFNDEF PressRelease}
    FNotifier: TPressNotifier;
    procedure Notify(AEvent: TPressEvent);
    {$ENDIF}
  protected
    function InternalFindAttribute(const AAttributeName: string): TPressAttributeClass; virtual;
    function InternalFindClass(const AClassName: string): TPressObjectClass; virtual;
    function InternalParentMetadataOf(AMetadata: TPressObjectMetadata): TPressObjectMetadata; virtual;
    class function InternalServiceType: TPressServiceType; override;
    property EnumMetadatas: TPressEnumMetadataList read FEnumMetadatas;
    property Metadatas: TPressObjectMetadataList read FMetadatas;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure AddAttribute(AAttributeClass: TPressAttributeClass);
    procedure AddClass(AClass: TPressObjectClass);
    function AttributeByName(const AAttributeName: string): TPressAttributeClass;
    function ClassByName(const AClassName: string): TPressObjectClass;
    function ClassByPersistentName(const APersistentName: string): TPressObjectClass;
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
    procedure UnregisterMetadata(AMetadata: TPressObjectMetadata);
    property KeyType: string read FKeyType;
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
  private
    FContentChanged: Boolean;
  public
    constructor Create(AOwner: TObject; AContentChanged: Boolean = True);
    property ContentChanged: Boolean read FContentChanged;
  end;

  TPressSubjectClass = class of TPressSubject;

  TPressSubject = class(TPressStreamable, IInterface)
  private
    FRefCount: Integer;
  protected
    procedure Finit; virtual;
    function GetSignature: string; virtual;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    constructor Create;
    function AddRef: Integer;
    procedure FreeInstance; override;
    function Release: Integer;
    property RefCount: Integer read FRefCount;
    property Signature: string read GetSignature;
  end;

  { Business Object base-type declarations }

  TPressObjectUnchangedEvent = class(TPressSubjectUnchangedEvent)
  end;

  TPressObjectChangedEvent = class(TPressSubjectChangedEvent)
  end;

  TDate = TDateTime;
  TTime = TDateTime;

  TPressAttributeList = class;
  TPressAttributeIterator = class;
  TPressStructure = class;

  TPressObject = class(TPressSubject)
  private
    FAttributes: TPressAttributeList;
    FDisableChangesCount: Integer;
    FDisableUpdatesCount: Integer;
    FId: TPressAttribute;
    FIsChanged: Boolean;
    FMap: TPressMap;
    FMementos: TPressObjectMementoList;
    FMetadata: TPressObjectMetadata;
    FOwnerAttribute: TPressStructure;
    FPersistentId: string;
    FPersistentObject: TObject;
    procedure CreateAttributes;
    function GetAttributes(AIndex: Integer): TPressAttribute;
    function GetChangesDisabled: Boolean;
    function GetId: string;
    function GetIsOwned: Boolean;
    function GetIsPersistent: Boolean;
    function GetIsUpdated: Boolean;
    function GetIsValid: Boolean;
    function GetMap: TPressMap;
    function GetMementos: TPressObjectMementoList;
    function GetMetadata: TPressObjectMetadata;
    function GetObjectOwner: TPressObject;
    function GetPersistentName: string;
    function GetUpdatesDisabled: Boolean;
    procedure NotifyMementos(AAttribute: TPressAttribute);
    procedure SetId(const Value: string);
    procedure SetPersistentObject(Value: TObject);
    procedure UnchangeAttributes;
    property Mementos: TPressObjectMementoList read GetMementos;
  protected
    procedure Finit; override;
    procedure Init;
  protected
    procedure AfterCreateAttributes; virtual;
    procedure AfterRetrieve; virtual;
    procedure AfterStore(AIsUpdating: Boolean); virtual;
    procedure BeforeCreateAttributes; virtual;
    procedure BeforeStore; virtual;
    procedure ClearOwnerContext;
    procedure Finalize; virtual;
    function GetOwner: TPersistent; override;
    procedure Initialize; virtual;
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; virtual;
    procedure InternalCalcAttribute(AAttribute: TPressAttribute); virtual;
    procedure InternalDispose; virtual;
    function InternalIsValid: Boolean; virtual;
    class function InternalMetadataStr: string; virtual;
    procedure InternalSave; virtual;
    procedure NotifyChange;
    procedure NotifyInvalidate;
    procedure NotifyUnchange;
    procedure SetOwnerContext(AOwner: TPressStructure);
  public
    constructor Create(AMetadata: TPressObjectMetadata = nil);
    constructor Retrieve(const AId: string; AMetadata: TPressObjectMetadata = nil);
    procedure Assign(Source: TPersistent); override;
    function AttributeByName(const AAttributeName: string): TPressAttribute;
    function AttributeByPath(const APath: string): TPressAttribute;
    function AttributeCount: Integer;
    procedure Changed(AAttribute: TPressAttribute);
    procedure Changing(AAttribute: TPressAttribute);
    class function ClassMap: TPressMap;
    class function ClassMetadata: TPressObjectMetadata;
    {$IFDEF FPC}class{$ENDIF} function ClassType: TPressObjectClass;
    function Clone: TPressObject;
    function CreateAttributeIterator: TPressAttributeIterator;
    function CreateMemento: TPressObjectMemento;
    procedure DisableChanges;
    procedure DisableUpdates;
    procedure Dispose;
    procedure EnableChanges;
    procedure EnableUpdates;
    function FindAttribute(const AAttributeName: string): TPressAttribute;
    function FindPathAttribute(const APath: string; ASilent: Boolean = True): TPressAttribute;
    class function ClassMetadataStr: string;
    class function ObjectMetadataClass: TPressObjectMetadataClass; virtual;
    class procedure RegisterClass;
    procedure Save;
    procedure Unchanged;
    property Attributes[AIndex: Integer]: TPressAttribute read GetAttributes;
    property ChangesDisabled: Boolean read GetChangesDisabled;
    property Id: string read GetId write SetId;
    property IsChanged: Boolean read FIsChanged;
    property IsOwned: Boolean read GetIsOwned;
    property IsPersistent: Boolean read GetIsPersistent;
    property IsUpdated: Boolean read GetIsUpdated;
    property IsValid: Boolean read GetIsValid;
    property Map: TPressMap read GetMap;
    property Metadata: TPressObjectMetadata read GetMetadata;
    property Owner: TPressObject read GetObjectOwner;
    property OwnerAttribute: TPressStructure read FOwnerAttribute;
    property PersistentId: string read FPersistentId;
    property PersistentName: string read GetPersistentName;
    property PersistentObject: TObject read FPersistentObject write SetPersistentObject;
    property UpdatesDisabled: Boolean read GetUpdatesDisabled;
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

  TPressSingletonObject = class(TPressObject)
  protected
    class function SingletonOID: string; virtual;
  public
    constructor Instance;
    class procedure RegisterOID(AOID: string);
  end;

  TPressObjectStore = class(TObject)
  private
    { TODO : Create and maintain a binary tree used to search stored objects }
    FObjectList: TPressObjectList;
    function GetObjectList: TPressObjectList;
  protected
    property ObjectList: TPressObjectList read GetObjectList;
  public
    destructor Destroy; override;
    procedure AddObject(AObject: TPressObject);
    function FindObject(const AClass, AId: string): TPressObject;
    procedure RemoveObject(AObject: TPressObject);
  end;

  { Proxy declarations }

  TPressProxy = class;

  TPressProxyType = (ptOwned, ptShared);

  TPressProxyChangeType = (pctAssigning, pctDereferencing);

  TPressProxyChangeInstanceEvent = procedure(
   Sender: TPressProxy; Instance: TPressObject;
   ChangeType: TPressProxyChangeType) of object;

  TPressProxyChangeReferenceEvent = procedure(
   Sender: TPressProxy; const AClassName, AId: string) of object;

  TPressProxyRetrieveInstanceEvent = procedure(
   Sender: TPressProxy) of object;

  TPressProxy = class(TObject)
  private
    FAfterChangeInstance: TPressProxyChangeInstanceEvent;
    FAfterChangeReference: TPressProxyChangeReferenceEvent;
    FBeforeChangeInstance: TPressProxyChangeInstanceEvent;
    FBeforeChangeReference: TPressProxyChangeReferenceEvent;
    FBeforeRetrieveInstance: TPressProxyRetrieveInstanceEvent;
    FInstance: TPressObject;
    FProxyType: TPressProxyType;
    FRefClass: string;
    FRefCount: Integer;
    FRefID: string;
    function GetInstance: TPressObject;
    function GetObjectClassName: string;
    function GetObjectId: string;
    function IsEmptyReference(const ARefClass, ARefID: string): Boolean;
    procedure SetInstance(Value: TPressObject);
  protected
    procedure Finit; virtual;
  public
    constructor Create(AProxyType: TPressProxyType; AObject: TPressObject = nil);
    function AddRef: Integer;
    procedure Assign(Source: TPressProxy); virtual;
    procedure AssignReference(const ARefClass, ARefID: string);
    procedure Clear;
    procedure ClearInstance;
    procedure ClearReference;
    function Clone: TPressProxy;
    procedure Dereference;
    procedure FreeInstance; override;
    function HasInstance: Boolean;
    function HasReference: Boolean;
    function IsEmpty: Boolean;
    function Release: Integer;
    function SameReference(AObject: TPressObject): Boolean; overload;
    function SameReference(const ARefClass, ARefID: string): Boolean; overload;
    property AfterChangeInstance: TPressProxyChangeInstanceEvent read FAfterChangeInstance write FAfterChangeInstance;
    property AfterChangeReference: TPressProxyChangeReferenceEvent read FAfterChangeReference write FAfterChangeReference;
    property BeforeChangeInstance: TPressProxyChangeInstanceEvent read FBeforeChangeInstance write FBeforeChangeInstance;
    property BeforeChangeReference: TPressProxyChangeReferenceEvent read FBeforeChangeReference write FBeforeChangeReference;
    property BeforeRetrieveInstance: TPressProxyRetrieveInstanceEvent read FBeforeRetrieveInstance write FBeforeRetrieveInstance;
    property Instance: TPressObject read GetInstance write SetInstance;
    property ObjectClassName: string read GetObjectClassName;
    property ObjectId: string read GetObjectId;
    property ProxyType: TPressProxyType read FProxyType;
  end;

  TPressProxyList = class;

  TPressProxyListEvent = procedure(
   Sender: TPressProxyList;
   Item: TPressProxy; Action: TListNotification) of object;

  TPressProxyIterator = class;

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
    function AddReference(const ARefClass, ARefID: string): Integer;
    function CreateIterator: TPressProxyIterator;
    procedure DisableNotification;
    procedure EnableNotification;
    function Extract(AObject: TPressProxy): TPressProxy;
    function IndexOf(AObject: TPressProxy): Integer;
    function IndexOfInstance(AObject: TPressObject): Integer;
    function IndexOfReference(const ARefClass, ARefID: string): Integer;
    procedure Insert(Index: Integer; AObject: TPressProxy);
    procedure InsertInstance(Index: Integer; AObject: TPressObject);
    procedure InsertReference(Index: Integer; const ARefClass, ARefID: string);
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

  TPressAttributeBaseType = (attUnknown, attString, attInteger, attFloat,
   attCurrency, attEnum, attBoolean, attDate, attTime, attDateTime, attVariant,
   attMemo, attBinary, attPicture,
   attPart, attReference, attParts, attReferences);

  TPressAttribute = class(TPressSubject)
  private
    FCalcUpdated: Boolean;
    FDisableChangesCount: Integer;
    FUsePublishedGetter: Boolean;
    FUsePublishedSetter: Boolean;
    FIsCalculating: Boolean;
    FIsChanged: Boolean;
    FIsNull: Boolean;
    FMetadata: TPressAttributeMetadata;
    FNotifier: TPressNotifier;
    FOwner: TPressObject;
    function CreateMemento: TPressAttributeMemento;
    function GetChangesDisabled: Boolean;
    function GetDefaultValue: string;
    function GetEditMask: string;
    function GetIsCalcAttribute: Boolean;
    function GetIsNull: Boolean;
    function GetName: string;
    function GetNotifier: TPressNotifier;
    function GetPersistentName: string;
    procedure InitPropInfo;
    procedure SetIsChanged(AValue: Boolean);
    function GetUsePublishedGetter: Boolean;
    function GetUsePublishedSetter: Boolean;
  protected
    function AccessError(const AAttributeName: string): EPressError;
    { TODO : Use exception messages from the PressDialog class }
    function ConversionError(E: EConvertError): EPressConversionError;
    function InvalidClassError(const AClassName: string): EPressError;
    function InvalidValueError(AValue: Variant; E: EVariantError): EPressError;
    { TODO : Review the need of As<Type> methods }
    procedure BindCalcNotification(AInstance: TPressObject);
    procedure Changing;
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
    function InternalCreateMemento: TPressAttributeMemento; virtual; abstract;
    function InternalTypeKinds: TTypeKinds; virtual;
    procedure Notify(AEvent: TPressEvent); virtual;
    procedure NotifyChange;
    procedure NotifyInvalidate;
    procedure NotifyUnchange;
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
    procedure VerifyCalcAttribute;
    property UsePublishedGetter: Boolean read GetUsePublishedGetter;
    property UsePublishedSetter: Boolean read GetUsePublishedSetter;
    property Notifier: TPressNotifier read GetNotifier;
  public
    constructor Create(AOwner: TPressObject; AMetadata: TPressAttributeMetadata); virtual;
    class function AttributeBaseType: TPressAttributeBaseType; virtual; abstract;
    class function AttributeName: string; virtual; abstract;
    procedure Changed;
    {$IFDEF FPC}class{$ENDIF} function ClassType: TPressAttributeClass;
    procedure Clear;
    function Clone: TPressAttribute;
    procedure DisableChanges;
    procedure EnableChanges;
    class procedure RegisterAttribute;
    procedure Reset; virtual;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property AsCurrency: Currency read GetAsCurrency write SetAsCurrency;
    property AsDate: TDate read GetAsDate write SetAsDate;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsString: string read GetAsString write SetAsString;
    property AsTime: TTime read GetAsTime write SetAsTime;
    property AsVariant: Variant read GetAsVariant write SetAsVariant;
    property ChangesDisabled: Boolean read GetChangesDisabled;
    property DefaultValue: string read GetDefaultValue;
    property DisplayText: string read GetDisplayText;
    property EditMask: string read GetEditMask;
    property IsCalcAttribute: Boolean read GetIsCalcAttribute;
    property IsCalculating: Boolean read FIsCalculating;
    property IsChanged: Boolean read FIsChanged write SetIsChanged;
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

  TPressStructureClass = class of TPressStructure;

  TPressStructure = class(TPressAttribute)
  private
    function GetObjectClass: TPressObjectClass;
  protected
    procedure AfterChangeInstance(Sender: TPressProxy; Instance: TPressObject; ChangeType: TPressProxyChangeType); virtual;
    procedure AfterChangeItem(AItem: TPressObject); virtual;
    procedure AfterChangeReference(Sender: TPressProxy; const AClassName, AId: string); virtual;
    procedure BeforeChangeInstance(Sender: TPressProxy; Instance: TPressObject; ChangeType: TPressProxyChangeType); virtual;
    procedure BeforeChangeItem(AItem: TPressObject); virtual;
    procedure BeforeChangeReference(Sender: TPressProxy; const AClassName, AId: string); virtual;
    procedure BeforeRetrieveInstance(Sender: TPressProxy); virtual;
    procedure BindInstance(AInstance: TPressObject); virtual;
    procedure BindProxy(AProxy: TPressProxy);
    procedure InternalAssignItem(AProxy: TPressProxy); virtual; abstract;
    procedure InternalAssignObject(AObject: TPressObject); virtual; abstract;
    function InternalProxyType: TPressProxyType; virtual; abstract;
    procedure InternalUnassignObject(AObject: TPressObject); virtual; abstract;
    procedure Notify(AEvent: TPressEvent); override;
    procedure NotifyReferenceChange;
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
function PressFindObject(const AClass, AId: string): TPressObject;

function PressModel: TPressModel;

implementation

uses
  PressConsts,
  {$IFDEF PressLog}PressLog,{$ENDIF}
  PressAttributes,
  PressMetadata,
  PressPersistence;

var
  _PressSingletonIDs: TStrings;
  _PressObjectStore: TPressObjectStore;
  _PressModel: TPressModel;

function PressSingletonIDs: TStrings;
begin
  if not Assigned(_PressSingletonIDs) then
  begin
    _PressSingletonIDs := TStringList.Create;
    PressRegisterSingleObject(_PressSingletonIDs);
  end;
  Result := _PressSingletonIDs;
end;

function PressObjectStore: TPressObjectStore;
begin
  if not Assigned(_PressObjectStore) then
  begin
    _PressObjectStore := TPressObjectStore.Create;
    PressRegisterSingleObject(_PressObjectStore);
  end;
  Result := _PressObjectStore;
end;

{ Global routines }

function PressModel: TPressModel;
begin
  if not Assigned(_PressModel) then
    _PressModel := TPressModel(PressApp.CreateService(TPressModel));
  Result := _PressModel;
end;

procedure PressAssignPersistentId(AObject: TPressObject; const AId: string);
begin
  if AObject.FPersistentId <> AId then
  begin
    AObject.FId.AsString := AId;  // friend class
    AObject.FPersistentId := AId;  // friend class
  end;
end;

function PressFindObject(const AClass, AId: string): TPressObject;
begin
  Result := PressObjectStore.FindObject(AClass, AId);
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
  for I := VTypeData.MinValue to VTypeData.MaxValue do
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
  for I := VTypeData.MinValue to VTypeData.MaxValue do
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

destructor TPressAttributeMetadata.Destroy;
begin
  FCalcMetadata.Free;
  if Assigned(FOwner) then
    FOwner.AttributeMetadatas.Extract(Self);
  inherited;
end;

function TPressAttributeMetadata.GetObjectClassName: string;
begin
  if Assigned(FObjectClass) then
    Result := FObjectClass.ClassName
  else
    Result := '';
end;

procedure TPressAttributeMetadata.SetAttributeName(const Value: string);
var
  VAttributeClass: TPressAttributeClass;
begin
  VAttributeClass := Model.FindAttribute(Value);
  if not Assigned(VAttributeClass) then
    raise EPressError.CreateFmt(SUnsupportedAttributeType, [Value]);
  FAttributeClass := VAttributeClass;
  FAttributeName := Value;

  { TODO : Initialize default Size for Enum, Boolean and Date/Time
    attribute types }
  { TODO : Improve }
  if (FSize = 0) and FAttributeClass.InheritsFrom(TPressNumeric) then
    FSize := 10;
  if (FEditMask = '') and (FAttributeClass = TPressCurrency) then
    FEditMask := ',0.00';

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
  { TODO : Assert }
  if not Assigned(Value) or not Assigned(FAttributeClass) or
   not FAttributeClass.InheritsFrom(TPressStructure) then
    Exit;

  if not Value.InheritsFrom(
   TPressStructureClass(FAttributeClass).ValidObjectClass) then
    raise EPressError.CreateFmt(SInvalidClassInheritance, [Value.ClassName,
     TPressStructureClass(FAttributeClass).ValidObjectClass.ClassName]);
  FObjectClass := Value;
end;

procedure TPressAttributeMetadata.SetObjectClassName(const Value: string);
begin
  if ObjectClassName <> Value then
    ObjectClass := Model.ClassByName(Value);
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

{ TPressMap }

constructor TPressMap.Create(AObjectMetadata: TPressObjectMetadata);
begin
  inherited Create(False);
  FObjectMetadata := AObjectMetadata;
  ReadMetadatas(AObjectMetadata);
end;

function TPressMap.FindMetadata(const APath: string): TPressAttributeMetadata;
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

function TPressMap.MetadataByPath(
  const APath: string): TPressAttributeMetadata;
begin
  Result := FindMetadata(APath);
  if not Assigned(Result) then
    raise EPressError.CreateFmt(
     SAttributeNotFound, [FObjectMetadata.ObjectClassName, APath]);
end;

procedure TPressMap.ReadMetadatas(AObjectMetadata: TPressObjectMetadata);
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

{ TPressObjectMetadata }

constructor TPressObjectMetadata.Create(
  AObjectClassName: string; AModel: TPressModel);
begin
  inherited Create;
  FObjectClassName := AObjectClassName;
  FPersistentName := FObjectClassName;
  FModel := AModel;
  FParent := FModel.ParentMetadataOf(Self);
  FKeyName := SPressIdString;
  FModel.Metadatas.Add(Self);
end;

function TPressObjectMetadata.CreateAttributeMetadata: TPressAttributeMetadata;
begin
  Result := InternalAttributeMetadataClass.Create(Self);
end;

destructor TPressObjectMetadata.Destroy;
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
    FIdMetadata := InternalAttributeMetadataClass.Create(nil);
    FIdMetadata.Name := KeyName;
    FIdMetadata.AttributeName := Model.KeyType;
  end;
  Result := FIdMetadata;
end;

function TPressObjectMetadata.GetMap: TPressMap;
begin
  if not Assigned(FMap) then
    FMap := TPressMap.Create(Self);
  Result := FMap;
end;

function TPressObjectMetadata.InternalAttributeMetadataClass: TPressAttributeMetadataClass;
begin
  Result := TPressAttributeMetadata;
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
begin
  Result := inherited Remove(AObject);
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

{ TPressObjectMemento }

constructor TPressObjectMemento.Create(AOwner: TPressObject);
begin
  inherited Create;
  {$IFDEF PressLogSubjectMemento}PressLogMsg(Self, 'Creating ' + AOwner.Signature, []);{$ENDIF}
  FOwner := AOwner;
  FOwner.AddRef;
  FIsChanged := FOwner.IsChanged;
end;

destructor TPressObjectMemento.Destroy;
begin
  {$IFDEF PressLogSubjectMemento}PressLogMsg(Self, 'Destroying ' + Owner.Signature, []);{$ENDIF}
  FAttributes.Free;
  FOwner.Mementos.Extract(Self);  // friend class
  FOwner.Free;
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
  {$IFDEF PressLogSubjectMemento}PressLogMsg(Self, Format('Notifying %s (%s)', [Owner.Signature, AAttribute.Signature]), []);{$ENDIF}
  if Attributes.IndexOfOwner(AAttribute) = -1 then
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

procedure TPressObjectMemento.Restore;
var
  I: Integer;
begin
  {$IFDEF PressLogSubjectMemento}PressLogMsg(Self, 'Restoring ' + Owner.Signature, []);{$ENDIF}
  { TODO : Retrieve under ChangesDisabled state }
  if Assigned(FAttributes) then
    for I := Pred(FAttributes.Count) downto 0 do
      FAttributes[I].Restore;
  if not FIsChanged then
    Owner.Unchanged;
end;

{ TPressObjectMementoList }

function TPressObjectMementoList.Add(
  AObject: TPressObjectMemento): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressObjectMementoList.CreateIterator: TPressObjectMementoIterator;
begin
  Result := TPressObjectMementoIterator.Create(Self);
end;

function TPressObjectMementoList.Extract(
  AObject: TPressObjectMemento): TPressObjectMemento;
begin
  Result := inherited Extract(AObject) as TPressObjectMemento;
end;

function TPressObjectMementoList.GetItems(
  AIndex: Integer): TPressObjectMemento;
begin
  Result := inherited Items[AIndex] as TPressObjectMemento;
end;

function TPressObjectMementoList.IndexOf(
  AObject: TPressObjectMemento): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressObjectMementoList.Insert(
  Index: Integer; AObject: TPressObjectMemento);
begin
  inherited Insert(Index, AObject);
end;

function TPressObjectMementoList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressObjectMementoList.Remove(
  AObject: TPressObjectMemento): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressObjectMementoList.SetItems(
  AIndex: Integer; Value: TPressObjectMemento);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressObjectMementoIterator }

function TPressObjectMementoIterator.GetCurrentItem: TPressObjectMemento;
begin
  Result := inherited CurrentItem as TPressObjectMemento;
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
    Owner.IsChanged := False;
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
end;

procedure TPressModel.AddClass(AClass: TPressObjectClass);
begin
  FClasses.Add(AClass);
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

function TPressModel.ClassByPersistentName(
  const APersistentName: string): TPressObjectClass;
var
  I: Integer;
begin
  // first pass -- by instantiated metadatas
  for I := 0 to Pred(Metadatas.Count) do
    with Metadatas[I] do
      if SameText(PersistentName, APersistentName) then
      begin
        Result := ClassByName(ObjectClassName);
        Exit;
      end;

  // second pass -- by registered classes
  for I := 0 to Pred(FClasses.Count) do
    with TPressObjectClass(FClasses[I]).ClassMetadata do
      if SameText(PersistentName, APersistentName) then
      begin
        Result := ClassByName(ObjectClassName);
        Exit;
      end;

  // All metadatas was instantiated, this PersistentName doesn't exist
  raise EPressError.CreateFmt(SPersistentClassNotFound, [APersistentName]);
end;

constructor TPressModel.Create;
begin
  inherited Create;
  FAttributes := TClassList.Create;
  FClasses := TClassList.Create;
  FMetadatas := TPressObjectMetadataList.Create(True);
  FEnumMetadatas := TPressEnumMetadataList.Create(True);
  FKeyType := TPressString.AttributeName;
  {$IFNDEF PressRelease}
  FNotifier := TPressNotifier.Create(Notify);
  FNotifier.AddNotificationItem(PressApp, [TPressApplicationRunningEvent]);
  {$ENDIF}
end;

function TPressModel.CreateMetadataIterator: TPressObjectMetadataIterator;
begin
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
  for I := 0 to Pred(Metadatas.Count) do
  begin
    Result := Metadatas[I];
    if SameText(Result.ObjectClassName, AClassName) then
      Exit;
  end;
  Result := nil;
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
  VObjectClass := ClassByName(AMetadata.ObjectClassName);
  if VObjectClass <> TPressObject then
    Result := TPressObjectClass(VObjectClass.ClassParent).ClassMetadata
  else
    Result := nil;
end;

class function TPressModel.InternalServiceType: TPressServiceType;
begin
  Result := stBusinessModel;
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
var
  I: Integer;
begin
  for I := 0 to Pred(FClasses.Count) do
    TPressObjectClass(FClasses[I]).ClassMap;
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

procedure TPressModel.UnregisterMetadata(AMetadata: TPressObjectMetadata);
begin
  { TODO : Verify metadatas whose parent is AMetadata }
  Metadatas.Remove(AMetadata);
end;

{ TPressSubjectEvent }

{$IFNDEF PressLogSubjectEvents}
function TPressSubjectEvent.AllowLog: Boolean;
begin
  Result := False;
end;
{$ENDIF}

{ TPressSubjectChangedEvent }

constructor TPressSubjectChangedEvent.Create(
  AOwner: TObject; AContentChanged: Boolean);
begin
  inherited Create(AOwner);
  FContentChanged := AContentChanged;
end;

{ TPressSubject }

function TPressSubject.AddRef: Integer;
begin
  ThreadSafeIncrement(FRefCount);
  Result := FRefCount;
end;

constructor TPressSubject.Create;
begin
  {$IFDEF PressLogMemory}PressLogMsg(Self, 'Creating "' + Signature + '"');{$ENDIF}
  inherited Create;
  FRefCount := 1;
end;

procedure TPressSubject.Finit;
begin
  {$IFDEF PressLogMemory}PressLogMsg(Self, 'Destroying "' + Signature + '"');{$ENDIF}
end;

procedure TPressSubject.FreeInstance;
begin
  Release;
  if FRefCount = 0 then
    try
      Finit;
    finally
      inherited;
    end;
end;

function TPressSubject.GetSignature: string;
begin
  Result := ClassName;
end;

function TPressSubject.QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := HResult($80004002);  // E_NOINTERFACE
end;

function TPressSubject.Release: Integer;
begin
  ThreadSafeDecrement(FRefCount);
  Result := FRefCount;
end;

function TPressSubject._AddRef: Integer; stdcall;
begin
  Result := AddRef;
end;

function TPressSubject._Release: Integer; stdcall;
begin
  Result := Release;
  if Result = 0 then
    try
      Finit;
    finally
      inherited FreeInstance;
    end;
end;

{ TPressObject }

procedure TPressObject.AfterCreateAttributes;
begin
end;

procedure TPressObject.AfterRetrieve;
begin
end;

procedure TPressObject.AfterStore(AIsUpdating: Boolean);
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

procedure TPressObject.BeforeCreateAttributes;
begin
end;

procedure TPressObject.BeforeStore;
begin
end;

procedure TPressObject.Changed(AAttribute: TPressAttribute);
begin
  if ChangesDisabled then
    Exit;
  FIsChanged := True;
  NotifyChange;
end;

procedure TPressObject.Changing(AAttribute: TPressAttribute);
begin
  if AAttribute.ChangesDisabled or ChangesDisabled then
    Exit;
  if Assigned(FOwnerAttribute) then
    FOwnerAttribute.BeforeChangeItem(Self);  // friend class
  NotifyMementos(AAttribute);
end;

class function TPressObject.ClassMap: TPressMap;
begin
  Result := ClassMetadata.Map;
end;

class function TPressObject.ClassMetadata: TPressObjectMetadata;
begin
  Result := PressModel.FindMetadata(ClassName);
  if not Assigned(Result) then
    Result := PressModel.RegisterMetadata(ClassMetadataStr)
end;

class function TPressObject.ClassMetadataStr: string;
var
  VMetadataMethod, VParentMetadataMethod: function: string of object;
begin
  Result := '';
  if Self <> TPressObject then
  begin
    VMetadataMethod := InternalMetadataStr;
    VParentMetadataMethod := TPressObjectClass(ClassParent).InternalMetadataStr;
    if TMethod(VMetadataMethod).Code <> TMethod(VParentMetadataMethod).Code then
      Result := VMetadataMethod;
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
  Result := ClassType.Create(FMetadata);
  Result.Assign(Self);
end;

constructor TPressObject.Create(AMetadata: TPressObjectMetadata);
begin
  inherited Create;
  FMetadata := AMetadata;
  Init;
end;

function TPressObject.CreateAttributeIterator: TPressAttributeIterator;
begin
  Result := FAttributes.CreateIterator;
end;

procedure TPressObject.CreateAttributes;
var
  VAttribute: PPressAttribute;
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
      VAttribute := InternalAttributeAddress(VMetadata.Name);
      if Assigned(VAttribute) then
      begin
        if not Assigned(VAttribute^) then
        begin
          VAttribute^ := VMetadata.CreateAttribute(Self);
          FAttributes.Add(VAttribute^);
        end;
      end else
        raise EPressError.CreateFmt(SAttributeNotFound,
         [VMetadata.Owner.ObjectClassName, VMetadata.Name]);
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

function TPressObject.CreateMemento: TPressObjectMemento;
begin
  Result := TPressObjectMemento.Create(Self);
  try
    Mementos.Add(Result);
  except
    Result.Free;
    raise;
  end;
end;

procedure TPressObject.DisableChanges;
begin
  Inc(FDisableChangesCount);
end;

procedure TPressObject.DisableUpdates;
begin
  { TODO : Disable updates in structured attributes }
  Inc(FDisableUpdatesCount);
  if FDisableUpdatesCount = 1 then
    NotifyInvalidate;
end;

procedure TPressObject.Dispose;
begin
  InternalDispose;
end;

procedure TPressObject.EnableChanges;
begin
  if FDisableChangesCount > 0 then
    Dec(FDisableChangesCount);
end;

procedure TPressObject.EnableUpdates;
begin
  if FDisableUpdatesCount > 0 then
    Dec(FDisableUpdatesCount);
  if FDisableUpdatesCount = 0 then
    NotifyInvalidate;
end;

procedure TPressObject.Finalize;
begin
end;

function TPressObject.FindAttribute(const AAttributeName: string): TPressAttribute;
var
  VAttribute: PPressAttribute;
begin
  VAttribute := InternalAttributeAddress(AAttributeName);
  if Assigned(VAttribute) then
    Result := VAttribute^
  else
    Result := nil;
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
  FPersistentObject.Free;
  DisableChanges;
  try
    Finalize;
  finally
    PressObjectStore.RemoveObject(Self);
    FMementos.Free;
    FAttributes.Free;
    inherited;
  end;
end;

function TPressObject.GetAttributes(AIndex: Integer): TPressAttribute;
begin
  Result := FAttributes[AIndex];
end;

function TPressObject.GetChangesDisabled: Boolean;
begin
  Result := (FDisableChangesCount > 0) or
   (IsOwned and FOwnerAttribute.ChangesDisabled);
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
begin
  Result := not IsChanged and IsPersistent;
end;

function TPressObject.GetIsValid: Boolean;
begin
  Result := InternalIsValid;
end;

function TPressObject.GetMap: TPressMap;
begin
  if not Assigned(FMap) then
    FMap := Metadata.Map;
  Result := FMap;
end;

function TPressObject.GetMementos: TPressObjectMementoList;
begin
  if not Assigned(FMementos) then
    FMementos := TPressObjectMementoList.Create(False);
  Result := FMementos;
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

function TPressObject.GetUpdatesDisabled: Boolean;
begin
  Result := FDisableUpdatesCount > 0;
end;

procedure TPressObject.Init;
begin
  FAttributes := TPressAttributeList.Create(True);
  DisableChanges;
  try
    CreateAttributes;
    PressObjectStore.AddObject(Self);
    Initialize;
  finally
    EnableChanges;
  end;
end;

procedure TPressObject.Initialize;
begin
end;

function TPressObject.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  Result := FieldAddress(SPressAttributePrefix + AAttributeName);
end;

procedure TPressObject.InternalCalcAttribute(AAttribute: TPressAttribute);
begin
end;

procedure TPressObject.InternalDispose;
begin
  PressDefaultPersistence.Dispose(Self);
end;

function TPressObject.InternalIsValid: Boolean;
begin
  Result := True;
end;

class function TPressObject.InternalMetadataStr: string;
begin
  Result := '';
end;

procedure TPressObject.InternalSave;
begin
  PressDefaultPersistence.Store(Self);
end;

procedure TPressObject.NotifyChange;
begin
  {$IFDEF PressLogSubjectChanges}PressLogMsg(Self, Format('Object %s changed', [Signature]));{$ENDIF}
  TPressObjectChangedEvent.Create(Self).Notify;
end;

procedure TPressObject.NotifyInvalidate;
begin
  {$IFDEF PressLogSubjectChanges}PressLogMsg(Self, Format('Object %s invalidated', [Signature]));{$ENDIF}
  TPressObjectChangedEvent.Create(Self, False).Notify;
end;

procedure TPressObject.NotifyMementos(AAttribute: TPressAttribute);
begin
  if Assigned(FMementos) then
    with FMementos.CreateIterator do
    try
      BeforeFirstItem;
      while NextItem do
        CurrentItem.Notify(AAttribute);
    finally
      Free;
    end;
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

class procedure TPressObject.RegisterClass;
begin
  PressModel.AddClass(Self);
end;

constructor TPressObject.Retrieve(
  const AId: string; AMetadata: TPressObjectMetadata);
var
  VInstance: TPressObject;
begin
  inherited Create;
  VInstance := PressDefaultPersistence.Retrieve(PersistentName, AId);
  if Assigned(VInstance) then
  begin
    inherited FreeInstance;
    Self := VInstance;
  end else
  begin
    FMetadata := AMetadata;
    Init;
    DisableChanges;
    try
      FId.AsString := AId;
    finally
      EnableChanges;
    end;
  end;
end;

procedure TPressObject.Save;
begin
  InternalSave;
end;

procedure TPressObject.SetId(const Value: string);
begin
  FId.AsString := Value;
end;

procedure TPressObject.SetOwnerContext(AOwner: TPressStructure);
begin
  FOwnerAttribute := AOwner;
end;

procedure TPressObject.SetPersistentObject(Value: TObject);
begin
  FPersistentObject.Free;
  FPersistentObject := Value;
end;

procedure TPressObject.UnchangeAttributes;
begin
  with CreateAttributeIterator do
  try
    BeforeFirstItem;
    while NextItem do
      CurrentItem.IsChanged := False;
  finally
    Free;
  end;
end;

procedure TPressObject.Unchanged;
begin
  if ChangesDisabled then
    Exit;
  UnchangeAttributes;
  FIsChanged := False;
  NotifyUnchange;
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

{ TPressSingletonObject }

constructor TPressSingletonObject.Instance;
begin
  Self := TPressSingletonObject(Retrieve(SingletonOID));
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

{ TPressObjectStore }

procedure TPressObjectStore.AddObject(AObject: TPressObject);
begin
  ObjectList.Add(AObject);
end;

destructor TPressObjectStore.Destroy;
begin
  FObjectList.Free;
  inherited;
end;

function TPressObjectStore.FindObject(const AClass, AId: string): TPressObject;
var
  I: Integer;
begin
  for I := 0 to Pred(ObjectList.Count) do
  begin
    Result := ObjectList[I];
    if (Result.PersistentId = AId) and
     ((AClass = '') or SameText(Result.ClassName, AClass)) then
      Exit;
  end;
  Result := nil;
end;

function TPressObjectStore.GetObjectList: TPressObjectList;
begin
  if not Assigned(FObjectList) then
    FObjectList := TPressObjectList.Create(False);
  Result := FObjectList;
end;

procedure TPressObjectStore.RemoveObject(AObject: TPressObject);
begin
  ObjectList.Remove(AObject);
end;

{ TPressProxy }

function TPressProxy.AddRef: Integer;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;

procedure TPressProxy.Assign(Source: TPressProxy);
begin
  if Source.HasInstance then
  begin
    if Source.FInstance <> FInstance then
    begin
      Instance := Source.FInstance;
      if ProxyType = ptOwned then
        FInstance.AddRef;
    end;
  end else if Source.HasReference then
    AssignReference(Source.FRefClass, Source.FRefID)
  else
    Clear;
end;

procedure TPressProxy.AssignReference(const ARefClass, ARefID: string);
begin
  if Assigned(FBeforeChangeReference) then
    FBeforeChangeReference(Self, ARefClass, ARefID);
  ClearInstance;
  FRefClass := ARefClass;
  FRefID := ARefID;
  if Assigned(FAfterChangeReference) then
    FAfterChangeReference(Self, ARefClass, ARefID);
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
  FreeAndNil(FInstance);
  if Assigned(FAfterChangeInstance) then
    FAfterChangeInstance(Self, nil, pctAssigning);
end;

procedure TPressProxy.ClearReference;
begin
  if not HasReference then
    Exit;
  if Assigned(FBeforeChangeReference) then
    FBeforeChangeReference(Self, '', '');
  FRefClass := '';
  FRefID := '';
  if Assigned(FAfterChangeReference) then
    FAfterChangeReference(Self, '', '');
end;

function TPressProxy.Clone: TPressProxy;
begin
  Result := TPressProxy.Create(FProxyType);
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
  if HasReference then
  begin
    VInstance := PressDefaultPersistence.Retrieve(FRefClass, FRefID);
    { TODO : Implement IsBroken support }
    if not Assigned(VInstance) then
      raise EPressError.CreateFmt(SInstanceNotFound, [FRefClass, FRefID]);
    if Assigned(FBeforeChangeInstance) then
      FBeforeChangeInstance(Self, VInstance, pctDereferencing);
    FInstance.Free;
    FInstance := VInstance;
    FRefClass := '';
    FRefID := '';
    if Assigned(FAfterChangeInstance) then
      FAfterChangeInstance(Self, VInstance, pctDereferencing);
  end else
    raise EPressError.Create(SNoReference);
end;

procedure TPressProxy.Finit;
begin
  { TODO : Removed to avoid events and AVs }
  //ClearInstance;
  FInstance.Free;
end;

procedure TPressProxy.FreeInstance;
begin
  Release;
  if FRefCount = 0 then
    try
      Finit;
    finally
      inherited;
    end;
end;

function TPressProxy.GetInstance: TPressObject;
begin
  if Assigned(FBeforeRetrieveInstance) then
    FBeforeRetrieveInstance(Self);
  if HasReference and not HasInstance then
    Dereference;
  Result := FInstance;
end;

function TPressProxy.GetObjectClassName: string;
begin
  if HasInstance then
    Result := FInstance.ClassName
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
  const ARefClass, ARefID: string): Boolean;
begin
  Result := ARefID = '';
end;

function TPressProxy.Release: Integer;
begin
  Dec(FRefCount);
  Result := FRefCount;
end;

function TPressProxy.SameReference(AObject: TPressObject): Boolean;
begin
  if Assigned(AObject) then
    if HasInstance then
      Result := AObject = FInstance
    else
      Result := AObject.IsPersistent and (AObject.PersistentId = FRefID) and
       ((FRefClass = '') or (SameText(AObject.ClassName, FRefClass)))
  else
    Result := IsEmpty;
end;

function TPressProxy.SameReference(const ARefClass, ARefID: string): Boolean;
begin
  if HasInstance then
    Result := FInstance.IsPersistent and (FInstance.PersistentId = ARefID) and
     ((ARefClass = '') or SameText(FInstance.ClassName, ARefClass))
  else if HasReference then
    Result := (FRefID = ARefID) and
     ((ARefClass = '') or SameText(FRefClass, ARefClass))
  else
    Result := IsEmptyReference(ARefClass, ARefID);
end;

procedure TPressProxy.SetInstance(Value: TPressObject);
begin
  if FInstance <> Value then
  begin
    if Assigned(FBeforeChangeInstance) then
      FBeforeChangeInstance(Self, Value, pctAssigning);
    FInstance.Free;
    FInstance := Value;
    FRefClass := '';
    FRefID := '';
    if (FProxyType = ptShared) and HasInstance then
      FInstance.AddRef;
    if Assigned(FAfterChangeInstance) then
      FAfterChangeInstance(Self, Value, pctAssigning);
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
  const ARefClass, ARefID: string): Integer;
var
  VProxy: TPressProxy;
begin
  VProxy := CreateProxy;
  try
    VProxy.AssignReference(ARefClass, ARefID);
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
  Index: Integer; const ARefClass, ARefID: string);
var
  VProxy: TPressProxy;
begin
  VProxy := CreateProxy;
  try
    Insert(Index, VProxy);
    VProxy.AssignReference(ARefClass, ARefID);
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

procedure TPressProxyList.Notify(
  Ptr: Pointer; Action: TListNotification);
begin
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

procedure TPressAttribute.Changed;
begin
  FIsNull := False;
  IsChanged := True;
end;

procedure TPressAttribute.Changing;
begin
  if not IsCalculating and Assigned(FOwner) then
    FOwner.Changing(Self);
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
    FIsNull := True;
    Reset;
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

procedure TPressAttribute.DisableChanges;
begin
  Inc(FDisableChangesCount);
end;

procedure TPressAttribute.EnableChanges;
begin
  Dec(FDisableChangesCount);
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

function TPressAttribute.GetChangesDisabled: Boolean;
begin
  Result := (FDisableChangesCount > 0) or
   (Assigned(FOwner) and FOwner.ChangesDisabled);
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

function TPressAttribute.GetUsePublishedGetter: Boolean;
begin
  Result := FUsePublishedGetter and not ChangesDisabled;
end;

function TPressAttribute.GetUsePublishedSetter: Boolean;
begin
  Result := FUsePublishedSetter and not ChangesDisabled;
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
    FNotifier := TPressNotifier.Create(Notify);
  Result := FNotifier;
end;

function TPressAttribute.GetPersistentName: string;
begin
  if Assigned(Metadata) then
    Result := Metadata.PersistentName
  else
    Result := '';
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
     (VPropInfo^.PropType^^.Kind in InternalTypeKinds) then
    begin
      FUsePublishedGetter := Assigned(VPropInfo^.GetProc);
      FUsePublishedSetter := Assigned(VPropInfo^.SetProc);
    end;
  end;
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
  if AEvent.ClassType.InheritsFrom(TPressAttributeChangedEvent) and
   IsCalcAttribute then
  begin
    FCalcUpdated := False;
    NotifyInvalidate;
  end;
end;

procedure TPressAttribute.NotifyChange;
begin
  {$IFDEF PressLogSubjectChanges}PressLogMsg(Self, Format('Attribute %s changed', [Signature]));{$ENDIF}
  TPressAttributeChangedEvent.Create(Self).Notify;
end;

procedure TPressAttribute.NotifyInvalidate;
begin
  {$IFDEF PressLogSubjectChanges}PressLogMsg(Self, Format('Attribute %s invalidated', [Signature]));{$ENDIF}
  TPressAttributeChangedEvent.Create(Self, False).Notify;
end;

procedure TPressAttribute.NotifyUnchange;
begin
  {$IFDEF PressLogSubjectChanges}PressLogMsg(Self, Format('Attribute %s unchanged', [Signature]));{$ENDIF}
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

procedure TPressAttribute.Reset;
begin
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

procedure TPressAttribute.SetIsChanged(AValue: Boolean);
begin
  if ChangesDisabled then
    Exit;
  FIsChanged := AValue;
  if FIsChanged then
  begin
    NotifyChange;
    if Assigned(Owner) then
      Owner.Changed(Self);
  end else
    { TODO : Unchange item(s) of structure classes }
    NotifyUnchange;
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

{ TPressStructure }

procedure TPressStructure.AfterChangeInstance(
  Sender: TPressProxy; Instance: TPressObject;
  ChangeType: TPressProxyChangeType);
begin
  if Assigned(Instance) then
    BindInstance(Instance);
  if ChangeType = pctAssigning then
    Changed;
end;

procedure TPressStructure.AfterChangeItem(AItem: TPressObject);
begin
end;

procedure TPressStructure.AfterChangeReference(
  Sender: TPressProxy; const AClassName, AId: string);
begin
  Changed;
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
  Sender: TPressProxy; const AClassName, AId: string);
begin
  ValidateObjectClass(AClassName);
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
  AProxy.AfterChangeInstance := AfterChangeInstance;
  AProxy.AfterChangeReference := AfterChangeReference;
  AProxy.BeforeChangeInstance := BeforeChangeInstance;
  AProxy.BeforeChangeReference := BeforeChangeReference;
  AProxy.BeforeRetrieveInstance := BeforeRetrieveInstance;
  if AProxy.HasInstance then
    BindInstance(AProxy.Instance);
end;

function TPressStructure.GetObjectClass: TPressObjectClass;
begin
  if Assigned(Metadata) then
    Result := Metadata.ObjectClass
  else
    Result := ValidObjectClass;
end;

procedure TPressStructure.Notify(AEvent: TPressEvent);
begin
  inherited;
  if AEvent.Owner is TPressObject then
    AfterChangeItem(TPressObject(AEvent.Owner));
end;

procedure TPressStructure.NotifyReferenceChange;
begin
  NotifyInvalidate;
  if Assigned(Owner) then
    Owner.NotifyInvalidate;  // friend class
end;

function TPressStructure.ProxyType: TPressProxyType;
begin
  Result := InternalProxyType;
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

procedure RegisterClasses;
begin
  TPressObject.RegisterClass;
  TPressSingletonObject.RegisterClass;
end;

initialization
  RegisterClasses;
  { TODO : Forcing premature ObjectStore initialization to avoid AVs
    due to SingleObjects destruction order.
    An ApplicationContext instance holding and destroying SingleObjects
    solves this issue. }
  PressObjectStore;

end.
