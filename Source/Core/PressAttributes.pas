(*
  PressObjects, Attribute Classes
  Copyright (C) 2006-2008 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressAttributes;

{$I Press.inc}

interface

uses
  Classes,
  Contnrs,
  TypInfo,
  PressClasses,
  PressNotifier,
  PressSubject;

type
  { Memento declarations }

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

  TPressItemMemento = class(TPressAttributeMemento)
  private
    FOldIndex: Integer;
    FOwnerList: TPressItemMementoList;
    FProxy: TPressProxy;
    FProxyClone: TPressProxy;
    FState: TPressItemState;
    FSubjectSavePoint: TPressSavePoint;
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

  { Value attributes declarations }

  TPressValue = class(TPressAttribute)
  protected
    function GetOldAttribute: TPressValue;
    function GetSignature: string; override;
    function InternalCreateMemento: TPressAttributeMemento; override;
  public
    property OldAttribute: TPressValue read GetOldAttribute;
  end;

  TPressCustomString = class(TPressValue)
  private
    FValue: string;
    function GetOldValue: string;
    function GetPubValue: string;
    procedure SetPubValue(const AValue: string);
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
    procedure InternalReset; override;
    function InternalTypeKinds: TTypeKinds; override;
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
    class function EmptyValue: Variant; override;
    property OldValue: string read GetOldValue;
    property PubValue: string read GetPubValue write SetPubValue;
    property Value: string read GetValue write SetValue;
  end;

  TPressPlainString = class(TPressCustomString)
  public
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
  end;

  TPressAnsiString = class(TPressCustomString)
  public
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
  end;

  TPressString = class(TPressAnsiString)
  public
    class function AttributeName: string; override;
  end;

  TPressNumeric = class(TPressValue)
  { TODO : Implement formula }
  protected
    function GetAsBoolean: Boolean; override;
    function GetAsDate: TDate; override;
    function GetAsDateTime: TDateTime; override;
    function GetAsTime: TTime; override;
    function GetDisplayText: string; override;
    function GetIsRelativelyChanged: Boolean; virtual; abstract;
    procedure SetAsBoolean(AValue: Boolean); override;
    procedure SetAsDate(AValue: TDate); override;
    procedure SetAsDateTime(AValue: TDateTime); override;
    procedure SetAsTime(AValue: TTime); override;
  public
    property IsRelativelyChanged: Boolean read GetIsRelativelyChanged;
  end;

  TPressInteger = class(TPressNumeric)
  private
    FDiff: Integer;
    FValue: Integer;
    function GetOldValue: Integer;
    function GetPubValue: Integer;
    procedure SetPubValue(AValue: Integer);
  protected
    procedure ClearPersistenceData; override;
    function GetAsFloat: Double; override;
    function GetAsInteger: Integer; override;
    function GetAsString: string; override;
    function GetAsVariant: Variant; override;
    function GetIsEmpty: Boolean; override;
    function GetIsRelativelyChanged: Boolean; override;
    function GetValue: Integer; virtual;
    procedure InternalReset; override;
    function InternalTypeKinds: TTypeKinds; override;
    procedure SetAsFloat(AValue: Double); override;
    procedure SetAsInteger(AValue: Integer); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetAsVariant(AValue: Variant); override;
    procedure SetValue(AValue: Integer); virtual;
  public
    procedure Assign(Source: TPersistent); override;
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
    procedure Decrement(AValue: Integer = 1); virtual;
    class function EmptyValue: Variant; override;
    procedure Increment(AValue: Integer = 1); virtual;
    property Diff: Integer read FDiff;
    property OldValue: Integer read GetOldValue;
    property PubValue: Integer read GetPubValue write SetPubValue;
    property Value: Integer read GetValue write SetValue;
  end;

  TPressFloat = class(TPressNumeric)
  private
    FDiff: Double;
    FValue: Double;
    function GetOldValue: Double;
    function GetPubValue: Double;
    procedure SetPubValue(AValue: Double);
  protected
    procedure ClearPersistenceData; override;
    function GetAsFloat: Double; override;
    function GetAsInteger: Integer; override;
    function GetAsString: string; override;
    function GetAsVariant: Variant; override;
    function GetIsEmpty: Boolean; override;
    function GetIsRelativelyChanged: Boolean; override;
    function GetValue: Double; virtual;
    procedure InternalReset; override;
    function InternalTypeKinds: TTypeKinds; override;
    procedure SetAsFloat(AValue: Double); override;
    procedure SetAsInteger(AValue: Integer); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetAsVariant(AValue: Variant); override;
    procedure SetValue(AValue: Double); virtual;
  public
    procedure Assign(Source: TPersistent); override;
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
    procedure Decrement(AValue: Double = 1); virtual;
    class function EmptyValue: Variant; override;
    procedure Increment(AValue: Double = 1); virtual;
    property Diff: Double read FDiff;
    property OldValue: Double read GetOldValue;
    property PubValue: Double read GetPubValue write SetPubValue;
    property Value: Double read GetValue write SetValue;
  end;

  TPressCurrency = class(TPressNumeric)
  private
    FDiff: Currency;
    FValue: Currency;
    function GetOldValue: Currency;
    function GetPubValue: Currency;
    procedure SetPubValue(AValue: Currency);
  protected
    procedure ClearPersistenceData; override;
    function GetAsCurrency: Currency; override;
    function GetAsFloat: Double; override;
    function GetAsInteger: Integer; override;
    function GetAsString: string; override;
    function GetAsVariant: Variant; override;
    function GetIsEmpty: Boolean; override;
    function GetIsRelativelyChanged: Boolean; override;
    function GetDisplayText: string; override;
    function GetValue: Currency; virtual;
    procedure InternalReset; override;
    function InternalTypeKinds: TTypeKinds; override;
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
    procedure Decrement(AValue: Currency = 1); virtual;
    class function EmptyValue: Variant; override;
    procedure Increment(AValue: Currency = 1); virtual;
    property Diff: Currency read FDiff;
    property OldValue: Currency read GetOldValue;
    property PubValue: Currency read GetPubValue write SetPubValue;
    property Value: Currency read GetValue write SetValue;
  end;

  TPressEnum = class(TPressValue)
  private
    FValue: Integer;
    function GetOldValue: Integer;
    function GetPubValue: Integer;
    procedure SetPubValue(AValue: Integer);
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
    function GetValue: Integer; virtual;
    procedure InternalReset; override;
    function InternalTypeKinds: TTypeKinds; override;
    procedure SetAsBoolean(AValue: Boolean); override;
    procedure SetAsDate(AValue: TDate); override;
    procedure SetAsDateTime(AValue: TDateTime); override;
    procedure SetAsFloat(AValue: Double); override;
    procedure SetAsInteger(AValue: Integer); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetAsTime(AValue: TTime); override;
    procedure SetAsVariant(AValue: Variant); override;
    procedure SetValue(AValue: Integer); virtual;
  public
    procedure Assign(Source: TPersistent); override;
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
    class function EmptyValue: Variant; override;
    function SameValue(AValue: Integer): Boolean;
    property OldValue: Integer read GetOldValue;
    property PubValue: Integer read GetPubValue write SetPubValue;
    property Value: Integer read GetValue write SetValue;
  end;

  TPressBoolean = class(TPressValue)
  private
    FValue: Boolean;
    FValues: array[Boolean] of string;
    function GetOldValue: Boolean;
    function GetPubValue: Boolean;
    procedure SetPubValue(AValue: Boolean);
  protected
    function GetAsBoolean: Boolean; override;
    function GetAsFloat: Double; override;
    function GetAsInteger: Integer; override;
    function GetAsString: string; override;
    function GetAsVariant: Variant; override;
    function GetDisplayText: string; override;
    function GetValue: Boolean; virtual;
    procedure Initialize; override;
    procedure InternalReset; override;
    function InternalTypeKinds: TTypeKinds; override;
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
    class function EmptyValue: Variant; override;
    property OldValue: Boolean read GetOldValue;
    property PubValue: Boolean read GetPubValue write SetPubValue;
    property Value: Boolean read GetValue write SetValue;
  end;

  TPressDate = class(TPressValue)
  private
    FValue: TDate;
    function GetOldValue: TDate;
    function GetPubValue: TDate;
    procedure SetPubValue(AValue: TDate);
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
    procedure InternalReset; override;
    function InternalTypeKinds: TTypeKinds; override;
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
    class function EmptyValue: Variant; override;
    property OldValue: TDate read GetOldValue;
    property PubValue: TDate read GetPubValue write SetPubValue;
    property Value: TDate read GetValue write SetValue;
  end;

  TPressTime = class(TPressValue)
  private
    FValue: TTime;
    function GetOldValue: TTime;
    function GetPubValue: TTime;
    procedure SetPubValue(AValue: TTime);
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
    procedure InternalReset; override;
    function InternalTypeKinds: TTypeKinds; override;
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
    class function EmptyValue: Variant; override;
    property OldValue: TTime read GetOldValue;
    property PubValue: TTime read GetPubValue write SetPubValue;
    property Value: TTime read GetValue write SetValue;
  end;

  TPressDateTime = class(TPressValue)
  private
    FValue: TDateTime;
    function GetOldValue: TDateTime;
    function GetPubValue: TDateTime;
    procedure SetPubValue(AValue: TDateTime);
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
    procedure InternalReset; override;
    function InternalTypeKinds: TTypeKinds; override;
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
    class function EmptyValue: Variant; override;
    property OldValue: TDateTime read GetOldValue;
    property PubValue: TDateTime read GetPubValue write SetPubValue;
    property Value: TDateTime read GetValue write SetValue;
  end;

  TPressVariant = class(TPressValue)
  private
    FValue: Variant;
    function GetOldValue: Variant;
    function GetPubValue: Variant;
    procedure SetPubValue(AValue: Variant);
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
    procedure InternalReset; override;
    function InternalTypeKinds: TTypeKinds; override;
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
    class function EmptyValue: Variant; override;
    property OldValue: Variant read GetOldValue;
    property PubValue: Variant read GetPubValue write SetPubValue;
    property Value: Variant read GetValue write SetValue;
  end;

  TPressBlob = class(TPressValue)
  private
    FStream: TMemoryStream;
    function GetOldValue: string;
    function GetPubValue: string;
    function GetSize: Integer;
    function GetStream: TMemoryStream;
    function GetValue: string;
    procedure SetPubValue(const AValue: string);
    procedure SetValue(const AValue: string);
  protected
    procedure Finit; override;
    function GetAsString: string; override;
    function GetAsVariant: Variant; override;
    procedure InternalReset; override;
    function InternalTypeKinds: TTypeKinds; override;
    procedure SetAsString(const AValue: string); override;
    procedure SetAsVariant(AValue: Variant); override;
    property Stream: TMemoryStream read GetStream;
  public
    procedure Assign(Source: TPersistent); override;
    procedure ClearBuffer;
    class function EmptyValue: Variant; override;
    procedure LoadFromStream(AStream: TStream);
    procedure SaveToStream(AStream: TStream);
    function WriteBuffer(const ABuffer; ACount: Integer): Boolean;
    property OldValue: string read GetOldValue;
    property PubValue: string read GetPubValue write SetPubValue;
    property Size: Integer read GetSize;
    property Value: string read GetValue write SetValue;
  end;

  TPressMemo = class(TPressBlob)
  public
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
  end;

  TPressBinary = class(TPressBlob)
  public
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
  end;

  { Structured attributes declarations }

  TPressItem = class(TPressStructure)
  private
    FProxy: TPressProxy;
    function GetOldValue: TPressObject;
    function GetProxy: TPressProxy;
    function GetPubValue: TPressObject;
    function GetValue: TPressObject;
    procedure SetPubValue(AValue: TPressObject);
    procedure SetValue(AValue: TPressObject);
  protected
    procedure AddSessionIntf(const ASession: IPressSession); override;
    procedure AfterChangeInstance(Sender: TPressProxy; Instance: TPressObject; ChangeType: TPressProxyChangeType); override;
    procedure Finit; override;
    function GetAsInteger: Integer; override;
    function GetAsString: string; override;
    function GetAsVariant: Variant; override;
    function GetIsEmpty: Boolean; override;
    function GetSignature: string; override;
    procedure InternalAssignObject(AObject: TPressObject); override;
    function InternalCreateMemento: TPressAttributeMemento; override;
    procedure InternalReset; override;
    function InternalTypeKinds: TTypeKinds; override;
    procedure InternalUnassignObject(AObject: TPressObject); override;
    procedure RemoveSessionIntf(const ASession: IPressSession); override;
    procedure SetAsInteger(AValue: Integer); override;
    procedure SetAsString(const AValue: string); override;
    procedure SetAsVariant(AValue: Variant); override;
  public
    procedure Assign(Source: TPersistent); override;
    procedure AssignReference(const AClassName, AId: string);
    function SameReference(AObject: TPressObject): Boolean; overload;
    function SameReference(const ARefClass, ARefID: string): Boolean; overload;
    property OldValue: TPressObject read GetOldValue;
    property Proxy: TPressProxy read GetProxy;
    property PubValue: TPressObject read GetPubValue write SetPubValue;
    property Value: TPressObject read GetValue write SetValue;
  end;

  TPressPart = class(TPressItem)
  protected
    procedure BeforeChangeInstance(Sender: TPressProxy; Instance: TPressObject; ChangeType: TPressProxyChangeType); override;
    procedure BeforeChangeItem(AItem: TPressObject); override;
    procedure BeforeRetrieveInstance(Sender: TPressProxy); override;
    procedure BindInstance(AInstance: TPressObject); override;
    procedure ChangedItem(AInstance: TPressObject; AUpdateIsChangedFlag: Boolean); override;
    procedure InternalAssignItem(AProxy: TPressProxy); override;
    function InternalProxyType: TPressProxyType; override;
    procedure InternalUnchanged; override;
    procedure ReleaseInstance(AInstance: TPressObject); override;
  public
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
  end;

  TPressReference = class(TPressItem)
  protected
    procedure InternalAssignItem(AProxy: TPressProxy); override;
    function InternalProxyType: TPressProxyType; override;
  public
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
  end;

  TPressItemsEventType =
   (ietAdd, ietInsert, ietModify, ietRemove, ietRebuild, ietClear);

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

  TPressItemsIterator = class;

  TPressItems = class(TPressStructure)
  private
    { TODO : Move added/removed proxies to session classes }
    FAddedProxies: TPressProxyList;
    FMementos: TObjectList;
    FProxyList: TPressProxyList;
    FRemovedProxies: TPressProxyList;
    function GetAddedProxies: TPressProxyList;
    function GetObjects(AIndex: Integer): TPressObject;
    function GetProxyList: TPressProxyList;
    function GetRemovedProxies: TPressProxyList;
    procedure ReleaseMemento(AMemento: TPressItemsMemento);
    procedure SetObjects(AIndex: Integer; AValue: TPressObject);
  protected
    procedure AddSessionIntf(const ASession: IPressSession); override;
    procedure AfterChangeInstance(Sender: TPressProxy; Instance: TPressObject; ChangeType: TPressProxyChangeType); override;
    procedure ChangedInstance(AInstance: TPressObject; AUpdateIsChangedFlag: Boolean = True);
    procedure ChangedList(Sender: TPressProxyList; Item: TPressProxy; Action: TListNotification);
    procedure ClearObjectCache;
    procedure Finit; override;
    function GetIsEmpty: Boolean; override;
    procedure InternalAssignObject(AObject: TPressObject); override;
    procedure InternalChanged(AChangedWhenDisabled: Boolean); override;
    function InternalCreateIterator: TPressItemsIterator; virtual;
    function InternalCreateMemento: TPressAttributeMemento; override;
    function InternalFormatList(const AFormat, AConn: string; AParams: array of string): string; virtual;
    procedure InternalReset; override;
    procedure InternalUnassignObject(AObject: TPressObject); override;
    procedure InternalUnchanged; override;
    procedure NotifyMemento(AProxy: TPressProxy; AItemState: TPressItemState; AOldIndex: Integer = -1);
    procedure NotifyRebuild;
    procedure RemoveSessionIntf(const ASession: IPressSession); override;
    (*
    function InternalCreateIterator: TPressItemsIterator; override;
    *)
  public
    function Add(AClass: TPressObjectClass = nil): TPressObject; overload;
    function Add(AObject: TPressObject): Integer; overload;
    function AddReference(const AClassName, AId: string): Integer;
    procedure Assign(Source: TPersistent); override;
    procedure AssignProxyList(AProxyList: TPressProxyList);
    function Count: Integer;
    function CreateIterator: TPressItemsIterator;
    function CreateProxyIterator: TPressProxyIterator;
    procedure Delete(AIndex: Integer);
    function FormatList(const AFormat, AConn: string; AParams: array of string): string;
    function IndexOf(AObject: TPressObject): Integer;
    function Insert(AIndex: Integer; AClass: TPressObjectClass = nil): TPressObject; overload;
    procedure Insert(AIndex: Integer; AObject: TPressObject); overload;
    function Remove(AObject: TPressObject): Integer;
    function RemoveReference(AProxy: TPressProxy): Integer;
    property AddedProxies: TPressProxyList read GetAddedProxies;
    property Objects[AIndex: Integer]: TPressObject read GetObjects write SetObjects; default;
    property ProxyList: TPressProxyList read GetProxyList;
    property RemovedProxies: TPressProxyList read GetRemovedProxies;
    (*
    function Add(AClass: TPressObjectClass = nil): TPressObject; overload;
    function Add(AObject: TPressObject): Integer; overload;
    function CreateIterator: TPressItemsIterator;
    function IndexOf(AObject: TPressObject): Integer;
    procedure Insert(AIndex: Integer; AObject: TPressObject);
    function Remove(AObject: TPressObject): Integer;
    class function ValidObjectClass: TPressObjectClass; override;
    property Objects[AIndex: Integer]: TPressObject read GetObjects write SetObjects; default;
    *)
  end;

  TPressItemsIterator = class(TPressProxyIterator)
  private
    function GetCurrentItem: TPressObject;
  public
    property CurrentItem: TPressObject read GetCurrentItem;
    (*
    property CurrentItem: TPressObject read GetCurrentItem;
    *)
  end;

  TPressParts = class(TPressItems)
  protected
    procedure BeforeChangeInstance(Sender: TPressProxy; Instance: TPressObject; ChangeType: TPressProxyChangeType); override;
    procedure BeforeChangeItem(AItem: TPressObject); override;
    procedure BeforeRetrieveInstance(Sender: TPressProxy); override;
    procedure BindInstance(AInstance: TPressObject); override;
    procedure ChangedItem(AInstance: TPressObject; AUpdateIsChangedFlag: Boolean); override;
    procedure InternalAssignItem(AProxy: TPressProxy); override;
    function InternalProxyType: TPressProxyType; override;
    procedure InternalUnchanged; override;
    procedure ReleaseInstance(AInstance: TPressObject); override;
  public
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
  end;

  TPressReferences = class(TPressItems)
  protected
    procedure InternalAssignItem(AProxy: TPressProxy); override;
    function InternalProxyType: TPressProxyType; override;
  public
    class function AttributeBaseType: TPressAttributeBaseType; override;
    class function AttributeName: string; override;
  end;

implementation

uses
  SysUtils,
  {$IFNDEF D5Down}Variants,{$ENDIF}
  {$IFDEF PressLog}PressLog,{$ENDIF}
  PressUtils,
  PressConsts;

type
  TPressObjectFriend = class(TPressObject);
  TPressProxyFriend = class(TPressProxy);
  TPressProxyListFriend = class(TPressProxyList);

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
  if Assigned(FAttributeClone) then
  begin
    {$IFDEF PressLogSubjectMemento}PressLogMsg(Self, Format('Restoring %s (%s)', [Owner.Signature, FAttributeClone.Signature]));{$ENDIF}
    Owner.Assign(FAttributeClone);
  end;
  RestoreChanged;
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
  FProxyClone.Free;
  FProxy.Free;
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
    if FProxy.HasInstance and (FProxy.ProxyType = ptOwned) then
      FSubjectSavePoint := FProxy.Instance.Memento.SavePoint;
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
    if FProxy.HasInstance and (FProxy.ProxyType = ptOwned) then
      FProxy.Instance.Memento.Restore(FSubjectSavePoint);
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
  if Owner is TPressItem then
    RestoreChanged;
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
  Owner.ReleaseMemento(Self);  // friend class
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
  RestoreChanged;
  Owner.NotifyRebuild;  // friend class
end;

{ TPressValue }

function TPressValue.GetOldAttribute: TPressValue;
var
  VMemento: TPressValueMemento;
begin
  VMemento := inherited FindUnchangedMemento as TPressValueMemento;
  if Assigned(VMemento) then
    Result := VMemento.AttributeClone
  else
    Result := Self;
end;

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

{ TPressCustomString }

procedure TPressCustomString.Assign(Source: TPersistent);
begin
  if (Source is TPressCustomString) and (TPressCustomString(Source).State = asValue) then
    PubValue := TPressCustomString(Source).PubValue
  else
    inherited;
end;

class function TPressCustomString.EmptyValue: Variant;
begin
  Result := '';
end;

function TPressCustomString.GetAsBoolean: Boolean;
var
  VValue: string;
begin
  VValue := PubValue;
  if SameText(VValue, SPressTrueString) then
    Result := True
  else if SameText(VValue, SPressFalseString) then
    Result := False
  else
    raise ConversionError(nil);
end;

function TPressCustomString.GetAsDate: TDate;
begin
  try
    Result := StrToDate(PubValue);
  except
    on E: EConvertError do
      raise ConversionError(E);
    else
      raise;
  end;
end;

function TPressCustomString.GetAsDateTime: TDateTime;
begin
  try
    Result := StrToDateTime(PubValue);
  except
    on E: EConvertError do
      raise ConversionError(E);
    else
      raise;
  end;
end;

function TPressCustomString.GetAsFloat: Double;
begin
  try
    Result := StrToFloat(PubValue);
  except
    on E: EConvertError do
      raise ConversionError(E);
    else
      raise;
  end;
end;

function TPressCustomString.GetAsInteger: Integer;
begin
  try
    Result := StrToInt(PubValue);
  except
    on E: EConvertError do
      raise ConversionError(E);
    else
      raise;
  end;
end;

function TPressCustomString.GetAsString: string;
begin
  Result := PubValue;
end;

function TPressCustomString.GetAsTime: TTime;
begin
  try
    Result := StrToTime(PubValue);
  except
    on E: EConvertError do
      raise ConversionError(E);
    else
      raise;
  end;
end;

function TPressCustomString.GetAsVariant: Variant;
begin
  Result := PubValue;
end;

function TPressCustomString.GetIsEmpty: Boolean;
begin
  Result := PubValue = '';
end;

function TPressCustomString.GetOldValue: string;
begin
  Result := (OldAttribute as TPressCustomString).Value;
end;

function TPressCustomString.GetPubValue: string;
begin
  if UsePublishedGetter then
    Result := GetStrProp(Owner, Metadata.Name)
  else
    Result := Value;
end;

function TPressCustomString.GetValue: string;
begin
  Synchronize;
  Result := FValue;
end;

procedure TPressCustomString.InternalReset;
begin
  inherited;
  FValue := '';
end;

function TPressCustomString.InternalTypeKinds: TTypeKinds;
begin
  Result := [tkString, tkLString, tkWString];
end;

procedure TPressCustomString.SetAsBoolean(AValue: Boolean);
begin
  if AValue then
    PubValue := SPressTrueString
  else
    PubValue := SPressFalseString;
end;

procedure TPressCustomString.SetAsDate(AValue: TDate);
begin
  PubValue := DateToStr(AValue);
end;

procedure TPressCustomString.SetAsDateTime(AValue: TDateTime);
begin
  PubValue := DateTimeToStr(AValue);
end;

procedure TPressCustomString.SetAsFloat(AValue: Double);
begin
  PubValue := FloatToStr(AValue);
end;

procedure TPressCustomString.SetAsInteger(AValue: Integer);
begin
  PubValue := IntToStr(AValue);
end;

procedure TPressCustomString.SetAsString(const AValue: string);
begin
  PubValue := AValue;
end;

procedure TPressCustomString.SetAsTime(AValue: TTime);
begin
  PubValue := TimeToStr(AValue);
end;

procedure TPressCustomString.SetAsVariant(AValue: Variant);
begin
  try
    if VarIsEmpty(AValue) or VarIsNull(AValue) then
      Clear
    else
      PubValue := AValue;
  except
    on E: EVariantError do
      raise InvalidValueError(AValue, E);
    else
      raise;
  end;
end;

procedure TPressCustomString.SetPubValue(const AValue: string);
begin
  if UsePublishedSetter then
    SetStrProp(Owner, Metadata.Name, AValue)
  else
    Value := AValue;
end;

procedure TPressCustomString.SetValue(const AValue: string);
var
  VMaxSize: Integer;
  VOwnerName: string;
begin
  if State = asNotLoaded then
    Synchronize;
  if (FValue <> AValue) or (State = asNull) then
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
    ValueAssigned;
  end;
end;

{ TPressPlainString }

class function TPressPlainString.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attPlainString;
end;

class function TPressPlainString.AttributeName: string;
begin
  if Self = TPressPlainString then
    Result := 'PlainString'
  else
    Result := ClassName;
end;

{ TPressAnsiString }

class function TPressAnsiString.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attAnsiString;
end;

class function TPressAnsiString.AttributeName: string;
begin
  if Self = TPressAnsiString then
    Result := 'AnsiString'
  else
    Result := ClassName;
end;

{ TPressString }

class function TPressString.AttributeName: string;
begin
  Result := 'String';
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
  if (Source is TPressInteger) and (TPressInteger(Source).State = asValue) then
    PubValue := TPressInteger(Source).PubValue
  else
    inherited;
end;

class function TPressInteger.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attInteger;
end;

class function TPressInteger.AttributeName: string;
begin
  if Self = TPressInteger then
    Result := 'Integer'
  else
    Result := ClassName;
end;

procedure TPressInteger.ClearPersistenceData;
begin
  inherited;
  FDiff := 0;
end;

procedure TPressInteger.Decrement(AValue: Integer);
begin
  Increment(-AValue);
end;

class function TPressInteger.EmptyValue: Variant;
begin
  Result := 0;
end;

function TPressInteger.GetAsFloat: Double;
begin
  Result := PubValue;
end;

function TPressInteger.GetAsInteger: Integer;
begin
  Result := PubValue;
end;

function TPressInteger.GetAsString: string;
begin
  if IsNull then
    Result := ''
  else
    Result := IntToStr(PubValue);
end;

function TPressInteger.GetAsVariant: Variant;
begin
  Result := PubValue;
end;

function TPressInteger.GetIsEmpty: Boolean;
begin
  Result := PubValue = 0;
end;

function TPressInteger.GetIsRelativelyChanged: Boolean;
begin
  Result := FDiff <> 0;
end;

function TPressInteger.GetOldValue: Integer;
begin
  Result := (OldAttribute as TPressInteger).Value;
end;

function TPressInteger.GetPubValue: Integer;
begin
  if UsePublishedGetter then
    Result := GetOrdProp(Owner, Metadata.Name)
  else
    Result := Value;
end;

function TPressInteger.GetValue: Integer;
begin
  Synchronize;
  Result := FValue;
end;

procedure TPressInteger.Increment(AValue: Integer);
begin
  if (AValue <> 0) and (State <> asNull) then
  begin
    Changing;
    FValue := FValue + AValue;
    if (FDiff <> 0) or not IsChanged then
      FDiff := FDiff + AValue;
    ValueAssigned;
  end;
end;

procedure TPressInteger.InternalReset;
begin
  inherited;
  FValue := 0;
end;

function TPressInteger.InternalTypeKinds: TTypeKinds;
begin
  Result := [tkInteger];
end;

procedure TPressInteger.SetAsFloat(AValue: Double);
begin
  PubValue := Round(AValue);
end;

procedure TPressInteger.SetAsInteger(AValue: Integer);
begin
  PubValue := AValue;
end;

procedure TPressInteger.SetAsString(const AValue: string);
begin
  try
    if AValue = '' then
      Clear
    else
      PubValue := StrToInt(AValue);
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
    if VarIsEmpty(AValue) or VarIsNull(AValue) then
      Clear
    else
      PubValue := AValue;
  except
    on E: EVariantError do
      raise InvalidValueError(AValue, E);
    else
      raise;
  end;
end;

procedure TPressInteger.SetPubValue(AValue: Integer);
begin
  if UsePublishedSetter then
    SetOrdProp(Owner, Metadata.Name, AValue)
  else
    Value := AValue;
end;

procedure TPressInteger.SetValue(AValue: Integer);
begin
  if State = asNotLoaded then
    Synchronize;
  if (FValue <> AValue) or (State = asNull) then
  begin
    Changing;
    FValue := AValue;
    FDiff := 0;
    ValueAssigned;
  end;
end;

{ TPressFloat }

procedure TPressFloat.Assign(Source: TPersistent);
begin
  if (Source is TPressFloat) and (TPressFloat(Source).State = asValue) then
    PubValue := TPressFloat(Source).PubValue
  else
    inherited;
end;

class function TPressFloat.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attFloat;
end;

class function TPressFloat.AttributeName: string;
begin
  if Self = TPressFloat then
    Result := 'Float'
  else
    Result := ClassName;
end;

procedure TPressFloat.ClearPersistenceData;
begin
  inherited;
  FDiff := 0;
end;

procedure TPressFloat.Decrement(AValue: Double);
begin
  Increment(-AValue);
end;

class function TPressFloat.EmptyValue: Variant;
begin
  Result := 0.0;
end;

function TPressFloat.GetAsFloat: Double;
begin
  Result := PubValue;
end;

function TPressFloat.GetAsInteger: Integer;
begin
  Result := Round(PubValue);
end;

function TPressFloat.GetAsString: string;
begin
  if IsNull then
    Result := ''
  else
    Result := FloatToStr(PubValue);
end;

function TPressFloat.GetAsVariant: Variant;
begin
  Result := PubValue;
end;

function TPressFloat.GetIsEmpty: Boolean;
begin
  Result := PubValue = 0;
end;

function TPressFloat.GetIsRelativelyChanged: Boolean;
begin
  Result := FDiff <> 0;
end;

function TPressFloat.GetOldValue: Double;
begin
  Result := (OldAttribute as TPressFloat).Value;
end;

function TPressFloat.GetPubValue: Double;
begin
  if UsePublishedGetter then
    Result := GetFloatProp(Owner, Metadata.Name)
  else
    Result := Value;
end;

function TPressFloat.GetValue: Double;
begin
  Synchronize;
  Result := FValue;
end;

procedure TPressFloat.Increment(AValue: Double);
begin
  if (AValue <> 0) and (State <> asNull) then
  begin
    Changing;
    FValue := FValue + AValue;
    if (FDiff <> 0) or not IsChanged then
      FDiff := FDiff + AValue;
    ValueAssigned;
  end;
end;

procedure TPressFloat.InternalReset;
begin
  inherited;
  FValue := 0;
end;

function TPressFloat.InternalTypeKinds: TTypeKinds;
begin
  Result := [tkFloat];
end;

procedure TPressFloat.SetAsFloat(AValue: Double);
begin
  PubValue := AValue;
end;

procedure TPressFloat.SetAsInteger(AValue: Integer);
begin
  PubValue := AValue;
end;

procedure TPressFloat.SetAsString(const AValue: string);
begin
  try
    if AValue = '' then
      Clear
    else
      PubValue := StrToFloat(AValue)
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
    if VarIsEmpty(AValue) or VarIsNull(AValue) then
      Clear
    else
      PubValue := AValue;
  except
    on E: EVariantError do
      raise InvalidValueError(AValue, E);
    else
      raise;
  end;
end;

procedure TPressFloat.SetPubValue(AValue: Double);
begin
  if UsePublishedSetter then
    SetFloatProp(Owner, Metadata.Name, AValue)
  else
    Value := AValue;
end;

procedure TPressFloat.SetValue(AValue: Double);
begin
  if State = asNotLoaded then
    Synchronize;
  if (FValue <> AValue) or (State = asNull) then
  begin
    Changing;
    FValue := AValue;
    FDiff := 0;
    ValueAssigned;
  end;
end;

{ TPressCurrency }

procedure TPressCurrency.Assign(Source: TPersistent);
begin
  if (Source is TPressCurrency) and (TPressCurrency(Source).State = asValue) then
    PubValue := TPressCurrency(Source).PubValue
  else
    inherited;
end;

class function TPressCurrency.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attCurrency;
end;

class function TPressCurrency.AttributeName: string;
begin
  if Self = TPressCurrency then
    Result := 'Currency'
  else
    Result := ClassName;
end;

procedure TPressCurrency.ClearPersistenceData;
begin
  inherited;
  FDiff := 0;
end;

procedure TPressCurrency.Decrement(AValue: Currency);
begin
  Increment(-AValue);
end;

class function TPressCurrency.EmptyValue: Variant;
begin
  Result := 0.0;
end;

function TPressCurrency.GetAsCurrency: Currency;
begin
  Result := PubValue;
end;

function TPressCurrency.GetAsFloat: Double;
begin
  Result := PubValue;
end;

function TPressCurrency.GetAsInteger: Integer;
begin
  Result := Round(PubValue);
end;

function TPressCurrency.GetAsString: string;
begin
  if IsNull then
    Result := ''
  else
    Result := CurrToStr(PubValue);
end;

function TPressCurrency.GetAsVariant: Variant;
begin
  Result := PubValue;
end;

function TPressCurrency.GetDisplayText: string;
begin
  if IsNull then
    Result := ''
  else if EditMask <> '' then
    Result := FormatCurr(EditMask, PubValue)
  else
    Result := AsString;
end;

function TPressCurrency.GetIsEmpty: Boolean;
begin
  Result := PubValue = 0;
end;

function TPressCurrency.GetIsRelativelyChanged: Boolean;
begin
  Result := FDiff <> 0;
end;

function TPressCurrency.GetOldValue: Currency;
begin
  Result := (OldAttribute as TPressCurrency).Value;
end;

function TPressCurrency.GetPubValue: Currency;
begin
  if UsePublishedGetter then
    Result := GetFloatProp(Owner, Metadata.Name)
  else
    Result := Value;
end;

function TPressCurrency.GetValue: Currency;
begin
  Synchronize;
  Result := FValue;
end;

procedure TPressCurrency.Increment(AValue: Currency);
begin
  if (AValue <> 0) and (State <> asNull) then
  begin
    Changing;
    FValue := FValue + AValue;
    if (FDiff <> 0) or not IsChanged then
      FDiff := FDiff + AValue;
    ValueAssigned;
  end;
end;

procedure TPressCurrency.InternalReset;
begin
  inherited;
  FValue := 0;
end;

function TPressCurrency.InternalTypeKinds: TTypeKinds;
begin
  Result := [tkFloat];
end;

procedure TPressCurrency.SetAsCurrency(AValue: Currency);
begin
  PubValue := AValue;
end;

procedure TPressCurrency.SetAsFloat(AValue: Double);
begin
  PubValue := AValue;
end;

procedure TPressCurrency.SetAsInteger(AValue: Integer);
begin
  PubValue := AValue;
end;

procedure TPressCurrency.SetAsString(const AValue: string);
begin
  try
    if AValue = '' then
      Clear
    else
      PubValue := StrToCurr(AValue)
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
    if VarIsEmpty(AValue) or VarIsNull(AValue) then
      Clear
    else
      PubValue := AValue;
  except
    on E: EVariantError do
      raise InvalidValueError(AValue, E);
    else
      raise;
  end;
end;

procedure TPressCurrency.SetPubValue(AValue: Currency);
begin
  if UsePublishedSetter then
    SetFloatProp(Owner, Metadata.Name, AValue)
  else
    Value := AValue;
end;

procedure TPressCurrency.SetValue(AValue: Currency);
begin
  if State = asNotLoaded then
    Synchronize;
  if (FValue <> AValue) or (State = asNull) then
  begin
    Changing;
    FValue := AValue;
    FDiff := 0;
    ValueAssigned;
  end;
end;

{ TPressEnum }

procedure TPressEnum.Assign(Source: TPersistent);
begin
  if (Source is TPressEnum) and (TPressEnum(Source).State = asValue) then
    PubValue := TPressEnum(Source).PubValue
  else
    inherited;
end;

class function TPressEnum.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attEnum;
end;

class function TPressEnum.AttributeName: string;
begin
  if Self = TPressEnum then
    Result := 'Enum'
  else
    Result := ClassName;
end;

class function TPressEnum.EmptyValue: Variant;
begin
  Result := 0;
end;

function TPressEnum.GetAsBoolean: Boolean;
begin
  Result := IsNull;
end;

function TPressEnum.GetAsDate: TDate;
begin
  Result := PubValue;
end;

function TPressEnum.GetAsDateTime: TDateTime;
begin
  Result := PubValue;
end;

function TPressEnum.GetAsFloat: Double;
begin
  Result := PubValue;
end;

function TPressEnum.GetAsInteger: Integer;
begin
  Result := PubValue;
end;

function TPressEnum.GetAsString: string;
begin
  if IsNull then
    Result := ''
  else
    Result := Metadata.EnumMetadata.Items[PubValue];
end;

function TPressEnum.GetAsTime: TTime;
begin
  Result := 0;
end;

function TPressEnum.GetAsVariant: Variant;
begin
  Result := PubValue;
end;

function TPressEnum.GetIsEmpty: Boolean;
begin
  Result := IsNull;
end;

function TPressEnum.GetOldValue: Integer;
begin
  Result := (OldAttribute as TPressEnum).Value;
end;

function TPressEnum.GetPubValue: Integer;
begin
  if UsePublishedGetter then
    Result := GetOrdProp(Owner, Metadata.Name)
  else
    Result := Value;
end;

function TPressEnum.GetValue: Integer;
begin
  Synchronize;
  if (FValue < 0) or
   (Assigned(Metadata) and (FValue >= Metadata.EnumMetadata.Count)) then
    raise EPressError.CreateFmt(SEnumOutOfBounds, [Name, FValue]);
  Result := FValue;
end;

procedure TPressEnum.InternalReset;
begin
  inherited;
  FValue := -1;
end;

function TPressEnum.InternalTypeKinds: TTypeKinds;
begin
  Result := [tkEnumeration];
end;

function TPressEnum.SameValue(AValue: Integer): Boolean;
begin
  Result := not IsEmpty and (FValue = AValue);
end;

procedure TPressEnum.SetAsBoolean(AValue: Boolean);
begin
  PubValue := Ord(AValue);
end;

procedure TPressEnum.SetAsDate(AValue: TDate);
begin
  PubValue := Trunc(AValue);
end;

procedure TPressEnum.SetAsDateTime(AValue: TDateTime);
begin
  PubValue := Trunc(AValue);
end;

procedure TPressEnum.SetAsFloat(AValue: Double);
begin
  PubValue := Round(AValue);
end;

procedure TPressEnum.SetAsInteger(AValue: Integer);
begin
  PubValue := AValue;
end;

procedure TPressEnum.SetAsString(const AValue: string);
var
  VIndex: Integer;
begin
  if AValue = '' then
    Clear
  else
  begin
    VIndex := GetEnumValue(Metadata.EnumMetadata.TypeAddress, AValue);
    if VIndex = -1 then
      VIndex := Metadata.EnumMetadata.IndexOf(AValue);
    if VIndex <> -1 then
      PubValue := VIndex
    else
      raise EPressError.CreateFmt(SEnumItemNotFound, [AValue]);
  end;
end;

procedure TPressEnum.SetAsTime(AValue: TTime);
begin
  PubValue := 0;
end;

procedure TPressEnum.SetAsVariant(AValue: Variant);
begin
  try
    if VarIsEmpty(AValue) or VarIsNull(AValue) then
      Clear
    else
      PubValue := AValue;
  except
    on E: EVariantError do
      raise InvalidValueError(AValue, E);
    else
      raise;
  end;
end;

procedure TPressEnum.SetPubValue(AValue: Integer);
begin
  if UsePublishedSetter then
    SetOrdProp(Owner, Metadata.Name, AValue)
  else
    Value := AValue;
end;

procedure TPressEnum.SetValue(AValue: Integer);
begin
  if State = asNotLoaded then
    Synchronize;
  if AValue = -1 then
    Clear
  else if (FValue <> AValue) or (State = asNull) then
  begin
    Changing;
    FValue := AValue;
    ValueAssigned;
  end;
end;

{ TPressBoolean }

procedure TPressBoolean.Assign(Source: TPersistent);
begin
  if (Source is TPressBoolean) and (TPressBoolean(Source).State = asValue) then
    PubValue := TPressBoolean(Source).PubValue
  else
    inherited;
end;

class function TPressBoolean.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attBoolean;
end;

class function TPressBoolean.AttributeName: string;
begin
  if Self = TPressBoolean then
    Result := 'Boolean'
  else
    Result := ClassName;
end;

class function TPressBoolean.EmptyValue: Variant;
begin
  Result := False;
end;

function TPressBoolean.GetAsBoolean: Boolean;
begin
  Result := PubValue;
end;

function TPressBoolean.GetAsFloat: Double;
begin
  Result := AsInteger;
end;

function TPressBoolean.GetAsInteger: Integer;
begin
  Result := Integer(PubValue);
end;

function TPressBoolean.GetAsString: string;
begin
  if IsNull then
    Result := ''
  else
    Result := FValues[PubValue];
end;

function TPressBoolean.GetAsVariant: Variant;
begin
  Result := PubValue;
end;

function TPressBoolean.GetDisplayText: string;
begin
  Result := AsString;
end;

function TPressBoolean.GetOldValue: Boolean;
begin
  Result := (OldAttribute as TPressBoolean).Value;
end;

function TPressBoolean.GetPubValue: Boolean;
begin
  if UsePublishedGetter then
    Result := Boolean(GetOrdProp(Owner, Metadata.Name))
  else
    Result := Value;
end;

function TPressBoolean.GetValue: Boolean;
begin
  Synchronize;
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
  if State = asNull then
    Value := False;
end;

procedure TPressBoolean.InternalReset;
begin
  inherited;
  FValue := False;
end;

function TPressBoolean.InternalTypeKinds: TTypeKinds;
begin
  Result := [{$IFDEF FPC}tkBool{$ELSE}tkEnumeration{$ENDIF}];
end;

procedure TPressBoolean.SetAsBoolean(AValue: Boolean);
begin
  PubValue := AValue;
end;

procedure TPressBoolean.SetAsFloat(AValue: Double);
begin
  AsInteger := Round(AValue);
end;

procedure TPressBoolean.SetAsInteger(AValue: Integer);
begin
  PubValue := Boolean(AValue);
end;

procedure TPressBoolean.SetAsString(const AValue: string);
begin
  if AValue = '' then
    Clear
  else if SameText(AValue, SPressTrueString) then
    PubValue := True
  else if SameText(AValue, SPressFalseString) then
    PubValue := False
  else
    raise ConversionError(nil);
end;

procedure TPressBoolean.SetAsVariant(AValue: Variant);
begin
  try
    if VarIsEmpty(AValue) or VarIsNull(AValue) then
      Clear
    else
      PubValue := AValue;
  except
    on E: EVariantError do
      raise InvalidValueError(AValue, E);
    else
      raise;
  end;
end;

procedure TPressBoolean.SetPubValue(AValue: Boolean);
begin
  if UsePublishedSetter then
    SetOrdProp(Owner, Metadata.Name, Integer(AValue))
  else
    Value := AValue;
end;

procedure TPressBoolean.SetValue(AValue: Boolean);
begin
  if State = asNotLoaded then
    Synchronize;
  if (FValue <> AValue) or (State = asNull) then
  begin
    Changing;
    FValue := AValue;
    ValueAssigned;
  end;
end;

{ TPressDate }

procedure TPressDate.Assign(Source: TPersistent);
begin
  if (Source is TPressDate) and (TPressDate(Source).State = asValue) then
    PubValue := TPressDate(Source).PubValue
  else
    inherited;
end;

class function TPressDate.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attDate;
end;

class function TPressDate.AttributeName: string;
begin
  if Self = TPressDate then
    Result := 'Date'
  else
    Result := ClassName;
end;

class function TPressDate.EmptyValue: Variant;
begin
  Result := 0;
end;

function TPressDate.GetAsDate: TDate;
begin
  Result := PubValue;
end;

function TPressDate.GetAsDateTime: TDateTime;
begin
  Result := PubValue;
end;

function TPressDate.GetAsFloat: Double;
begin
  Result := PubValue;
end;

function TPressDate.GetAsString: string;
var
  VValue: TDate;
begin
  VValue := PubValue;
  if IsNull or (VValue = 0) then
    Result := ''
  else
    Result := DateToStr(VValue);
end;

function TPressDate.GetAsTime: TTime;
begin
  Result := 0;
end;

function TPressDate.GetAsVariant: Variant;
begin
  Result := PubValue;
end;

function TPressDate.GetDisplayText: string;
var
  VValue: TDate;
begin
  VValue := PubValue;
  if IsNull or (VValue = 0) then
    Result := ''
  else if EditMask <> '' then
    Result := FormatDateTime(EditMask, VValue)
  else
    Result := DateToStr(VValue);
end;

function TPressDate.GetOldValue: TDate;
begin
  Result := (OldAttribute as TPressDate).Value;
end;

function TPressDate.GetPubValue: TDate;
begin
  if UsePublishedGetter then
    Result := GetFloatProp(Owner, Metadata.Name)
  else
    Result := Value;
end;

function TPressDate.GetValue: TDate;
begin
  Synchronize;
  Result := FValue;
end;

procedure TPressDate.Initialize;
begin
  if SameText(DefaultValue, 'now') then
    PubValue := Date
  else
    inherited;
end;

procedure TPressDate.InternalReset;
begin
  inherited;
  FValue := 0;
end;

function TPressDate.InternalTypeKinds: TTypeKinds;
begin
  Result := [tkFloat];
end;

procedure TPressDate.SetAsDate(AValue: TDate);
begin
  PubValue := AValue;
end;

procedure TPressDate.SetAsDateTime(AValue: TDateTime);
begin
  PubValue := AValue;
end;

procedure TPressDate.SetAsFloat(AValue: Double);
begin
  PubValue := AValue;
end;

procedure TPressDate.SetAsString(const AValue: string);
begin
  try
    if AValue = '' then
      Clear
    else
      PubValue := StrToDate(AValue);
  except
    on E: EConvertError do
      raise ConversionError(E);
    else
      raise;
  end;
end;

procedure TPressDate.SetAsTime(AValue: TTime);
begin
  PubValue := 0;
end;

procedure TPressDate.SetAsVariant(AValue: Variant);
begin
  try
    if VarIsEmpty(AValue) or VarIsNull(AValue) then
      Clear
    else
      PubValue := AValue;
  except
    on E: EVariantError do
      raise InvalidValueError(AValue, E);
    else
      raise;
  end;
end;

procedure TPressDate.SetPubValue(AValue: TDate);
begin
  if UsePublishedSetter then
    SetFloatProp(Owner, Metadata.Name, AValue)
  else
    Value := AValue;
end;

procedure TPressDate.SetValue(AValue: TDate);
begin
  if State = asNotLoaded then
    Synchronize;
  if (FValue <> AValue) or (State = asNull) then
  begin
    Changing;
    if AValue = 0 then
      Clear
    else
    begin
      FValue := Int(AValue);
      ValueAssigned;
    end;
  end;
end;

{ TPressTime }

procedure TPressTime.Assign(Source: TPersistent);
begin
  if (Source is TPressTime) and (TPressTime(Source).State = asValue) then
    PubValue := TPressTime(Source).PubValue
  else
    inherited;
end;

class function TPressTime.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attTime;
end;

class function TPressTime.AttributeName: string;
begin
  if Self = TPressTime then
    Result := 'Time'
  else
    Result := ClassName;
end;

class function TPressTime.EmptyValue: Variant;
begin
  Result := 0;
end;

function TPressTime.GetAsDate: TDate;
begin
  Result := 0;
end;

function TPressTime.GetAsDateTime: TDateTime;
begin
  Result := PubValue;
end;

function TPressTime.GetAsFloat: Double;
begin
  Result := PubValue;
end;

function TPressTime.GetAsString: string;
begin
  if IsNull then
    Result := ''
  else
    Result := TimeToStr(PubValue);
end;

function TPressTime.GetAsTime: TTime;
begin
  Result := PubValue;
end;

function TPressTime.GetAsVariant: Variant;
begin
  Result := PubValue;
end;

function TPressTime.GetDisplayText: string;
begin
  if IsNull then
    Result := ''
  else if EditMask <> '' then
    Result := FormatDateTime(EditMask, PubValue)
  else
    Result := AsString;
end;

function TPressTime.GetOldValue: TTime;
begin
  Result := (OldAttribute as TPressTime).Value;
end;

function TPressTime.GetPubValue: TTime;
begin
  if UsePublishedGetter then
    Result := GetFloatProp(Owner, Metadata.Name)
  else
    Result := Value;
end;

function TPressTime.GetValue: TTime;
begin
  Synchronize;
  Result := FValue;
end;

procedure TPressTime.Initialize;
begin
  if SameText(DefaultValue, 'now') then
    PubValue := Time
  else
    inherited;
end;

procedure TPressTime.InternalReset;
begin
  inherited;
  FValue := 0;
end;

function TPressTime.InternalTypeKinds: TTypeKinds;
begin
  Result := [tkFloat];
end;

procedure TPressTime.SetAsDate(AValue: TDate);
begin
  PubValue := 0;
end;

procedure TPressTime.SetAsDateTime(AValue: TDateTime);
begin
  PubValue := AValue;
end;

procedure TPressTime.SetAsFloat(AValue: Double);
begin
  PubValue := AValue;
end;

procedure TPressTime.SetAsString(const AValue: string);
begin
  try
    if AValue = '' then
      Clear
    else
      PubValue := StrToTime(AValue);
  except
    on E: EConvertError do
      raise ConversionError(E);
    else
      raise;
  end;
end;

procedure TPressTime.SetAsTime(AValue: TTime);
begin
  PubValue := AValue;
end;

procedure TPressTime.SetAsVariant(AValue: Variant);
begin
  try
    if VarIsEmpty(AValue) or VarIsNull(AValue) then
      Clear
    else
      PubValue := AValue;
  except
    on E: EVariantError do
      raise InvalidValueError(AValue, E);
    else
      raise;
  end;
end;

procedure TPressTime.SetPubValue(AValue: TTime);
begin
  if UsePublishedSetter then
    SetFloatProp(Owner, Metadata.Name, AValue)
  else
    Value := AValue;
end;

procedure TPressTime.SetValue(AValue: TTime);
begin
  if State = asNotLoaded then
    Synchronize;
  if (FValue <> AValue) or (State = asNull) then
  begin
    Changing;
    FValue := Frac(AValue);
    ValueAssigned;
  end;
end;

{ TPressDateTime }

procedure TPressDateTime.Assign(Source: TPersistent);
begin
  if (Source is TPressDateTime) and (TPressDateTime(Source).State = asValue) then
    PubValue := TPressDateTime(Source).PubValue
  else
    inherited;
end;

class function TPressDateTime.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attDateTime;
end;

class function TPressDateTime.AttributeName: string;
begin
  if Self = TPressDateTime then
    Result := 'DateTime'
  else
    Result := ClassName;
end;

class function TPressDateTime.EmptyValue: Variant;
begin
  Result := 0;
end;

function TPressDateTime.GetAsDate: TDate;
begin
  Result := Int(PubValue);
end;

function TPressDateTime.GetAsDateTime: TDateTime;
begin
  Result := PubValue;
end;

function TPressDateTime.GetAsFloat: Double;
begin
  Result := PubValue;
end;

function TPressDateTime.GetAsString: string;
var
  VValue: TDateTime;
begin
  VValue := PubValue;
  if VValue = 0 then
    Result := ''
  else if VValue < 1 then
    Result := TimeToStr(VValue)
  else
    Result := DateTimeToStr(VValue);
end;

function TPressDateTime.GetAsTime: TTime;
begin
  Result := Frac(PubValue);
end;

function TPressDateTime.GetAsVariant: Variant;
begin
  Result := PubValue;
end;

function TPressDateTime.GetDisplayText: string;
var
  VValue: TDateTime;
begin
  VValue := PubValue;
  if VValue = 0 then
    Result := ''
  else if EditMask <> '' then
    Result := FormatDateTime(EditMask, VValue)
  else if VValue < 1 then
    Result := TimeToStr(VValue)
  else
    Result := DateTimeToStr(VValue);
end;

function TPressDateTime.GetOldValue: TDateTime;
begin
  Result := (OldAttribute as TPressDateTime).Value;
end;

function TPressDateTime.GetPubValue: TDateTime;
begin
  if UsePublishedGetter then
    Result := GetFloatProp(Owner, Metadata.Name)
  else
    Result := Value;
end;

function TPressDateTime.GetValue: TDateTime;
begin
  Synchronize;
  Result := FValue;
end;

procedure TPressDateTime.Initialize;
begin
  if SameText(DefaultValue, 'now') then
    PubValue := Now
  else
    inherited;
end;

procedure TPressDateTime.InternalReset;
begin
  inherited;
  FValue := 0;
end;

function TPressDateTime.InternalTypeKinds: TTypeKinds;
begin
  Result := [tkFloat];
end;

procedure TPressDateTime.SetAsDate(AValue: TDate);
begin
  PubValue := Int(AValue);
end;

procedure TPressDateTime.SetAsDateTime(AValue: TDateTime);
begin
  PubValue := AValue;
end;

procedure TPressDateTime.SetAsFloat(AValue: Double);
begin
  PubValue := AValue;
end;

procedure TPressDateTime.SetAsString(const AValue: string);
begin
  try
    if AValue = '' then
      Clear
    else
      PubValue := StrToDateTime(AValue);
  except
    on E: EConvertError do
      raise ConversionError(E);
    else
      raise;
  end;
end;

procedure TPressDateTime.SetAsTime(AValue: TTime);
begin
  PubValue := Frac(AValue);
end;

procedure TPressDateTime.SetAsVariant(AValue: Variant);
begin
  try
    if VarIsEmpty(AValue) or VarIsNull(AValue) then
      Clear
    else
      PubValue := AValue;
  except
    on E: EVariantError do
      raise InvalidValueError(AValue, E);
    else
      raise;
  end;
end;

procedure TPressDateTime.SetPubValue(AValue: TDateTime);
begin
  if UsePublishedSetter then
    SetFloatProp(Owner, Metadata.Name, AValue)
  else
    Value := AValue;
end;

procedure TPressDateTime.SetValue(AValue: TDateTime);
begin
  if State = asNotLoaded then
    Synchronize;
  if (FValue <> AValue) or (State = asNull) then
  begin
    Changing;
    if AValue = 0 then
      Clear
    else
    begin
      FValue := AValue;
      ValueAssigned;
    end;
  end;
end;

{ TPressVariant }

procedure TPressVariant.Assign(Source: TPersistent);
begin
  if Source is TPressVariant then
    PubValue := TPressVariant(Source).PubValue
  else
    inherited;
end;

class function TPressVariant.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attVariant;
end;

class function TPressVariant.AttributeName: string;
begin
  if Self = TPressVariant then
    Result := 'Variant'
  else
    Result := ClassName;
end;

class function TPressVariant.EmptyValue: Variant;
begin
  Result := varEmpty;
end;

function TPressVariant.GetAsBoolean: Boolean;
var
  VValue: Variant;
begin
  VValue := PubValue;
  try
    Result := VValue;
  except
    on E: EVariantError do
      raise InvalidValueError(VValue, E);
    else
      raise;
  end;
end;

function TPressVariant.GetAsDate: TDate;
var
  VValue: Variant;
begin
  VValue := PubValue;
  try
    Result := VValue;
  except
    on E: EVariantError do
      raise InvalidValueError(VValue, E);
    else
      raise;
  end;
end;

function TPressVariant.GetAsDateTime: TDateTime;
var
  VValue: Variant;
begin
  VValue := PubValue;
  try
    Result := VValue;
  except
    on E: EVariantError do
      raise InvalidValueError(VValue, E);
    else
      raise;
  end;
end;

function TPressVariant.GetAsFloat: Double;
var
  VValue: Variant;
begin
  VValue := PubValue;
  try
    Result := VValue;
  except
    on E: EVariantError do
      raise InvalidValueError(VValue, E);
    else
      raise;
  end;
end;

function TPressVariant.GetAsInteger: Integer;
var
  VValue: Variant;
begin
  VValue := PubValue;
  try
    Result := VValue;
  except
    on E: EVariantError do
      raise InvalidValueError(VValue, E);
    else
      raise;
  end;
end;

function TPressVariant.GetAsString: string;
var
  VValue: Variant;
begin
  VValue := PubValue;
  try
    if IsNull then
      Result := ''
    else
      Result := VValue;
  except
    on E: EVariantError do
      raise InvalidValueError(VValue, E);
    else
      raise;
  end;
end;

function TPressVariant.GetAsTime: TTime;
var
  VValue: Variant;
begin
  VValue := PubValue;
  try
    Result := VValue;
  except
    on E: EVariantError do
      raise InvalidValueError(VValue, E);
    else
      raise;
  end;
end;

function TPressVariant.GetAsVariant: Variant;
begin
  Result := PubValue;
end;

function TPressVariant.GetOldValue: Variant;
begin
  Result := (OldAttribute as TPressVariant).Value;
end;

function TPressVariant.GetPubValue: Variant;
begin
  if UsePublishedGetter then
    Result := GetVariantProp(Owner, Metadata.Name)
  else
    Result := Value;
end;

function TPressVariant.GetValue: Variant;
begin
  Synchronize;
  Result := FValue;
end;

procedure TPressVariant.InternalReset;
begin
  inherited;
  FValue := Null;
end;

function TPressVariant.InternalTypeKinds: TTypeKinds;
begin
  Result := [tkVariant];
end;

procedure TPressVariant.SetAsBoolean(AValue: Boolean);
begin
  PubValue := AValue;
end;

procedure TPressVariant.SetAsDate(AValue: TDate);
begin
  PubValue := AValue;
end;

procedure TPressVariant.SetAsDateTime(AValue: TDateTime);
begin
  PubValue := AValue;
end;

procedure TPressVariant.SetAsFloat(AValue: Double);
begin
  PubValue := AValue;
end;

procedure TPressVariant.SetAsInteger(AValue: Integer);
begin
  PubValue := AValue;
end;

procedure TPressVariant.SetAsString(const AValue: string);
begin
  PubValue := AValue;
end;

procedure TPressVariant.SetAsTime(AValue: TTime);
begin
  PubValue := AValue;
end;

procedure TPressVariant.SetAsVariant(AValue: Variant);
begin
  PubValue := AValue;
end;

procedure TPressVariant.SetPubValue(AValue: Variant);
begin
  if UsePublishedSetter then
    SetVariantProp(Owner, Metadata.Name, AValue)
  else
    Value := AValue;
end;

procedure TPressVariant.SetValue(AValue: Variant);
begin
  if State = asNotLoaded then
    Synchronize;
  if (FValue <> AValue) or (State = asNull) then
  begin
    Changing;
    if VarIsEmpty(AValue) or VarIsNull(AValue) then
      Clear
    else
    begin
      FValue := AValue;
      ValueAssigned;
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
    ValueUnassigned;
  end;
end;

class function TPressBlob.EmptyValue: Variant;
begin
  Result := '';
end;

procedure TPressBlob.Finit;
begin
  FStream.Free;
  inherited;
end;

function TPressBlob.GetAsString: string;
begin
  Result := PubValue;
end;

function TPressBlob.GetAsVariant: Variant;
begin
  Result := PubValue;
end;

function TPressBlob.GetOldValue: string;
begin
  Result := (OldAttribute as TPressBlob).Value;
end;

function TPressBlob.GetPubValue: string;
begin
  if UsePublishedGetter then
    Result := GetStrProp(Owner, Metadata.Name)
  else
    Result := Value;
end;

function TPressBlob.GetSize: Integer;
begin
  if Assigned(FStream) then
    Result := FStream.Size
  else
    Result := 0;
end;

function TPressBlob.GetStream: TMemoryStream;
begin
  if not Assigned(FStream) then
    FStream := TMemoryStream.Create;
  Result := FStream;
end;

function TPressBlob.GetValue: string;
begin
  Synchronize;
  if Assigned(FStream) and (FStream.Size > 0) then
  begin
    SetLength(Result, FStream.Size);
    FStream.Position := 0;
    FStream.Read(Result[1], FStream.Size);
  end else
    Result := '';
end;

procedure TPressBlob.InternalReset;
begin
  inherited;
  if Assigned(FStream) and (FStream.Size > 0) then
    FStream.Clear;
end;

function TPressBlob.InternalTypeKinds: TTypeKinds;
begin
  Result := [tkString, tkLString, tkWString];
end;

procedure TPressBlob.LoadFromStream(AStream: TStream);
begin
  if Assigned(AStream) then
  begin
    Changing;
    Stream.LoadFromStream(AStream);
    ValueAssigned;
  end else
    Clear;
end;

procedure TPressBlob.SaveToStream(AStream: TStream);
begin
  Synchronize;
  if Assigned(AStream) then
    Stream.SaveToStream(AStream);
end;

procedure TPressBlob.SetAsString(const AValue: string);
begin
  PubValue := AValue;
end;

procedure TPressBlob.SetAsVariant(AValue: Variant);
begin
  try
    if VarIsEmpty(AValue) or VarIsNull(AValue) then
      Clear
    else
      PubValue := AValue;
  except
    on E: EVariantError do
      raise InvalidValueError(AValue, E);
    else
      raise;
  end;
end;

procedure TPressBlob.SetPubValue(const AValue: string);
begin
  if UsePublishedSetter then
    SetStrProp(Owner, Metadata.Name, AValue)
  else
    Value := AValue;
end;

procedure TPressBlob.SetValue(const AValue: string);
begin
  if State = asNotLoaded then
    Synchronize;
  if AValue <> '' then
    WriteBuffer(AValue[1], Length(AValue))
  else if State = asNull then
  begin
    Changing;
    ValueAssigned;
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
      ValueAssigned;
    end else
    begin
      Stream.Clear;
      ValueUnassigned;
    end;
  end;
end;

{ TPressMemo }

class function TPressMemo.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attMemo;
end;

class function TPressMemo.AttributeName: string;
begin
  if Self = TPressMemo then
    Result := 'Memo'
  else
    Result := ClassName;
end;

{ TPressBinary }

class function TPressBinary.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attBinary;
end;

class function TPressBinary.AttributeName: string;
begin
  if Self = TPressBinary then
    Result := 'Binary'
  else
    Result := ClassName;
end;

{ TPressItem }

procedure TPressItem.AddSessionIntf(const ASession: IPressSession);
begin
  inherited;
  if Assigned(FProxy) then
    TPressProxyFriend(FProxy).AddSessionIntf(ASession);
end;

procedure TPressItem.AfterChangeInstance(
  Sender: TPressProxy; Instance: TPressObject;
  ChangeType: TPressProxyChangeType);
begin
  inherited;
  if not Assigned(Instance) then
    Clear;
end;

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

function TPressItem.GetAsInteger: Integer;
begin
  try
    Result := StrToInt(AsString);
  except
    on E: EConvertError do
      raise ConversionError(E);
    else
      raise;
  end;
end;

function TPressItem.GetAsString: string;
begin
  if Proxy.HasInstance then
    Result := PubValue.Id
  else
    Result := Proxy.ObjectId;
end;

function TPressItem.GetAsVariant: Variant;
begin
  Result := AsString;
end;

function TPressItem.GetIsEmpty: Boolean;
begin
  Synchronize;
  Result := not Assigned(FProxy) or FProxy.IsEmpty; 
end;

function TPressItem.GetOldValue: TPressObject;
var
  VMemento: TPressItemMemento;
begin
  VMemento := inherited FindUnchangedMemento as TPressItemMemento;
  if Assigned(VMemento) and Assigned(VMemento.FProxyClone) then  // friend class
    Result := VMemento.FProxyClone.Instance  // friend class
  else
    Result := Value;
end;

function TPressItem.GetProxy: TPressProxy;
begin
  if not Assigned(FProxy) then
  begin
    FProxy := TPressProxy.Create(Session, InternalProxyType);
    BindProxy(FProxy);
  end;
  Synchronize;
  Result := FProxy;
end;

function TPressItem.GetPubValue: TPressObject;
begin
  if UsePublishedGetter then
    Result := TPressObject(GetObjectProp(Owner, Metadata.Name, TPressObject))
  else
    Result := Value;
end;

function TPressItem.GetSignature: string;
begin
  Synchronize;
  if Assigned(FProxy) then
  begin
    if FProxy.HasInstance then
      Result := FProxy.Instance.Signature
    else if FProxy.HasReference then
      Result := FProxy.ObjectId
    else
      Result := SPressNilString;
  end else
    Result := SPressNilString;
end;

function TPressItem.GetValue: TPressObject;
begin
  Result := Proxy.Instance;
end;

procedure TPressItem.InternalAssignObject(AObject: TPressObject);
begin
  PubValue := AObject;
end;

function TPressItem.InternalCreateMemento: TPressAttributeMemento;
begin
  Result := TPressItemMemento.Create(Self, Proxy);
end;

procedure TPressItem.InternalReset;
begin
  inherited;
  { TODO : Changed notification duplicated }
  if Assigned(FProxy) then
    FProxy.Instance := nil;
end;

function TPressItem.InternalTypeKinds: TTypeKinds;
begin
  Result := [tkClass];
end;

procedure TPressItem.InternalUnassignObject(AObject: TPressObject);
begin
  if Proxy.SameReference(AObject) then
    Proxy.ClearInstance;
end;

function TPressItem.SameReference(AObject: TPressObject): Boolean;
begin
  Synchronize;
  Result := (not Assigned(AObject) and not Assigned(FProxy)) or
   (Assigned(FProxy) and FProxy.SameReference(AObject));
end;

procedure TPressItem.RemoveSessionIntf(const ASession: IPressSession);
begin
  inherited;
  if Assigned(FProxy) then
    TPressProxyFriend(FProxy).RemoveSessionIntf(ASession);
end;

function TPressItem.SameReference(const ARefClass, ARefID: string): Boolean;
begin
  Result := Proxy.SameReference(ARefClass, ARefID);
end;

procedure TPressItem.SetAsInteger(AValue: Integer);
begin
  AsString := IntToStr(AValue);
end;

procedure TPressItem.SetAsString(const AValue: string);
begin
  if AValue = '' then
    Proxy.Clear
  else
    AssignReference(ObjectClass.ClassName, AValue);
end;

procedure TPressItem.SetAsVariant(AValue: Variant);
begin
  try
    if VarIsEmpty(AValue) or VarIsNull(AValue) then
      Proxy.Clear
    else
      AsString := VarToStr(AValue);
  except
    on E: EVariantError do
      raise InvalidValueError(AValue, E);
    else
      raise;
  end;
end;

procedure TPressItem.SetPubValue(AValue: TPressObject);
begin
  if UsePublishedSetter then
    SetObjectProp(Owner, Metadata.Name, AValue)
  else
    Value := AValue;
end;

procedure TPressItem.SetValue(AValue: TPressObject);
begin
  Proxy.Instance := AValue;
end;

{ TPressPart }

class function TPressPart.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attPart;
end;

class function TPressPart.AttributeName: string;
begin
  if Self = TPressPart then
    Result := 'Part'
  else
    Result := ClassName;
end;

procedure TPressPart.BeforeChangeInstance(
  Sender: TPressProxy; Instance: TPressObject;
  ChangeType: TPressProxyChangeType);
begin
  inherited;
  if Assigned(Instance) and Instance.IsOwned then
    raise EPressError.CreateFmt(SInstanceAlreadyOwned,
     [Instance.ClassType, Instance.Id]);
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
  TPressObjectFriend(AInstance).SetOwnerContext(Self);
end;

procedure TPressPart.ChangedItem(
  AInstance: TPressObject; AUpdateIsChangedFlag: Boolean);
begin
  inherited;
  ValueAssigned(AUpdateIsChangedFlag);
end;

procedure TPressPart.InternalAssignItem(AProxy: TPressProxy);
begin
  { TODO : AfterCreate called before assign the owner }
  PubValue := AProxy.Instance.Clone;
end;

function TPressPart.InternalProxyType: TPressProxyType;
begin
  Result := ptOwned;
end;

procedure TPressPart.InternalUnchanged;
begin
  inherited;
  if Assigned(FProxy) and FProxy.HasInstance then
    FProxy.Instance.Unchanged;
end;

procedure TPressPart.ReleaseInstance(AInstance: TPressObject);
begin
  inherited;
  TPressObjectFriend(AInstance).SetOwnerContext(nil);
end;

{ TPressReference }

class function TPressReference.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attReference;
end;

class function TPressReference.AttributeName: string;
begin
  if Self = TPressReference then
    Result := 'Reference'
  else
    Result := ClassName;
end;

procedure TPressReference.InternalAssignItem(AProxy: TPressProxy);
begin
  PubValue := AProxy.Instance;
end;

function TPressReference.InternalProxyType: TPressProxyType;
begin
  if Assigned(Metadata) and Metadata.WeakReference then
    Result := ptWeakReference
  else
    Result := ptShared;
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

function TPressItems.Add(AClass: TPressObjectClass): TPressObject;
begin
  Result := Insert(Count, AClass);
end;

function TPressItems.Add(AObject: TPressObject): Integer;
begin
  Result := ProxyList.AddInstance(AObject);
end;

function TPressItems.AddReference(const AClassName, AId: string): Integer;
begin
  Result := ProxyList.AddReference(AClassName, AId);
end;

procedure TPressItems.AddSessionIntf(const ASession: IPressSession);
begin
  inherited;
  if Assigned(FProxyList) then
    TPressProxyListFriend(FProxyList).AddSessionIntf(ASession);
end;

procedure TPressItems.AfterChangeInstance(
  Sender: TPressProxy; Instance: TPressObject;
  ChangeType: TPressProxyChangeType);
begin
  inherited;
  if ChangeType = pctAssigning then
    ChangedInstance(Instance);
end;

procedure TPressItems.Assign(Source: TPersistent);
begin
  if Source is TPressItems then
  begin
    BeginUpdate;
    try
      if Assigned(FProxyList) then
        FProxyList.Clear;
      with TPressItems(Source).CreateProxyIterator do
      try
        BeforeFirstItem;
        while NextItem do
          InternalAssignItem(CurrentItem);
      finally
        Free;
      end;
    finally
      EndUpdate;
    end;
  end else
    inherited;
end;

procedure TPressItems.AssignProxyList(AProxyList: TPressProxyList);
var
  I: Integer;
begin
  DisableChanges;
  try
    if Assigned(FProxyList) then
    begin
      if FProxyList.Count > 0 then
        Clear;
      FProxyList.Free;
    end;
    FProxyList := AProxyList;
    if Assigned(FProxyList) then
    begin
      FProxyList.OnChangeList := {$IFDEF FPC}@{$ENDIF}ChangedList;
      for I := 0 to Pred(FProxyList.Count) do
      begin
        ValidateProxy(FProxyList[I]);
        BindProxy(FProxyList[I]);
      end;
      Changed;
    end;
  finally
    EnableChanges;
  end;
end;

procedure TPressItems.ChangedInstance(
  AInstance: TPressObject; AUpdateIsChangedFlag: Boolean);
var
  VIndex: Integer;
begin
  if ChangesDisabled then
    Exit;
  VIndex := ProxyList.IndexOfInstance(AInstance);
  if VIndex >= 0 then
    TPressItemsChangedEvent.Create(
     Self, ProxyList[VIndex], VIndex, ietModify).Notify;
  ValueAssigned(AUpdateIsChangedFlag);
end;

procedure TPressItems.ChangedList(
  Sender: TPressProxyList; Item: TPressProxy; Action: TListNotification);

  procedure AddedProxy;
  begin
    AddedProxies.Add(Item);
    Item.AddRef;
  end;

  procedure RemovedProxy;
  var
    VIndex: Integer;
  begin
    if Assigned(FAddedProxies) then
    begin
      VIndex := FAddedProxies.IndexOf(Item);
      if VIndex >= 0 then
        FAddedProxies.Delete(VIndex);
    end else
      VIndex := -1;
    if VIndex = -1 then
    begin
      RemovedProxies.Add(Item);
      Item.AddRef;
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
          ValidateProxy(Item);
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
          AddedProxy;
          NotifyMemento(Item, isAdded);
        end;
      else {lnExtracted, lnDeleted}
        begin
          if Item.HasInstance then
            ReleaseInstance(Item.Instance);
          VEventType := ietRemove;
          VIndex := -1;
          RemovedProxy;
          { TODO : OldIndex? }
          NotifyMemento(Item, isDeleted, -1);
        end;
    end;
    TPressItemsChangedEvent.Create(Self, Item, VIndex, VEventType).Notify;
  end;

  procedure UpdateInstance;
  begin
    if Action = lnAdded then
    begin
      ValidateProxy(Item);
      BindProxy(Item);
    end else {lnExtracted, lnDeleted}
    begin
      if Item.HasInstance then
        ReleaseInstance(Item.Instance);
    end;
  end;

begin
  { TODO : Implement Updating state }
  if ChangesDisabled then
    UpdateInstance
  else
    DoChanges;
  if Count > 0 then
    ValueAssigned
  else
    ValueUnassigned;
end;

procedure TPressItems.ClearObjectCache;
begin
  if Assigned(FAddedProxies) then
    FAddedProxies.Clear;
  if Assigned(FRemovedProxies) then
    FRemovedProxies.Clear;
end;

function TPressItems.Count: Integer;
begin
  Synchronize;
  if Assigned(FProxyList) then
    Result := FProxyList.Count
  else
    Result := 0;
end;

function TPressItems.CreateIterator: TPressItemsIterator;
begin
  Result := InternalCreateIterator;
end;

function TPressItems.CreateProxyIterator: TPressProxyIterator;
begin
  Result := TPressProxyIterator.Create(ProxyList);
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
  FAddedProxies.Free;
  FRemovedProxies.Free;
  inherited;
end;

function TPressItems.FormatList(
  const AFormat, AConn: string; AParams: array of string): string;
begin
  Result := InternalFormatList(AFormat, AConn, AParams);
end;

function TPressItems.GetAddedProxies: TPressProxyList;
begin
  if not Assigned(FAddedProxies) then
    FAddedProxies := TPressProxyList.Create(Session, True, ptShared);
  Result := FAddedProxies;
end;

function TPressItems.GetIsEmpty: Boolean;
begin
  Result := Count = 0;
end;

function TPressItems.GetObjects(AIndex: Integer): TPressObject;
begin
  Result := ProxyList[AIndex].Instance;
end;

function TPressItems.GetProxyList: TPressProxyList;
begin
  if not Assigned(FProxyList) then
    AssignProxyList(TPressProxyList.Create(Session, True, InternalProxyType));
  Synchronize;
  Result := FProxyList;
end;

function TPressItems.GetRemovedProxies: TPressProxyList;
begin
  if not Assigned(FRemovedProxies) then
    FRemovedProxies := TPressProxyList.Create(Session, True, ptShared);
  Result := FRemovedProxies;
end;

function TPressItems.IndexOf(AObject: TPressObject): Integer;
begin
  Result := ProxyList.IndexOfInstance(AObject);
end;

function TPressItems.Insert(
  AIndex: Integer; AClass: TPressObjectClass): TPressObject;
begin
  if Assigned(AClass) then
    ValidateObjectClass(AClass)
  else
    AClass := ObjectClass;
  Result := TPressObject(AClass.NewInstance);
  try
    // lacks inherited Create
    TPressObjectFriend(Result).InitInstance;
    Insert(AIndex, Result);
    TPressObjectFriend(Result).AfterCreate;
    if InternalProxyType = ptShared then
      Result.Release;
  except
    if InternalProxyType = ptShared then
      FreeAndNil(Result);
    raise;
  end;
end;

procedure TPressItems.Insert(AIndex: Integer; AObject: TPressObject);
begin
  ProxyList.InsertInstance(AIndex, AObject);
end;

procedure TPressItems.InternalAssignObject(AObject: TPressObject);
begin
  Add(AObject);
end;

procedure TPressItems.InternalChanged(AChangedWhenDisabled: Boolean);
begin
  if AChangedWhenDisabled and (State <> asNotLoaded) then
  begin
    if Count > 0 then
      ValueAssigned(False)
    else
      ValueUnassigned(False);
    NotifyRebuild;
  end;
  inherited;
end;

function TPressItems.InternalCreateIterator: TPressItemsIterator;
begin
  Result := TPressItemsIterator.Create(ProxyList);
end;

function TPressItems.InternalCreateMemento: TPressAttributeMemento;
begin
  Result := TPressItemsMemento.Create(Self);
  if not Assigned(FMementos) then
    FMementos := TObjectList.Create(False);
  FMementos.Add(Result);
end;

function TPressItems.InternalFormatList(
  const AFormat, AConn: string; AParams: array of string): string;

  procedure ConcatObject(var ABuffer: string; AObject: TPressObject);
  var
    VVars: array of Variant;
    VStr: string;
    I: Integer;
  begin
    SetLength(VVars, Length(AParams));
    for I := 0 to Pred(Length(AParams)) do
      VVars[I] := AObject.Expression(AParams[I]);
    VStr := PressVarFormat(AFormat, VVars);
    if VStr <> '' then
      if ABuffer <> '' then
        ABuffer := ABuffer + AConn + VStr
      else
        ABuffer := VStr;
  end;

var
  I: Integer;
begin
  Result := '';
  for I := 0 to Pred(Count) do
    ConcatObject(Result, Objects[I]);
end;

procedure TPressItems.InternalReset;
begin
  inherited;
  if Assigned(FProxyList) and (FProxyList.Count > 0) then
  begin
    BeginUpdate;
    try
      TPressStructureUnassignObjectEvent.Create(Self, FProxyList).Notify;
      FProxyList.Clear;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TPressItems.InternalUnassignObject(AObject: TPressObject);
begin
  ProxyList.RemoveInstance(AObject);
end;

procedure TPressItems.InternalUnchanged;
begin
  inherited;
  ClearObjectCache;
end;

procedure TPressItems.NotifyMemento(
  AProxy: TPressProxy; AItemState: TPressItemState; AOldIndex: Integer);
begin
  if Assigned(FMementos) then
    TPressItemsMemento(FMementos.Last).Notify(AProxy, AItemState, AOldIndex);
end;

procedure TPressItems.NotifyRebuild;
begin
  if ChangesDisabled then
    Exit;
  TPressItemsChangedEvent.Create(Self, nil, -1, ietRebuild).Notify;
end;

procedure TPressItems.ReleaseMemento(AMemento: TPressItemsMemento);
begin
  if Assigned(FMementos) then
    FMementos.Extract(AMemento);
end;

function TPressItems.Remove(AObject: TPressObject): Integer;
begin
  Result := ProxyList.IndexOfInstance(AObject);
  if Result >= 0 then
    ProxyList.Delete(Result);
end;

function TPressItems.RemoveReference(AProxy: TPressProxy): Integer;
begin
  Result := ProxyList.IndexOfReference(AProxy.ObjectClassName, AProxy.ObjectID);
  if Result >= 0 then
    ProxyList.Delete(Result);
end;

procedure TPressItems.RemoveSessionIntf(const ASession: IPressSession);
begin
  inherited;
  if Assigned(FProxyList) then
    TPressProxyListFriend(FProxyList).RemoveSessionIntf(ASession);
end;

procedure TPressItems.SetObjects(AIndex: Integer; AValue: TPressObject);
begin
  ProxyList[AIndex].Instance := AValue;
end;

{ TPressItemsIterator }

function TPressItemsIterator.GetCurrentItem: TPressObject;
begin
  Result := inherited CurrentItem.Instance;
end;

{ TPressParts }

class function TPressParts.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attParts;
end;

class function TPressParts.AttributeName: string;
begin
  if Self = TPressParts then
    Result := 'Parts'
  else
    Result := ClassName;
end;

procedure TPressParts.BeforeChangeInstance(Sender: TPressProxy;
  Instance: TPressObject; ChangeType: TPressProxyChangeType);
begin
  inherited;
  if Assigned(Instance) and Instance.IsOwned then
    raise EPressError.CreateFmt(SInstanceAlreadyOwned,
     [Instance.ClassName, Instance.Id]);
  if not ChangesDisabled and (ChangeType = pctAssigning) then
    NotifyMemento(Sender, isModified);
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
    NotifyMemento(ProxyList[VIndex], isModified);
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
  TPressObjectFriend(AInstance).SetOwnerContext(Self);
end;

procedure TPressParts.ChangedItem(
  AInstance: TPressObject; AUpdateIsChangedFlag: Boolean);
begin
  inherited;
  ChangedInstance(AInstance, AUpdateIsChangedFlag);
end;

procedure TPressParts.InternalAssignItem(AProxy: TPressProxy);
begin
  Add(AProxy.ObjectClassType).Assign(AProxy.Instance);
end;

function TPressParts.InternalProxyType: TPressProxyType;
begin
  Result := ptOwned;
end;

procedure TPressParts.InternalUnchanged;
var
  I: Integer;
begin
  inherited;
  if State <> asNotLoaded then
    for I := 0 to Pred(Count) do
      with ProxyList[I] do
        if HasInstance then
          Instance.Unchanged;
end;

procedure TPressParts.ReleaseInstance(AInstance: TPressObject);
begin
  inherited;
  TPressObjectFriend(AInstance).SetOwnerContext(nil);
end;

{ TPressReferences }

class function TPressReferences.AttributeBaseType: TPressAttributeBaseType;
begin
  Result := attReferences;
end;

class function TPressReferences.AttributeName: string;
begin
  if Self = TPressReferences then
    Result := 'References'
  else
    Result := ClassName;
end;

procedure TPressReferences.InternalAssignItem(AProxy: TPressProxy);
begin
  Add(AProxy.Instance);
end;

function TPressReferences.InternalProxyType: TPressProxyType;
begin
  if Assigned(Metadata) and Metadata.WeakReference then
    Result := ptWeakReference
  else
    Result := ptShared;
end;

end.
