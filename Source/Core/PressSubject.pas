(*
  PressObjects, Subject Classes
  Copyright (C) 2006 Laserpress Ltda.

  http://www.pressobjects.org

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*)

unit PressSubject;

interface

{$I Press.inc}

uses
{$IFDEF USE_INSTANTOBJECTS}
  InstantPersistence;
{$ELSE}
  SysUtils,
  {$IFDEF D6+}Variants,{$ENDIF}
  Classes,
  Controls,
  Graphics,
  PressCompatibility,
  PressClasses,
  PressNotifier;
{$ENDIF}

type
{$IFDEF USE_INSTANTOBJECTS}
  TPressSubject = TObject;
  TPressSubjectClass = TClass;
  TPressObject = TInstantObject;

  TPressValue = TInstantSimple;
  TPressString = TInstantString;
  TPressInteger = TInstantInteger;
  TPressFloat = TInstantFloat;
  TPressCurrency = TInstantCurrency;
  TPressBoolean = TInstantBoolean;
  TPressDate = TInstantDateTime;
  TPressTime = TInstantDateTime;
  TPressDateTime = TInstantDateTime;
  //TPressVariant
  TPressMemo = TInstantMemo;
  TPressPicture = TInstantGraphic;

  TPressStructure = TInstantComplex;
  TPressPart = TInstantPart;
  TPressReference = TInstantReference;
  TPressItems = TInstantContainer;
  TPressParts = TInstantParts;
  TPressReferences = TInstantReferences;
{$ELSE}
  TPressObject = class;
  TPressObjectClass = class of TPressObject;
  TPressObjectMetadata = class;
  PPressAttribute = ^TPressAttribute;
  TPressAttribute = class;
  TPressAttributeClass = class of TPressAttribute;

  { Metadata declarations }

  TPressEnumMetadata = class(TObject)
  private
    FItems: TStrings;
    FName: string;
    FTypeAddress: Pointer;
    function RemoveEnumItemPrefix(const AEnumName: string): string;
  public
    constructor Create(ATypeAddress: Pointer);
    destructor Destroy; override;
    property Items: TStrings read FItems write FItems;
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

  TPressAttributeMetadata = class(TPressStreamable)
  private
    FAttributeName: string;
    FDefaultValue: string;
    FEditMask: string;
    FEnumMetadata: TPressEnumMetadata;
    FName: string;
    FObjectClass: TPressObjectClass;
    FObjectClassName: string;
    FOwner: TPressObjectMetadata;
    FPersistentName: string;
    FSize: Integer;
    procedure SetName(const Value: string);
    procedure SetObjectClassName(const Value: string);
  public
    constructor Create(AOwner: TPressObjectMetadata);
    function CreateAttribute(AOwner: TPressObject): TPressAttribute;
    property ObjectClass: TPressObjectClass read FObjectClass;
  published
    property AttributeName: string read FAttributeName write FAttributeName;
    property DefaultValue: string read FDefaultValue write FDefaultValue;
    property EditMask: string read FEditMask write FEditMask;
    property EnumMetadata: TPressEnumMetadata read FEnumMetadata write FEnumMetadata;
    property Name: string read FName write SetName;
    property ObjectClassName: string read FObjectClassName write SetObjectClassName;
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

  TPressObjectMetadata = class(TPressStreamable)
  private
    FAttributeMetadatas: TPressAttributeMetadataList;
    FObjectClass: TPressObjectClass;
    FPersistentName: string;
    function GetAttributeMetadatas: TPressAttributeMetadataList;
  public
    constructor Create(AObjectClass: TPressObjectClass);
    destructor Destroy; override;
    function ParentMetadata: TPressObjectMetadata;
    property AttributeMetadatas: TPressAttributeMetadataList read GetAttributeMetadatas;
    property ObjectClass: TPressObjectClass read FObjectClass;
  published
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
  protected
    procedure Notify(AAttribute: TPressAttribute);
    property Attributes: TPressAttributeMementoList read GetAttributes;
    property IsChanged: Boolean read FIsChanged;
    property Owner: TPressObject read FOwner;
  public
    constructor Create(AOwner: TPressObject);
    destructor Destroy; override;
    procedure Restore;
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

  TPressValue = class;

  TPressValueMemento = class(TPressAttributeMemento)
  private
    FAttributeClone: TPressValue;
  protected
    procedure Modifying; override;
    procedure Restore; override;
    property AttributeClone: TPressValue read FAttributeClone;
  public
    destructor Destroy; override;
  end;

  TPressItemState = (isUnmodified, isAdded, isModified, isDeleted);

  TPressItemMementoList = class;
  TPressProxy = class;
  TPressStructure = class;

  TPressItemMemento = class(TPressAttributeMemento)
  private
    FOldIndex: Integer;
    FOwnerList: TPressItemMementoList;
    FProxy: TPressProxy;
    FProxyClone: TPressProxy;
    FState: TPressItemState;
    FSubjectMemento: TPressObjectMemento;
  protected
    procedure Init; override;
    procedure ItemAdded;
    procedure ItemDeleted(AOldIndex: Integer);
    procedure Modifying; override;
    procedure ReleaseItem;
    procedure Restore; override;
    property OldIndex: Integer read FOldIndex;
    property Proxy: TPressProxy read FProxy;
    property State: TPressItemState read FState;
    property SubjectMemento: TPressObjectMemento read FSubjectMemento;
  public
    constructor Create(AOwner: TPressStructure; AProxy: TPressProxy);
    destructor Destroy; override;
  end;

  TPressItemMementoIterator = class;

  TPressItemMementoList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressItemMemento;
    procedure SetItems(AIndex: Integer; Value: TPressItemMemento);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    function Add(AObject: TPressItemMemento): Integer;
    function AddItem(AOwner: TPressStructure; AProxy: TPressProxy): TPressItemMemento;
    function CreateIterator: TPressItemMementoIterator;
    function Extract(AObject: TPressItemMemento): TPressItemMemento;
    function IndexOf(AObject: TPressItemMemento): Integer;
    function IndexOfProxy(AProxy: TPressProxy): Integer;
    procedure Insert(Index: Integer; AObject: TPressItemMemento);
    function Remove(AObject: TPressItemMemento): Integer;
    property Items[AIndex: Integer]: TPressItemMemento read GetItems write SetItems; default;
  end;

  TPressItemMementoIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressItemMemento;
  public
    property CurrentItem: TPressItemMemento read GetCurrentItem;
  end;

  TPressItems = class;

  TPressItemsMemento = class(TPressAttributeMemento)
  private
    FItems: TPressItemMementoList;
    function GetItems: TPressItemMementoList;
    function GetOwner: TPressItems;
  protected
    procedure Notify(AProxy: TPressProxy; AItemState: TPressItemState; AOldIndex: Integer = -1);
    procedure Restore; override;
    property Items: TPressItemMementoList read GetItems;
    property Owner: TPressItems read GetOwner;
  public
    constructor Create(AOwner: TPressItems);
    destructor Destroy; override;
  end;

  TPressItemsMementoIterator = class;

  TPressItemsMementoList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressItemsMemento;
    procedure SetItems(AIndex: Integer; Value: TPressItemsMemento);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressItemsMemento): Integer;
    function CreateIterator: TPressItemsMementoIterator;
    function Extract(AObject: TPressItemsMemento): TPressItemsMemento;
    function IndexOf(AObject: TPressItemsMemento): Integer;
    procedure Insert(Index: Integer; AObject: TPressItemsMemento);
    function Remove(AObject: TPressItemsMemento): Integer;
    property Items[AIndex: Integer]: TPressItemsMemento read GetItems write SetItems; default;
  end;

  TPressItemsMementoIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressItemsMemento;
  public
    property CurrentItem: TPressItemsMemento read GetCurrentItem;
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

  TPressString = class;
  TPressAttributeList = class;
  TPressAttributeIterator = class;

  TPressObject = class(TPressSubject)
    _Id: TPressString;
  private
    FAttributes: TPressAttributeList;
    FDisableChangesCount: Integer;
    FIsChanged: Boolean;
    FMementos: TPressObjectMementoList;
    FMetadata: TPressObjectMetadata;
    FOwnerAttribute: TPressStructure;
    FPersistentId: string;
    FPersistentObject: TObject;
    procedure ClearOwnerContext;
    procedure CreateAttributes;
    function GetAttributes(AIndex: Integer): TPressAttribute;
    function GetChangesDisabled: Boolean;
    function GetId: string;
    function GetIsOwned: Boolean;
    function GetIsPersistent: Boolean;
    function GetIsUpdated: Boolean;
    function GetIsValid: Boolean;
    function GetMementos: TPressObjectMementoList;
    function GetMetadata: TPressObjectMetadata;
    function GetPersistentName: string;
    procedure NotifyChange;
    procedure NotifyInvalidate;
    procedure NotifyMementos(AAttribute: TPressAttribute);
    procedure NotifyUnchange;
    procedure SetId(const Value: string);
    procedure SetPersistentObject(Value: TObject);
    procedure SetOwnerContext(AOwner: TPressStructure);
    procedure UnchangeAttributes;
    property Mementos: TPressObjectMementoList read GetMementos;
  protected
    procedure Finit; override;
    procedure Init;
  protected
    procedure AfterCreateAttributes; virtual;
    procedure BeforeCreateAttributes; virtual;
    procedure Finalize; virtual;
    procedure Initialize; virtual;
    procedure InternalDispose; virtual;
    function InternalIsValid: Boolean; virtual;
    procedure InternalSave; virtual;
  public
    constructor Create(AMetadata: TPressObjectMetadata = nil);
    constructor Retrieve(const AId: string; AMetadata: TPressObjectMetadata = nil);
    procedure Assign(Source: TPersistent); override;
    function AttributeAddress(const AAttributeName: string): PPressAttribute;
    function AttributeByName(const AAttributeName: string): TPressAttribute;
    function AttributeByPath(const APath: string): TPressAttribute;
    function AttributeCount: Integer;
    procedure Changed(AAttribute: TPressAttribute);
    procedure Changing(AAttribute: TPressAttribute);
    class function ClassMetadata: TPressObjectMetadata;
    function ClassType: TPressObjectClass;
    function Clone: TPressObject;
    function CreateAttributeIterator: TPressAttributeIterator;
    function CreateMemento: TPressObjectMemento;
    procedure DisableChanges;
    procedure Dispose;
    procedure EnableChanges;
    function FindAttribute(const AAttributeName: string): TPressAttribute;
    function FindPathAttribute(const APath: string): TPressAttribute;
    class procedure RegisterClass;
    procedure Save;
    procedure Unchanged;
    property Attributes[AIndex: Integer]: TPressAttribute read GetAttributes;
    property ChangesDisabled: Boolean read GetChangesDisabled;
    property IsChanged: Boolean read FIsChanged;
    property IsOwned: Boolean read GetIsOwned;
    property IsPersistent: Boolean read GetIsPersistent;
    property IsUpdated: Boolean read GetIsUpdated;
    property IsValid: Boolean read GetIsValid;
    property Metadata: TPressObjectMetadata read GetMetadata;
    property OwnerAttribute: TPressStructure read FOwnerAttribute;
    property PersistentId: string read FPersistentId;
    property PersistentName: string read GetPersistentName;
    property PersistentObject: TObject read FPersistentObject write SetPersistentObject;
  published
    property Id: string read GetId write SetId;
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
    function GetItems(AIndex: Integer): TPressProxy;
    function GetNotificationDisabled: Boolean;
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
   attMemo, attPicture, attPart, attReference, attParts, attReferences);

  TPressAttribute = class(TPressSubject)
  private
    FIsChanged: Boolean;
    FIsNull: Boolean;
    FMetadata: TPressAttributeMetadata;
    FOwner: TPressObject;
    function CreateMemento: TPressAttributeMemento;
    function GetChangesDisabled: Boolean;
    function GetDefaultValue: string;
    function GetEditMask: string;
    function GetName: string;
    function GetPersistentName: string;
    procedure NotifyChange;
    procedure NotifyInvalidate;
    procedure NotifyUnchange;
    procedure SetIsChanged(AValue: Boolean);
  protected
    function AccessError(const AAttributeName: string): EPressError;
    { TODO : Use exception messages from the PressDialog class }
    function ConversionError(E: EConvertError): EPressConversionError;
    procedure Changing;
    function InvalidClassError(const AClassName: string): EPressError;
    function InvalidValueError(AValue: Variant; E: EVariantError): EPressError;
    { TODO : Review the need of As<Type> methods }
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
  public
    constructor Create(AOwner: TPressObject; AMetadata: TPressAttributeMetadata); virtual;
    class function AttributeBaseType: TPressAttributeBaseType; virtual; abstract;
    class function AttributeName: string; virtual; abstract;
    procedure Changed;
    function ClassType: TPressAttributeClass;
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
    property IsChanged: Boolean read FIsChanged write SetIsChanged;
    property IsEmpty: Boolean read GetIsEmpty;
    property IsNull: Boolean read FIsNull;
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

  { Value attributes declarations }

  TPressValue = class(TPressAttribute)
  protected
    function GetSignature: string; override;
    function InternalCreateMemento: TPressAttributeMemento; override;
  end;

  TPressString = class(TPressValue)
  private
    FValue: string;
  protected
    function GetAsBoolean: Boolean; override;
    function GetAsDate: TDate; override;
    function GetAsDateTime: TDateTime; override;
    function GetAsFloat: Double; override;
    function GetAsInteger: Integer; override;
    function GetAsString: string; override;
    function GetAsTime: TTime; override;
    function GetAsVariant: Variant; override;
    function GetIsEmpty: Boolean; override;
    function GetValue: string; virtual;
    procedure SetAsBoolean(AValue: Boolean); override;
    procedure SetAsDate(AValue: TDate); override;
    procedure SetAsDateTime(AValue: TDateTime); override;
    procedure SetAsFloat(AValue: Double); override;
    procedure SetAsInteger(AValue: Integer); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetAsTime(AValue: TTime); override;
    procedure SetAsVariant(AValue: Variant); override;
    procedure SetValue(const AValue: string); virtual;
  public
    procedure Assign(Source: TPersistent); override;
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
    procedure Reset; override;
    property Value: string read GetValue write SetValue;
  end;

  TPressNumeric = class(TPressValue)
  protected
    function GetAsBoolean: Boolean; override;
    function GetAsDate: TDate; override;
    function GetAsDateTime: TDateTime; override;
    function GetAsTime: TTime; override;
    function GetDisplayText: string; override;
    procedure SetAsBoolean(AValue: Boolean); override;
    procedure SetAsDate(AValue: TDate); override;
    procedure SetAsDateTime(AValue: TDateTime); override;
    procedure SetAsTime(AValue: TTime); override;
  end;

  TPressInteger = class(TPressNumeric)
  private
    FValue: Integer;
  protected
    function GetAsFloat: Double; override;
    function GetAsInteger: Integer; override;
    function GetAsString: string; override;
    function GetAsVariant: Variant; override;
    function GetIsEmpty: Boolean; override;
    function GetValue: Integer; virtual;
    procedure SetAsFloat(AValue: Double); override;
    procedure SetAsInteger(AValue: Integer); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetAsVariant(AValue: Variant); override;
    procedure SetValue(AValue: Integer); virtual;
  public
    procedure Assign(Source: TPersistent); override;
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
    procedure Reset; override;
    property Value: Integer read GetValue write SetValue;
  end;

  TPressFloat = class(TPressNumeric)
  private
    FValue: Double;
  protected
    function GetAsFloat: Double; override;
    function GetAsInteger: Integer; override;
    function GetAsString: string; override;
    function GetAsVariant: Variant; override;
    function GetIsEmpty: Boolean; override;
    function GetValue: Double; virtual;
    procedure SetAsFloat(AValue: Double); override;
    procedure SetAsInteger(AValue: Integer); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetAsVariant(AValue: Variant); override;
    procedure SetValue(AValue: Double); virtual;
  public
    procedure Assign(Source: TPersistent); override;
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
    procedure Reset; override;
    property Value: Double read GetValue write SetValue;
  end;

  TPressCurrency = class(TPressNumeric)
  private
    FValue: Currency;
  protected
    function GetAsCurrency: Currency; override;
    function GetAsFloat: Double; override;
    function GetAsInteger: Integer; override;
    function GetAsString: string; override;
    function GetAsVariant: Variant; override;
    function GetIsEmpty: Boolean; override;
    function GetDisplayText: string; override;
    function GetValue: Currency; virtual;
    procedure SetAsCurrency(AValue: Currency); override;
    procedure SetAsFloat(AValue: Double); override;
    procedure SetAsInteger(AValue: Integer); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetAsVariant(AValue: Variant); override;
    procedure SetValue(AValue: Currency); virtual;
  public
    procedure Assign(Source: TPersistent); override;
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
    procedure Reset; override;
    property Value: Currency read GetValue write SetValue;
  end;

  TPressEnum = class(TPressValue)
  private
    FValue: Byte;
  protected
    function GetAsBoolean: Boolean; override;
    function GetAsDate: TDate; override;
    function GetAsDateTime: TDateTime; override;
    function GetAsFloat: Double; override;
    function GetAsInteger: Integer; override;
    function GetAsString: string; override;
    function GetAsTime: TTime; override;
    function GetAsVariant: Variant; override;
    function GetIsEmpty: Boolean; override;
    function GetValue: Byte; virtual;
    procedure SetAsBoolean(AValue: Boolean); override;
    procedure SetAsDate(AValue: TDate); override;
    procedure SetAsDateTime(AValue: TDateTime); override;
    procedure SetAsFloat(AValue: Double); override;
    procedure SetAsInteger(AValue: Integer); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetAsTime(AValue: TTime); override;
    procedure SetAsVariant(AValue: Variant); override;
    procedure SetValue(AValue: Byte); virtual;
  public
    procedure Assign(Source: TPersistent); override;
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
    procedure Reset; override;
    property Value: Byte read GetValue write SetValue;
  end;

  TPressBoolean = class(TPressValue)
  private
    FValue: Boolean;
    FValues: array[Boolean] of string;
  protected
    function GetAsBoolean: Boolean; override;
    function GetAsFloat: Double; override;
    function GetAsInteger: Integer; override;
    function GetAsString: string; override;
    function GetAsVariant: Variant; override;
    function GetDisplayText: string; override;
    function GetValue: Boolean; virtual;
    procedure Initialize; override;
    procedure SetAsBoolean(AValue: Boolean); override;
    procedure SetAsFloat(AValue: Double); override;
    procedure SetAsInteger(AValue: Integer); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetAsVariant(AValue: Variant); override;
    procedure SetValue(AValue: Boolean); virtual;
  public
    procedure Assign(Source: TPersistent); override;
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
    procedure Reset; override;
    property Value: Boolean read GetValue write SetValue;
  end;

  TPressDate = class(TPressValue)
  private
    FValue: TDate;
  protected
    function GetAsDate: TDate; override;
    function GetAsDateTime: TDateTime; override;
    function GetAsFloat: Double; override;
    function GetAsString: string; override;
    function GetAsTime: TTime; override;
    function GetAsVariant: Variant; override;
    function GetDisplayText: string; override;
    function GetValue: TDate; virtual;
    procedure Initialize; override;
    procedure SetAsDate(AValue: TDate); override;
    procedure SetAsDateTime(AValue: TDateTime); override;
    procedure SetAsFloat(AValue: Double); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetAsTime(AValue: TTime); override;
    procedure SetAsVariant(AValue: Variant); override;
    procedure SetValue(AValue: TDate); virtual;
  public
    procedure Assign(Source: TPersistent); override;
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
    procedure Reset; override;
    property Value: TDate read GetValue write SetValue;
  end;

  TPressTime = class(TPressValue)
  private
    FValue: TTime;
  protected
    function GetAsDate: TDate; override;
    function GetAsDateTime: TDateTime; override;
    function GetAsFloat: Double; override;
    function GetAsString: string; override;
    function GetAsTime: TTime; override;
    function GetAsVariant: Variant; override;
    function GetDisplayText: string; override;
    function GetValue: TTime; virtual;
    procedure Initialize; override;
    procedure SetAsDate(AValue: TDate); override;
    procedure SetAsDateTime(AValue: TDateTime); override;
    procedure SetAsFloat(AValue: Double); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetAsTime(AValue: TTime); override;
    procedure SetAsVariant(AValue: Variant); override;
    procedure SetValue(AValue: TTime); virtual;
  public
    procedure Assign(Source: TPersistent); override;
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
    procedure Reset; override;
    property Value: TTime read GetValue write SetValue;
  end;

  TPressDateTime = class(TPressValue)
  private
    FValue: TDateTime;
  protected
    function GetAsDate: TDate; override;
    function GetAsDateTime: TDateTime; override;
    function GetAsFloat: Double; override;
    function GetAsString: string; override;
    function GetAsTime: TTime; override;
    function GetAsVariant: Variant; override;
    function GetDisplayText: string; override;
    function GetValue: TDateTime; virtual;
    procedure Initialize; override;
    procedure SetAsDate(AValue: TDate); override;
    procedure SetAsDateTime(AValue: TDateTime); override;
    procedure SetAsFloat(AValue: Double); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetAsTime(AValue: TTime); override;
    procedure SetAsVariant(AValue: Variant); override;
    procedure SetValue(AValue: TDateTime); virtual;
  public
    procedure Assign(Source: TPersistent); override;
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
    procedure Reset; override;
    property Value: TDateTime read GetValue write SetValue;
  end;

  TPressVariant = class(TPressValue)
  private
    FValue: Variant;
  protected
    function GetAsBoolean: Boolean; override;
    function GetAsDate: TDate; override;
    function GetAsDateTime: TDateTime; override;
    function GetAsFloat: Double; override;
    function GetAsInteger: Integer; override;
    function GetAsString: string; override;
    function GetAsTime: TTime; override;
    function GetAsVariant: Variant; override;
    function GetValue: Variant; virtual;
    procedure SetAsBoolean(AValue: Boolean); override;
    procedure SetAsDate(AValue: TDate); override;
    procedure SetAsDateTime(AValue: TDateTime); override;
    procedure SetAsFloat(AValue: Double); override;
    procedure SetAsInteger(AValue: Integer); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetAsTime(AValue: TTime); override;
    procedure SetAsVariant(AValue: Variant); override;
    procedure SetValue(AValue: Variant); virtual;
  public
    procedure Assign(Source: TPersistent); override;
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
    procedure Reset; override;
    property Value: Variant read GetValue write SetValue;
  end;

  TPressBlob = class(TPressValue)
  private
    FStream: TMemoryStream;
    function GetStream: TMemoryStream;
    function GetValue: string;
    procedure SetValue(const AValue: string);
  protected
    procedure Finit; override;
    function GetAsString: string; override;
    function GetAsVariant: Variant; override;
    procedure SetAsString(const AValue: string); override;
    procedure SetAsVariant(AValue: Variant); override;
    property Stream: TMemoryStream read GetStream;
  public
    procedure Assign(Source: TPersistent); override;
    procedure ClearBuffer;
    procedure LoadFromStream(AStream: TStream);
    procedure Reset; override;
    procedure SaveToStream(AStream: TStream);
    function WriteBuffer(const ABuffer; ACount: Integer): Boolean;
    property Value: string read GetValue write SetValue;
  end;

  TPressMemo = class(TPressBlob)
  public
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
  end;

  TPressPicture = class(TPressBlob)
  private
    function GetHasPicture: Boolean;
  public
    procedure AssignPicture(APicture: TPicture);
    procedure AssignPictureFromFile(const AFileName: string);
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
    procedure ClearPicture;
    property HasPicture: Boolean read GetHasPicture;
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

  TPressStructure = class(TPressAttribute)
  private
    FNotifier: TPressNotifier;
    function GetObjectClass: TPressObjectClass;
    procedure Notify(AEvent: TPressEvent);
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
    procedure Finit; override;
    procedure InternalAssignItem(AProxy: TPressProxy); virtual; abstract;
    procedure InternalAssignObject(AObject: TPressObject); virtual; abstract;
    procedure InternalUnassignObject(AObject: TPressObject); virtual; abstract;
    procedure NotifyReferenceChange;
    procedure ReleaseInstance(AInstance: TPressObject); virtual;
    procedure ValidateObject(AObject: TPressObject);
    procedure ValidateObjectClass(AClass: TPressObjectClass); overload;
    procedure ValidateObjectClass(const AClassName: string); overload;
    procedure ValidateProxy(AProxy: TPressProxy);
  public
    constructor Create(AOwner: TPressObject; AMetadata: TPressAttributeMetadata); override;
    procedure AssignItem(AProxy: TPressProxy);
    procedure AssignObject(AObject: TPressObject);
    procedure UnassignObject(AObject: TPressObject);
    property ObjectClass: TPressObjectClass read GetObjectClass;
  end;

  TPressItem = class(TPressStructure)
  private
    FProxy: TPressProxy;
    function GetObjectClassName: string;
    function GetObjectId: string;
    function GetProxy: TPressProxy;
    function GetValue: TPressObject;
    procedure SetValue(Value: TPressObject);
  protected
    function CreateProxy: TPressProxy; virtual; abstract;
    procedure Finit; override;
    function GetIsEmpty: Boolean; override;
    function GetSignature: string; override;
    procedure InternalAssignObject(AObject: TPressObject); override;
    function InternalCreateMemento: TPressAttributeMemento; override;
    procedure InternalUnassignObject(AObject: TPressObject); override;
    property Proxy: TPressProxy read GetProxy;
  public
    procedure Assign(Source: TPersistent); override;
    procedure AssignReference(const AClassName, AId: string);
    function HasInstance: Boolean;
    property ObjectClassName: string read GetObjectClassName;
    property ObjectId: string read GetObjectId;
    property Value: TPressObject read GetValue write SetValue;
  end;

  TPressPart = class(TPressItem)
  protected
    procedure AfterChangeItem(AItem: TPressObject); override;
    procedure BeforeChangeInstance(Sender: TPressProxy; Instance: TPressObject; ChangeType: TPressProxyChangeType); override;
    procedure BeforeChangeItem(AItem: TPressObject); override;
    procedure BeforeRetrieveInstance(Sender: TPressProxy); override;
    procedure BindInstance(AInstance: TPressObject); override;
    function CreateProxy: TPressProxy; override;
    procedure InternalAssignItem(AProxy: TPressProxy); override;
    procedure ReleaseInstance(AInstance: TPressObject); override;
  public
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
  end;

  TPressReference = class(TPressItem)
  protected
    procedure AfterChangeItem(AItem: TPressObject); override;
    function CreateProxy: TPressProxy; override;
    procedure InternalAssignItem(AProxy: TPressProxy); override;
  public
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
  end;

  TPressItemsEventType =
   (ietAdd, ietInsert, ietModify, ietNotify, ietRemove, ietRebuild, ietClear);

  TPressItemsChangedEvent = class(TPressAttributeChangedEvent)
  private
    FEventType: TPressItemsEventType;
    FIndex: Integer;
    FProxy: TPressProxy;
  public
    constructor Create(AOwner: TObject; AProxy: TPressProxy; AIndex: Integer; AEventType: TPressItemsEventType);
    property EventType: TPressItemsEventType read FEventType;
    property Index: Integer read FIndex;
    property Proxy: TPressProxy read FProxy;
  end;

  TPressItems = class(TPressStructure)
  private
    FMementos: TPressItemsMementoList;
    FProxyDeletedList: TPressProxyList;
    FProxyList: TPressProxyList;
    function GetHasAddedItem: Boolean;
    function GetHasDeletedItem: Boolean;
    function GetMementos: TPressItemsMementoList;
    function GetObjects(AIndex: Integer): TPressObject;
    function GetProxies(AIndex: Integer): TPressProxy;
    function GetProxyDeletedList: TPressProxyList;
    function GetProxyList: TPressProxyList;
    procedure SetObjects(AIndex: Integer; AValue: TPressObject);
  protected
    procedure AfterChangeInstance(Sender: TPressProxy; Instance: TPressObject; ChangeType: TPressProxyChangeType); override;
    procedure ChangedItem(AItem: TPressObject; ASubjectChanged: Boolean = True);
    procedure ChangedList(Sender: TPressProxyList; Item: TPressProxy; Action: TListNotification);
    procedure Finit; override;
    function GetIsEmpty: Boolean; override;
    procedure InternalAssignObject(AObject: TPressObject); override;
    function InternalCreateMemento: TPressAttributeMemento; override;
    function InternalCreateProxyList: TPressProxyList; virtual; abstract;
    procedure InternalUnassignObject(AObject: TPressObject); override;
    procedure NotifyMementos(AProxy: TPressProxy; AItemState: TPressItemState; AOldIndex: Integer = -1);
    procedure NotifyRebuild;
    property Mementos: TPressItemsMementoList read GetMementos;
    property ProxyDeletedList: TPressProxyList read GetProxyDeletedList;
    property ProxyList: TPressProxyList read GetProxyList;
  public
    function Add(AObject: TPressObject; AShareInstance: Boolean = True): Integer;
    function AddReference(const AClassName, AId: string): Integer;
    procedure Assign(Source: TPersistent); override;
    procedure AssignProxyList(AProxyList: TPressProxyList);
    procedure Clear;
    function Count: Integer;
    function CreateIterator: TPressProxyIterator;
    procedure Delete(AIndex: Integer);
    function IndexOf(AObject: TPressObject): Integer;
    procedure Insert(AIndex: Integer; AObject: TPressObject; AShareInstance: Boolean = True);
    function Remove(AObject: TPressObject): Integer;
    property HasAddedItem: Boolean read GetHasAddedItem;
    property HasDeletedItem: Boolean read GetHasDeletedItem;
    property Objects[AIndex: Integer]: TPressObject read GetObjects write SetObjects; default;
    property Proxies[AIndex: Integer]: TPressProxy read GetProxies;
  end;

  TPressParts = class(TPressItems)
  protected
    procedure AfterChangeItem(AItem: TPressObject); override;
    procedure BeforeChangeInstance(Sender: TPressProxy; Instance: TPressObject; ChangeType: TPressProxyChangeType); override;
    procedure BeforeChangeItem(AItem: TPressObject); override;
    procedure BeforeRetrieveInstance(Sender: TPressProxy); override;
    procedure BindInstance(AInstance: TPressObject); override;
    procedure InternalAssignItem(AProxy: TPressProxy); override;
    function InternalCreateProxyList: TPressProxyList; override;
    procedure ReleaseInstance(AInstance: TPressObject); override;
  public
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
  end;

  TPressReferences = class(TPressItems)
  protected
    procedure AfterChangeItem(AItem: TPressObject); override;
    procedure InternalAssignItem(AProxy: TPressProxy); override;
    function InternalCreateProxyList: TPressProxyList; override;
  public
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
  end;

procedure PressAssignPersistentId(AObject: TPressObject; const AId: string);
function PressFindAttributeClass(const AAttributeName: string): TPressAttributeClass;
function PressFindObject(const AClass, AId: string): TPressObject;
function PressFindObjectClass(const AClassName: string): TPressObjectClass;
function PressObjectClassByName(const AClassName: string): TPressObjectClass;
function PressObjectClassByPersistentName(const APersistentName: string): TPressObjectClass;
function PressRegisterMetadata(const AMetadataStr: string): TPressObjectMetadata;
procedure PressUnregisterMetadata(AMetadata: TPressObjectMetadata);
function PressRegisterEnumMetadata(AEnumAddress: Pointer; const AEnumName: string): TPressEnumMetadata;
function PressEnumMetadataByName(const AEnumName: string): TPressEnumMetadata;

{$ENDIF}

implementation

{$IFNDEF USE_INSTANTOBJECTS}

uses
  TypInfo,
  Contnrs,
  PressConsts,
  {$IFDEF PressLog}PressLog,{$ENDIF}
  PressMetadata,
  PressPersistence;

var
  _PressRegisteredObjectClasses: TClassList;
  _PressRegisteredAttributes: TClassList;
  _PressSingletonIDs: TStrings;
  _PressObjectMetadatas: TPressObjectMetadataList;
  _PressEnumMetadatas: TPressEnumMetadataList;
  _PressObjectStore: TPressObjectStore;

function PressRegisteredClasses: TClassList;
begin
  if not Assigned(_PressRegisteredObjectClasses) then
  begin
    _PressRegisteredObjectClasses := TClassList.Create;
    PressRegisterSingleObject(_PressRegisteredObjectClasses);
  end;
  Result := _PressRegisteredObjectClasses;
end;

function PressRegisteredAttributes: TClassList;
begin
  if not Assigned(_PressRegisteredAttributes) then
  begin
    _PressRegisteredAttributes := TClassList.Create;
    PressRegisterSingleObject(_PressRegisteredAttributes);
  end;
  Result := _PressRegisteredAttributes;
end;

function PressSingletonIDs: TStrings;
begin
  if not Assigned(_PressSingletonIDs) then
  begin
    _PressSingletonIDs := TStringList.Create;
    PressRegisterSingleObject(_PressSingletonIDs);
  end;
  Result := _PressSingletonIDs;
end;

function PressObjectMetadatas: TPressObjectMetadataList;
begin
  if not Assigned(_PressObjectMetadatas) then
  begin
    _PressObjectMetadatas := TPressObjectMetadataList.Create(True);
    PressRegisterSingleObject(_PressObjectMetadatas);
  end;
  Result := _PressObjectMetadatas;
end;

function PressEnumMetadatas: TPressEnumMetadataList;
begin
  if not Assigned(_PressEnumMetadatas) then
  begin
    _PressEnumMetadatas := TPressEnumMetadataList.Create(True);
    PressRegisterSingleObject(PressEnumMetadatas);
  end;
  Result := _PressEnumMetadatas;
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

procedure PressAssignPersistentId(AObject: TPressObject; const AId: string);
begin
  AObject.FPersistentId := AId;  // friend class
  AObject._Id.FValue := AId;  // friend class
end;

function PressFindAttributeClass(const AAttributeName: string): TPressAttributeClass;
var
  I: Integer;
begin
  for I := 0 to Pred(PressRegisteredAttributes.Count) do
  begin
    Result := TPressAttributeClass(PressRegisteredAttributes[I]);
    if Result.AttributeName = AAttributeName then
      Exit;
  end;
  Result := nil;
end;

function PressFindObject(const AClass, AId: string): TPressObject;
begin
  Result := PressObjectStore.FindObject(AClass, AId);
end;

function PressFindObjectClass(const AClassName: string): TPressObjectClass;
var
  I: Integer;
begin
  if AClassName = TPressObject.ClassName then
    Result := TPressObject
  else
  begin
    for I := 0 to Pred(PressRegisteredClasses.Count) do
    begin
      Result := TPressObjectClass(PressRegisteredClasses[I]);
      if Result.ClassName = AClassName then
        Exit;
    end;
    Result := nil;
  end;
end;

function PressObjectClassByName(const AClassName: string): TPressObjectClass;
begin
  Result := PressFindObjectClass(AClassName);
  if not Assigned(Result) then
    raise EPressError.CreateFmt(SClassNotFound, [AClassName]);
end;

function PressObjectClassByPersistentName(
  const APersistentName: string): TPressObjectClass;
var
  I: Integer;
begin
  if Assigned(_PressObjectMetadatas) then
    for I := 0 to Pred(_PressObjectMetadatas.Count) do
      with _PressObjectMetadatas[I] do
        if PersistentName = APersistentName then
        begin
          Result := ObjectClass;
          Exit;
        end;
  raise EPressError.CreateFmt(SPersistentClassNotFound, [APersistentName]);
end;

function PressRegisterMetadata(const AMetadataStr: string): TPressObjectMetadata;
var
  VCodeMetadata: TPressCodeMetadata;
  VCodeReader: TPressCodeReader;
  VStream: TMemoryStream;
begin
  { TODO : Improve (remove TStream instance) }
  Result := nil;
  VStream := TMemoryStream.Create;
  if AMetadataStr <> '' then
    VStream.Write(AMetadataStr[1], Length(AMetadataStr));
  VCodeReader := TPressCodeReader.Create(VStream);
  VCodeMetadata := TPressCodeMetadata.Create(nil);
  try
    try
      VCodeMetadata.Read(VCodeReader);
      Result := VCodeMetadata.Metadata;
    except
      on E: EPressParseError do
        raise EPressError.CreateFmt(SMetadataParseError,
         [E.Line, E.Column, E.Message, AMetadataStr]);
      else
        raise;
    end;
  finally
    VCodeMetadata.Free;
    VCodeReader.Free;
    VStream.Free;
  end;
end;

procedure PressUnregisterMetadata(AMetadata: TPressObjectMetadata);
var
  I: Integer;
begin
  if Assigned(AMetadata) then
    for I := Pred(PressObjectMetadatas.Count) downto 0 do
      if PressObjectMetadatas[I] = AMetadata then
      begin
        PressObjectMetadatas.Delete(I);
        Exit;
      end;
end;

function PressRegisterEnumMetadata(
  AEnumAddress: Pointer; const AEnumName: string): TPressEnumMetadata;
begin
  Result := TPressEnumMetadata.Create(AEnumAddress);
  Result.Name := AEnumName;
  PressEnumMetadatas.Add(Result);
end;

function PressEnumMetadataByName(const AEnumName: string): TPressEnumMetadata;
var
  I: Integer;
begin
  for I := 0 to Pred(PressEnumMetadatas.Count) do
  begin
    Result := PressEnumMetadatas[I];
    if SameText(Result.Name, AEnumName) then
      Exit;
  end;
  raise EPressError.CreateFmt(SEnumMetadataNotFound, [AEnumName]);
end;

{ TPressEnumMetadata }

constructor TPressEnumMetadata.Create(ATypeAddress: Pointer);
var
  I: Integer;
  TypeData: PTypeData;
begin
  inherited Create;
  FTypeAddress := ATypeAddress;
  TypeData := GetTypeData(FTypeAddress);
  FItems := TStringList.Create;
  for I := TypeData.MinValue to TypeData.MaxValue do
    FItems.Add(RemoveEnumItemPrefix(GetEnumName(ATypeAddress, I)));
end;

destructor TPressEnumMetadata.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TPressEnumMetadata.RemoveEnumItemPrefix(const AEnumName: string): string;
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

{ TPressAttributeMetadata }

constructor TPressAttributeMetadata.Create(AOwner: TPressObjectMetadata);
begin
  inherited Create;
  FObjectClass := TPressObject;
  FOwner := AOwner;
  FOwner.AttributeMetadatas.Add(Self);
end;

function TPressAttributeMetadata.CreateAttribute(
  AOwner: TPressObject): TPressAttribute;
var
  VAttributeClass: TPressAttributeClass;
begin
  VAttributeClass := PressFindAttributeClass(AttributeName);
  if Assigned(VAttributeClass) then
    Result := VAttributeClass.Create(AOwner, Self)
  else
    raise EPressError.CreateFmt(SUnsupportedAttributeType, [AttributeName]);
end;

procedure TPressAttributeMetadata.SetName(const Value: string);
begin
  FName := Value;
  if FPersistentName = '' then
    FPersistentName := FName;
end;

procedure TPressAttributeMetadata.SetObjectClassName(const Value: string);
begin
  FObjectClass := PressObjectClassByName(Value);
  FObjectClassName := Value;
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

{ TPressObjectMetadata }

constructor TPressObjectMetadata.Create(AObjectClass: TPressObjectClass);
begin
  inherited Create;
  FObjectClass := AObjectClass;
  FPersistentName := FObjectClass.ClassName;
  PressObjectMetadatas.Add(Self);
end;

destructor TPressObjectMetadata.Destroy;
begin
  FAttributeMetadatas.Free;
  inherited;
end;

function TPressObjectMetadata.GetAttributeMetadatas: TPressAttributeMetadataList;
begin
  if not Assigned(FAttributeMetadatas) then
    FAttributeMetadatas := TPressAttributeMetadataList.Create(True);
  Result := FAttributeMetadatas;
end;

function TPressObjectMetadata.ParentMetadata: TPressObjectMetadata;
begin
  if ObjectClass = TPressObject then
    Result := nil
  else
    Result := TPressObjectClass(ObjectClass.ClassParent).ClassMetadata;
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
  FOwner.Mementos.Extract(Self);
  FOwner.Free;
  inherited;
end;

function TPressObjectMemento.GetAttributes: TPressAttributeMementoList;
begin
  if not Assigned(FAttributes) then
    FAttributes := TPressAttributeMementoList.Create(True);
  Result := FAttributes;
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

{ TPressValueMemento }

destructor TPressValueMemento.Destroy;
begin
  FAttributeClone.Free;
  inherited;
end;

procedure TPressValueMemento.Modifying;
begin
  inherited;
  FAttributeClone.Free;
  FAttributeClone := Owner.Clone as TPressValue;
end;

procedure TPressValueMemento.Restore;
begin
  { TODO : Workaround, PressItems views doesn't listen attribute events }
//  Owner.DisableChanges;
//  try
    if Assigned(FAttributeClone) then
    begin
      {$IFDEF PressLogSubjectMemento}PressLogMsg(Self, Format('Restoring %s (%s)', [Owner.Signature, FAttributeClone.Signature]));{$ENDIF}
      Owner.Assign(FAttributeClone);
//      Owner.NotifyChange;  // friend class
    end;
//  finally
//    Owner.EnableChanges;
//  end;
  Owner.FIsChanged := FIsChanged;  // friend class
end;

{ TPressItemMemento }

constructor TPressItemMemento.Create(
  AOwner: TPressStructure; AProxy: TPressProxy);
begin
  inherited Create(AOwner);
  FProxy := AProxy;
  FProxy.AddRef;
end;

destructor TPressItemMemento.Destroy;
begin
  FProxy.Free;
  FProxyClone.Free;
  FSubjectMemento.Free;
  inherited;
end;

procedure TPressItemMemento.Init;
begin
  inherited;
  FState := isUnmodified;
end;

procedure TPressItemMemento.ItemAdded;
begin
  {$IFDEF PressLogSubjectMemento}PressLogMsg(Self, 'Adding to ' + Owner.Signature);{$ENDIF}
  FState := isAdded;
end;

procedure TPressItemMemento.ItemDeleted(AOldIndex: Integer);
begin
  {$IFDEF PressLogSubjectMemento}PressLogMsg(Self, 'Deleting from ' + Owner.Signature);{$ENDIF}
  if State = isAdded then
    ReleaseItem
  else
  begin
    FOldIndex := AOldIndex;
    FState := isDeleted;
  end;
end;

procedure TPressItemMemento.Modifying;
begin
  {$IFDEF PressLogSubjectMemento}PressLogMsg(Self, 'Trying to modify item ' + Owner.Signature);{$ENDIF}
  if FState = isUnmodified then
  begin
    inherited;
    FProxyClone.Free;
    FProxyClone := FProxy.Clone;
    FreeAndNil(FSubjectMemento);
    if FProxy.HasInstance and (FProxy.ProxyType = ptOwned) then
      FSubjectMemento := FProxy.Instance.CreateMemento;
    FState := isModified;
  end;
end;

procedure TPressItemMemento.ReleaseItem;
begin
  if Assigned(FOwnerList) then
    FOwnerList.Extract(Self);
  Free;
end;

procedure TPressItemMemento.Restore;

  procedure RestoreAdded;
  begin
    {$IFDEF PressLogSubjectMemento}PressLogMsg(Self, 'Restoring added to ' + Owner.Signature);{$ENDIF}
    (Owner as TPressItems).ProxyList.Remove(FProxy);  // friend class
  end;

  procedure RestoreModified;
  begin
    {$IFDEF PressLogSubjectMemento}PressLogMsg(Self, 'Restoring modified ' + Owner.Signature);{$ENDIF}
    if Assigned(FProxyClone) then
      FProxy.Assign(FProxyClone);
    if Assigned(FSubjectMemento) then
      FSubjectMemento.Restore;
  end;

  procedure RestoreDeleted;
  var
    VProxyList: TPressProxyList;
  begin
    {$IFDEF PressLogSubjectMemento}PressLogMsg(Self, 'Restoring deleted from ' + Owner.Signature);{$ENDIF}
    VProxyList := (Owner as TPressItems).ProxyList;  // friend class
    if (FOldIndex >= 0) and (FOldIndex < VProxyList.Count) then
      VProxyList.Insert(FOldIndex, FProxy)
    else
      VProxyList.Add(FProxy);
    FProxy.AddRef;
  end;

begin
  Owner.DisableChanges;
  try
    case State of
      isUnmodified:
        ;
      isAdded:
        RestoreAdded;
      isModified:
        RestoreModified;
      isDeleted:
        RestoreDeleted;
    end;
  finally
    Owner.EnableChanges;
  end;
  if Owner is TPressItem then
    Owner.FIsChanged := FIsChanged;  // friend class
end;

{ TPressItemMementoList }

function TPressItemMementoList.Add(AObject: TPressItemMemento): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressItemMementoList.AddItem(
  AOwner: TPressStructure; AProxy: TPressProxy): TPressItemMemento;
begin
  Result := TPressItemMemento.Create(AOwner, AProxy);
  try
    Add(Result);
  except
    Result.Free;
    raise;
  end;
end;

function TPressItemMementoList.CreateIterator: TPressItemMementoIterator;
begin
  Result := TPressItemMementoIterator.Create(Self);
end;

function TPressItemMementoList.Extract(
  AObject: TPressItemMemento): TPressItemMemento;
begin
  Result := inherited Extract(AObject) as TPressItemMemento;
end;

function TPressItemMementoList.GetItems(
  AIndex: Integer): TPressItemMemento;
begin
  Result := inherited Items[AIndex] as TPressItemMemento;
end;

function TPressItemMementoList.IndexOf(
  AObject: TPressItemMemento): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

function TPressItemMementoList.IndexOfProxy(AProxy: TPressProxy): Integer;
begin
  for Result := 0 to Pred(Count) do
    if Items[Result].Proxy = AProxy then
      Exit;
  Result := -1;
end;

procedure TPressItemMementoList.Insert(
  Index: Integer; AObject: TPressItemMemento);
begin
  inherited Insert(Index, AObject);
end;

function TPressItemMementoList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

procedure TPressItemMementoList.Notify(
  Ptr: Pointer; Action: TListNotification);
begin
  inherited;
  if Action = lnAdded then
    (TObject(Ptr) as TPressItemMemento).FOwnerList := Self;
end;

function TPressItemMementoList.Remove(AObject: TPressItemMemento): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressItemMementoList.SetItems(
  AIndex: Integer; Value: TPressItemMemento);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressItemMementoIterator }

function TPressItemMementoIterator.GetCurrentItem: TPressItemMemento;
begin
  Result := inherited CurrentItem as TPressItemMemento;
end;

{ TPressItemsMemento }

constructor TPressItemsMemento.Create(AOwner: TPressItems);
begin
  inherited Create(AOwner);
end;

destructor TPressItemsMemento.Destroy;
begin
  Owner.Mementos.Extract(Self);
  FItems.Free;
  inherited;
end;

function TPressItemsMemento.GetItems: TPressItemMementoList;
begin
  if not Assigned(FItems) then
    FItems := TPressItemMementoList.Create(True);
  Result := FItems;
end;

function TPressItemsMemento.GetOwner: TPressItems;
begin
  Result := inherited Owner as TPressItems;
end;

procedure TPressItemsMemento.Notify(
  AProxy: TPressProxy; AItemState: TPressItemState; AOldIndex: Integer);
var
  VIndex: Integer;
  VItem: TPressItemMemento;
begin
  {$IFDEF PressLogSubjectMemento}PressLogMsg(Self, 'Notifying ' + Owner.Signature);{$ENDIF}
  VIndex := Items.IndexOfProxy(AProxy);
  if VIndex = -1 then
    VItem := Items.AddItem(Owner, AProxy)
  else
    VItem := Items[VIndex];
  case AItemState of
    isAdded:
      VItem.ItemAdded;
    isModified:
      VItem.Modifying;
    isDeleted:
      VItem.ItemDeleted(AOldIndex);
  end;
end;

procedure TPressItemsMemento.Restore;
var
  I: Integer;
begin
  {$IFDEF PressLogSubjectMemento}PressLogMsg(Self, 'Restoring ' + Owner.Signature);{$ENDIF}
  Owner.DisableChanges;
  try
    if Assigned(FItems) then
      for I := Pred(FItems.Count) downto 0 do
        FItems[I].Restore;
  finally
    Owner.EnableChanges;
  end;
  Owner.FIsChanged := FIsChanged;  // friend class
  Owner.NotifyRebuild;  // friend class
end;

{ TPressItemsMementoList }

function TPressItemsMementoList.Add(AObject: TPressItemsMemento): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressItemsMementoList.CreateIterator: TPressItemsMementoIterator;
begin
  Result := TPressItemsMementoIterator.Create(Self);
end;

function TPressItemsMementoList.Extract(
  AObject: TPressItemsMemento): TPressItemsMemento;
begin
  Result := inherited Extract(AObject) as TPressItemsMemento;
end;

function TPressItemsMementoList.GetItems(
  AIndex: Integer): TPressItemsMemento;
begin
  Result := inherited Items[AIndex] as TPressItemsMemento;
end;

function TPressItemsMementoList.IndexOf(
  AObject: TPressItemsMemento): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressItemsMementoList.Insert(
  Index: Integer; AObject: TPressItemsMemento);
begin
  inherited Insert(Index, AObject);
end;

function TPressItemsMementoList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressItemsMementoList.Remove(
  AObject: TPressItemsMemento): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressItemsMementoList.SetItems(
  AIndex: Integer; Value: TPressItemsMemento);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressItemsMementoIterator }

function TPressItemsMementoIterator.GetCurrentItem: TPressItemsMemento;
begin
  Result := inherited CurrentItem as TPressItemsMemento;
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
  Inc(FRefCount);
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
  Dec(FRefCount);
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

function TPressObject.AttributeAddress(const AAttributeName: string): PPressAttribute;
begin
  Result := FieldAddress(SPressAttributePrefix + AAttributeName);
end;

function TPressObject.AttributeByName(const AAttributeName: string): TPressAttribute;
begin
  Result := FindAttribute(AAttributeName);
  if not Assigned(Result) then
    raise EPressError.CreateFmt(SAttributeNotFound, [ClassName, AAttributeName]);
end;

function TPressObject.AttributeByPath(const APath: string): TPressAttribute;
begin
  Result := FindPathAttribute(APath);
  if not Assigned(Result) then
    raise EPressError.CreateFmt(SAttributeNotFound, [ClassName, APath]);
end;

function TPressObject.AttributeCount: Integer;
begin
  Result := FAttributes.Count;
end;

procedure TPressObject.BeforeCreateAttributes;
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
  if ChangesDisabled then
    Exit;
  if Assigned(FOwnerAttribute) then
    FOwnerAttribute.BeforeChangeItem(Self);  // friend class
  NotifyMementos(AAttribute);
end;

class function TPressObject.ClassMetadata: TPressObjectMetadata;
var
  VTargetClass: TPressObjectClass;
  I: Integer;
begin
  VTargetClass := Self;
  while Assigned(VTargetClass) do
  begin
    for I := 0 to Pred(PressObjectMetadatas.Count) do
    begin
      Result := TPressObjectMetadata(PressObjectMetadatas[I]);
      if Result.ObjectClass = VTargetClass then
        Exit;
    end;
    if VTargetClass <> TPressObject then
      VTargetClass := TPressObjectClass(VTargetClass.ClassParent)
    else
      VTargetClass := nil;
  end;
  raise EPressError.CreateFmt(SMetadataNotFound, [ClassName]);
end;

function TPressObject.ClassType: TPressObjectClass;
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

  procedure CreateMetadataAttributes(AMetadata: TPressObjectMetadata);
  var
    VAttribute: PPressAttribute;
  begin
    if not Assigned(AMetadata) then
      Exit;
    CreateMetadataAttributes(AMetadata.ParentMetadata);
    with AMetadata.AttributeMetadatas.CreateIterator do
    try
      while not IsDone do
      begin
        VAttribute := AttributeAddress(CurrentItem.Name);
        if Assigned(VAttribute) then
        begin
          if not Assigned(VAttribute^) then
          begin
            VAttribute^ := CurrentItem.CreateAttribute(Self);
            FAttributes.Add(VAttribute^);
          end;
        end else
          raise EPressError.CreateFmt(SAttributeNotFound,
           [AMetadata.ObjectClass.ClassName, CurrentItem.Name]);
        Next;
      end;
    finally
      Free;
    end;
  end;

begin
  { TODO : Use a map to instantiate inherited attributes }
  BeforeCreateAttributes;
  CreateMetadataAttributes(Metadata);
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

procedure TPressObject.Dispose;
begin
  InternalDispose;
end;

procedure TPressObject.EnableChanges;
begin
  if FDisableChangesCount > 0 then
    Dec(FDisableChangesCount);
end;

procedure TPressObject.Finalize;
begin
end;

function TPressObject.FindAttribute(const AAttributeName: string): TPressAttribute;
var
  VAttribute: PPressAttribute;
begin
  VAttribute := AttributeAddress(AAttributeName);
  if Assigned(VAttribute) then
    Result := VAttribute^
  else
    Result := nil;
end;

function TPressObject.FindPathAttribute(const APath: string): TPressAttribute;
var
  P: Integer;
begin
  if APath = '' then
  begin
    Result := nil;
    Exit;
  end;
  P := Pos(SPressAttributeSeparator, APath);
  if P = 0 then
    Result := AttributeByName(APath)
  else
  begin
    Result := AttributeByName(Copy(APath, 1, P-1));
    if (Result is TPressItem) and Assigned(TPressItem(Result).Value) then
      Result := TPressItem(Result).Value.
       FindPathAttribute(Copy(APath, P+1, Length(APath)))
    else
      Result := nil;
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
  Result := _Id.Value;
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

function TPressObject.GetPersistentName: string;
begin
  Result := Metadata.PersistentName;
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

procedure TPressObject.InternalDispose;
begin
  PressPersistenceBroker.Dispose(Self);
end;

function TPressObject.InternalIsValid: Boolean;
begin
  Result := True;
end;

procedure TPressObject.InternalSave;
begin
  PressPersistenceBroker.Store(Self);
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

class procedure TPressObject.RegisterClass;
begin
  PressRegisteredClasses.Add(Self);
end;

constructor TPressObject.Retrieve(
  const AId: string; AMetadata: TPressObjectMetadata);
var
  VInstance: TPressObject;
begin
  inherited Create;
  VInstance := PressPersistenceBroker.Retrieve(ClassName, AId);
  if Assigned(VInstance) then
  begin
    inherited FreeInstance;
    Self := VInstance;
  end else
  begin
    FMetadata := AMetadata;
    Init;
    _Id.FValue := AId;  // friend class
  end;
end;

procedure TPressObject.Save;
begin
  InternalSave;
end;

procedure TPressObject.SetId(const Value: string);
begin
  _Id.Value := Value;
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
  Self := Retrieve(SingletonOID);
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
    if (Result.Id = AId) and
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
    VInstance := PressPersistenceBroker.Retrieve(FRefClass, FRefID);
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
      Result := AObject.IsPersistent and (AObject.PersistentId = ObjectId) and
       ((ObjectClassName = '') or (SameText(AObject.ClassName, ObjectClassName)))
  else
    Result := IsEmpty;
end;

function TPressProxy.SameReference(
  const ARefClass, ARefID: string): Boolean;
begin
  if HasInstance then
    Result :=
     (FInstance.ClassName = ARefClass) and (FInstance.PersistentId = ARefID)
  else if HasReference then
    Result := (FRefClass = ARefClass) and (FRefID = ARefID)
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
  if not NotificationDisabled and Assigned(FOnChangeList) then
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

procedure TPressAttribute.Changed;
begin
  FIsNull := False;
  IsChanged := True;
end;

procedure TPressAttribute.Changing;
begin
  if Assigned(FOwner) then
    FOwner.Changing(Self);
end;

function TPressAttribute.ClassType: TPressAttributeClass;
begin
  Result := TPressAttributeClass(inherited ClassType);
end;

procedure TPressAttribute.Clear;
begin
  if not FIsNull then
  begin
    FIsNull := True;
    Reset;
  end;
end;

function TPressAttribute.Clone: TPressAttribute;
begin
  Result := ClassType.Create(nil, nil);
  try
    Result.Assign(Self);
  except
    Result.Free;
    raise;
  end;
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
    Clear;
    Initialize;
  finally
    EnableChanges;
  end;
end;

function TPressAttribute.CreateMemento: TPressAttributeMemento;
begin
  Result := InternalCreateMemento;
end;

procedure TPressAttribute.DisableChanges;
begin
  if Assigned(FOwner) then
    FOwner.DisableChanges;
end;

procedure TPressAttribute.EnableChanges;
begin
  if Assigned(FOwner) then
    FOwner.EnableChanges;
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
  if Assigned(FOwner) then
    Result := FOwner.ChangesDisabled
  else
    Result := False;
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

function TPressAttribute.GetIsEmpty: Boolean;
begin
  Result := IsNull;
end;

function TPressAttribute.GetName: string;
begin
  if Assigned(Metadata) then
    Result := Metadata.Name
  else
    Result := '';
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
    AsString := DefaultValue;
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

procedure TPressAttribute.NotifyChange;
begin
  {$IFDEF PressLogSubjectChanges}PressLogMsg(Self, Format('Attribute %s changed', [Signature]));{$ENDIF}
  TPressAttributeChangedEvent.Create(Self).Notify;
end;

procedure TPressAttribute.NotifyInvalidate;
begin
  {$IFDEF PressLogSubjectChanges}PressLogMsg(Self, Format('Attribute %s invalidated', [Signature]));{$ENDIF}
  TPressAttributeChangedEvent.Create(Self).Notify;
end;

procedure TPressAttribute.NotifyUnchange;
begin
  {$IFDEF PressLogSubjectChanges}PressLogMsg(Self, Format('Attribute %s unchanged', [Signature]));{$ENDIF}
end;

class procedure TPressAttribute.RegisterAttribute;
begin
  { TODO : Check duplicated attribute name }
  PressRegisteredAttributes.Add(Self);
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

{ TPressValue }

function TPressValue.GetSignature: string;

  function FormatOwnerName: string;
  begin
    if Assigned(Owner) then
      Result := Owner.ClassName
    else
      Result := TPressObject.ClassName;
  end;

  function FormatValue: string;
  begin
    Result := AsString;
    if Length(Result) > 32 then
    begin
      SetLength(Result, 32);
      FillChar(Result[30], 3, '.');
    end;
  end;

begin
  Result := Format('%s(%s): %s', [FormatOwnerName, Name, FormatValue]);
end;

function TPressValue.InternalCreateMemento: TPressAttributeMemento;
begin
  Result := TPressValueMemento.Create(Self);
end;

{ TPressString }

procedure TPressString.Assign(Source: TPersistent);
begin
  if Source is TPressString then
    Value := TPressString(Source).Value
  else
    inherited;
end;

class function TPressString.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attString;
end;

class function TPressString.AttributeName: string;
begin
  Result := 'String';
end;

function TPressString.GetAsBoolean: Boolean;
begin
  if SameText(Value, SPressTrueString) then
    Result := True
  else if SameText(Value, SPressFalseString) then
    Result := False
  else
    raise ConversionError(nil);
end;

function TPressString.GetAsDate: TDate;
begin
  try
    Result := StrToDate(Value);
  except
    on E: EConvertError do
      raise ConversionError(E);
    else
      raise;
  end;
end;

function TPressString.GetAsDateTime: TDateTime;
begin
  try
    Result := StrToDateTime(Value);
  except
    on E: EConvertError do
      raise ConversionError(E);
    else
      raise;
  end;
end;

function TPressString.GetAsFloat: Double;
begin
  try
    Result := StrToFloat(Value);
  except
    on E: EConvertError do
      raise ConversionError(E);
    else
      raise;
  end;
end;

function TPressString.GetAsInteger: Integer;
begin
  try
    Result := StrToInt(Value);
  except
    on E: EConvertError do
      raise ConversionError(E);
    else
      raise;
  end;
end;

function TPressString.GetAsString: string;
begin
  Result := Value;
end;

function TPressString.GetAsTime: TTime;
begin
  try
    Result := StrToTime(Value);
  except
    on E: EConvertError do
      raise ConversionError(E);
    else
      raise;
  end;
end;

function TPressString.GetAsVariant: Variant;
begin
  Result := Value;
end;

function TPressString.GetIsEmpty: Boolean;
begin
  Result := Value = '';
end;

function TPressString.GetValue: string;
begin
  Result:= FValue;
end;

procedure TPressString.Reset;
begin
  FValue := '';
  IsChanged := True;
end;

procedure TPressString.SetAsBoolean(AValue: Boolean);
begin
  if AValue then
    Value := SPressTrueString
  else
    Value := SPressFalseString;
end;

procedure TPressString.SetAsDate(AValue: TDate);
begin
  Value := DateToStr(AValue);
end;

procedure TPressString.SetAsDateTime(AValue: TDateTime);
begin
  Value := DateTimeToStr(AValue);
end;

procedure TPressString.SetAsFloat(AValue: Double);
begin
  Value := FloatToStr(AValue);
end;

procedure TPressString.SetAsInteger(AValue: Integer);
begin
  Value := IntToStr(AValue);
end;

procedure TPressString.SetAsString(const AValue: string);
begin
  Value := AValue;
end;

procedure TPressString.SetAsTime(AValue: TTime);
begin
  Value := TimeToStr(AValue);
end;

procedure TPressString.SetAsVariant(AValue: Variant);
begin
  try
    Value := AValue;
  except
    on E: EVariantError do
      raise InvalidValueError(AValue, E);
    else
      raise;
  end;
end;

procedure TPressString.SetValue(const AValue: string);
var
  VMaxSize: Integer;
  VOwnerName: string;
begin
  { TODO : removed IsNull check in order to avoid some unwished
    Changed events }
  if {IsNull or} (FValue <> AValue) then
  begin
    if Assigned(Metadata) then
      VMaxSize := Metadata.Size
    else
      VMaxSize := 0;
    if (VMaxSize > 0) and (Length(AValue) > VMaxSize) then
    begin
      if Assigned(Owner) then
        VOwnerName := Owner.ClassName
      else
        VOwnerName := ClassName;
      raise EPressError.CreateFmt(SStringOverflow, [VOwnerName, Name]);
    end;
    Changing;
    FValue := AValue;
    Changed;
  end;
end;

{ TPressNumeric }

function TPressNumeric.GetAsBoolean: Boolean;
begin
  Result := AsInteger <> 0;
end;

function TPressNumeric.GetAsDate: TDate;
begin
  Result := Int(AsFloat);
end;

function TPressNumeric.GetAsDateTime: TDateTime;
begin
  Result := AsFloat;
end;

function TPressNumeric.GetAsTime: TTime;
begin
  Result := Frac(AsFloat);
end;

function TPressNumeric.GetDisplayText: string;
begin
  if IsNull then
    Result := ''
  else if EditMask <> '' then
    Result := FormatFloat(EditMask, AsFloat)
  else
    Result := AsString;
end;

procedure TPressNumeric.SetAsBoolean(AValue: Boolean);
begin
  AsInteger := Integer(AValue);
end;

procedure TPressNumeric.SetAsDate(AValue: TDate);
begin
  AsFloat := Int(AValue);
end;

procedure TPressNumeric.SetAsDateTime(AValue: TDateTime);
begin
  AsFloat := AValue;
end;

procedure TPressNumeric.SetAsTime(AValue: TTime);
begin
  AsFloat := Frac(AValue);
end;

{ TPressInteger }

procedure TPressInteger.Assign(Source: TPersistent);
begin
  if Source is TPressInteger then
    Value := TPressInteger(Source).Value
  else
    inherited;
end;

class function TPressInteger.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attInteger;
end;

class function TPressInteger.AttributeName: string;
begin
  Result := 'Integer';
end;

function TPressInteger.GetAsFloat: Double;
begin
  Result := Value;
end;

function TPressInteger.GetAsInteger: Integer;
begin
  Result := Value;
end;

function TPressInteger.GetAsString: string;
begin
  if IsNull then
    Result := ''
  else
    Result := IntToStr(Value);
end;

function TPressInteger.GetAsVariant: Variant;
begin
  Result := Value;
end;

function TPressInteger.GetIsEmpty: Boolean;
begin
  Result := Value = 0;
end;

function TPressInteger.GetValue: Integer;
begin
  Result := FValue;
end;

procedure TPressInteger.Reset;
begin
  FValue := 0;
  IsChanged := True;
end;

procedure TPressInteger.SetAsFloat(AValue: Double);
begin
  Value := Round(AValue);
end;

procedure TPressInteger.SetAsInteger(AValue: Integer);
begin
  Value := AValue;
end;

procedure TPressInteger.SetAsString(const AValue: string);
begin
  try
    if AValue = '' then
      Clear
    else
      Value := StrToInt(AValue);
  except
    on E: EConvertError do
      raise ConversionError(E);
    else
      raise;
  end;
end;

procedure TPressInteger.SetAsVariant(AValue: Variant);
begin
  try
    Value := AValue;
  except
    on E: EVariantError do
      raise InvalidValueError(AValue, E);
    else
      raise;
  end;
end;

procedure TPressInteger.SetValue(AValue: Integer);
begin
  if IsNull or (AValue <> FValue) then
  begin
    Changing;
    FValue := AValue;
    Changed;
  end;
end;

{ TPressFloat }

procedure TPressFloat.Assign(Source: TPersistent);
begin
  if Source is TPressFloat then
    Value := TPressFloat(Source).Value
  else
    inherited;
end;

class function TPressFloat.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attFloat;
end;

class function TPressFloat.AttributeName: string;
begin
  Result := 'Float';
end;

function TPressFloat.GetAsFloat: Double;
begin
  Result := Value;
end;

function TPressFloat.GetAsInteger: Integer;
begin
  Result := Round(Value);
end;

function TPressFloat.GetAsString: string;
begin
  if IsNull then
    Result := ''
  else
    Result := FloatToStr(Value);
end;

function TPressFloat.GetAsVariant: Variant;
begin
  Result := Value;
end;

function TPressFloat.GetIsEmpty: Boolean;
begin
  Result := Value = 0;
end;

function TPressFloat.GetValue: Double;
begin
  Result := FValue;
end;

procedure TPressFloat.Reset;
begin
  FValue := 0;
  IsChanged := True;
end;

procedure TPressFloat.SetAsFloat(AValue: Double);
begin
  Value := AValue;
end;

procedure TPressFloat.SetAsInteger(AValue: Integer);
begin
  Value := AValue;
end;

procedure TPressFloat.SetAsString(const AValue: string);
begin
  try
    if AValue = '' then
      Clear
    else
      Value := StrToFloat(AValue)
  except
    on E: EConvertError do
      raise ConversionError(E);
    else
      raise;
  end;
end;

procedure TPressFloat.SetAsVariant(AValue: Variant);
begin
  try
    Value := AValue;
  except
    on E: EVariantError do
      raise InvalidValueError(AValue, E);
    else
      raise;
  end;
end;

procedure TPressFloat.SetValue(AValue: Double);
begin
  if IsNull or (AValue <> FValue) then
  begin
    Changing;
    FValue := AValue;
    Changed;
  end;
end;

{ TPressCurrency }

procedure TPressCurrency.Assign(Source: TPersistent);
begin
  if Source is TPressCurrency then
    Value := TPressCurrency(Source).Value
  else
    inherited;
end;

class function TPressCurrency.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attCurrency;
end;

class function TPressCurrency.AttributeName: string;
begin
  Result := 'Currency';
end;

function TPressCurrency.GetAsCurrency: Currency;
begin
  Result := Value;
end;

function TPressCurrency.GetAsFloat: Double;
begin
  Result := Value;
end;

function TPressCurrency.GetAsInteger: Integer;
begin
  Result := Round(Value);
end;

function TPressCurrency.GetAsString: string;
begin
  if IsNull then
    Result := ''
  else
    Result := CurrToStr(Value);
end;

function TPressCurrency.GetAsVariant: Variant;
begin
  Result := Value;
end;

function TPressCurrency.GetDisplayText: string;
begin
  if IsNull then
    Result := ''
  else if EditMask <> '' then
    Result := FormatCurr(EditMask, Value)
  else
    Result := FormatCurr(',0.00', Value)
end;

function TPressCurrency.GetIsEmpty: Boolean;
begin
  Result := Value = 0;
end;

function TPressCurrency.GetValue: Currency;
begin
  Result := FValue;
end;

procedure TPressCurrency.Reset;
begin
  FValue := 0;
  IsChanged := True;
end;

procedure TPressCurrency.SetAsCurrency(AValue: Currency);
begin
  Value := AValue;
end;

procedure TPressCurrency.SetAsFloat(AValue: Double);
begin
  Value := AValue;
end;

procedure TPressCurrency.SetAsInteger(AValue: Integer);
begin
  Value := AValue;
end;

procedure TPressCurrency.SetAsString(const AValue: string);
begin
  try
    if AValue = '' then
      Clear
    else
      Value := StrToCurr(AValue)
  except
    on E: EConvertError do
      raise ConversionError(E);
    else
      raise;
  end;
end;

procedure TPressCurrency.SetAsVariant(AValue: Variant);
begin
  try
    Value := AValue;
  except
    on E: EVariantError do
      raise InvalidValueError(AValue, E);
    else
      raise;
  end;
end;

procedure TPressCurrency.SetValue(AValue: Currency);
begin
  if IsNull or (AValue <> FValue) then
  begin
    Changing;
    FValue := AValue;
    Changed;
  end;
end;

{ TPressEnum }

procedure TPressEnum.Assign(Source: TPersistent);
begin
  if Source is TPressEnum then
    Value := TPressEnum(Source).Value
  else
    inherited;
end;

class function TPressEnum.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attEnum;
end;

class function TPressEnum.AttributeName: string;
begin
  Result := 'Enum';
end;

function TPressEnum.GetAsBoolean: Boolean;
begin
  Result := IsNull;
end;

function TPressEnum.GetAsDate: TDate;
begin
  Result := Value;
end;

function TPressEnum.GetAsDateTime: TDateTime;
begin
  Result := Value;
end;

function TPressEnum.GetAsFloat: Double;
begin
  Result := Value;
end;

function TPressEnum.GetAsInteger: Integer;
begin
  Result := Value;
end;

function TPressEnum.GetAsString: string;
begin
  if IsNull then
    Result := ''
  else
    Result := Metadata.EnumMetadata.Items[Value];
end;

function TPressEnum.GetAsTime: TTime;
begin
  Result := 0;
end;

function TPressEnum.GetAsVariant: Variant;
begin
  Result := Value;
end;

function TPressEnum.GetIsEmpty: Boolean;
begin
  Result := IsNull;
end;

function TPressEnum.GetValue: Byte;
begin
  Result := FValue;
end;

procedure TPressEnum.Reset;
begin
  Clear;
end;

procedure TPressEnum.SetAsBoolean(AValue: Boolean);
begin
  Value := Ord(AValue);
end;

procedure TPressEnum.SetAsDate(AValue: TDate);
begin
  Value := Trunc(AValue);
end;

procedure TPressEnum.SetAsDateTime(AValue: TDateTime);
begin
  Value := Trunc(AValue);
end;

procedure TPressEnum.SetAsFloat(AValue: Double);
begin
  Value := Round(AValue);
end;

procedure TPressEnum.SetAsInteger(AValue: Integer);
begin
  Value := AValue;
end;

procedure TPressEnum.SetAsString(const AValue: string);
begin
  try
    if AValue = '' then
      Clear
    else
      Value := Metadata.EnumMetadata.Items.IndexOf(AValue);
  except
    on E: EConvertError do
      raise ConversionError(E);
    else
      raise;
  end;
end;

procedure TPressEnum.SetAsTime(AValue: TTime);
begin
  Value := 0;
end;

procedure TPressEnum.SetAsVariant(AValue: Variant);
begin
  try
    Value := AValue;
  except
    on E: EVariantError do
      raise InvalidValueError(AValue, E);
    else
      raise;
  end;
end;

procedure TPressEnum.SetValue(AValue: Byte);
begin
  if IsNull or (AValue <> FValue) then
  begin
    Changing;
    FValue := AValue;
    Changed;
  end;
end;

{ TPressBoolean }

procedure TPressBoolean.Assign(Source: TPersistent);
begin
  if Source is TPressBoolean then
    Value := TPressBoolean(Source).Value
  else
    inherited;
end;

class function TPressBoolean.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attBoolean;
end;

class function TPressBoolean.AttributeName: string;
begin
  Result := 'Boolean';
end;

function TPressBoolean.GetAsBoolean: Boolean;
begin
  Result := Value;
end;

function TPressBoolean.GetAsFloat: Double;
begin
  Result := AsInteger;
end;

function TPressBoolean.GetAsInteger: Integer;
begin
  Result := Integer(Value);
end;

function TPressBoolean.GetAsString: string;
begin
  if IsNull then
    Result := ''
  else
    Result := FValues[FValue];
end;

function TPressBoolean.GetAsVariant: Variant;
begin
  Result := Value;
end;

function TPressBoolean.GetDisplayText: string;
begin
  Result := AsString;
end;

function TPressBoolean.GetValue: Boolean;
begin
  Result := FValue;
end;

procedure TPressBoolean.Initialize;
var
  VEditMask: string;
  VPos: Integer;
begin
  VEditMask := EditMask;
  if VEditMask = '' then
  begin
    FValues[False] := SPressFalseString;
    FValues[True] := SPressTrueString;
  end else
  begin
    VPos := Pos(';', VEditMask);
    if VPos = 0 then
      VPos := Length(VEditMask) + 1;
    FValues[False] := Copy(VEditMask, VPos + 1, Length(VEditMask));
    FValues[True] := Copy(VEditMask, 1, VPos - 1);
  end;
  inherited;
end;

procedure TPressBoolean.Reset;
begin
  FValue := False;
  IsChanged := True;
end;

procedure TPressBoolean.SetAsBoolean(AValue: Boolean);
begin
  Value := AValue;
end;

procedure TPressBoolean.SetAsFloat(AValue: Double);
begin
  AsInteger := Round(AValue);
end;

procedure TPressBoolean.SetAsInteger(AValue: Integer);
begin
  Value := Boolean(AValue);
end;

procedure TPressBoolean.SetAsString(const AValue: string);
begin
  if AValue = '' then
    Clear
  else if SameText(AValue, SPressTrueString) then
    Value := True
  else if SameText(AValue, SPressFalseString) then
    Value := False
  else
    raise ConversionError(nil);
end;

procedure TPressBoolean.SetAsVariant(AValue: Variant);
begin
  try
    Value := AValue;
  except
    on E: EVariantError do
      raise InvalidValueError(AValue, E);
    else
      raise;
  end;
end;

procedure TPressBoolean.SetValue(AValue: Boolean);
begin
  if IsNull or (AValue <> FValue) then
  begin
    Changing;
    FValue := AValue;
    Changed;
  end;
end;

{ TPressDate }

procedure TPressDate.Assign(Source: TPersistent);
begin
  if Source is TPressDate then
    Value := TPressDate(Source).Value
  else
    inherited;
end;

class function TPressDate.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attDate;
end;

class function TPressDate.AttributeName: string;
begin
  Result := 'Date';
end;

function TPressDate.GetAsDate: TDate;
begin
  Result := Value;
end;

function TPressDate.GetAsDateTime: TDateTime;
begin
  Result := Value;
end;

function TPressDate.GetAsFloat: Double;
begin
  Result := Value;
end;

function TPressDate.GetAsString: string;
begin
  if IsNull or (Value = 0) then
    Result := ''
  else
    Result := DateToStr(Value);
end;

function TPressDate.GetAsTime: TTime;
begin
  Result := 0;
end;

function TPressDate.GetAsVariant: Variant;
begin
  Result := Value;
end;

function TPressDate.GetDisplayText: string;
begin
  if IsNull or (Value = 0) then
    Result := ''
  else if EditMask <> '' then
    Result := FormatDateTime(EditMask, Value)
  else
    Result := AsString;
end;

function TPressDate.GetValue: TDate;
begin
  Result := FValue;
end;

procedure TPressDate.Initialize;
begin
  if SameText(DefaultValue, 'now') then
    FValue := Date
  else
    inherited;
end;

procedure TPressDate.Reset;
begin
  FValue := 0;
  IsChanged := True;
end;

procedure TPressDate.SetAsDate(AValue: TDate);
begin
  Value := AValue;
end;

procedure TPressDate.SetAsDateTime(AValue: TDateTime);
begin
  Value := AValue;
end;

procedure TPressDate.SetAsFloat(AValue: Double);
begin
  Value := AValue;
end;

procedure TPressDate.SetAsString(const AValue: string);
begin
  try
    if AValue = '' then
      Clear
    else
      Value := StrToDate(AValue);
  except
    on E: EConvertError do
      raise ConversionError(E);
    else
      raise;
  end;
end;

procedure TPressDate.SetAsTime(AValue: TTime);
begin
  Value := 0;
end;

procedure TPressDate.SetAsVariant(AValue: Variant);
begin
  try
    Value := AValue;
  except
    on E: EVariantError do
      raise InvalidValueError(AValue, E);
    else
      raise;
  end;
end;

procedure TPressDate.SetValue(AValue: TDate);
begin
  if IsNull or (FValue <> AValue) then
  begin
    Changing;
    if AValue = 0 then
      Clear
    else
    begin
      FValue := Int(AValue);
      Changed;
    end;
  end;
end;

{ TPressTime }

procedure TPressTime.Assign(Source: TPersistent);
begin
  if Source is TPressTime then
    Value := TPressTime(Source).Value
  else
    inherited;
end;

class function TPressTime.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attTime;
end;

class function TPressTime.AttributeName: string;
begin
  Result := 'Time';
end;

function TPressTime.GetAsDate: TDate;
begin
  Result := 0;
end;

function TPressTime.GetAsDateTime: TDateTime;
begin
  Result := Value;
end;

function TPressTime.GetAsFloat: Double;
begin
  Result := Value;
end;

function TPressTime.GetAsString: string;
begin
  if IsNull then
    Result := ''
  else
    Result := TimeToStr(Value);
end;

function TPressTime.GetAsTime: TTime;
begin
  Result := Value;
end;

function TPressTime.GetAsVariant: Variant;
begin
  Result := Value;
end;

function TPressTime.GetDisplayText: string;
begin
  if IsNull then
    Result := ''
  else if EditMask <> '' then
    Result := FormatDateTime(EditMask, Value)
  else
    Result := AsString;
end;

function TPressTime.GetValue: TTime;
begin
  Result := FValue;
end;

procedure TPressTime.Initialize;
begin
  if SameText(DefaultValue, 'now') then
    FValue := Time
  else
    inherited;
end;

procedure TPressTime.Reset;
begin
  FValue := 0;
  IsChanged := True;
end;

procedure TPressTime.SetAsDate(AValue: TDate);
begin
  Value := 0;
end;

procedure TPressTime.SetAsDateTime(AValue: TDateTime);
begin
  Value := AValue;
end;

procedure TPressTime.SetAsFloat(AValue: Double);
begin
  Value := Value;
end;

procedure TPressTime.SetAsString(const AValue: string);
begin
  try
    if AValue = '' then
      Clear
    else
      Value := StrToTime(AValue);
  except
    on E: EConvertError do
      raise ConversionError(E);
    else
      raise;
  end;
end;

procedure TPressTime.SetAsTime(AValue: TTime);
begin
  Value := AValue;
end;

procedure TPressTime.SetAsVariant(AValue: Variant);
begin
  try
    Value := AValue;
  except
    on E: EVariantError do
      raise InvalidValueError(AValue, E);
    else
      raise;
  end;
end;

procedure TPressTime.SetValue(AValue: TTime);
begin
  if IsNull or (FValue <> AValue) then
  begin
    Changing;
    FValue := Frac(AValue);
    Changed;
  end;
end;

{ TPressDateTime }

procedure TPressDateTime.Assign(Source: TPersistent);
begin
  if Source is TPressDateTime then
    Value := TPressDateTime(Source).Value
  else
    inherited;
end;

class function TPressDateTime.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attDateTime;
end;

class function TPressDateTime.AttributeName: string;
begin
  Result := 'DateTime';
end;

function TPressDateTime.GetAsDate: TDate;
begin
  Result := Int(Value);
end;

function TPressDateTime.GetAsDateTime: TDateTime;
begin
  Result := Value;
end;

function TPressDateTime.GetAsFloat: Double;
begin
  Result := Value;
end;

function TPressDateTime.GetAsString: string;
begin
  if Value = 0 then
    Result := ''
  else if Value < 1 then
    Result := TimeToStr(Value)
  else
    Result := DateTimeToStr(Value);
end;

function TPressDateTime.GetAsTime: TTime;
begin
  Result := Frac(Value);
end;

function TPressDateTime.GetAsVariant: Variant;
begin
  Result := Value;
end;

function TPressDateTime.GetDisplayText: string;
begin
  if AsDateTime = 0 then
    Result := ''
  else if EditMask <> '' then
    Result := FormatDateTime(EditMask, Value)
  else
    Result := AsString;
end;

function TPressDateTime.GetValue: TDateTime;
begin
  Result := FValue;
end;

procedure TPressDateTime.Initialize;
begin
  if SameText(DefaultValue, 'now') then
    FValue := Now
  else
    inherited;
end;

procedure TPressDateTime.Reset;
begin
  FValue := 0;
  IsChanged := True;
end;

procedure TPressDateTime.SetAsDate(AValue: TDate);
begin
  Value := Int(AValue);
end;

procedure TPressDateTime.SetAsDateTime(AValue: TDateTime);
begin
  Value := AValue;
end;

procedure TPressDateTime.SetAsFloat(AValue: Double);
begin
  Value := AValue;
end;

procedure TPressDateTime.SetAsString(const AValue: string);
begin
  try
    if AValue = '' then
      Clear
    else
      Value := StrToDateTime(AValue);
  except
    on E: EConvertError do
      raise ConversionError(E);
    else
      raise;
  end;
end;

procedure TPressDateTime.SetAsTime(AValue: TTime);
begin
  Value := Frac(AValue);
end;

procedure TPressDateTime.SetAsVariant(AValue: Variant);
begin
  try
    Value := AValue;
  except
    on E: EVariantError do
      raise InvalidValueError(AValue, E);
    else
      raise;
  end;
end;

procedure TPressDateTime.SetValue(AValue: TDateTime);
begin
  if IsNull or (FValue <> AValue) then
  begin
    Changing;
    if AValue = 0 then
      Clear
    else
    begin
      FValue := AValue;
      Changed;
    end;
  end;
end;

{ TPressVariant }

procedure TPressVariant.Assign(Source: TPersistent);
begin
  if Source is TPressVariant then
    Value := TPressVariant(Source).Value
  else
    inherited;
end;

class function TPressVariant.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attVariant;
end;

class function TPressVariant.AttributeName: string;
begin
  Result := 'Variant';
end;

function TPressVariant.GetAsBoolean: Boolean;
begin
  try
    Result := Value;
  except
    on E: EVariantError do
      raise InvalidValueError(Value, E);
    else
      raise;
  end;
end;

function TPressVariant.GetAsDate: TDate;
begin
  try
    Result := Value;
  except
    on E: EVariantError do
      raise InvalidValueError(Value, E);
    else
      raise;
  end;
end;

function TPressVariant.GetAsDateTime: TDateTime;
begin
  try
    Result := Value;
  except
    on E: EVariantError do
      raise InvalidValueError(Value, E);
    else
      raise;
  end;
end;

function TPressVariant.GetAsFloat: Double;
begin
  try
    Result := Value;
  except
    on E: EVariantError do
      raise InvalidValueError(Value, E);
    else
      raise;
  end;
end;

function TPressVariant.GetAsInteger: Integer;
begin
  try
    Result := Value;
  except
    on E: EVariantError do
      raise InvalidValueError(Value, E);
    else
      raise;
  end;
end;

function TPressVariant.GetAsString: string;
begin
  try
    if IsNull then
      Result := ''
    else
      Result := Value;
  except
    on E: EVariantError do
      raise InvalidValueError(Value, E);
    else
      raise;
  end;
end;

function TPressVariant.GetAsTime: TTime;
begin
  try
    Result := Value;
  except
    on E: EVariantError do
      raise InvalidValueError(Value, E);
    else
      raise;
  end;
end;

function TPressVariant.GetAsVariant: Variant;
begin
  Result := Value;
end;

function TPressVariant.GetValue: Variant;
begin
  Result := FValue;
end;

procedure TPressVariant.Reset;
begin
  FValue := Null;
  IsChanged := True;
end;

procedure TPressVariant.SetAsBoolean(AValue: Boolean);
begin
  Value := AValue;
end;

procedure TPressVariant.SetAsDate(AValue: TDate);
begin
  Value := AValue;
end;

procedure TPressVariant.SetAsDateTime(AValue: TDateTime);
begin
  Value := AValue;
end;

procedure TPressVariant.SetAsFloat(AValue: Double);
begin
  Value := AValue;
end;

procedure TPressVariant.SetAsInteger(AValue: Integer);
begin
  Value := AValue;
end;

procedure TPressVariant.SetAsString(const AValue: string);
begin
  Value := AValue;
end;

procedure TPressVariant.SetAsTime(AValue: TTime);
begin
  Value := AValue;
end;

procedure TPressVariant.SetAsVariant(AValue: Variant);
begin
  Value := AValue;
end;

procedure TPressVariant.SetValue(AValue: Variant);
begin
  if IsNull or (FValue <> AValue) then
  begin
    Changing;
    if AValue = Null then
      Clear
    else
    begin
      FValue := AValue;
      Changed;
    end;
  end;
end;

{ TPressBlob }

procedure TPressBlob.Assign(Source: TPersistent);
begin
  if Source is TPressBlob then
    LoadFromStream(TPressBlob(Source).FStream)
  else
    inherited;
end;

procedure TPressBlob.ClearBuffer;
begin
  if Assigned(FStream) and (FStream.Size > 0) then
  begin
    Changing;
    FStream.Clear;
    IsChanged := True;
  end;
end;

procedure TPressBlob.Finit;
begin
  FStream.Free;
  inherited;
end;

function TPressBlob.GetAsString: string;
begin
  Result := Value;
end;

function TPressBlob.GetAsVariant: Variant;
begin
  Result := Value;
end;

function TPressBlob.GetStream: TMemoryStream;
begin
  if not Assigned(FStream) then
    FStream := TMemoryStream.Create;
  Result := FStream;
end;

function TPressBlob.GetValue: string;
begin
  if Assigned(FStream) and (FStream.Size > 0) then
  begin
    SetLength(Result, FStream.Size);
    FStream.Position := 0;
    FStream.Read(Result[1], FStream.Size);
  end else
    Result := '';
end;

procedure TPressBlob.LoadFromStream(AStream: TStream);
begin
  if Assigned(AStream) then
  begin
    Changing;
    Stream.LoadFromStream(AStream);
    Changed;
  end;
end;

procedure TPressBlob.Reset;
begin
  ClearBuffer;
end;

procedure TPressBlob.SaveToStream(AStream: TStream);
begin
  if Assigned(AStream) then
    Stream.SaveToStream(AStream);
end;

procedure TPressBlob.SetAsString(const AValue: string);
begin
  Value := AValue;
end;

procedure TPressBlob.SetAsVariant(AValue: Variant);
begin
  try
    Value := AValue;
  except
    on E: EVariantError do
      raise InvalidValueError(AValue, E);
    else
      raise;
  end;
end;

procedure TPressBlob.SetValue(const AValue: string);
begin
  if Length(AValue) > 0 then
    WriteBuffer(AValue[1], Length(AValue))
  else if IsNull then
  begin
    Changing;
    Changed;
  end else
    ClearBuffer;
end;

function TPressBlob.WriteBuffer(const ABuffer; ACount: Integer): Boolean;

  function ChangedValue: Boolean;
  var
    Ch: Char;
    I: Integer;
  begin
    Result := Stream.Size <> ACount;
    if Result then
      Exit;
    Stream.Position := 0;
    for I := 0 to Pred(ACount) do
    begin
      Result := (Stream.Read(Ch, 1) = 0) or (PChar(@ABuffer)[I] <> Ch);
      if Result then
        Exit;
    end;
  end;

begin
  Result := ChangedValue;
  if Result then
  begin
    Changing;
    if ACount > 0 then
    begin
      Stream.Position := 0;
      Stream.Size := ACount;
      Stream.WriteBuffer(ABuffer, ACount);
    end else
      Stream.Clear;
    Changed;
  end;
end;

{ TPressMemo }

class function TPressMemo.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attMemo;
end;

class function TPressMemo.AttributeName: string;
begin
  Result := 'Memo';
end;

{ TPressPicture }

procedure TPressPicture.AssignPicture(APicture: TPicture);
begin
  { TODO : Implement }
end;

procedure TPressPicture.AssignPictureFromFile(const AFileName: string);
var
  VPicture: TPicture;
begin
  VPicture := TPicture.Create;
  try
    VPicture.LoadFromFile(AFileName);
    AssignPicture(VPicture);
  finally
    VPicture.Free;
  end;
end;

class function TPressPicture.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attPicture;
end;

class function TPressPicture.AttributeName: string;
begin
  Result := 'Picture';
end;

procedure TPressPicture.ClearPicture;
begin
  { TODO : Implement }
end;

function TPressPicture.GetHasPicture: Boolean;
begin
  { TODO : Implement }
  Result := False;
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
  if Assigned(AInstance) then
    FNotifier.AddNotificationItem(AInstance, [TPressObjectChangedEvent]);
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

constructor TPressStructure.Create(
  AOwner: TPressObject; AMetadata: TPressAttributeMetadata);
begin
  inherited Create(AOwner, AMetadata);
  FNotifier := TPressNotifier.Create(Notify);
end;

procedure TPressStructure.Finit;
begin
  FNotifier.Free;
  inherited;
end;

function TPressStructure.GetObjectClass: TPressObjectClass;
begin
  if Assigned(Metadata) then
    Result := Metadata.ObjectClass
  else
    Result := TPressObject;
end;

procedure TPressStructure.Notify(AEvent: TPressEvent);
begin
  if AEvent.Owner is TPressObject then
    AfterChangeItem(TPressObject(AEvent.Owner));
end;

procedure TPressStructure.NotifyReferenceChange;
begin
  NotifyInvalidate;
  if Assigned(Owner) then
    Owner.NotifyInvalidate;  // friend class
end;

procedure TPressStructure.ReleaseInstance(AInstance: TPressObject);
begin
  if Assigned(AInstance) then
    FNotifier.RemoveNotificationItem(AInstance);
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
  ValidateObjectClass(PressObjectClassByName(AClassName));
end;

procedure TPressStructure.ValidateProxy(
  AProxy: TPressProxy);
begin
  if AProxy.HasInstance then
    ValidateObject(AProxy.Instance)
  else if AProxy.HasReference then
    ValidateObjectClass(AProxy.ObjectClassName);
end;

{ TPressItem }

procedure TPressItem.Assign(Source: TPersistent);
begin
  if Source is TPressItem then
    InternalAssignItem(TPressItem(Source).Proxy)
  else
    inherited;
end;

procedure TPressItem.AssignReference(const AClassName, AId: string);
begin
  Proxy.AssignReference(AClassName, AId);
end;

procedure TPressItem.Finit;
begin
  FProxy.Free;
  inherited;
end;

function TPressItem.GetIsEmpty: Boolean;
begin
  Result := not Assigned(FProxy) or FProxy.IsEmpty; 
end;

function TPressItem.GetObjectClassName: string;
begin
  Result := Proxy.ObjectClassName;
end;

function TPressItem.GetObjectId: string;
begin
  Result := Proxy.ObjectId;
end;

function TPressItem.GetProxy: TPressProxy;
begin
  if not Assigned(FProxy) then
  begin
    FProxy := CreateProxy;
    BindProxy(FProxy);
  end;
  Result := FProxy;
end;

function TPressItem.GetSignature: string;
begin
  if Assigned(FProxy) then
  begin
    if Proxy.HasInstance then
      Result := Proxy.Instance.Signature
    else if Proxy.HasReference then
      Result := Proxy.ObjectId
    else
      Result := SPressNilString;
  end else
    Result := SPressNilString;
end;

function TPressItem.GetValue: TPressObject;
begin
  Result := Proxy.Instance;
end;

function TPressItem.HasInstance: Boolean;
begin
  Result := Proxy.HasInstance;
end;

procedure TPressItem.InternalAssignObject(AObject: TPressObject);
begin
  Value := AObject;
end;

function TPressItem.InternalCreateMemento: TPressAttributeMemento;
begin
  Result := TPressItemMemento.Create(Self, Proxy);
end;

procedure TPressItem.InternalUnassignObject(AObject: TPressObject);
begin
  if Proxy.SameReference(AObject) then
    Proxy.ClearInstance;
end;

procedure TPressItem.SetValue(Value: TPressObject);
begin
  Proxy.Instance := Value;
end;

{ TPressPart }

procedure TPressPart.AfterChangeItem(AItem: TPressObject);
begin
  inherited;
  Changed;
end;

class function TPressPart.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attPart;
end;

class function TPressPart.AttributeName: string;
begin
  Result := 'Part';
end;

procedure TPressPart.BeforeChangeInstance(
  Sender: TPressProxy; Instance: TPressObject;
  ChangeType: TPressProxyChangeType);
begin
  inherited;

end;

procedure TPressPart.BeforeChangeItem(AItem: TPressObject);
begin
  inherited;
  Changing;
end;

procedure TPressPart.BeforeRetrieveInstance(Sender: TPressProxy);
begin
  if Sender.IsEmpty then
  begin
    DisableChanges;
    try
      Sender.Instance := ObjectClass.Create;
    finally
      EnableChanges;
    end;
  end;
  inherited;
end;

procedure TPressPart.BindInstance(AInstance: TPressObject);
begin
  inherited;
  AInstance.SetOwnerContext(Self);
end;

function TPressPart.CreateProxy: TPressProxy;
begin
  Result := TPressProxy.Create(ptOwned);
end;

procedure TPressPart.InternalAssignItem(AProxy: TPressProxy);
begin
  Value := AProxy.Instance.Clone;
end;

procedure TPressPart.ReleaseInstance(AInstance: TPressObject);
begin
  inherited;
  AInstance.ClearOwnerContext;
end;

{ TPressReference }

procedure TPressReference.AfterChangeItem(AItem: TPressObject);
begin
  inherited;
  NotifyReferenceChange;
end;

class function TPressReference.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attReference;
end;

class function TPressReference.AttributeName: string;
begin
  Result := 'Reference';
end;

function TPressReference.CreateProxy: TPressProxy;
begin
  Result := TPressProxy.Create(ptShared);
end;

procedure TPressReference.InternalAssignItem(AProxy: TPressProxy);
begin
  Value := AProxy.Instance;
end;

{ TPressItemsChangedEvent }

constructor TPressItemsChangedEvent.Create(
  AOwner: TObject; AProxy: TPressProxy;
  AIndex: Integer; AEventType: TPressItemsEventType);
begin
  inherited Create(AOwner);
  FEventType := AEventType;
  FIndex := AIndex;
  FProxy := AProxy;
end;

{ TPressItems }

function TPressItems.Add(AObject: TPressObject; AShareInstance: Boolean): Integer;
begin
  Result := ProxyList.AddInstance(AObject);
  if not AShareInstance and (ProxyList.ProxyType = ptShared) then
    AObject.Release;
end;

function TPressItems.AddReference(const AClassName, AId: string): Integer;
begin
  Result := ProxyList.AddReference(AClassName, AId);
end;

procedure TPressItems.AfterChangeInstance(
  Sender: TPressProxy; Instance: TPressObject;
  ChangeType: TPressProxyChangeType);
begin
  inherited;
  ChangedItem(Instance, ChangeType = pctAssigning);
end;

procedure TPressItems.Assign(Source: TPersistent);
begin
  if Source is TPressItems then
  begin
    DisableChanges;
    try
      if Assigned(FProxyList) then
        FProxyList.Clear;
      with TPressItems(Source).CreateIterator do
      try
        BeforeFirstItem;
        while NextItem do
          InternalAssignItem(CurrentItem);
      finally
        Free;
      end;
    finally
      EnableChanges;
    end;
    NotifyRebuild;
  end else
    inherited;
end;

procedure TPressItems.AssignProxyList(AProxyList: TPressProxyList);
begin
  Clear;
  FProxyList.Free;
  FProxyList := AProxyList;
  if Assigned(FProxyList) then
  begin
    FProxyList.OnChangeList := ChangedList;
    with FProxyList.CreateIterator do
    try
      BeforeFirstItem;
      while NextItem do
      begin
        ValidateProxy(CurrentItem);
        BindProxy(CurrentItem);
      end;
    finally
      Free;
    end;
    NotifyRebuild;
  end;
end;

procedure TPressItems.ChangedItem(
  AItem: TPressObject; ASubjectChanged: Boolean);
var
  VIndex: Integer;
  VEventType: TPressItemsEventType;
begin
  if ChangesDisabled then
    Exit;
  VIndex := ProxyList.IndexOfInstance(AItem);
  if VIndex >= 0 then
  begin
    if ASubjectChanged then
      VEventType := ietModify
    else
      VEventType := ietNotify;
    TPressItemsChangedEvent.Create(
     Self, ProxyList[VIndex], VIndex, VEventType).Notify;
  end;
  if ASubjectChanged then
    Changed;
end;

procedure TPressItems.ChangedList(
  Sender: TPressProxyList; Item: TPressProxy; Action: TListNotification);

  procedure VerifyNewItem;
  begin
    try
      ValidateProxy(Item);
    except
      Sender.DisableNotification;
      try
        Sender.Remove(Item);
      finally
        Sender.EnableNotification;
      end;
      raise;
    end;
  end;

  procedure DoChanges;
  var
    VEventType: TPressItemsEventType;
    VIndex: Integer;
  begin
    Changing;
    case Action of
      lnAdded:
        begin
          VerifyNewItem;
          if Sender[Sender.Count - 1] = Item then
          begin
            VEventType := ietAdd;
            VIndex := Sender.Count - 1;
          end else
          begin
            VEventType := ietInsert;
            VIndex := Sender.IndexOf(Item);
          end;
          BindProxy(Item);
          NotifyMementos(Item, isAdded);
        end;
      else {lnExtracted, lnDeleted}
        begin
          if Item.HasInstance then
            ReleaseInstance(Item.Instance);
          VEventType := ietRemove;
          VIndex := -1;
          { TODO : OldIndex? }
          NotifyMementos(Item, isDeleted, -1);
        end;
    end;
    TPressItemsChangedEvent.Create(Self, Item, VIndex, VEventType).Notify;
    Changed;
  end;

  procedure UpdateInstance;
  begin
    if Action = lnAdded then
    begin
      VerifyNewItem;
      BindProxy(Item);
    end else {lnExtracted, lnDeleted}
      if Item.HasInstance then
        ReleaseInstance(Item.Instance);
  end;

begin
  if ChangesDisabled then
    UpdateInstance
  else
    DoChanges;
end;

procedure TPressItems.Clear;
begin
  if Assigned(FProxyList) then
  begin
    DisableChanges;
    try
      FProxyList.Clear;
    finally
      EnableChanges;
    end;
    TPressItemsChangedEvent.Create(Self, nil, -1, ietClear).Notify;
  end;
end;

function TPressItems.Count: Integer;
begin
  if Assigned(FProxyList) then
    Result := FProxyList.Count
  else
    Result := 0;
end;

function TPressItems.CreateIterator: TPressProxyIterator;
begin
  Result := ProxyList.CreateIterator;
end;

procedure TPressItems.Delete(AIndex: Integer);
begin
  ProxyList.Delete(AIndex);
end;

procedure TPressItems.Finit;
begin
  Clear;
  FProxyList.Free;
  FMementos.Free;
  inherited;
end;

function TPressItems.GetHasAddedItem: Boolean;
begin
  { TODO : Implement }
  Result := False;
end;

function TPressItems.GetHasDeletedItem: Boolean;
begin
  Result := Assigned(FProxyDeletedList) and (FProxyDeletedList.Count > 0);
end;

function TPressItems.GetIsEmpty: Boolean;
begin
  Result := Count = 0;
end;

function TPressItems.GetMementos: TPressItemsMementoList;
begin
  if not Assigned(FMementos) then
    FMementos := TPressItemsMementoList.Create(False);
  Result := FMementos;
end;

function TPressItems.GetObjects(AIndex: Integer): TPressObject;
begin
  Result := ProxyList[AIndex].Instance;
end;

function TPressItems.GetProxies(AIndex: Integer): TPressProxy;
begin
  Result := ProxyList[AIndex];
end;

function TPressItems.GetProxyDeletedList: TPressProxyList;
begin
  if not Assigned(FProxyDeletedList) then
    FProxyDeletedList := InternalCreateProxyList;
  Result := FProxyDeletedList;
end;

function TPressItems.GetProxyList: TPressProxyList;
begin
  if not Assigned(FProxyList) then
    AssignProxyList(InternalCreateProxyList);
  Result := FProxyList;
end;

function TPressItems.IndexOf(AObject: TPressObject): Integer;
begin
  Result := ProxyList.IndexOfInstance(AObject);
end;

procedure TPressItems.Insert(
  AIndex: Integer; AObject: TPressObject; AShareInstance: Boolean);
begin
  ProxyList.InsertInstance(AIndex, AObject);
  if not AShareInstance and (ProxyList.ProxyType = ptShared) then
    AObject.Release;
end;

procedure TPressItems.InternalAssignObject(AObject: TPressObject);
begin
  Add(AObject);
end;

function TPressItems.InternalCreateMemento: TPressAttributeMemento;
begin
  Result := TPressItemsMemento.Create(Self);
  try
    Mementos.Add(TPressItemsMemento(Result));
  except
    Result.Free;
    raise;
  end;
end;

procedure TPressItems.InternalUnassignObject(AObject: TPressObject);
begin
  ProxyList.RemoveInstance(AObject);
end;

procedure TPressItems.NotifyMementos(
  AProxy: TPressProxy; AItemState: TPressItemState; AOldIndex: Integer);
begin
  if Assigned(FMementos) then
    with FMementos.CreateIterator do
    try
      BeforeFirstItem;
      while NextItem do
        CurrentItem.Notify(AProxy, AItemState, AOldIndex);
    finally
      Free;
    end;
end;

procedure TPressItems.NotifyRebuild;
begin
  TPressItemsChangedEvent.Create(Self, nil, -1, ietRebuild).Notify;
end;

function TPressItems.Remove(AObject: TPressObject): Integer;
begin
  Result := ProxyList.IndexOfInstance(AObject);
  if Result >= 0 then
    Delete(Result);
end;

procedure TPressItems.SetObjects(AIndex: Integer; AValue: TPressObject);
begin
  ProxyList[AIndex].Instance := AValue;
end;

{ TPressParts }

procedure TPressParts.AfterChangeItem(AItem: TPressObject);
begin
  inherited;
  ChangedItem(AItem);
end;

class function TPressParts.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attParts;
end;

class function TPressParts.AttributeName: string;
begin
  Result := 'Parts';
end;

procedure TPressParts.BeforeChangeInstance(Sender: TPressProxy;
  Instance: TPressObject; ChangeType: TPressProxyChangeType);
begin
  inherited;
  if not ChangesDisabled and (ChangeType = pctAssigning) then
    NotifyMementos(Sender, isModified);
end;

procedure TPressParts.BeforeChangeItem(AItem: TPressObject);
var
  VIndex: Integer;
begin
  inherited;
  if ChangesDisabled then
    Exit;
  Changing;
  VIndex := ProxyList.IndexOfInstance(AItem);
  if VIndex >= 0 then
    NotifyMementos(ProxyList[VIndex], isModified);
end;

procedure TPressParts.BeforeRetrieveInstance(Sender: TPressProxy);
begin
  if Sender.IsEmpty then
  begin
    DisableChanges;
    try
      Sender.Instance := ObjectClass.Create;
    finally
      EnableChanges;
    end;
  end;
  inherited;
end;

procedure TPressParts.BindInstance(AInstance: TPressObject);
begin
  inherited;
  AInstance.SetOwnerContext(Self);
end;

procedure TPressParts.InternalAssignItem(AProxy: TPressProxy);
begin
  Add(AProxy.Instance.Clone);
end;

function TPressParts.InternalCreateProxyList: TPressProxyList;
begin
  Result := TPressProxyList.Create(True, ptOwned);
end;

procedure TPressParts.ReleaseInstance(AInstance: TPressObject);
begin
  inherited;
  AInstance.ClearOwnerContext;
end;

{ TPressReferences }

procedure TPressReferences.AfterChangeItem(AItem: TPressObject);
begin
  inherited;
  ChangedItem(AItem, False);
  NotifyReferenceChange;
end;

class function TPressReferences.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attReferences;
end;

class function TPressReferences.AttributeName: string;
begin
  Result := 'References';
end;

procedure TPressReferences.InternalAssignItem(AProxy: TPressProxy);
begin
  Add(AProxy.Instance);
end;

function TPressReferences.InternalCreateProxyList: TPressProxyList;
begin
  Result := TPressProxyList.Create(True, ptShared);
end;

{ Initialization routines }

procedure RegisterAttributes;
begin
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
  TPressPicture.RegisterAttribute;
  TPressPart.RegisterAttribute;
  TPressReference.RegisterAttribute;
  TPressParts.RegisterAttribute;
  TPressReferences.RegisterAttribute;
end;

procedure RegisterClasses;
begin
  TPressObject.RegisterClass;
end;

procedure InitMetadatas;
begin
  PressRegisterMetadata(
   TPressObject.ClassName + ';' +
   SPressIdString+': String(32);');
end;

initialization
  RegisterAttributes;
  RegisterClasses;
  InitMetadatas;
  { TODO : Forcing premature ObjectStore initialization to avoid AVs
    due to SingleObjects destruction order.
    An ApplicationContext instance holding and destroying SingleObjects
    solves this issue. }
  PressObjectStore;

{$ENDIF}

end.
