unit Main;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, ExtCtrls, jpeg;

type
  TSprite = record
    Img : TImage;       // Image du sprite (*.bmp)
    Mask : TBitmap;     // Bitmap du masque de ce sprite
    sX, sY : Integer;   // Coordonées du sprite
    layer : Integer;    // 'calque' sur lequel se déplace le sprite
    locked : Boolean;   // Verrouillé ou non
  end;

type
  PTSprite = ^TSprite;  // pointeur sur la structure

type
    TForm1 = class(TForm)
        b_Close: TButton;
        Fond: TImage;
    b_0: TButton;
    b_1: TButton;
    b_2: TButton;
        procedure b_CloseClick(Sender: TObject);
        procedure Init(Sender: TObject);
        procedure Close(Sender: TObject; var Action: TCloseAction);
        procedure GetMouseXY(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
        procedure MoveTheSprite(Sender: TObject; Shift: TShiftState; X, Y: Integer);
        procedure b_0Click(Sender: TObject);
        procedure b_1Click(Sender: TObject);
        procedure b_2Click(Sender: TObject);
    private
        { Déclarations privées }
    public
        { Déclarations publiques }
    end;

Procedure CreateMsk(PSprite: PTSprite);
Procedure SimpleDrawSprite(PSprite: PTSprite);

var
    Form1: TForm1;
    LeSprite : array[0..2] of TSprite; // Juste deux sprites pour essais
    NbSprite : Integer; // Mémorise le nombre de sprite créé
    Selected : Integer; // Le sprite sélectionné (un à la fois)

    hdcSave: Hdc;       // Context device : Sauvegarde de l'image de fond lorsqu'elle est 'vierge'
    bmSave: HBitmap;    // Bitmap associée à cette sauvegarde

    HdcWork: Hdc;       // Zone de travail
    bmWork: HBitmap;    // Bitmap associé à cette zone

    OldMouseX, OldMouseY: Integer;
    OkDepl: Boolean;


implementation

{$R *.dfm}

//-----------------------------------------------------------------------------------------------------------
procedure TForm1.b_0Click(Sender: TObject);
begin
    Selected := 0;
end;
//-----------------------------------------------------------------------------------------------------------
procedure TForm1.b_1Click(Sender: TObject);
begin
    Selected := 1;
end;
//-----------------------------------------------------------------------------------------------------------
procedure TForm1.b_2Click(Sender: TObject);
begin
    Selected := 2;
end;

//-----------------------------------------------------------------------------------------------------------
procedure TForm1.b_CloseClick(Sender: TObject);
begin
    Application.Terminate;
end;

// -------------------------------------------------------------------------------------------------------------
procedure TForm1.Close(Sender: TObject; var Action: TCloseAction);
var
  i : Integer;
begin
  for I := 0 to NBSprite  do  // Libère les ressources sprite
  Begin
    LeSprite[i].img.Free;
    LeSprite[i].Mask.Free;
  End;
  // Destruction de la ZT
  DeleteDC(HdcWork);
  DeleteObject(SelectObject(HdcWork, bmWork));

  // Destruction de la sauvegarde
  DeleteObject(SelectObject(hdcSave, bmSave));
  DeleteDC(hdcSave);
end;

// -------------------------------------------------------------------------------------------------------------
procedure TForm1.GetMouseXY(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    OkDepl := False;
    With LeSprite[Selected] do
    Begin
      if (X > sX) AND (X < sX + img.Width) AND (Y > sY) AND (Y < sY + img.Height) then
      Begin
          OldMouseX := X;
          OldMouseY := Y;
          OkDepl := True;
      end;
    End;
end;

// -------------------------------------------------------------------------------------------------------------
procedure TForm1.Init(Sender: TObject);
var
  Jpg: TJPEGImage;
begin
    Jpg := TJPEGImage.Create; // Charge un Jpeg et le stocke dans le TImage de fond.
    Jpg.LoadFromFile('fond.jpg');
    Fond.Picture.Bitmap.Assign(Jpg);
    Jpg.Free;

    DoubleBuffered := True; // Pour éviter le scintillement
    NbSprite := -1;

    // Sauvegarde de l'ensemble de l'image vierge (sans sprite) et création d'une zone de travail
    // qui contiendra, elle aussi, l'ensemble de l'image.
    with Fond do
    Begin
        // Création du DC de la sauvegarde (mêmes caractéristique que l'image de fond)
        hdcSave := CreateCompatibleDC(Canvas.Handle);
        // Création de la bitmap associée à ce context device
        bmSave := CreateCompatibleBitmap(Canvas.Handle, Picture.Width, Picture.Height);
        SelectObject(hdcSave, bmSave);
        // et copie de l'image de fond vers cette sauvegarde
        BitBlt(hdcSave, 0, 0, Width, Height, Canvas.Handle, 0, 0, SrcCopy);

        // Création du DC de la zone de travail
        HdcWork := CreateCompatibleDC(Canvas.Handle);
        bmWork := CreateCompatibleBitmap(Canvas.Handle, Picture.Width, Picture.height);
        SelectObject(HdcWork, bmWork);
    End;

     // création du Sprite 0
     With LeSprite[0] do
     Begin
         img := TImage.Create(self);
         img.AutoSize := True;
         img.Picture.LoadFromFile('Sprite4.bmp');
         layer := 0;
         locked := False;
     End;
     // Création du masque du sprite 0
     CreateMsk(@LeSprite[0]);
     Inc(NbSprite);

     // création du Sprite 1
     With LeSprite[1] do
     Begin
         img := TImage.Create(self);
         img.AutoSize := True;
         img.Picture.LoadFromFile('Sprite8.bmp');
         layer := 1;
         locked := False;
     End;
     // Création du masque du sprite 1
     CreateMsk(@LeSprite[1]);
     Inc(NbSprite);

     // création du Sprite 2
     With LeSprite[2] do
     Begin
         img := TImage.Create(self);
         img.AutoSize := True;
         img.Picture.LoadFromFile('Sprite3.bmp');
         layer := 2;
         locked := False;
     End;
     // Création du masque du sprite 1
     CreateMsk(@LeSprite[2]);
     Inc(NbSprite);

     // Affiche des sprites
     SimpleDrawSprite(@LeSprite[0]);
     SimpleDrawSprite(@LeSprite[1]);
     SimpleDrawSprite(@LeSprite[2]);

     Selected := NbSprite; // Le dernier sprite créé est sélectionné

end;

// ------------------------------------------------------------------------------------------------------------
procedure TForm1.MoveTheSprite(Sender: TObject; Shift: TShiftState; X, Y: Integer);
Var
    i,dx, dy: Integer;
begin
    if (Shift = [ssLeft]) AND OkDepl then    // Shift = [ssLeft] s'assure que le bouton gauche est enfoncé quand la souris se déplace
    begin
        // Calcule le déplacement du sprite
        dx := X - OldMouseX;
        dy := Y - OldMouseY;

        // Mémorise les nouvelles coordonnées du sprite
        LeSprite[selected].sX := LeSprite[selected].sX + dx;
        LeSprite[selected].sY := LeSprite[selected].sY + dy;

        // Sauvegarde de l'image écran en entier => ZT
        BitBlt(HdcWork, 0, 0, Fond.Picture.Width, Fond.Picture.height, HdcSave, 0, 0, SrcCopy);

        // Redessine tous les sprites (dans l'ordre des calques)
        for i := 0 to NBSprite do
        begin
            With LeSprite[i] do
            Begin
                // Sprite + masque => ZT
                MaskBlt(HdcWork, sX, sY, img.Width, img.Height, img.Canvas.Handle, 0, 0, Mask.Handle, 0, 0, MAKEROP4(SrcCopy, $00AA0029));
            end;
        end;

        // ZT => Image de fond
        BitBlt(Fond.Canvas.Handle, 0, 0, Fond.Picture.Width, Fond.Picture.height, hdcWork, 0, 0, SrcCopy);
        Invalidate;

        OldMouseX := X;
        OldMouseY := Y;

    end;
end;

// ------------------------------------------------------------------------------------------------------------
Procedure SimpleDrawSprite(PSprite: PTSprite);
Begin
    With PSprite^ do
    Begin
        // Centre le sprite au milieu de l'image de fond
        sX := (Form1.Fond.Width div 2) - (img.width div 2);
        sY := (Form1.Fond.Height div 2) - (img.height div 2);

        // Dessine le Sprite (avec le masque)
        MaskBlt(Form1.Fond.Canvas.Handle, sX, sY, img.Width, img.Height, img.Canvas.Handle, 0, 0, Mask.Handle, 0, 0, MAKEROP4(SrcCopy, $00AA0029));
    End;
End;

// --------------------------------------------------------------------------------------------------------
// Dans cette version de CreateMsk, les pixels blancs représentent la transparence
// --------------------------------------------------------------------------------------------------------
Procedure CreateMsk(PSprite: PTSprite); // Passage par pointeur
var
    X, Y: Integer;
    cl: TColor;
begin
    With PSprite^ do
    Begin
      Mask := TBitmap.Create;
      With Mask do
      begin
          Width := img.Width;
          Height := img.Height;
          pixelFormat := pf1bit; // <- 1 bit/pixel
          Canvas.Brush.Color := clWhite; // <-  blanc (changer cette valeur pour choisir une autre couleur de transparence)
          Canvas.FillRect(Canvas.ClipRect);
      end;

      for Y := 0 to img.Height - 1 do
      begin
          for X := 0 to img.Width - 1 do
          begin
              cl := img.Canvas.pixels[X, Y];
              if cl = clWhite then Mask.Canvas.pixels[X, Y] := clBlack;
          end;
      end;
    End;
    // Au final, on obtient une bitmap monochrome dont les pixels noirs représentent la partie transparente
    // du sprite et les pixels blancs, la partie non transparente.
end;

end.

{
=================================
TO DO LIST
=================================

 * Verrouiller un sprite.
 * Le sprite ne bouge pas si on a cliqué dans une partie transparente
 * Gérer la transparence des parties du sprite non blanches.


 }




