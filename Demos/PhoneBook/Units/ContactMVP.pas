unit ContactMVP;

{$I PhoneBook.inc}

interface

uses
  CustomMVP;

type
  TContactEditPresenter = class(TCustomEditPresenter)
  protected
    procedure InitPresenter; override;
  end;

  TPersonEditPresenter = class(TContactEditPresenter)
  protected
    procedure InitPresenter; override;
  end;

  TCompanyEditPresenter = class(TContactEditPresenter)
  protected
    procedure InitPresenter; override;
  end;

  TPhoneEditPresenter = class(TCustomEditPresenter)
  protected
    procedure InitPresenter; override;
  end;

  TCityEditPresenter = class(TCustomEditPresenter)
  protected
    procedure InitPresenter; override;
  end;

implementation

uses
  ContactBO;

{ TContactEditPresenter }

procedure TContactEditPresenter.InitPresenter;
begin
  inherited;
  CreateSubPresenter('Name', 'NameEdit');
  CreateSubPresenter('Address.Street', 'StreetEdit');
  CreateSubPresenter('Address.Zip', 'ZipEdit');
  CreateSubPresenter('Address.City', 'CityComboBox', 'Name');
  CreateSubPresenter('Phones', 'PhonesStringGrid', 'PhoneType(80);Number(120)');
end;

{ TPersonEditPresenter }

procedure TPersonEditPresenter.InitPresenter;
begin
  inherited;
  CreateSubPresenter('NickName', 'NickNameEdit');
end;

{ TCompanyEditPresenter }

procedure TCompanyEditPresenter.InitPresenter;
begin
  inherited;
  CreateSubPresenter('Contact', 'ContactComboBox', 'Name');
end;

{ TPhoneEditPresenter }

procedure TPhoneEditPresenter.InitPresenter;
begin
  inherited;
  CreateSubPresenter('Number', 'NumberEdit');
  CreateSubPresenter('PhoneType', 'PhoneTypeComboBox');
end;

{ TCityEditPresenter }

procedure TCityEditPresenter.InitPresenter;
begin
  inherited;
  CreateSubPresenter('Name', 'NameEdit');
  CreateSubPresenter('State', 'StateEdit');
end;

initialization
  TCompanyEditPresenter.RegisterBO(TCompany);
  TPersonEditPresenter.RegisterBO(TPerson);
  TPhoneEditPresenter.RegisterBO(TPhone);
  TCityEditPresenter.RegisterBO(TCity);

end.
