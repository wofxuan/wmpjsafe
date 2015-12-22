unit WMFBData_Impl;

{----------------------------------------------------------------------------}
{ This unit was automatically generated by the RemObjects SDK after reading  }
{ the RODL file associated with this project .                               }
{                                                                            }
{ This is where you are supposed to code the implementation of your objects. }
{----------------------------------------------------------------------------}

{$I RemObjects.inc}

interface

uses
  {vcl:} Classes, SysUtils,
  {RemObjects:} uROXMLIntf, uROClientIntf, uROTypes, uROServer, uROServerIntf, uROSessions,
  {Required:} uRORemoteDataModule,
  {Generated:} WMServer_Intf, DB, Provider, Dialogs, Variants, DBClient,
  ADODB, uParamObject, superobject;

const
  ServerCfgFile = 'WMServer.Cfg';
  
type
  { TWMFBData }
  TWMFBData = class(TRORemoteDataModule, IWMFBData)
    dspPubBackQryData: TDataSetProvider;
    conDB: TADOConnection;
    qryPubBackData: TADOQuery;
    spPubBackData: TADOStoredProc;
    dspPubBackSPData: TDataSetProvider;
    procedure RORemoteDataModuleCreate(Sender: TObject);
  private
    FServerAddr, FPassword, FUser, FBaseName: string;

    procedure SetParametersValue(AParams: TParameters; AInputParams: ISuperObject);
    function GetParamValueByName(const AParamName: string; AParams: ISuperObject; var Value: Variant): Boolean;
    procedure SetBackParameters(AProcParams: TParameters; aBackParams: TParams);
    procedure LoadCfg;
  protected
    { IWMFBData methods }
    function Sum(const A: Integer; const B: Integer): Integer;
    function GetServerTime: DateTime;
    function QuerySQL(const ASQL: AnsiString; var AQueryData: OleVariant): Integer;
    //传入的json参数格式'{"ProcName":"getptype","Params":{"@comde":"0001","@type1":"00002"}}'
    function ExecuteProc(const AInputParams: OleVariant; out AOutParams: OleVariant): Integer;
    function ExecuteProcBackData(const AInputParams: OleVariant; out AOutParams: OleVariant; var ABackData: OleVariant): Integer;
    function SaveBill(const ABillData: OleVariant; var AOutPutData: OleVariant): Integer;
  end;


var
  fClassFactory: IROClassFactory;

implementation

{$R *.dfm}
uses
  {Generated:} WMServer_Invk, IniFiles, uPubFun;

procedure Create_WMFBData(out anInstance: IUnknown);
begin
  anInstance := TWMFBData.Create(nil);
end;

{ WMFBData }

function TWMFBData.Sum(const A: Integer; const B: Integer): Integer;
begin
  Result := A + B;
end;

function TWMFBData.GetServerTime: DateTime;
begin
  Result := Now;
end;

function TWMFBData.QuerySQL(const ASQL: AnsiString; var AQueryData: OleVariant): Integer;
var
  aData: OleVariant;
begin
  try
    Result := -1;
    qryPubBackData.SQL.Clear;
    qryPubBackData.SQL.Add(ASQL);
    qryPubBackData.Open;
    AQueryData := dspPubBackQryData.Data;
    Result := 0;
  except

  end;
end;

procedure TWMFBData.RORemoteDataModuleCreate(Sender: TObject);
begin
  if not conDB.Connected then
  begin
    LoadCfg();
    conDB.ConnectionString := 'Provider=SQLOLEDB.1;Password=' + FPassword + ';Persist Security Info=True;' +
                              'User ID=' + FUser + ';Initial Catalog=' + FBaseName + ';Data Source=' + FServerAddr;
    conDB.Connected := True;
  end;
end;

function TWMFBData.ExecuteProc(const AInputParams: OleVariant;
  out AOutParams: OleVariant): Integer;
var
  aJsonStr, aProcName: string;
  aJson, aJsonParams: ISuperObject;
  aBackParams: TParams;
begin
  aJsonStr := OleDataToStr(AInputParams);
  aJson := SO(aJsonStr);
  aProcName := aJson.S['ProcName'];

  if Trim(aProcName) = EmptyStr then Exit;

  aJsonParams := SO(aJson.S['Params']);
  with spPubBackData do
  begin
    Close;
    ProcedureName := aProcName;
    Parameters.Refresh; //刷新存储过程参数，得到参数列表
    SetParametersValue(Parameters, aJsonParams);
    ExecProc; //没有返回数据集的时候
    Result := Parameters[0].Value;
    aBackParams := TParams.Create;
    try
      SetBackParameters(Parameters, aBackParams);
      AOutParams := PackageParams(aBackParams);
    finally
      FreeAndNil(aBackParams);
    end;
  end;
end;

function TWMFBData.ExecuteProcBackData(const AInputParams: OleVariant;
  out AOutParams: OleVariant; var ABackData: OleVariant): Integer;
var
  aJsonStr, aProcName: string;
  aJson, aJsonParams: ISuperObject;
  aBackParams: TParams;
begin
  aJsonStr := OleDataToStr(AInputParams);
  aJson := SO(aJsonStr);
  aProcName := aJson.S['ProcName'];

  if Trim(aProcName) = EmptyStr then Exit;

  aJsonParams := SO(aJson.S['Params']);
  with spPubBackData do
  begin
    Close;
    ProcedureName := aProcName;
    Parameters.Refresh; //刷新存储过程参数，得到参数列表
    SetParametersValue(Parameters, aJsonParams);
    Open; //返回数据集的时候
    Result := Parameters[0].Value;
    aBackParams := TParams.Create;
    try
      SetBackParameters(Parameters, aBackParams);
      AOutParams := PackageParams(aBackParams);
    finally
      FreeAndNil(aBackParams);
    end;
  end;
  ABackData := dspPubBackSPData.Data;
end;

procedure TWMFBData.SetParametersValue(AParams: TParameters;
  AInputParams: ISuperObject);
var
  i: Integer;
  inputValue: Variant;
begin
  for i := 0 to AParams.Count - 1 do
  begin
    if AParams[i].DataType in [ftBCD, ftFMTBcd] then
      AParams[i].DataType := ftFloat;
    if (AParams[i].Direction in [pdInput, pdInputOutput]) then
      if GetParamValueByName(AParams[i].Name, AInputParams, inputValue) then
      begin
        AParams[i].Value := inputValue;
      end
      else if AParams[i].Direction <> pdInput then
      begin
        AParams[i].Value := Null;
      end;
  end;
end;

function TWMFBData.GetParamValueByName(const AParamName: string;
  AParams: ISuperObject; var Value: Variant): Boolean;
var
  aItem: TSuperObjectIter;
begin
  Result := False;
  Value := Null;
  if ObjectFindFirst(AParams, aItem) then
  repeat
    if SameText(AParamName, aItem.key) then
    begin
      case aItem.val.DataType of
        stInt: Value := aItem.val.AsInteger;
        stDouble: Value := aItem.val.AsDouble;
        stString: Value := aItem.val.AsString;
      else
        Value := aItem.val.AsString;
      end;

      Result := True;
      Break;
    end;
  until not ObjectFindNext(aItem);
  ObjectFindClose(aItem);
end;

procedure TWMFBData.SetBackParameters(AProcParams: TParameters;
  aBackParams: TParams);
var
  i: Integer;
  aDataType: TDataType;
begin
  aBackParams.Clear;
  for i := 1 to AProcParams.Count - 1 do // Iterate
  begin
    if (AProcParams[i].Direction in [pdOutPut, pdInputOutput]) then
    begin
      with TParam(aBackParams.Add) do
      begin
        aDataType := AProcParams[i].DataType;
        ParamType := TParamType(Ord(AProcParams[i].Direction));
        Name := AProcParams[i].Name;
        if AProcParams[i].DataType = ftBCD then
          AsFloat := AProcParams[i].Value
        else
          Value := AProcParams[i].Value;
      end;
    end;
  end;
end;

function TWMFBData.SaveBill(const ABillData: OleVariant;
  var AOutPutData: OleVariant): Integer;
begin

end;

procedure TWMFBData.LoadCfg;
var
  aFilePath: string;
  aIni: TIniFile;
begin
  aFilePath := ExtractFilePath(ParamStr(0)) + ServerCfgFile;
  if not FileExists(aFilePath) then
  begin
    FileCreate(aFilePath)
  end;
  aIni := TIniFile.Create(aFilePath);
  try
    FServerAddr := aIni.ReadString('DataBase', 'ServerAddr', '127.0.0.1');  
    aIni.WriteString('DataBase', 'ServerAddr', FServerAddr);
    
    FPassword := aIni.ReadString('DataBase', 'Password', '123456');
    aIni.WriteString('DataBase', 'Password', FPassword);

    FUser := aIni.ReadString('DataBase', 'User', 'sa');
    aIni.WriteString('DataBase', 'User', FUser);

    FBaseName := aIni.ReadString('Server', 'BaseName', 'wmpj');
    aIni.WriteString('DataBase', 'BaseName', FBaseName);
  finally
    aIni.Free;
  end;
end;

initialization
  fClassFactory := TROClassFactory.Create('WMFBData', Create_WMFBData, TWMFBData_Invoker);
  // RegisterForZeroConf(fClassFactory,'_WMFBData_rosdk._tcp.');

finalization
  UnRegisterClassFactory(fClassFactory);
  fClassFactory := nil;

end.

