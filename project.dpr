program project;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  Horse.Jhonson,
  System.JSON;

var
  App: THorse;
  Persons: TJsonArray;

begin
  App := THorse.Create();
  Persons := TJsonArray.Create();

  App.Use(Jhonson);

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

  App.Post('/person',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      Person: TJSONObject;
    begin
      Person := Req.Body<TJSONObject>.Clone as TJSONObject;
      Persons.AddElement(Person);
      Res.Send<TJSONAncestor>(Person.Clone).Status(201);
    end);

  App.Listen(9000);
end.
