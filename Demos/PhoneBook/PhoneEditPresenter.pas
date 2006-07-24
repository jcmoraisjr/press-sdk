unit PhoneEditPresenter;

interface

uses
  CustomEditPresenter;

type
  TPhoneEditPresenter = class(TCustomEditPresenter)
  protected
    procedure InitPresenter; override;
  end;

implementation

uses
  ObjectModel, PhoneEdit;

{ TPhoneEditPresenter }

procedure TPhoneEditPresenter.InitPresenter;
begin
  inherited;
  CreateSubPresenter('Number', 'NumberEdit');
  CreateSubPresenter('PhoneType', 'PhoneTypeComboBox');
end;

initialization
  TPhoneEditPresenter.RegisterFormPresenter(TPhone, TPhoneEditForm);

end.
