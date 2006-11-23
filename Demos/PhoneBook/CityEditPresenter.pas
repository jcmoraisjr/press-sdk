unit CityEditPresenter;

{$I PhoneBook.inc}

interface

uses
  CustomEditPresenter;

type
  TCityEditPresenter = class(TCustomEditPresenter)
  protected
    procedure InitPresenter; override;
  end;

implementation

uses
  ObjectModel, CityEdit;

{ TCityEditPresenter }

procedure TCityEditPresenter.InitPresenter;
begin
  inherited;
  CreateSubPresenter('Name', 'NameEdit');
  CreateSubPresenter('State', 'StateEdit');
end;

initialization
  TCityEditPresenter.RegisterFormPresenter(TCity, TCityEditForm);

end.
