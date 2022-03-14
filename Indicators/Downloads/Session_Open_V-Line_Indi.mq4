//+------------------------------------------------------------------+
//|                                                   i-Sessions.mq4 |
//|                                           ��� ����� �. aka KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//|  16.11.2005  ��������� �������� ������                           |
//+------------------------------------------------------------------+
#property copyright "��� ����� �. aka KimIV"
#property link      "http://www.kimiv.ru"

#property indicator_chart_window

//------- ������� ��������� ���������� -------------------------------

extern int Line_Width_1_2_3_4_or_5 = 1;
extern int Line_Style = 0;
extern int    Historical_Days = 360;        // ���������� ����
extern bool Hide_London_EuroZone = false; 
extern color  London_EuroZone_Color = DodgerBlue;       // ���� ����������� ������
extern string London_EuroZone_Open = "09:00";   // �������� ����������� ������

extern bool Hide_USA = false;
extern color  USA_Color = Magenta; // ���� ������������ ������
extern string USA_Open = "15:30";   // �������� ������������ ������

extern bool Hide_Asia = false;
extern color  Asia_Color = Green; // ���� ��������� ������
extern string Asia_Open = "20:00";   // �������� ��������� ������

string AsiaEnd = "Asia_Open";   // �������� ��������� ������
string EurEnd = "London_EuroZone_Open";   // �������� ����������� ������
string USAEnd = "USA_Open";   // �������� ������������ ������


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init() {
  DeleteObjects();
  for (int i=0; i<Historical_Days; i++) {
    CreateObjects("AS"+i, Asia_Color);
    CreateObjects("EU"+i,London_EuroZone_Color);
    CreateObjects("US"+i, USA_Color);
  }
  Comment("");
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void deinit() {
  DeleteObjects();
  Comment("");
}

//+------------------------------------------------------------------+
//| �������� �������� ����������                                     |
//| ���������:                                                       |
//|   no - ������������ �������                                      |
//|   cl - ���� �������                                              |
//+------------------------------------------------------------------+
void CreateObjects(string no, color cl){
  ObjectCreate(no, OBJ_VLINE, 0, 0,0, 0,0);
  ObjectSet(no, OBJPROP_WIDTH, Line_Width_1_2_3_4_or_5);
  ObjectSet(no, OBJPROP_STYLE, Line_Style);
  ObjectSet(no, OBJPROP_COLOR, cl);
  ObjectSet(no, OBJPROP_BACK, false);
}

//+------------------------------------------------------------------+
//| �������� �������� ����������                                     |
//+------------------------------------------------------------------+
void DeleteObjects() {
  for (int i=0; i<Historical_Days; i++) {
    ObjectDelete("AS"+i);
    ObjectDelete("EU"+i);
    ObjectDelete("US"+i);
  }
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void start() {
  datetime dt=CurTime();

  for (int i=0; i<Historical_Days; i++) {
    if(Hide_Asia==false){
      DrawObjects(dt, "AS"+i, Asia_Open,AsiaEnd);}
    if(Hide_London_EuroZone==false){
      DrawObjects(dt, "EU"+i, London_EuroZone_Open, EurEnd);}
    if(Hide_USA==false){
      DrawObjects(dt, "US"+i, USA_Open, USAEnd);}
    dt=decDateTradeDay(dt);
    while (TimeDayOfWeek(dt)>5) dt=decDateTradeDay(dt);
  }
}

//+------------------------------------------------------------------+
//| ���������� �������� �� �������                                   |
//| ���������:                                                       |
//|   dt - ���� ��������� ���                                        |
//|   no - ������������ �������                                      |
//|   tb - ����� ������ ������                                       |
//|   te - ����� ��������� ������                                    |
//+------------------------------------------------------------------+
void DrawObjects(datetime dt, string no, string tb, string te) {
  datetime t1, t2;
  double   p1, p2;
  int      b1, b2;

  t1=StrToTime(TimeToStr(dt, TIME_DATE)+" "+tb);
  t2=StrToTime(TimeToStr(dt, TIME_DATE)+" "+te);
  b1=iBarShift(NULL, 0, t1);
  b2=iBarShift(NULL, 0, t2);
  p1=High[Highest(NULL, 0, MODE_HIGH, b1-b2, b2)];
  p2=Low [Lowest (NULL, 0, MODE_LOW , b1-b2, b2)];
  ObjectSet(no, OBJPROP_TIME1 , t1);
  ObjectSet(no, OBJPROP_PRICE1, p1);
  ObjectSet(no, OBJPROP_TIME2 , t2);
  ObjectSet(no, OBJPROP_PRICE2, p2);
}

//+------------------------------------------------------------------+
//| ���������� ���� �� ���� �������� ����                            |
//| ���������:                                                       |
//|   dt - ���� ��������� ���                                        |
//+------------------------------------------------------------------+
datetime decDateTradeDay (datetime dt) {
  int ty=TimeYear(dt);
  int tm=TimeMonth(dt);
  int td=TimeDay(dt);
  int th=TimeHour(dt);
  int ti=TimeMinute(dt);

  td--;
  if (td==0) {
    tm--;
    if (tm==0) {
      ty--;
      tm=12;
    }
    if (tm==1 || tm==3 || tm==5 || tm==7 || tm==8 || tm==10 || tm==12) td=31;
    if (tm==2) if (MathMod(ty, 4)==0) td=29; else td=28;
    if (tm==4 || tm==6 || tm==9 || tm==11) td=30;
  }
  return(StrToTime(ty+"."+tm+"."+td+" "+th+":"+ti));
}
//+------------------------------------------------------------------+

