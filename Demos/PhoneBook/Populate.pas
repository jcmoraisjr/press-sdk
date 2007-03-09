unit Populate;

interface

uses
  PressSubject;

procedure PopulatePhoneBook(AList: TPressObjectList);

implementation

uses
  ObjectModel;

procedure PopulatePhoneBook(AList: TPressObjectList);
var
  VPerson: TPerson;
  VCompany: TCompany;
  VPhone: TPhone;
  VCity: TCity;
begin
  VPerson := TPerson.Create;
  VPerson.Id := '1';  // this is not necessary, used because of the retrieve, some lines below
  VPerson.Name := 'John Doe';
  VPerson.NickName := 'John';
  VPerson.Address.Street := 'John''s Street';
  VPerson.Address.Zip := '18020-250';
  VCity := TCity.Create;
  VCity.Id := '2';  // same
  VCity.Name := 'New York';
  VCity.State := 'NY';
  VCity.Store;
  VPerson.Address.City := VCity;
  VCity.Release;
  VPerson.Store;
  AList.Add(VPerson);

  VPerson := TPerson.Create;
  VPerson.Name := 'Jane Doe';
  VPerson.NickName := 'Jane';
  VPerson.Address.Street := 'Jane''s Street';
  VPerson.Address.Zip := '23240-030';
  VCity := TCity.Create;
  VCity.Name := 'Los Angeles';
  VCity.State := 'CA';
  VCity.Store;
  VPerson.Address.City := VCity;
  VCity.Release;
  VPhone := TPhone.Create;
  VPhone.Number := '1213-6798';
  VPhone.PhoneType := ptPhone;
  VPerson.Phones.Add(VPhone);
  VPhone := TPhone.Create;
  VPhone.Number := '9866-2122';
  VPhone.PhoneType := ptMobile;
  VPerson.Phones.Add(VPhone);
  VPerson.Store;
  AList.Add(VPerson);

  VCompany := TCompany.Create;
  VCompany.Name := 'Press Software Corp';
  VCompany.Contact := TPerson.Retrieve('1');
  VCompany.Contact.Release;  // Retrieve will increase the reference count, release will avoid memory leak
  VCompany.Address.Street := 'Press'' Street';
  VCompany.Address.Zip := '36070-920';
  VCompany.Address.City := TCity.Retrieve('2');
  VCompany.Address.City.Release;  // same
  VPhone := TPhone.Create;
  VPhone.Number := '2213-2100';
  VPhone.PhoneType := ptPhone;
  VCompany.Phones.Add(VPhone);
  VPhone := TPhone.Create;
  VPhone.Number := '2213-2128';
  VPhone.PhoneType := ptFax;
  VCompany.Phones.Add(VPhone);
  VCompany.Store;
  AList.Add(VCompany);
end;

end.
