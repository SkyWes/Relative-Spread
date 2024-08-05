//+------------------------------------------------------------------+
//|                                                        SpreadvsRange.mq5 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                        http://www.metaquotes.net                  |
//+------------------------------------------------------------------+

#property indicator_chart_window
#define XPOS 5 //-- x axis position from left edge
#define YDIF 15 //-- space on the y axis between comments
#define FIRST 25           //-- y axis position of first comment
#define SECOND FIRST+YDIF  //-- y axis position of second comment
#define THIRD  SECOND+YDIF //-- y axis position of third comment
#define FOURTH THIRD+YDIF  //-- y axis position of fourth comment
#define FIFTH  FOURTH+YDIF //-- y axis position of fifth comment

int bars = 50; // The number of bars to calculate the average range

void CommentDraw(string CommentText, string label_name, int y);

string long_comment;
string short_comment;
string spread_range;
string rel_spread;
string spread_val;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnStart()
  {
   
   double new_ask{};
   double ask{};
   
   while(!IsStopped())
     {
      ask = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
      //Only calculate if ask has changed.
      if(new_ask==ask)
         continue;
       
      new_ask=ask;
      //Get values
      double bid = SymbolInfoDouble(Symbol(),SYMBOL_BID);  
      double avgRange = CalculateAverageRange(bars);
      double spreadValue = ask - bid;
      double spreadPercentage = (spreadValue / avgRange) * 100;
      double midPrice = (bid + ask) / 2;
      double relativeSpread = ((ask - bid) / midPrice) * 100;
      
      double long_swap;
      double short_swap;
      SymbolInfoDouble(Symbol(),SYMBOL_SWAP_LONG,long_swap);
      SymbolInfoDouble(Symbol(),SYMBOL_SWAP_SHORT,short_swap);
      //Build strings
      long_comment = "Long Swap : " + DoubleToString(long_swap,2);
      short_comment = "Short Swap : " + DoubleToString(short_swap,2);
      spread_range = "Spread / AvgRange : " + DoubleToString(spreadPercentage,2) + " %";
      spread_val = "Spread : " + DoubleToString(spreadValue,2);
      rel_spread = "Relative Spread : " + DoubleToString(relativeSpread,2) + " %";
      
      CommentDraw(spread_val,"spread_val",FIRST);
      CommentDraw(spread_range,"spread_range",SECOND);
      CommentDraw(rel_spread, "rel_spread",THIRD);
      CommentDraw(long_comment,"long_comment",FOURTH);
      CommentDraw(short_comment, "short_comment",FIFTH);
      
     }
     
   //--Delete chart objects
   CommentDraw("","spread_val");
   CommentDraw("","spread_range");
   CommentDraw("", "rel_spread");
   CommentDraw("","long_comment");
   CommentDraw("", "short_comment");
  }

//+------------------------------------------------------------------+
//| Function to calculate the average range of the last X bars       |
//+------------------------------------------------------------------+
double CalculateAverageRange(int b)
  {
   double totalRange = 0;
   double High[];
   double Low[];
   ArrayResize(High,b);
   ArrayResize(Low,b);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   CopyHigh(_Symbol,PERIOD_CURRENT,1,b,High);
   CopyLow(_Symbol,PERIOD_CURRENT,1,b,Low);
   
   for(int i = 1; i < b; i++)
     {
      double range =  High[i] - Low[i];
      totalRange += range;
     }

   return totalRange / bars;
  }
//+------------------------------------------------------------------+
void CommentDraw(string CommentText, string label_name, int y=25)
  {
   int CommentIndex = 0;

   if(CommentText == "")
     {
      //  delete all Comment texts
      while(ObjectFind(0,label_name) >= 0)
        {
         ObjectDelete(0,label_name);
         CommentIndex++;
        }
      return;
     }


//    Print("CommentText: ",CommentText);

   ObjectCreate(0,label_name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,label_name, OBJPROP_CORNER,CORNER_LEFT_UPPER);
//--- set X coordinate
   ObjectSetInteger(0,label_name,OBJPROP_XDISTANCE,XPOS);
//--- set Y coordinate
   ObjectSetInteger(0,label_name,OBJPROP_YDISTANCE,y);
//--- define text color
   ObjectSetInteger(0,label_name,OBJPROP_COLOR,clrBlack);
//--- define text for object Label
   ObjectSetString(0,label_name,OBJPROP_TEXT,CommentText);
//--- define font
   ObjectSetString(0,label_name,OBJPROP_FONT,"Arial");
//--- define font size
   ObjectSetInteger(0,label_name,OBJPROP_FONTSIZE,8);
//--- disable for mouse selecting
   ObjectSetInteger(0,label_name,OBJPROP_SELECTABLE,true);
//--- draw it on the chart
   ChartRedraw(0);

  }