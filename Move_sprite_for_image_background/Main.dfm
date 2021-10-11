object Form1: TForm1
  Left = 253
  Top = 116
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 
    'Move a sprite for the background image (with the "layer" of mana' +
    'gement)'
  ClientHeight = 658
  ClientWidth = 921
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = Close
  OnCreate = Init
  PixelsPerInch = 96
  TextHeight = 13
  object Fond: TImage
    Left = 7
    Top = 8
    Width = 904
    Height = 609
    Center = True
    OnMouseDown = GetMouseXY
    OnMouseMove = MoveTheSprite
  end
  object b_Close: TButton
    Left = 8
    Top = 624
    Width = 233
    Height = 25
    Caption = 'Close'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = b_CloseClick
  end
  object b_0: TButton
    Left = 512
    Top = 624
    Width = 25
    Height = 25
    Caption = '0'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = b_0Click
  end
  object b_1: TButton
    Left = 543
    Top = 624
    Width = 25
    Height = 25
    Caption = '1'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = b_1Click
  end
  object b_2: TButton
    Left = 574
    Top = 624
    Width = 25
    Height = 25
    Caption = '2'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnClick = b_2Click
  end
end
