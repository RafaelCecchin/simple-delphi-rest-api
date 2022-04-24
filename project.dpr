program project;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  Horse.Compression,
  Horse.Jhonson,
  Horse.Commons,
  System.JSON,
  Horse.BasicAuthentication,
  System.SysUtils;

var
  App: THorse;
  Persons: TJsonArray;

begin
  App := THorse.Create();
  Persons := TJsonArray.Create();

  App.Use(Compression());
  App.Use(Jhonson());

  App.Use(HorseBasicAuthentication(
  function(const AUsername, APassword: string): Boolean
  begin
    Result := AUsername.Equals('username') and APassword.Equals('1234567');
  end));

  App.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      I: Integer;
      LPong: TJSONArray;
    begin
      LPong := TJSONArray.Create;
      for I := 0 to 1000 do
        LPong.Add(TJSONObject.Create(TJSONPair.Create('ping', 'pong')));
      Res.Send(LPong);
    end);

  App.Get('/persons',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send<TJSONAncestor>(Persons.Clone);
    end);

  App.Post('/persons',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      Person: TJSONObject;
    begin
      Person := Req.Body<TJSONObject>.Clone as TJSONObject;
      Persons.AddElement(Person);
      Res.Send<TJSONAncestor>(Person.Clone).Status(THTTPStatus.Created);
    end);

  App.Delete('/persons/:id',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      Id: Integer;
    begin
      Id := Req.Params.Items['id'].toInteger;
      Persons.Remove(Id).Free;
      Res.Send<TJSONAncestor>(Persons.Clone).Status(THTTPStatus.NoContent);
    end);

  App.Get('/exception',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LConteudo: TJSONObject;
    begin
      try
        raise Exception.Create('Exception example');
      except on E: Exception do
        Res.Send(TJSONObject.Create(TJSONPair.Create('error', E.Message))).Status(THTTPStatus.InternalServerError);
      end;
      
      
    end);

  App.Listen(9000);
end.
