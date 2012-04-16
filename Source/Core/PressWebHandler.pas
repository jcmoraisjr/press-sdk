unit PressWebHandler;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  HTTPDefs,
  fgl,
  PressClasses,
  PressApplication;

const
  CPressWebHandlerService = CPressWebServicesBase + $0001;

type

  EPressWebHandler = class(EPressWebException);

  IPressWebRequestHandler = interface(IUnknown)
  ['{350D929B-88D8-4643-9C94-6225A1BBDB0B}']
    procedure HandleRequest(ARequest: TRequest; AResponse: TResponse);
  end;

  { TPressWebRequestHandlerItem }

  TPressWebRequestHandlerItem = class(TObject)
  private
    FPattern: string;
    FHandler: IPressWebRequestHandler;
  public
    constructor Create(APattern: string; AHandler: IPressWebRequestHandler);
    property Pattern: string read FPattern;
    property Handler: IPressWebRequestHandler read FHandler;
  end;

  TPressWebRequestHandlerList = specialize TFPGObjectList<TPressWebRequestHandlerItem>;

  { TPressWebRequestInvoker }

  TPressWebRequestInvoker = class(TObject)
  private
    FHandlerList: TPressWebRequestHandlerList;
  protected
    procedure DoHandleRequest(AHandler: IPressWebRequestHandler; ARequest: TRequest; AResponse: TResponse); virtual;
    procedure InternalInvoke(ARequest: TRequest; AResponse: TResponse); virtual;
    function PatternMatch(const APattern, APathInfo: string): Boolean; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Invoke(ARequest: TRequest; AResponse: TResponse);
    property HandlerList: TPressWebRequestHandlerList read FHandlerList;
  end;

  { TPressWebHandler }

  TPressWebHandler = class(TPressService)
  private
    FInvoker: TPressWebRequestInvoker;
  protected
    procedure Finit; override;
    function InternalCreateInvoker: TPressWebRequestInvoker; virtual;
    procedure InternalIsDefaultChanged; override;
    class function InternalServiceType: TPressServiceType; override;
  public
    constructor Create; override;
    class function DefaultService: TPressWebHandler;
    procedure HandleRequest(ARequest: TRequest; AResponse: TResponse); virtual;
    procedure RegisterRequestHandler(const APattern: string; AHandler: IPressWebRequestHandler); virtual;
  end;

implementation

uses
  SysUtils;

var
  _WebHandlerDefaultService: TPressWebHandler;

{ TPressWebRequestHandlerItem }

constructor TPressWebRequestHandlerItem.Create(APattern: string;
  AHandler: IPressWebRequestHandler);
begin
  inherited Create;
  FPattern := APattern;
  FHandler := AHandler;
end;

{ TPressWebRequestInvoker }

procedure TPressWebRequestInvoker.DoHandleRequest(
  AHandler: IPressWebRequestHandler; ARequest: TRequest; AResponse: TResponse);
begin
  AHandler.HandleRequest(ARequest, AResponse);
end;

procedure TPressWebRequestInvoker.InternalInvoke(ARequest: TRequest;
  AResponse: TResponse);
var
  VPath: string;
  I: Integer;
begin
  VPath := ARequest.PathInfo;
  for I := 0 to Pred(HandlerList.Count) do
    if PatternMatch(HandlerList[I].Pattern, VPath) then
      DoHandleRequest(HandlerList[I].Handler, ARequest, AResponse);
end;

function TPressWebRequestInvoker.PatternMatch(
  const APattern, APathInfo: string): Boolean;
var
  VPatternLength, VPathLength, VPos, I: Integer;
begin
  Result := APattern = APathInfo;
  if Result then
    Exit;
  VPatternLength := Length(APattern);
  VPathLength := Length(APathInfo);
  Result := VPathLength + 1 >= VPatternLength;
  if not Result then
    Exit;
  VPos := Pos('*', APattern);
  Result := VPos <> 0;
  if not Result then
    Exit;
  Result := False;
  for I := 1 to Pred(VPos) do
    if APattern[I] <> APathInfo[I] then
      Exit;
  for I := VPatternLength downto Succ(VPos) do
    if APattern[I] <> APathInfo[VPathLength + I - VPatternLength] then
      Exit;
  Result := True;
end;

constructor TPressWebRequestInvoker.Create;
begin
  FHandlerList := TPressWebRequestHandlerList.Create;
end;

destructor TPressWebRequestInvoker.Destroy;
begin
  FHandlerList.Free;
  inherited Destroy;
end;

procedure TPressWebRequestInvoker.Invoke(ARequest: TRequest;
  AResponse: TResponse);
begin
  InternalInvoke(ARequest, AResponse);
end;

{ TPressWebHandler }

procedure TPressWebHandler.Finit;
begin
  FreeAndNil(FInvoker);
  inherited Finit;
end;

function TPressWebHandler.InternalCreateInvoker: TPressWebRequestInvoker;
begin
  Result := TPressWebRequestInvoker.Create;
end;

procedure TPressWebHandler.InternalIsDefaultChanged;
begin
  inherited InternalIsDefaultChanged;
  _WebHandlerDefaultService := Registry.DefaultService as TPressWebHandler;
end;

class function TPressWebHandler.InternalServiceType: TPressServiceType;
begin
  Result := CPressWebHandlerService;
end;

constructor TPressWebHandler.Create;
begin
  inherited Create;
  FInvoker := TPressWebRequestInvoker.Create;
end;

class function TPressWebHandler.DefaultService: TPressWebHandler;
begin
  if _WebHandlerDefaultService = nil then
    _WebHandlerDefaultService :=
     PressApp.Registry[InternalServiceType].DefaultService as TPressWebHandler;
  Result := _WebHandlerDefaultService;
end;

procedure TPressWebHandler.HandleRequest(ARequest: TRequest;
  AResponse: TResponse);
begin
  if Assigned(FInvoker) then
    FInvoker.Invoke(ARequest, AResponse);
end;

procedure TPressWebHandler.RegisterRequestHandler(const APattern: string;
  AHandler: IPressWebRequestHandler);
begin
  FInvoker.HandlerList.Add(TPressWebRequestHandlerItem.Create(APattern, AHandler));
end;

initialization
  TPressWebHandler.RegisterService;

finalization
  TPressWebHandler.UnregisterService;

end.

