(*
  PressObjects, Base Persistence Classes
  Copyright (C) 2006-2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressPersistence;

{$I Press.inc}

interface

uses
  Contnrs,
  PressApplication,
  PressSubject,
  PressDAO;

type
  TPressPersistence = class;

  TPressOIDGeneratorClass = class of TPressOIDGenerator;

  TPressOIDGenerator = class(TPressService)
  protected
    function InternalGenerateOID(Sender: TPressPersistence; AObjectClass: TPressObjectClass; const AAttributeName: string): string; virtual;
    procedure InternalReleaseOID(Sender: TPressPersistence; AObjectClass: TPressObjectClass; const AAttributeName, AOID: string); virtual;
    class function InternalServiceType: TPressServiceType; override;
  public
    function GenerateOID(Sender: TPressPersistence; AObjectClass: TPressObjectClass; const AAttributeName: string): string;
    procedure ReleaseOID(Sender: TPressPersistence; AObjectClass: TPressObjectClass; const AAttributeName, AOID: string);
  end;

  TPressPersistence = class(TPressDAO)
  private
    FOIDGenerator: TPressOIDGenerator;
    function GetOIDGenerator: TPressOIDGenerator;
  protected
    function GetIdentifierQuotes: string; virtual;
    function GetStrQuote: Char; virtual;
    function InternalGenerateOID(AClass: TPressObjectClass; const AAttributeName: string): string; override;
    function InternalOIDGeneratorClass: TPressOIDGeneratorClass; virtual;
    property OIDGenerator: TPressOIDGenerator read GetOIDGenerator;
  public
    destructor Destroy; override;
    property IdentifierQuotes: string read GetIdentifierQuotes;
    property StrQuote: Char read GetStrQuote;
  end;

  TPressPersistentObjectLink = class(TObject)
  private
    FPersistentObject: TObject;
    FPressObject: TPressObject;
    procedure SetPersistentObject(AValue: TObject);
  public
    constructor Create(APressObject: TPressObject; APersistentObject: TObject);
    destructor Destroy; override;
    property PersistentObject: TObject read FPersistentObject write SetPersistentObject;
    property PressObject: TPressObject read FPressObject;
  end;

  TPressThirdPartyPersistenceCache = class(TPressDAOCache)
  private
    FPersistentObjectLinkList: TObjectList;
    function GetPersistentObjectLink(AIndex: Integer): TPressPersistentObjectLink;
  protected
    property PersistentObjectLinkList: TObjectList read FPersistentObjectLinkList;
  public
    constructor Create; override;
    destructor Destroy; override;
    function AddLink(APressObject: TPressObject; APersistentObject: TObject): Integer;
    function IndexOfLink(APressObject: TPressObject): Integer;
    procedure ReleaseObjects; override;
    function RemoveObject(AObject: TPressObject): Integer; override;
    property PersistentObjectLink[AIndex: Integer]: TPressPersistentObjectLink read GetPersistentObjectLink;
  end;

  TPressThirdPartyPersistence = class(TPressPersistence)
  private
    function GetCache: TPressThirdPartyPersistenceCache;
    function GetPersistentObject(APressObject: TPressObject): TObject;
    procedure SetPersistentObject(APressObject: TPressObject; AValue: TObject);
  protected
    function InternalCacheClass: TPressDAOCacheClass; override;
    property Cache: TPressThirdPartyPersistenceCache read GetCache;
    property PersistentObject[APressObject: TPressObject]: TObject read GetPersistentObject write SetPersistentObject;
  end;

implementation

uses
  SysUtils,
  PressCompatibility,
  PressConsts;

{ TPressOIDGenerator }

function TPressOIDGenerator.GenerateOID(
  Sender: TPressPersistence; AObjectClass: TPressObjectClass;
  const AAttributeName: string): string;
begin
  Result := InternalGenerateOID(Sender, AObjectClass, AAttributeName);
end;

function TPressOIDGenerator.InternalGenerateOID(
  Sender: TPressPersistence; AObjectClass: TPressObjectClass;
  const AAttributeName: string): string;
var
  VId: array[0..15] of Byte;
  I: Integer;
begin
  GenerateGUID(TGUID(VId));
  SetLength(Result, 32);
  for I := 0 to 15 do
    Move(IntToHex(VId[I], 2)[1], Result[2*I+1], 2);
end;

procedure TPressOIDGenerator.InternalReleaseOID(Sender: TPressPersistence;
  AObjectClass: TPressObjectClass; const AAttributeName, AOID: string);
begin
end;

class function TPressOIDGenerator.InternalServiceType: TPressServiceType;
begin
  Result := stOIDGenerator;
end;

procedure TPressOIDGenerator.ReleaseOID(Sender: TPressPersistence;
  AObjectClass: TPressObjectClass; const AAttributeName, AOID: string);
begin
  InternalReleaseOID(Sender, AObjectClass, AAttributeName, AOID);
end;

{ TPressPersistence }

destructor TPressPersistence.Destroy;
begin
  FOIDGenerator.Free;
  inherited;
end;

function TPressPersistence.GetIdentifierQuotes: string;
begin
  Result := '"';
end;

function TPressPersistence.GetOIDGenerator: TPressOIDGenerator;
begin
  if not Assigned(FOIDGenerator) then
    FOIDGenerator := InternalOIDGeneratorClass.Create;
  Result := FOIDGenerator;
end;

function TPressPersistence.GetStrQuote: Char;
begin
  Result := '''';
end;

function TPressPersistence.InternalGenerateOID(AClass: TPressObjectClass;
  const AAttributeName: string): string;
begin
  Result := OIDGenerator.GenerateOID(Self, AClass, AAttributeName);
end;

function TPressPersistence.InternalOIDGeneratorClass: TPressOIDGeneratorClass;
begin
  Result :=
   TPressOIDGeneratorClass(PressApp.DefaultServiceClass(stOIDGenerator));
end;

{ TPressPersistentObjectLink }

constructor TPressPersistentObjectLink.Create(
  APressObject: TPressObject; APersistentObject: TObject);
begin
  inherited Create;
  FPressObject := APressObject;
  FPersistentObject := APersistentObject;
end;

destructor TPressPersistentObjectLink.Destroy;
begin
  FPersistentObject.Free;
  inherited;
end;

procedure TPressPersistentObjectLink.SetPersistentObject(AValue: TObject);
begin
  FPersistentObject.Free;
  FPersistentObject := AValue;
end;

{ TPressThirdPartyPersistenceCache }

function TPressThirdPartyPersistenceCache.AddLink(
  APressObject: TPressObject; APersistentObject: TObject): Integer;
begin
  Result := PersistentObjectLinkList.Add(
   TPressPersistentObjectLink.Create(APressObject, APersistentObject));
end;

constructor TPressThirdPartyPersistenceCache.Create;
begin
  inherited Create;
  FPersistentObjectLinkList := TObjectList.Create(True);
end;

destructor TPressThirdPartyPersistenceCache.Destroy;
begin
  FPersistentObjectLinkList.Free;
  inherited;
end;

function TPressThirdPartyPersistenceCache.GetPersistentObjectLink(
  AIndex: Integer): TPressPersistentObjectLink;
begin
  Result := PersistentObjectLinkList[AIndex] as TPressPersistentObjectLink;
end;

function TPressThirdPartyPersistenceCache.IndexOfLink(
  APressObject: TPressObject): Integer;
begin
  for Result := 0 to Pred(PersistentObjectLinkList.Count) do
    if PersistentObjectLink[Result].PressObject = APressObject then
      Exit;
  Result := -1;
end;

procedure TPressThirdPartyPersistenceCache.ReleaseObjects;
begin
  inherited;
  PersistentObjectLinkList.Clear;
end;

function TPressThirdPartyPersistenceCache.RemoveObject(
  AObject: TPressObject): Integer;
var
  VIndex: Integer;
begin
  Result := inherited RemoveObject(AObject);
  VIndex := IndexOfLink(AObject);
  if VIndex >= 0 then
    PersistentObjectLinkList.Delete(VIndex);
end;

{ TPressThirdPartyPersistence }

function TPressThirdPartyPersistence.GetCache: TPressThirdPartyPersistenceCache;
begin
  Result := inherited Cache as TPressThirdPartyPersistenceCache;
end;

function TPressThirdPartyPersistence.GetPersistentObject(
  APressObject: TPressObject): TObject;
var
  VIndex: Integer;
begin
  VIndex := Cache.IndexOfLink(APressObject);
  if VIndex >= 0 then
    Result := Cache.PersistentObjectLink[VIndex].PersistentObject
  else
    Result := nil;
end;

function TPressThirdPartyPersistence.InternalCacheClass: TPressDAOCacheClass;
begin
  Result := TPressThirdPartyPersistenceCache;
end;

procedure TPressThirdPartyPersistence.SetPersistentObject(
  APressObject: TPressObject; AValue: TObject);
var
  VIndex: Integer;
begin
  VIndex := Cache.IndexOfLink(APressObject);
  if VIndex >= 0 then
    Cache.PersistentObjectLink[VIndex].PersistentObject := AValue
  else
    Cache.AddLink(APressObject, AValue);
end;

procedure RegisterServices;
begin
  TPressOIDGenerator.RegisterService;
end;

initialization
  RegisterServices;

end.
