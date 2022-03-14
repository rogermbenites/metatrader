/*
вызов индикатора из др.программ
iCustom(string symbol, int timeframe, "_StochNR", int %Kperiod, int %Dperiod, 
int slowing, int method, int price_field, double sens, int mode, int shift);
iCustom(NULL,0,"_StochNR",Kperiod,Dperiod,Slowing,Dmethod,PriceFild,Sens, 0,i);
*/

#property indicator_separate_window // в отд. окне 
#property indicator_buffers 2
#property indicator_color1 LightSeaGreen // главная
#property indicator_style1 0
#property indicator_color2 Red // сигнальная
#property indicator_style2 2
#property indicator_maximum 100
#property indicator_minimum 0
#property indicator_level1 80
#property indicator_level2 20

// входные параметры
extern int Kperiod=5; // %K
extern int Dperiod=3; // %D сигнальная
extern int Slowing=3; // замедление
extern int Dmethod=0; // тип MA сигнальной: 0-SMA, 1-EMA
extern int PriceFild=0; // тип цены: 0-High/Low; 1-Close/Close
extern int Sens=0; // чувствительность в пп.
 int History=0; // история пересчета: 0 - все бары

// инд.буферы
double   Main[]; // главная
double   Signal[]; // сигнальная

// общие переменные
bool first=1; // флаг первого запуска
double sens; // чувствительность в ценах
double kd; // коэфф. EMA для сигнальной

int init()
  {
   first=1;
   sens=Sens*Point; // чувствительность в ценах
   if(Dmethod==1) kd=2.0/(1+Dperiod); // коэфф. EMA для сигнальной

   // буфер главной   
   SetIndexBuffer(0,Main);
   SetIndexStyle(0,DRAW_LINE);
   string _str="("+Kperiod+","+Slowing+")";
   SetIndexLabel(0,"Main"+_str);
   // буфер сигнальной
   SetIndexBuffer(1,Signal);
   SetIndexStyle(1,DRAW_LINE);
   _str="("+Dperiod+")";
   SetIndexLabel(1,"Signal"+_str);

   // короткое имя
   if(Sens!=0) string ShName=Sens+" ";
   ShName=ShName+"Stoch ";
   if(PriceFild==0) ShName=ShName+"H/L";
   else ShName=ShName+"C/C";
   ShName=ShName+" ("+Kperiod+","+Dperiod+","+Slowing+")";
   IndicatorShortName(ShName);   
   
   return(0);
  }

int reinit() // ф-я дополнительной инициализации
  {
   ArrayInitialize(Main,0.0);
   ArrayInitialize(Signal,0.0);
   return(0);
  }

int start()
  {
   int ic=IndicatorCounted();
   if(!first && Bars-ic-1>1) ic=reinit(); first=0;
   //int limit=Bars-ic-1; // кол-во пересчетов
   //if(History!=0 && limit>History) limit=History-1; // кол-во пересчетов по истории
   
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+Slowing;

   for(int i=limit; i>=0; i--) { // цикл пересчета по ВСЕМ барам
      // главная
      Main[i]=Stoch(Kperiod, Slowing, PriceFild, sens, i);
      // сигнальнаяё
      switch(Dmethod) {
         case 1: // EMA
            Signal[i]=kd*Main[i]+(1-kd)*Signal[i+1]; break;
         case 0: // SMA
            int sh=i+Dperiod;
            double ma=Signal[i+1]*Dperiod-Main[sh];
            Signal[i]=(ma+Main[i])/Dperiod;
        }
     }
   return(0);
  }

double Stoch(int Kperiod, int Slowing, int PriceFild, double sens, int i) {  
   // экстремумы цены
   double max,min,c;
   for(int j=i; j<i+Slowing; j++) {
      if(PriceFild==1) { // по Close
         max+=Close[ArrayMaximum(Close,Kperiod,j)];
         min+=Close[ArrayMinimum(Close,Kperiod,j)];
        }
      else { // по High/Low
         max+=High[ArrayMaximum(High,Kperiod,j)];
         min+=Low[ArrayMinimum(Low,Kperiod,j)];
        }
      c+=Close[j];
     }
   
   double delta=max-min;
   if(delta<sens) {
      double sens2=sens/2;
      max+=sens2; min-=sens2;
     }
   delta=max-min;
   if(delta==0) double s0=1;
   else s0=(c-min)/delta;

   return(100*s0);
  }