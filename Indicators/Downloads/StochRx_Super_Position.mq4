//+------------------------------------------------------------------+
//|                                            Cronex StochR% SP.mq4 |
//|                                        Copyright © 2007, Cronex. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2007, Cronex"
#property  link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 6
#property  indicator_color1  Silver
#property  indicator_color2  DarkOrange
#property  indicator_color3  Black
#property  indicator_color4  OrangeRed
#property  indicator_color5  SteelBlue
#property  indicator_color6  SteelBlue
#property  indicator_level1 -0.20
#property  indicator_level2  0.20
#property  indicator_level3  0.50
#property  indicator_level4  0.80
#property  indicator_width4  2
#property  indicator_width5  2
//---- indicator parameters
extern int R5=14;
extern int StochK=7;
extern int StochD=5;
extern int FastMA=10;
extern int SlowMA=10;
//---- indicator buffers
double     R5Buffer[];
double     StochBuffer[];
double     SPBuffer[];
double     FastMABuffer[];
double     SlowMABuffer[];
double     TmpDiverBuff[];
double     DiverBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(7);
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);   
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexStyle(5,DRAW_HISTOGRAM);
   SetIndexDrawBegin(1,SlowMA);
//   IndicatorDigits(Digits+1);
//---- indicator buffers mapping
   SetIndexBuffer(0,R5Buffer);
   SetIndexBuffer(1,StochBuffer);
   SetIndexBuffer(2,SPBuffer);
   SetIndexBuffer(3,FastMABuffer);
   SetIndexBuffer(4,SlowMABuffer);
   SetIndexBuffer(5,DiverBuffer);
   SetIndexBuffer(6,TmpDiverBuff);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("StochR% SP");
   SetIndexLabel(0,"%R");
   SetIndexLabel(1,"Stoch");
   SetIndexLabel(2,"Stoch %R Super Position");
   SetIndexLabel(3,"Fast MA");
   SetIndexLabel(4,"Slow MA");
   SetIndexLabel(5,"Stoch %R Divergence");
//   SetIndexShift(3,-2);

//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Cronex R5                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- R5 counted in the 1-st buffer

   for(int i=0; i<limit; i++)
   {
      R5Buffer[i]=(iWPR(NULL,0,R5,i)+100)/100;
      StochBuffer[i]=iStochastic(NULL,0,StochK,StochD,3,MODE_LWMA,0,MODE_MAIN,i)/100;
      SPBuffer[i]=(R5Buffer[i]+StochBuffer[i])/2;
      TmpDiverBuff[i]=R5Buffer[i]-StochBuffer[i];
      
    }  
      
//---- signal line counted in the 2-nd buffer
   for(i=0; i<limit; i++)
    {  
      FastMABuffer[i]=iMAOnArray(SPBuffer,Bars,FastMA,0,MODE_LWMA,i);
    } 
   for(i=0; i<limit; i++)
    {  
      SlowMABuffer[i]=iMAOnArray(FastMABuffer,Bars,SlowMA,0,MODE_LWMA,i);
      DiverBuffer[i]=iMAOnArray(TmpDiverBuff,Bars,SlowMA,0,MODE_LWMA,i);
    }     
    
//---- done
   return(0);
  }
//+------------------------------------------------------------------+