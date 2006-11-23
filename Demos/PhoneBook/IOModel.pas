unit IOModel;

{$I PhoneBook.inc}

interface

uses
  InstantPersistence;

type
  TAddress = class;
  TCity = class;
  TCompany = class;
  TContact = class;
  TPerson = class;
  TPhone = class;

  TContact = class(TInstantObject)
  {IOMETADATA stored;
    Name: String(40);
    Address: Part(TAddress) external;
    Phones: Parts(TPhone) external 'Contact_Phones'; }
    _Address: TInstantPart;
    _Name: TInstantString;
    _Phones: TInstantParts;
  private
    function GetAddress: TAddress;
    function GetName: string;
    function GetPhoneCount: Integer;
    function GetPhones(Index: Integer): TPhone;
    procedure SetAddress(Value: TAddress);
    procedure SetName(const Value: string);
    procedure SetPhones(Index: Integer; Value: TPhone);
  public
    function AddPhone(Phone: TPhone): Integer;
    procedure ClearPhones;
    procedure DeletePhone(Index: Integer);
    function IndexOfPhone(Phone: TPhone): Integer;
    procedure InsertPhone(Index: Integer; Phone: TPhone);
    function RemovePhone(Phone: TPhone): Integer;
    property PhoneCount: Integer read GetPhoneCount;
    property Phones[Index: Integer]: TPhone read GetPhones write SetPhones;
  published
    property Address: TAddress read GetAddress write SetAddress;
    property Name: string read GetName write SetName;
  end;

  TAddress = class(TInstantObject)
  {IOMETADATA stored;
    Street: String(40);
    Zip: String(10);
    City: Reference(TCity); }
    _City: TInstantReference;
    _Street: TInstantString;
    _Zip: TInstantString;
  private
    function GetCity: TCity;
    function GetStreet: string;
    function GetZip: string;
    procedure SetCity(Value: TCity);
    procedure SetStreet(const Value: string);
    procedure SetZip(const Value: string);
  published
    property City: TCity read GetCity write SetCity;
    property Street: string read GetStreet write SetStreet;
    property Zip: string read GetZip write SetZip;
  end;

  TCity = class(TInstantObject)
  {IOMETADATA stored;
    Name: String(30);
    State: String(5); }
    _Name: TInstantString;
    _State: TInstantString;
  private
    function GetName: string;
    function GetState: string;
    procedure SetName(const Value: string);
    procedure SetState(const Value: string);
  published
    property Name: string read GetName write SetName;
    property State: string read GetState write SetState;
  end;

  TPerson = class(TContact)
  {IOMETADATA stored;
    NickName: String(20); }
    _NickName: TInstantString;
  private
    function GetNickName: string;
    procedure SetNickName(const Value: string);
  published
    property NickName: string read GetNickName write SetNickName;
  end;

  TCompany = class(TContact)
  {IOMETADATA stored;
    Contact: Reference(TPerson); }
    _Contact: TInstantReference;
  private
    function GetContact: TPerson;
    procedure SetContact(Value: TPerson);
  published
    property Contact: TPerson read GetContact write SetContact;
  end;

  TPhone = class(TInstantObject)
  {IOMETADATA stored;
    Number: String(15);
    PhoneType: Integer; }
    _Number: TInstantString;
    _PhoneType: TInstantInteger;
  private
    function GetNumber: string;
    function GetPhoneType: Integer;
    procedure SetNumber(const Value: string);
    procedure SetPhoneType(Value: Integer);
  published
    property Number: string read GetNumber write SetNumber;
    property PhoneType: Integer read GetPhoneType write SetPhoneType;
  end;

implementation

{ TContact }

function TContact.AddPhone(Phone: TPhone): Integer;
begin
  Result := _Phones.Add(Phone);
end;

procedure TContact.ClearPhones;
begin
  _Phones.Clear;
end;

procedure TContact.DeletePhone(Index: Integer);
begin
  _Phones.Delete(Index);
end;

function TContact.GetAddress: TAddress;
begin
  Result := _Address.Value as TAddress;
end;

function TContact.GetName: string;
begin
  Result := _Name.Value;
end;

function TContact.GetPhoneCount: Integer;
begin
  Result := _Phones.Count;
end;

function TContact.GetPhones(Index: Integer): TPhone;
begin
  Result := _Phones[Index] as TPhone;
end;

function TContact.IndexOfPhone(Phone: TPhone): Integer;
begin
  Result := _Phones.IndexOf(Phone);
end;

procedure TContact.InsertPhone(Index: Integer; Phone: TPhone);
begin
  _Phones.Insert(Index, Phone);
end;

function TContact.RemovePhone(Phone: TPhone): Integer;
begin
  Result := _Phones.Remove(Phone);
end;

procedure TContact.SetAddress(Value: TAddress);
begin
  _Address.Value := Value;
end;

procedure TContact.SetName(const Value: string);
begin
  _Name.Value := Value;
end;

{ TAddress }

function TAddress.GetCity: TCity;
begin
  Result := _City.Value as TCity;
end;

function TAddress.GetStreet: string;
begin
  Result := _Street.Value;
end;

function TAddress.GetZip: string;
begin
  Result := _Zip.Value;
end;

procedure TAddress.SetCity(Value: TCity);
begin
  _City.Value := Value;
end;

procedure TAddress.SetStreet(const Value: string);
begin
  _Street.Value := Value;
end;

procedure TAddress.SetZip(const Value: string);
begin
  _Zip.Value := Value;
end;

{ TCity }

function TCity.GetName: string;
begin
  Result := _Name.Value;
end;

function TCity.GetState: string;
begin
  Result := _State.Value;
end;

procedure TCity.SetName(const Value: string);
begin
  _Name.Value := Value;
end;

procedure TCity.SetState(const Value: string);
begin
  _State.Value := Value;
end;

{ TPerson }

procedure TContact.SetPhones(Index: Integer; Value: TPhone);
begin
  _Phones[Index] := Value;
end;

function TPerson.GetNickName: string;
begin
  Result := _NickName.Value;
end;

procedure TPerson.SetNickName(const Value: string);
begin
  _NickName.Value := Value;
end;

{ TCompany }

function TCompany.GetContact: TPerson;
begin
  Result := _Contact.Value as TPerson;
end;

procedure TCompany.SetContact(Value: TPerson);
begin
  _Contact.Value := Value;
end;

{ TPhone }

function TPhone.GetNumber: string;
begin
  Result := _Number.Value;
end;

function TPhone.GetPhoneType: Integer;
begin
  Result := _PhoneType.Value;
end;

procedure TPhone.SetNumber(const Value: string);
begin
  _Number.Value := Value;
end;

procedure TPhone.SetPhoneType(Value: Integer);
begin
  _PhoneType.Value := Value;
end;

initialization
  InstantRegisterClasses([
    TAddress,
    TCity,
    TCompany,
    TContact,
    TPerson,
    TPhone
  ]);

end.
