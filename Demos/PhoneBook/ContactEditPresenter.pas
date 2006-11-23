unit ContactEditPresenter;

{$I PhoneBook.inc}

interface

uses
  CustomEditPresenter;

type
  TContactEditPresenter = class(TCustomEditPresenter)
  protected
    procedure InitPresenter; override;
  end;

implementation

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

end.
