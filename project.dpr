program project;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
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

  App.Use(Jhonson);

  App.Use(HorseBasicAuthentication(
  function(const AUsername, APassword: string): Boolean
  begin
    Result := AUsername.Equals('username') and APassword.Equals('1234567');
  end));

  App.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
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

  App.Listen(9000);
end.
