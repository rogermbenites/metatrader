//+------------------------------------------------------------------+
//|                        Smoothed RSI Inverse Fisher Transform.mq4 |
//|                                     © 2011 MaryJane@ForexFactory |
//|   Indicator formula © 2010 Sylvain Vervoort, http://stocata.org/ |
//|                                Alert routine code © 2011 hanover |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, MaryJane"
#property link      "http://www.forexfactory.com/MaryJane"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 1
#property indicator_color1 Blue
#property indicator_width1 3
#property indicator_level1 12
#property indicator_level2 88
#property indicator_levelcolor DimGray
//--- input parameters
extern int     RsiPeriod=4;
extern int     EmaPeriod=4;
extern int     AlertCandle         = 1;
extern int     AlertLevelUp        = 12;
extern int     AlertLevelDown      = 88;
extern bool    ShowChartAlerts     = false;
extern string  AlertEmailSubject   = "";
extern int     BarCount            = 500;

datetime       OldTime;
datetime       LastAlertTime       = -999999;
string         AlertTextCrossUp    = "SVE RSI I-Fish UP";
string         AlertTextCrossDown  = "SVE RSI I-Fish DOWN";

//--- buffers
double wma0[],wma1[],wma2[],wma3[],wma4[],wma5[],wma6[],wma7[],wma8[],wma9[];
double ema0[],ema1[],rainbow[],rsi[],srsi[],fish[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName(StringConcatenate("SVE RSI I-Fish (",RsiPeriod,",",EmaPeriod,")"));
//---- indicators
   IndicatorBuffers(6);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,fish);
   SetIndexBuffer(1,rainbow);
   SetIndexBuffer(2,rsi);
   SetIndexBuffer(3,ema0);
   SetIndexBuffer(4,ema1);
   SetIndexBuffer(5,srsi);
   ArrayResize(wma0,BarCount); ArraySetAsSeries(wma0,true);
   ArrayResize(wma1,BarCount); ArraySetAsSeries(wma1,true);
   ArrayResize(wma2,BarCount); ArraySetAsSeries(wma2,true);
   ArrayResize(wma3,BarCount); ArraySetAsSeries(wma3,true);
   ArrayResize(wma4,BarCount); ArraySetAsSeries(wma4,true);
   ArrayResize(wma5,BarCount); ArraySetAsSeries(wma5,true);
   ArrayResize(wma6,BarCount); ArraySetAsSeries(wma6,true);
   ArrayResize(wma7,BarCount); ArraySetAsSeries(wma7,true);
   ArrayResize(wma8,BarCount); ArraySetAsSeries(wma8,true);
   ArrayResize(wma9,BarCount); ArraySetAsSeries(wma9,true);
//---- reset counter  
   OldTime=Time[0];
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1;

//---- resize/shift extra buffers on first and every next bar
   if(Time[0]!=OldTime) SyncExtraBuffers();

   int size=Bars;
   ArrayResize(wma0,size);
   ArrayResize(wma1,size);
   ArrayResize(wma2,size);
   ArrayResize(wma3,size);
   ArrayResize(wma4,size);
   ArrayResize(wma5,size);
   ArrayResize(wma6,size);
   ArrayResize(wma7,size);
   ArrayResize(wma8,size);
   ArrayResize(wma9,size);

//---- prepare partial averages
   for(int i=limit; i>=0; i--) wma0[i]=iMA(NULL,0,2,0,MODE_LWMA,PRICE_CLOSE,i);
   for(i = limit; i >= 0; i--) wma1[i] = iMAOnArray(wma0, 0, 2, 0, MODE_LWMA, i);
   for(i = limit; i >= 0; i--) wma2[i] = iMAOnArray(wma1, 0, 2, 0, MODE_LWMA, i);
   for(i = limit; i >= 0; i--) wma3[i] = iMAOnArray(wma2, 0, 2, 0, MODE_LWMA, i);
   for(i = limit; i >= 0; i--) wma4[i] = iMAOnArray(wma3, 0, 2, 0, MODE_LWMA, i);
   for(i = limit; i >= 0; i--) wma5[i] = iMAOnArray(wma4, 0, 2, 0, MODE_LWMA, i);
   for(i = limit; i >= 0; i--) wma6[i] = iMAOnArray(wma5, 0, 2, 0, MODE_LWMA, i);
   for(i = limit; i >= 0; i--) wma7[i] = iMAOnArray(wma6, 0, 2, 0, MODE_LWMA, i);
   for(i = limit; i >= 0; i--) wma8[i] = iMAOnArray(wma7, 0, 2, 0, MODE_LWMA, i);
   for(i = limit; i >= 0; i--) wma9[i] = iMAOnArray(wma8, 0, 2, 0, MODE_LWMA, i);
//---- weigh the averages
   for(i=limit; i>=0; i--)
     {
      rainbow[i]=(5*wma0[i]+4*wma1[i]+3*wma2[i]+2*wma3[i]+wma4[i]+wma5[i]+wma6[i]+wma7[i]+wma8[i]+wma9[i])/20;
     }
//---- calculate rsi from rainbow smoothed price curve 
   for(i=limit; i>=0; i--) rsi[i]=0.1 *(iRSIOnArray(rainbow,0,RsiPeriod,i)-50);
//---- smooth the rsi with Vervoort zero lag MA
   for(i = limit; i >= 0; i--) ema0[i] = iMAOnArray(rsi, 0, EmaPeriod, 0, MODE_EMA, i);
   for(i = limit; i >= 0; i--) ema1[i] = iMAOnArray(ema0, 0, EmaPeriod, 0, MODE_EMA, i);
   for(i = limit; i >= 0; i--) srsi[i] = ema0[i] + (ema0[i] - ema1[i]);
//---- do the fish
   for(i=limit; i>=0; i--) fish[i]=((MathExp(2*srsi[i])-1)/(MathExp(2*srsi[i])+1)+1)*50;
//----
   ProcessAlerts();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Shift array elements on new bar                                  |
//+------------------------------------------------------------------+
void SyncExtraBuffers()
  {
   int size=ArraySize(wma1);
   for(int i=size-1; i>=0; i--)
     {
      wma0[i + 1] = wma0[i];
      wma1[i + 1] = wma1[i];
      wma2[i + 1] = wma2[i];
      wma3[i + 1] = wma3[i];
      wma4[i + 1] = wma4[i];
      wma5[i + 1] = wma5[i];
      wma6[i + 1] = wma6[i];
      wma7[i + 1] = wma7[i];
      wma8[i + 1] = wma8[i];
      wma9[i + 1] = wma9[i];
     }
//---- reset counter   
   OldTime=Time[0];
  }
//+------------------------------------------------------------------+
//  Alert routine by hanover
//  http://www.forexfactory.com/showthread.php?t=299520
//+------------------------------------------------------------------+                                                                          //
int ProcessAlerts() 
  {                                                                                                                         //
//+------------------------------------------------------------------+                                                                          //
   if(AlertCandle>=0 && Time[0]>LastAlertTime) 
     {                                                                                        //
      //
      // === Alert processing for crossover UP (indicator line crosses ABOVE signal line) ===                                                     //
      if(fish[AlertCandle]>AlertLevelUp && fish[AlertCandle+1]<=AlertLevelUp) 
        {                                                           //
         string AlertText = Symbol()+ "," + TFToStr(Period()) + ": " + AlertTextCrossUp;                                                          //
         if(ShowChartAlerts)          Alert(AlertText);                                                                                           //
         if(AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);                                                                      //
        }                                                                                                                                           //
      //
      // === Alert processing for crossover DOWN (indicator line crosses BELOW signal line) ===                                                   //
      if(fish[AlertCandle]<AlertLevelDown && fish[AlertCandle+1]>=AlertLevelDown) 
        {                                                       //
         AlertText = Symbol()+ "," + TFToStr(Period()) + ": " + AlertTextCrossDown;                                                               //
         if(ShowChartAlerts)          Alert(AlertText);                                                                                           //
         if(AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);                                                                      //
        }                                                                                                                                           //
      //
      LastAlertTime = Time[0];                                                                                                                    //
     }                                                                                                                                             //
   return(0);                                                                                                                                    //
  }                                                                                                                                               //
//
//+------------------------------------------------------------------+                                                                          //
string TFToStr(int tf) 
  {                                                                                                                      //
//+------------------------------------------------------------------+                                                                          //
   if(tf == 0)        tf = Period();                                                                                                            //
   if(tf >= 43200)    return("MN");                                                                                                             //
   if(tf >= 10080)    return("W1");                                                                                                             //
   if(tf >=  1440)    return("D1");                                                                                                             //
   if(tf >=   240)    return("H4");                                                                                                             //
   if(tf >=    60)    return("H1");                                                                                                             //
   if(tf >=    30)    return("M30");                                                                                                            //
   if(tf >=    15)    return("M15");                                                                                                            //
   if(tf >=     5)    return("M5");                                                                                                             //
   if(tf >=     1)    return("M1");                                                                                                             //
   return("");                                                                                                                                   //
  }                                                                                                                                               //
// ============================================================================================================================================ //
